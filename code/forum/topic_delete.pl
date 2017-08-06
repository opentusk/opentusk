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

# Get CGI parameters
my $topicId = $m->paramInt('tid');
my $notify = $m->paramBool('notify');
my $reason = $m->paramStr('reason');
my $sourceAuth = $m->paramInt('auth');
$topicId or $m->paramError($lng->{errTpcIdMiss});

# Check request source authentication
$sourceAuth == $user->{sourceAuth} or $m->paramError($lng->{errSrcAuth});

# Get topic
my $topic = $m->fetchHash("
	SELECT topics.boardId, topics.pollId, topics.lastPostTime, topics.subject,
		posts.userId
	FROM $cfg->{dbPrefix}topics AS topics
		INNER JOIN $cfg->{dbPrefix}posts AS posts
		ON posts.id = topics.basePostId
	WHERE topics.id = $topicId");
$topic or $m->entryError($lng->{errTpcNotFnd});
my $boardId = $topic->{boardId};

# Check if user is admin or moderator
$user->{admin} || $m->boardAdmin($userId, $boardId) or $m->adminError();

# Get previous topic id for redirection to same page
my $prevTopicId = $m->fetchArray("
	SELECT id 
	FROM $cfg->{dbPrefix}topics 
	WHERE boardId = $boardId
		AND lastPostTime > $topic->{lastPostTime}
	ORDER BY lastPostTime
	LIMIT 1");

# Determine whether to trash or delete topic
my $trash = $cfg->{trashBoardId} && $cfg->{trashBoardId} != $boardId;

# Delete topic
$m->deleteTopic($topicId, $trash);

# Update board stats
$m->recalcStats($boardId);
$m->recalcStats($cfg->{trashBoardId}) if $trash;

# Add notification message
$m->addNote($topic->{userId}, 'notTpcDel', tpcSbj => $topic->{subject}, reason => $reason) 
	if $notify && $topic->{userId} && $topic->{userId} != $userId;

# Log action
$m->logAction(1, 'topic', 'delete', $userId, $boardId, $topicId);

# Redirect back
$m->redirect('board_show', bid => $boardId, tid => $prevTopicId, msg => 'TpcDelete', 
	tgt => "tid$prevTopicId");
