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

package TUSK::Medbiq::Expectations;

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

use HSDB4::Constants;
use TUSK::Medbiq::Competency::Object;
use Types::Standard qw( ArrayRef HashRef InstanceOf Str);
use TUSK::Types qw(Competency);
use TUSK::Medbiq::Types;
use TUSK::Namespaces ':all';
use TUSK::Medbiq::Competency::Framework;

#########
# * Setup
#########

use Moose;
with 'TUSK::XML::Object';

####################
# * Class attributes
####################

has event_competencies => (
    is => 'ro',
    isa => ArrayRef[Competency],
    required => 1,
);

has course_competencies => (
    is => 'ro',
    isa => ArrayRef[Competency],
    required => 1,
);

has school_competencies => (
    is => 'ro',
    isa => ArrayRef[Competency],
    lazy => 1,
    builder => '_build_school_competencies',
);

has national_competencies => (
    is => 'ro',
    isa => ArrayRef[Competency],
    lazy => 1,
    builder => '_build_national_competencies',
);

has framework_id => (
    is => 'ro',
    isa => Str,
    required => 1,
);

has CompetencyObject => (
    is => 'ro',
    isa => ArrayRef[TUSK::Medbiq::Types::CompetencyObject],
    lazy => 1,
    builder => '_build_CompetencyObject',
);

has CompetencyFramework => (
    is => 'ro',
    isa => TUSK::Medbiq::Types::CompetencyFramework,
    lazy => 1,
    builder => '_build_CompetencyFramework',
);


############
# * Builders
############

sub _build_school_competencies {
    my $self = shift;
    return $self->_competencies_relation('school', [ map { $_->getPrimaryKeyID() } @{$self->course_competencies()} ]);
}

sub _build_national_competencies {
    my $self = shift;
    return $self->_competencies_relation('national', [ map { $_->getPrimaryKeyID() } @{$self->school_competencies()} ]);
}

sub _build_CompetencyObject {
    my $self = shift;
    my @objects = ();

    foreach my $comp_group_by_level ($self->school_competencies(),
				     $self->course_competencies(),
				     $self->event_competencies()) {
	push @objects, @{ $self->_processCompetencyObjects($comp_group_by_level) };
    }
    return \@objects;
}

sub _build_CompetencyFramework {
    my $self = shift;
    return TUSK::Medbiq::Competency::Framework->new(
	    event_competencies => $self->event_competencies(),
	    course_competencies => $self->course_competencies(),
	    school_competencies => $self->school_competencies(),
	    national_competencies => $self->national_competencies(),
	    framework_id => $self->framework_id(),
    );
}

sub _build_namespace { curriculum_inventory_ns }
sub _build_xml_content { [ qw(CompetencyObject CompetencyFramework) ] }



###################
# * Private methods
###################
sub _processCompetencyObjects {
    my ($self, $competencies) = @_;

    my %hashes = map { $_->getPrimaryKeyID() => $_ } @$competencies;

    my @objects = ();
    foreach my $comp_id (sort keys %hashes) {
	push @objects, TUSK::Medbiq::Competency::Object->new(dao =>  $hashes{$comp_id});
    }
    return \@objects;
}

sub _competencies_relation {
    my ($self, $token, $linked_competencies) = @_;
    return [] unless scalar @$linked_competencies;

    return TUSK::Competency::Competency->lookup('', undef, undef, undef, [
	  TUSK::Core::JoinObject->new('TUSK::Enum::Data', {
	      jointype => 'inner',
	      origkey => 'competency_level_enum_id',
	      joinkey => 'enum_data_id',
	      alias => 'competency_level',
	  }),
	  TUSK::Core::JoinObject->new('TUSK::Competency::Relation', {
	      jointype => 'inner',
	      origkey => 'competency_id',
	      joinkey => 'competency_id_2',
	      joincond => 'competency_id_1 in (' . join(',', @$linked_competencies) . ')',
	  }),
	  TUSK::Core::JoinObject->new('TUSK::Feature::Link', {
	      origkey => 'competency_id',
	      joinkey => 'feature_id',
	  }),
	  TUSK::Core::JoinObject->new('TUSK::Enum::Data', {
	      origkey => 'feature_link.feature_type_enum_id',
	      joinkey => 'enum_data_id',
	      joincond => "feature_type.short_name = '$token'",
	      alias => 'feature_type',
	  }),
    ]);
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

TUSK::Medbiq::Expectations - A short description of the module's purpose

=head1 VERSION

This documentation refers to L<TUSK::Medbiq::Expectations> v0.0.1.

=head1 SYNOPSIS

  use TUSK::Medbiq::Expectations;

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
