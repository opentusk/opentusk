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
    };

    bless($self, $class);
  
    return $self;
 }

sub getScheduleCourses{
	my ($self, $user_id) = @_;

	my @courseTitles = ();
  	my @courseIds = ();
	my @timePeriods = ();
	my @startDates = ();
	my @endDates = ();
	my @siteNames = ();

	my $scheduleCourses = TUSK::Academic::LevelClinicalSchedule->new();
	my $sth = $scheduleCourses->databaseSelect(
		"SELECT t6.title, t7.period, t7.start_date, t7.end_date, t8.site_name, t6.course_id
		FROM " . $scheduleCourses->getDatabase() . ".academic_level_clinical_schedule AS t1 
		INNER JOIN tusk.academic_level AS t2
			ON (t1.academic_level_id = t2.academic_level_id) 
		INNER JOIN tusk.academic_level_course AS t3
			ON (t1.academic_level_id = t3.academic_level_id AND t2.academic_level_id = t3.academic_level_id)
		INNER JOIN tusk.course AS t4
			ON (t4.course_id = t3.course_id)
		INNER JOIN " . $self->{school_db} . ".link_course_student AS t5
			ON (t4.school_course_code = t5.parent_course_id)
		INNER JOIN " . $self->{school_db} . ".course AS t6
			ON (t6.course_id = t5.parent_course_id AND t6.course_id = t4.school_course_code)
		LEFT JOIN " . $self->{school_db} . ".time_period AS t7 
			ON t7.time_period_id = t5.time_period_id
		LEFT JOIN " . $self->{school_db} . ".teaching_site AS t8
			ON t8.teaching_site_id = t5.teaching_site_id
		WHERE (t5.child_user_id = '$user_id' AND t1.school_id = '$self->{school_id}')
		ORDER BY t7.start_date"
	);

	while (my ($title, $period, $startDate, $endDate, $siteName, $courseId) = $sth->fetchrow_array()) {
		push @courseIds, $courseId;
		push @courseTitles, $title;
		push @timePeriods, $period;
		push @startDates, $startDate;
		push @endDates, $endDate;
		push @siteNames, $siteName;
	}

	$sth->finish();

	return (\@courseIds, \@courseTitles, \@timePeriods, \@startDates, \@endDates, \@siteNames);
}

sub getScheduleStudents{
	my ($self, $academicLevelTitle, $academicYear) = @_;

	my $scheduleStudents = TUSK::Academic::LevelClinicalSchedule->new();
	my $sth = $scheduleStudents->databaseSelect(
	"SELECT DISTINCT t5.child_user_id, t8.lastname, t8.firstname
	FROM " . $scheduleStudents->getDatabase() . ".academic_level_clinical_schedule AS t1
	INNER JOIN tusk.academic_level AS t2
		ON (t1.academic_level_id = t2.academic_level_id)
	INNER JOIN tusk.academic_level_course AS t3
		ON (t1.academic_level_id = t3.academic_level_id AND t2.academic_level_id = t3.academic_level_id)
	INNER JOIN tusk.course AS t4
	  	ON (t4.course_id = t3.course_id)
	INNER JOIN " . $self->{school_db} . ".link_course_student AS t5
		ON (t4.school_course_code = t5.parent_course_id)
	INNER JOIN " . $self->{school_db} . ".course AS t6
		ON (t6.course_id = t5.parent_course_id AND t6.course_id = t4.school_course_code)
	LEFT JOIN " . $self->{school_db} . ".time_period AS t7 
		ON t7.time_period_id = t5.time_period_id
	INNER JOIN hsdb4.user AS t8 
	  	ON (t5.child_user_id = t8.user_id)
	WHERE (t1.school_id = '$self->{school_id}' AND t2.title = '$academicLevelTitle' AND t7.academic_year = '$academicYear')"
	);

	my @userIds = ();
	my @lastNames = ();
	my @firstNames = ();

	while (my ($userId, $lastName, $firstName) = $sth->fetchrow_array()) {
		push @userIds, $userId;
		push @lastNames, $lastName;
		push @firstNames, $firstName;
	}

	$sth->finish();

	return {
		userIds => \@userIds,
		lastNames => \@lastNames,
		firstNames => \@firstNames,
	};

}

sub getScheduleStudentsFiltering{
	my ($self) = @_;

	my $filter = TUSK::Academic::LevelClinicalSchedule->new();
	my $filterValues = $filter->lookup( "", undef, undef, undef,
    [
    	TUSK::Core::JoinObject->new('TUSK::Academic::Level',
        {
        	joinkey => 'academic_level_id', origkey => 'academic_level_id', jointype => 'inner',  alias => 't2',
            joincond => "t2.school_id = '$self->{school_id}'"
        }),
        TUSK::Core::JoinObject->new('TUSK::Core::HSDB45Tables::TimePeriod',
        {
            joinkey => 'academic_year', origkey => 't3.academic_year', jointype => 'right', database => $self->{school_db}, alias => 't3',
        })
    ]);

    return $filterValues;
}
1;
