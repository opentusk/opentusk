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

package TUSK::Medbiq::Competency::Object;

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
use Encode qw( encode decode );

use TUSK::LOM;
use TUSK::LOM::General;
use TUSK::LOM::Identifier;
use TUSK::LOM::LangString;

use TUSK::Namespaces ':all';
use TUSK::Meta::Attribute::Trait::Namespaced;
use Types::Standard qw( Maybe ArrayRef );
use TUSK::LOM::Types qw( LOM );
use TUSK::Medbiq::Types;
use TUSK::Types qw( Competency URI );
use TUSK::Medbiq::Competency::Category;

#########
# * Setup
#########

use Moose;
with 'TUSK::XML::Object';

####################
# * Class attributes
####################

has dao => (
    is => 'ro',
    isa => Competency,
    required => 1,
);

has lom => (
    traits => [qw(Namespaced)],
    is => 'ro',
    isa => LOM,
    lazy => 1,
    builder => '_build_lom',
    namespace => lom_ns,
);

has Status => (
    is => 'ro',
    isa => Maybe[TUSK::Medbiq::Types::Status],
    lazy => 1,
    builder => '_build_Status',
);

has Replaces => (
    is => 'ro',
    isa => ArrayRef[URI],
    lazy => 1,
    builder => '_build_Replaces',
);

has IsReplacedBy => (
    is => 'ro',
    isa => ArrayRef[URI],
    lazy => 1,
    builder => '_build_IsReplacedBy',
);

has Category => (
    is => 'ro',
    isa => ArrayRef[TUSK::Medbiq::Types::Category],
    lazy => 1,
    builder => '_build_Category',
);

has References => (
    is => 'ro',
    isa => Maybe[TUSK::Medbiq::Types::References],
    lazy => 1,
    builder => '_build_References',
);

has SupportingInformation => (
    is => 'ro',
    isa => Maybe[TUSK::Medbiq::Types::SupportingInformation],
    lazy => 1,
    builder => '_build_SupportingInformation',
);


############
# * Builders
############

sub _build_namespace { competency_object_ns }
sub _build_xml_content { [ qw( lom Status Replaces IsReplacedBy Category
                               References SupportingInformation ) ] }
sub _build_empty_tags { [ qw( Category ) ] }


sub _build_lom {
    my $self = shift;
    my $title_string = $self->dao->getDescription();
    chomp $title_string;

    my $pk = $self->dao->getPrimaryKeyID();
    my $uri = 'http://' . $TUSK::Constants::Domain . '/comoetency/competency/view/' . $pk;
    my $identifier = TUSK::LOM::Identifier->new(
        catalog => 'URI',
        entry => $uri,
    );
    my $title = TUSK::LOM::LangString->new(
        string => $title_string,
    );
    my $general = TUSK::LOM::General->new(
        identifier => [ $identifier ],
        title => $title,
    );
    return TUSK::LOM->new( general => $general );
}

sub _build_Category { 
    my $self = shift;

    my %levels = ( national => 'national',
		   school => 'program',
		   course => 'sequence-block',
		   class_meet => 'event',
		   content => 'event' );

    if (my $competency_level = $self->dao()->getJoinObject('TUSK::Enum::Data')) {
	if (exists $levels{$competency_level->getShortName()}) {
	    return [ TUSK::Medbiq::Competency::Category->new(level => $levels{$competency_level->getShortName()}) ];
	} else {
	    warn 'Competency id ' . $self->dao()->getPrimaryKeyID() . " has incorrect competency_level (" . $competency_level->getShortName() . ").\n";
	}
    }
    return [];
}

sub _build_Status { return; }

sub _build_Replaces { return []; }

sub _build_IsReplacedBy { return []; }

sub _build_References { return; }

sub _build_SupportingInformation { return; }


#################
# * Class methods
#################

###################
# * Private methods
###################

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

TUSK::Medbiq::Competency::Object - A short description of the module's purpose

=head1 VERSION

This documentation refers to L<TUSK::Medbiq::Competency::Object> v0.0.1.

=head1 SYNOPSIS

  use TUSK::Medbiq::Competency::Object;

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
