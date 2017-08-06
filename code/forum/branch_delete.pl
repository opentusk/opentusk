#!/usr/bin/env perl
#------------------------------------------------------------------------------
#    mwForum - Web-based discussion forum
#    Copyright (c) 1999-2007 Markus Wichitill
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#------------------------------------------------------------------------------

use strict;
use warnings;
no warnings qw(uninitialized redefine once);

# Imports
use Forum::MwfMain;

#------------------------------------------------------------------------------

# Init
my ($m, $cfg, $lng, $user) = MwfMain->new(@_);
my $userId = $user->{id};

# Get CGI parameters
my $postId = $m->paramInt('pid');
my $sourceAuth = $m->paramInt('auth');
$postId or $m->paramError($lng->{errPstIdMiss});

# Check request source authentication
$sourceAuth == $user->{sourceAuth} or $m->paramError($lng->{errSrcAuth});

# Get base post
my ($boardId, $topicId, $parentId) = $m->fetchArray("
	SELECT boardId, topicId, parentId FROM $cfg->{dbPrefix}posts WHERE id = $postId");
$boardId or $m->entryError($lng->{errPstNotFnd});

# Branch base post can't be topic base post
$parentId or $m->userError($lng->{errPromoTpc});

# Check if user is admin or moderator
$user->{admin} || $m->boardAdmin($userId, $boardId) or $m->adminError();

# Get posts
my $posts = $m->fetchAllHash("
	SELECT id, parentId	FROM $cfg->{dbPrefix}posts WHERE topicId = $topicId");

# Put posts in by-parent lookup table
our (%postsByParent, @branchPostIds);
%postsByParent = ();
push @{$postsByParent{$_->{parentId}}}, $_ for @$posts;

# Get ids of posts that belong to branch
@branchPostIds = ();
getBranchPostIds($postId);
sub getBranchPostIds
{
	my $pid = shift();
	push @branchPostIds, $pid;
	for my $child (@{$postsByParent{$pid}}) { 
		$child->{id} != $pid or $main::m->printError("Integrity Error", "Post is its own parent?!");
		getBranchPostIds($child->{id});
	}
}
my $branchPostIdsStr = join(",", @branchPostIds);

# Transaction
$m->dbBegin();
eval {
	# Delete attachments
	my $attachments = $m->fetchAllArray("
		SELECT id FROM $cfg->{dbPrefix}attachments WHERE postId IN ($branchPostIdsStr)");
	$m->deleteAttachment($_->[0]) for @$attachments;

	# Delete todo list entries
	$m->dbDo("
		DELETE FROM $cfg->{dbPrefix}postTodos WHERE postId IN ($branchPostIdsStr)");
	
	# Delete report list entries
	$m->dbDo("
		DELETE FROM $cfg->{dbPrefix}postReports WHERE postId IN ($branchPostIdsStr)");

	# Delete posts
	$m->dbDo("
		DELETE FROM $cfg->{dbPrefix}posts WHERE id IN ($branchPostIdsStr)");
};
$@ ? $m->dbRollback() : $m->dbCommit();

# Update board and topic stats
$m->recalcStats($boardId, $topicId);

# Log action
$m->logAction(1, 'branch', 'delete', $userId, $boardId, $topicId, $postId);

# Redirect
$m->redirect('topic_show', tid => $topicId, msg => 'BrnDelete');
