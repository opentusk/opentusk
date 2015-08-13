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


package HSDB4::SQLRow::User;

use strict;

BEGIN {
    require Exporter;
    require HSDB4::SQLRow;
    require HSDB4::SQLLink;
    require HSDB4::XML::User;
    require Digest::MD5;

    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

    @ISA = qw(HSDB4::SQLRow Exporter);
    @EXPORT = qw( );
    @EXPORT_OK = qw( );
    $VERSION = do { my @r = (q$Revision: 1.232 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
}

use HTML::Entities;
use HSDB4::Constants qw(:school);
use TUSK::Constants;
use TUSK::GradeBook::GradeEvent;
use TUSK::GradeBook::LinkUserGradeEvent;
use TUSK::Assignment::Assignment;
use TUSK::Shibboleth::User;
use TUSK::Course::CourseSharing;
use HSDB45::Announcement;
use HSDB45::TimePeriod;
use TUSK::HomepageCategory;
use Forum::MwfConfig;
use TUSK::GradeBook::GradeEventEval;
use TUSK::Application::GradeBook::GradeBook;
use TUSK::Core::School;
use TUSK::Permission;
use TUSK::DB::Util qw(sql_prep_list);
use TUSK::Competency::Checklist::Group;
use overload ('cmp' => \&name_compare,
	      '""' => \&out_full_name);

use Carp;
use HSDB4::DateTime;
require HSDB4::SQLRow::Content;
require HSDB4::SQLRow::Preference;
require HSDB45::Authentication;
require TUSK::Eval::Group;
require HSDB45::Eval;
require HSDB45::Eval::Completion;
require HSDB45::UserGroup;
require TUSK::Application::Email;
require TUSK::Core::HSDB45Tables::Course;
require TUSK::Core::School;
# require TUSK::Competency::Checklist::Group;
use vars @EXPORT_OK;

# Non-exported package globals go here
use vars ();

#
# File-private lexicals
#
my $tablename         = 'user';
my $primary_key_field = 'user_id';
my @fields =       qw(user_id source status tufts_id sid trunk password email preferred_email profile_status modified
		      password_reset expires login previous_login lastname firstname midname suffix
		      degree affiliation gender body loggedout_flag uid
                      );

my %numeric_fields = (
		      );

my %blob_fields =    (body => 1
		      );

my %cache = ();

#
# >>>>> Constructor <<<<<
#

sub new {
    #
    # Do the default creation stuff
    #

    # Find out what class we are
    my $class = shift;
    $class = ref $class || $class;
    # Call the super-class's constructor and give it all the values
    my $self = $class->SUPER::new ( _tablename => $tablename,
				    _fields => \@fields,
				    _blob_fields => \%blob_fields,
				    _numeric_fields => \%numeric_fields,
				    _primary_key_field => $primary_key_field,
				    _cache => \%cache,
				    @_);
    # Finish initialization...
    $self->{saveForumData} = 0;
    return $self;
}

sub user_id {
    my $self = shift();
    return $self->field_value('user_id');
}

sub uid {
	my $self = shift();
	return $self->field_value('uid');
}

sub source {
    my $self = shift;
    return $self->field_value('source');
}

sub status {
    my $self = shift;
    return $self->field_value('status');
}

sub active {
    my $self = shift;
    return 1 if $self->status =~ /Active|Test|Restricted/;
}

sub restricted {
    my $self = shift;
    return 1 if $self->status =~ /Restricted/;
}

sub first_name {
    my $self = shift();
    return $self->field_value('firstname');
}

sub last_name {
    my $self = shift();
    return $self->field_value('lastname');
}

sub middle_name {
    my $self = shift();
    return $self->field_value('midname');
}

sub degree {
    my $self = shift();
    return $self->field_value('degree');
}

sub affiliation {
    my $self = shift();
    return $self->field_value('affiliation');
}

sub affiliation_or_default_school {
    my $self = shift;

    unless ($self->{-affiliation_or_default_school}) {
	$self->{-affiliation_or_default_school} = (exists $TUSK::Constants::Schools{$self->field_value('affiliation')}) ? $self->field_value('affiliation') : $TUSK::Constants::Default{School};
    }

    return $self->{-affiliation_or_default_school};
}

sub set_preferred_email {
    my $self = shift();
    my $new_preferred_email = shift;
    # Send an email to someone... (either the old preferred or the origional email address)... that a new preferred email has been entered.
    send_email($self, "New preferred $TUSK::Constants::SiteAbbr email entered", "The new email address being used with $TUSK::Constants::SiteAbbr is $new_preferred_email");
    $self->set_field_values("preferred_email" => $new_preferred_email);
    $self->{saveForumData} = 1;
    if($self->primary_key()) { $self->save(); }
}

sub preferred_email {
    my $self = shift();
    return $self->field_value('preferred_email');
}

sub set_email {
    my $self = shift();
    my $new_email = shift;
    $self->set_field_values("email" => $new_email);
    $self->{saveForumData} = 1;
    if($self->{primaryKey}) { $self->save(); }
}

sub email {
    my $self = shift();
    return $self->field_value('email');
}

sub default_email {
    my $self = shift();
    return ($self->field_value('preferred_email')) ? $self->field_value('preferred_email') : $self->field_value('email');
}

sub login {
    my $self = shift();
    return $self->field_value('login');
}

sub previous_login {
    my $self = shift();
    return $self->field_value('previous_login');
}

sub get_new_uid {

  my $dbh = HSDB4::Constants::def_db_handle ();
  my $current_max;

  eval {
		    my $sql = "select max(uid) from hsdb4.user";
            my $sth = $dbh->prepare ($sql);
	        $sth->execute ();
			$current_max = $sth->fetchrow_array;
			$sth->finish;
  };
  confess $@ if ($@);

  return ($current_max + 1);

}

sub lookup_by_uid {
	my ($self, $uid) = @_;
	my @objs = $self->lookup_conditions("uid = $uid");
	if (scalar @objs == 1) {
		return $objs[0];
	}
	return undef;
}


#
# >>>>> Linked objects <<<<<
#

sub check_author {
    my ($self, $roles) = @_;

    $roles->{tusk_session_is_author} = 0;

    if (!$self->primary_key()){
	confess "check_author only works on initialized user objects";
    }

    if (scalar @{TUSK::Course::User->lookup("user_id = '" . $self->primary_key() . "'")}) {
	$roles->{tusk_session_is_author} = 1;
	return (defined($roles->{tusk_session_is_admin})) ? $roles : $self->check_admin($roles);
    }

    my $linkdef = $HSDB4::SQLLinkDefinition::LinkDefs{"link_content_user"};
    if ($linkdef->get_parent_count($self->primary_key())){
		$roles->{tusk_session_is_author} = 1;
		if (defined($roles->{tusk_session_is_admin})){
			return ($roles);
		}else{
			return ($self->check_admin($roles));
		}
	}

	if (defined($roles->{tusk_session_is_admin})){
		return ($roles);
	}else{
		return ($self->check_admin($roles));
    }
}

sub check_admin {
    my ($self, $roles) = @_;

    if (!$self->primary_key()){
	confess "check_author only works on initialized user objects";
    }

    # Get the link definition
    foreach my $school (course_schools()){
	my $db = get_school_db($school);
	my $eval_gid = HSDB4::Constants::get_eval_admin_group($school);
	my $admin_gid = $HSDB4::Constants::School_Admin_Group{$school};
	my $linkdef = $HSDB4::SQLLinkDefinition::LinkDefs{"$db\.link_user_group_user"};

	if ($eval_gid && $linkdef->get_parent_count($self->primary_key(), "parent_user_group_id = $eval_gid")) {
	    $roles->{tusk_session_eval_admin}->{$school} = 1;
	    $roles->{tusk_session_is_author} = 1;
	}

	if ($admin_gid && $linkdef->get_parent_count($self->primary_key(), "parent_user_group_id = $admin_gid")) {
	    $roles->{tusk_session_admin}->{$school} = 1;
	    $roles->{tusk_session_is_author} = 1;
	}
    }
    return $roles;
}

sub isFaculty {
  my $self = shift;
  my $user_id = $self->user_id();
  my $school_name = $self->affiliation_or_default_school();
  my $db = TUSK::Core::School->new->getSchoolDb($school_name);

  my $dbh = HSDB4::Constants::def_db_handle();

  my $class_meetings;

  eval {
    my $sql = "SELECT count(*) FROM $db.link_class_meeting_user
                WHERE child_user_id = '$user_id'";

    my $sth = $dbh->prepare ($sql);
    $sth->execute();
    $class_meetings = $sth->fetchall_arrayref();
    $sth->finish;
  };

  return $class_meetings;
}

# Return the courses the user is a part of teaching for 'course' course_type  or course admin for other course_types.
sub author_courses {
    my ($self, $conds) = @_;
    my @schools = course_schools();
    my @courses = ();

    if ($self->field_value('status') eq 'ghost') {
	foreach my $school (@schools) {
	    my $school_db = get_school_db($school);
	    my $course = TUSK::Core::HSDB45Tables::Course->new();
	    $course->setDatabase($school_db);
	    push @courses, @{$course->lookup($conds, ['course.course_id'], undef, undef, [
		TUSK::Core::JoinObject->new('TUSK::Course', { joinkey => 'school_course_code', origkey => 'course_id', jointype => 'inner', }),
		TUSK::Core::JoinObject->new('TUSK::Core::School', { joinkey => 'course_id', jointype => 'inner', joincond => "school_name = '$school'"  }),
		TUSK::Core::JoinObject->new('TUSK::Course::CourseSharing', { joinkey => 'course_sharing.school_id', origkey => 'school.school_id', jointype => 'inner', joincond => "shared_with = " . $self->field_value('sid') . " AND avaliable_from <= NOW() AND avaliable_to >= NOW()"  }),
	   ])};
	}
    } else {
	foreach my $school (@schools) {
	    my $school_db = get_school_db($school);
	    my $course = TUSK::Core::HSDB45Tables::Course->new();
	    $course->setDatabase($school_db);
	    push @courses, @{$course->lookup($conds, ['course.course_id'], undef, undef, [
		TUSK::Core::JoinObject->new('TUSK::Course::User', { joinkey => 'course_id', jointype => 'inner', joincond => "user_id = '" . $self->primary_key() . "'" }),
		TUSK::Core::JoinObject->new('TUSK::Core::School', { joinkey => 'school_id', origkey => 'course_user.school_id', jointype => 'inner', joincond => "school_name = '$school'"  }),
		TUSK::Core::JoinObject->new('TUSK::Permission::UserRole', { joinkey => 'feature_id', origkey => 'course_user.course_user_id', jointype => 'inner'  }),
		TUSK::Core::JoinObject->new('TUSK::Permission::Role', { joinkey => 'role_id', origkey => 'permission_user_role.role_id',  jointype => 'inner', joincond => "virtual_role = 0" }),
		   TUSK::Core::JoinObject->new('TUSK::Permission::FeatureType', { joinkey => 'feature_type_id', origkey => 'permission_role.feature_type_id', jointype => 'inner', joincond => "feature_type_token = 'course'" }),
	])};
	}
    }
    return @courses;
}


sub parent_class_meetings {
    #
    # Get class_meetings to which a faculty member is linked
    #

	my $self = shift;
	unless ($self->{-parent_class_meetings}) {
		my @meetings = ();
        # Get the link definition
		for my $db (map { get_school_db($_) } schedule_schools()) {
			my $linkdef =
				$HSDB4::SQLLinkDefinition::LinkDefs{"$db\.link_class_meeting_user"};
			# And use it to get a LinkSet, if possible
			push @meetings, $linkdef->get_parents( $self->primary_key() )->parents();
			$self->{-parent_class_meetings} = \@meetings;
		}
	}
    # Return the list
	return @{$self->{-parent_class_meetings}};
}

sub parent_class_meetings_today {
    #
    # Get class_meetings to which a faculty member is linked scheduled for today
    #

	my $self = shift;
	my $today = HSDB4::DateTime->new()->out_mysql_date;
	return $self->parent_class_meetings_on_date($today);
}

sub parent_class_meetings_on_date{
	my $self = shift;
	my $date = shift;

	unless ($self->{'-parent_class_meetings' . $date}) {
		my @meetings = ();

		my $dbh = HSDB4::Constants::def_db_handle();
		foreach my $school (schedule_schools()) {
			my $db = get_school_db($school);
			eval {
				my $sth = $dbh->prepare (qq[SELECT cm.class_meeting_id
						FROM $db\.class_meeting cm, $db\.link_class_meeting_user l
						WHERE l.child_user_id=?
						AND l.parent_class_meeting_id=cm.class_meeting_id
						AND cm.meeting_date = '$date'
					    ]);
				$sth->execute ($self->primary_key);

				while (my ($m_id) = $sth->fetchrow_array) {
					push @meetings, HSDB45::ClassMeeting->new(_school=>$school)->lookup_key($m_id);
				}
	               $sth->finish;
			};
			$self->{'-parent_class_meetings' . $date} = \@meetings;
		}
	}
    # Return the list
	return @{$self->{'-parent_class_meetings' . $date}};

}

sub sorted_meetings_on_date{
	my $self = shift;
	my $date = shift;

	my @meetings;

	my $ug_courses = $self->user_group_courses('', $date);
	my %seen;
	foreach my $c_hash (@$ug_courses){
		my $id = $c_hash->{course_id};
		unless($seen{ $id }){
			my $course = HSDB45::Course->new(_school => $c_hash->{'school_name'})->lookup_key($id);
			if ($course->primary_key) {
				push @meetings, $course->meetings_on_date($date);
			}
			$seen{ $id } = 1;
		}
	}

	my @parent_meetings = $self->parent_class_meetings_today();

	push @meetings, @parent_meetings;

	my @sorted_meets = sort{ $a->start_time cmp $b->start_time } @meetings;

	return @sorted_meets;
}

sub todays_sorted_meetings_by_school {
    #
    # Get meetings, split out by school, for a student for current day
	#
	my $self = shift;
	my $today = HSDB4::DateTime->new()->out_mysql_date;
	my @meetings = $self->sorted_meetings_on_date($today);
	my %sorted_meetings;

	foreach my $meeting (@meetings) {
		push @{$sorted_meetings{$meeting->school}}, $meeting;
	}

	return \%sorted_meetings;
}

sub has_schedule {
    #
    # Find out if user has calendar events in the current period
    #	- limited by school if passed as argument
    #	- see comments for get_schedule_start_end for definition of 'current period'
	#
	my $user = shift;
	my $school = shift || undef;
	my ($start, $end) = get_schedule_start_end();
	my $dbh = HSDB4::Constants::def_db_handle();
	my ($sth, @selects, @ids);
	my %ug_hash;

	if ($school) {
		my $db = 'hsdb45_' . $TUSK::Constants::Schools{$school}{ShortName} . '_admin';
		push @selects, "SELECT DISTINCT '$school' AS schoolName, parent_user_group_id, label, COUNT(meeting_date) AS num FROM $db.link_user_group_user, $db.link_course_user_group, $db.class_meeting, $db.time_period, $db.user_group WHERE CURDATE() BETWEEN start_date AND end_date AND parent_course_id = course_id AND time_period.time_period_id = link_course_user_group.time_period_id AND meeting_date BETWEEN start_date AND end_date AND meeting_date BETWEEN ? AND ? AND parent_user_group_id = child_user_group_id AND parent_user_group_id = user_group_id AND child_user_id = ? GROUP BY user_group_id ORDER BY num DESC";
		push (@ids, ($start, $end, $user->primary_key()));
	}
	else {
		my %school_dbs = map { $_ => 'hsdb45_' . $TUSK::Constants::Schools{$_}{ShortName} . '_admin' } keys %TUSK::Constants::Schools;
		foreach my $school (keys %school_dbs) {
			my $db = $school_dbs{$school};
			push @selects, "(SELECT DISTINCT '$school' AS schoolName, parent_user_group_id, label, COUNT(meeting_date) AS num FROM $db.link_user_group_user, $db.link_course_user_group, $db.class_meeting, $db.time_period, $db.user_group WHERE CURDATE() BETWEEN start_date AND end_date AND parent_course_id = course_id AND time_period.time_period_id = link_course_user_group.time_period_id AND meeting_date BETWEEN start_date AND end_date AND meeting_date BETWEEN ? AND ? AND parent_user_group_id = child_user_group_id AND parent_user_group_id = user_group_id AND child_user_id = ? GROUP BY user_group_id)";
			push (@ids, ($start, $end, $user->primary_key()));
		}
	}
    $sth = $dbh->prepare(join (' union ', @selects) . " ORDER BY num DESC");
    $sth->execute(@ids);
	while (my ($school, $ug_id, $ug_label, undef) = $sth->fetchrow_array) {
		push @{$ug_hash{$school}}, {id => $ug_id, label => $ug_label};
	}

	return \%ug_hash;
}

sub get_schedule_start_end {
    #
    # Get start and end date for user's current period:
    #	- 6 month period (either Jan. - June. or July - Dec.) depending on the current date
    #	- if it's December, includes next Jan. - June
    #	- if it's June, includes July - Dec.
	#
	my ($startdate, $enddate);
	my $today = HSDB4::DateTime->new;
	my $year = HSDB4::DateTime->new->current_year();
	my $midyear_cutoff = HSDB4::DateTime->new->in_mysql_date("$year-05-31 23:59:59");
	my $midyear = HSDB4::DateTime->new->in_mysql_date("$year-06-30 23:59:59");
	my $endyear_cutoff = HSDB4::DateTime->new->in_mysql_date("$year-11-30 23:59:59");
	my $endyear = HSDB4::DateTime->new->in_mysql_date("$year-12-31 23:59:59");

	## we're in the first half of the year but not in June
	if ($today < $midyear_cutoff) {
		$startdate = "$year-01-01 00:00:00";
		$enddate = "$year-06-30 23:59:59";
	}
	## we're in June
	elsif ($today < $midyear) {
		$startdate = "$year-01-01 00:00:00";
		$enddate = "$year-12-31 23:59:59";
	}
	## we're in the second half of the year but not in December
	elsif ($today < $endyear_cutoff) {
		$startdate = "$year-07-01 00:00:00";
		$enddate = "$year-12-31 23:59:59";
	}
	## we're in December
	else {
		$startdate = "$year-07-01 00:00:00";
		$enddate = ($year + 1) . "-06-30 23:59:59";
	}
	return ($startdate, $enddate);
}

sub get_important_upcoming_dates_by_school {
    # Get items with upcoming due dates:
    #	- Exams and Holidays (pulled from the user group schedule where meeting type is exam or holiday)
    #	- All quizzes with due dates
    #	- All cases with due dates
    #	- Evals
    #	- Assignments

    my $user = shift;
    my $school = shift;
    my @dates;
    my $db = get_school_db($school);
    my (undef, $enddate) = get_schedule_start_end();

    my $dbh = HSDB4::Constants::def_db_handle();
    my @sql_values;

    my $schedule_sql = <<"END_SQL";
SELECT
  c.course_id AS course_id,
  'schedule' AS type,
  cm.class_meeting_id AS id,
  cm.title AS title,
  DATE_FORMAT(cm.meeting_date, '%b. %e, %Y') AS date,
  DATE_FORMAT(cm.starttime,'%h:%i %p') AS time,
  DATE_ADD(cm.meeting_date, INTERVAL cm.starttime HOUR_SECOND) AS exact_time,
  c.title AS course_title
FROM
  $db.course c
  INNER JOIN $db.class_meeting cm
    ON c.course_id = cm.course_id
  INNER JOIN $db.link_course_user_group lcug
    ON c.course_id = lcug.parent_course_id
  INNER JOIN $db.link_user_group_user lugu
    ON lcug.child_user_group_id = lugu.parent_user_group_id
  INNER JOIN $db.time_period tp
    ON lcug.time_period_id = tp.time_period_id
  INNER JOIN tusk.class_meeting_type cmt
    ON cm.type_id = cmt.class_meeting_type_id
  INNER JOIN tusk.school s
    ON s.school_id = cmt.school_id
WHERE
  s.school_name = ?
  AND
  (cmt.label = 'Holiday' OR cmt.label = 'Examination')
  AND
  NOW() BETWEEN tp.start_date AND tp.end_date
  AND
  cm.meeting_date BETWEEN NOW() AND ?
  AND
  lugu.child_user_id = ?
END_SQL
    push @sql_values, ($school, $enddate, $user->primary_key());

    my $quiz_sql = <<"END_SQL";
SELECT
  c.course_id AS course_id,
  'quiz' AS type,
  q.quiz_id AS id,
  q.title AS title,
  DATE_FORMAT(lcq.due_date, '%b. %e, %Y') AS date,
  DATE_FORMAT(lcq.due_date,'%h:%i %p') AS time,
  lcq.due_date AS exact_time,
  c.title AS course_title
FROM
  tusk.quiz q
  INNER JOIN tusk.link_course_quiz lcq ON (q.quiz_id = lcq.child_quiz_id)
  INNER JOIN $db.course c ON (c.course_id = lcq.parent_course_id)
  INNER JOIN tusk.school s ON (lcq.school_id = s.school_id)
  INNER JOIN $db.link_course_student lcs ON (lcs.parent_course_id = c.course_id AND lcq.time_period_id = lcs.time_period_id)
  INNER JOIN $db.time_period tp ON (lcs.time_period_id = tp.time_period_id)
WHERE
  s.school_name = ?
  AND lcq.available_date < NOW()
  AND NOW() BETWEEN tp.start_date AND tp.end_date
  AND lcq.due_date BETWEEN NOW() AND ?
  AND child_user_id = ?
  AND q.quiz_id NOT IN (
    SELECT qr.quiz_id
    FROM tusk.quiz_result qr
    WHERE user_id = ? AND qr.end_date IS NOT NULL
  )
END_SQL
    push @sql_values, ($school, $enddate, $user->primary_key(), $user->primary_key());

    my $case_sql = <<"END_SQL";
SELECT
  c.course_id AS course_id,
  'case' AS type,
  ch.case_header_id AS id,
  ch.case_title AS title,
  DATE_FORMAT(lcc.due_date, '%b. %e, %Y') AS date,
  DATE_FORMAT(lcc.due_date,'%h:%i %p') AS time,
  lcc.due_date AS exact_time,
  c.title AS course_title
FROM
  tusk.case_header ch
  INNER JOIN tusk.link_course_case lcc
    ON ch.case_header_id = lcc.child_case_id
  INNER JOIN tusk.school s
    ON s.school_id = lcc.school_id
  INNER JOIN $db.course c
    ON c.course_id = lcc.parent_course_id
  INNER JOIN $db.link_course_student lcs
    ON c.course_id = lcs.parent_course_id
  INNER JOIN $db.time_period tp
    ON tp.time_period_id = lcs.time_period_id
WHERE
  s.school_name = ?
  AND
  (lcc.available_date IS NULL OR lcc.available_date < NOW())
  AND
  NOW() BETWEEN tp.start_date AND tp.end_date AND
  lcc.due_date BETWEEN NOW() AND ?
  AND
  child_user_id = ?
  AND
  ch.publish_flag = 1
END_SQL
    push @sql_values, ($school, $enddate, $user->primary_key());

    my $eval_sql = <<"END_SQL";
SELECT
  c.course_id AS course_id,
  'eval' AS type,
  e.eval_id AS id,
  e.title AS title,
  DATE_FORMAT(e.due_date, '%b. %e, %Y') AS date,
  NULL AS time,
  e.due_date AS exact_time,
  c.title AS course_title
FROM $db.eval e
INNER JOIN $db.time_period tp ON (e.time_period_id = tp.time_period_id AND now() BETWEEN tp.start_date AND tp.end_date)
INNER JOIN $db.course c ON (e.course_id = c.course_id)
INNER JOIN $db.link_course_student lcs ON
  (lcs.time_period_id = tp.time_period_id AND lcs.parent_course_id = c.course_id AND child_user_id = ?
   AND lcs.teaching_site_id = e.teaching_site_id)
WHERE
  e.due_date BETWEEN now() AND ?
  AND e.available_date < now()
  AND e.eval_id NOT IN (SELECT ec.eval_id FROM $db.eval_completion ec WHERE status = 'Done' AND ec.user_id = child_user_id)
END_SQL
    push @sql_values, ($user->primary_key(), $enddate);

    my $assignment_sql = <<"END_SQL";
SELECT
  c.course_id AS course_id,
  'assignment' AS type,
  a.assignment_id AS id,
  ge.event_name AS title,
  DATE_FORMAT(a.due_date, '%b. %e, %Y') AS date,
  DATE_FORMAT(a.due_date,'%h:%i %p') AS time,
  a.due_date AS exact_time,
  c.title AS course_title
FROM
  tusk.grade_event ge
  INNER JOIN tusk.school s
    ON ge.school_id = s.school_id
  INNER JOIN $db.time_period tp
    ON ge.time_period_id = tp.time_period_id
  INNER JOIN tusk.assignment a
    ON a.grade_event_id = ge.grade_event_id
  INNER JOIN tusk.link_assignment_student las
    ON a.assignment_id = las.parent_assignment_id
  INNER JOIN $db.course c
    ON ge.course_id = c.course_id
WHERE
  s.school_name = ?
  AND
  a.available_date < NOW()
  AND
  NOW() BETWEEN tp.start_date AND tp.end_date
  AND
  a.due_date BETWEEN NOW() AND ?
  AND
  las.child_user_id = ?
END_SQL
    push @sql_values, ($school, $enddate, $user->primary_key());

    my $sql_query = join(
        "\nUNION\n",
        $schedule_sql,
        $quiz_sql,
        $case_sql,
        $eval_sql,
        $assignment_sql,
    ) . "\nORDER BY exact_time";

    my $sth = $dbh->prepare($sql_query);
    $sth->execute(@sql_values);
    while ( my $row = $sth->fetchrow_hashref() ) {
        push @dates, $row;
    }
    $sth->finish;

    return \@dates;
}

sub recently_modified {
    #
    # Get a set of the content that the user authored
    #

    my $self = shift;
    # Check the cache

    # Get the link definition
    my $linkdef =
        $HSDB4::SQLLinkDefinition::LinkDefs{'link_content_user'};
    # And get the LinkSet of parents
    my $sel = $linkdef->parent_select($self->primary_key);
    $sel->order_by("parent.modified desc");
    $sel->{-fields}=[];
    $sel->add_fields("parent.title");
    $sel->limit("10");

    my $parent_content = $linkdef->get_links($sel);

    # And return the list
    return $parent_content->parents () if $parent_content;
}

sub parent_content {
    #
    # Get a set of the content that the user authored
    #

    my $self = shift;
    # Check the cache

    # Get the link definition
    my $linkdef =
        $HSDB4::SQLLinkDefinition::LinkDefs{'link_content_user'};
    # And get the LinkSet of parents
    my $parent_content = $linkdef->get_parents ($self->primary_key,@_);

    # And return the list
    return $parent_content->parents () if $parent_content;
}


sub user_group_hashref{
    my $self = shift;
    unless ($self->{-user_group_hash}){
	my @user_groups=$self->parent_edit_user_groups;
	push(@user_groups,$self->admin_user_groups);

	for(my $i=0; $i<scalar @user_groups; $i++){
	    my $key = $user_groups[$i]->{_school}." - ".$user_groups[$i]->field_value("label");
	    $self->{-user_group_hash}{$key}=$user_groups[$i];
	}
    }
    return $self->{-user_group_hash};
}

sub admin_user_groups{
    #
    # Get a list of courses this person has access to as an admin
    #
    my $self = shift;
    unless ($self->{-admin_user_groups}) {
	my ($school,@user_groups);
	foreach $school (keys %HSDB4::Constants::School_Admin_Group) {
	    if ($self->check_school_permissions($school)){
		my $user_group = HSDB45::UserGroup->new(_school => $school);
		push(@user_groups,$user_group->lookup_conditions());
	    }
	}
	$self->{-admin_user_groups} = \@user_groups;
    }

    return @{$self->{-admin_user_groups}};

}

sub parent_edit_user_groups{
    my $self = shift;
    unless ($self->{-parent_edit_user_groups}) {
	my @groups = ();
        # Get the link definition
	foreach my $school (user_group_schools()) {
	    next unless ($self->check_school_permissions($school));
	    my $db = get_school_db($school);
	    my $linkdef =
		$HSDB4::SQLLinkDefinition::LinkDefs{"$db\.link_user_group_user"};
	    # And use it to get a LinkSet, if possible
	    push @groups, $linkdef->get_parents( $self->primary_key() )->parents();
	}
	$self->{-parent_edit_user_groups} = \@groups;
    }
    # Return the list
    return @{$self->{-parent_edit_user_groups}};
}


sub parent_user_groups {
    #
    # Get user group objects to which a user is linked
    #
    my $self = shift;
    my @conds = @_;
    push @conds, "order by label";

    unless ($self->{-parent_user_groups}) {
	my @groups = ();
        # Get the link definition
	for my $db (map { get_school_db($_) } user_group_schools()) {
	    my $linkdef =
		$HSDB4::SQLLinkDefinition::LinkDefs{"$db\.link_user_group_user"};
	    # And use it to get a LinkSet, if possible
	    push @groups, $linkdef->get_parents( $self->primary_key(), @conds )->parents();
	}
        # This was causing huge bloat in the stored session object
        # (hsdb4.sessions table in the database). TEXT columns cannot
        # store more than 64K, and the parent_user_groups object gets
        # bloated when users belong to lots of groups, such as happens
        # with administrators. Temporary fix is to comment out this
        # assignment to make the session object much smaller.
        # $self->{-parent_user_groups} = \@groups;
	return @groups;
    }
    # Return the list
    return @{$self->{-parent_user_groups}};
}


sub get_user_course_groups {
    #
    # Gets group objects to which a user is linked to in a course
    #
    my $self = shift;
    my $course = shift;

    return () unless ($course);

    my $cacheID = "-get_user_course_groups" . $course->school() . $course->primary_key;

    if (! exists $self->{$cacheID}) {
        $self->{$cacheID} = [];

        # Get the link definition
	my $linkdef = $HSDB4::SQLLinkDefinition::LinkDefs{get_school_db($course->school()) . "\.link_user_group_user"};

        my @subGroupsOfCourse = $course->sub_user_groups();

	if($linkdef && scalar @subGroupsOfCourse) {
		#Make the and clause for the sql call
		my $andClause = "parent_user_group_id IN (";
                #Combine the sub and not sub groups and display them.
		#It would be nice if there was a single function that combined all of this togeather.
		foreach (@subGroupsOfCourse) { $andClause .= $_->primary_key() .", "; }
		$andClause =~ s/, $//;
		$andClause .= ")";

		# And use it to get a LinkSet, if possible
		my @groups = $linkdef->get_parents( $self->primary_key(), $andClause )->parents();
		$self->{$cacheID} = \@groups;
	    }
    }

    # Return the list
    return @{$self->{$cacheID}};
}



sub all_courses{
    my ($self) = @_;
    return $self->current_courses( {'all_courses' => 1} );
}

sub user_group_courses{
    # Get the user's current student's user group courses
    # unless a date is passed in, in which case, get the groups linked on that date

    my $self = shift;
    my $cond = shift || "";
    my $date = shift || HSDB4::DateTime->new()->out_mysql_date;
    my $lookup = { map { $_->getSchoolName() => $_ } @{TUSK::Core::School->new()->getTUSKConfSchools()} };

    my $courses = [];
    my @school_joins = ();

    foreach my $school (course_schools()) {
	my $db = get_school_db($school);
	my $school_id = $lookup->{ $school }->getPrimaryKeyID();

	push @school_joins, "(select '" . $school . "' as school_name, '" . $school_id . "' as school_id, parent_course_id, t.time_period_id, u.user_group_id, u.sub_group
			from $db\.link_user_group_user lugu, $db\.link_course_user_group lcug, $db\.time_period t, $db\.user_group u
			where lugu.parent_user_group_id = lcug.child_user_group_id and t.time_period_id = lcug.time_period_id and
                        u.user_group_id = lcug.child_user_group_id and $cond
                        lugu.child_user_id = '" . $self->primary_key() . "' and t.start_date <= '$date' and t.end_date >= '$date')";
    }

    my $dbh = HSDB4::Constants::def_db_handle();
    my $sth = $dbh->prepare(join (' union ', @school_joins));
    $sth->execute();

    while (my $row = $sth->fetchrow_hashref){
		my $link_course_student = $HSDB4::SQLLinkDefinition::LinkDefs{ HSDB4::Constants::get_school_db($row->{school_name}) . '.link_course_student'};
		if ( $link_course_student->check_for_link( $row->{parent_course_id}, $self->user_id, ' AND time_period_id = ' . $row->{time_period_id} ) ) {
			push @$courses, {
			    school_id => $row->{school_id},
			    school_name => $row->{school_name},
			    course_id => $row->{parent_course_id},
			    sub_group_id => ($row->{sub_group} eq 'Yes') ? $row->{user_group_id} : 0,
			    time_period_id => $row->{time_period_id},
			};
		}
    }
    $sth->finish;

    return $courses;
}

sub current_courses {
    #
    # Get the user's current courses
    #

    my $self = shift;
    my $params = shift || ();

    $self->{_current_courses_calls}++;

	# We need to cache all possible parameter options...
#	if ($params->{'all_courses'} && $params->{'only_enrollment'}) {
#		return @{$self->{'-all_enrollment_courses'}} if ($self->{'-all_enrollment_courses'});
#	} elsif ($params->{'all_courses'} && !$params->{'only_enrollment'}) {
#		return @{$self->{'-all_courses'}} if ($self->{'-all_courses'});
#	} elsif (!$params->{'all_courses'} && $params->{'only_enrollment'}) {
#		return @{$self->{'-current_enrollment_courses'}} if ($self->{'-current_enrollment_courses'});
#	} elsif (!$params->{'all_courses'} && !$params->{'only_enrollment'}) {
#		return @{$self->{'-current_courses'}} if ($self->{'-current_courses'});
#	}

    my $where = '';
    $where = "and t.start_date <= curdate() and t.end_date >= curdate()" unless ($params->{'all_courses'});

	my @courses;
	my $dbh = HSDB4::Constants::def_db_handle ();
	for my $school ( course_schools() ) {
	    my $db = get_school_db($school);
	    my @course_ids = ();
	    my @timeperiod_ids = ();
	    eval {
		my $sql = qq[SELECT parent_course_id, l.time_period_id
			     FROM $db\.course c, $db\.link_course_student l, $db\.time_period t
			     WHERE l.child_user_id=?
			     AND l.time_period_id=t.time_period_id
			     AND l.parent_course_id=c.course_id ];
		if ($params->{'only_enrollment'}) { $sql .= " AND c.associate_users='Enrollment' "; }
		$sql .= $where;

		my $sth = $dbh->prepare($sql);

		$sth->execute ($self->primary_key);

		while (my ($course_id, $timeperiod_id) = $sth->fetchrow_array) {
		    push @course_ids, $course_id;
		    push @timeperiod_ids, $timeperiod_id
		}
		$sth->finish;

	    };

	    for (my $i=0; $i<scalar(@course_ids); $i++){
		my $c = HSDB45::Course->new( _school => $school, _id => $course_ids[$i] );
		$c->set_aux_info(time_period_id => $timeperiod_ids[$i]);
		push @courses, $c if ($c->primary_key);
	    }
	}

        # This was causing huge bloat in the stored session object
        # (hsdb4.sessions table in the database). TEXT columns cannot
        # store more than 64K, and the parent_user_groups object gets
        # bloated when users belong to lots of groups, such as happens
        # with administrators. Temporary fix is to comment out this
        # assignment to make the session object much smaller.
	# if ($params->{'all_courses'} && $params->{'only_enrollment'}) {
	# 	$self->{'-all_enrollment_courses'} = \@courses;
	# } elsif ($params->{'all_courses'} && !$params->{'only_enrollment'}) {
	# 	$self->{'-all_courses'} = \@courses;
	# } elsif (!$params->{'all_courses'} && $params->{'only_enrollment'}) {
	# 	$self->{'-current_enrollment_courses'} = \@courses;
	# } elsif (!$params->{'all_courses'} && !$params->{'only_enrollment'}) {
	# 	$self->{'-current_courses'} = \@courses;
	# }

	return @courses;
}

sub check_school_permissions{
    my $self = shift;
    my $school = shift;

    unless (exists($self->{-school_permissions}->{$school})){
	# test to see if in admin goup
	my $contains=0;
	my $admin_group_id = $HSDB4::Constants::School_Admin_Group{$school};
	my $admin_user_group = HSDB45::UserGroup->new(_school => $school,_id => $admin_group_id);

	# check and if not in admin check to see if in edit group
	unless ($contains = $admin_user_group->contains_user($self->primary_key)){
	    my $edit_group_id = $HSDB::Constants::School_Edit_Group{$school};
	    my $edit_user_group = HSDB45::UserGroup->new(_school => $school,_id => $edit_group_id);
	    $contains=$edit_user_group->contains_user($self->primary_key);
	}
	$self->{-school_permissions}->{$school}=$contains;
    }

    return ($self->{-school_permissions}->{$school});
}


sub admin_courses {
    # Get a list of courses this person has access to as an admin.
    # Don't cache because it makes the user object too big to fit in
    # hsdb4.sessions.a_session column in MySQL
    my $self = shift;
    my ($school,$group_id,@admin_courses);
    foreach $school (keys %HSDB4::Constants::School_Admin_Group) {
	if ($self->check_school_permissions($school)){
	    my @courses = HSDB45::Course->new(_school => $school)->lookup_conditions();
	    push(@admin_courses, @courses);
	}
    }
    return \@admin_courses;
}


sub cms_courses {
    my $self = shift;
    my @courses = ();

    foreach my $author_course ($self->author_courses()) {
	my $school = $author_course->getJoinObject('TUSK::Core::School')->getPrimaryKeyID();
	my $course = HSDB45::Course->new(_school => $school)->lookup_key($author_course->getPrimaryKeyID());
	push @courses, $course;
    }

    push @courses, @{$self->admin_courses()};

    my $courses_hash;
    foreach my $course (@courses) {
	my $school = $course->school;
	my $key = $course->out_title."\0".$course->primary_key;
	$courses_hash->{$school}->{$key} = $course;
    }
    return $courses_hash;
}

sub cms_courses_sorted {
    my $self = shift;
    my $courses_hashref = $self->cms_courses();
    my $group_courses_hashref;
    my $tc_courses_hashref;

    foreach my $school (keys %{$courses_hashref}){
	    foreach my $course (sort keys %{$courses_hashref->{$school}}){
		    if($courses_hashref->{$school}->{$course}->type() ){
		         if($courses_hashref->{$school}->{$course}->type() eq 'group'){
			        $group_courses_hashref->{$school}->{$course} = $courses_hashref->{$school}->{$course};
				    delete $courses_hashref->{$school}->{$course};
			    }
			    elsif($courses_hashref->{$school}->{$course}->type() eq 'thesis committee'){
			        $tc_courses_hashref->{$school}->{$course} = $courses_hashref->{$school}->{$course};
				    delete $courses_hashref->{$school}->{$course};
			    }
			}
		}
		# if we have deleted all courses from a school above, delete the school, itself
		if(!(keys %{$courses_hashref->{$school}})){
		    delete $courses_hashref->{$school};
		}

	}

	return ($courses_hashref, $group_courses_hashref, $tc_courses_hashref);
}

sub check_cms {
    my $self = shift;
    my ($courses_hashref,  $group_courses_hashref, $tc_courses_hashref) = $self->cms_courses_sorted();
    return scalar keys %$courses_hashref;
}

sub taken_quizzes{
    my ($self, $course) = (@_);

    my ($taken_quizzes);

    my $school_id = TUSK::Core::School->new->getSchoolID($course->school);

    my $course_id = $course->primary_key();

	my $tps = $course->get_users_active_timeperiods($self->user_id);
	my $tp_cond = '';
	if ($tps and scalar(@$tps)) {
		my @tp_ids = map { $_->primary_key() } @$tps;
		$tp_cond = 'and time_period_id in (' . join(',', @tp_ids) . ')';
	}
    my $user_id = $self->primary_key();

    my $sql = <<EOM;
select q.quiz_id, q.title, r.end_date
from tusk.quiz q, tusk.link_course_quiz l, tusk.quiz_result r
where (school_id = $school_id  and parent_course_id = $course_id)
and r.quiz_id = q.quiz_id
and r.user_id = '$user_id'
and q.quiz_id = l.child_quiz_id
and r.end_date is not null
$tp_cond
and preview_flag = 0
order by r.end_date desc
EOM
    my $dbh = HSDB4::Constants::def_db_handle ();

    eval {
	my $sth = $dbh->prepare ($sql);
	$sth->execute ();
	while (my ($quiz_id, $title, $end_date) = $sth->fetchrow_array) {
	    push @$taken_quizzes, {'quiz_id' => $quiz_id, 'title' => $title, 'end_date' => $end_date};
	}
     $sth->finish;
    };
    if ($@){
	confess "$@";
    }

    return $taken_quizzes
}

sub current_quizzes{
    #
    # Get quizzes for this user in all active time periods in which they are enrolled.
    #
    my ($self, $coursearray) = (@_);

    my (@where_clause, $schoolhash, $quizzes, @courses, $course_hashref);
    my $preview = {};

    #A ghost can not have quizzes
    if($self->isGhost()) {return [];}

    if ($coursearray and scalar(@$coursearray)){
	foreach my $course (@$coursearray){
	    my $tps = $course->get_users_active_timeperiods($self->user_id);
	    next unless $tps and scalar(@$tps);
	    my $key = $course->school . "-" . $course->course_id;
	    my $preview_value = 0;

            #Verify the user is enrolled in this course or is some other kind of child user.
	    my $user_is_enrolled = 0;
	    foreach my $tp (@$tps) {
		if ($course->is_user_registered($self->primary_key, $tp->primary_key)){
		    push (@courses, $course);
		    $user_is_enrolled = 1;
		    last;
		}
	    }

	    if (!$user_is_enrolled and $course->user_has_role($self->primary_key, ['author', 'editor', 'director', 'manager'])) {
		push (@courses, $course);
		$preview_value = 1;
		last;
	    }
	    $preview->{$key} = $preview_value;
	}
    } else {
	my @all_courses = $self->current_courses;
	foreach my $course (@all_courses){
	    unless ($course_hashref->{$course}){
		push (@courses, $course);
		$course_hashref->{$course} = 1;
	    }
	}

	foreach my $course ($self->author_courses()) {
	    if ($course->checkJoinObject('TUSK::Permission::Role')) {
		my @author_roles = grep { !($_->getVirtualRole()) } grep { ref $_ eq 'TUSK::Permission::Role' }  $course->getJoinObjects('TUSK::Permission::Role');
		next unless (scalar @author_roles);
	    }
	    my $key = $course->school . "-" . $course->course_id;
	    $preview->{$key} = 1;
	    unless ($course_hashref->{$course}){
		push (@courses, $course);
		$course_hashref->{$course} = 1;
	    }
	}
    }

    foreach my $course (@courses){
		unless ($schoolhash->{$course->school}){
	    	$schoolhash->{$course->school} = TUSK::Core::School->new->getSchoolID($course->school);
		}

		my $school_id = $schoolhash->{$course->school};
		my $tps = $course->get_users_active_timeperiods($self->user_id);
		my $tp_cond = '';
		if ($tps and scalar(@$tps)) {
			my @tp_ids = map { $_->primary_key() } @$tps;
			$tp_cond = " and time_period_id in (" . join(',', @tp_ids) . ")";
		}
		push (@where_clause, "(school_id =" . $school_id . " and parent_course_id = " . $course->primary_key . "$tp_cond)");
    }

    return [] unless (scalar(@where_clause));

    my $sql =  "select q.quiz_id, q.title, r.start_date, l.parent_course_id, l.school_id, l.due_date from tusk.link_course_quiz l, tusk.quiz q left outer join tusk.quiz_result r on (r.quiz_id = q.quiz_id and r.user_id = '" . $self->primary_key . "'  and preview_flag = 0) where (" . join(' or ', @where_clause) . ") and available_date < now() and (due_date > now() or due_date is null) and l.child_quiz_id = q.quiz_id and r.end_date is null and (q.quiz_type = 'Quiz' or q.quiz_type = 'FeedbackQuiz') order by l.sort_order";


    my $dbh = HSDB4::Constants::def_db_handle ();

    %$schoolhash = reverse %$schoolhash;

    eval {
	my $sth = $dbh->prepare ($sql);
	$sth->execute ();
	while (my ($quiz_id, $title, $start_date, $course_id, $school_id, $due_date) = $sth->fetchrow_array) {
	    my $school = $schoolhash->{$school_id};
	    my $preview_value = $school . "-" . $course_id;
	    my $ddate;
	    if ($due_date) {
		my $dt = HSDB4::DateTime->new()->in_mysql_timestamp($due_date);
		$ddate = $dt->out_string_date_short() . ' ' . $dt->out_string_time();
	    }
	    push @$quizzes, {'quiz_id' => $quiz_id, 'title' => $title, 'start_date' => $start_date, 'course_id' => $course_id, 'school' => $school, 'preview' => $preview->{$preview_value}, 'due_date' => $ddate};
	}
     $sth->finish;
    };

    return $quizzes;
}

sub current_evals {
    #
    # Get the user's current evals
    #

    my $self = shift;
    my $dbh = HSDB4::Constants::def_db_handle ();
    my %courses = ();
    my %course_evals = ();
    my %current_evals = ();

    # Get the user groups, then filter out the ones that aren't allowed
    # (probably because they're already filled out)
    my @evals;

    # Now, get enrollment evaluations.
    my @enroll_evals = ();
    for my $school ( eval_schools() ) {
	my $db = get_school_db($school);
	my @eval_ids = ();

	eval {
	    my $sql = qq[SELECT eval_id, t.token, c.title, c.course_id
			 FROM $db\.eval e, $db\.link_course_student l, tusk.eval_type t, $db\.course c
			 WHERE l.child_user_id=?
			 AND l.parent_course_id=e.course_id
			 AND l.time_period_id=e.time_period_id
			 AND to_days(e.available_date) <= to_days(now())
			 AND to_days(e.due_date) >= to_days(now())
			 AND (e.teaching_site_id is null OR e.teaching_site_id = 0 OR e.teaching_site_id = l.teaching_site_id)
			 AND e.eval_type_id = t.eval_type_id
			 AND parent_course_id = c.course_id
			 AND eval_id not in (SELECT eval_id FROM $db\.eval_completion WHERE user_id = l.child_user_id)
			 ];

            my $sth = $dbh->prepare($sql);
	    $sth->execute($self->primary_key);

	    while (my ($eval_id, $eval_type, $course_title, $course_id) = $sth->fetchrow_array) {
		if ($eval_type eq 'teaching') {
		    $courses{$school . '/' . $course_id} = $course_title;
		    ## delete from course evals list so we could display only clinical eval
		    if (exists $course_evals{$school . '/' . $course_id}) {
			delete $course_evals{$school . '/' . $course_id};
		    }
		} elsif ($eval_type eq 'course') {
		    ## weed out course evals that has clinical evals
		    unless (exists $courses{$school . '/' . $course_id}) {
			push @{$course_evals{$school . '/' . $course_id}}, $eval_id;
		    }
		}
		push @eval_ids, $eval_id;
	    }
	    $sth->finish;

	    if (scalar @eval_ids) {
		my @evals = HSDB45::Eval->new( _school => $school)->new()->lookup_conditions('eval_id in (' . join(',', @eval_ids) . ')');
		foreach my $eval (@evals) {
##		    if ($eval->primary_key && ($eval->is_user_allowed ($self))[0]) {
			push @{$current_evals{$school . '/' . $eval->field_value('course_id')}}, $eval;
##		    }
		}
	    }
	};
	confess $@ if ($@);
    }
    return (\%current_evals, \%courses, \%course_evals);
}


sub eval_completions {
    #
    # Get the user's completions
    #

    my $self = shift;

    # Form the conditions
    my @comps = ();
    my @conds = (sprintf ("user_id='%s'", $self->primary_key),
		 'ORDER BY created DESC');
    # Return the results of the lookup
    for my $school ( eval_schools() ) {
	my $blankcomp = HSDB45::Eval::Completion->new( _school => $school );
	push @comps, $blankcomp->lookup_conditions(@conds);
    }

    return @comps;
}
sub overdue_evals {
        #
        #  Return a List of Evals that Have not been Completed by the User
        #  and are past due
        #

    my $self = shift;

    # Get the user groups, then filter out the ones that aren't allowed
    # (probably because they're already filled out)
    my @evals = map { $_->overdue_evals($self) } $self->parent_user_groups;
    # Now, get enrollment evaluations.
    my @enroll_evals = ();
    my $dbh = HSDB4::Constants::def_db_handle ();
    for my $school ( eval_schools() ) {
        my $db = get_school_db($school);
        my @eval_ids = ();
        eval {
            my $sth = $dbh->prepare (<<EOM);
SELECT e.eval_id
FROM $db\.link_course_student l,
        $db\.eval e
        LEFT OUTER JOIN $db\.eval_completion ec ON
        ec.eval_id = e.eval_id
	AND ec.user_id = ?
WHERE  l.child_user_id= ?
        AND ec.eval_id IS NULL
        AND l.parent_course_id=e.course_id
        AND l.time_period_id=e.time_period_id
        AND to_days(e.due_date) < to_days(now())
        AND (e.teaching_site_id is null
               OR e.teaching_site_id = l.teaching_site_id)
        ORDER BY e.title
EOM
            $sth->execute ($self->primary_key,$self->primary_key);

            while (my ($eval_id) = $sth->fetchrow_array) {
                push @eval_ids, $eval_id;
            }
            $sth->finish;
        };
        for my $eval_id (@eval_ids) {
            my $e = HSDB45::Eval->new( _school => $school, _id => $eval_id );
            if ($e->primary_key) {
                    push @evals, $e
                }
        }
    }

    # Now, add in the the user_group evals;
    return @evals;
}

sub get_course_grades {
	my $self = shift;
	my $course = shift;
	my $course_id = $course->primary_key();
        if (!defined($course_id)){
                confess "Need to have valid course object passed";
        }
	my $user_id = $self->primary_key();
	if (!$user_id){
		confess "Need to have valid user object passed";
	}
	my $school_id = $course->get_school->getPrimaryKeyID();
	my $time_period = $course->get_users_current_timeperiod($self->user_id);

	if ($time_period == 0 or !(defined($time_period->primary_key()))){
		return [];
	}

	my $time_period_id = $time_period->primary_key();

	my $cond = <<EOM;
publish_flag
and course_id = $course_id
and school_id = $school_id
and time_period_id = $time_period_id
EOM
	return TUSK::GradeBook::GradeEvent->lookup($cond,['sort_order'],undef,undef,
		[
		 TUSK::Core::JoinObject->new("TUSK::GradeBook::LinkUserGradeEvent", {'joinkey'=>'child_grade_event_id','origkey'=>'grade_event_id', 'cond' => "parent_user_id = '$user_id'"})
		 ]);

}

sub _databases_with_grade_events {
    my ($self) = @_;
    my $user_id = $self->primary_key;
    my $school_dbs = [];
    my $sql = <<'END_SQL';
        SELECT DISTINCT s.school_db
        FROM
          tusk.school s
          INNER JOIN tusk.grade_event ge
            ON s.school_id = ge.school_id
          INNER JOIN tusk.link_user_grade_event luge
            ON ge.grade_event_id = luge.child_grade_event_id
        WHERE luge.parent_user_id = ?;
END_SQL
    my $sth = $self->dbh->prepare($sql);
    $sth->execute($user_id);
    while ( my $row = $sth->fetchrow_hashref ) {
        push @$school_dbs, $row->{school_db};
    }
    $sth->finish;
    return $school_dbs;
}

sub _grades_list_sql {
    my ($school_db) = @_;
    my $sql = <<"END_SQL";
        SELECT
          luge.grade,
          luge.comments,
          gc.grade_category_id,
          gc.grade_category_name,
          gc.lineage,
          ge.school_id,
          s.school_name,
          ge.event_name,
          ge.grade_event_id,
          ge.sort_order,
          s.school_id,
          s.school_name,
          s.school_db,
          c.course_id,
          c.title,
          tp.start_date,
          tp.end_date,
          tp.time_period_id
        FROM
          tusk.link_user_grade_event luge
          INNER JOIN tusk.grade_event ge
            ON luge.child_grade_event_id = ge.grade_event_id
          INNER JOIN tusk.school s
            ON ge.school_id = s.school_id
          INNER JOIN $school_db.time_period tp
            ON ge.time_period_id = tp.time_period_id
          INNER JOIN $school_db.course c
            ON ge.course_id = c.course_id
          INNER JOIN tusk.grade_category gc
            ON ge.grade_category_id = gc.grade_category_id
        WHERE
          luge.parent_user_id = ?
          AND s.school_id = ?
          AND ge.publish_flag = 1
        ORDER BY
          tp.start_date DESC,
          tp.end_date DESC,
          c.title,
          gc.depth,
          gc.sort_order,
          ge.sort_order;
END_SQL
    return $sql;
}

sub _pending_eval_link {
    my ($school_name, $eval_id) = @_;
    return sprintf(
        '<a href="/protected/eval/complete/%s/%d">Pending Eval Completion</a>',
        $school_name, $eval_id
    );
}

sub _grade_link {
    my ($self, $grade_ref, $school_name) = @_;
    my $link;
    my $eval_link = TUSK::GradeBook::GradeEventEval->lookupReturnOne(
        "grade_event_id = " . $grade_ref->{grade_event_id} );
    if ($eval_link) {
        my $eval_id = $eval_link->getEvalID();
        my $eval_obj = HSDB45::Eval->new(
            _school => $school_name )->lookup_key( $eval_id );
        if ( ! $eval_obj->is_user_complete($self) ) {
            $link = _pending_eval_link($school_name, $eval_id);
        }
    }
    return $link;
}

sub _grades_for_school {
    my ($self, $school_obj) = @_;
    my $school_db = $school_obj->getSchoolDb();
    my $school_name = $school_obj->getSchoolName();
    my $school_id = $school_obj->getPrimaryKeyID();
    my $grades = [];
    my $sql = _grades_list_sql($school_db);
    my $sth = $self->dbh->prepare($sql);
    $sth->execute($self->primary_key, $school_id);
    while ( my $grade_ref = $sth->fetchrow_hashref ) {
        my $grade_eval_link = $self->_grade_link($grade_ref, $school_name);
        $grade_ref->{grade} = $grade_eval_link if $grade_eval_link;
        push @$grades, $grade_ref;
    }
    $sth->finish;
    return $grades;
}

sub _grades_list {
    my ($self) = @_;
    my $school_dbs = $self->_databases_with_grade_events();
    my $grades = [];
    foreach my $school_db (sort @$school_dbs) {
        my $school_obj = TUSK::Core::School->lookupReturnOne(
            "school_db = '$school_db'" );
        my $school_grades = $self->_grades_for_school($school_obj);
        push @$grades, @$school_grades;
    }
    return $grades;
}

sub _unique_category_ids {
    my ($student_grades) = @_;
    my @id_list = grep /\d+/, map {
        ( $_->{grade_category_id}, (split '/', $_->{lineage}) )
    } @$student_grades;
    my %seen;
    @id_list = sort { $a <=> $b } grep { ! $seen{$_}++ } @id_list;
    return \@id_list;
}

sub _grade_categories {
    my ($self, $student_grades) = @_;
    my $category = {};
    my $id_list = _unique_category_ids($student_grades);
    return $category unless @$id_list; # BUG: empty list causes SQL syntax error
    my $id_prep = sql_prep_list(@$id_list);
    my $sql = <<"END_SQL";
        SELECT gc.grade_category_id,
               gc.grade_category_name,
               gc.parent_grade_category_id,
               gc.depth,
               gc.sort_order,
               gc.lineage
        FROM tusk.grade_category gc
        WHERE gc.grade_category_id IN ($id_prep);
END_SQL
    my $sth = $self->dbh->prepare($sql);
    $sth->execute(@$id_list);
    while (my $row = $sth->fetchrow_hashref) {
        $category->{$row->{grade_category_id}} = $row;
    }
    return $category;
}

sub _grade_tree {
    # Grade tree: Map IDs to node info and children
    # School
    # |-- Time Period
    #     |-- Course
    #         |-- [Grade category tree]
    #             |-- Grade event/row
    my ($self, $student_grades) = @_;
    my $category_info = $self->_grade_categories($student_grades);
    my $school_for = {};
    my $time_period_for;
    my $course_for;
    my $category_for;
    my $info;
    my $grade_events;

    foreach my $grade (@$student_grades) {
        # create school if necessary
        my $school_id = $grade->{school_id};
        if ( ! exists $school_for->{$school_id} ) {
            $school_for->{$school_id} = {
                school_name => $grade->{school_name},
                time_periods => {},
            };
        }
        $time_period_for = $school_for->{$school_id}{time_periods};

        # create time period if necessary
        my $time_period_id = $grade->{time_period_id};
        if ( ! exists $time_period_for->{$time_period_id} ) {
            $time_period_for->{$time_period_id} = {
                start_date => $grade->{start_date},
                end_date => $grade->{end_date},
                courses => {},
            };
        }
        $course_for = $time_period_for->{$time_period_id}{courses};

        # create course if necessary
        my $course_id = $grade->{course_id};
        if ( ! exists $course_for->{$course_id} ) {
            $course_for->{$course_id} = {
                course_title => $grade->{title},
                categories => {},
            };
        }
        $category_for = $course_for->{$course_id}{categories};

        # walk lineage to create grade category tree
        my @gc_tree = grep /\d+/, split('/', $grade->{lineage});
        foreach my $id (@gc_tree) {
            if ( ! exists $category_for->{$id} ) {
                $info = $category_info->{$id};
                $category_for->{$id} = {
                    category_name => $info->{grade_category_name},
                    depth => $info->{depth},
                    sort_order => $info->{sort_order},
                    children => {},
                    grade_events => {},
                };
            }
            $category_for = $category_for->{$id}{children};
        }

        # create grade category if necessary
        my $grade_category_id = $grade->{grade_category_id};
        if ( ! exists $category_for->{$grade_category_id} ) {
            # add grade category leaf
            $info = $category_info->{$grade_category_id};
            $category_for->{$grade_category_id} = {
                category_name => $info->{grade_category_name},
                depth => $info->{depth},
                sort_order => $info->{sort_order},
                children => {},
                grade_events => {},
            };
        }
        $grade_events = $category_for->{$grade_category_id}{grade_events};

        $grade_events->{ $grade->{grade_event_id} } = $grade;
    }

    return $school_for;
}

sub _keys_in_alpha_order_by_field {
    my ($hashref, $field) = @_;
    return sort {
        $hashref->{$a}{$field} cmp $hashref->{$b}{$field}
    } keys %$hashref;
}

sub _keys_in_num_order_by_field {
    my ($hashref, $field) = @_;
    return sort {
        $hashref->{$a}{$field} <=> $hashref->{$b}{$field}
    } keys %$hashref;
}

sub _keys_in_sort_order {
    my ($hashref) = @_;
    return _keys_in_num_order_by_field($hashref, 'sort_order');
}

sub _keys_in_school_name_order {
    my ($hashref) = @_;
    return _keys_in_alpha_order_by_field($hashref, 'school_name');
}

sub _keys_in_start_date_order {
    my ($hashref) = @_;
    return _keys_in_alpha_order_by_field($hashref, 'start_date');
}

sub _keys_in_time_period_order {
    my ($hashref) = @_;
    return sort {
        my $t1 = $hashref->{$a}{start_date} . $hashref->{$a}{end_date};
        my $t2 = $hashref->{$b}{start_date} . $hashref->{$b}{end_date};
        $t1 cmp $t2
    } keys %$hashref;
}

sub _keys_in_course_title_order {
    my ($hashref) = @_;
    return _keys_in_alpha_order_by_field($hashref, 'course_title');
}

sub _grade_event_data_hash {
    my ($self, $arg_ref) = @_;
    my $grade_info = $arg_ref->{grade_info};
    my $school_name = $arg_ref->{school_name};
    my $course_id = $arg_ref->{course_id};
    my $time_period_id = $arg_ref->{time_period_id};
    my $depth = $arg_ref->{depth};

    my $user_id = $self->primary_key;
    my $indent = '&nbsp;&nbsp;' x $depth;

    my $scaled_grade = q();
    if ( defined( $grade_info->{grade} ) ) {
        # skip if eval is pending completion
        if ( $grade_info->{grade} !~ /Pending Eval Completion/ ) {
            my $course = HSDB45::Course->new(
                _school => $school_name )->lookup_key( $course_id );
            my $gb = TUSK::Application::GradeBook::GradeBook->new({
                course => $course,
                time_period_id => $time_period_id,
                user_id => $user_id
            });
            $scaled_grade = $gb->getScaledGrade(
                $grade_info->{grade}, $grade_info->{grade_event_id} );
        }
    }
    else {
        $grade_info->{grade} = "No Grade";
        $scaled_grade = "No Grade";
    }

    # add the grade to the current data arrayref
    my $event_name = encode_entities($grade_info->{event_name});
    $event_name = "$indent$event_name";
    my $grade_data = {
        grade => $grade_info->{grade},
        scaled_grade => $scaled_grade,
        comments => $grade_info->{comments},
        name => $event_name,
    };
    return $grade_data;
}

sub _walk_grade_categories {
    # Walk category tree, pushing onto the accumulator.
    # Exclude Offering Category for reasons that baffle me.
    my ($self, $arg_ref) = @_;
    my $school_name = $arg_ref->{school_name};
    my $time_period_id = $arg_ref->{time_period_id};
    my $course_id = $arg_ref->{course_id};
    my $category_for = $arg_ref->{categories};
    my $accum = $arg_ref->{accum};

    foreach my $id ( _keys_in_sort_order($category_for) ) {
        my $info = $category_for->{$id};
        my $name = $info->{category_name};
        my $depth = $info->{depth};
        my $is_offering_category = $depth == 0 && $name eq 'Offering Category';

        # push parent category data
        if (! $is_offering_category) {
            my $indent = '&nbsp;&nbsp;' x ($depth - 1);
            push @$accum, {
                grade => q(),
                scaled_grade => q(),
                comments => q(),
                name => "$indent<b>$name</b>",
            };
        }

        # push grade event data
        foreach my $evt_id ( _keys_in_sort_order($info->{grade_events}) ) {
            my $evt = $info->{grade_events}{$evt_id};
            push @$accum, $self->_grade_event_data_hash({
                grade_info => $evt,
                school_name => $school_name,
                time_period_id => $time_period_id,
                course_id => $course_id,
                depth => $depth,
            });
        }

        # recursive call down categories hierarchy
        $self->_walk_grade_categories({
            school_name => $school_name,
            time_period_id => $time_period_id,
            course_id => $course_id,
            categories => $info->{children},
            accum => $accum,
        });
    }

    return $accum;
}

sub _collapse_grade_tree {
    my ($self, $grade_hierarchy) = @_;

    # helper variables
    my $user_id = $self->primary_key;

    my $current_group = q();
    my $current_data_ref;
    my $current_category = q();
    my $grouped_grades = [];

    # iterate over schools
    my @school_id_list = _keys_in_school_name_order($grade_hierarchy);
    foreach my $school_id (@school_id_list) {
        my $school = $grade_hierarchy->{$school_id};
        my $school_name = $school->{school_name};

        # iterate over time periods
        my @tp_id_list
            = reverse _keys_in_time_period_order($school->{time_periods});
        foreach my $tpid (@tp_id_list) {
            my $tp = $school->{time_periods}{$tpid};

            # iterate over courses and walk grade hierarchy for each course
            my @course_id_list = _keys_in_course_title_order($tp->{courses});
            foreach my $course_id (@course_id_list) {
                my $course = $tp->{courses}{$course_id};
                my $data = $self->_walk_grade_categories({
                    school_name => $school_name,
                    time_period_id => $tpid,
                    course_id => $course_id,
                    categories => $course->{categories},
                    accum => [],
                });
                push @$grouped_grades, {
                    data => $data,
                    title => $course->{course_title},
                    time_period_id => $tpid,
                    school_id => $school_id,
                    school_name => $school_name,
                    course_id => $course_id,
                };
            }
        }
    }

    return $grouped_grades;
}

sub get_grades {
    my ($self) = @_;

    # This only tells you what grades you have. It does not tell you
    # if there is a grade event that you are related to but do not
    # have a grade yet.

    # TODO: This is the third place I've found where we should sort
    # grade events by category and sort order. We should create one
    # consistent way to access grade events that can be tuned for
    # student and admin users.

    # get grades associated with current user
    my $sorted_grades = $self->_grades_list();

    # Group grades by (school, time period, course title, grade category).
    my $grade_hierarchy = $self->_grade_tree($sorted_grades);

    # Result grouped_grades is an array of hashrefs.
    #
    # Each hashref contains a data arrayref, which contains grade
    # event data for that group sorted by grade category and display
    # sort order.
    my $grouped_grades = $self->_collapse_grade_tree($grade_hierarchy);

    return $grouped_grades;
}


sub has_grades {
        my $self = shift;
        my $user_id = $self->primary_key();
        if (!$user_id){
                confess "Need to have valid user object passed";
        }
	return TUSK::GradeBook::LinkUserGradeEvent->exists(" parent_user_id = '$user_id' ");
}

sub child_personal_content {
    #
    # Get top-level personal content items for the user
    #

    my ($self) = shift;
	my $params = shift;

    # No cache!
    # Get the link definition
    my $linkdef =
	$HSDB4::SQLLinkDefinition::LinkDefs{'link_user_personal_content'};
    # And get the LinkSet of parents
	my $set;
    if (exists $params->{'type'} ) {
		 $set = $linkdef->get_children ($self->primary_key,$params->{'type'});;
	}
	else {
		$set = $linkdef->get_children ($self->primary_key);;
	}
    # And return the list
    return $set->children ();
}


sub preference {
    #
    # [GS]et preferences for the user
    #

    my $self = shift;

    my ($field, $value) = @_;

    return unless defined $field;

    # We don't cache the preferences, so we just look up the one in
    # question right now
    my $pref = HSDB4::SQLRow::Preference->new;
    $pref->lookup_key ($self->primary_key, $field);
    return $pref->field_value('value') unless $value;
    my $retval;
    # Then, we do the setting if that's required
    if (not $pref->primary_key) {
	$pref->primary_key ($self->primary_key, $field);
	$retval = $pref->field_value ('value', $value);
	$pref->save;
    }
    else {
	$retval = $pref->field_value('value', $value);
	$pref->save;
    }

    # And now return the proper value
    return $retval;
}

sub new_child_personal_content_folder {
    #
    # Add a child_personal_content object to the end of this user's list
    #

    my $self = shift;
    my $title = shift || 'New Folder';

    # OK, first make the new folder
    my $folder = HSDB4::SQLRow::PersonalContent->new ();
    $folder->set_field_values ('user_id' => $self->primary_key,
			       'type' => 'Collection',
			       'body' => $title,
			       );
    my $result = $folder->save;
    if ($result) { $self->add_child_personal_content ($folder); }
    $folder;
}

sub new_child_personal_content_deck {
    #
    # Add a child_personal_content object to the end of this user's list
    #

    my $self = shift;
    my $title = shift || 'New Deck';

    # OK, first make the new folder
    my $folder = HSDB4::SQLRow::PersonalContent->new ();
    $folder->set_field_values ('user_id' => $self->primary_key,
			       'type' => 'Flash Card Deck',
			       'body' => $title,

			       );
    my $result = $folder->save;
    if ($result) { $self->add_child_personal_content ($folder); }
    $folder;
}

sub add_child_personal_content {
    #
    # Add a new personal content object to the end of this user's list
    #

    my $self = shift;
    # Get the right link definition
    my $linkdef =
	$HSDB4::SQLLinkDefinition::LinkDefs{'link_user_personal_content'};
    # Get the object to add in, and make sure it's good
    my $pc = shift;
    $pc and $pc->primary_key or return;
    # Make sure it's the right class
    $pc->isa ($linkdef->child_class) or return;
    # Get the sort order of the last item, and add 10 to it
    my @p_content = $self->child_personal_content;
    foreach (@p_content) { return if $_->primary_key == $pc->primary_key }
    my $last_sort = @p_content ?
	$p_content[-1]->aux_info ('sort_order') + 10 : 10;
    # Now do the insert
    my ($r, $msg) = $linkdef->insert (-parent_id => $self->primary_key,
				      -child_id => $pc->primary_key,
				      sort_order => $last_sort);
    # Clear the cache so we read from the DB next time we ask for this list
    if ($r) { $self->{-child_personal_content} = undef; }
    # And return the results
    return wantarray ? ($r, $msg) : $r;
}

sub all_personal_content {
    #
    # Get the relevant personal content objects
    #

    my $self = shift;
    # Check the cache

    # Make the condition (which we should quote properly...)
    my $condition = sprintf "user_id='%s'", $self->primary_key;
    # And get a list, if necessary
    my @p_cont = HSDB4::SQLRow::PersonalContent->lookup_conditions ($condition);

    # Return the list
    return @p_cont;
}

sub all_user_content {
    my $self = shift;
    my $linkdef =
	$HSDB4::SQLLinkDefinition::LinkDefs{'link_content_user'};
    my $set = $linkdef->get_parents($self->primary_key,@_);
    return $set->parents;
}

sub body {
    #
    # Get the HSDB4::XML::User user_body object and let us manipulate it
    #

    my $self = shift;

    my $body = HSDB4::XML::User->new('user_body');
    my $val = $self->field_value('body');
    if ($val) {
        eval {
    	$body->parse($val);
        };
        if ($@) { ; }
    }
    return $body;
}

sub recent_history {
    #
    # Find that this user has been looking at recently
    #

    my $self = shift;

	# Make the condition
	my $sql =
	    qq[SELECT content_id, MAX(hit_date) AS recent, COUNT(recent_log_item_id)
	       FROM recent_log_item l,
		tusk.log_item_type t
	       WHERE user_id=?
	       AND t.label='Content'
	       AND t.log_item_type_id = l.log_item_type_id
	       AND content_id!=0
	       GROUP BY content_id
	       ORDER BY recent DESC
	       LIMIT 10];
	my $dbh = HSDB4::Constants::def_db_handle();
	my @content_ids = ();
	my %times = ();
    my $recent_history;
	eval {
	    my $sth = $dbh->prepare ($sql);
	    $sth->execute ($self->primary_key);
	    while (my ($content_id, $time) = $sth->fetchrow_array) {
		push @content_ids, $content_id;
		$times{$content_id} = $time;
	    }
         $sth->finish;
	};
	confess $@ if $@;
	if (@content_ids) {
	    my $cond = 'content_id in (' . join (', ', @content_ids) . ')';
	    my @conts = sort { $times{$b->primary_key}
			       cmp $times{$a->primary_key}
			   } HSDB4::SQLRow::Content->lookup_conditions($cond);
	    $recent_history = \@conts;
	}
	else {
	    $recent_history = [];
	}

    return @{$recent_history};
}

sub available_recent_history {
    my $self = shift;
    return grep { $_->is_active() } $self->recent_history;
}

sub update_previous_login {
    my $self = shift;
    return unless $self->primary_key;
    $self->set_field_values("previous_login" => $self->login,
			    "login" => HSDB4::DateTime->new->out_mysql_timestamp);
    $self->save;
}

sub get_loggedout_flag{
    my ($self) = @_;
    return $self->field_value('loggedout_flag');
}

sub update_loggedout_flag{
    my ($self, $value) = @_;
    $self->field_value('loggedout_flag', $value);
    $self->save;
}

sub previous_login_unix_timestamp {
    my $self = shift;
    my $dt = HSDB4::DateTime->new;
    $dt->in_mysql_timestamp($self->previous_login);
    return $dt->out_unix_time;
}

sub new_body {
    #
    # Get a blank HSDB4::XML::User user_body for us to work with
    #

    my $self = shift;
    my $body = HSDB4::XML::User->new('user_body');
    $self->{-body} = $body;
    return $self->{-body};
}

#
# >>>>> Input functions <<<<<
#

sub in_fdat_hash {
    #
    # Read a big hash into the data, including setting contact info
    #

    my $self = shift;
    my @data = @_;

    $self->new_body()->in_fdat_hash(@data);

    my @field_values = ();
    my %fields = map { ($_, 1) } $self->fields;

    while (my ($key, $val) = splice (@data, 0, 2)) {
	next unless $key =~ /field_(.+)$/ and $fields{$1};
	push @field_values, ($1, $val);
    }

    $self->set_field_values (@field_values,
			     'body', $self->{-body}->out_xml);
}

sub in_xml {
    #
    # Attempts to fill in a new object based on XML
    #
}

#
# >>>>> (X|HT)ML output
#

sub out_contact_info {
    #
    # Get a list of the contact_info HSDB4::XML::Element objects
    #

    my $self = shift;
    # Who's viewing the document? And do we have any groups in common with
    # them?
    # Get the viewer object
    my $viewer = shift;
    $viewer = $self->new->lookup_key($viewer) unless ref $viewer;
    my $same_user = 0;
    my $common_group = 0;
    my $valid_user = 0;
    # First, if it's the same user..
    if ($viewer and $viewer->can('primary_key')) {
	if ($self->primary_key eq $viewer->primary_key) {
	    $same_user = 1;
	    $common_group = 1;
	    $valid_user = 1;
	}
	elsif ($viewer and $viewer->can('out_groups')) {
	    # Figure out if they have any in common, and set the flag
	    foreach my $user_group ($self->out_groups) {
		$common_group = grep { $_ eq $user_group } $viewer->out_groups;
		last if $common_group;
	    }
	    $valid_user = 1;
	}
	elsif (  (not HSDB4::Constants::is_guest($viewer->primary_key)) && (TUSK::Shibboleth::User::isShibUser($viewer->primary_key) == -1)  ) {
	    $valid_user = 1;
	}
    }

    # Go through the contact info bits and see what we've got, and what
    # we're allowed to see
    my @viewable = ();
    foreach my $cinfo ($self->body->tag_values ('contact_info')) {
	my $pub = $cinfo->get_attribute_values('publicity')->value;
	if ($pub eq 'public') { push @viewable, $cinfo }
	elsif ($pub eq 'class') { push @viewable, $cinfo if $common_group }
	elsif ($pub eq 'tufts') { push @viewable, $cinfo if $valid_user }
	elsif ($pub eq 'none') { push @viewable, $cinfo if $same_user }
    }
    # And return what we find
    return @viewable;
}

sub out_groups {
    #
    # Return a comma separated list of groups the use belongs to
    #

    my $self = shift;
    return map { $_->field_value('label') } $self->parent_user_groups;
}

sub out_html_email {
    #
    # Return the email address in a <A HREF="mailto:..."> tag
    #

    my $self = shift;
    my $email = $self->field_value ('email') or return;
    return sprintf ('<A HREF="mailto:%s">%s</A>', $email, $email);
}

sub out_full_name {
    #
    # Make a nice full name for the user
    #

    my $self = shift;
    my ($fn, $ln, $sfx, $dg) =
	$self->get_field_values(qw(firstname lastname suffix degree));
    return $self->primary_key unless $ln;
    # Process the suffix
    $sfx = '' unless $sfx;
    # Make sure there are not spaces in it
    $sfx =~ s/\s//g;
    # If it's a roman numeral (VIII or less, that is), just use a space...
    if ($sfx =~ /^[iv]+$/i) { $sfx = " $sfx" }
    # ...otherwise, use a comma and a space
    elsif ($sfx) { $sfx = ", $sfx" }
    # Just say lastname if we don't know anything else
    if (not $fn and not $dg) { return "$ln" }
    # Otherwise, format it all out nicely
    return sprintf ("%s%s%s%s", $fn ? "$fn " : '',
		    $ln, $sfx, $dg ? ", $dg" : '');
}

sub out_user_code {
    #
    # Make a hashed code for the user
    #

    my $self = shift;
    my $secret = shift || '';
    my $ctx = Digest::MD5->new;
    $ctx->add ($self->primary_key, $secret);
    return $ctx->add ($ctx->b64digest())->b64digest ();
}

sub name_compare {
    #
    # Do a name comparison
    #

    my ($left, $right) = @_;
    my $result;
    $result = $left->field_value('lastname') cmp $right->field_value('lastname') and return $result;
    $result = $left->field_value('firstname') cmp $right->field_value('firstname') and return $result;
    $result = $left->field_value('midname') cmp $right->field_value('midname') and return $result;
}

sub out_label {
    #
    # SQLRow's function...
    #

    my $self = shift;
    return $self->out_full_name;
}

sub out_html_full_name {
    #
    # Put the user's full name with a link to their page on HSDB
    #

    my $self = shift;
    return sprintf '<A HREF="%s">%s</A>', $self->out_url, $self->out_full_name;
}

sub out_option_name {
    #
    # output of this user as would appear in an html select box (as an option)
    #

    my $self = shift;
    my @fields;
    my @spacing;
    my $optionString;
    my $displacement;

    $fields[0] = $self->last_name.", ".$self->first_name;
    $fields[1] = $self->primary_key;
    $fields[2] = $self->email;
    $fields[3] = $self->affiliation;

    $spacing[0] = 23;
    $spacing[1] = 15;
    $spacing[2] = 23;
    $spacing[3] = 0;

    for(my $i=0; $i<scalar(@fields); $i++){
	if ($spacing[$i] and length($fields[$i]) >= $spacing[$i]-1){
	    $fields[$i] = substr($fields[$i], 0, $spacing[$i]-1);
	    $fields[$i] =~s/, ?q$//;
	}
	$optionString .= $fields[$i];
	$displacement = $spacing[$i] - length($fields[$i]);
	if ($displacement > 0){
	    $optionString .= "&nbsp;" x $displacement;
	}
    }

    return $optionString;
}

sub out_short_name {
    #
    # A short version of the user's name
    #

    my $self = shift;
    my ($fn, $ln, $mn) =
	$self->get_field_values (qw(firstname lastname midname));
    return $self->primary_key unless $ln;
    my $out = "";
    # First initial, if available
    if ($fn) { $out .= sprintf "%s. ", substr ($fn, 0, 1) }
    # Middle initial, if available
    if ($mn) { $out .= sprintf "%s. ", substr ($mn, 0, 1) }
    # And tack on the last name
    if ($ln) { $out .= $ln }
    return $out;
}

sub out_lastfirst_name{
    #
    # Show lastname, comma, then firstname
    #

    my $self = shift;
    return $self->field_value_esc('lastname') . ", " . $self->field_value_esc('firstname');

}

sub out_abbrev {
    #
    # SQLRow's function...
    #

    my $self = shift;
    return $self->out_short_name;
}

sub out_html_short_name {
    #
    # Put the user's short name with a link to their page on HSDB
    #

    my $self = shift;
    return sprintf '<A HREF="%s">%s</A>', $self->out_url, $self->out_short_name;
}

sub out_html_body {
    #
    # Make the body a nice chunk of HTML
    #

    my $self = shift;
    return "<TABLE BORDER=0>" . $self->body()->out_html_row() . "</TABLE>";
}

sub out_html_row {
    #
    # Return a nice 4-data element summary row for this row
    #

    my $self = shift;

    return sprintf ("<TR><TD COLSPAN=2>%s</TD><TD>%s</TD><TD>%s</TD></TR>\n",
		    $self->out_html_full_name,
		    $self->field_value('affiliation'), $self->out_html_email);
}

sub out_html_div {
    #
    # Return a nice HTML bit with this object's information
    #

    my $self = shift;
    return join ("\n",
		 "<BODY>\n<H2>", $self->out_full_name, "</H2>\n",
		 "<DIV>", $self->out_html_email, "</DIV>\n",
		 $self->out_html_body
		 );
}

sub out_edit_url {
    #
    # Returns a URL for editing a row
    #

    # Return the link to the row's fundamental page
    my $self = shift;
    # Get the base URL from HSDB4::Constants
    my $class = ref $self || $self;
    my $url = $HSDB4::Constants::EditURLs{$class} or return;
    return $url;
}

sub out_xml {
    #
    # Return an XML version of this object
    #

}

#
# >>>>>  Account Maintenance  <<<<<<
#

sub new_user {
    #
    # Checks to make sure this user isn't already in the database, and if not,
    # then writes the user.
    #

    my $self = shift;
    my $is_ldap = shift;
    return unless $self->primary_key;

    # Check for a user with this name already
    {
	my $check_user = $self->new->lookup_key ($self->primary_key);
	return if $check_user->primary_key;
    }

    # New users have to change passwords and all that good stuff
    $self->field_value ('profile_status', 'ChangePassword') unless ($is_ldap);

    # And now to do the actual save...
    $self->save;
}

sub user_save {
    #
    # Does a save, but checks to make sure that the UpdateInfo flag is
    # down as well.
    #

    my $self = shift;
    # Get the status
    my $status = $self->field_value('profile_status');
    # Take the UpdateInfo out of the status
    $status = join (',', grep { $_ ne 'UpdateInfo' } split (',', $status));
    # Put the new string back in
    $self->field_value('profile_status', $status);
    warn sprintf ("Saving fields %s to user %s Stat: [%s] New: [%s]",
		  join (':', keys %{$self->{_modified}}), $self->primary_key,
		  $self->field_value('profile_status'), $status);
    # Save to the database
    return $self->SUPER::save;
}

sub is_expired {
    #
    # Return true if the user account as expired
    #

    my $self = shift;
    # Get the expiration date
    my $exp_date = $self->field_value('expires') or return;
    # Make sure it's not all zeros (like it would be if it weren't set)
    $exp_date =~ /[1-9]/ or return 0;
    # Make a now object
    my $now = HSDB4::DateTime->new;
    # Make an object out of the expiration
    $exp_date = HSDB4::DateTime->new->in_mysql_date ($exp_date);
    # And return 1 if it's later than that
    return 1 if $now->out_unix_time > $exp_date->out_unix_time + 86400;
    # Otherwise, return 0
    return 0;
}

sub verify_password {
    #
    # Checks that the password is good
    #
    my $self = shift;
    my $inpw = shift;
    my $authen= HSDB45::Authentication->new();
    return $authen->verify_password($self,$inpw);
}

sub verify {
    #
    # Checks that the password is good and returns a list of return code and message
    # and this should provide a better debugging interface
    #
    my $self = shift;
    my $inpw = shift;
    my $authen= HSDB45::Authentication->new();
    return $authen->verify($self->user_id(),$inpw);

}

sub send_email_from {
    my $self = shift;
    my $email = shift;
    if ($email) {
	$self->{_email_from} = $email;
    }
    return $self->{_email_from};
}

sub send_email {
    #
    # Send the user an e-mail message
    #

    my $self = shift;
    my $subject = shift;
    my $email = $self->field_value('preferred_email');
    unless($email) {$email = $self->field_value('email');}
    return (0,"No To: email address specified") unless ($email);
    my $message = join("\n",@_);
    my $email_from = $self->send_email_from;
    $email_from = $TUSK::Constants::Institution{Email} unless ($email_from);

	my $mail = TUSK::Application::Email->new(
		{
			to_addr   => $email,
			from_addr => $email_from,
			subject   => $subject,
			body      => $message,
			'Content-Type' => ($message =~ /^\<html\>/ ? "text/html; charset='utf-8'" : ""),
		});

    if ($mail->send()) {
		return (1,"Email sent to ".$self->primary_key);
    }
    return(0,$mail->getError());
}



sub change_password {
    #
    # The actual business of changing a user's password
    #

    my $self = shift;
    my $new_pw = shift;

    my ($res, $msg) = (1, "Successfully changed password for ".$self->primary_key."\n");
    eval {
	# Make a connection
	my $dbh = HSDB4::Constants::def_db_handle();
	# Do the update specially
	$dbh->do (sprintf qq[UPDATE user SET password=password(%s),
			     profile_status=NULL,
                             password_reset=NOW()
			     WHERE %s=%s],
		  $dbh->quote ($new_pw), $self->primary_key_field,
		  $dbh->quote ($self->primary_key));
	$self->field_value('profile_status', '');

    };
    ($res, $msg) = (0, "Could not save password to database: $@") if $@;
    return ($res, $msg);
}

sub user_change_password {
    #
    # Interface to easily change a user's password given the old password and
    # two copies of a new password.
    #

    my $self = shift;
    my ($old_pw, $new_pw, $new_pw_copy) = @_;

    # Make sure the old password is right
    return (0, "Could not verify the old password")
	unless $self->verify_password ($old_pw);
    # Make sure the new passwords are the same
    return (0, "Both copies of the new password must be the same")
	unless $new_pw eq $new_pw_copy;
    # Make sure the new password is different from the old one
    return (0, "New password must be different from the old password")
	unless $old_pw ne $new_pw;
    return (0, "New password must be six or more characters long")
	unless length($new_pw) > 5;

    return ($self->change_password ($new_pw));
}

sub reset_password {
    #
    # Reset the password to something sort of random, and mail the user the
    # new password and force them to log in again
    #

    my $self = shift;
    my ($pw_flag,$msg) = $self->check_password_reset;
    return ($pw_flag,$msg) unless $pw_flag;

    ($pw_flag,$msg) = $self->process_reset_password;
    return ($pw_flag,$msg);
}

sub admin_reset_password {
    my $self = shift;
    my ($pw_flag,$msg) = $self->process_reset_password;
    return ($pw_flag,$msg);

}
sub check_password_reset {
    # Make sure that we haven't reset the password in the last day
    my $self = shift;
    my $pw_reset = $self->field_value ('password_reset');
    if ($pw_reset =~ /[1-9]/) {
	# Make a now object
	my $now = HSDB4::DateTime->new;
	# Make an object out of the reset time
	$pw_reset = HSDB4::DateTime->new->in_mysql_date ($pw_reset);
	  if ($pw_reset->out_unix_time > $now->out_unix_time - 86400) {
	      	return (0, "Password was reset too recently")
	  }
    }
    return (1);
}

sub process_reset_password {
    my $self = shift;
    # Create a random password; avoid 0, O, 1, and l to avoid confusing
    # users
    my @letters= ('A'..'N', 'P'..'Z', 'a'..'k', 'm'..'z', 2..9, 2..9, 2..9);
    my $newpw = join '', map { $letters[rand(73)] } 1..8;
    # Actually change the password, and raise the flag requiring it to be
    # reset when the user first logs in
    my ($res, $msg) = $self->change_password ($newpw);
    $self->field_value('profile_status','ChangePassword');
    $self->save();
    # Send them an e-mail message telling them what their new password is
    ($res,$msg) = $self->send_email ($TUSK::Constants::SiteAbbr." Password Change",
		       sprintf ("Your ".$TUSK::Constants::SiteAbbr." (http://" . $ENV{'HTTP_HOST'} . ") username is '%s'.",
				$self->primary_key),
		       "Your password has been reset to '$newpw'.",
		       "",
		       "You will be required to change it the next",
		       "time you log in to ".$TUSK::Constants::SiteAbbr.".",
		       "",
		       "If you have any concerns, please reply to",
		       "this message, and a staff member will",
		       "get back to you as soon as possible.") if $res;
    return ($res,$msg);
}

sub get_id_api_token {
    my $self = shift;
    my $token = shift;
    my @info = split('!!',$token);
    return $info[1];
}

sub get_patient_logs{
    my ($self) = @_;
    my $patientlogs = [];

    my $user_id = $self->primary_key();
    my $affiliation = $self->affiliation();
    my $schools = TUSK::Core::School->new->lookup("school_name = '$affiliation'");
    return $patientlogs unless (scalar(@$schools));

    my $db = $schools->[0]->getSchoolDb();
    my $school_id = $schools->[0]->getPrimaryKeyID();

    my $sql =<<EOM;
select c.course_id as course_id, c.title as title, $school_id as school_id, '$affiliation' as school_name, t.time_period_id as time_period_id, concat(t.period, " (", t.academic_year, ")") as time_period, ts.teaching_site_id as teaching_site_id, ts.site_name as site_name, ts.site_city_state as site_city_state,
if ((t.start_date <= curdate() and t.end_date >= curdate()), 1, 0) as form_link,
fo.form_id as form_id, fo.form_name as form_name
from
tusk.link_course_form f,
tusk.form_builder_form fo,
tusk.form_builder_form_type ft,
$db\.link_course_student l,
$db\.time_period t,
$db\.course c,
$db\.teaching_site ts
where
f.school_id = ? and
f.parent_course_id = l.parent_course_id and
l.time_period_id = t.time_period_id and
l.child_user_id = ? and
ts.teaching_site_id = l.teaching_site_id and
c.course_id = l.parent_course_id and
fo.form_id = f.child_form_id and
fo.publish_flag = 1 and
fo.form_type_id = ft.form_type_id and
ft.token = 'PatientLog'
order by t.start_date desc, t.end_date desc;
EOM
    my $dbh = HSDB4::Constants::def_db_handle ();

    eval {
	my $sth = $dbh->prepare ($sql);
	$sth->execute ($school_id, $user_id);
	$patientlogs = $sth->fetchall_arrayref({});
    };
    if ($@){
	confess "$@";
    }

    return $patientlogs;
}

=item
    Return a list of current checklist_groups
=cut
sub get_course_competency_checklist_groups {
    my ($self, $course) = @_;
    my $school = $course->get_school();
    my $db = $school->getSchoolDb();

    return TUSK::Competency::Checklist::Group->lookup('publish_flag = 1 AND school_id = ' . $school->getPrimaryKeyID() . ' AND course_id = ' . $course->primary_key(), undef, undef, undef, [
                TUSK::Core::JoinObject->new("TUSK::Core::HSDB45Tables::LinkCourseStudent", { database => $db, joinkey => 'parent_course_id', origkey => 'course_id', cond => "child_user_id = '" . $self->primary_key() . "'", jointype => 'inner' }),
        	TUSK::Core::JoinObject->new("TUSK::Core::HSDB45Tables::TimePeriod", { database => $db, joinkey => 'time_period_id', origkey=> "link_course_student.time_period_id",  cond => "start_date < now()  AND (end_date + interval 1 day) > now()", jointype => 'inner' }),
    ]);
}

sub get_courses_with_checklists {
    my $self = shift;
    my $affiliation = $self->affiliation();
    my $school = TUSK::Core::School->lookupReturnOne("school_name = '$affiliation'");
    my $db = $school->getSchoolDb();

    my $sth = TUSK::Competency::Checklist::Group->new()->databaseSelect(qq(
SELECT distinct course.course_id, course.title
FROM $db.course
INNER JOIN $db.link_course_student on (parent_course_id = course.course_id and child_user_id = ?)
INNER JOIN $db.time_period on (link_course_student.time_period_id = time_period.time_period_id AND start_date < now() AND (end_date + interval 1 day) > now())
INNER JOIN tusk.competency_checklist_group on (school_id = ? AND link_course_student.parent_course_id = competency_checklist_group.course_id AND publish_flag = 1)
ORDER BY course.title), $self->primary_key(), $school->getPrimaryKeyID());

    my $data = [];
    while (my ($course_id, $course_title) = $sth->fetchrow_array()) {
	push @$data, {
	    course_id => $course_id,
	    course_title => $course_title,
	    affiliation => $affiliation,
	};
    }
    return $data;
}


sub get_director_checklists {
    my $self = shift;

    my $affiliation = $self->affiliation();
    my $school = TUSK::Core::School->lookupReturnOne("school_name = '$affiliation'");
    return [] unless ref $school eq 'TUSK::Core::School';

    my $checklists = TUSK::Competency::Checklist::Group->lookup("competency_checklist_group.school_id = " . $school->getPrimaryKeyID(), undef, undef, undef, [
        TUSK::Core::JoinObject->new("TUSK::Core::HSDB45Tables::Course", {
	    database => $school->getSchoolDb(),
	    jointype => 'inner',
	    joinkey => 'course_id',
        }),
        TUSK::Core::JoinObject->new("TUSK::Course::User", {
	    jointype => 'inner',
	    origkey => 'course.course_id',
	    joinkey => 'course_id',
	    joincond => "course_user.school_id = competency_checklist_group.school_id",
        }),
        TUSK::Core::JoinObject->new("TUSK::Core::HSDB45Tables::TimePeriod", {
	    database => $school->getSchoolDb(),
	    jointype => 'inner',
	    origkey => 'course_user.time_period_id',
	    joinkey => 'time_period_id',
	    joincond => "start_date < now() AND (end_date + interval 1 day) > now()",
        }),
        TUSK::Core::JoinObject->new("TUSK::Permission::UserRole", {
	    jointype => 'inner',
	    origkey => 'course_user.course_user_id',
	    joinkey => 'feature_id',
	    joincond => "permission_user_role.user_id = '" . $self->getPrimaryKeyID() . "'",
        }),
        TUSK::Core::JoinObject->new("TUSK::Permission::Role", {
	    jointype => 'inner',
	    origkey => 'permission_user_role.role_id',
	    joinkey => 'role_id',
	    joincond => "role_token = 'director'",
        }),
    ]);

    my @data = ();
    foreach my $checklist (@$checklists) {
	push @data, { school_name => $affiliation, course_id => $checklist->getCourseID(), checklist_group_id => $checklist->getPrimaryKeyID(), checklist_group_name => $checklist->getTitle() };
    }
    return \@data;
}

sub get_director_forms {
    my ($self, $form_type_token) = @_;
	croak "Missing Form Type" unless $form_type_token;

    my $forms = [];
    my $school = TUSK::Core::School->lookupReturnOne("school_name = '" . $self->affiliation() . "'");

    return $forms unless (defined $school);

    my $db = $school->getSchoolDb();
    my $school_id = $school->getPrimaryKeyID();

    my $sql = qq(
		 SELECT DISTINCT c.course_id AS course_id, c.title AS title, f.school_id AS school_id,
		 s.school_name AS school_name, fo.form_id AS form_id, fo.form_name AS form_name
		 FROM tusk.link_course_form f,
		 tusk.form_builder_form fo,
		 tusk.form_builder_form_type ft,
		 tusk.school s,
		 tusk.course_user cu,
		 tusk.permission_user_role ur,
		 tusk.permission_role pr,
		 tusk.permission_feature_type pft,
		 $db\.course c
		 WHERE f.school_id = ?
		 AND f.parent_course_id = cu.course_id
		 AND f.school_id = cu.school_id
		 AND cu.user_id = ?
		 AND cu.course_user_id = ur.feature_id
		 AND ur.role_id = pr.role_id
		 AND pr.feature_type_id = pft.feature_type_id
		 AND pft.feature_type_token = 'course'
		 AND pr.role_token in ('director', 'site_director', 'manager')
		 AND c.course_id = cu.course_id
		 AND fo.form_id = f.child_form_id
		 AND s.school_id = f.school_id
		 AND fo.publish_flag = 1
		 AND fo.form_type_id = ft.form_type_id
		 AND ft.token = ?
		 );

    my $dbh = HSDB4::Constants::def_db_handle ();
    eval {
	my $sth = $dbh->prepare($sql);
	$sth->execute($school_id, $self->primary_key(), $form_type_token);
	$forms = $sth->fetchall_arrayref({});
    };
    confess "$@" if ($@);
    return $forms;
}


sub get_instructor_simulated_patients {
    my ($self) = @_;

    my $affiliation = $self->affiliation();
    my $school = TUSK::Core::School->new->lookupReturnOne("school_name = '$affiliation'");
    return [] unless $school;

    my $db = $school->getSchoolDb();
    my $sql = qq(
		 SELECT '$affiliation' as school_name, d.course_id, title,
		 b.form_id as form_id, form_name, form_description
		 FROM tusk.link_course_form a,
		 tusk.form_builder_form b,
		 tusk.form_builder_form_type c,
		 $db\.course d,
		 tusk.course_user e,
		 tusk.form_builder_form_association i,
		 tusk.permission_user_role ur,
		 tusk.permission_role pr,
		 tusk.permission_feature_type pft
		 WHERE a.parent_course_id = d.course_id
		 AND a.parent_course_id = e.course_id
		 AND a.child_form_id  = b.form_id
		 AND publish_flag = 1
		 AND b.form_type_id = c.form_type_id
		 AND c.token = 'SP'
		 AND pr.role_token = 'instructor'
		 AND e.user_id = ?
		 AND a.child_form_id = i.form_id
		 AND e.user_id = i.user_id
		 AND e.course_user_id = ur.feature_id
		 AND ur.role_id = pr.role_id
		 AND pr.feature_type_id = pft.feature_type_id
		 AND pft.feature_type_token = 'course'
		 group by e.user_id
	     );

    my $dbh = HSDB4::Constants::def_db_handle ();
    my $simulated_patients;

    eval {
		my $sth = $dbh->prepare($sql);
		$sth->execute($self->primary_key());
		$simulated_patients = $sth->fetchall_arrayref({});
    };

	confess "$@" if ($@);

    return $simulated_patients;
}

sub get_assessments {
	my ($self) = @_;
	my $sql = qq(
				 select s.school_id, s.school_name, parent_course_id as course_id,
			 	 f.form_id as form_id, form_name, form_description, y.entry_id
				 from tusk.form_builder_subject_assessor sa
			     inner join tusk.link_course_form as cf on (sa.form_id = cf.child_form_id)
				 inner join tusk.form_builder_form as f on (sa.form_id = f.form_id)
				 inner join tusk.form_builder_form_type as ft on (f.form_type_id = ft.form_type_id)
				 inner join tusk.school as s on (cf.school_id = s.school_id)
				 left outer join
					(select form_id, e.entry_id
					 from tusk.form_builder_entry e, tusk.form_builder_entry_association ea
					 where e.entry_id = ea.entry_id and ea.user_id = ? and complete_date is not NULL
						 and is_final = 1) as y on (y.form_id = sa.form_id)
				 where f.publish_flag = 1
				 and ft.token = 'Assessment' and status in (1,2)
				 and sa.subject_id  = ?
	);

    my $dbh = HSDB4::Constants::def_db_handle ();
	my $assessments = [];
    eval {
		my $sth = $dbh->prepare($sql);
		$sth->execute($self->primary_key(),$self->primary_key());
		$assessments = $sth->fetchall_arrayref({});
    };

	confess "$@" if ($@);
    return $assessments;

}

sub get_instructor_assessments {
	my ($self) = @_;
	my $sql = qq(
				 select distinct a.school_id, school_name, a.parent_course_id as course_id,
				 b.form_id as form_id, form_name, form_description
				 from tusk.link_course_form a,
				 tusk.form_builder_form b,
				 tusk.form_builder_form_type c,
				 tusk.form_builder_subject_assessor d,
				 tusk.school e
				 where a.child_form_id = d.form_id
				 and a.school_id = e.school_id
				 and a.child_form_id  = b.form_id
				 and publish_flag = 1
				 and b.form_type_id = c.form_type_id
				 and c.token = 'Assessment'
				 and assessor_id = ?
				 );

    my $dbh = HSDB4::Constants::def_db_handle ();
	my $assessments = [];
    eval {
		my $sth = $dbh->prepare($sql);
		$sth->execute($self->primary_key());
		$assessments = $sth->fetchall_arrayref({});
    };

	confess "$@" if ($@);
    return $assessments;
}


### include school, course and course group announcements for the affiliation
sub get_all_announcements {
    my $self = shift;
    my @announcements = ();

    if (my $affiliation = $self->affiliation_or_default_school()) {
	push @announcements, map {
                          { item   => $_,
			    type   => 'user_group',
			    school => $affiliation,
			    id     => $TUSK::Constants::Schools{$affiliation}{Groups}{SchoolWideUserGroup} }
		      } HSDB45::Announcement::schoolwide_announcements($affiliation);
    }

    if (my $course_announcements = $self->get_course_announcements()) {
	push @announcements, @$course_announcements;
    }

    return \@announcements;
}

sub get_course_announcements {
    my $self = shift;
    my $announcements = ();

    foreach my $ug ($self->parent_user_groups()) {   ### course group announcements
	push(@$announcements,  map {
                            {  item   => $_,
			       type   => 'user_group',
			       school => $ug->school,
			       id     =>  $ug->field_value('user_group_id'),
			       id_label => $ug->out_label }
			  } $ug->announcements ) if $ug->announcements;
    }

    my $seen_courses = {};
    foreach my $course ($self->current_courses()) {   ###  course announcements
	next if ($seen_courses->{ $course->primary_key() });
	$seen_courses->{$course->primary_key()} = 1;

	my @course_announcements = $course->announcements();
	foreach my $course_announcement (@course_announcements) {
		push @$announcements, { item   => $course_announcement,
					type   => 'course',
					course =>  $course };
	}
    }

    return $announcements;
}

sub count_new_announcements{
	my $self = shift;
	my $anns = $self->get_all_announcements();
	my $base_date = HSDB4::DateTime->new();
	$base_date->subtract_days(5);
	my $new_cnt = 0;

	foreach my $ann (@$anns){
		my $ann_date = HSDB4::DateTime->new()->in_mysql_date($ann->{item}->field_value('start_date'));
		if($ann_date->out_unix_time() > $base_date->out_unix_time()){
			#an announcement is new if less than 5 days old
			$new_cnt++;
		}
	}
	return $new_cnt;
}

sub get_announcements_by_start{
	my $self = shift;

	my $anns = $self->get_all_announcements();

	my @sorted = sort { $b->{item}->field_value('start_date') cmp $a->{item}->field_value('start_date') } @$anns;
    return \@sorted;

}

sub get_announcements_by_group_and_course{
	my $self = shift;

	my $anns = $self->get_all_announcements();

	my @ug_anns;
	while(scalar @$anns){
		if($anns->[0]->{type} eq 'user_group'){
			push @ug_anns, shift @$anns;
		}
		else{
			last;
		}
	}

	my @sorted = sort { $b->{item}->field_value('start_date') cmp $a->{item}->field_value('start_date') } @ug_anns;

	my @courses = sort {
		my $cmp_val = $a->{course}->out_abbrev() cmp $b->{course}->out_abbrev();
		unless($cmp_val){
			$cmp_val = $b->{item}->field_value('start_date') cmp $a->{item}->field_value('start_date');
		}
		return $cmp_val
		} @$anns;


	push @sorted, @courses;
    return \@sorted;
}

sub _get_course_assignments_sql {
    my $self = shift;
    return <<"END_SQL";
SELECT
    a.assignment_id, g.event_name, g.course_id, s.school_name
FROM
    tusk.assignment a
INNER JOIN
    tusk.grade_event g ON (a.grade_event_id = g.grade_event_id)
INNER JOIN
    tusk.school s ON (g.school_id = s.school_id)
INNER JOIN
    $_[0].link_course_student l
    ON
        (g.course_id = l.parent_course_id AND l.child_user_id = '$self->{'user_id'}' AND g.time_period_id = l.time_period_id)
INNER JOIN
    $_[0].time_period t
    ON
        (t.time_period_id = l.time_period_id AND t.start_date <= curdate() AND t.end_date >= curdate())
WHERE
    a.due_date >=curdate()
ORDER BY
    a.due_date
END_SQL
}

sub get_course_assignments {

    my $self = shift;

    my @courses = $self->current_courses();

    my %schools_dbs = map { $_->school_db() => 1} @courses;

    my @all_assignments;

    foreach my $school(keys %schools_dbs) {
	my $sql = $self->_get_course_assignments_sql($school);
	my $sth = TUSK::Core::SQLRow->new()->databaseSelect($sql);

	push @all_assignments, values %{$sth->fetchall_hashref('assignment_id')};
    }

    return \@all_assignments;
}

sub get_school_announcements {
	my $self = shift;
	my %all_announcements;

	## kludgy, get unique school names from two different types of course ojbects
	my @schools = keys %{{ map { $_ => 1 }
		( (map { $_->getJoinObject('TUSK::Core::School')->getSchoolName() } $self->author_courses()),
		  (map { $_->school() } $self->current_courses() )) }};

	foreach my $school (@schools) {
		my @announcements = HSDB45::Announcement::schoolwide_announcements($school);
		foreach my $ann (@announcements) {
			$all_announcements{$school}{$ann->primary_key()} = $ann;
		}
	}
	return \%all_announcements;
}

sub makeGhost {
	my ($self, $user_id, @params) = @_;
	# Basically we need to set the primary_key and the user ID
	if($user_id) {
		$self->primary_key($TUSK::Constants::shibbolethUserID . $user_id);
		$self->field_value('lastname', TUSK::Shibboleth::User->new()->lookupKey($user_id)->getUserGreeting());
		$self->field_value('status', 'ghost');
		$self->field_value('email', $TUSK::Constants::ErrorEmail);
		$self->field_value('sid', $user_id);
	}
	return;
}

sub isGhost {
	my ($self) = @_;
	if($self->field_value('status') eq 'ghost') {return(1);}
	return(0);
}

sub get_course_categories {
	my $self = shift;
	my @categories = ();

	if (my $affiliation = $self->affiliation_or_default_school()) {
		my $cat = TUSK::HomepageCategory->new(_school => $affiliation);
		@categories = $cat->lookup_conditions("order by sort_order");
	}

	return @categories;
}


### for a given school, return a list of user group courses with categories
sub get_user_group_courses_with_categories {
    my $self = shift;
    my $dbh = HSDB4::Constants::def_db_handle ();
    my %categories = ();

    foreach my $school ( course_schools() ) {
    my $db = get_school_db($school);

    my $sql = qq(
		 SELECT hc.course_id, hc.label as course_label, hcat.label as category_label, indent, url, hc.sort_order, hcat.sort_order
		 FROM $db.homepage_course hc, $db.homepage_category hcat, $db.link_user_group_user lug
		 WHERE hc.category_id = hcat.id
		 AND hc.show_date <= date(now()) AND  (hc.hide_date >= date(now()) OR hc.hide_date = '0000-00-00')
		 AND (lug.parent_user_group_id = hcat.primary_user_group_id OR lug.parent_user_group_id = hcat.secondary_user_group_id)
		 AND lug.child_user_id = ?
		 ORDER BY hcat.sort_order, hc.sort_order
		 );
    eval {
	my $sth = $dbh->prepare($sql);
	$sth->execute($self->primary_key());

	while (my ($course_id, $course_title, $category, $indentation, $course_url, $course_sort_order, $category_sort_order) = $sth->fetchrow_array) {
	    $categories{$school}{$category_sort_order}{label} = $category;
	    push @{$categories{$school}{$category_sort_order}{courses}}, {
		id => $course_id,
		title => $course_title,
		url => $course_url,
		indentation => $indentation
		};
	}
	$sth->finish();
    };

	print $@ if ($@);
}
    return \%categories;
}


sub get_enrollment_courses {
        my $self = shift;
	my %ids;

	my @enrollment_courses;
	my @current_courses = $self->current_courses({'only_enrollment' => 1});

	foreach my $course (@current_courses){
	    push @enrollment_courses, $course if ($course->type() !~ /group|thesis committee/ && !(exists $ids{$course->primary_key()}));
	    $ids{$course->primary_key()} = 1;
	}

	return @enrollment_courses;
}

sub save {
	my ($self, @params) = @_;
	# Check to make sure we are not a "ghost" user
	if($self->status eq 'ghost') {return 1;}
	else {
		if(!defined($self->{uid}) ) {
			$self->{uid} = get_new_uid();
		}
		my $returnCode = $self->SUPER::save(@params);
		if($returnCode && $self->{saveForumData}) {
			my $dbh = HSDB4::Constants::def_db_handle();
			my $forumConfig = $MwfConfig::cfg;

			my $email = $self->field_value('preferred_email');
			unless($email) {$email = $self->field_value('email');}

			my $quotedEmail = $dbh->quote($email);
			my $quotedName = $dbh->quote($self->first_name ." ". $self->last_name);

			my $sqlStatement = "UPDATE $forumConfig->{dbPrefix}users SET realName=$quotedName, email=$quotedEmail WHERE userName=". $dbh->quote($self->primary_key);
			$dbh->do($sqlStatement);
			$self->{saveForumData} = 0;
		}
		return $returnCode;
	}
}

sub set_last_name{
	my ($self, @params) = @_;
	my $newLastName = $params[0];
	$self->field_value("lastname", $newLastName);
	$self->{saveForumData} = 1;
}

sub set_first_name{
	my ($self, @params) = @_;
	my $newFirstName = $params[0];
	$self->field_value("firstname", $newFirstName);
	$self->{saveForumData} = 1;
}

sub official_image {
	my ($self) = @_;
	my $filePath;
	my $imagePath = '/graphics/no-profile.gif';

	## check to see if there exists a .jpg, .jpeg, .bmp, .png, or .gif image for the user
	my @suffixes = qw(jpg jpeg bmp png gif);
	foreach my $suffix (@suffixes) {
		$filePath = $TUSK::Constants::BaseStaticPath . $TUSK::Constants::UserImagesPath . '/' . $self->uid() . '/official.' . $suffix;
		if (-e $filePath) {
			$imagePath = $TUSK::Constants::UserImagesPath . '/' . $self->uid() . '/official.' . $suffix;
			last;
		}
	}
	return $imagePath;
}

sub get_faculty_class_meeting {
    my ($self, $db) = @_;
    my $user_id = $self->user_id();
    my $dbh = HSDB4::Constants::def_db_handle();
    my $class_meetings;

    eval {
	    my $sql = "SELECT meeting_date, starttime, endtime, location, title, label, class_meeting_id, course_id FROM $db.link_class_meeting_user
                  INNER JOIN $db.class_meeting on parent_class_meeting_id = class_meeting_id
                  INNER JOIN tusk.class_meeting_type on type_id = class_meeting_type_id
                  WHERE child_user_id = '$user_id' ORDER BY meeting_date, starttime, endtime";

      my $sth = $dbh->prepare ($sql);
	    $sth->execute();
	    $class_meetings = $sth->fetchall_arrayref();
	    $sth->finish;
    };

    return $class_meetings;
}

1;

__END__

=head1 NAME

B<HSDB4::SQLRow::User> - Instatiation of the a B<SQLRow> to
represent a user (either student or faculty).  Also serves as the
interface for user updates, profiles, preferences, etc.

=head1 SYNOPSIS

    use HSDB4::SQLRow::User;

    # Make a new object
    my $user = HSDB4::SQLRow::User->new ();
    # And feed in the data from the database
    $user->lookup_key ($key);

    # Get the linked objects for this user
    my @courses = $user->courses;
    my @class_meetings = $user->class_meetings;
    my @content = $user->content;
    my @small_groups = $user->small_groups;
    my @user_groups = $user->user_groups;
    my @personal_content = $user->personal_content;

    # Get the HSDB4::XML::Element object corresponding to the body
    my $body = $user->body();

    # A quick but nice HTML page
    print "<HTML>\n",
    "<HEAD><TITLE>".$TUSK::Constants::SiteAbbr." User: ", $user->out_short_name, "</TITLE></HEAD>\n",
    "<BODY>\n<H2>", $user->out_full_name, "</H2>\n",
    "<DIV>", $user->out_html_email, "</DIV>\n",
    $user->out_html_body,
    "</BODY>\n",
    "</HTML>\n";

    # Is this the user's password?
    $user->verify_password ($pw);

    # Password change by the user:
    $user->user_change_password ($old_pw, $new_pw, $new_pw2);
    # Oops, forgot password!  Reset it:
    $user->reset_password();

    # Send the user an e-mail message
    $user->send_email ("Random Message", # This is the subject
		       "This is the first real line",
		       "And this is another.  I'll just be sticking",
		       "them together to send them to you.",
		       "Love, TUSK");

=head1 Table Definition

    CREATE TABLE user (
        user_id char(24) NOT NULL DEFAULT '',
        tufts_id char(10),
        password char(16),
        email varchar(80) DEFAULT '' NOT NULL,
        profile_status set('UpdateInfo','ChangePassword'),
        lastname varchar(40) DEFAULT '' NOT NULL,
        firstname varchar(20) DEFAULT '' NOT NULL,
        midname varchar(20),
        suffix varchar(10),
        degree varchar(20),
        affiliation set('Medical', 'Dental', 'Veterinary', 'NEMC', \
             'Affiliated Hospitals', 'Nutrition', 'Arts and Sciences', \
             'Fletcher', 'Administration', 'Sackler', 'HSDB') \
             DEFAULT 'Medical' NOT NULL,
        gender enum('Male','Female','Unknown') NOT NULL DEFAULT 'Unknown',
        body text,
        PRIMARY KEY (user_id),
        KEY lastname (lastname, firstname),
        KEY affiliation (affiliation)
    );

=head1 DESCRIPTION

Represents a user.  Look the user up in the database, and provide an
interface to all sorts of manipulations from them: whether they're
authorized to look at particular pages, what their preferences are,
what they've written.

=head1 Linked Objects

B<parent_content()>, B<author_courses()>, B<parent_class_meetings()>,
B<parent_small_groups()>, B<parent_user_groups()>,
B<personal_content()>: Get the appropriate sets of linked objects for
the given $user object.

B<body()> gets the text of the C<body> field and parses it as a
B<HSDB4::XML::Element> object, which can then be used for fun purposes
like forms and HTML displays.

=head1 Output Methods

B<out_full_name()>, B<out_short_name()>, B<out_html_full_name()>,
B<out_html_short_name()>, B<out_html_email()>: Return formatted bits
of stuff, like short or full names.  B<out_label()> and
B<out_abbrev()> call B<out_full_name()> and B<out_short_name()>,
respectively.  B<out_html_*()> return them formatted with HTML
HREFs. B<out_body_body()> returns a nice HTML formatting of the
information contained in the body, essentially a nice table of the
C<body> object.

B<out_contact_info()> returns a list of C<contact_info>
B<HSDB4::XML::Element> objects which are in the C<body> object.

B<out_html_row()> returns a set 4-cell row for putting into an HTML
table which presents summary information for a user.  It contains the
user's full name, their affiliation, and their e-mail address.

B<out_xml()> is not yet implemented.

=head1 Input Methods

B<in_fdat_hash()> takes a set of C<(key, value)> pairs like would come
from B<HTML::Embperl>'s C<%fdat> hash and put them in the right
places. The values which are actually field names of B<User> will
cause those fields to be set. Everything gets passed to the body's
B<HSDB4::XML> object, which causes the body to set the values (if the
form was generated properly).

B<in_xml()> is not yet implemented.

=head1 Account Maintenance Methods

B<verify_password()> takes a password and checks against the user
object whether that password is valid by using the C<PASSWORD()>
function of MySQL.  Returns a true value if the passwords match, and a
false value otherwise.

B<user_change_password()> is the routine by which a user changes
his/her password; a form asks for the current password and two copies
of a new password. B<user_change_password()> checks the make sure the
old password is good and that the two new copies of the password
match, and that the new password is different from the old one. Then
it changes the password. Returns two values: a status (1 or 0), and a
status message.

B<send_email()> is a utility function of sending an e-mail
message to a user.  The first argument is made into the subject of the
message, and each subsequent argument is added to the message body.
The mail is then sent directly using B<Net::SMTP>.

B<reset_password()> changes the user's password to a random but
appropriate string and sends an e-mail to their e-mail address
informing them of this and what the new address is. It also sets the
C<ChangePassword> flag in the database's C<profile_status> field for
the user, so that they can be asked to change their password.

B<change_password()> does the actual behind-the-curtain business of
changing the user's password and setting the appropriate in their
C<profile_status> field.  Its first argument is the new password.  If
its second argument is true, it will try to lower the
C<ChangePassword> flag on the user's C<profile_status> field if it is
raised.

=head1 AUTHOR

Tarik Alkasab <talkas01@tufts.edu>

=head1 SEE ALSO

L<HSDB4>, L<HSDB4::SQLRow>, L<HSDB4::SQLLink>, L<HSDB4::XML>.

=cut
