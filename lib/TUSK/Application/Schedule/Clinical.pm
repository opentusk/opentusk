# Copyright 2012 Tufts University 

# Licensed under the Educational Community License, Version 1.0 (the "License"); 
# you may not use this file except in compliance with the License. 
# You may obtain a copy of the License at 

# http://www.opensource.org/licenses/ecl1.php 

# Unless required by applicable law or agreed to in writing, software 
# distributed under the License is distributed on an "AS IS" BASIS, 
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
# See the License for the specific language governing permissions and 
# limitations under the License.

package TUSK::Application::Schedule::Clinical;

use TUSK::Academic::LevelClinicalSchedule;

sub new {
    my ($class, $args) = @_;
  
    my $self = {
        school_id => $args->{school_id},
        school_db => $args->{school_db},
        user_id => $args->{user_id}
    };

    bless($self, $class);
  
    return $self;
 }

sub getScheduleCourses{
	my ($self) = @_;

	my @courseTitles = ();
  	my @courseIds = ();
	my @timePeriods = ();
	my @startDates = ();
	my @endDates = ();
	my @siteNames = ();

	my $scheduleCourses = TUSK::Academic::LevelClinicalSchedule->new();
	my $dB = $scheduleCourses->databaseSelect(
		"SELECT t6.title, t7.period, t7.start_date, t7.end_date, t8.site_name, t6.course_id
		FROM ".$scheduleCourses->getDatabase().".academic_level_clinical_schedule AS t1 
		INNER JOIN tusk.academic_level AS t2
		ON (t1.academic_level_id = t2.academic_level_id) 
		INNER JOIN tusk.academic_level_course AS t3
		ON (t1.academic_level_id = t3.academic_level_id AND t2.academic_level_id = t3.academic_level_id)
		INNER JOIN tusk.course AS t4
		ON (t4.course_id = t3.course_id)
		INNER JOIN ".$self->{school_db}.".link_course_student AS t5
		ON (t4.school_course_code = t5.parent_course_id)
		INNER JOIN ".$self->{school_db}.".course AS t6
		ON (t6.course_id = t5.parent_course_id AND t6.course_id = t4.school_course_code)
		LEFT JOIN ".$self->{school_db}.".time_period AS t7 
		ON t7.time_period_id = t5.time_period_id
		LEFT JOIN ".$self->{school_db}.".teaching_site AS t8
		ON t8.teaching_site_id = t5.teaching_site_id
		WHERE (t5.child_user_id = '$self->{user_id}' AND t1.school_id = '$self->{school_id}')"
	);

	while (my ($dBTitle, $dBPeriod, $dBStartDate, $dBEndDate, $dBSiteName, $dBCourseId) = $dB->fetchrow_array()) {
		push @courseIds, $dBCourseId;
		push @courseTitles, $dBTitle;
		push @timePeriods, $dBPeriod;
		push @startDates, $dBStartDate;
		push @endDates, $dBEndDate;
		push @siteNames, $dBSiteName;
	}

	$dB->finish();

	return (\@courseIds, \@courseTitles, \@timePeriods, \@startDates, \@endDates, \@siteNames);
}

1;
