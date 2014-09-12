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


package TUSK::Manage::Email;

use HSDB4::Constants;
use HSDB4::SQLRow::User;
use TUSK::Functions;

use strict;

sub email_pre_process{
    my ($req, $timeperiod, $udat) = @_;
    
    my $data;
    $timeperiod = TUSK::Functions::course_time_periods($req, $timeperiod, $udat);
    
    $data->{usergroups} = [ $req->{course}->sub_user_groups($timeperiod) ];
    
    return $data;
}

sub email_preview_process {
    my ($req, $fdat) = @_;
    my $data;
    if ($fdat->{to}){
	$data->{usergroup} = HSDB45::UserGroup->new(_school => $req->{school})->lookup_key($fdat->{to});
    }

    return ($data);
}


###### school name is needed if the 'to' parameters is user_group_id
###### course, timeperiod needed if sending a class of student for a given time period
sub email_process {
    my ($user, $fdat, $school, $course, $timeperiod_id) = @_;

    my $data;

    my $fullname = $user->field_value('firstname') . " " . $user->field_value('lastname');
    $data->{email_from} = $fullname . "<" . $user->field_value('email') . ">";

    if ($fdat->{to}){
		if ($fdat->{email_list}) {  ### individual email recipients
			my @users = (ref($fdat->{to}) eq 'ARRAY') ? map { HSDB4::SQLRow::User->new()->lookup_key($_) } @{$fdat->{to}} : HSDB4::SQLRow::User->new()->lookup_key($fdat->{to});
			foreach my $usr (@users) {
				$usr->send_email_from($data->{email_from});
				my ($success, $msg) = $usr->send_email($fdat->{subject}, $fdat->{body});
				$data->{users}{$usr} = [ $success, $msg ];		
			}
		} else {    ### email by user groups
			if (ref $fdat->{to} eq 'ARRAY') {  
				foreach my $to (@{$fdat->{to}}) {
					$data->{usergroup} = HSDB45::UserGroup->new(_school => $school)->lookup_key($to);
					$data->{usergroup}->email_child_users($fdat->{subject}, $data->{email_from}, $fdat->{body});
				}
			} else {
				$data->{usergroup} = HSDB45::UserGroup->new(_school => $school)->lookup_key($fdat->{to});
				$data->{usergroup}->email_child_users($fdat->{subject}, $data->{email_from}, $fdat->{body});
			}
		}
    } else { ### email students in a course for a given time period
		if (ref $course eq 'HSDB45::Course' && $timeperiod_id) {
			$course->email_students($fdat->{subject}, $data->{email_from}, $timeperiod_id, $fdat->{body});
		}
    }

    if ($fdat->{sendself}) {
		$user->send_email_from($data->{email_from});
		$user->send_email($fdat->{subject}, $fdat->{body});
    }

    if ($fdat->{senddirectors} && ref $course eq 'HSDB45::Course') {
		my $course_users = $course->users($timeperiod_id);
		foreach my $course_user (@$course_users) {
			my $course_user_id = $course_user->getPrimaryKeyID();
			next if ($fdat->{sendself} && ($course_user_id eq $user->primary_key()));
			if ($course_user->hasRole(['director', 'manager'])) {
				my $user = HSDB4::SQLRow::User->new()->lookup_key($course_user_id);
				$user->send_email_from($data->{email_from});
				$user->send_email($fdat->{subject}, $fdat->{body});
			}
		}
    }

    return $data;
}

1;
