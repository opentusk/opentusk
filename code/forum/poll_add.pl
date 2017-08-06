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

# Check if polls are enabled
$cfg->{polls} or $m->userError($lng->{errFeatDisbl});

# Get CGI parameters
my $topicId = $m->paramInt('tid');
my $title = $m->paramStr('title');
my $multi = $m->paramBool('multi');
my $submitted = $m->paramBool('subm');
my $sourceAuth = $m->paramInt('auth');
$topicId or $m->paramError($lng->{errTpcIdMiss});

# Get topic
my $topic = $m->fetchHash("
	SELECT topics.id, topics.boardId, topics.pollId, topics.subject, topics.locked,
		posts.userId
	FROM $cfg->{dbPrefix}topics AS topics
		INNER JOIN $cfg->{dbPrefix}posts AS posts
			ON posts.id = topics.basePostId
	WHERE topics.id = $topicId");
$topic or $m->entryError($lng->{errTpcNotFnd});
!$topic->{pollId} or $m->userError($lng->{errPolExist});
my $boardId = $topic->{boardId};

# Get board
my $board = $m->fetchHash("
	SELECT * FROM $cfg->{dbPrefix}boards WHERE id = $boardId");

# Check if topic is locked
!$topic->{locked} or $m->userError($lng->{errTpcLocked});

# Check if user can add poll
my $boardAdmin = $user->{admin} || $m->boardAdmin($userId, $boardId);
$boardAdmin || $userId == $topic->{userId} or $m->userError($lng->{errCheat});
$cfg->{polls} == 1 || $cfg->{polls} == 2 && $boardAdmin	or $m->adminError();

# Process form
if ($submitted) {
	# Check request source authentication
	$sourceAuth == $user->{sourceAuth} or $m->formError($lng->{errSrcAuth});

	# At least the first two options need to be filled in
	length($m->paramStr("option0")) && length($m->paramStr("option1")) 
		or $m->formError($lng->{errPolOneOpt});

	# Print form errors or finish action
	if (@{$m->{formErrors}}) { $m->printFormErrors() }
	else {
		# Quote strings
		my $titleQ = $m->dbQuote($m->escHtml($title));
		
		# Transaction
		my $pollId = 0;
		$m->dbBegin();
		eval {
			# Insert poll
			$m->dbDo("
				INSERT INTO $cfg->{dbPrefix}polls (title, multi) VALUES ($titleQ, $multi)");
			$pollId = $m->dbInsertId("$cfg->{dbPrefix}polls");

			# Insert poll options
			for my $i (0..19) {
				my $title = $m->paramStr("option$i");
				next if !length($title);
				my $titleQ = $m->dbQuote($m->escHtml($title));
				$m->dbDo("
					INSERT INTO $cfg->{dbPrefix}pollOptions (pollId, title) VALUES ($pollId, $titleQ)");
			}
			
			# Update topic
			$m->dbDo("
				UPDATE $cfg->{dbPrefix}topics SET pollId = $pollId WHERE id = $topicId");
		};
		$@ ? $m->dbRollback() : $m->dbCommit();
		
		# Log action
		$m->logAction(1, 'poll', 'add', $userId, $boardId, $topicId, undef, $pollId);
		
		# Redirect back to topic
		$m->redirect('topic_show', tid => $topicId, msg => 'PollAdd');
	}
}

# Print form
if (!$submitted || @{$m->{formErrors}}) {
	# Print header
	$m->printHeader();

	# Print page bar
	my @navLinks = ({ url => $m->url('topic_show', tid => $topicId), txt => 'comUp', ico => 'up' });
	$m->printPageBar(mainTitle => $lng->{tpcTitle}, subTitle => $topic->{subject}, 
		navLinks => \@navLinks);

	# Prepare subject
	$title = $m->escHtml($title) if $title;
	
	# Print add poll form
	print
		"<form action='poll_add$m->{ext}' method='post'>\n",
		"<div class='frm'>\n",
		"<div class='hcl'>\n",
		"<span class='htt'>$lng->{aplTitle}</span>\n",
		"</div>\n",
		"<div class='ccl'>\n",
		"$lng->{aplPollTitle}<br/>\n",
		"<input type='text' name='title' size='80' maxlength='200' value='$title'/><br/><br/>\n",
		"$lng->{aplPollOpts}<br/>\n";

	# Print options	
	for my $i (0..19) {
		my $option = $m->paramStr("option$i");
		$option = $m->escHtml($option) if $option;
		print "<input type='text' name='option$i' size='40' maxlength='50' value='$option'/><br/>\n";
	}

	my $multiChecked = $multi ? "checked='checked'" : "";
	print
		"<br/>\n",
		"<label><input type='checkbox' name='multi' $multiChecked/>",
		" $lng->{aplPollMulti}</label><br/><br/>\n",
		"$lng->{aplPollNote}<br/><br/>\n",
		$m->submitButton('aplPollAddB', 'poll'),
		"<input type='hidden' name='tid' value='$topicId'/>\n",
		$m->stdFormFields(),
		"</div>\n",
		"</div>\n",
		"</form>\n\n";
	
	# Log action
	$m->logAction(3, 'poll', 'add', $userId, $boardId, $topicId);
	
	# Print footer
	$m->printFooter();
}
