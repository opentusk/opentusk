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
my $optionId = $m->paramInt('option');
my $topicId = $m->paramInt('tid');
my $sourceAuth = $m->paramInt('auth');

# Check request source authentication
$sourceAuth == $user->{sourceAuth} or $m->paramError($lng->{errSrcAuth});

# Get topic
my $topic = $m->fetchHash("
	SELECT id, boardId, pollId, locked FROM $cfg->{dbPrefix}topics WHERE id = $topicId");
$topic or $m->entryError($lng->{errTpcNotFnd});
my $pollId = $topic->{pollId};

# Get board
my $board = $m->fetchHash("
	SELECT * FROM $cfg->{dbPrefix}boards WHERE id = $topic->{boardId}");

# Check if user can see and write to board
my $boardAdmin = $user->{admin} || $m->boardAdmin($userId, $board->{id});
$boardAdmin || $m->boardVisible($board) or $m->entryError($lng->{errBrdNotFnd});
$boardAdmin || $m->boardWritable($board, 1) or $m->userError($lng->{errReadOnly});

# Get poll
my $poll = $m->fetchHash("
	SELECT locked, multi FROM $cfg->{dbPrefix}polls WHERE id = $pollId");
$poll or $m->entryError($lng->{errPolNotFnd});

# Check if topic or poll is locked
!$topic->{locked} or $m->userError($lng->{errTpcLocked});
!$poll->{locked} or $m->userError($lng->{errPolLocked});

# Multi-vote polls
if ($poll->{multi}) {
	# Get options
	my $options = $m->fetchAllArray("
		SELECT id FROM $cfg->{dbPrefix}pollOptions WHERE pollId = $pollId");
	
	for my $option (@$options) {
		# Check if user has voted for this option
		if ($m->paramBool("option_$option->[0]")) {
			# Check if user has already voted for this option before
			my $votedThis = $m->fetchArray("
				SELECT 1 
				FROM $cfg->{dbPrefix}pollVotes 
				WHERE pollId = $pollId 
					AND userId = $userId
					AND optionId = $option->[0]");

			# Insert vote if it's not a dupe
			if (!$votedThis) {
				$m->dbDo("
					INSERT INTO $cfg->{dbPrefix}pollVotes (pollId, userId, optionId)
					VALUES ($pollId, $userId, $option->[0])");
			}
		}
	}
}
# Single-vote polls
else {
	# Check if an option has been selected
	$optionId or $m->userError($lng->{errPolNoOpt});

	# Check if option exists, and is part of this poll
	$m->fetchArray("
		SELECT id FROM $cfg->{dbPrefix}pollOptions WHERE id = $optionId AND pollId = $pollId") 
		or $m->entryError($lng->{errPolOpNFnd});
	
	# Check if user has already voted
	!$m->fetchArray("
		SELECT 1 FROM $cfg->{dbPrefix}pollVotes WHERE pollId = $pollId AND userId = $userId")
		or $m->userError($lng->{errPolVotedP});
	
	# Insert vote
	$m->dbDo("
		INSERT INTO $cfg->{dbPrefix}pollVotes (pollId, userId, optionId)
		VALUES ($pollId, $userId, $optionId)");
	
	# Double check votes to make sure no parallel thread inserted votes in single-vote polls
	# The PKey (pollId, userId, optionId) takes care of multi-vote polls
	my $votes = $m->fetchArray("
		SELECT COUNT(*)
		FROM $cfg->{dbPrefix}pollVotes
		WHERE pollId = $pollId
			AND userId = $userId
			AND optionId = $optionId");
	
	# Delete all votes if poll got more than one vote
	if ($votes > 1) {
		$m->dbDo("
			DELETE FROM $cfg->{dbPrefix}pollVotes WHERE pollId = $pollId AND userId = $userId");
		$m->userError($lng->{errPolVotedP});
	}
}

# Log action
$m->logAction(1, 'poll', 'vote', $userId, $topic->{boardId}, $topicId, undef, $pollId);

# Redirect to topic page
$m->redirect('topic_show', tid => $topicId, msg => 'PollVote');
