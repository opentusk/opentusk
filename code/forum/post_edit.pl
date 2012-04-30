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
my $postId = $m->paramInt('pid');
my $subject = $m->paramStr('subject');
my $body = $m->paramStr('body');
my $notify = $m->paramBool('notify');
my $reason = $m->paramStr('reason');
my $submitted = $m->paramBool('subm');
my $sourceAuth = $m->paramInt('auth');
$postId or $m->paramError($lng->{errPstIdMiss});

# Get post
my $post = $m->fetchHash("
	SELECT * FROM $cfg->{dbPrefix}posts WHERE id = $postId");
$post or $m->entryError($lng->{errPstNotFnd});
my $boardId = $post->{boardId};
my $topicId = $post->{topicId};

# Is this a blog topic?
my $blog = $cfg->{blogs} && $boardId < 0 ? 1 : 0;
my $blogger = $blog ? $m->getUser(abs($boardId)) : undef;

# Get board
my $board = undef;
if ($blog) { $board = $m->getBlogBoard($blogger) }
else {
	$board = $m->fetchHash("
		SELECT * FROM $cfg->{dbPrefix}boards WHERE id = $boardId");
	$board or $m->entryError($lng->{errBrdNotFnd});
}

# Get topic
my $topic = $m->fetchHash("
	SELECT * FROM $cfg->{dbPrefix}topics WHERE id = $topicId");

# Check authorization
$m->checkAuthz($user, 'editPost', post => $post, topic => $topic, board => $board);

# Check if user is allowed to edit post
my $boardAdmin = $user->{admin} || $m->boardAdmin($userId, $boardId);
$userId == $post->{userId} || $boardAdmin or $m->userError($lng->{errCheat});

# Don't allow editing of approved posts in moderated boards
my $boardMember = $m->boardMember($userId, $boardId);
!$board->{approve} || !$post->{approved} || $boardAdmin || ($boardMember && $board->{private} != 1)
	or $m->userError($lng->{errEditAppr});

# Check editing time limitation
!$cfg->{postEditTime} || time() < $post->{postTime} + $cfg->{postEditTime} 
	|| $boardAdmin || $boardMember
	or $m->userError($lng->{errPstEdtTme});

# Check if topic is locked
!$topic->{locked} || $boardAdmin or $m->userError($lng->{errTpcLocked});

# Process form
if ($submitted) {
	# Check request source authentication
	$sourceAuth == $user->{sourceAuth} or $m->formError($lng->{errSrcAuth});

	# Check subject/body length
	if (!$post->{parentId}) {
		length($subject) or $m->formError($lng->{errSubEmpty});
		length($subject) <= $cfg->{maxSubjectLen} or $m->formError($lng->{errSubLen});
		$subject =~ /\S/ or $m->formError($lng->{errSubNoText}) if length($subject);
	}
	length($body) or $m->formError($lng->{errBdyEmpty});
	length($body) <= $cfg->{maxBodyLen} or $m->formError($lng->{errBdyLen});

	# Print form errors or finish action
	if (@{$m->{formErrors}}) { $m->printFormErrors() }
	else {
		# Translate text
		my $oldBody = $post->{body};
		$post->{subject} = $subject;
		$post->{body} = $body;
		$m->editToDb($board, $post);

		# Only set editTime if there's 2min between post and edit and body changed
		my $editTimeStr = ($m->{now} - $post->{postTime} > 120) && ($oldBody ne $post->{body})
			? "editTime = $m->{now}," : "";
		
		# Quote strings
		my $subjectQ = $m->dbQuote($post->{subject}) if !$post->{parentId};
		my $bodyQ = $m->dbQuote($post->{body});
		
		# Transaction
		$m->dbBegin();
		eval {
			# Update post
			$m->dbDo("
				UPDATE $cfg->{dbPrefix}posts SET 
					$editTimeStr
					body = $bodyQ
				WHERE id = $postId")
				if $post->{userId} != -2;
			
			# Update topic subject if first post
			$m->dbDo("
				UPDATE $cfg->{dbPrefix}topics SET 
					subject = $subjectQ 
				WHERE id = $topicId")
				if !$post->{parentId};
		};
		$@ ? $m->dbRollback() : $m->dbCommit();

		# Add notification message
		if ($notify && $post->{userId} && $post->{userId} != $userId) {
			my $url = "topic_show$m->{ext}?pid=$postId";
			$m->addNote($post->{userId}, 'notPstEdt', pstUrl => $url, reason => $reason);
		}

		# Log action
		$m->logAction(1, 'post', 'edit', $userId, $boardId, $topicId, $postId);
		
		# Redirect back to topic
		$m->redirect('topic_show', tid => $topicId, pid => $postId, msg => 'PstChange', 
			tgt => "pid$postId");
	}
}

# Print form
if (!$submitted || @{$m->{formErrors}}) {
	# Print header
	$m->printHeader();

	# Prepare subject
	$subject = $m->escHtml($subject) if $subject;
	$subject ||= $topic->{subject};

	# Prepare body
	if ($body) { $body = $m->escHtml($body, 1) }
	else { $m->dbToEdit($board, $post) }
	$body ||= $post->{body};

	# Print bar
	my @navLinks = ({ 
		url => $m->url('topic_show', tid => $topicId, pid => $postId, tgt => "pid$postId"), 
		txt => 'comUp', ico => 'up' });
	$m->printPageBar(mainTitle => $lng->{eptTitle}, navLinks => \@navLinks);
	
	# Print edit post form
	print
		"<form action='post_edit$m->{ext}' method='post'>\n",
		"<div class='frm'>\n",
		"<div class='hcl'>\n",
		"<span class='htt'>$lng->{eptEditTtl}</span>\n",
		"</div>\n",
		"<div class='ccl'>\n";

	# Print subject textfield
	print	
		"$lng->{eptEditSbj}<br/>\n",
		"<input type='text' name='subject' size='60' maxlength='$cfg->{maxSubjectLen}'",
		" value='$subject'/><br/><br/>\n"
		if !$post->{parentId};

	# Print textfield
	print	
		"$lng->{eptEditBody}<br/>\n",
		$m->tagButtons(),
		"<textarea name='body' cols='80' rows='13'>$body</textarea><br/><br/>\n";

	# Print notification checkbox
	my $checked = $cfg->{noteDefMod} ? "checked='checked'" : "";
	print		
		"<label><input type='checkbox' name='notify' $checked/>$lng->{notNotify}</label><br/>\n",
		"<input type='text' name='reason' size='80'/><br/><br/>\n"
		if $post->{userId} > 0 && $post->{userId} != $userId;

	print
		$m->submitButton('eptEditB', 'edit'),
		"<input type='hidden' name='pid' value='$postId'/>\n",
		$m->stdFormFields(),
		"</div>\n",
		"</div>\n",
		"</form>\n\n";
	
	# Log action
	$m->logAction(3, 'post', 'edit', $userId, $boardId, $topicId, $postId);
	
	# Print footer
	$m->printFooter();
}
