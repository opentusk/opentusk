#------------------------------------------------------------------------------
#    mwForum - Web-based discussion forum
#    Copyright (c) 1999-2007 Markus Wichitill
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#------------------------------------------------------------------------------

package MwfPlgAuthz;
use strict;
use warnings;
no warnings qw(uninitialized redefine);
$MwfPlgAuthz::VERSION = "2.5.0";

# Imports
use Forum::MwfMain;
use Data::Dumper;

#------------------------------------------------------------------------------
# Parameters for all actions:
#   m => MwfMain object
#
# Parameters for action 'regUser':
#   user => executing user hashref (
#   regUser => new user hashref (containing userName, email and possibly extraX fields only)
#
# Parameters for action 'userOpt':
#   user => executing user hashref
#   optUser => changed user hashref (parameter doesn't exist, will add if needed)
#
# Parameters for action 'viewBoard':
#   user => user hashref
#   board => board hashref
#
# Parameters for action 'newTopic':
#   user => user hashref
#   board => board hashref
#
# Parameters for action 'newPost':
#   user => user hashref
#   board => board hashref
#   topic => topic hashref
#   parent => parent post hashref
#
# Parameters for action 'editPost':
#   user => user hashref
#   board => board hashref
#   topic => topic hashref
#   post => post hashref
#
# Parameters for action 'attach':
#   user => user hashref
#   board => board hashref
#   topic => topic hashref
#   post => post hashref
#   delete => deleting attachment?
#   toggle => toggling embedded status?
#
# Parameters for action 'deletePost':
#   user => user hashref
#   post => post hashref
#
# Return undef to authorize the action, any error message string to deny it.
# Exception for viewBoard: return undef to continue normal access checking, 
#   1 to deny, and 2 to grant access without further access checking.

#------------------------------------------------------------------------------
# This simple user registration example checks a code in the extra3 profile field 
# and allows registration if the code is 42.

sub regUser
{
	my %params = @_;
	my $m = $params{m};
	my $regUser = $params{regUser};

	return undef if $regUser->{extra3} == 42;
	return "Invalid code";
}

#------------------------------------------------------------------------------
# TUSK modification, we can use this viewBoard section to restrict access to boards
# in the mwforum software, all boards need to be viewable by everyone first.
# there is tricky logic here, will get messy.  if admin, should be able to see everything.

# you check board->categoryId to restrict people.  
# 1. map all groups from tusk to a category
# 2. determine permissions on a group by group(category) basis.
# 3. new functions need to be created for specific actions (viewing, deleting, posting, editing, attaching, etc.)
# 4. you can restrict permissions by category ie. return undef if $board->{categoryId} != 2.
# 5. as far as editing userName and fields like that, we would have to edit the user_options.pl.
#    there is an update statement, we can remove userName and any other fields we do not want to allow users to update.
# 6. right now there is no way to modify the permissions without editing this file.  this is probably not a good solution
#    some sort of script needs to be made so these global permission can be edited easily from the web?
#    or create some sort of automatic system that can read information from TUSK and process it into appropriate permissions

my $count = 0;

sub viewBoard
{
	my %params = @_;
	my $m = $params{m};
	my $cfg = $m->{cfg};
	my $dbUser = $params{user};
	my $board = $params{board};

	my $viewableBoards = $m->{viewableBoards};
	my $boardhash = $m->{boardhash};

	if (!$viewableBoards) {
	    $viewableBoards = $m->fetchAllArray("
                  SELECT name FROM $cfg->{dbPrefix}variables WHERE userId = $dbUser->{id} AND value = 'viewableBoard'");
	
	    if (!@$viewableBoards) {
		$viewableBoards = 1;
	    }
	    else {
		my %boards = map { $_->[0] =>  1 } @$viewableBoards;
		$m->{boardhash} = \%boards;
		$boardhash = $m->{boardhash};
	    }

	    $m->{viewableBoards} = $viewableBoards;
	}
	elsif ($viewableBoards == 1) {
	    return 1;
	}
	
	if ((@$viewableBoards && (exists $boardhash->{$board->{id}})) || $board->{id} < 0)
	{
	    # undef allows a user to see the board
	    return undef;
	}
	
	# return value of 1 does not allow user to see the board
	return 1;
}


#------------------------------------------------------------------------------
# This example for the attach action limits attachments to two per topic 
# per user.

sub attach
{
  my %params = @_;
  my $m = $params{m};
  my $cfg = $m->{cfg};
  my $user = $params{user};
  my $topic = $params{topic};
  my $delete = $params{delete};
  my $toggle = $params{toggle};
  my $board = $params{board};

  return 1;

  return undef if $delete || $toggle;

  my $attachNum = $m->fetchArray("
  	SELECT COUNT(*) 
  	FROM $m->{cfg}{dbPrefix}posts 
  	WHERE userId = $user->{id}
  		AND topicId = $topic->{id} 
  		AND attach <> ''");

  return undef if $attachNum < 2;
  return "Only two attachments per topic per user.";
}

#------------------------------------------------------------------------------
1;
