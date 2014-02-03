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


package HSDB45::UserGroup;

use strict;
use base qw/HSDB4::SQLRow/;

BEGIN {
    require HSDB4::SQLLink;

    use vars qw($VERSION);
    
    $VERSION = do { my @r = (q$Revision: 1.67 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
}

sub version { return $VERSION }

# dependencies for things that relate to caching
my @mod_deps  = ('HSDB45::Course',
		 'HSDB45::ClassMeeting',
		 'HSDB45::Eval',
		 'HSDB45::Announcement');

my @file_deps;

sub get_mod_deps {
    return @mod_deps;
}

sub get_file_deps {
    return @file_deps;
}

use Carp qw(confess cluck);
use HSDB4::Constants;
require HSDB45::Course;
require HSDB45::ClassMeeting;
require HSDB4::SQLRow::Content;
require HSDB45::Eval;
require HSDB45::Announcement;

# File-private lexicals
my $tablename = "user_group";
my $primary_key_field = "user_group_id";
my @fields = qw(user_group_id
                label
		homepage_info
		schedule_flag_time
		modified
		description
		sub_group
		sort_order
		);
my %blob_fields = ('description'=>1);
my %numeric_fields = ();

my %cache = ();

# Creation methods

sub new {
    # Find out what class we are
    my $incoming = shift;
    # Call the super-class's constructor and give it all the values
    my $self = $incoming->SUPER::new ( _tablename => $tablename,
				       _fields => \@fields,
				       _blob_fields => \%blob_fields,
				       _numeric_fields => \%numeric_fields,
				       _primary_key_field => $primary_key_field,
				       _cache => \%cache,
				       @_);
    # Finish initialization...
    return $self;
}

sub label {
    my $self = shift;
    return $self->field_value('label');
}

sub homepage_info {
    my $self = shift;
    return $self->field_value('homepage_info');
}

sub schedule_flag_time {
    my $self = shift;
    return $self->field_value('schedule_flag_time');
}

sub description {
    my $self = shift;
    return $self->field_value('description');
}

sub sub_group {
    my $self = shift;
    return $self->field_value('sub_group');
}

sub modified {
    my $self = shift;
    return $self->field_value('modified');
}

sub split_by_school {
    my $self = shift;
    return 1;
}

sub user_link {
    my $self = shift;
    my $db = $self->school_db();
    return $HSDB4::SQLLinkDefinition::LinkDefs{"$db\.link_user_group_user"};
}

sub course_link {
    my $self = shift;
    my $db = $self->school_db();
    return $HSDB4::SQLLinkDefinition::LinkDefs{"$db\.link_course_user_group"};
}

#
# >>>>> Linked objects <<<<<
#

sub email_child_users{
    my $self = shift;
    my $subject = shift;
    my $email_from=shift;
    my @message = @_;
    my @child_users=$self->child_users;
    foreach my $child_user (@child_users){
	$child_user->send_email_from($email_from);
	$child_user->send_email($subject,@message);
    }

}


sub child_users {
    #
    # Get the users in this group
    #

    my $self = shift;
    # Check cache...
    unless ($self->{-child_users}) {
        # Get the link definition
        my $linkdef = $self->user_link ();
        # And use it to get a LinkSet of users
	my @child_users = ();
	for my $user ($linkdef->get_children($self->primary_key(),@_)->children()) {
	    push @child_users, $user 
		if $user && ref $user eq 'HSDB4::SQLRow::User' && $user->primary_key();
	}
        $self->{-child_users} = \@child_users;
	return @child_users;
    }
    # Return the list
    return @{$self->{-child_users}};
}

sub ordered_child_users {
    my $self = shift;
    return sort { $a->last_name cmp $b->last_name || $a->first_name cmp $b->first_name } $self->child_users;
}

sub child_users_hashref {
    #
    # Get a hashref that is the set of users in the group
    #

    my $self = shift;
    # Check for the cache
    unless ($self->{-child_users_hashref}) {
	# Otherwise, make up the cache
	my %user_hash = ();
	for my $user ($self->child_users) {
	    $user_hash{$user->primary_key} = 1;
	}
	$self->{-child_users_hashref} = \%user_hash;
    }
    # Now return the value
    return $self->{-child_users_hashref};
}

sub getStudentMembers {
	my ($self, $course, $time_period_id, $just_user_id) = @_;

	return [] unless $course->isa('HSDB45::Course');

	unless ($time_period_id) {
		my $time_period = $course->get_current_timeperiod();
		if ($time_period) {
			$time_period_id = $time_period->primary_key();
		} else {
			return [];
		}
	}

    my $dbh = HSDB4::Constants::def_db_handle();
    my $db = $self->school_db();
	my $sql = qq(select a.child_user_id
				 from $db\.link_user_group_user a, $db\.link_course_student b, $db\.time_period c
				 where a.child_user_id = b.child_user_id
				 and parent_user_group_id = ?
				 and parent_course_id = ?
				 and b.time_period_id = c.time_period_id
				 and b.time_period_id = ?
				 );
    my $sth = $dbh->prepare( $sql );
    eval {$sth->execute( $self->primary_key(), $course->primary_key(), $time_period_id) };
    warn $@, return if $@;

	my $user_ids = $sth->fetchall_arrayref([0]);
	return [] if (!$user_ids || scalar @$user_ids == 0) ;

	if ($just_user_id) {
		return [ map { $_->[0] } @$user_ids ];
	} else {
		my @users = HSDB4::SQLRow::User->new()->lookup_conditions("user_id in (" . join(",", map { "'$_->[0]'" } @$user_ids) . ")");
		return \@users;
	}
}

=for
sub getCourseStudentMembers {
	my ($self, $time_period_id) = @_;

	unless ($time_period_id) {
		my $time_period = $course->get_current_timeperiod();
		if ($time_period) {
			$time_period_id = $time_period->primary_key();
		} else {
			return [];
		}
	}

    my $dbh = HSDB4::Constants::def_db_handle();
    my $db = $self->school_db();
	my $sql = qq(select a.child_user_id
				 from $db\.link_user_group_user a, $db\.link_course_student b
				 where a.child_user_id = b.child_user_id
				 and parent_user_group_id = ?
				 and parent_course_id = ?
				 and b.time_period_id = c.time_period_id
				 and b.time_period_id = ?
				 );
    my $sth = $dbh->prepare( $sql );
    eval {$sth->execute( $self->primary_key(), $course->primary_key(), $time_period_id) };
    warn $@, return if $@;

	my $user_ids = $sth->fetchall_arrayref([0]);
	return unless $user_ids;
	my @users = HSDB4::SQLRow::User->new()->lookup_conditions("user_id in (" . join(",", map { "'$_->[0]'" } @$user_ids) . ")");
	return \@users;
}
=cut

sub reset_user_list {
    #
    # Undo the cache stuff
    #

    my $self = shift;
    $self->{-child_users_hashref} = 0;
    $self->{-child_users} = 0;
}

sub contains_user {
    #
    # Check to see if a user is contained in a group
    #

    my $self = shift;
    # Read in a user_id
    my $user_id = shift;
    # See if it's an object, and if it is, get the ID
    $user_id = $user_id->primary_key if (ref($user_id) && $user_id->isa('HSDB4::SQLRow'));

    return $self->user_link()->check_for_link($self->primary_key(), $user_id) ? 1 : 0;
    # return $id ? 1 : 0;

    # Check in the hash, and return 1 if it's the case
    return 1 if $self->child_users_hashref ()->{$user_id};
    # Return false otherwise
    return 0;
}

sub can_edit_course {
    my $self = shift;
    my $course = shift;
    my $group_id = $self->primary_key;
    my $school = $course->school;
    my $admin_group = $HSDB4::Constants::School_Admin_Group{$school};
    return 1 if ($group_id eq $admin_group);
}

sub can_edit_content {
    my $self = shift;
    my $content = shift;
    my $group_id = $self->primary_key;
    my $school = $content->field_value('school');
    $school = $content->course->field_value('school') unless ($school);
    return 1 if ($HSDB4::Constants::School_Edit_Group{$school} =~ /$group_id/);
    return 1 if ($HSDB4::Constants::School_Admin_Group{$school} =~ /$group_id/);
}

sub get_admin_group{
	my $self = shift;
	my $school = shift;

	my $type = ref $self ? ref $self : $self;
	my $ug = $self->new(_school => $school);
	$ug->lookup_key($HSDB4::Constants::School_Admin_Group{$school});
	return $ug;
}

sub add_user {
    #
    # Add the user to a particular group
    #

    my ($self,$user,$un,$pw) = @_;

	my $linkdef = $self->user_link ();

    my $user_id;
    if (ref $user and $user->isa ($linkdef->child_class ())) {
	$user_id = $user->primary_key;
    }
    else {
	$user = $linkdef->child_class ()->new->lookup_key ($user);
	$user_id = $user->primary_key;
    }
    return (0, "Couldn't figure out user") unless $user_id;

	$self->add_child_user( $un, $pw, $user_id );
}

sub courses {
    #
    # Find the courses that a particular user group takes for a given time_period_id
    #

    my $self = shift;
    my @time_period_ids = @_;
    my @course_ids = ();
    my $db = $self->school_db();
    my $tp_cond = '';
    if (@time_period_ids) {
	$tp_cond = sprintf(" AND lcug.time_period_id IN (%s)", join(", ", @time_period_ids));
    }
    my $sql = qq[SELECT lcug.parent_course_id FROM $db\.link_course_user_group lcug, $db\.course c
		 WHERE lcug.parent_course_id=c.course_id AND lcug.child_user_group_id=?$tp_cond ORDER BY c.title];
    my $dbh = HSDB4::Constants::def_db_handle();
    my $sth = $dbh->prepare( $sql );
    eval {
	$sth->execute( $self->primary_key() );
	while (my ($id) = $sth->fetchrow_array()) {
	    push @course_ids, $id if $id;
	}
     $sth->finish;
    };
    warn $@, return if $@;

    my @courses = ();
    my $school = $self->school();
    for my $course_id (@course_ids) {
	my $course = HSDB45::Course->new(_school => $school, _id => $course_id);
	unless ($course && $course->primary_key()) {
	    die "Failed to construct a course for course_id is $course_id";
	}
	push @courses, $course;
    }
    return @courses;
}

sub time_periods {
	#
	# Find the time periods that this group has courses associated.
	#

	my $self    = shift;
	my @time_periods = ();
    my $school = $self->school();
	my $db = $self->school_db();
	my $sql = qq[SELECT DISTINCT time_period_id FROM $db\.link_course_user_group
				WHERE child_user_group_id=?];
	my $dbh = HSDB4::Constants::def_db_handle();
	my $sth = $dbh->prepare( $sql );
	eval {
	$sth->execute( $self->primary_key() );
	while (my ($id) = $sth->fetchrow_array()) {
		if ( $id ) {
			my $time_period = HSDB45::TimePeriod->new( _school => $school )->lookup_key( $id );
	    	push @time_periods, $time_period;
		}
	}
     $sth->finish;
	};
	warn $@, return if $@;

	return @time_periods;
}


sub make_courses {
    my $self = shift;
    my $mysql_date = shift;

}

sub count_time_period_meetings {
    my $self = shift;
    my $date = shift;
    my $db = $self->school_db();

    unless ($date) {
	$date = HSDB4::DateTime->new()->out_mysql_date();
    }
    my $blank_period = HSDB45::TimePeriod->new( _school => $self->school() );
    my @periods = $blank_period->time_periods_for_date($date);
    return 0 unless @periods;
    my $sum = 0;
    my $sql = qq[SELECT COUNT(*) 
		 FROM $db\.link_course_user_group l, $db\.class_meeting m
		 WHERE l.time_period_id=? AND m.course_id=l.parent_course_id
		 AND m.meeting_date BETWEEN ? AND ?];
    my $sth = HSDB4::Constants::def_db_handle()->prepare($sql);    
    for my $period (@periods) {
	$sth->execute($period->primary_key(), $period->field_value('start_date'),
		      $period->field_value('end_date'));
	my ($count) = $sth->fetchrow_array();
	$sum += $count;
     $sth->finish;
    }
    return $sum;
}




sub time_period_meetings{
     #
     # Find the class meetings that a user group is currently taking
     #
 
     my $self = shift;
     my $mysql_date = shift;
     my $db = $self->school_db();
     
 
     
     
     if (!$mysql_date){
		$mysql_date="curdate()";
	} else {
		$mysql_date = "'" . $mysql_date . "'";
	}
	
 	# Make the condition
 	my $sql = qq[select class_meeting_id from $db\.link_course_user_group l, $db\.time_period t, $db\.class_meeting m
 			where 	l.child_user_group_id = ? 
 			AND m.course_id=l.parent_course_id
 			AND m.meeting_date>=t.start_date and m.meeting_date<=t.end_date
 			AND l.time_period_id = t.time_period_id 
 			AND t.start_date <= $mysql_date and t.end_date >= $mysql_date];
 	my $dbh = HSDB4::Constants::def_db_handle();
 	my @current_class_meetings = ();
 	eval {
 	    my $sth = $dbh->prepare ($sql);
 	    $sth->execute($self->primary_key());
 	    while (my ($class_meeting_id) = $sth->fetchrow_array) {
 		push @current_class_meetings, $class_meeting_id;
 	    }
         $sth->finish;
 	};
 	warn $@ if $@;
 	my $temp = 
 	    [ map { HSDB45::ClassMeeting->new( _school => $self->school(), _id => $_ ) } 
 	      @current_class_meetings ];
    return @{$temp};
 }
 
 
sub current_class_meetings{
    #
    # Find the class meetings that a user group is currently taking
    #

    my $self = shift;
    my $db = $self->school_db();
    unless ($self->{-current_class_meetings}) {
	# Make the condition
	my $sql = qq[select class_meeting_id from $db\.link_course_user_group l, $db\.time_period t, $db\.class_meeting m
			where l.child_user_group_id = ? 
			AND m.course_id=l.parent_course_id
			AND m.meeting_date>t.start_date and m.meeting_date<t.end_date
			AND l.time_period_id = t.time_period_id 
			AND t.start_date<curdate() and t.end_date>curdate();];
	my $dbh = HSDB4::Constants::def_db_handle();
	my @current_class_meetings = ();
	eval {
	    my $sth = $dbh->prepare ($sql);
	    $sth->execute($self->primary_key());
	    while (my ($class_meeting_id) = $sth->fetchrow_array) {
		push @current_class_meetings, $class_meeting_id;
	    }
         $sth->finish;
	};
	warn $@ if $@;
	$self->{-current_class_meetings} = 
	    [ map { HSDB45::ClassMeeting->new( _school => $self->school(), _id => $_ ) } 
	      @current_class_meetings ];
    }
   return @{$self->{-current_class_meetings}};
 }

sub class_meetings {
	my ($self, $start_date, $end_date) = @_;

    my $db = $self->school_db();
	# Make the condition
	my $sql = qq[select class_meeting_id from $db\.link_course_user_group l, $db\.time_period t, $db\.class_meeting m
			where l.child_user_group_id = ? 
			AND m.course_id=l.parent_course_id
			AND m.meeting_date>=t.start_date and m.meeting_date<=t.end_date
			AND l.time_period_id = t.time_period_id 
			AND t.start_date<='$start_date' and t.end_date>='$start_date'
			AND m.meeting_date>='$start_date' and m.meeting_date<='$end_date'
			ORDER BY meeting_date, starttime, endtime desc;];
	my $dbh = HSDB4::Constants::def_db_handle();
	my %class_meetings = ();
	my $date = HSDB4::DateTime->new()->in_mysql_date( $start_date );
	$class_meetings{ $start_date } = ();
	while ( $date->out_mysql_date lt $end_date ) {
		$date->add_days(1);
		$class_meetings{ $date->out_mysql_date } = ();
	}

	eval {
	    my $sth = $dbh->prepare ($sql);
	    $sth->execute($self->primary_key());
	    while (my ($class_meeting_id) = $sth->fetchrow_array) {
			my $meeting = HSDB45::ClassMeeting->new( _school => $self->school(), _id => $class_meeting_id );
			push @{$class_meetings{ $meeting->meeting_date }}, $meeting;
	    }
         $sth->finish;
	};
	warn $@ if $@;
	return %class_meetings;
}

sub current_courses {
    #
    # Find the courses that a user group is currently taking
    #

    my $self = shift;
    my $db = $self->school_db();
    unless ($self->{-current_courses}) {
	# Make the condition
	my $sql = qq[SELECT parent_course_id 
		     FROM $db\.link_course_user_group l, $db\.time_period t 
		     WHERE l.child_user_group_id=?
		     AND l.time_period_id=t.time_period_id 
		     AND t.start_date < curdate() and t.end_date > curdate()];
	my $dbh = HSDB4::Constants::def_db_handle();
	my @current_courses = ();
	eval {
	    my $sth = $dbh->prepare ($sql);
	    $sth->execute($self->primary_key());
	    while (my ($course_id) = $sth->fetchrow_array) {
		push @current_courses, $course_id;
	    }
         $sth->finish;
	};
	confess $@ if $@;
        my $current_course_objects = [];
	my $course_obj;
	foreach my $course_id (@current_courses){
		$course_obj = HSDB45::Course->new(_school=>$self->school(),_id=>$course_id);
		if (!defined($course_obj->primary_key())){
			cluck "Invalid course ID : $course_id for user_group ".$self->primary_key().
			" in school ".$self->school();
		}
		push @{$current_course_objects}, $course_obj;
	}
	$self->{-current_courses} =  $current_course_objects;
    }
    return @{$self->{-current_courses}};
}

sub has_discussion {
    my $self = shift;
    if ($self->field_value('homepage_info') =~ /Discussion/) { return 1 }
    return;
}

sub has_evals {
    my $self = shift;
    if (!defined($self->field_value('homepage_info'))) { return;  }
    if ($self->field_value('homepage_info') =~ /Evals/) { return 1 }
    return;
}

sub current_evals {
    #
    # Get a list of the current evals for this group
    #

    my $self = shift;

    my @evals = ();
    # We skip unless the Evals flag is set in homepage_info field.
    return unless $self->has_evals();
    my $dbh = HSDB4::Constants::def_db_handle ();
    eval {
	my $db = $self->school_db();
	# Do a lookup to get all the appropriate evals: that is, evals where
	# we can find a link_course_user_group which specifies an appropriate
	# time_period_id and where the course also specifies User Group
        my $sth = $dbh->prepare (<<EOM);
SELECT eval_id FROM
        $db\.eval e,
        $db\.link_course_user_group l,
        $db\.course c
        WHERE l.child_user_group_id=?
        AND l.parent_course_id=e.course_id
        AND e.course_id=c.course_id
        AND find_in_set('User Group', c.associate_users)
        AND l.time_period_id=e.time_period_id
        AND to_days(e.available_date) <= to_days(now())
        AND to_days(e.due_date) >= to_days(now())
EOM

	$sth->execute ($self->primary_key);

	while (my ($eval_id) = $sth->fetchrow_array) { push @evals, $eval_id }
     $sth->finish;
    };
    warn $@ if $@;

    # Return the list
    return map { HSDB45::Eval->new( _school => $self->school(), _id => $_ ) } @evals;
}


sub overdue_evals {
        #
        #  Generate a list of evals that have already past there due date
        #  for this user group.
        #

    my $self = shift;
    my $user = shift || confess "A User Object is required by overdue_evals";
    my $user_id = $user->primary_key() or confess "A initialized user object is required for overdue_evals";

    my @evals = ();
    # We skip unless the Evals flag is set in homepage_info field.
    return unless $self->has_evals();
    my $dbh = HSDB4::Constants::def_db_handle ();
    eval {
        my $db = $self->school_db();
        # Do a lookup to get all the appropriate evals: that is, evals where
        # we can find a link_course_user_group which specifies an appropriate
        # time_period_id and where the course also specifies User Group
        my $sth = $dbh->prepare (<<EOM);
SELECT distinct e.eval_id FROM
        $db\.link_course_user_group l,
        $db\.course c,
        $db\.eval e
        LEFT OUTER JOIN $db\.eval_completion ec ON
        ec.eval_id = e.eval_id
	AND ec.user_id = '$user_id'
        WHERE l.child_user_group_id=?
        AND ec.eval_id IS NULL
        AND l.parent_course_id=e.course_id
        AND e.course_id=c.course_id
        AND find_in_set('User Group', c.associate_users)
        AND l.time_period_id=e.time_period_id
        AND to_days(e.due_date) < to_days(now())
        ORDER BY e.title
EOM
        $sth->execute ($self->primary_key);

        while (my ($eval_id) = $sth->fetchrow_array) { push @evals, $eval_id }
        $sth->finish;
    };
    confess $@ if $@;

    # Return the list
    return map { HSDB45::Eval->new( _school => $self->school(), _id => $_ ) } @evals;
}

sub has_hot_content {
    my $self = shift;
    my $homepage_info = $self->field_value('homepage_info');
    if (defined($homepage_info) && ($homepage_info =~ /Hot Content/)) { return 1 }
    return;
}

sub hot_content {
    my $self = shift;
    return () unless $self->has_hot_content();
    unless ($self->{-hot_content}) {
	my $db = HSDB4::Constants::get_school_db( $self->school() );
	my $sql = "SELECT content_ids FROM $db\.hot_content_cache WHERE user_group_id=?";
	my $dbh = HSDB4::Constants::def_db_handle();
	my @content_ids = ();
	eval {
	    my $sth = $dbh->prepare($sql);
	    $sth->execute($self->primary_key());
	    my ($ids) = $sth->fetchrow_array();
         $sth->finish;
	    if ($ids) { @content_ids = split(/\s+/, $ids); }
	};
	warn $@ if $@;
	if (@content_ids) {
	    my $cond = 'content_id in (' . join (', ', @content_ids) . ')';
	    my @conts = HSDB4::SQLRow::Content->lookup_conditions ($cond);
	    $self->{-hot_content} = \@conts;
	}
	else {
	    $self->{-hot_content} = [];
	}
    }
    return @{$self->{-hot_content}};
}

sub compute_hot_content {
    #
    # Find the content that members of this group are looking at
    #

    my $self = shift;
    # We skip unless homepage_info has Hot Content set.
    return unless $self->has_hot_content();

    my $db = HSDB4::Constants::get_school_db( $self->school() );
	# Make the condition
    my $sql = 
	qq[SELECT content_id, COUNT(recent_log_item_id) AS log_count
	   FROM recent_log_item l, user u, $db\.link_user_group_user g,
		tusk.log_item_type t
	   WHERE l.hit_date > SUBDATE(CURDATE(), INTERVAL 10 DAY)
	   AND t.label='Content'
	   AND t.log_item_type_id = l.log_item_type_id
	   AND l.user_id=u.user_id
	   AND u.user_id=g.child_user_id
	   AND g.parent_user_group_id=?
	   GROUP BY parent_user_group_id, content_id
	   ORDER BY parent_user_group_id, log_count DESC
	   LIMIT 10];
    my $dbh = HSDB4::Constants::def_db_handle();
    my @content_ids = ();
    eval {
	my $sth = $dbh->prepare ($sql);
	$sth->execute($self->primary_key());
	while (my ($content_id, $count) = $sth->fetchrow_array) {
	    push @content_ids, $content_id;
	}
     $sth->finish;
    };
    warn $@ if $@;
    if (@content_ids) {
	my $update = 
	    "REPLACE $db\.hot_content_cache (user_group_id, content_ids) VALUES (?, ?)";
	my $sth = $dbh->prepare($update);
	$sth->execute($self->primary_key(), join(' ', @content_ids));
    }
    warn $@ if $@;
}

sub has_announcements {
    my $self = shift;
    if ($self->field_value('homepage_info') =~ /Announcements/) { return 1 }
    return;
}

sub systemwide_usergroup {
    return schoolwide_usergroup($TUSK::Constants::Default{School});
}

sub schoolwide_usergroup {
    my $school = lc(shift);
    my $user_group_id = HSDB4::Constants::school_wide_user_group_id($school)
          || $TUSK::Constants::Schools{$TUSK::Constants::Default{School}}{Groups}{SchoolWideUserGroup};
    return HSDB45::UserGroup->new(_school => $school, _id => $user_group_id);
}

sub announcement_link {
    my $self = shift();
    my $db = HSDB4::Constants::get_school_db($self->school());
    return $HSDB4::SQLLinkDefinition::LinkDefs{"$db\.link_user_group_announcement"};
}

sub add_announcement {
    my $self = shift();
    my ($username, $password, $announcement_id) = @_;

    my ($r, $msg) = $self->announcement_link()->insert(-user => $username,
						       -password => $password,
						       -parent_id => $self->primary_key(),
						       -child_id => $announcement_id);
    return ($r, $msg);
}

sub remove_announcement {
    my $self = shift();
    my ($username, $password, $announcement_id) = @_;

    my ($r, $msg) = $self->announcement_link()->delete(-user => $username,
						       -password => $password,
						       -parent_id => $self->primary_key(),
						       -child_id => $announcement_id);
    return ($r, $msg);
}

sub announcements { # namely, unexpired ones
    my $self = shift;

	unless ( $self->{-current_ann} ) {
		my @ann = grep { $_->current() } $self->announcement_link()->get_children($self->primary_key)->children();
		$self->{-current_ann} = \@ann;
	}

    return @{$self->{-current_ann}};
}

sub all_announcements { # notably, including expired ones
    my $self = shift;

    return $self->announcement_link()->get_children($self->primary_key)->children();
}

sub can_user_manage_user_group {
    #
    # Decide whether a user has permission to edit the user_group information
    #

    my $self = shift;
    my $user = shift;

    return unless $self->school();
    # Check for a school-based admin group here
    my $admin_group_id = $HSDB4::Constants::School_Admin_Group{$self->school()};
    my $admin_group = $self->new(_id => $admin_group_id);
    if ($admin_group && $admin_group->contains_user($user)) { return 1; }

    # Failed all the tests
    return 0;
}

sub add_child_user {
    #
    # Add a user to this user_group
    #

    my $self = shift;
    my ($u, $p, $username, $tp, @roles) = @_;

    $self->delete_child_user($u, $p, $username);

	if ( $self->sub_group eq 'No' ) {
		my $link_course_student = $HSDB4::SQLLinkDefinition::LinkDefs{ $self->school_db() . '.link_course_student' };
		foreach my $course ( $self->courses ) {
			my $course_tp = $self->course_link()->get_row( $course->primary_key, $self->primary_key )->{'time_period_id'};

			$link_course_student->insert( '-parent_id' => $course->course_id, '-child_id' => $username, 'time_period_id' => $course_tp );
		}
	}

    my ($r, $msg) = $self->user_link()->insert (-user => $u, -password => $p,
						-child_id => $username,
						-parent_id => $self->primary_key,
						time_period => $tp);
    if ($r) { $self->reset_user_list () }

    return ($r, $msg);
}

sub delete_children{
    #
    # Delete all users from this user_group
    #

    my $self = shift;
    my ($u, $p) = @_;

	my $link_course_student = $HSDB4::SQLLinkDefinition::LinkDefs{ $self->school_db() . '.link_course_student' };

	foreach my $course ( $self->courses ) {
		my $course_tp = $self->course_link()->get_row( $course->primary_key, $self->primary_key )->{'time_period_id'};

		if ( $self->sub_group() eq 'No' ) {
			foreach my $user ( @{$self->user_link()->get_children($self->primary_key)->{'_list'}} ) {
				$link_course_student->delete( '-parent_id' => $course->course_id, '-child_id' => $user->{'-child'}->{'user_id'}, 'cond' => ' AND time_period_id = ' . $course_tp );			
			}
		}
	}

    my ($r, $msg) = $self->user_link()->delete_children(-user => $u, -password => $p, -parent_id => $self->primary_key);
    
    return ($r, $msg);
}

sub delete_child_user {
    #
    # Delete a user from this user_group
    #

    my $self = shift;
    my ($u, $p, $username, $tp) = @_;

	my $link_course_student = $HSDB4::SQLLinkDefinition::LinkDefs{ $self->school_db() . '.link_course_student' };

	foreach my $course ( $self->courses ) {
		my $course_tp = $self->course_link()->get_row( $course->primary_key, $self->primary_key )->{'time_period_id'};
		if ( $self->sub_group() eq 'No' ) {
			$link_course_student->delete( '-parent_id' => $course->course_id, '-child_id' => $username, 'cond' => ' AND time_period_id = ' . $course_tp );
		}
	}

    my ($r, $msg) =  $self->user_link()->delete (-user => $u, -password => $p,
						 -parent_id => $self->primary_key,
						 -child_id => $username);
    if ($r) { $self->reset_user_list () }
    return ($r, $msg);
}

#
# >>>>>  Output Methods  <<<<<
#

sub flagtime {
    #
    # A DateTime representation of the flag time for this user group
    #

    my $self = shift;
    # Return the cached object if there is one
    return $self->{-flagtime} if $self->{-flagtime};
    # Otherwise, make a new one
    $self->{-flagtime} = HSDB4::DateTime->new;
    # And suck in the MySQL time if it's there
    my $flagtime = $self->field_value('schedule_flag_time');
    if ($flagtime =~ /[1-9]/) {
	$self->{-flagtime}->in_mysql_timestamp ($flagtime);
    }
    # And then return the object
    return $self->{-flagtime};
}

sub out_courses_condition {
    #
    # Return a condition of the form "course_id in ( ... )" for using in
    # other kinds of searches
    #

    my $self = shift;
    my $date = shift;
    my $blank_tp = HSDB45::TimePeriod->new(_school => $self->school());
    my @tpids = map { $_->primary_key } $blank_tp->time_periods_for_date($date);
    # Get the courses ID's
    my @course_ids = map { $_->primary_key } $self->courses(@tpids);
    return unless @course_ids;
    return sprintf ("course_id in (%s)", join (', ', @course_ids));
}

sub out_label {
    #
    # A label for the object: its title
    #

    my $self = shift;
    return $self->field_value('label');
}

sub out_abbrev {
    #
    # An abbreviation for the object: the first twenty characters of its
    # title
    #

    my $self = shift;
    return $self->out_label;
}

1;
__END__
