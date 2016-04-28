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


package TUSK::Manage::GroupLinks;

use HSDB4::Constants;
use TUSK::Functions;
use HSDB45::TimePeriod;
use HSDB45::Course;
use TUSK::Constants;

use strict;

my $pw = $TUSK::Constants::DatabaseUsers{ContentManager}->{writepassword};
my $un = $TUSK::Constants::DatabaseUsers{ContentManager}->{writeusername};

sub delete_process{
	my ($school,$usergroup_id, $data) = @_;

	my $usergroup = HSDB45::UserGroup->new(_school=>$school)->lookup_key($usergroup_id);
	my $link_course_student = $HSDB4::SQLLinkDefinition::LinkDefs{ HSDB4::Constants::get_school_db($school) . '.link_course_student'};
	my $users = [ $usergroup->child_users() ];

	foreach my $user (@$users) {
		$link_course_student->delete( '-parent_id' => $data->{course}->course_id, '-child_id' => $user->user_id, 'cond' => ' AND time_period_id = ' . $data->{timeperiod} );
	}

	## remove course link
	my ($rval ,$msg) = $data->{course}->delete_child_user_group_link($un, $pw, $usergroup_id);

	return (1, "Group Link Deleted");
}

sub delete_pre_process{
    my ($school,$course_id,$timeperiod_id) = @_;
    my $data;

    $data->{course} = HSDB45::Course->new(_school=>$school)->lookup_key($course_id);
    $data->{timeperiod} = HSDB45::TimePeriod->new(_school=>$school)->lookup_key($timeperiod_id);

    return $data;
}

sub addedit_process{
	my ($school, $usergroup_id,$course_id, $fdat) = @_;
	my ($rval, $msg, $successmsg, $warning_msgs);

	my $usergroup = HSDB45::UserGroup->new(_school=>$school)->lookup_key($usergroup_id);
	my $link_course_student = $HSDB4::SQLLinkDefinition::LinkDefs{ HSDB4::Constants::get_school_db($school) . '.link_course_student'};
	my $users = [ $usergroup->child_users() ];

	if ($fdat->{action} eq "edit"){
		my $course    = HSDB45::Course->new(_school=>$school)->lookup_key($course_id);

		foreach my $user (@$users) {
			$link_course_student->delete( '-parent_id' => $course->course_id, '-child_id' => $user->user_id, 'cond' => ' AND time_period_id = ' . $fdat->{time_period_id} );
		}

		$course->delete_child_user_group_link($un, $pw, $usergroup_id);
		$successmsg = "Group Link updated successfully.";
	} else{
		$successmsg = "Group Link(s) added successfully.";
	}

	my @course_ids = (ref $fdat->{course_id}) ? @{$fdat->{course_id}} : ($fdat->{course_id});
	foreach my $course_id (@course_ids){
		my $course = HSDB45::Course->new(_school=>$school)->lookup_key($course_id);

		my @groups = $course->user_group_link()->get_children($course->primary_key, "link.child_user_group_id = ". $usergroup->primary_key)->children;

		unless (scalar @groups){
			foreach my $user (@$users) {
				my $already_exists = $link_course_student->get_row( $course_id, $user->user_id, 'AND time_period_id = ' . $fdat->{time_period_id} . ' AND teaching_site_id = 0' );

				if ( defined($already_exists) ) {
					$warning_msgs .= '<b>' . $user->user_id . '</b> is already enrolled in <b>' . $course->title . '</b> for this time period.<br />';
				} else {
					$link_course_student->insert( '-parent_id' => $course_id, '-child_id' => $user->user_id, 'time_period_id' =>  $fdat->{time_period_id} );
				}
			}

			($rval, $msg) = $course->add_child_user_group_link($un, $pw, $usergroup_id, $fdat->{time_period_id});
			return ($rval, $msg) if ($rval < 1);
		}else{
			$successmsg = "Group Link already added.  Use the modify link to change time period.";
		}
	}

	if ( $warning_msgs ) {
		return (2, $warning_msgs . "<br />" . $successmsg );
	} else {
		return (1, $successmsg);
	}
}

sub addedit_pre_process{
    my ($school,$course_id,$timeperiod_id, $fdat) = @_;
    my $data;

    $data->{courses} = [ HSDB45::Course->new(_school => $school)->lookup_conditions("associate_users = 'User Group' order by title") ];
    $data->{timeperiods} = [ HSDB45::TimePeriod->new(_school => $school)->nonpast_time_periods ];

    if ($fdat->{page} eq "add"){
		##$req->{image} = "CreateNewUserGroupLink";
		$data->{current_course_id} = "";
		$data->{current_time_period_id} = "";
    }else{
		##$req->{image} = "ModifyUserGroupLink";
		$data->{current_course_id} = $course_id;
		$data->{current_time_period_id} = $timeperiod_id;
    }

    return $data;
}

sub show_pre_process{
	my ($usergroup_id,$school) = @_;

    my $data;

	my $usergroup = HSDB45::UserGroup->new(_school=>$school)->lookup_key($usergroup_id);

	$data->{courses} = [ $usergroup->course_link()->get_parents($usergroup->primary_key, 'order by time_period_id, upper(title)')->parents ];

    foreach my $course (@{$data->{courses}}){
	my $time_period_id = $course->aux_info('time_period_id');
	if ($time_period_id){
	    unless ($data->{timeperiods}->{ $time_period_id }){
		my $tp = HSDB45::TimePeriod->new(_school=>$school)->lookup_key($time_period_id);
		$data->{timeperiods}->{ $time_period_id } = $tp->field_value('period');
	    }
	}
	else{
	    $data->{timeperiods}->{$course->primary_key} = "None";
	}
    }

    return $data;
}

1;
