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
my $submitted = $m->paramBool('subm');
my $sourceAuth = $m->paramInt('auth');
$postId or $m->paramError($lng->{errPstIdMiss});

# Get post
my $post = $m->fetchHash("
	SELECT boardId, topicId FROM $cfg->{dbPrefix}posts WHERE id = $postId");
$post or $m->entryError($lng->{errPstNotFnd});

# Get board
my $board = $m->fetchHash("
	SELECT * FROM $cfg->{dbPrefix}boards WHERE id = $post->{boardId}");

# Check if user can see board
my $boardAdmin = $user->{admin} || $m->boardAdmin($userId, $board->{id});
$boardAdmin || $m->boardVisible($board) or $m->entryError($lng->{errPstNotFnd});

# Check if there's already an entry
my $entry = $m->fetchArray("
	SELECT userId FROM $cfg->{dbPrefix}postTodos WHERE userId = $userId AND postId = $postId");
!$entry or $m->userError($lng->{errTdoDupe});

# Process form
if ($submitted) {
	# Check request source authentication
	$sourceAuth == $user->{sourceAuth} or $m->formError($lng->{errSrcAuth});

	# Print form errors or finish action
	if (@{$m->{formErrors}}) { $m->printFormErrors() }
	else {
		# Add post to list
		$m->dbDo("
			INSERT INTO $cfg->{dbPrefix}postTodos (userId, postId) VALUES ($userId, $postId)");
		
		# Log action
		$m->logAction(1, 'todo', 'add', $userId, $board->{id}, $post->{topicId}, $postId);
		
		# Redirect back to topic
		$m->redirect('topic_show', tid => $post->{topicId}, pid => $postId, msg => 'PstAddTdo', 
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
	$m->printPageBar(mainTitle => $lng->{atdTitle}, navLinks => \@navLinks);

	# Print add to todo list form
	print
		"<form action='todo_add$m->{ext}' method='post'>\n",
		"<div class='frm'>\n",
		"<div class='hcl'>\n",
		"<span class='htt'>$lng->{atdTodoTtl}</span>\n",
		"</div>\n",
		"<div class='ccl'>\n",
		"$lng->{atdTodoT}<br/><br/>\n",
		$m->submitButton('atdTodoB', 'todo'),
		"<input type='hidden' name='pid' value='$postId'/>\n",
		$m->stdFormFields(),
		"</div>\n",
		"</div>\n",
		"</form>\n\n";

	# Log action
	$m->logAction(3, 'todo', 'add', $userId, $board->{id}, $post->{topicId}, $postId);

	# Print footer
	$m->printFooter();
}
