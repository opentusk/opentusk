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

package TUSK::Medbiq::Sequence;

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

use TUSK::Namespaces ':all';
use TUSK::Types qw( Competency AcademicLevel );
use Types::Standard qw( Maybe ArrayRef HashRef InstanceOf);
use TUSK::Medbiq::Types qw( NonNullString );
use TUSK::Medbiq::Sequence::Block;
use TUSK::Medbiq::Sequence::Block::Event;
use TUSK::Medbiq::Timing;
use TUSK::Medbiq::Dates;
use List::Util qw(maxstr minstr);

#########
# * Setup
#########

use Moose;
with 'TUSK::XML::Object';

####################
# * Class attributes
####################

has school => (
    is => 'ro',
    isa => TUSK::Types::School,
    required => 1,
);

has levels => (
    is => 'ro',
    isa => ArrayRef[AcademicLevel],
    required => 1,
);

has levels_with_courses => (
    is => 'ro',
    isa => ArrayRef[InstanceOf['TUSK::Course::AcademicLevel']],
    required => 1,
);

has SequenceBlock => (
    is => 'ro',
    isa => ArrayRef[TUSK::Medbiq::Types::SequenceBlock],
    lazy => 1,
    builder => '_build_SequenceBlock',
);


############
# * Builders
############

sub _build_namespace { curriculum_inventory_ns }
sub _build_xml_content { [ qw( SequenceBlock ) ] }

sub _processCourseData {
    my $self = shift;
    my %course_levels = ();
    my %class_meetings = ();

    foreach my $cl (@{$self->levels_with_courses()}) {
	my $course_id = $cl->getJoinObject('TUSK::Core::HSDB45Tables::Course')->getPrimaryKeyID();
	my $cm = $cl->getJoinObject('TUSK::Core::HSDB45Tables::ClassMeeting');
	$course_levels{$cl->getJoinObject('TUSK::AcademicLevel')->getSortOrder()}{$course_id} = $cl;
	$class_meetings{$course_id}{dates}{$cm->getMeetingDate()} = 1;
	$class_meetings{$course_id}{event_ids}{$cm->getPrimaryKeyID()} = $cm;
    }

    ## getting start/end dates for each course
    foreach my $course_id (keys %class_meetings) {
	my @dates = keys %{$class_meetings{$course_id}{dates}};
	$class_meetings{$course_id}{max_date} = maxstr @dates;
	$class_meetings{$course_id}{min_date} = minstr @dates;
    }

    return (\%course_levels, \%class_meetings);
}

sub _build_SequenceBlock {
    my $self = shift;
    my @blocks = ();

    my ($course_levels, $class_meetings) = $self->_processCourseData();
    my $required_type = 'Optional';

    foreach my $level (@{$self->levels()}) {
	my $level_id = $level->getSortOrder();
	next unless exists $course_levels->{$level_id};

	foreach my $course_id (keys %{$course_levels->{$level_id}}) {
	    my @block_events = ();
	    my @block_refs = ();
	    my %num_days = ();

	    foreach my $event_id (keys %{$class_meetings->{$course_id}{event_ids}}) {
	        my $meeting_date = $class_meetings->{$course_id}{event_ids}{$event_id}->getMeetingDate();
	        my $seq_block_event = TUSK::Medbiq::Sequence::Block::Event->new(
	           required => 'false',
                   EventReference => "/CurriculumInventory/Events/Event[\@id='$event_id']",
	           StartDate => $meeting_date,
		   EndDate => $meeting_date,
                );
		push @block_events, $seq_block_event;
	    }

	    my $timing = TUSK::Medbiq::Timing->new(
		Dates => TUSK::Medbiq::Dates->new(
			  StartDate => $class_meetings->{$course_id}{min_date}, 
			  EndDate => $class_meetings->{$course_id}{max_date},
	        ),
	        Duration => 'P' . scalar(keys %{$class_meetings->{$course_id}{dates}}) . 'D',
	   );

           my $academic_level = "/CurriculumInventory/AcademicLevels/Level[\@number='$level_id']";
	   my $course = $course_levels->{$level_id}{$course_id}->getJoinObject('TUSK::Core::HSDB45Tables::Course');

           my $seq_block = TUSK::Medbiq::Sequence::Block->new(
		      id => $course_id,
		      required => $required_type,
		      Title => $course->getTitle(),
		      Timing => $timing,
		      Level => $academic_level,
		      CompetencyObjectReference => [],
		      SequenceBlockEvent => \@block_events,
		      SequenceBlockReference => \@block_refs,
          );
          push @blocks, $seq_block;
	} ## course_id
    } ## academic_level_id
    return \@blocks;
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

TUSK::Medbiq::Sequence - A short description of the module's purpose

=head1 VERSION

This documentation refers to L<TUSK::Medbiq::Sequence> v0.0.1.

=head1 SYNOPSIS

  use TUSK::Medbiq::Sequence;

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
