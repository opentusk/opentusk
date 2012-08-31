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
my $oldTopicId = $m->paramInt('tid');
my $newTopicId1 = $m->paramInt('newTopic1');
my $newTopicId2 = $m->paramInt('newTopic2');
my $notify = $m->paramBool('notify');
my $reason = $m->paramStr('reason');
my $submitted = $m->paramBool('subm');
my $sourceAuth = $m->paramInt('auth');
my $newTopicId = $newTopicId2 || $newTopicId1;
$oldTopicId or $m->paramError($lng->{errTpcIdMiss});

# Get topic
my $topic = $m->fetchHash("
	SELECT topics.boardId, topics.basePostId, topics.lastPostTime,
		posts.userId
	FROM $cfg->{dbPrefix}topics AS topics
		INNER JOIN $cfg->{dbPrefix}posts AS posts
		ON posts.id = topics.basePostId
	WHERE topics.id = $oldTopicId");
$topic or $m->entryError($lng->{errTpcNotFnd});
my $oldBoardId = $topic->{boardId};

# Check if user is admin or moderator in source board
$user->{admin} || $m->boardAdmin($userId, $oldBoardId) or $m->adminError();

# Process form
if ($submitted) {
	# Check request source authentication
	$sourceAuth == $user->{sourceAuth} or $m->formError($lng->{errSrcAuth});

	# Get destination topic
	my ($newBoardId, $newBasePostId) = $m->fetchArray("
		SELECT boardId, basePostId FROM $cfg->{dbPrefix}topics WHERE id = $newTopicId");
	$newBoardId or $m->formError($lng->{errTpcNotFnd});

	# Check if user is admin or moderator in destination board
	$user->{admin} || $m->boardAdmin($userId, $newBoardId) or $m->adminError()
		if $oldBoardId != $newBoardId;
	
	# Print form errors or finish action
	if (@{$m->{formErrors}}) { $m->printFormErrors() }
	else {
		# Get previous topic id for redirection to same page
		my $prevTopicId = $m->fetchArray("
			SELECT id 
			FROM $cfg->{dbPrefix}topics 
			WHERE boardId = $oldBoardId
				AND lastPostTime > $topic->{lastPostTime}
			ORDER BY lastPostTime
			LIMIT 1");
		
		# Transaction
		$m->dbBegin();
		eval {
			# Update posts
			$m->dbDo("
				UPDATE $cfg->{dbPrefix}posts SET 
					topicId = $newTopicId,
					boardId = $newBoardId
				WHERE topicId = $oldTopicId");
			
			# Update base post
			$m->dbDo("
				UPDATE $cfg->{dbPrefix}posts SET parentId = $newBasePostId WHERE id = $topic->{basePostId}");
			
			# Delete old topic
			$m->dbDo("
				DELETE FROM $cfg->{dbPrefix}topics WHERE id = $oldTopicId");
			
			# Set topicReadTimes to zero, otherwise too many posts might be marked as read
			$m->dbDo("
				UPDATE $cfg->{dbPrefix}topicReadTimes SET lastReadTime = 0 WHERE topicId = $newTopicId");
			
			# Update statistics
			$m->recalcStats(undef, $newTopicId);
			if ($oldBoardId != $newBoardId) {
				$m->recalcStats($oldBoardId);
				$m->recalcStats($newBoardId);
			}
		};
		$@ ? $m->dbRollback() : $m->dbCommit();

		# Add notification message
		if ($notify && $topic->{userId} && $topic->{userId} != $userId) {
			my $url = "topic_show$m->{ext}?tid=$newTopicId";
			$m->addNote($topic->{userId}, 'notTpcMrg', tpcUrl => $url, reason => $reason);
		}
		
		# Log action
		$m->logAction(1, 'topic', 'merge', $userId, $oldBoardId, $oldTopicId, 0, $newTopicId);
		
		# Redirect
		$m->redirect('board_show', bid => $oldBoardId, tid => $prevTopicId, msg => 'TpcMerge',
			tgt => "tid$prevTopicId");
	}
}

# Print forms
if (!$submitted || @{$m->{formErrors}}) {
	# Print header
	$m->printHeader();

	# Get subject
	my $subject = $m->fetchArray("
		SELECT subject FROM $cfg->{dbPrefix}topics WHERE id = $oldTopicId");
	$subject or $m->entryError($lng->{errTpcNotFnd});

	# Print page bar
	my @navLinks = ({ url => $m->url('topic_show', tid => $oldTopicId), 
		txt => 'comUp', ico => 'up' });
	$m->printPageBar(mainTitle => $lng->{mgtTitle}, subTitle => $subject, navLinks => \@navLinks);
	
	# Get other topics
	my $topics = $m->fetchAllHash("
		SELECT id, subject
		FROM $cfg->{dbPrefix}topics
		WHERE boardId = $oldBoardId
			AND id <> $oldTopicId
		ORDER BY lastPostTime DESC
		LIMIT 200");
	
	# Print destination topic form
	print
		"<form action='topic_merge$m->{ext}' method='post'>\n",
		"<div class='frm'>\n",
		"<div class='hcl'>\n",
		"<span class='htt'>$lng->{mgtMrgTtl}</span>\n",
		"</div>\n",
		"<div class='ccl'>\n",
		"$lng->{mgtMrgDest}<br/>\n",
		"<select name='newTopic1' size='10'>\n";
	
	for my $tpc (@$topics) {
		my $sel = $tpc->{id} == $newTopicId ? "selected='selected'" : '';
		print "<option value='$tpc->{id}' $sel>$tpc->{subject}</option>\n";
	}
	
	print
		"</select><br/><br/>\n",
		"$lng->{mgtMrgDest2}<br/>\n",
		"<input type='text' name='newTopic2' size='8' maxlength='8'/><br/><br/>\n";

	# Print notification checkbox
	my $checked = $cfg->{noteDefMod} ? "checked='checked'" : "";
	print		
		"<label><input type='checkbox' name='notify' $checked/>$lng->{notNotify}</label><br/>\n",
		"<input type='text' name='reason' size='80'/><br/><br/>\n"
		if $topic->{userId} > 0 && $topic->{userId} != $userId;

	print
		$m->submitButton('mgtMrgB', 'merge'),
		"<input type='hidden' name='tid' value='$oldTopicId'/>\n",
		$m->stdFormFields(),
		"</div>\n",
		"</div>\n",
		"</form>\n\n";
	
	# Log action
	$m->logAction(3, 'topic', 'merge', $userId, 0, $oldTopicId);
	
	# Print footer
	$m->printFooter();
}
