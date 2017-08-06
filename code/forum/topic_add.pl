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
$m->checkBan($userId);
$m->checkBlock();

# Load additional modules
require Forum::MwfCaptcha if $cfg->{captcha};

# Get CGI parameters
my $boardId = $m->paramInt('bid');
my $subject = $m->paramStr('subject');
my $body = $m->paramStr('body');
my $add = $m->paramBool('add');
my $preview = $m->paramBool('preview');
my $submitted = $m->paramBool('subm');
my $sourceAuth = $m->paramInt('auth');
$boardId or $m->paramError($lng->{errBrdIdMiss});

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

# Check if user is registered
$userId || $board->{unregistered} or $m->regError();

# Check if user has been registered for long enough
$m->{now} > $user->{regTime} + $cfg->{minRegTime}
	or $m->userError($m->formatStr($lng->{errMinRegTim}, { hours => $cfg->{minRegTime} / 3600 }))
	if $cfg->{minRegTime} && $userId;

# Check authorization
$m->checkAuthz($user, 'newTopic', board => $board);

# Check if user can see and write to board
my $boardAdmin = $user->{admin} || $m->boardAdmin($userId, $boardId);
my $boardMember = $m->boardMember($userId, $boardId);
$boardAdmin || $boardMember || $m->boardVisible($board) or $m->entryError($lng->{errBrdNotFnd});
$boardAdmin || $boardMember || $m->boardWritable($board) or $m->userError($lng->{errReadOnly});

# Process form
if ($add) {
	# Check request source authentication
	$sourceAuth == $user->{sourceAuth} or $m->formError($lng->{errSrcAuth});

	# Flood control
	if ($cfg->{repostTime} && !$boardAdmin) {
		my $lastPostTime = $m->fetchArray("
			SELECT MAX(postTime) FROM $cfg->{dbPrefix}posts WHERE userId = $userId");
		my $waitTime = $cfg->{repostTime} - ($m->{now} - $lastPostTime);
		my $errStr = $m->formatStr($lng->{errRepostTim}, { seconds => $waitTime });
		$waitTime < 1 or $m->formError($errStr);
	}

	# Check subject/body length
	length($subject) or $m->formError($lng->{errSubEmpty});
	length($subject) <= $cfg->{maxSubjectLen} or $m->formError($lng->{errSubLen});
	$subject =~ /\S/ or $m->formError($lng->{errSubNoText}) if length($subject);
	length($body) <= $cfg->{maxBodyLen} or $m->formError($lng->{errBdyLen});
	
	# Determine misc values
	my $anonOrUnreg = $board->{anonymous} || !$userId;
	my $approved = !$board->{approve} || $boardAdmin || ($board->{private} != 1 && $boardMember)
		? 1 : 0;
	my $userNameQ = $m->dbQuote($user->{userName});
	my $postUserId = $anonOrUnreg ? -1 : $userId;
	my $anonUserName = $cfg->{anonName} eq 'ip' 
		? "'$m->{env}{userIp}'" : $m->dbQuote($cfg->{anonName} || "?");
	my $postUserName = $anonOrUnreg ? $anonUserName : $userNameQ;
	
	# Translate text
	my $post = { subject => $subject, body => $body };
	$m->editToDb($board, $post);

	# Any text left after filtering?
	length($post->{body}) or $m->formError($lng->{errBdyEmpty});

	# Check captcha
	MwfCaptcha::checkCaptcha($m, 'pstCpt')
		if $cfg->{captcha} >= 3 || $cfg->{captcha} >= 2 && !$m->{user}{id};

	# Print form errors or finish action
	if (@{$m->{formErrors}}) { $m->printFormErrors() }
	else {
		# Check for dupe
		my $subjectQ = $m->dbQuote($post->{subject});
		my $bodyQ = $m->dbQuote($post->{body});
		!$m->fetchArray("
			SELECT id 
			FROM $cfg->{dbPrefix}posts 
			WHERE boardId = $boardId 
				AND userId = $userId 
				AND parentId = 0
				AND postTime > $m->{now} - 1000
				AND body = $bodyQ")
			or $m->userError($lng->{errDupe});
		
		# Transaction
		my $topicId = 0;
		my $postId = 0;
		$m->dbBegin();
		eval {
			# Insert topic
			$m->dbDo("
				INSERT INTO $cfg->{dbPrefix}topics (
					subject, boardId, locked, hitNum, postNum, lastPostTime
				) VALUES (
					$subjectQ, $boardId, 0, 1, 1, $m->{now}
				)");
			$topicId = $m->dbInsertId("$cfg->{dbPrefix}topics");
			
			# Insert post
			$m->dbDo("
				INSERT INTO $cfg->{dbPrefix}posts (
					userId, userNameBak, boardId, topicId, parentId,
					approved, ip, postTime, body
				) VALUES (
					$postUserId, $postUserName, $boardId, $topicId, 0,
					$approved, '$m->{env}{userIp}', $m->{now}, $bodyQ
				)");
			$postId = $m->dbInsertId("$cfg->{dbPrefix}posts");
		
			# Update topic's basePostId
			$m->dbDo("
				UPDATE $cfg->{dbPrefix}topics SET basePostId = $postId WHERE id = $topicId");
			
			# Update board stats
			$m->dbDo("
				UPDATE $cfg->{dbPrefix}boards SET 
					postNum = postNum + 1, 
					lastPostTime = $m->{now}
				WHERE id = $boardId");
		
			# Update user stats
			$m->dbDo("
				UPDATE $cfg->{dbPrefix}users SET postNum = postNum + 1 WHERE id = $userId")
				if !$board->{anonymous};
		};
		$@ ? $m->dbRollback() : $m->dbCommit();
		
		# Log action
		$m->logAction(1, 'topic', 'add', $userId, $boardId, $topicId, $postId);
		
		# Redirect back to topic
		$m->redirect('topic_show', tid => $topicId, msg => 'NewPost');
	}
}

# Print form
if (!$add || @{$m->{formErrors}}) {
	# Print header
	$m->printHeader();

	# Print page bar
	my @navLinks = ({ url => $m->url('board_show', bid => $boardId), txt => 'comUp', ico => 'up' });
	$m->printPageBar(mainTitle => $blog ? $lng->{ntpBlgTitle} : $lng->{ntpTitle}, 
		subTitle => $board->{title}, navLinks => \@navLinks);

	# Prepare preview body
	if ($preview) {
		$preview = { body => $body };
		$m->editToDb($board, $preview);
		$m->dbToDisplay($board, $preview);
	}

	# Prepare other values
	$subject = $m->escHtml($subject) if $subject;
	$body = $m->escHtml($body, 1) if $body;
	
	# Print new topic form
	print
		"<form action='topic_add$m->{ext}' method='post'>\n",
		"<div class='frm'>\n",
		"<div class='hcl'>\n",
		"<span class='htt'>$lng->{ntpTpcTtl}</span>\n",
		"</div>\n",
		"<div class='ccl'>\n",
		"$lng->{ntpTpcSbj}<br/>\n",
		"<input type='text' name='subject' size='60' maxlength='$cfg->{maxSubjectLen}'",
		" value='$subject'/><br/><br/>\n",
		"$lng->{ntpTpcBody}<br/>\n",
		$m->tagButtons(),
		"<textarea name='body' cols='80' rows='13'>$body</textarea><br/>\n",
		$cfg->{captcha} >= 3 || $cfg->{captcha} >= 2 && !$m->{user}{id} 
			? MwfCaptcha::captchaInputs($m, 'pstCpt') : "",
		"<br/>\n",
		$m->submitButton('ntpTpcB', 'write', 'add'),
		$m->submitButton('ntpTpcPrvB', 'preview', 'preview'),
		"<input type='hidden' name='bid' value='$boardId'/>\n",
		$m->stdFormFields(),
		"</div>\n",
		"</div>\n",
		"</form>\n\n";

	# Print preview
	print
		"<div class='frm'>\n",
		"<div class='hcl'>\n",
		"<span class='htt'>$lng->{ntpPrvTtl}</span>\n",
		"</div>\n",
		"<div class='ccl'>\n",
		$preview->{body}, "\n",
		"</div>\n",
		"</div>\n\n"
		if $preview;
	
	# Log action
	$m->logAction(3, 'topic', 'add', $userId, $boardId);
	
	# Print footer
	$m->printFooter();
}
