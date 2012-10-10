# Copyright 2012 Tufts University 
#
# Licensed under the Educational Community License, Version 1.0 (the "License"); 
# you may not use this file except in compliance with the License. 
# You may obtain a copy of the License at 
#
# http://www.opensource.org/licenses/ecl1.php 
#
# Unless required by applicable law or agreed to in writing, software 
# distributed under the License is distributed on an "AS IS" BASIS, 
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
# See the License for the specific language governing permissions and 
# limitations under the License.


package TUSK::Application::CurriculumReport::UsergroupSummary;

use strict;
use TUSK::Application::CurriculumReport::CourseSummary;
use TUSK::Core::School;
use TUSK::Core::Objective;
use TUSK::Core::Keyword;
use HSDB4::Constants;
use TUSK::Course::CourseExclusion;

sub new {
	my $self;
	my $class = shift;
	($self->{'school'}, $self->{'usergroup_id'}, $self->{'timeperiod_ids'}, $self->{'include'}, $self->{'exclude'}) = @_;
	die "Missing school, usergroup_id and/or timeperiod_id\n" unless ($self->{'school'} && $self->{'usergroup_id'} && $self->{'timeperiod_ids'});
	$class = ref $class || $class;

	bless $self, $class;
	$self->init();
	return $self;
}


sub init {
	my $self = shift;
	
	eval {
		$self->{'dbh'} = HSDB4::Constants::def_db_handle();
	};
	die "$@\t... failed to obtain database handle!" if $@;

	my $school = TUSK::Core::School->new()->lookupReturnOne("school_name = '" . $self->{'school'} . "'");
	$self->{'school_id'}  = $school->getSchoolID( $self->{'school'} ); 
	$self->{'school_db'}  = $school->getSchoolDb;

	if ( $self->{'include'} ) {
		my $course = HSDB45::Course->new( _school => $self->{'school'}, _id => $self->{'include'} );
		my $course_exclusion = TUSK::Course::CourseExclusion->new()->lookupReturnOne( 'course_exclusion_type_id = 1 and course_id = ' . $course->getTuskCourseID() );

		if ($course_exclusion) {
			$course_exclusion->delete();
		}
	} elsif ( $self->{'exclude'} ) {
		my $course = HSDB45::Course->new( _school => $self->{'school'}, _id => $self->{'exclude'} );
		my $course_exclusion = TUSK::Course::CourseExclusion->new()->lookupReturnOne( 'course_exclusion_type_id = 1 and course_id = ' . $course->getTuskCourseID() );

		if (!$course_exclusion) {
			$course_exclusion = TUSK::Course::CourseExclusion->new();
			$course_exclusion->setCourseExclusionTypeID(1);
			$course_exclusion->setCourseID($course->getTuskCourseID);
			$course_exclusion->save();
		}
	}

	$self->generateCourseReports();
}


sub generateCourseReports {
	my $self  = shift;

    my $query = "	select
						tc.school_course_code 
					from 
						tusk.course tc,
						tusk.course_exclusion tce,
						" . $self->{'school_db'} . ".link_course_user_group l, 
						" . $self->{'school_db'} . ".course c
					where 
						tc.school_id = " . $self->{'school_id'} . " and
						tce.course_exclusion_type_id = 1 and
						tce.course_id = tc.course_id and
						l.child_user_group_id = " . $self->{'usergroup_id'} . " and
						l.time_period_id in (" . join(",", @{$self->{'timeperiod_ids'}}) . ") and
						l.parent_course_id = c.course_id and
						tc.school_course_code = c.course_id";

	eval {
		my $handle = $self->{'dbh'}->prepare($query);
		my ($course_id);

		$handle->execute();
		$handle->bind_columns(\$course_id);

		while($handle->fetch()) {
			push @{$self->{'excluded_courses'}}, $course_id;
		}
	};
	die "$@\t... failed to obtain excluded courses!" if $@;

    $query = "	select 
						l.parent_course_id,
						l.time_period_id,
						c.title,
						c.oea_code
					from 
						" . $self->{'school_db'} . ".link_course_user_group l, 
						" . $self->{'school_db'} . ".course c
					where 
						l.child_user_group_id = " . $self->{'usergroup_id'} . " and
						l.time_period_id in (" . join(",", @{$self->{'timeperiod_ids'}}) . ") and
						l.parent_course_id = c.course_id ";
	$query .= "		and
						c.course_id not in (" . join(",", @{$self->{'excluded_courses'}}) . ")" if ( $self->{'excluded_courses'} );
	$query .= "		order by
						c.title";

	eval {
		my $handle = $self->{'dbh'}->prepare($query);
		my ($course_id, $timeperiod_id, $title, $oea_code);

		$handle->execute();
		$handle->bind_columns(\$course_id, \$timeperiod_id, \$title, \$oea_code);

		my $meeting_types;
		while($handle->fetch()) {
			my $report = TUSK::Application::CurriculumReport::CourseSummary->new( $self->{'school'}, $course_id, $timeperiod_id );

			if ( defined( $self->{'timeperiods'}->{$course_id} ) ) {
				# Same course and usergroup for more than one time period... kind of ugly.
				# $self->{'timeperiods'} only gets used to look it up if there's no classes, so we can ignore it.
				# $self->{'titles'} doesn't change.
				my $temp_hash_ref = $report->classMeetingsReport;
				foreach my $key ( keys %{$temp_hash_ref} ) {
					if ( $temp_hash_ref->{$key} ) {
						$self->{'class_meetings'}->{$course_id}->{$key}->{'count'} += $temp_hash_ref->{$key}->{'count'};
						$self->{'class_meetings'}->{$course_id}->{$key}->{'time'}  += $temp_hash_ref->{$key}->{'time'};
					}
				}
			} else {
				$self->{'timeperiods'}->{$course_id}    = $timeperiod_id;
				$self->{'titles'}->{$course_id}         = $title;
				$self->{'class_meetings'}->{$course_id} = $report->classMeetingsReport();
#				$self->{'objectives'}->{$course_id}     = $report->objectivesReport();
#				$self->{'keywords'}->{$course_id}       = $report->keywordsReport();
			}

			foreach ( keys %{$self->{'class_meetings'}->{$course_id}} ) {
				$meeting_types->{$_} = 1;
			}
		}
		$self->{'types'} = [ sort keys %{$meeting_types} ];
	};
	die "$@\t... failed to obtain usergroup courses!" if $@;
}

sub excludeCourse {
	my $self = shift;
}

sub includeCourse {
	my $self = shift;

}

1
