#!/usr/bin/perl
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
no warnings qw(uninitialized redefine);

# Imports
use Forum::MwfMain;

#------------------------------------------------------------------------------

# Init
my ($m, $cfg, $lng, $user) = MwfMain->new(@_);
my $userId = $user->{id};

# Get CGI parameters
my $postId = $m->paramInt('pid');
my $newParentId = $m->paramInt('parent') || 0;
my $sourceAuth = $m->paramInt('auth');
$postId or $m->paramError($lng->{errPstIdMiss});

# Check request source authentication
$sourceAuth == $user->{sourceAuth} or $m->paramError($lng->{errSrcAuth});

# Get branch base post
my ($oldBoardId, $oldTopicId, $oldParentId) = $m->fetchArray("
	SELECT boardId, topicId, parentId FROM $cfg->{dbPrefix}posts WHERE id = $postId");
$oldBoardId or $m->entryError($lng->{errPstNotFnd});

# Branch base post can't be topic base post
$oldParentId or $m->userError($lng->{errPromoTpc});

# Check if user is admin or moderator in source board
$user->{admin} || $m->boardAdmin($userId, $oldBoardId) or $m->adminError();

# If moving to other parent post
if ($newParentId) {
	# Get new parent post
	my ($newBoardId, $newTopicId) = $m->fetchArray("
		SELECT boardId, topicId FROM $cfg->{dbPrefix}posts WHERE id = $newParentId");
	$newTopicId or $m->entryError($lng->{errPstNotFnd});
	
	# If moving to parent post in other topic and/or board
	if ($oldTopicId != $newTopicId || $oldBoardId != $newBoardId) {
		# Check if user is admin or moderator in destination board
		$user->{admin} || $m->boardAdmin($userId, $newBoardId) or $m->adminError()
			if $oldBoardId != $newBoardId;
	
		# Get IDs of posts that belong to branch
		my $posts = $m->fetchAllHash("
			SELECT id, parentId FROM $cfg->{dbPrefix}posts WHERE topicId = $oldTopicId");
		our %postsByParent = ();
		push @{$postsByParent{$_->{parentId}}}, $_ for @$posts;
		our @branchPostIds = ();
		getBranchPostIds($postId);
		sub getBranchPostIds
		{
			my $pid = shift();
			push @branchPostIds, $pid;
			for my $child (@{$postsByParent{$pid}}) { 
				$child->{id} != $pid or printError("Integrity Error", "Post is its own parent?!");
				getBranchPostIds($child->{id});
			}
		}
		my $branchPostIdsStr = join(",", @branchPostIds);
	
		# Transaction
		$m->dbBegin();
		eval {
			# Update base post's parentId
			$m->dbDo("
				UPDATE $cfg->{dbPrefix}posts SET parentId = $newParentId WHERE id = $postId");
			
			# Update posts
			$m->dbDo("
				UPDATE $cfg->{dbPrefix}posts SET
					boardId = $newBoardId,
					topicId = $newTopicId
				WHERE id IN ($branchPostIdsStr)");
		
			# Update statistics
			if ($oldBoardId != $newBoardId) {
				$m->recalcStats($oldBoardId, $oldTopicId);
				$m->recalcStats($newBoardId, $newTopicId);
			}
			elsif ($oldTopicId != $newTopicId) {
				$m->recalcStats(undef, $oldTopicId);
				$m->recalcStats(undef, $newTopicId);
			}
		};
		$@ ? $m->dbRollback() : $m->dbCommit();
	}
	# If moving to other parent post in same topic
	else {
		# Update base post's parentId
		$m->dbDo("
			UPDATE $cfg->{dbPrefix}posts SET parentId = $newParentId WHERE id = $postId");
	}
}
# If making post new topic base post
else {
	# Get old topic base post id
	my $oldBasePostId = $m->fetchArray("
		SELECT basePostId FROM $cfg->{dbPrefix}topics WHERE id = $oldTopicId");

	# Transaction
	$m->dbBegin();
	eval {
		# Make post new topic base post
		$m->dbDo("
			UPDATE $cfg->{dbPrefix}topics SET basePostId = $postId WHERE id = $oldTopicId");
		$m->dbDo("
			UPDATE $cfg->{dbPrefix}posts SET parentId = 0 WHERE id = $postId");
		$m->dbDo("
			UPDATE $cfg->{dbPrefix}posts SET parentId = $postId WHERE id = $oldBasePostId");
		$m->dbDo("
			UPDATE $cfg->{dbPrefix}posts SET parentId = $postId WHERE parentId = $oldBasePostId");
	};
	$@ ? $m->dbRollback() : $m->dbCommit();
}

# Log action
$m->logAction(1, 'branch', 'move', $userId, $oldBoardId, $oldTopicId, $postId, $newParentId);

# Redirect
$m->redirect('topic_show', tid => $oldTopicId, pid => $postId, msg => 'BrnMove', tgt => "pid$postId");
