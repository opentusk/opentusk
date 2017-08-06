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
my $newBoardId = $m->paramInt('bid');
my $notify = $m->paramBool('notify');
my $reason = $m->paramStr('reason');
my $submitted = $m->paramBool('subm');
my $sourceAuth = $m->paramInt('auth');
$topicId or $m->paramError($lng->{errTpcIdMiss});

# Get topic and topic poster
my $topic = $m->fetchHash("
	SELECT topics.boardId, topics.lastPostTime, topics.basePostId,
		posts.userId AS userId
	FROM $cfg->{dbPrefix}topics AS topics
		INNER JOIN $cfg->{dbPrefix}posts AS posts
			ON posts.id = topics.basePostId
	WHERE topics.id = $topicId");
my $boardId = $topic->{boardId};
$boardId or $m->entryError($lng->{errTpcNotFnd});

# Check if user is admin or moderator in source board
$user->{admin} || $m->boardAdmin($userId, $boardId) or $m->adminError();

# Process form
if ($submitted) {
	# Check request source authentication
	$sourceAuth == $user->{sourceAuth} or $m->formError($lng->{errSrcAuth});

	# Check if destination board exists
	$newBoardId or $m->paramError($lng->{errBrdIdMiss});
	my $newBoard = $m->fetchHash("
		SELECT * FROM $cfg->{dbPrefix}boards WHERE id = $newBoardId");
	$newBoard or $m->entryError($lng->{errBrdNotFnd});

	# Check if user has write access to destination board
	$m->boardVisible($newBoard) or $m->entryError($lng->{errBrdNotFnd});
	$m->boardWritable($newBoard) or $m->userError($lng->{errReadOnly});

	# Print form errors or finish action
	if (@{$m->{formErrors}}) { $m->printFormErrors() }
	else {
		# Get previous topic id for redirection to same page
		my $prevTopicId = $m->fetchArray("
			SELECT id 
			FROM $cfg->{dbPrefix}topics 
			WHERE boardId = $boardId
				AND lastPostTime > $topic->{lastPostTime}
			ORDER BY lastPostTime
			LIMIT 1");

		# Transaction
		$m->dbBegin();
		eval {
			# Update posts
			$m->dbDo("
				UPDATE $cfg->{dbPrefix}posts SET boardId = $newBoardId WHERE topicId = $topicId");
			
			# Update topic
			$m->dbDo("
				UPDATE $cfg->{dbPrefix}topics SET boardId = $newBoardId WHERE id = $topicId");
				
			# Update statistics
			$m->recalcStats($boardId);
			$m->recalcStats($newBoardId);
		};
		$@ ? $m->dbRollback() : $m->dbCommit();

		# Add notification message
		if ($notify && $topic->{userId} && $topic->{userId} != $userId) {
			my $url = "topic_show$m->{ext}?tid=$topicId";
			$m->addNote($topic->{userId}, 'notTpcMov', tpcUrl => $url, reason => $reason);
		}

		# Log action
		$m->logAction(1, 'topic', 'move', $userId, $boardId, $topicId, 0, $newBoardId);
		
		# Redirect
		$m->redirect('board_show', bid => $boardId, tid => $prevTopicId, msg => 'TpcMove', 
			tgt => "tid$prevTopicId");
	}
}

# Print form
if (!$submitted || @{$m->{formErrors}}) {
	# Print header
	$m->printHeader();

	# Get subject
	my $subject = $m->fetchArray("
		SELECT subject FROM $cfg->{dbPrefix}topics WHERE id = $topicId");
	$subject or $m->entryError($lng->{errTpcNotFnd});

	# Print page bar
	my @navLinks = ({ url => $m->url('topic_show', tid => $topicId), txt => 'comUp', ico => 'up' });
	$m->printPageBar(mainTitle => $lng->{mvtTitle}, subTitle => $subject, navLinks => \@navLinks);
	
	# TUSK begin
	# need to get boards using our method.
	# Get boards
	my $boards = Forum::ForumKey::getViewableBoardsHash($m, $user);
=pod
	my $boards = $m->fetchAllHash("
		SELECT boards.*,
			categories.title AS categTitle
		FROM $cfg->{dbPrefix}boards AS boards
			INNER JOIN $cfg->{dbPrefix}categories AS categories
				ON categories.id = boards.categoryId
		ORDER BY categories.pos, boards.pos");
	@$boards = grep($_->{id} != $boardId, @$boards);
	@$boards = grep($m->boardVisible($_), @$boards);
	@$boards = grep($m->boardWritable($_), @$boards);
=cut
        # TUSK end

	# Print destination board form
	print
		"<form action='topic_move$m->{ext}' method='post'>\n",
		"<div class='frm'>\n",
		"<div class='hcl'>\n",
		"<span class='htt'>$lng->{mvtMovTtl}</span>\n",
		"</div>\n",
		"<div class='ccl'>\n",
		"$lng->{mvtMovDest}<br/>\n",
		"<select name='bid' size='10'>\n";
	
	for my $board (@$boards) {
		my $sel = $board->{id} == $newBoardId ? "selected='selected'" : '';
		print "<option value='$board->{id}' $sel>$board->{categTitle} / $board->{title}</option>\n";
	}
	
	print "</select><br/><br/>\n";

	# Print notification checkbox
	my $checked = $cfg->{noteDefMod} ? "checked='checked'" : "";
	print		
		"<label><input type='checkbox' name='notify' $checked/>$lng->{notNotify}</label><br/>\n",
		"<input type='text' name='reason' size='80'/><br/><br/>\n"
		if $topic->{userId} > 0 && $topic->{userId} != $userId;
	
	# TUSK begin
	# print warning about moving topics
	print "<h4><font color='red'>Warning: If you move a topic to another board where you<br>do not have moderator priviliges, you will not be able to<br>modify the topic anymore.</font></h4>";
	# TUSK end
	print	
		$m->submitButton('mvtMovB', 'move'),
		"<input type='hidden' name='tid' value='$topicId'/>\n",
		$m->stdFormFields(),
		"</div>\n",
		"</div>\n",
		"</form>\n\n";

	# Log action
	$m->logAction(3, 'topic', 'move', $userId, 0, $topicId);
	
	# Print footer
	$m->printFooter();
}
