# Copyright 2013 Tufts University
#
# Licensed under the Educational Community License, Version 1.0 (the
# "License"); you may not use this file except in compliance with the
# License. You may obtain a copy of the License at
#
# http://www.opensource.org/licenses/ecl1.php
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

package TUSK::Medbiq::Competency::Framework;

###########
# * Imports
###########

use 5.008;
use strict;
use warnings;
use version; our $VERSION = qv('0.0.1');
use utf8;
use Carp;
use Readonly;

use TUSK::Meta::Attribute::Trait::Namespaced;
use TUSK::Namespaces ':all';
use TUSK::Types qw( Competency );
use TUSK::Medbiq::Types qw( CFIncludes CFLOM );
use Types::Standard qw( Maybe ArrayRef Str);
use Types::XSD qw( Date AnyURI );
use TUSK::LOM;
use TUSK::LOM::General;
use TUSK::LOM::Identifier;
use TUSK::Medbiq::Identifier;
use TUSK::Medbiq::Competency::Framework::Relation;

#########
# * Setup
#########

use Moose;
with 'TUSK::XML::Object';

####################
# * Class attributes
####################

has course_competencies => (
    is => 'ro',
    isa => ArrayRef[Competency],
    required => 1,
);

has event_competencies => (
    is => 'ro',
    isa => ArrayRef[Competency],
    required => 1,
);

has school_competencies => (
    is => 'ro',
    isa => ArrayRef[Competency],
    required => 1,
);

has national_competencies => (
    is => 'ro',
    isa => ArrayRef[Competency],
    required => 1,
);

has framework_id => (
    is => 'ro',
    isa => Str,
    required => 1,
);

has lom => (
    traits => [ qw(Namespaced) ],
    is => 'ro',
    isa => CFLOM,
    builder => '_build_lom',
    namespace => lom_ns,
);

has EffectiveDate => (
    is => 'ro',
    isa => Maybe[Date],
    lazy => 1,
    builder => '_build_EffectiveDate',
);

has RetiredDate => (
    is => 'ro',
    isa => Maybe[Date],
    lazy => 1,
    builder => '_build_RetiredDate',
);

has Replaces => (
    is => 'ro',
    isa => ArrayRef[AnyURI],
    lazy => 1,
    builder => '_build_Replaces',
);

has IsReplacedBy => (
    is => 'ro',
    isa => ArrayRef[AnyURI],
    lazy => 1,
    builder => '_build_IsReplacedBy',
);

has SupportingInformation => (
    is => 'ro',
    isa => ArrayRef[TUSK::Medbiq::Types::SupportingInformation],
    lazy => 1,
    builder => '_build_SupportingInformation',
);

has Includes => (
    is => 'ro',
    isa => CFIncludes,
    lazy => 1,
    builder => '_build_Includes',		 
);

has Relation => (
    is => 'ro',
    isa => ArrayRef[TUSK::Medbiq::Types::Relation],
    lazy => 1,
    builder => '_build_Relation',
);


############
# * Builders
############

sub _build_lom {
    my $self = shift;

    return TUSK::LOM->new(
	 general => TUSK::LOM::General->new(
	      identifier => [
 		      TUSK::LOM::Identifier->new(
			   catalog => 'URI',
			   entry => 'http://' . $TUSK::Constants::Domain . '/comoetency/framework/view/' . $self->framework_id,
		      ),
              ],
	     title => TUSK::LOM::LangString->new(string => ''),
	  )
    );
}

sub _build_Includes {
    my $self = shift;
    my @cf_includes = ();

    foreach my $comp (@{$self->school_competencies()},
		      @{$self->course_competencies()},
		      @{$self->event_competencies()}
		      ) {
	push @cf_includes, $self->_get_id_object($comp->getPrimaryKeyID());
    }

    return \@cf_includes;
}

sub _build_Relation { 
    my $self = shift;

    my @cf_relations = ();
    foreach my $comp (@{$self->national_competencies()},
		      @{$self->school_competencies()},
		      @{$self->course_competencies()},
		      @{$self->event_competencies()}
		      ) {
	if (my $relation = $comp->getJoinObject('TUSK::Competency::Relation'))  {
	    push @cf_relations, TUSK::Medbiq::Competency::Framework::Relation->new(
	       Reference1 => $self->_get_id_object($relation->getCompetencyId2()),
	       Relationship => 'http://www.w3.org/2004/02/skos/core#broader',
	       Reference2 => $self->_get_id_object($relation->getCompetencyId1()),
            );
	}
    }

    return \@cf_relations;
}

sub _build_namespace { competency_framework_ns }
sub _build_xml_content { [ qw( lom Includes Relation ) ] }

sub _build_EffectiveDate { return; }
sub _build_RetiredDate { return; }
sub _build_Replaces { [] }
sub _build_IsReplacedBy { [] }
sub _build_SupportingInformation { [] }

#################
# * Class methods
#################

###################
# * Private methods
###################

sub _get_id_object {
    my ($self, $id) = @_;
    return TUSK::Medbiq::Identifier->new(
	   Entry => 'http://' . $TUSK::Constants::Domain . '/comoetency/view/' . $id,
    );
}





###########
# * Cleanup
###########

__PACKAGE__->meta->make_immutable;
no Moose;
1;

###########
# * Perldoc
###########

__END__

=head1 NAME

TUSK::Medbiq::Competency::Framework - A short description of the module's purpose

=head1 VERSION

This documentation refers to L<TUSK::Medbiq::Competency::Framework> v0.0.1.

=head1 SYNOPSIS

  use TUSK::Medbiq::Competency::Framework;

=head1 DESCRIPTION

=head1 ATTRIBUTES

=head1 METHODS

=head1 DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

TUSK modules depend on properly set constants in the configuration
file loaded by L<TUSK::Constants>. See the documentation for
L<TUSK::Constants> for more detail.

=head1 INCOMPATIBILITIES

This module has no known incompatibilities.

=head1 BUGS AND LIMITATIONS

There are no known bugs in this module. Please report problems to the
TUSK development team (tusk@tufts.edu) Patches are welcome.

=head1 LICENSE AND COPYRIGHT

Copyright 2013 Tufts University

Licensed under the Educational Community License, Version 1.0 (the
"License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at

http://www.opensource.org/licenses/ecl1.php

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
