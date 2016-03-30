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
use TUSK::Course::StudentNote;
use TUSK::Core::HSDB45Tables::TimePeriod;
use TUSK::Core::HSDB45Tables::LinkCourseTeachingSite;
use HSDB4::Constants;
use TUSK::Core::School;
use TUSK::Course;
use HSDB4::DateTime;

use Carp qw(cluck croak confess);

sub new {
	my ($class, $args) = @_;
	my $self = {
		school_id => $args->{school_id},
		school_db => TUSK::Core::School->new()->lookupKey($args->{school_id})->{_field_values}->{school_db},
	};

	bless($self, $class);
	return $self;
}

sub getScheduleCourses{
	my ($self, $arg_ref) = @_;

	croak("(ref($arg_ref)) isn't a hash reference.")
		if (ref($arg_ref) ne "HASH");

	my @courseTitles = ();
	my @courseIds = ();
	my @timePeriods = ();
	my @timePeriodIds = ();
	my @startDates = ();
	my @endDates = ();
	my @siteNames = ();
	my @teachingSiteIds = ();
	my $sqlSelection;
	my $sqlCoreStatement;
	my $sqlConditionals;
	my $sql;

	if ($arg_ref->{export_requested}){
		$sqlConditionals = "WHERE (t5.child_user_id = '$arg_ref->{user_id}' AND t1.school_id = '$self->{school_id}') AND t2.academic_level_id = '$arg_ref->{academic_level_id}' AND t7.academic_year = '$arg_ref->{academic_year}'";
	} else {
		$sqlConditionals = "WHERE (t5.child_user_id = '$arg_ref->{user_id}' AND t1.school_id = '$self->{school_id}')";
	}

	my $scheduleCourses = TUSK::Academic::LevelClinicalSchedule->new();
	$sqlSelection = "SELECT t6.title, t7.period, t7.start_date, t7.end_date, t8.site_name, t6.course_id, t7.time_period_id, t8.teaching_site_id";
	$sqlCoreStatement = "FROM " . $scheduleCourses->getDatabase() . ".academic_level_clinical_schedule AS t1 
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
			ON t8.teaching_site_id = t5.teaching_site_id";
	$sql = qq{
		$sqlSelection
		$sqlCoreStatement
		$sqlConditionals
		ORDER BY t7.start_date};

	my $sth = $scheduleCourses->databaseSelect($sql);

	while (my ($title, $period, $startDate, $endDate, $siteName, $courseId, $timePeriodId, $teachingSiteId) = $sth->fetchrow_array()) {
		push @courseIds, $courseId;
		push @courseTitles, $title;
		push @timePeriods, $period;
		push @startDates, $startDate;
		push @endDates, $endDate;
		push @siteNames, $siteName;
		push @timePeriodIds, $timePeriodId;
		push @teachingSiteIds, $teachingSiteId;
	}

	$sth->finish();

	return {
		courseIds => \@courseIds, 
		courseTitles => \@courseTitles, 
		timePeriods => \@timePeriods, 
		startDates => \@startDates, 
		endDates => \@endDates, 
		siteNames => \@siteNames,
		timePeriodIds => \@timePeriodIds,
		teachingSiteIds => \@teachingSiteIds
	};
}

sub noteInput{
	my ($self, $args) = @_;
	my $note = TUSK::Course::StudentNote->new();
	my $tuskCourseId = TUSK::Course->new()->getTuskCourseIDFromSchoolID($self->{school_id}, $args->{course_id});

	$note->setFieldValues({note => $args->{note},
		student_id => $args->{user_id},
		course_id => $tuskCourseId,
		date => HSDB4::DateTime->new()->out_mysql_timestamp()});

	eval {
		$note->save({
			user => $args->{modified_by}});
	};

	return "Error: $@" if ($@);

	return 'ok';
}

sub getScheduleStudents{
	my ($self, $academicLevelId, $academicYear) = @_;

	my %map = (
		"\'" => "\\'",
	);

	my $chars = join '', keys %map;
	$academicYear  =~ s/([$chars])/$map{$1}/g;

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
	WHERE (t1.school_id = '$self->{school_id}' AND t2.academic_level_id = '$academicLevelId' AND t7.academic_year = '$academicYear')
	ORDER BY t8.lastname ASC, t8.firstname ASC"
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
	my $sth = $filter->databaseSelect(
	"SELECT DISTINCT t2.title, t2.academic_level_id, t3.academic_year
	FROM tusk.academic_level_clinical_schedule AS t1 
	INNER JOIN tusk.academic_level AS t2
		ON (t1.academic_level_id = t2.academic_level_id)
	INNER JOIN " . $self->{school_db} . ".time_period AS t3 
	WHERE (t1.school_id = '$self->{school_id}' AND !(t3.academic_year IS NULL OR t3.academic_year = ''))
	ORDER BY t3.start_date DESC, t3.end_date DESC"
	);

	my %academicLevels;
	my @timePeriods = ();

	while (my ($academicLevelTitle, $academicLevelId, $timePeriod) = $sth->fetchrow_array())
	{
		$academicLevels{$academicLevelId} = $academicLevelTitle;
		push @timePeriods, $timePeriod;
	}

	$sth->finish();

	return {
		academicLevels => \%academicLevels,
		timePeriods => \@timePeriods
	}
}

sub constructStudentModificationCourses{
	my ($self, $academicLevelTitle) = @_;

	my @courses = ();
	my $sql = qq/
		SELECT t5.title, t5.course_id
		FROM tusk.academic_level_clinical_schedule AS t1 
		INNER JOIN tusk.academic_level AS t2
			ON (t1.academic_level_id = t2.academic_level_id) 
		INNER JOIN tusk.academic_level_course AS t3
			ON (t1.academic_level_id = t3.academic_level_id AND t2.academic_level_id = t3.academic_level_id)
		INNER JOIN tusk.course AS t4
			ON (t4.course_id = t3.course_id)
		INNER JOIN $self->{school_db}.course AS t5
			ON (t5.course_id = t4.school_course_code)
		WHERE (t1.school_id = ? AND t2.title = ?)
		ORDER BY t5.title ASC/;
	my $dbh = $self->{-dbh};
	my $sth = $dbh->prepare($sql);
	eval {
		$sth->execute(($self->{school_id}, $academicLevelTitle));
	};
	croak "error : $@ query $sql failed for class " . ref($self) if ($@);
	while (my ($course, $courseId) = $sth->fetchrow_array())
	{
		push @courses, {
			course => $course,
			courseId => $courseId
		};
	}

	return \@courses;
}

sub getStudentModificationTeachingSites{
	my ($self, $currentCourseId) = @_;
	my $dbh = HSDB4::Constants::def_db_handle();
	my @teachingSites = ();
	my $sql = qq/SELECT DISTINCT t1.site_name, t1.teaching_site_id
		FROM $self->{school_db}.teaching_site AS t1
		INNER JOIN $self->{school_db}.link_course_teaching_site AS t2
		ON (t1.teaching_site_id = t2.child_teaching_site_id)
		WHERE t2.parent_course_id = ?
		ORDER BY t1.site_name ASC/;
	
	my $sth = $dbh->prepare($sql);
	eval {
		$sth->execute($currentCourseId);
	};
	croak "error : $@ query $sql failed for class " . ref($self) if ($@);
	while (my ($teachingSite, $teachingSiteId) = $sth->fetchrow_array())
	{
		push @teachingSites, {
			teachingSite => $teachingSite,
			teachingSiteId => $teachingSiteId,
		};
	}

	return \@teachingSites;
}

sub getStudentModificationCourses{
	my ($self, $academicLevelTitle) = @_;
	my $dbh = HSDB4::Constants::def_db_handle();
	my @courses = ();
	my $sql = qq/
		SELECT t5.title, t5.course_id
		FROM tusk.academic_level_clinical_schedule AS t1 
		INNER JOIN tusk.academic_level AS t2
			ON (t1.academic_level_id = t2.academic_level_id) 
		INNER JOIN tusk.academic_level_course AS t3
			ON (t1.academic_level_id = t3.academic_level_id AND t2.academic_level_id = t3.academic_level_id)
		INNER JOIN tusk.course AS t4
			ON (t4.course_id = t3.course_id)
		INNER JOIN $self->{school_db}.course AS t5
			ON (t5.course_id = t4.school_course_code)
		WHERE (t1.school_id = ? AND t2.title = ?)
		ORDER BY t5.title ASC/;
	my $sth = $dbh->prepare($sql);
	eval {
		$sth->execute(($self->{school_id}, $academicLevelTitle));
	};
	croak "error : $@ query $sql failed for class " . ref($self) if ($@);
	while (my ($course, $courseId) = $sth->fetchrow_array())
	{
		push @courses, {
			course => $course,
			courseId => $courseId
		};
	}

	return \@courses;
}

sub getScheduleRotations{
	my ($self, $academicLevelId, $academicYear) = @_;
	my $dbh = HSDB4::Constants::def_db_handle();
	my @courses = ();

	my $sql = qq/
	SELECT DISTINCT t6.title, t6.course_id
	FROM tusk.academic_level_clinical_schedule AS t1
	INNER JOIN tusk.academic_level AS t2
		ON (t1.academic_level_id = t2.academic_level_id)
	INNER JOIN tusk.academic_level_course AS t3
		ON (t1.academic_level_id = t3.academic_level_id AND t2.academic_level_id = t3.academic_level_id)
	INNER JOIN tusk.course AS t4
		ON (t4.course_id = t3.course_id)
	INNER JOIN $self->{school_db}.link_course_student AS t5
		ON (t4.school_course_code = t5.parent_course_id)
	INNER JOIN $self->{school_db}.course AS t6
		ON (t6.course_id = t5.parent_course_id AND t6.course_id = t4.school_course_code)
	LEFT JOIN $self->{school_db}.time_period AS t7 
		ON t7.time_period_id = t5.time_period_id
	INNER JOIN hsdb4.user AS t8 
		ON (t5.child_user_id = t8.user_id)
	WHERE (t1.school_id = ? AND t2.academic_level_id = ? AND t7.academic_year = ?)/;

	my $sth = $dbh->prepare($sql);
	eval {
		$sth->execute(($self->{school_id}, $academicLevelId, $academicYear));
	};
	croak "error : $@ query $sql failed for class " . ref($self) if ($@);
	while (my ($courseTitle, $courseId) = $sth->fetchrow_array())
	{
		push @courses, {
			courseTitle => $courseTitle,
			courseId => $courseId
		};
	}

	return \@courses;
}

sub getScheduleRotationTimePeriods{
	my ($self, $args) = @_;
	my $dbh = HSDB4::Constants::def_db_handle();
	my @timePeriods = ();

	my $sqlSelection = "SELECT DISTINCT t7.time_period_id, t7.period, t7.start_date, t7.end_date";
	my $sqlConditionals = "WHERE (t1.school_id = ? AND t2.academic_level_id = ? AND t7.academic_year = ? AND t6.course_id = ?)";
	@sqlArgs = ($self->{school_id}, 
	$args->{academicLevelId},
	$args->{academicYear}, 
	$args->{courseId});

	my $sql = qq{
	$sqlSelection
	$args->{sqlCoreStatement} 
	$sqlConditionals
	ORDER BY t7.start_date, t7.end_date};

	my $sth = $dbh->prepare($sql);
	eval {
		$sth->execute(@sqlArgs);
	};
	croak "error : $@ query $sql failed for class " . ref($self) if ($@);

	while(my ($timePeriodId, $timePeriod, $startDate, $endDate) = $sth->fetchrow_array())
	{
		push @timePeriods, {
			timePeriod => $timePeriod,
			timePeriodId => $timePeriodId,
			startDate => $startDate,
			endDate => $endDate
		};
	}

	return \@timePeriods;
}

sub getScheduleRotationStudents{
	my ($self, $args) = @_;
	my $dbh = HSDB4::Constants::def_db_handle();
	$args->{sqlCoreStatement} = $args->{sqlCoreStatement} . 
	"\nINNER JOIN hsdb4.user AS t8 
		ON (t5.child_user_id = t8.user_id)";
	my @students = ();
	my @sqlArgs = ($self->{school_id}, 
		$args->{academicLevelId},
		$args->{academicYear}, 
		$args->{courseId},
		$args->{timePeriodId});

	my $sqlSelection = "SELECT DISTINCT t5.child_user_id, t8.lastname, t8.firstname";
	my $sqlConditionals = "WHERE (t1.school_id = ? AND t2.academic_level_id = ? AND t7.academic_year = ? AND t6.course_id = ? AND t7.time_period_id = ?)";

	my $sql = qq{
		$sqlSelection
		$args->{sqlCoreStatement} 
		$sqlConditionals
		ORDER BY t8.lastname ASC, t8.firstname ASC};
		
	my $sth = $dbh->prepare($sql);
	eval {
		$sth->execute(@sqlArgs);
	};
	croak "error : $@ query $sql failed for class " . ref($self) if ($@);

	while (my ($userId, $lastName, $firstName) = $sth->fetchrow_array()) {
		push @students, {
			userId => $userId,
			lastName => $lastName,
			firstName => $firstName
		};
	}

	return \@students;
}

sub getScheduleRotationDetails{
	my ($self, $args) = @_;

	
	$args->{sqlCoreStatement} = "FROM tusk.academic_level_clinical_schedule AS t1
	INNER JOIN tusk.academic_level AS t2
		ON (t1.academic_level_id = t2.academic_level_id)
	INNER JOIN tusk.academic_level_course AS t3
		ON (t1.academic_level_id = t3.academic_level_id AND t2.academic_level_id = t3.academic_level_id)
	INNER JOIN tusk.course AS t4
		ON (t4.course_id = t3.course_id)
	INNER JOIN $self->{school_db}.link_course_student AS t5
		ON (t4.school_course_code = t5.parent_course_id)
	INNER JOIN $self->{school_db}.course AS t6
		ON (t6.course_id = t5.parent_course_id AND t6.course_id = t4.school_course_code)
	LEFT JOIN $self->{school_db}.time_period AS t7 
		ON t7.time_period_id = t5.time_period_id";

	if ($args->{timePeriodsRequested}){
		return $self->getScheduleRotationTimePeriods($args);
	} elsif ($args->{studentsRequested}){
		return $self->getScheduleRotationStudents($args);
	}

	return;
}

sub deleteStudentFromCourse{
	my ($self, $sqlArgs) = @_;
	my $sql = qq/DELETE FROM $self->{school_db}.link_course_student
		WHERE parent_course_id = ? 
		AND time_period_id = ? 
		AND teaching_site_id = ? 
		AND child_user_id = ?
		LIMIT 1/;
	my $dbh = $self->{-dbh};
	my $rowsUpdates;
	eval {
		$rowsUpdates = $dbh->do($sql, undef, @{$sqlArgs});
	};
	warn "error : $@ query $sql failed for class " . ref($self) if ($@);
	return $rowsUpdates == 1 ? 'ok' : $dbh->errstr;
}

sub applyStudentModifications{
	my ($self, $args) = @_;
	my $modification = TUSK::Core::HSDB45Tables::LinkCourseTeachingSite->new();
	my $dbh = $modification->getDatabaseWriteHandle();
	$self->{-dbh} = $dbh;
	my @sqlArgs;

	if ($args->{delete_requested})
	{
		@sqlArgs = ($args->{course_id}, 
			$args->{current_time_period}, 
			$args->{current_teaching_site}, 
			$args->{user_id}
		);
		return $self->deleteStudentFromCourse(\@sqlArgs);  
	}

	my $sql;
	if ($args->{add_requested})
	{
		$sql = qq/INSERT INTO $self->{school_db}.link_course_student
		(time_period_id, teaching_site_id, child_user_id, parent_course_id)
		VALUES (?, ?, ?, ?)/;
		@sqlArgs = (
			$args->{requested_time_period}, 
			$args->{requested_teaching_site}, 
			$args->{user_id},
			$args->{course_id}
		);
	} else { 
		$sql = qq/UPDATE $self->{school_db}.link_course_student AS t3
		SET t3.time_period_id = ?
		, t3.teaching_site_id = ?
		WHERE t3.child_user_id = ? 
		AND t3.time_period_id = ?
		AND t3.teaching_site_id = ?
		AND t3.parent_course_id = ?/;

		@sqlArgs = (
			$args->{requested_time_period}, 
			$args->{requested_teaching_site}, 
			$args->{user_id},
			$args->{current_time_period},
			$args->{current_teaching_site},
			$args->{course_id}
		);
	}
	my $rowsUpdates;
	eval {
		$rowsUpdates = $dbh->do($sql, undef, @sqlArgs);
	};
	warn "error : $@ query $sql failed for class " . ref($self) if ($@);
	return $rowsUpdates == 1 ? 'ok' : $dbh->errstr;
}

sub checkNumberOfEnrolled{
	my ($self, $args) = @_;
	my $check = TUSK::Core::HSDB45Tables::LinkCourseTeachingSite->new();
	my @sqlArgs = ($args->{course_id},
		$args->{temp_time_period},
		$args->{temp_teaching_site}
	);
	my $sql = qq/SELECT COUNT(*)
	FROM $self->{school_db}.link_course_student AS t1
	WHERE t1.parent_course_id = ? 
	AND t1.time_period_id = ? 
	AND t1.teaching_site_id = ?/;
	my $sth = $check->databaseSelect($sql, @sqlArgs);
	my $alreadyEnrolled = -1;
	while (my ($already_enrolled) = $sth->fetchrow_array())
	{
		$alreadyEnrolled = $already_enrolled;
	}
	$sth->finish();
	return defined $alreadyEnrolled ? $alreadyEnrolled : -1;
}

1;
