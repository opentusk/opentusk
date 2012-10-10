package TUSK::Manage::Course::Students;

use HSDB4::Constants;
use HSDB4::SQLRow::User;
use HSDB45::TeachingSite;
use TUSK::Session;
use TUSK::Functions;
use TUSK::Constants;

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
	}
	
	$data->{showflag} = 1;
    
    if ($user){
#		$req->{image} = "ModifyCourseStudent";
		$data->{action}="edit";
		my $userobj = HSDB4::SQLRow::User->new->lookup_key($user);
		$data->{userarray} = [ {userid => $user, name => $userobj->out_lastfirst_name} ];
		$data->{actionref} = {usage => 'No'};
    }else{
#		$req->{image} = "CreateNewCourseStudents";
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

	## my $timeperiod = TUSK::Functions::get_time_period($req, $udat);

	my @students = get_students($req, $course_id, $school,  $timeperiod);

	foreach my $student (@students){
	    if (
		$student->primary_key() eq $user->{pk} 
		&& 
		$student->aux_info('teaching_site_id') == $fdat->{teaching_site}
		&&
		$student->aux_info('time_period_id') == $timeperiod
		){
		return("0", "Could not modify teaching site as this student is already associated with the teaching site you selected.");
	    }
	}
	
	($rval, $msg) = $course->update_child_student($un, $pw, $user->{pk}, $timeperiod, $fdat->{teaching_site});
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
	    ($rval, $msg) = $course->add_child_student($un, $pw, $user->{pk}, $timeperiod, $fdat->{teaching_site});
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

1;
