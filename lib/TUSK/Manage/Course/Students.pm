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


package TUSK::Manage::Course::Students;

use HSDB4::Constants;
use HSDB4::SQLRow::User;
use HSDB45::TeachingSite;
use TUSK::Session;
use TUSK::Functions;
use TUSK::Constants;
use TUSK::FormBuilder::SubjectAssessor;

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
    my ($req, $course_id, $school, $timeperiod) = @_;

    my $data;
	my $course = HSDB45::Course->new( _school => $school )->lookup_key( $course_id );
    
    #$timeperiod = TUSK::Functions::course_time_periods($req, $timeperiod, $udat);
    $data->{students} = [ $course->get_students($timeperiod) ];
    my $sites =  [ $course->child_teaching_sites() ];

    foreach my $site (@$sites){
		my $site_id = $site->primary_key();
		$data->{sites}->{$site_id} = $site;
    }

    return $data;
}

sub teachingsites_pre_process{
    my ($req, $course_id, $school, $timeperiod) = @_;

    my $data;
    my $course = HSDB45::Course->new( _school => $school )->lookup_key( $course_id );
    # $timeperiod = TUSK::Functions::course_time_periods($req, $timeperiod);

    $data->{students} = [ $course->get_students($timeperiod) ];

    my $sites =  [ $course->child_teaching_sites() ];

    foreach my $site (@$sites){
		my $site_id = $site->primary_key();
		$data->{sites}->{$site_id} = $site;
    }

    return $data;
}

sub addedit_pre_process{
    my ($req, $course_id, $school, $timeperiod, $user) = @_;

    my $data;
	my $course = HSDB45::Course->new( _school => $school )->lookup_key( $course_id );

    $data->{showflag} = 0;

	# get the teaching_sites
	$data->{sites} =  [ $course->child_teaching_sites() ];
	
	# check to see if we are adding or editing
	my @students = $course->child_students("child_user_id='" . $user . "' AND time_period_id = '" . $timeperiod . "'"); 

	if ($students[0]){
	    $data->{cursite} = $students[0]->aux_info('teaching_site_id');
	    $data->{elective} = $students[0]->aux_info('elective');
	}
	
	$data->{showflag} = 1;
    
    if ($user){
		$data->{action}="edit";
		my $userobj = HSDB4::SQLRow::User->new->lookup_key($user);
		$data->{userarray} = [ {userid => $user, name => $userobj->out_lastfirst_name} ];
		$data->{actionref} = {usage => 'No'};
    }else{
		$data->{action}="add";
		$data->{userarray} = [];
		$data->{actionref} = {usage => 'Yes', length => 100, functions => [ {func=>'remove', label=>'Delete'} ]};
    }

    $data->{usergroups} = [ get_usergroupstp($req, $course_id, $school,  $timeperiod) ];

    return $data;

}

sub get_usergroupstp{
	my ($req,$course_id, $school,  $tp) = @_;
	
	my $course = HSDB45::Course->new( _school => $school )->lookup_key( $course_id );

    return $course->sub_user_groups($tp);
}

sub get_usergroups{
    my ($req, $udat) = @_;

    return $req->{course}->sub_user_groups($udat->{timeperiod});
}

sub get_students{
    my ($req, $course_id, $school,  $timeperiod) = @_;
	my $course = HSDB45::Course->new( _school => $school )->lookup_key( $course_id );

    return $course->get_students($timeperiod);
}

sub delete{
    my ($req, $tp, $course_id, $school,  $fdat) = @_;
    my ($rval, $msg);
    
	my $course = HSDB45::Course->new( _school => $school )->lookup_key( $course_id );

    ## delete the course student relationship
    ($rval, $msg) = $course->delete_child_student($un, $pw, $fdat->{user}, $tp);
    
    return ($rval, $msg) if ($rval == 0);

    ## delete the sub user group relationships
    my @usergroups = get_usergroupstp($req,$course_id, $school, $tp);
    foreach my $usergroup (@usergroups){
		$usergroup->delete_child_user($un, $pw, $fdat->{user});
    }
    
    return (1, "Student Deleted");
}

sub addedit_users{
    my ($req, $course_id, $school, $timeperiod,$fdat) = @_;
    my ($rval, $msg);
    
	
    if ($fdat->{action} eq 'add'){
		($rval, $msg) = TUSK::Manage::Course::Students::add_users($req, $course_id, $school, $timeperiod,  $fdat);
    }else{
		($rval, $msg) = TUSK::Manage::Course::Students::edit_user($req, $course_id, $school, $timeperiod, $fdat);
    }
    
    return ($rval, $msg);
}

sub modify_teachingsites {
    my ($req, $course_id, $school, $timeperiod, $fdat) = @_;
    my ($rval, $msg);

	# my $timeperiod = TUSK::Functions::get_time_period($req, $udat);

	my $course = HSDB45::Course->new( _school => $school )->lookup_key( $course_id );
	my @students = get_students($req, $course_id, $school, $timeperiod);

	foreach my $student (@students){
		($rval, $msg) = $course->update_child_student($un, $pw, $student->user_id, $timeperiod, $fdat->{$student->user_id});
		last if ($rval == 0);
	}

	return($rval, $msg) if ($rval == 0);

    return (1, "Teaching Sites Updated");
}

sub edit_user{
    my ($req, $course_id, $school, $timeperiod, $fdat) = @_;
    my ($rval, $msg);

	my $course = HSDB45::Course->new( _school => $school )->lookup_key( $course_id );
    my @users = TUSK::Functions::get_users($fdat);
    
    my $user = $users[0];
    return (0, "User not found.") unless $user;

	my @students = get_students($req, $course_id, $school,  $timeperiod);

	($rval, $msg) = $course->update_child_student($un, $pw, $user->{pk}, $timeperiod, $fdat->{teaching_site}, $fdat->{elective});
	return($rval, $msg) if ($rval == 0);

    process_groups($user->{pk}, $course_id, $school, $timeperiod, $fdat, $req);

    return (1, "Student Updated");
    
}

sub add_users{
    my ($req, $course_id, $school, $timeperiod, $fdat) = @_;
    my ($rval, $msg, %seen, @overlap);

    ##my $timeperiod = TUSK::Functions::get_time_period($req, $udat);
	my $course = HSDB45::Course->new( _school => $school )->lookup_key( $course_id );
    my @users = TUSK::Functions::get_users($fdat);
    my @students = get_students($req, $course_id, $school,  $timeperiod);

    foreach my $student (@students){
		$seen{$student->primary_key} = 1;
    }

    foreach my $user (@users){
	unless ($seen{$user->{pk}}){
	    ($rval, $msg) = $course->add_child_student($un, $pw, $user->{pk}, $timeperiod, $fdat->{teaching_site}, $fdat->{elective});
	    return($rval, $msg) if ($rval == 0);
	    
	    ($rval, $msg) = process_groups($user->{pk}, $course_id, $school, $timeperiod, $fdat, $req);
	    return($rval, $msg) if ($rval == 0);
	}else{
	    push (@overlap, $user->{pk});
	}
    }

    if (@overlap){
		return (2, "The following users were already added: " . join(", ", @overlap));
    }else{
		return (1, "Student(s) Added");
    }
}
	
sub process_groups{
    my ($user, $course_id, $school, $timeperiod, $fdat, $req, $udat) = @_;
    my ($rval, $msg, $pk);
    my @usergroups = get_usergroupstp($req, $course_id, $school, $timeperiod);

    # delete and/or add the usergroups	
    foreach my $usergroup (@usergroups){
		$pk=$usergroup->primary_key;

		$fdat->{"newgroup-".$pk} = 0 unless $fdat->{"newgroup-".$pk};

		if ($fdat->{"newgroup-".$pk} ne $fdat->{"oldgroup-".$pk}){
			if ($fdat->{"newgroup-".$pk}){
				$usergroup->delete_child_user($un, $pw, $user); # first delete just to make sure user is not already in the group
				($rval, $msg) = $usergroup->add_child_user($un,$pw,$user);
				return($rval, $msg) if ($rval == 0);
			}else{
				$usergroup->delete_child_user($un,$pw, $user);
			}
		}
	}

    return 1;
}

sub get_assessor {
	my ($req, $form_id, $tp_id) = @_;
	my $links = TUSK::FormBuilder::SubjectAssessor->lookup("form_id = $form_id AND time_period_id = $tp_id");
	return { map { $_->getSubjectID() . '__' . $_->getAssessorID() => [ $_->getPrimaryKeyID(),  $_->getStatus() ] } @$links };
}

sub assign_assessor {
	my ($req, $form_id, $tp_id, $checked_student_assessor, $user_id, $existing) = @_;
	my @student_assessors = ();
	
	if (ref $checked_student_assessor eq 'ARRAY') {
		@student_assessors = @$checked_student_assessor;
	} else {
		@student_assessors = ($checked_student_assessor);
	}

	foreach my $sa_id (@student_assessors) {
		## if there, remove from the list-to-remove, otherwise add new one
		next unless ($sa_id);
		my ($student_id, $assessor_id, $ssid) = split(/__/, $sa_id);
		if ($existing->{$student_id . '__' .  $assessor_id}) {
			delete $existing->{$student_id . '__' . $assessor_id};  
		} else {
			my $link = TUSK::FormBuilder::SubjectAssessor->new();
			$link->setFieldValues({  
									 form_id => $form_id,
									 time_period_id => $tp_id,
									 subject_id => $student_id,
									 assessor_id => $assessor_id });
			$link->save({ user => $user_id });
		}
	}

	## remove the ones that are not sent along
	if (keys %$existing) {
		if (my @saids = map { $_->[0] } values %$existing) {
			my $links = TUSK::FormBuilder::SubjectAssessor->lookup('subject_assessor_id in (' . join(',', @saids) . ')');
			foreach (@$links) {
				$_->delete({ user => $user_id });
			}
		}
	}
}

1;
