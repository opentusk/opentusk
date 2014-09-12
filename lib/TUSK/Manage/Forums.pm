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


package TUSK::Manage::Forums;

use HSDB4::Constants;
use HSDB4::SQLLink;
use HSDB45::UserGroup;
use TUSK::Functions;
use TUSK::Core::School;
use TUSK::Constants;

use HSDB45::Course;
use HSDB45::TimePeriod;
use Forum::Board;
use Forum::Permission;
use Forum::BoardAdmin;
use Forum::ForumKey;

use strict;

my $pw = $TUSK::Constants::DatabaseUsers{ContentManager}->{writepassword};
my $un = $TUSK::Constants::DatabaseUsers{ContentManager}->{writeusername};

sub addedit_process{
    my ($req, $fdat, $udat) = @_;
    my ($rval, $msg);
    # apply any updates...

    my $dbh = HSDB4::Constants::def_db_handle();
    my $db = HSDB4::Constants::get_school_db($req->{school});
    
    my $school = TUSK::Core::School->new->lookupReturnOne("school_name = lcase('" . $req->{school} . "')");
    my $schoolId = $school->getPrimaryKeyID();

    my $groupId = $fdat->{usergroup} || 0;

    my ($boardKey, $categoryKey, $categoryId, $categoryName);
    my ($time_period_id, $courseId);
    
    # Construct boardKey and categoryKey values based on what kind of board we are adding/editing.
	if ($req->{type} eq "school")
	{
		$categoryKey = "0-$schoolId-0";
		$boardKey = Forum::ForumKey::createBoardKey($schoolId,0,0,0);
	}
	elsif ($req->{type} eq "course")
	{
		$courseId = $req->{course_id} || 0;
		$categoryKey = ($req->{course}->type() =~ /group|thesis committee/i)? "$courseId-0-0" : "0-0-0";
		$time_period_id = $udat->{timeperiod} || 0;
		$boardKey = Forum::ForumKey::createBoardKey($schoolId,$courseId,$time_period_id,$groupId);
	}
	else
	{
		$categoryKey = "0-$schoolId-$groupId";
		$boardKey = Forum::ForumKey::createBoardKey($schoolId,0,0,$groupId);
	}

    my $sth = $dbh->prepare("SELECT id FROM mwforum.categories WHERE categorykey = '$categoryKey'");
    $sth->execute;
    my @row = $sth->fetchrow_array();



	# A return value means we have a categoryId already.
	if (@row) {
		$categoryId = shift(@row);
	}
	# If nothing is returned, then we need to create a new category
	else {
		if ($req->{type} eq "school")
		{
			$categoryName = $school->getSchoolDisplay();
		}
		elsif ($req->{type} eq "course")
		{
			$categoryName = ($req->{course}->type() =~ /group|thesis committee/i)? $req->{course}->title() : "Courses";
		}
		else
		{
			my $group = HSDB45::UserGroup->new(_school => $req->{school})->lookup_key($req->{usergroup});
			$categoryName = $group->out_label;
		}	
	
		$sth = $dbh->prepare("INSERT INTO mwforum.categories (title, pos, categorykey)
                              VALUES (?,?,?)");
		$sth->execute($categoryName, 0, $categoryKey);
		$categoryId = $dbh->{'mysql_insertid'};
	}


	my $board = Forum::Board->new();

	$fdat->{'action'} = 'add';
 
    if ($req->{discussion_id}){
		$fdat->{'action'} = 'edit';
	    $board->lookupKey($req->{discussion_id});
	}
    elsif ($req->{type} eq 'course'){
	my $time_period_id = $udat->{timeperiod} || 0;
	if ($time_period_id){
	    my $time_period_obj = HSDB45::TimePeriod->new( _school => $req->{school})->lookup_key($time_period_id);
	    $board->setStartDate($time_period_obj->field_value('start_date'));
	    $board->setEndDate($time_period_obj->field_value('end_date'));
	}
    }
    
	if ($req->{type} eq 'course' && $req->{course}->type() !~ /group|thesis committee/i){
		$board->setTitle($req->{course}->title() . " - " . $fdat->{title});
	}
	else{
		$board->setTitle($fdat->{title});
	}

    $board->setCategoryID($categoryId);
    $board->setShortDesc($fdat->{shortDesc} || "");
    $board->setLongDesc($fdat->{longDesc} || "");
    $board->setBoardkey($boardKey);
    $board->setAnonymous($fdat->{anonymous});
    $board->setAttach("1");

    # need to figure out pos when adding new board
    unless ($req->{discussion_id}){
		my $position = 999;
		if ($req->{type} eq "school"){
			# for school/user group case - figure out how many boards are already there and set position to be one more
			$sth = $dbh->prepare("SELECT count(*) FROM mwforum.boards WHERE boardkey like ?");
			$sth->execute($boardKey);
			@row = $sth->fetchrow_array();
	    
			$position = shift(@row) + 1;
	    
		}
		elsif ( $req->{type} eq "usergroup"){
			
		}
		elsif ($req->{type} eq "course"){
			$sth = $dbh->prepare("SELECT count(*) FROM mwforum.boards WHERE boardkey like ?");
			$sth->execute($boardKey);
			@row = $sth->fetchrow_array();
	    
			$position = shift(@row) + 1;
		}
	
		$board->setPos($position);
	}
	$board->save();

    # We need to add the creator of this board as the moderator of the board
    # if this is not an edit action.

	if (!($fdat->{action} eq "edit")) {
		my $boardId = $board->getPrimaryKeyID();
		add_moderator($boardId, $req->{user}->primary_key());

		if ($req->{type} eq "course") {
			foreach my $user (@{$req->{course}->users($time_period_id)}) {
				next if ($user->getPrimaryKeyID() eq $req->{user}->primary_key());

				if ($user->hasRole('director') || $user->hasRole('manager')) {
					add_moderator($boardId, $user->getPrimaryKeyID());
				}
				elsif(!$fdat->{thesis_comm}){
					add_user($boardId, $user->getPrimaryKeyID(), "User");
				}
				else{
					add_user_thesis_comm($user->getPrimaryKeyID(), $fdat->{thesis_comm}, $req->{course}, $boardId);
				}
			}
		}
		
		# add board to user's viewable list
		my $sth = $dbh->prepare("INSERT INTO mwforum.variables (name, userId, value) SELECT ? as name, users.id as userId, 'viewableBoard' as value FROM mwforum.users as users WHERE users.userName = ?");
		$sth->execute(int($boardId), $req->{user}->primary_key());
	}

	if ($fdat->{action} eq "edit"){
		return (1, "Discussion Successfully Updated");
	}
	else {
		return (1, "Discussion Successfully Added");
	}
}

# put this logic into sub because it is a bit messy and only for the 'beta' thesis committee
# this way, if thesis comm goes away, or is severely altered, this logic is easily
# 'untied' from code.
sub add_user_thesis_comm{
	my ($user_id, $committee, $course, $boardId) = @_;

	# don't want 'users' added to advisor student group
	if($committee eq 'Advisor-Student'){
		return;
	}
	# student is also a user with role 'student-editor', so don't add them
	# to 'advisor-committee' or 'all' discussions as a user. let their 
	# identity as student have precedence
	elsif(!$course->is_child_student($user_id)){
		add_user($boardId, $user_id, "User");
	}
	# ban students from this group
	elsif($committee eq 'Advisor-Committee'){
		my @students = $course->child_students();
		foreach my $student (@students){
			add_user($boardId, $student->primary_key(), "Banned");
		}
       }
}


# This function adds a viewableBoard entry to the variables table with the
# supplied boardId and userName.
sub add_viewableBoard{
    my ($boardId, $userName) = @_;
    my $dbh = HSDB4::Constants::def_db_handle();
    
    # if we are editing a board, it means that people have already been added to the
    # variables table.  We never deleted entries from the variables table, so if
    # we just try to insert them, an error will be thrown.  We need to check if an
    # entry already exists for this combination of userid and boardid.
    my $sth = $dbh->prepare("SELECT value FROM mwforum.variables, mwforum.users WHERE name = ? AND userId = users.id AND users.userName = ? AND value='viewableBoard'");
    $sth->execute(int($boardId), $userName);
    my @row = $sth->fetchrow_array();
    if (!@row) {
	$sth = $dbh->prepare("INSERT INTO mwforum.variables (name, userId, value) SELECT ? as name, users.id as userId, 'viewableBoard' FROM mwforum.users as users WHERE users.userName = ?");
    $sth->execute(int($boardId), $userName);
    }
}

sub add_moderator{
    my ($boardId, $userName) = @_;
    my $dbh = HSDB4::Constants::def_db_handle();
    
    add_user($boardId, $userName, "Moderator");
    my $sth = $dbh->prepare("INSERT INTO mwforum.boardAdmins (userId, boardId) SELECT users.id as userId, ? as boardId FROM mwforum.users as users WHERE users.userName = ?");
    $sth->execute(int($boardId), $userName);
    
}

sub add_user{
    my ($boardId, $userName, $role) = @_;
    #add_viewableBoard($boardId, $userName);

    my $permission = Forum::Permission->new();
    
    $permission->setUserName($userName);
    $permission->setBoardID(int($boardId));
    $permission->setPermissions($role);
    $permission->save();
    
}

sub addedit_pre_process{
    my ($req, $fdat, $udat) = @_;
    my $data;

    $data->{board} = Forum::Board->new()->lookupKey($req->{discussion_id});

    
    if ($req->{type} eq "course"){
	my $timeperiod = TUSK::Functions::get_time_period($req, $udat);
	$data->{usergroups} = [ $req->{course}->sub_user_groups($timeperiod) ];
	
	if ($fdat->{page} eq "edit") {
	    my $course_title = $req->{course}->title();
	    my $title = $data->{board}->getTitle();
	    $title =~ s/^$course_title - //;
	    $data->{board}->setTitle($title);
	    my @boardkey = split(/-/, $data->{board}->getBoardkey());
	    $req->{usergroup} = $boardkey[3];
	}
    }


    if ($fdat->{page} eq "edit") {
	$req->{image}="ModifyDiscussion";
    }else{
	$req->{image}="CreateNewDiscussion";
    }

    return $data;
}

sub users_process{
    #
    # manage forum users
    #

    my ($forum_id, $fdat) = @_;
    my ($rval, $msg);
    my $dbh = HSDB4::Constants::def_db_handle();

    my @users = TUSK::Functions::get_users($fdat);

    Forum::Permission->new()->delete("boardId='" . int($forum_id) . "'");

    my $sth = $dbh->prepare("DELETE FROM mwforum.boardAdmins WHERE boardId = ?");
    $sth->execute(int($forum_id));

    foreach my $user (@users){
	if ($user->{permissions} eq "Moderator") {
	    add_moderator(int($forum_id), $user->{userid});
	}
	else {
	    # add_user can take care of the user and banned permissions because we don't have to add them to the boardAdmin table.
	    add_user(int($forum_id), $user->{userid}, $user->{permissions});
	}

    }

    return (1, "Discussion Users Updated");
}

sub update_board_title{
	my $course = shift;
	my $dbh = HSDB4::Constants::def_db_handle();
	my $sth = $dbh->prepare("SELECT id FROM mwforum.categories WHERE categorykey = ?");
	$sth->execute($course->primary_key() . '-0-0');
	my @row = $sth->fetchrow_array();
	if (@row) {
		my $category_id = shift(@row);
		$sth = $dbh->prepare("update mwforum.categories set title=? WHERE id = '$category_id'");
		$sth->execute($course->title());
	}
}
1;
