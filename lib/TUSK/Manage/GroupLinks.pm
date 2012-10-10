package TUSK::Manage::GroupLinks;

use HSDB4::Constants;
use TUSK::Functions;
use HSDB45::TimePeriod;
use HSDB45::Course;
use TUSK::Constants;

use strict;

my $pw = $TUSK::Constants::DatabaseUsers->{ContentManager}->{writepassword};
my $un = $TUSK::Constants::DatabaseUsers->{ContentManager}->{writeusername};

sub delete_process{
	my ($req, $data) = @_;

	my $link_course_student = $HSDB4::SQLLinkDefinition::LinkDefs{ HSDB4::Constants::get_school_db($req->{school}) . '.link_course_student'};
	my $users = [ $req->{usergroup}->child_users() ];

	foreach my $user (@$users) {
		$link_course_student->delete( '-parent_id' => $data->{course}->course_id, '-child_id' => $user->user_id, 'cond' => ' AND time_period_id = ' . $data->{timeperiod} );
	}

	## remove course link
	my ($rval ,$msg) = $data->{course}->delete_child_user_group_link($un, $pw, $req->{usergroup_id});
    
	return (1, "Group Link Deleted");
}

sub delete_pre_process{
    my ($req) = @_;
    my $data;

    $data->{course} = HSDB45::Course->new(_school=>$req->{school})->lookup_key($req->{course_id});
    $data->{timeperiod} = HSDB45::TimePeriod->new(_school=>$req->{school})->lookup_key($req->{timeperiod_id});

    return $data;
}

sub addedit_process{
	my ($req, $fdat) = @_;
	my ($rval, $msg, $successmsg, $warning_msgs);

	my $usergroup = HSDB45::UserGroup->new(_school=>$req->{school})->lookup_key($req->{usergroup_id});
	my $link_course_student = $HSDB4::SQLLinkDefinition::LinkDefs{ HSDB4::Constants::get_school_db($req->{school}) . '.link_course_student'};
	my $users = [ $usergroup->child_users() ];


	if ($fdat->{action} eq "edit"){
		my $course    = HSDB45::Course->new(_school=>$req->{school})->lookup_key($req->{course_id});

		foreach my $user (@$users) {
			$link_course_student->delete( '-parent_id' => $course->course_id, '-child_id' => $user->user_id, 'cond' => ' AND time_period_id = ' . $fdat->{time_period_id} );
		}
		
		$course->delete_child_user_group_link($un, $pw, $req->{usergroup_id});
		$successmsg = "Group Link updated successfully.";
	} else{
		$successmsg = "Group Link(s) added successfully.";
	}

	my @course_ids = split('\t', $fdat->{course_id});
	foreach my $course_id (@course_ids){
		my $course = HSDB45::Course->new(_school=>$req->{school})->lookup_key($course_id);

		my @groups = $course->user_group_link()->get_children($course->primary_key, "link.child_user_group_id = ". $req->{usergroup}->primary_key)->children;
    
		unless (scalar @groups){
			foreach my $user (@$users) {
				my $already_exists = $link_course_student->get_row( $course_id, $user->user_id, 'AND time_period_id = ' . $fdat->{time_period_id} . ' AND teaching_site_id = 0' );

				if ( defined($already_exists) ) {
					$warning_msgs .= '<b>' . $user->user_id . '</b> is already enrolled in <b>' . $course->title . '</b> for this time period.<br />';
				} else {
					$link_course_student->insert( '-parent_id' => $course_id, '-child_id' => $user->user_id, 'time_period_id' =>  $fdat->{time_period_id} );
				}
			}
			
			($rval, $msg) = $course->add_child_user_group_link($un, $pw, $req->{usergroup_id}, $fdat->{time_period_id});
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
    my ($req, $fdat) = @_;
    my $data;
    
    $data->{courses} = [ HSDB45::Course->new(_school => $req->{school})->lookup_conditions("associate_users = 'User Group' order by title") ];
    $data->{timeperiods} = [ HSDB45::TimePeriod->new(_school => $req->{school})->nonpast_time_periods ];
    
    if ($fdat->{page} eq "add"){
	$req->{image} = "CreateNewUserGroupLink";
	$data->{current_course_id} = "";
	$data->{current_time_period_id} = "";
    }else{	
	$req->{image} = "ModifyUserGroupLink";
	$data->{current_course_id} = $req->{course_id};
	$data->{current_time_period_id} = $req->{timeperiod_id};
    }
	
    return $data;
}

sub show_pre_process{
    my ($req) = @_;
    my $data;

    $data->{courses} = [ $req->{usergroup}->course_link()->get_parents($req->{usergroup}->primary_key, 'order by time_period_id, upper(title)')->parents ];

    foreach my $course (@{$data->{courses}}){
	my $time_period_id = $course->aux_info('time_period_id');
	if ($time_period_id){
	    unless ($data->{timeperiods}->{ $time_period_id }){
		my $tp = HSDB45::TimePeriod->new(_school=>$req->{school})->lookup_key($time_period_id);
		$data->{timeperiods}->{ $time_period_id } = $tp->field_value('period');
	    }
	}
	else{
	    $data->{timeperiods}->{$course->primary_key} = "None";
	}
    }

    return $data;
}
