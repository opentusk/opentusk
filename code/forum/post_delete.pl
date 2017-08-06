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
no warnings qw(uninitialized redefine);

# Imports
use Forum::MwfMain;

#------------------------------------------------------------------------------

# Init
my ($m, $cfg, $lng, $user) = MwfMain->new(@_);
my $userId = $user->{id};

# Check if access should be denied
$userId or $m->regError();
$m->checkBan($userId);
$m->checkBlock();

# Get CGI parameters
my $postId = $m->paramInt('pid');
my $notify = $m->paramBool('notify');
my $reason = $m->paramStr('reason');
my $sourceAuth = $m->paramInt('auth');
$postId or $m->paramError($lng->{errPstIdMiss});

# Check request source authentication
$sourceAuth == $user->{sourceAuth} or $m->paramError($lng->{errSrcAuth});

# Get post
my $post = $m->fetchHash("
	SELECT posts.*, 
		topics.pollId, topics.subject
	FROM $cfg->{dbPrefix}posts AS posts
		INNER JOIN $cfg->{dbPrefix}topics AS topics
			ON topics.id = posts.topicId
	WHERE posts.id = $postId");
$post or $m->entryError($lng->{errPstNotFnd});
my $parentId = $post->{parentId};
my $boardId = $post->{boardId};
my $topicId = $post->{topicId};

# Check authorization
$m->checkAuthz($user, 'deletePost', post => $post);

# Check if user is allowed to delete post
my $boardAdmin = $user->{admin} || $m->boardAdmin($userId, $boardId);
$userId == $post->{userId} || $boardAdmin	or $m->userError($lng->{errCheat});
	
# Check editing time limitation
!$cfg->{postEditTime} || time() < $post->{postTime} + $cfg->{postEditTime}
	|| $boardAdmin || $m->boardMember($userId, $boardId)
	or $m->userError($lng->{errPstEdtTme});

# Delete post
my $trash = $cfg->{trashBoardId} && $cfg->{trashBoardId} != $boardId;
my $topicDeleted = $m->deletePost($postId, $trash);

# Update board/topic stats
$m->recalcStats($boardId, $topicId);

# Add notification message
if ($notify && $post->{userId} && $post->{userId} != $userId) {
	if ($topicDeleted) {
		$m->addNote($post->{userId}, 'notTpcDel', tpcSbj => $post->{subject}, reason => $reason);
	}
	else {
		my $url = "topic_show$m->{ext}?tid=$topicId";
		$m->addNote($post->{userId}, 'notPstDel', tpcUrl => $url, reason => $reason);
	}
}

# Log action
$m->logAction(1, 'post', 'delete', $userId, $boardId, $topicId, $postId);

# Redirect back
$m->redirect('board_show', bid => $boardId, msg => 'PstTpcDel') if $topicDeleted;
$m->redirect('topic_show', tid => $topicId, pid => $parentId, msg => 'PstDel', 
	tgt => "pid$parentId");
