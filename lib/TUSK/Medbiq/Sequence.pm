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
use TUSK::Medbiq::Sequence::Block::Reference;
use TUSK::Medbiq::Timing;
use TUSK::Medbiq::Dates;
use List::Util qw(maxstr minstr);
use TUSK::Core::HSDB45Tables::Course;

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

sub _build_SequenceBlock {
    my $self = shift;
    my @blocks = ();
    my $courses = $self->_processCourseData();

    foreach my $course_id (sort { $courses->{$a}{level_id} <=> $courses->{$b}{level_id} || $a <=> $b } keys %$courses) {
	my @block_events = ();
	foreach my $event_id (sort { $a <=> $b } keys %{$courses->{$course_id}{event_ids}}) {
	    push @block_events, TUSK::Medbiq::Sequence::Block::Event->new(
		    required => 'false',
		    EventReference => "/CurriculumInventory/Events/Event[\@id='$event_id']",
	    );
	}

	my @block_refs = ();
	if ($courses->{$course_id}{child_courses}) {
	    foreach my $child_course_id (sort { $a <=> $b } @{$courses->{$course_id}{child_courses}}) {
		push @block_refs, TUSK::Medbiq::Sequence::Block::Reference->new(
		   xpath => "/CurriculumInventory/Sequence/SequenceBlock[\@id='$child_course_id']"
		);
	    }
	}

	next unless (scalar @block_events || scalar @block_refs);  ## either one is required

        my $seq_block = TUSK::Medbiq::Sequence::Block->new(
	   id => $course_id,
	   required => 'Optional',
	   Title => $courses->{$course_id}{title},
	   Timing => 
		   TUSK::Medbiq::Timing->new(
		       Dates => TUSK::Medbiq::Dates->new(
			 StartDate => $courses->{$course_id}{min_date}, 
			 EndDate => $courses->{$course_id}{max_date},
		       ),
		       Duration => 'P' . scalar(keys %{$courses->{$course_id}{dates}}) . 'D',
		   ),
		   Level => "/CurriculumInventory/AcademicLevels/Level[\@number='$courses->{$course_id}{level_id}']",
	   CompetencyObjectReference => $self->_getCompObjRefs($courses->{$course_id}{competencies}),
	   SequenceBlockEvent => \@block_events,
	   SequenceBlockReference => \@block_refs,
	);

        push @blocks, $seq_block;
    }

    return \@blocks;
}


#################
# * Class methods
#################

###################
# * Private methods
###################

sub _processCourseData {
    my $self = shift;

    my %class_meetings = ();
    my %course_data = ();

    foreach my $cl (@{$self->levels_with_courses()}) {
	my $course = $cl->getJoinObject('hsdb45_course');
	my $course_id = $course->getPrimaryKeyID();

	$course_data{$course_id}{level_id} = $cl->getJoinObject('TUSK::Academic::Level')->getSortOrder();
	$course_data{$course_id}{title} = $course->getTitle();
	$course_data{$course_id}{description} = $course->getBody();
	$course_data{$course_id}{competencies} = $cl->getJoinObjects('TUSK::Competency::Competency');

	foreach my $cm (@{$cl->getJoinObjects('TUSK::Core::HSDB45Tables::ClassMeeting')}) {
	    $course_data{$course_id}{dates}{$cm->getMeetingDate()} = 1;
	    $course_data{$course_id}{event_ids}{$cm->getPrimaryKeyID()} = $cm;
	}
    }

    ## getting start/end dates for each course
    foreach my $course_id (keys %course_data) {
	my @dates = keys %{$course_data{$course_id}{dates}};
	$course_data{$course_id}{max_date} = maxstr @dates;
	$course_data{$course_id}{min_date} = minstr @dates;
    }

    ## getting parent courses if available
    if (my @course_ids = keys %course_data) {
	my $pcourses = $self->_getParentCourses(\@course_ids);

	foreach my $pcourse (@{$pcourses}) {
	    my $pcourse_id = $pcourse->getPrimaryKeyID();
	    $course_data{$pcourse_id}{level_id} = $pcourse->getJoinObject('TUSK::Academic::Level')->getSortOrder();
	    $course_data{$pcourse_id}{title} = $pcourse->getTitle();
	    $course_data{$pcourse_id}{description} = $pcourse->getBody();

	    ### getting child courses 
	    if (my $child_courses = $pcourse->getJoinObjects('tusk_child_course')) {
		foreach my $child_course (@$child_courses) {
		    push @{$course_data{$pcourse_id}{child_courses}}, $child_course->getSchoolCourseCode();
		}
	    }

	    ### and figuring timing for parent courses based on children
	    if (exists $course_data{$pcourse_id}{child_courses}) {
		foreach my $child_course_id (@{$course_data{$pcourse_id}{child_courses}}) {
		    foreach my $date (keys %{$course_data{$child_course_id}{dates}}) {
			$course_data{$pcourse_id}{dates}{$date} = 1;
		    }

		    my @pcourse_dates = keys %{$course_data{$pcourse_id}{dates}};
		    $course_data{$pcourse_id}{max_date} = maxstr @pcourse_dates;
		    $course_data{$pcourse_id}{min_date} = minstr @pcourse_dates;
		}
	    }
	}
    }

    return \%course_data;
}

sub _getParentCourses {
    my ($self, $child_course_ids) = @_;

    my $course = TUSK::Core::HSDB45Tables::Course->new();
    $course->setDatabase($self->school()->getSchoolDb());
    my $parent_courses = $course->lookup('', undef, undef, undef, [
	   TUSK::Core::JoinObject->new('TUSK::Course', {
	       jointype => 'inner',
	       origkey => 'course_id',
	       joinkey => 'school_course_code',
	       alias => 'tusk_course',
	   }),
	   TUSK::Core::JoinObject->new('TUSK::Core::LinkCourseCourse', {
	       jointype => 'inner',
	       origkey => 'tusk_course.course_id',
	       joinkey => 'parent_course_id',
	   }),
	   TUSK::Core::JoinObject->new('TUSK::Course', {
	       jointype => 'inner',
	       origkey => 'link_course_course.child_course_id',
	       joinkey => 'course_id',
	       joincond => 'tusk_child_course.school_course_code in (' . join(',', @$child_course_ids) . ')',
	       alias => 'tusk_child_course',
	   }),
	   TUSK::Core::JoinObject->new('TUSK::Course::AcademicLevel', {
	       jointype => 'inner',
	       origkey => 'tusk_course.course_id',
	       joinkey => 'course_id',
	   }),
	   TUSK::Core::JoinObject->new('TUSK::Academic::Level', {
	       jointype => 'inner',
	       origkey => 'academic_level_course.academic_level_id',
	       joinkey => 'academic_level_id',
	       joincond => 'academic_level.school_id = ' . $self->school()->getPrimaryKeyID(),
	   }),
        ]);
}

sub _getCompObjRefs {
    my ($self, $competencies) = @_;

    if ($competencies) {
	my $co_ref_fmt = '/CurriculumInventory/Expectations/CompetencyObject'
	    . "[lom:lom/lom:general/lom:identifier/lom:entry='"
	    . 'http://'
	    . $TUSK::Constants::Domain
	    . '/competency/competency/view/%d'
	    . "']";

	return [ map { sprintf($co_ref_fmt, $_) } sort (map { $_->getPrimaryKeyID() } @$competencies) ];
    }
    return [];
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
