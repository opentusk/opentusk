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

package TUSK::Medbiq::Event;

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

use MooseX::Types::Moose ':all';
use TUSK::Types ':all';
use TUSK::Medbiq::Namespaces ':all';

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
    isa => ClassMeeting,
    required => 1,
);

has id => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_id',
);

has Title => (
    is => 'ro',
    isa => NonNullString,
    lazy => 1,
    builder => '_build_Title',
);

has EventDuration => (
    is => 'ro',
    isa => xs_duration,
    lazy => 1,
    builder => '_build_EventDuration',
);

has Description => (
    is => 'ro',
    isa => Maybe[Str],
    lazy => 1,
    builder => '_build_Description',
);

has Keyword => (
    is => 'ro',
    isa => ArrayRef[Medbiq_Keyword],
    lazy => 1,
    builder => '_build_Keyword',
);

has Interprofessional => (
    is => 'ro',
    isa => Maybe[xs_boolean],
    lazy => 1,
    builder => '_build_Interprofessional',
);

has CompetencyObjectReference => (
    is => 'ro',
    isa => ArrayRef[Medbiq_CompetencyObjectReference],
    lazy => 1,
    builder => '_build_CompetencyObjectReference',
);

has ResourceType => (
    is => 'ro',
    isa => ArrayRef[Medbiq_VocabularyTerm],
    lazy => 1,
    builder => '_build_ResourceType',
);

has InstructionalMethod => (
    is => 'ro',
    isa => ArrayRef[Medbiq_InstructionalMethod],
    lazy => 1,
    builder => '_build_InstructionalMethod',
);

has AssessmentMethod => (
    is => 'ro',
    isa => ArrayRef[Medbiq_AssessmentMethod],
    lazy => 1,
    builder => '_build_AssessmentMethod',
);


############
# * Builders
############

sub _build_namespace { return curriculum_inventory_ns(); }
sub _build_xml_attributes { [ qw(id) ] }
sub _build_xml_content {
    return [ qw( Title EventDuration Description Keyword Interprofessional
                 CompetencyObjectReference ResourceType InstructionalMethod
                 AssessmentMethod ) ];
}

sub _build_Title {
    my $self = shift;
}

sub _build_EventDuration {
    my $self = shift;
}

sub _build_Description {
    my $self = shift;
}

sub _build_Keyword {
    my $self = shift;
}

sub _build_Interprofessional {
    my $self = shift;
}

sub _build_CompetencyObjectReference {
    my $self = shift;
}

sub _build_ResourceType {
    my $self = shift;
}

sub _build_InstructionalMethod {
    my $self = shift;
}

sub _build_AssessmentMethod {
    my $self = shift;
}


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

TUSK::Medbiq::Event - A short description of the module's purpose

=head1 VERSION

This documentation refers to L<TUSK::Medbiq::Event> v0.0.1.

=head1 SYNOPSIS

  use TUSK::Medbiq::Event;

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
