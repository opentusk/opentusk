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
use TUSK::Core::HSDB45Tables::TimePeriod;
use TUSK::Core::HSDB45Tables::LinkCourseTeachingSite;
use Carp qw(cluck croak confess);

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

    return {
        courseIds => \@courseIds, 
        courseTitles => \@courseTitles, 
        timePeriods => \@timePeriods, 
        startDates => \@startDates, 
        endDates => \@endDates, 
        siteNames => \@siteNames
    };
}

sub getScheduleStudents{
    my ($self, $academicLevelTitle, $academicYear) = @_;

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
    my $sth = $filter->databaseSelect(
    "SELECT DISTINCT t2.title, t3.academic_year
    FROM tusk.academic_level_clinical_schedule AS t1 
    INNER JOIN tusk.academic_level AS t2
        ON (t1.academic_level_id = t2.academic_level_id)
    INNER JOIN " . $self->{school_db} . ".time_period AS t3 
    WHERE (t1.school_id = '$self->{school_id}' AND !(t3.academic_year IS NULL OR t3.academic_year = ''));"
    );

    my @academicLevels = ();
    my @timePeriods = ();

    while (my ($academicLevel, $timePeriod) = $sth->fetchrow_array())
    {
        push @academicLevels, $academicLevel;
        push @timePeriods, $timePeriod;
    }

    $sth->finish();

    return {
        academicLevels => \@academicLevels,
        timePeriods => \@timePeriods
    }
}

sub getStudentModificationValues{
    my ($self) = @_;

    unless($self->{-modifications}) {
        my $options = TUSK::Core::HSDB45Tables::TimePeriod->new();
        my $sth = $options->databaseSelect(
        "SELECT DISTINCT t1.period, t2.site_name
        FROM " . $self->{school_db} . ".time_period AS t1
        INNER JOIN " . $self->{school_db} . ".teaching_site AS t2;"
        );

        my @timePeriods = ();
        my @teachingSites = ();

        while (my ($timePeriod, $teachingSite) = $sth->fetchrow_array())
        {
            push @timePeriods, $timePeriod;
            push @teachingSites, $teachingSite;
        }

        $sth->finish();
        $self->{-modifications} = {
            timePeriods => \@timePeriods,
            teachingSites => \@teachingSites
        };
    }
    return $self;
}

sub getStudentModificationTimePeriods{
    my ($self) = @_;

    $self->getStudentModificationValues();
    return $self->{-modifications}->{'timePeriods'};
}

sub getStudentModificationTeachingSites{
    my ($self) = @_;

    $self->getStudentModificationValues();
    return $self->{-modifications}->{'teachingSites'};
}

sub getAlreadyEnrolledInACourse{
    my ($self, $args) = @_;
    my $sql = qq/SELECT COUNT(*)
        FROM $self->{school_db}.link_course_teaching_site AS t1
        WHERE t1.parent_course_id = (
            SELECT course_id
            FROM $self->{school_db}.course
            WHERE title = ?
        ) AND time_period_id = (
            SELECT time_period_id 
            FROM $self->{school_db}.time_period
            WHERE period = ?
            LIMIT 1
        ) AND t1.teaching_site_id = (
            SELECT teaching_site_id
            FROM $self->{school_db}.teaching_site
            WHERE site_name = ?
        );/;
    my $dbh = $self->{-dbh};
    my $alreadyEnrolled = $dbh->do($sql, undef, @{$sqlArgs}) or die $dbh->errstr;

    return defined $alreadyEnrolled ? $alreadyEnrolled : -1;
}

sub deleteStudentFromCourse{
    my ($self, $sqlArgs) = @_;
    my $sql = qq/DELETE FROM $self->{school_db}.link_course_student
        WHERE parent_course_id = (
            SELECT course_id
            FROM $self->{school_db}.course
            WHERE title = ?
        ) AND time_period_id = (
            SELECT time_period_id 
            FROM $self->{school_db}.time_period
            WHERE period = ?
            LIMIT 1
        ) AND teaching_site_id = (
            SELECT teaching_site_id
            FROM $self->{school_db}.teaching_site
            WHERE site_name = ?
        ) AND child_user_id = ?
        LIMIT 1;/;
    my $dbh = $self->{-dbh};
    my $rowsUpdates = $dbh->do($sql, undef, @{$sqlArgs}) or die $dbh->errstr;

    return $rowsUpdates;
}

sub applyStudentModifications{
    my ($self, $args) = @_;
    my $modification = TUSK::Core::HSDB45Tables::LinkCourseTeachingSite->new();
    my $dbh = $modification->getDatabaseWriteHandle();
    $self->{-dbh} = $dbh;
    my @sqlArgs;

    if ($args->{delete_requested} eq 'yes')
    {
        @sqlArgs = ($args->{course_name}, 
            $args->{current_time_period}, 
            $args->{current_teaching_site}, 
            $args->{user_id}
        );
        my $deletedRows = $self->deleteStudentFromCourse(\@sqlArgs);
        return $deletedRows == 1 ? 'true' : 'false';    
    }

    my $sql = qq/UPDATE $self->{school_db}.link_course_student AS t3
    SET t3.time_period_id = (
        SELECT time_period_id 
        FROM $self->{school_db}.time_period
        WHERE period = ?
        LIMIT 1
    ), t3.teaching_site_id = (
        SELECT teaching_site_id
        FROM $self->{school_db}.teaching_site
        WHERE site_name = ?
    )
    WHERE t3.child_user_id = ? 
    AND t3.time_period_id = (
        SELECT time_period_id 
        FROM $self->{school_db}.time_period
        WHERE period = ?
        LIMIT 1
    )
    AND t3.teaching_site_id = (
        SELECT CASE WHEN ? = '' THEN 0 ELSE (
            SELECT teaching_site_id
            FROM $self->{school_db}.teaching_site
            WHERE site_name = ?)
            END
    )
    AND t3.parent_course_id = (
        SELECT course_id
        FROM $self->{school_db}.course
        WHERE title = ?
    );/;
    
    @sqlArgs = ($args->{requested_time_period}, 
        $args->{requested_teaching_site}, 
        $args->{user_id},
        $args->{current_time_period},
        $args->{current_teaching_site},
        $args->{current_teaching_site},
        $args->{course_name}
    );

    my $rowsUpdates = $dbh->do($sql, undef, @sqlArgs) or die $dbh->errstr;
    warn('Updated rows is : ' . $rowsUpdates);
    warn ('Function applyStudentModifications() is done with execution.');
    return 'true';
}

sub checkNumberOfEnrolled{
    my ($self, $args) = @_;
    my $check = TUSK::Core::HSDB45Tables::LinkCourseTeachingSite->new();
    my @sqlArgs = ($args->{course_name},
        $args->{temp_time_period},
        $args->{temp_teaching_site}
    );
    my $sql = qq/SELECT COUNT(*)
    FROM $self->{school_db}.link_course_student AS t1
    WHERE t1.parent_course_id = (
        SELECT course_id
        FROM $self->{school_db}.course
        WHERE title = ?
    ) AND t1.time_period_id = (
        SELECT time_period_id 
        FROM $self->{school_db}.time_period
        WHERE period = ?
        LIMIT 1
    ) AND t1.teaching_site_id = (
        SELECT teaching_site_id
        FROM $self->{school_db}.teaching_site
        WHERE site_name = ?
    );/;
    my $sth = $check->databaseSelect($sql, @sqlArgs);
    my $alreadyEnrolled = -1;
    while (my ($already_enrolled) = $sth->fetchrow_array())
    {
        warn('Already enrolled number of students could be ' . $already_enrolled);
        $alreadyEnrolled = $already_enrolled;
    }
    warn('Already enrolled number of students is ' . $alreadyEnrolled);
    $sth->finish();
    return defined $alreadyEnrolled ? $alreadyEnrolled : -1;
}

1;
