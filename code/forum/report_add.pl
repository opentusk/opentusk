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
my $reason = $m->paramStr('reason');
my $submitted = $m->paramBool('subm');
my $sourceAuth = $m->paramInt('auth');
$postId or $m->paramError($lng->{errPstIdMiss});

# Get post
my $post = $m->fetchHash("
	SELECT userId, boardId, topicId FROM $cfg->{dbPrefix}posts WHERE id = $postId");
$post or $m->entryError($lng->{errPstNotFnd});

# Get board
my $board = $m->fetchHash("
	SELECT * FROM $cfg->{dbPrefix}boards WHERE id = $post->{boardId}");

# Check if user can see board
my $boardAdmin = $user->{admin} || $m->boardAdmin($userId, $board->{id});
$boardAdmin || $m->boardVisible($board) or $m->entryError($lng->{errPstNotFnd});

# Check if there's already a report from user
my $entry = $m->fetchArray("
	SELECT userId FROM $cfg->{dbPrefix}postReports WHERE userId = $userId AND postId = $postId");
!$entry or $m->userError($lng->{errRepDupe});

# Process form
if ($submitted) {
	# Check request source authentication
	$sourceAuth == $user->{sourceAuth} or $m->formError($lng->{errSrcAuth});

	# Don't let user report his own posts
	$userId != $post->{userId} or $m->userError($lng->{errRepOwn});

	# Check reason
	$reason or $m->formError($lng->{errRepReason});

	# Print form errors or finish action
	if (@{$m->{formErrors}}) { $m->printFormErrors() }
	else {
		# Filter and quote strings
		my $fakeBoard = { flat => 1 };
		my $fakePost = { isReport => 1, body => $reason };
		$m->editToDb($fakeBoard, $fakePost);
		my $reasonQ = $m->dbQuote($fakePost->{body});
		
		# Add post to list
		$m->dbDo("
			INSERT INTO $cfg->{dbPrefix}postReports (userId, postId, reason)
			VALUES ($userId, $postId, $reasonQ)");
		
		# Log action
		$m->logAction(1, 'report', 'add', $userId, $board->{id}, $post->{topicId}, $postId);
		
		# Redirect back to topic
		$m->redirect('topic_show', tid => $post->{topicId}, pid => $postId, msg => 'PstAddRep',
			tgt => "pid$postId");
	}
}

# Print form
if (!$submitted || @{$m->{formErrors}}) {
	# Print header
	$m->printHeader();

	# Print bar
	my @navLinks = ({ 
		url => $m->url('topic_show', tid => $post->{topicId}, pid => $postId, tgt => "pid$postId"), 
		txt => 'comUp', ico => 'up' });
	$m->printPageBar(mainTitle => $lng->{arpTitle}, navLinks => \@navLinks);

	# Print report form
	print
		"<form action='report_add$m->{ext}' method='post'>\n",
		"<div class='frm'>\n",
		"<div class='hcl'>\n",
		"<span class='htt'>$lng->{arpRepTtl}</span>\n",
		"</div>\n",
		"<div class='ccl'>\n",
		"$lng->{arpRepT}<br/><br/>\n",
		"$lng->{arpRepReason}<br/>\n",
		"<textarea name='reason' cols='80' rows='3'></textarea><br/><br/>\n",
		$m->submitButton('arpRepB', 'report'),
		"<input type='hidden' name='pid' value='$postId'/>\n",
		$m->stdFormFields(),
		"</div>\n",
		"</div>\n",
		"</form>\n\n";

	# Log action
	$m->logAction(3, 'report', 'add', $userId, $board->{id}, $post->{topicId}, $postId);
	
	# Print footer
	$m->printFooter();
}
