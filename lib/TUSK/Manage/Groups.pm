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


package TUSK::Manage::Groups;

use HSDB4::Constants;
use TUSK::Functions;
use HSDB45::UserGroup;
use HSDB45::TimePeriod;
use TUSK::Constants;

use strict;

my $pw = $TUSK::Constants::DatabaseUsers->{ContentManager}->{writepassword};
my $un = $TUSK::Constants::DatabaseUsers->{ContentManager}->{writeusername};

sub delete_pre_process{
    my ($req) = @_;

    if ($req->{type} eq "course"){
	$req->{image} = "DeleteCourseGroup";
    }else{
	$req->{image} = "DeleteSchoolGroup";
    }
}

sub show_pre_process{
    my ($req, $timeperiod, $udat) = @_;
    my $data;
    
    if ($req->{type} eq "course"){
	$req->{image} = "ManageCourseGroups";
	$timeperiod = TUSK::Functions::course_time_periods_emb($req, $timeperiod, $udat);
	$data->{usergroups} = [ $req->{course}->sub_user_groups($timeperiod) ]; 
    }else{
	$req->{image} = "ManageSchoolGroups";
	$data->{usergroups} = [ HSDB45::UserGroup->new( _school => $req->{school} )->lookup_conditions("sub_group='No'", "order by upper(label)") ];
    }

    return $data;
}

sub addedit_pre_process{
    my ($req, $fdat, $udat) = @_;
    my ($data, $userid);

    $data->{userarray} = [];

     if ($req->{usergroup}){
	 $data->{users} = [ $req->{usergroup}->child_users ]; 
	 foreach my $user (@{$data->{users}}){
	     $userid = $user->primary_key;
	     push (@{$data->{userarray}}, {userid => $userid, name => $user->out_lastfirst_name});
	     $data->{seen}->{$userid} = 1;
	 }
     }


    if ($req->{type} eq "course"){
	$data->{timeperiod} = TUSK::Functions::get_time_period($req, $udat);

	if ($fdat->{page} eq "add"){
	    $req->{image} = "CreateNewCourseGroup";
	}else{
	    $req->{image} = "ModifyCourseGroup";
	}

	$data->{students} = [ $req->{course}->get_students($data->{timeperiod}) ];
	
	$data->{studentarray} = [];

	foreach my $student (@{$data->{students}}){
	    my $studentid = $student->primary_key;
	    next if ($data->{seen}->{$studentid});
	    push (@{$data->{studentarray}}, {userid => $studentid, name => $student->out_lastfirst_name});
	}
    }else{
	if ($fdat->{page} eq "add"){
	    $req->{image} = "CreateNewSchoolGroup";
	}else{
	    $req->{image} = "ModifySchoolGroup";
	}
    }
    
    return $data;
}

sub addedit_usergroup{
    my ($req, $fdat, $udat) = @_;
    my ($rval, $msg);
    
    if ($fdat->{action} eq "add"){
	$req->{usergroup} = HSDB45::UserGroup->new(_school=>$req->{school});
	if ($req->{type} eq "course"){
	    $req->{usergroup}->set_field_values(sub_group=>'Yes');
	}
    }

    $req->{usergroup}->set_field_values( label => $fdat->{label}, description => $fdat->{description});
    if ($req->{type} ne "course"){
	$fdat->{homepage_info}=~s/\t/,/g;
	$req->{usergroup}->set_field_values( homepage_info => $fdat->{homepage_info}, schedule_flag_time => $fdat->{schedule_flag_time});
    }

    ($rval, $msg) = $req->{usergroup}->save($un, $pw);
    return ($rval, $msg) if ($rval == 0);
   
    ## add link_course_user_group
    if ($req->{type} eq "course"){
	my $timeperiod = TUSK::Functions::get_time_period($req, $udat);

	if ($fdat->{action} eq "edit"){
	    ($rval, $msg) = $req->{course}->delete_child_user_group_link($un, $pw, $req->{usergroup}->primary_key);
	}
	($rval, $msg) = $req->{course}->add_child_user_group_link($un ,$pw, $req->{usergroup}->primary_key, $timeperiod);
    }		
    
    return ($rval, $msg) unless (defined($rval));
    
    ($rval, $msg) = $req->{usergroup}->delete_children($un, $pw);
    return ($rval, $msg) unless (defined($rval));    
    
    my @users = TUSK::Functions::get_data($fdat, "members");

    foreach my $user (@users){
	($rval, $msg) = $req->{usergroup}->add_child_user($un, $pw, $user->{pk});
	return ($rval, $msg) unless (defined($rval));
    }

    if ($fdat->{action} eq "add"){
	$fdat->{page}="edit";
	return (1, "User Group Successfully Added");
    }else{
	return (1, "User Group Successfully Updated");
    }        
}

sub delete{
    my ($req) = @_;
    my ($rval, $msg);
    
    ## remove course link
    if ($req->{type} eq "course"){
	($rval,$msg) = $req->{course}->delete_child_user_group_link($un, $pw, $req->{usergroup}->primary_key);
	return ($rval, $msg) if ($rval == 0);
    }
    
    ## remove user links
    my @users=$req->{usergroup}->child_users;
    
    foreach my $user (@users){
	($rval,$msg) = $req->{usergroup}->delete_child_user($un, $pw, $user->primary_key);
	return ($rval, $msg) if ($rval == 0);	
    }
    ## remove user group
    
    ($rval, $msg) = $req->{usergroup}->delete($un, $pw);
    return ($rval, $msg) if ($rval == 0);
    
    return (1, "User Group Deleted");
    
}

1;
