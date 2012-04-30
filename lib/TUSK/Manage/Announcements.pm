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


package TUSK::Manage::Announcements;

use HSDB4::Constants;
use HSDB45::Announcement;
use HSDB45::UserGroup;
use TUSK::Functions;
use TUSK::Constants;

use strict;

my $pw = $TUSK::Constants::DatabaseUsers->{ContentManager}->{writepassword};
my $un = $TUSK::Constants::DatabaseUsers->{ContentManager}->{writeusername};

sub get_usergroups{
    my ($req, $udat) = @_;
    my $usergroups = [];

    if ($req->{type} eq "course"){
	my $timeperiod = TUSK::Functions::get_time_period($req, $udat);
	$usergroups = [ $req->{course}->sub_user_groups($timeperiod) ];
    }elsif ($req->{type} eq "school"){
	$usergroups = [ HSDB45::UserGroup->new( _school => $req->{school} )->lookup_conditions("sub_group='No'","order by upper(label)") ];
    }

    return $usergroups;
}


sub addedit_pre_process{
    my ($req, $page, $udat) = @_;
    my $data;

    if ($page eq "add"){
	$req->{image}="CreateNewAnnouncement";
    }else{
	$req->{image}="ModifyAnnouncement";
    }
    
    $data->{usergroups} = get_usergroups($req, $udat);

    return $data;
}

sub show_pre_process{
    my ($req, $usergroup_id, $timeperiod, $udat) = @_;
    my ($data, $maingroup);

    $data->{usergroup_id} = $usergroup_id;

	my $cur_ind = 0;

	if ($req->{type} eq "course"){ 
		$timeperiod = TUSK::Functions::course_time_periods_emb($req, $timeperiod, $udat);	
		$data->{usergroup_id} = 0 unless ($data->{usergroup_id});

		$cur_ind = (exists $req->{extratext})? scalar @{$req->{extratext}} : 0;

		$req->{extratext}->[$cur_ind]->{name} = "Course Group";
		$req->{extratext}->[$cur_ind]->{text} .= "<select name=\"ug_id\" onchange=\"document.generic.submit();\" class=\"navsm\">";
		$req->{extratext}->[$cur_ind]->{text} .= "<option value=\"0\" class=\"navsm\">Entire Course\n";
	}elsif ($req->{type} eq "school"){
		$data->{usergroup_id} = $TUSK::Constants::SchoolWideUserGroup->{lc($req->{school})} unless ($data->{usergroup_id});
		$req->{extratext}->[$cur_ind]->{name} = "Group";
		$req->{extratext}->[$cur_ind]->{text} = "<select name=\"ug_id\" onchange=\"document.generic.submit();\" class=\"navsm\">";
		$req->{extratext}->[$cur_ind]->{text} .= "<option value=\"".$TUSK::Constants::SchoolWideUserGroup->{lc($req->{school})}."\" class=\"navsm\">Entire School\n";
	}

    $data->{usergroups} = get_usergroups($req, $udat);
    
    foreach my $group (@{$data->{usergroups}}){
	if ($group->primary_key == $data->{usergroup_id} or (!$data->{usergroup_id} and $group->primary_key == $TUSK::Constants::SchoolWideUserGroup->{lc($group->school)})){
	    $maingroup = $group;
	}
	unless ($group->primary_key == $TUSK::Constants::SchoolWideUserGroup->{lc($group->school)}) {
	    $maingroup = $group if ($group->primary_key == $data->{usergroup_id});
	    $req->{extratext}->[$cur_ind]->{text} .= "<option class=\"navsm\" value=\"" . $group->primary_key . "\" ";
	    $req->{extratext}->[$cur_ind]->{text} .= "selected" if ($group->primary_key == $data->{usergroup_id});
	    $req->{extratext}->[$cur_ind]->{text} .= ">" . $group->field_value('label') . "\n";
	}
    }
    $req->{extratext}->[$cur_ind]->{text} .= "</select>";
    
    if ($data->{usergroup_id} == 0){
	$data->{announcements} = [ $req->{course}->all_announcements ]
      if ( defined $req->{course} );
    }else{
	$data->{announcements} = [ $maingroup->all_announcements ]
      if ( defined $maingroup );
    }

    return $data;
}

sub addedit_process{
    my ($req, $fdat, $udat) = @_;
    my ($rval, $msg, $ug);
    my $flag = 0;

    my $text = $fdat->{body}; 
    my $expire = $fdat->{expire}; 
    my $start = $fdat->{start};
    
    foreach ($text, $expire, $start){
	$_ =~ s/^\s*//;
	$_ =~ s/\s*$//;
    }

    if ($fdat->{action} eq "add"){
	$req->{announcement} = HSDB45::Announcement->new(_school => $req->{school});
    }
				      
    $req->{announcement}->set_field_values(
					   expire_date => $expire,
					   start_date => $start,
					   username => $req->{user}->primary_key,
					   body => $text,
					   );
    
    ($rval, $msg) = $req->{announcement}->save($un, $pw);
    return ($rval, $msg) if ($rval == 0);

    if ($fdat->{action} eq "edit" and $fdat->{usergroup_id} != $req->{usergroup_id}){
	my $temp=$req->{usergroup_id};
	$req->{selfpath}=~s/\/$temp$//;
	$req->{selfpath}.="/".$fdat->{usergroup_id};
	$flag=1;
	if ($req->{usergroup_id}){
	    $ug = HSDB45::UserGroup->new(_school => $req->{school})->lookup_key($req->{usergroup_id});
	    ($rval, $msg) = $ug->remove_announcement($un, $pw, $req->{announcement_id});
	    return ($rval, $msg) if ($rval == 0);
	}else{
	    ($rval, $msg) = $req->{course}->remove_announcement($un, $pw, $req->{announcement_id});
	    return ($rval, $msg) if ($rval == 0);
	}
    }


    my $email_from = $req->{user}->field_value('firstname') . " " . $req->{user}->field_value('lastname') . "<" . $req->{user}->field_value('email') . ">";

    if ($fdat->{usergroup_id}){
	$ug = HSDB45::UserGroup->new(_school => $req->{school})->lookup_key($fdat->{usergroup_id});
	($rval, $msg) = $ug->add_announcement($un, $pw, $req->{announcement}->primary_key) if ($flag == 1 or $fdat->{action} eq "add");
	return ($rval, $msg) if ($rval == 0);

	($rval, $msg) = $ug->email_child_users("Announcement for '".$ug->field_value('label')."'",$email_from,
			       "<html><body>Announcement: $text<br>\nStart Date: $start<br>\nEnd Date: $expire<br>\n</body></html>") if ($fdat->{email});
	return ($rval, $msg) if ($msg);
    }else{
	($rval, $msg) = $req->{course}->add_announcement($un, $pw, 
					 $req->{announcement}->primary_key) if ($flag == 1 or $fdat->{action} eq "add");
	return ($rval, $msg) if ($rval == 0);
	my $timeperiod = TUSK::Functions::get_time_period($req, $udat);
	($rval, $msg) = $req->{course}->email_child_users("Announcement for '".$req->{course}->field_value('title')."'",$email_from,$timeperiod,
					  "<html><body>Announcement: $text<br>\nStart Date: $start<br>\nEnd Date: $expire<br>\n</body></html>") if ($fdat->{email});
	return ($rval, $msg) if ($msg);
    }

    return (1, $msg);
}

sub delete_process{
    my ($req) = @_;
    my ($rval, $msg);

    ## remove the link
    if ($req->{usergroup_id}){
	my $ug = HSDB45::UserGroup->new(_school => $req->{school})->lookup_key($req->{usergroup_id});
	($rval,$msg) = $ug->remove_announcement($un, $pw, $req->{announcement_id});
    }else{
	($rval,$msg) = $req->{course}->remove_announcement($un, $pw, $req->{announcement_id});
    }
    
    return ($rval, $msg) if ($rval == 0);
    
    ## remove announcement
    
    ($rval,$msg) = $req->{announcement}->delete($un, $pw);
    return ($rval, $msg) if ($rval == 0);
    
    return (1, "Announcement Deleted");

}




