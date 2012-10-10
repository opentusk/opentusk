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

# Check if access should be denied
$userId or $m->regError();
$m->checkBan($userId);
$m->checkBlock();

# Get CGI parameters
my $topicId = $m->paramInt('tid');
my $sourceAuth = $m->paramInt('auth');

# Check request source authentication
$sourceAuth == $user->{sourceAuth} or $m->paramError($lng->{errSrcAuth});

# Get topic
my $topic = $m->fetchHash("
	SELECT topics.id, topics.boardId, topics.pollId,
		posts.userId
	FROM $cfg->{dbPrefix}topics AS topics
		INNER JOIN $cfg->{dbPrefix}posts AS posts
			ON posts.id = topics.basePostId
	WHERE topics.id = $topicId");
$topic or $m->entryError($lng->{errTpcNotFnd});
my $pollId = $topic->{pollId};

# Check if user owns topic or is admin
my $boardAdmin = $user->{admin} || $m->boardAdmin($userId, $topic->{boardId});
$userId == $topic->{userId} || $boardAdmin or $m->userError($lng->{errCheat});

# Transaction
$m->dbBegin();
eval {
	# Consolidate votes
	my $voteSums = $m->fetchAllArray("
		SELECT optionId, COUNT(*)
		FROM $cfg->{dbPrefix}pollVotes
		WHERE pollId = $pollId
		GROUP BY optionId");
	
	# Set option sums
	$m->dbDo("
		UPDATE $cfg->{dbPrefix}pollOptions SET votes = $_->[1] WHERE id = $_->[0]")
		for @$voteSums;

	# Mark poll as locked
	$m->dbDo("
		UPDATE $cfg->{dbPrefix}polls SET locked = 1 WHERE id = $pollId");

	# Delete individual votes
	$m->dbDo("
		DELETE FROM $cfg->{dbPrefix}pollVotes WHERE pollId = $pollId");
};
$@ ? $m->dbRollback() : $m->dbCommit();

# Log action
$m->logAction(1, 'poll', 'lock', $userId, $topic->{boardId}, $topicId, undef, $pollId);

# Redirect to topic page
$m->redirect('topic_show', tid => $topicId, msg => 'PollLock');
