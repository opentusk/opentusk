#!/usr/bin/env perl
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
use CGI::Carp qw(fatalsToBrowser);
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

# Check if user is registered and not banned
$user->{'default'} and regError();
checkBan($user->primary_key);
checkBlock();

# Check if request is coming from this site
checkReferer();

# Get CGI parameters
my $cgi = new Forum::MwfCGI;
my $postId = int($cgi->param('pid'));
my $direction = $cgi->param('dir') ? 1 : -1;
my $page = int($cgi->param('pg')) || 1;
my $origin = $cgi->param('ori');
$postId or paramError($lng->{'errPstIdMiss'});

# Get post
my $query = "SELECT userId, boardId, topicId FROM posts WHERE user_id = $postId";
my $sth = query($query);
my $post = $sth->fetchrow_hashref();
$post or entryError($lng->{'errPstNotFnd'});

# Check if user has votes left
$user->{'votesLeft'} > 0
	or redirect("topic_show.pl?tid=$post->{'topicId'}&msg=NoVotes#$postId");

# Check if user is trying to moderate his own post
$user->primary_key != $post->{'userId'} 
	or userError($lng->{'errModOwnPst'});

# Transaction
begin();
eval {
	# Update post score
	$query = "UPDATE posts SET score = score+($direction) WHERE user_id = $postId";
	$dbh->do($query) or dbError();
	
	# Update user votes
	$query = "UPDATE users SET votesLeft = votesLeft-1 WHERE user_id = $user->primary_key";
	$dbh->do($query) or dbError();
};
$@ ? rollback() : commit();

# Log action
logAction(1, 'post', 'moderate', $user->primary_key, $post->{'boardId'}, $post->{'topicId'}, $postId);

# Redirect back
my $msg = $direction == 1 ? "ModUp" : "ModDown";
$origin eq "newPst"
	? redirect("post_shownew.pl?msg=$msg#$postId") 
	: redirect("topic_show.pl?tid=$post->{'topicId'}&pg=$page&msg=$msg#$postId");
