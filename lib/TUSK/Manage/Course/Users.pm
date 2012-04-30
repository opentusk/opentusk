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


package TUSK::Manage::Course::Users;

use HSDB4::Constants;
use HSDB4::SQLRow::User;
use TUSK::Functions;
use TUSK::Constants;
use Data::Dumper;

use strict;

my $pw = $TUSK::Constants::DatabaseUsers->{ContentManager}->{writepassword};
my $un = $TUSK::Constants::DatabaseUsers->{ContentManager}->{writeusername};

sub delete_pre_process{
    my ($user) = @_;

    my $data;

    $data->{user} = HSDB4::SQLRow::User->new->lookup_key($user); 

    return $data;
}

sub show_pre_process{
    my ($req, $timeperiod, $course_id, $school) = @_;

    my $data;
	my $course = HSDB45::Course->new( _school => $school )->lookup_key( $course_id );

    # $data->{users} = [ get_users($req) ];
	#$req->{course}->child_users;

	@{$data->{users}} = $course->child_users;
    $data->{usercount} = scalar(@{$data->{users}});

	$data->{subusercount} = 0;
	if ( $course->type() eq 'integrated course' ) {
		foreach my $subcourse ( @{$course->get_subcourses()} ) {
			my @users;
			foreach my $user ($subcourse->child_users) {
				push @users, $user;
				$data->{subusercount}++;
			}
			$data->{subusers}->{$subcourse->out_title} = \@users;
		}
	}

    return $data;
}

sub addedit_pre_process{
    my ($req, $course_id, $school, $timeperiod, $user) = @_;
    my $data;
	my $course = HSDB45::Course->new( _school => $school )->lookup_key( $course_id );

    $data->{usergroups} =  [ $course->sub_user_groups($timeperiod) ]  ; # get_usergroups($req, $timeperiod) ];
    $data->{usergroupcount} = scalar(@{$data->{usergroups}});
    $data->{shownone} = 0;
    
    $data->{teaching_sites} = [ $course->child_teaching_sites() ];

    if ($user){
	# get the roles
		my @usersroles = $course->child_users("child_user_id='" . $user . "'"); # check the roles to the first user in the array
		if (@usersroles){
			$data->{roles} = { map { ($_, 1) } split (/\s*,\s*/, $usersroles[0]->aux_info('roles')) };
			$data->{teaching_site_id} = $usersroles[0]->aux_info('teaching_site_id');
		}

		if (!$data->{roles}->{Manager} and !$data->{roles}->{Director} and !$data->{roles}->{Editor} and !$data->{roles}->{Author} and !$data->{roles}->{'Student Editor'} and !$data->{roles}->{'Student Manager'} and !$data->{roles}->{'Site Director'}){
			$data->{shownone} = 1;
		}
		$data->{action} = "edit";
		##$req->{image} = "ModifyCourseEditor";
		my $userobj = HSDB4::SQLRow::User->new->lookup_key($user);
		$data->{userarray} = [ {userid => $user, name => $userobj->out_lastfirst_name} ];
		$data->{actionref} = {usage => 'No'};
    }else{
		$data->{action} = "add";
		##$req->{image} = "CreateNewCourseEditors";
		$data->{userarray} = [];
		$data->{actionref} = {usage => 'Yes', length => 100, functions => [ {func=>'remove', label=>'Delete'} ]};
		$data->{shownone} = 1;
		$data->{teaching_site_id} = 0;
    }
    
    return $data;
}


sub change_order{
    my ($req,  $order,$course_id, $school, $users) = @_;
    my ($rval, $msg);
    
    my ($index, $insert)=split('-', $order);
    my $course = HSDB45::Course->new( _school => $school )->lookup_key( $course_id );
    splice(@$users, ($insert-1), 0,splice(@$users,($index-1),1));
    
    my $link = $course->user_link;
    
    for( my $i=0; $i < scalar(@$users); $i++){
	($rval, $msg) = $link->update(-user => $un,
				      -password=> $pw,
				      -parent_id => $course_id,
				      -child_id => @$users[$i]->primary_key,
				      sort_order => 10*($i+1),
				      );
	return($rval, $msg) unless defined($rval);
    }

    return(1, "Order Successfully Changed")

}

sub addedit_users{
    my ($req, $course_id, $school, $timeperiod, $fdat) = @_;
    my ($rval, $msg, $roles);
 
	$roles=$fdat->{roles};
    #$roles = $fdat->{roles} . "\t" . $fdat->{labels};

	my $labels = $fdat->{labels};
	if (ref($labels) eq 'ARRAY'){
		foreach my $label (@$labels) {
			$roles =$roles . "," . $label;
		}
    } else {
		$roles = $roles . "," . $labels;
	}

    $roles =~s/\t/,/g;
    $roles =~s/^,//;
    $roles =~s/,$//;
    
    my @users = TUSK::Functions::get_users($fdat);
    
    if ($fdat->{action} eq "edit"){
		($rval, $msg) = edit_user($req,$course_id, $school, $timeperiod,  $fdat, $users[0], $roles);
		return ($rval, $msg) if ($rval == 0);
    }else{
		($rval, $msg) = add_users($req, $course_id, $school, $timeperiod, $fdat, $roles, @users);
	return ($rval, $msg) if ($rval == 0);
    }

    return (1, $msg);
}

sub update_usergroups{
    my ($req, $course_id, $school, $timeperiod, $fdat, $user) = @_;

	my $course = HSDB45::Course->new( _school => $school )->lookup_key( $course_id );
    my @usergroups = $course->sub_user_groups($timeperiod); # get_usergroups($req, $timeperiod);

    # delete and/or add the usergroups	
    foreach my $usergroup (@usergroups){
		my $pk = $usergroup->primary_key;
		$fdat->{"newgroup-".$pk} = 0 unless $fdat->{"newgroup-".$pk};
	
		if ($fdat->{"newgroup-" . $pk} ne $fdat->{"oldgroup-" . $pk}){
			if ($fdat->{"newgroup-".$pk}){
				$usergroup->delete_child_user($un, $pw, $user->{pk}); # first delete just to make sure user is not already in the group 
				$usergroup->add_child_user($un, $pw, $user->{pk});
			}else{
				$usergroup->delete_child_user($un, $pw, $user->{pk});
			}
		}
    }
    
    return (1);
}

sub edit_user{
    my ($req, $course_id, $school, $timeperiod,  $fdat, $user, $roles) = @_;
    my ($rval, $msg);

	my $course = HSDB45::Course->new( _school => $school )->lookup_key( $course_id );
    warn "user is ".$user->{pk};
	warn "crs is ".$course->primary_key,
    #Set a default ID of 0 if we did not get one (This was broken on a new linux server)
    $fdat->{teaching_site_id} ||= 0;
    ($rval, $msg) = $course->user_link()->update(
							-user => $un,
							-password => $pw,
							-parent_id => $course->primary_key,
							-child_id => $user->{pk},
							roles => $roles,
							teaching_site_id => $fdat->{teaching_site_id}
							);

    return ($rval, $msg) if ($rval == 0);

    ($rval, $msg) = update_usergroups($req,$course_id, $school, $timeperiod, $fdat, $user);
    return ($rval, $msg) if ($rval == 0);

    return (1, "User Updated.");
}

sub add_users{
    my ($req, $course_id, $school, $timeperiod, $fdat, $roles, @users) = @_;
    my ($rval, $msg);

    my $course = HSDB45::Course->new( _school => $school )->lookup_key( $course_id );

    foreach my $user (@users){
	 ($rval, $msg) = $course->user_link()->delete(
					     -user => $un,
					     -password => $pw,
					     -parent_id => $course->primary_key,
					     -child_id => $user->{pk});

	#Set a default ID of 0 if we did not get one (This was broken on a new linux server)
	$fdat->{teaching_site_id} ||= 0;
	($rval, $msg) = $course->user_link()->insert(
				      -user => $un,
				      -password => $pw,
				      -parent_id => $course->primary_key,
				      -child_id => $user->{pk},
				      roles => $roles,
				      teaching_site_id => $fdat->{teaching_site_id}
				      );
	
	($rval, $msg) = update_usergroups($req,$course_id, $school,  $timeperiod, $fdat, $user);
	return ($rval, $msg . "2") if ($rval == 0);
	
    }
    return (1, "User(s) Added.");
}

sub delete{
    my ($req, $user, $course_id, $school, $time_period) = @_;
    my ($rval, $msg);

	my $course = HSDB45::Course->new( _school => $school )->lookup_key( $course_id );

    ## delete the course user relationship
    ($rval, $msg) =  $course->user_link()->delete(
				       -user => $un,
				       -password => $pw,
				       -parent_id => $course->primary_key,
				       -child_id => $user,
				       );
    return ($rval, $msg) if ($msg);
    
    ## delete the sub user group relationships
  
    my @usergroups = $course->sub_user_groups($time_period); #get_usergroups($req, $time_period);
    foreach my $usergroup (@usergroups){
		$usergroup->delete_child_user($un, $pw, $user);
    }
    
    return(1, "User Deleted");
}

sub get_usergroups{
    my ($req, $timeperiod) = @_;

    return $req->{course}->sub_user_groups($timeperiod);
}

sub get_users{
    my ($req) = @_;
    return $req->{course}->child_users;
}

1;
