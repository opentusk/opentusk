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
$m->checkBan($userId);
$m->checkBlock();

# Load additional modules
require Forum::MwfCaptcha if $cfg->{captcha};

# Get CGI parameters
my $parentId = $m->paramInt('pid');
my $body = $m->paramStr('body');
my $wantQuote = $m->paramBool('quote');
my $add = $m->paramBool('add');
my $preview = $m->paramBool('preview');
my $submitted = $m->paramBool('subm');
my $sourceAuth = $m->paramInt('auth');
$parentId or $m->paramError($lng->{errPrtIdMiss});

# Get parent post
my $parent = $m->fetchHash("
	SELECT * FROM $cfg->{dbPrefix}posts WHERE id = $parentId");
$parent or $m->entryError($lng->{errPrtNotFnd});
my $boardId = $parent->{boardId};
my $topicId = $parent->{topicId};

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

# Check if user can see and write to board
my $boardAdmin = $user->{admin} || $m->boardAdmin($userId, $boardId);
my $boardMember = $m->boardMember($userId, $boardId);
$boardAdmin || $boardMember || $m->boardVisible($board) or $m->entryError($lng->{errBrdNotFnd});
$boardAdmin || $boardMember || $m->boardWritable($board, 1) or $m->userError($lng->{errReadOnly});

# Check if user is registered
$userId || $board->{unregistered} or $m->regError();

# Check if user has been registered for long enough
$m->{now} > $user->{regTime} + $cfg->{minRegTime}
	or $m->userError($m->formatStr($lng->{errMinRegTim}, { hours => $cfg->{minRegTime} / 3600 }))
	if $cfg->{minRegTime} && $userId;

# Check if topic is locked
!$topic->{locked} || $boardAdmin or $m->userError($lng->{errTpcLocked});

# Check authorization
$m->checkAuthz($user, 'newPost', parent => $parent, topic => $topic, board => $board);

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

	# Check body length
	length($body) <= $cfg->{maxBodyLen} or $m->formError($lng->{errBdyLen});
	
	# Determine misc values
	my $anonOrUnreg = $board->{anonymous} || !$userId;
	my $approved = !$board->{approve} || $boardAdmin || ($boardMember && $board->{private} != 1) 
		? 1 : 0;
	my $postUserId = $anonOrUnreg ? -1 : $userId;
	my $anonUserName = $cfg->{anonName} eq 'ip' ? "$m->{env}{userIp}" : $cfg->{anonName} || "?";
	my $postUserName = $anonOrUnreg ? $anonUserName : $user->{userName};
	my $postUserNameQ = $m->dbQuote($postUserName);
	
	# Process text
	my $post = { body => $body };
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
		my $bodyQ = $m->dbQuote($post->{body});
		!$m->fetchArray(" 
			SELECT id 
			FROM $cfg->{dbPrefix}posts 
			WHERE parentId = $parentId 
				AND userId = $userId 
				AND body = $bodyQ")
			or $m->userError($lng->{errDupe});
		
		# Set parentId to basePostId in non-threaded boards
		my $insertParentId = $board->{flat} ? $topic->{basePostId} : $parentId;
		
		# Transaction
		my $postId = undef;
		$m->dbBegin();
		eval {
			# Insert post
			$m->dbDo("
				INSERT INTO $cfg->{dbPrefix}posts (
					userId, userNameBak, boardId, topicId, parentId, 
					approved, ip, postTime, body
				) VALUES (
					$postUserId, $postUserNameQ, $boardId, $topicId, $insertParentId,
					$approved, '$m->{env}{userIp}', $m->{now}, $bodyQ
				)");
			$postId = $m->dbInsertId("$cfg->{dbPrefix}posts");
			
			# Mark read if there haven't been other new posts in the meantime
			my $topicReadTime = $m->fetchArray("
				SELECT lastReadTime 
				FROM $cfg->{dbPrefix}topicReadTimes 
				WHERE userId = $userId 
					AND topicId = $topicId");
			my $lowestUnreadTime = $m->max($topicReadTime, $user->{fakeReadTime}, 
				$m->{now} - $cfg->{maxUnreadDays} * 86400);		
			my $allRead = $m->fetchArray("
				SELECT lastPostTime <= $lowestUnreadTime 
				FROM $cfg->{dbPrefix}topics 
				WHERE id = $topicId");
			if ($allRead) {
				$m->dbDo("
					DELETE FROM $cfg->{dbPrefix}topicReadTimes
					WHERE userId = $userId
						AND topicId = $topicId");
				$m->dbDo("
					INSERT INTO $cfg->{dbPrefix}topicReadTimes (userId, topicId, lastReadTime)
					VALUES ($userId, $topicId, $m->{now} + 1)");
			}
			
			# Update board/topic stats
			$m->dbDo("
				UPDATE $cfg->{dbPrefix}topics SET 
					postNum = postNum + 1, 
					lastPostTime = $m->{now}
				WHERE id = $topicId");
			$m->dbDo("
				UPDATE $cfg->{dbPrefix}boards SET 
					postNum = postNum + 1, 
					lastPostTime = $m->{now}
				WHERE id = $boardId");
			
			# Update user stats
			$m->dbDo("
				UPDATE $cfg->{dbPrefix}users SET postNum = postNum + 1 WHERE id = $userId")
				if !$board->{anonymous};
			
			# Remove parent post from user's todo list
			$m->dbDo("
				DELETE FROM $cfg->{dbPrefix}postTodos	WHERE userId = $userId AND postId = $parentId");
		};
		$@ ? $m->dbRollback() : $m->dbCommit();

		# Notifications
		my $recv = $m->getUser($parent->{userId});
		if ($recv && $recv->{notify} && $recv->{id} != $userId) {
			# Check whether receiver ignores poster				
			my $ignored = $m->fetchArray("
				SELECT 1 
				FROM $cfg->{dbPrefix}userIgnores
				WHERE userId = $recv->{id}
					AND ignoredId = $userId");

			# If receiver doesn't ignore user and can still see board
			if (!$ignored && $m->boardVisible($board, $recv)) {
				# Add notification message
				my $url = "topic_show$m->{ext}?pid=$postId#pid$postId";
				$m->addNote($recv->{id}, 'notPstAdd', usrNam => $postUserName, pstUrl => $url);
			
				# Send notification email
				if ($recv->{msgNotify} && $recv->{email} && !$recv->{dontEmail}) {
					my $absUrl = $cfg->{baseUrl};
					$absUrl =~ s!http://!https://! if $recv->{secureLogin};
					$absUrl = "$absUrl$m->{env}{scriptUrlPath}/$url";
					$m->sendEmail($m->createEmail(
						type     => 'replyNtf',
						user     => $recv,
						replUser => $user,
						board    => $board,
						topic    => $topic,
						parent   => $parent,
						post     => $post,
						url      => $absUrl));
				}
			}
		}
		
		# Log action
		$m->logAction(1, 'post', 'add', $userId, $boardId, $topicId, $postId, $parentId);
		
		# Redirect back to topic
		$m->redirect('topic_show', tid => $topicId, pid => $postId, msg => 'ReplyPost', 
			tgt => "pid$postId");
	}
}

# Print form
if (!$add || @{$m->{formErrors}}) {
	# Print header
	$m->printHeader();
	
	# Print bar
	my @navLinks = ({ 
		url => $m->url('topic_show', tid => $topicId, pid => $parentId, tgt => "pid$parentId"), 
		txt => 'comUp', ico => 'up' });
	$m->printPageBar(mainTitle => $blog ? $lng->{rplBlgTitle} : $lng->{rplTitle}, 
		subTitle => $topic->{subject}, navLinks => \@navLinks);
	
	# Check if user started topic
	my $basePostUserId = $m->fetchArray("
		SELECT userId FROM $cfg->{dbPrefix}posts WHERE id = $topic->{basePostId}");
	my $usersTopic = $basePostUserId == $userId;
	
	# Quote parent post body
	my $quote = undef;
	if ($cfg->{quote} && $wantQuote	&& ($board->{flat} || $cfg->{quote} == 2)
		&& eval { require Text::Flowed }) {

		# Prepare quote
		$quote = $parent->{body};
		$quote =~ s!<blockquote>.+?</blockquote>(?:<br/>)?!!g;
		$quote =~ s!<br/>!\n!g;  # Preserve linebreaks before removing tags
		$quote =~ s!<.+?>!!g;  # Remove tags before quoting
		$quote = $m->deescHtml($quote);
		$quote = Text::Flowed::reformat($quote, { quote => 1, fixed => 1,
			max_length => $cfg->{quoteCols}, opt_length => $cfg->{quoteCols} - 6});

		# Prefix "user:" to quote
		if ($cfg->{quotePrefix} && !$board->{anonymous}) {
			$quote = "$parent->{userNameBak}:\n$quote";
		}
	}

	# Prepare preview body
	if ($preview) {
		$preview = { body => $body };
		$m->editToDb($board, $preview);
		$m->dbToDisplay($board, $preview);
	}

	# Prepare other values
	$body ||= $quote;
	$body = $m->escHtml($body, 1) if $body;
	$m->dbToDisplay($board, $parent);

	# Print reply form
	print
		"<form action='post_add$m->{ext}' method='post'>\n",
		"<div class='frm'>\n",
		"<div class='hcl'>\n",
		"<span class='htt'>$lng->{rplReplyTtl}</span>\n",
		"</div>\n",
		"<div class='ccl'>\n",
		"$lng->{rplReplyBody}<br/>\n",
		$m->tagButtons(),
  	"<textarea name='body' cols='80' rows='13'>$body</textarea><br/>\n",
		$cfg->{captcha} >= 3 || $cfg->{captcha} >= 2 && !$m->{user}{id} 
			? MwfCaptcha::captchaInputs($m, 'pstCpt') : "",
		"<br/>\n",
		$m->submitButton('rplReplyB', 'write', 'add'),
		$m->submitButton('rplReplyPrvB', 'preview', 'preview'),
		"<input type='hidden' name='pid' value='$parentId'/>\n",
		$m->stdFormFields(),
		"</div>\n",
		"</div>\n",
		"</form>\n\n";
	
	# Print preview
	print
		"<div class='frm'>\n",
		"<div class='hcl'>\n",
		"<span class='htt'>$lng->{rplPrvTtl}</span>\n",
		"</div>\n",
		"<div class='ccl'>\n",
		$preview->{body}, "\n",
		"</div>\n",
		"</div>\n\n"
		if $preview;

	# Print parent post
	print
		"<div class='frm'>\n",
		"<div class='hcl'>\n",
		"<span class='htt'>$lng->{rplReplyResp}</span> $parent->{userNameBak}\n",
		"</div>\n",
		"<div class='ccl'>\n",
		$parent->{body}, "\n",
		"</div>\n",
		"</div>\n\n";
	
	# Log action
	$m->logAction(3, 'post', 'add', $userId, $boardId, $topicId, 0, $parentId);
	
	# Print footer
	$m->printFooter();
}
