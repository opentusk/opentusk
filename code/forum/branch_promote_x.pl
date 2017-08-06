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

# Check if request is coming from this site
checkReferer();

# Get CGI parameters
my $cgi = new Forum::MwfCGI;
my $postId = int($cgi->param('pid'));
my $subject = $cgi->param('subject');
$postId or paramError($lng->{'errPstIdMiss'});
$subject or userError($lng->{'errSubEmpty'});

# Get base post
my $query = "
	SELECT boardId, topicId, parentId
	FROM posts	
	WHERE user_id = $postId";
my $sth = query($query);
my $basePost = $sth->fetchrow_hashref();
$basePost or entryError($lng->{'errPstNotFnd'});

# Branch base post can't be topic base post
$basePost->{'parentId'} or userError($lng->{'errPromoTpc'});

# Check if user is forum/board admin
$user->{'admin'} || boardAdmin($user->primary_key, $basePost->{'boardId'}) or adminError();

# Get posts
$query = "
	SELECT id, parentId
	FROM posts	
	WHERE topicId = $basePost->{'topicId'}";
$sth = query($query);
my $posts = $sth->fetchall_arrayref({});

# Put posts in by-parent lookup table
use vars qw(%postsByParent @branchPostIds);
%postsByParent = ();
for my $post (@$posts) { push @{$postsByParent{$post->{'parentId'}}}, $post }

# Get ids of posts that belong to branch
@branchPostIds = ();
getBranchPostIds($postId);
my $branchPostIds = join(",", @branchPostIds);

# Quote values
my $subjectQ = quote(escHtml($subject, 1));

# Transaction
my $newTopicId = undef;
begin();
eval {
	# Insert topic
	my $now = time();
	$query = "
		INSERT INTO topics SET 
			id           = NULL,
			subject      = $subjectQ,
			boardId      = $basePost->{'boardId'},
			basePostId   = $postId,
			protected    = 0,
			locked       = 0,
			hitNum       = 1,
			lastPostTime = $now";
	$dbh->do($query) or dbError();
	
	# Get new topic id
	$query = "SELECT LAST_INSERT_ID()";
	$sth = query($query);
	$newTopicId = $sth->fetchrow_array();
	
	# Update base post's parentId
	$query = "UPDATE posts SET parentId = 0 WHERE user_id = $postId";
	$dbh->do($query) or dbError();
	
	# Update posts
	$query = "
		UPDATE posts SET
			boardId = $basePost->{'boardId'},
			topicId = $newTopicId
		WHERE user_id IN ($branchPostIds)";
	$dbh->do($query) or dbError();
};
$@ ? rollback() : commit();

# Update topic stats
recalcStats(undef, $basePost->{'topicId'});
recalcStats(undef, $newTopicId);

# Log action
logAction(1, 'branch', 'promote', $user->primary_key, 
	$basePost->{'boardId'}, $basePost->{'topicId'}, $postId, $newTopicId);

# Redirect
redirect("board_show.pl?bid=$basePost->{'boardId'}&msg=BrnPromo");

#------------------------------------------------------------------------------

# Recursive branch post search
sub getBranchPostIds
{
	my $postId = shift();
	
	push @branchPostIds, $postId;
	
	for my $child (@{$postsByParent{$postId}}) { 
		$child->{'id'} != $postId or printError("Integrity Error", "Post is its own parent?!");
		getBranchPostIds($child->{'id'});
	}
}
