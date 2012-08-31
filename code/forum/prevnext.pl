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
my $srcBoardId = $m->paramInt('bid');
my $srcTopicId = $m->paramInt('tid');
my $direction = $m->paramStr('dir');
$direction or $m->paramError($lng->{errParamMiss});

if ($srcBoardId) {
	# Get source board
	my $board = $m->fetchHash("
		SELECT boards.*, categories.pos AS categPos
		FROM $cfg->{dbPrefix}boards AS boards
			INNER JOIN $cfg->{dbPrefix}categories AS categories
				ON categories.id = boards.categoryId
		WHERE boards.id = $srcBoardId");
	$board or $m->entryError($lng->{errBrdNotFnd});

	# Query direction
	my $rel;
	my $strrel;
	my $order;
	if ($direction eq 'prev') {
		$rel = "<";
   	        $strrel = "-1";
		$order = "DESC";
	}
	else {
	        $rel = ">";
	        $strrel = "1";
		$order = "ASC";
	}

	# Get destination board id (M-M-MO-MO-MONSTER QUERY!)
	my $dstBoardId = $m->fetchArray("
		SELECT boards.id 
		FROM $cfg->{dbPrefix}boards AS boards, $cfg->{dbPrefix}variables AS variables
		WHERE (strcmp(boards.boardkey,'$board->{boardkey}') = $strrel
                          OR (boards.boardkey = '$board->{boardkey}' AND boards.pos $rel $board->{pos}))
                      AND variables.name = boards.id
                      AND variables.userId = $userId
                      AND variables.value = 'viewableBoard'
		      AND boards.private = 0 
		ORDER BY boards.boardkey $order, boards.pos $order
		LIMIT 1");

	# If at end of board list, wrap around	
	if (!$dstBoardId) {
		$dstBoardId = $m->fetchArray("
                        SELECT boards.* FROM $cfg->{dbPrefix}boards AS boards, $cfg->{dbPrefix}variables AS variables
                              WHERE variables.userId = $user->{id}
                              AND variables.value = 'viewableBoard'
                              AND variables.name = boards.id
                              AND boards.private = '0'
                              ORDER BY boards.boardkey $order, boards.pos $order
			LIMIT 1");
	}

	# Redirect to board
	$m->redirect('board_show', bid => $dstBoardId);
}
elsif ($srcTopicId) {
	# Get source topic
	my $topic = $m->fetchHash("
		SELECT boardId, lastPostTime FROM $cfg->{dbPrefix}topics WHERE id = $srcTopicId");
	$topic or $m->entryError($lng->{errTpcNotFnd});

	# Query direction
	my $rel;
	my $order;
	if ($direction eq 'prev') {
		$rel = ">";
		$order = "ASC";
	}
	else {
		$rel = "<";
		$order = "DESC";
	}

	# Get destination topic id
	my $dstTopicId = $m->fetchArray("
		SELECT id 
		FROM $cfg->{dbPrefix}topics 
		WHERE boardId = $topic->{boardId}
			AND lastPostTime $rel $topic->{lastPostTime}
		ORDER BY lastPostTime $order
		LIMIT 1");

	if ($dstTopicId) {
		# Redirect to topic
		$m->redirect('topic_show', tid => $dstTopicId, tgt => $userId ? "fp" : "");
	}
	else {
		# Redirect to board
		$m->redirect('board_show', tid=> $srcTopicId, msg => 'EolTpc');
	}
}

# Redirect to forum page in case of missing params
$m->redirect('forum_show');
