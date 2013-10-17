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

package TUSK::Medbiq::InstructionalMethod;

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

use Type::Utils -all;
use TUSK::Medbiq::Types qw( NonNullString );
use TUSK::Namespaces ':all';

#########
# * Setup
#########

use Moose;
with 'TUSK::XML::Object';

####################
# * Class attributes
####################

has content => (
    is => 'ro',
    isa => NonNullString,
    required => 1,
);

has primary => (
    is => 'ro',
    isa => enum([qw(true false)]),
    lazy => 1,
    builder => '_build_primary',
);

has source => (
    is => 'ro',
    isa => NonNullString,
    lazy => 1,
    builder => '_build_source',
);

has sourceID => (
    is => 'ro',
    isa => NonNullString,
    required => 1,
);

######################################
# * Medbiquitous instructional methods
######################################

Readonly my %METHOD_FROM_UID => (
    IM001 => 'Case-Based Instruction/Learning',
    IM002 => 'Clinical Experience - Ambulatory',
    IM003 => 'Clinical Experience - Inpatient',
    IM004 => 'Concept Mapping',
    IM005 => 'Conference',
    IM006 => 'Demonstration',
    IM007 => 'Discussion, Large Group (>12)',
    IM008 => 'Discussion, Small Group (≤12)',
    IM009 => 'Games',
    IM010 => 'Independent Learning',
    IM011 => 'Journal Club',
    IM012 => 'Laboratory',
    IM013 => 'Lecture',
    IM014 => 'Mentorship',
    IM015 => 'Patient Presentation - Faculty',
    IM016 => 'Patient Presentation - Learner',
    IM017 => 'Peer Teaching',
    IM018 => 'Preceptorship',
    IM019 => 'Problem-Based Learning (PBL)',
    IM020 => 'Reflection',
    IM021 => 'Research',
    IM022 => 'Role Play/Dramatization',
    IM023 => 'Self-Directed Learning',
    IM024 => 'Service Learning Activity',
    IM025 => 'Simulation',
    IM026 => 'Team-Based Learning (TBL)',
    IM027 => 'Team-Building',
    IM028 => 'Tutorial',
    IM029 => 'Ward Rounds',
    IM030 => 'Workshop',
);

Readonly my %UID_FROM_TYPE => (
    'Case-based Lecture' => 'IM001',
    'Case-based Small Group' => 'IM001',
    'Clinical Experiences' => 'IM003',
    'Clinical Pathologic Conference (CPC)' => 'IM005',
    'Clinical Skills Development' => 'IM003',
    'Computer-assisted instruction' => 'IM023',
    'Group Presentation' => 'IM016',
    'Lecture' => 'IM013',
    'Small Group' => 'IM008',
    'Conference' => 'IM005',
    'Laboratory' => 'IM012',
    'Seminar' => 'IM030',
    'Workshop' => 'IM030',
);

sub has_medbiq_translation {
    my $class = shift;
    my $type = shift;
    return exists $UID_FROM_TYPE{$type};
}

sub medbiq_method {
    my $class = shift;
    my $arg_ref = shift;
    my $type = $arg_ref->{class_meeting_type};
    my $primary = $arg_ref->{primary} ? 'true' : 'false';
    if (! exists $UID_FROM_TYPE{$type}) {
        confess "No Medbiquitous Instructional Method found for "
            . "class meeting type $type";
    }
    my $sourceID = $UID_FROM_TYPE{$type};
    my $content = $METHOD_FROM_UID{$sourceID};
    return $class->new(
        sourceID => $sourceID,
        primary => $primary,
        content => $content,
    );
}

#################
# * Class methods
#################

###################
# * Private methods
###################

sub _build_namespace { curriculum_inventory_ns }
sub _build_xml_content { shift->content }
sub _build_xml_attributes { [ qw(primary source sourceID) ] }

sub _build_source { 'http://medbiq.org/curriculum/vocabularies.pdf' }
sub _build_primary { 'false' }

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

TUSK::Medbiq::InstructionalMethod - A short description of the module's purpose

=head1 VERSION

This documentation refers to L<TUSK::Medbiq::InstructionalMethod> v0.0.1.

=head1 SYNOPSIS

  use TUSK::Medbiq::InstructionalMethod;

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
