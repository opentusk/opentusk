#!/usr/bin/perl
#------------------------------------------------------------------------------
#    mwForum - Web-based discussion forum
#    Copyright (c) 1999-2001 Markus Wichitill <mwforum@mawic.de>
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
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#------------------------------------------------------------------------------

use strict;

# Imports
use CGI::Carp qw();
use DBI;
use Forum::MwfConfig;
use Forum::MwfMain;
use Forum::MwfCGI;

#------------------------------------------------------------------------------

# Get user
connectDb();
authUser();

# Print HTTP header
printHttpHeader();

# Check if request is coming from this site
checkReferer();

# Get CGI parameters
my $cgi = new Forum::MwfCGI;
my $topicId = int($cgi->param('tid'));
my $newBoardId = int($cgi->param('bid'));
$topicId or paramError($lng->{'errTpcIdMiss'});
$newBoardId or paramError($lng->{'errBrdIdMiss'});

# Get topic
my $query = "SELECT boardId FROM topics WHERE id = $topicId";
my $sth = query($query);
my $oldBoardId = $sth->fetchrow_array();
$oldBoardId or entryError($lng->{'errTpcNotFnd'});

# Transaction
begin();
eval {
	# Get destination board
	my $query = "SELECT * FROM boards WHERE id = $newBoardId";
	my $sth = query($query);
	my $newBoard = $sth->fetchrow_hashref();
	$newBoard or entryError($lng->{'errBrdNotFnd'});

	# Check if user may move from/to boards
	$user->{'admin'} 
		|| boardAdmin($user->primary_key, $oldBoardId) && boardWritable($newBoard)
		or adminError();

	# Update posts
	$query = "UPDATE posts SET boardId = $newBoardId WHERE topicId = $topicId";
	$dbh->do($query) or dbError();
	
	# Update topic
	$query = "UPDATE topics SET boardId = $newBoardId WHERE id = $topicId";
	$dbh->do($query) or dbError();
};
$@ ? rollback() : commit();

# Update board stats
recalcStats($oldBoardId);
recalcStats($newBoardId);

# Log action
logAction(1, 'topic', 'move', $user->primary_key, $oldBoardId, $topicId, 0, $newBoardId);

# Redirect
redirect("board_show.pl?bid=$oldBoardId&msg=TpcMove");
