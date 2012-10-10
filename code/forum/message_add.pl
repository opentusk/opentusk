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

# Check if private messages are enabled
$cfg->{messages} or $m->userError($lng->{errFeatDisbl});

# Load additional modules
require Forum::MwfCaptcha if $cfg->{captcha};

# Check if user has been registered for long enough
$m->{now} > $user->{regTime} + $cfg->{minRegTime}
	or $m->userError($m->formatStr($lng->{errMinRegTim}, { hours => $cfg->{minRegTime} / 3600 }))
	if $cfg->{minRegTime};

# Get CGI parameters
my $recvId = $m->paramInt('uid');
my $recvName = $m->paramStr('recvName');
my $refMsgId = $m->paramInt('mid');
my $subject = $m->paramStr('subject');
my $body = $m->paramStr('body');
my $wantQuote = $m->paramBool('quote');
my $add = $m->paramBool('add');
my $preview = $m->paramBool('preview');
my $sourceAuth = $m->paramInt('auth');

# Get username from id or vice versa
if ($recvId) {
	$recvName = $m->fetchArray("
		SELECT userName FROM $cfg->{dbPrefix}users WHERE id = $recvId");
	$recvName or $m->formError($lng->{errUsrNotFnd});
}
else {
	my $recvNameQ = $m->dbQuote($recvName);
	$recvId = $m->fetchArray("
		SELECT id FROM $cfg->{dbPrefix}users WHERE userName = $recvNameQ");
	$recvId or $m->formError($lng->{errUsrNotFnd});
}

# Fake board
my $board = { flat => 1 };

# Get referenced message
my $refMsg = undef;
my $refSubject = undef;
if ($refMsgId) {
	$refMsg = $m->fetchHash("
		SELECT * FROM $cfg->{dbPrefix}messages WHERE id = $refMsgId");
	$refMsg or $m->entryError($lng->{errMsgNotFnd});
	$refMsg->{receiverId} == $userId or $m->entryError($lng->{errMsgNotFnd});
	$recvId ||= $refMsg->{senderId};
	$refSubject = $refMsg->{subject} =~ /Re:/ ? $refMsg->{subject} : "Re: $refMsg->{subject}";
	$refSubject = substr($refSubject, 0, $cfg->{maxSubjectLen});
}

# Process form
if ($add) {
	# Check request source authentication
	$sourceAuth == $user->{sourceAuth} or $m->formError($lng->{errSrcAuth});

	# Flood control
	if ($cfg->{repostTime} && !$user->{admin}) {
		my $lastPostTime = $m->fetchArray("
			SELECT MAX(sendTime) FROM $cfg->{dbPrefix}messages WHERE senderId = $userId");
		my $waitTime = $cfg->{repostTime} - ($m->{now} - $lastPostTime);
		my $errStr = $m->formatStr($lng->{errRepostTim}, { seconds => $waitTime });
		$waitTime < 1 or $m->formError($errStr);
	}
	
	# Check subject/body length
	length($subject) or $m->formError($lng->{errSubEmpty});
	length($subject) <= $cfg->{maxSubjectLen} or $m->formError($lng->{errSubLen});
	$subject =~ /\S/ or $m->formError($lng->{errSubNoText}) if length($subject);
	length($body) <= $cfg->{maxBodyLen} or $m->formError($lng->{errBdyLen});
	
	# Translate text
	my $msg = { isMessage => 1, subject => $subject, body => $body };
	$m->editToDb($board, $msg);
	
	# Any text left after filtering?
	length($body) or $m->formError($lng->{errBdyEmpty});

	# Check captcha
	MwfCaptcha::checkCaptcha($m, 'msgCpt') if $cfg->{captcha} >= 3;

	# Print form errors or finish action
	if (@{$m->{formErrors}}) { $m->printFormErrors() }
	else {
		# Check if recipient ignores sender
		my $ignored = $m->fetchArray("
			SELECT 1
			FROM $cfg->{dbPrefix}userIgnores 
			WHERE userId = $recvId 
				AND ignoredId = $userId");

		# Quote strings
		my $subjectQ = $m->dbQuote($msg->{subject});
		my $bodyQ = $m->dbQuote($msg->{body});
		
		# Insert message
		my $inbox = $ignored ? 0 : 1;
		$m->dbDo("
			INSERT INTO $cfg->{dbPrefix}messages (
				senderId, receiverId, sendTime, inbox, sentbox, subject, body
			) VALUES (
				$userId, $recvId, $m->{now}, $inbox, 1, $subjectQ, $bodyQ
			)");
		my $msgId = $m->dbInsertId("$cfg->{dbPrefix}messages");

		# Update referenced message status
		$m->dbDo("
			UPDATE $cfg->{dbPrefix}messages SET hasRead = 2 WHERE id = $refMsgId") 
			if $refMsgId && $refMsg->{hasRead} < 2;
			
		# Get receiver
		my $recv = $m->getUser($recvId);
		if (!$ignored) {
			# Add notification message
			my $url = "message_show$m->{ext}?mid=$msgId";
			$m->addNote($recv->{id}, 'notMsgAdd', usrNam => $user->{userName}, msgUrl => $url);
			
			# Send notification email
			if ($recv->{msgNotify} && $recv->{email} && !$recv->{dontEmail}) {
				my $absUrl = $cfg->{baseUrl};
				$absUrl =~ s!http://!https://! if $recv->{secureLogin};
				$absUrl = "$absUrl$m->{env}{scriptUrlPath}/$url";
				$m->sendEmail($m->createEmail(
					type     => 'msgNtf',
					user     => $recv,
					sendUser => $user,
					board    => $board,
					msg      => $msg,
					url      => $absUrl));
			}
		}
		
		# Log action
		$m->logAction(1, 'msg', 'add', $userId, 0, 0, 0, $msgId);
		
		# Redirect back to message list
		$m->redirect('message_list', msg => 'MsgAdd');
	}
}

# Print form
if (!$add || @{$m->{formErrors}}) {
	# Print header
	$m->printHeader();

	# Get recipient's username
	if ($recvId) {
		$recvName = $m->fetchArray("
			SELECT userName FROM $cfg->{dbPrefix}users WHERE id = $recvId");
		length($recvName) or $m->entryError($lng->{errUsrNotFnd});
	}
	
	# Print page bar
	my @navLinks = ({ url => $m->url('message_list'), txt => 'comUp', ico => 'up' });
	$m->printPageBar(mainTitle => $lng->{msaTitle}, navLinks => \@navLinks);
	
	# Quote message body
	my $quote = undef;
	if ($refMsg && $wantQuote && $cfg->{quote} && eval { require Text::Flowed }) {
		$quote = $refMsg->{body};
		$quote =~ s!<br/>!\n!g;  # Preserve linebreaks before removing tags
		$quote =~ s!<.+?>!!g;  # Remove tags before quoting
		$quote = $m->deescHtml($quote);
		$quote = Text::Flowed::reformat($quote, { quote => 1, fixed => 1,
			max_length => $cfg->{quoteCols}, opt_length => $cfg->{quoteCols} - 6 });
	}

	# Prepare preview body
	if ($preview) {
		$preview = { isMessage => 1, body => $body };
		$m->editToDb($board, $preview);
		$m->dbToDisplay($board, $preview);
	}

	# Prepare other values
	$recvName = $m->escHtml($recvName) if $recvName;
	$subject = $m->escHtml($subject) if $subject;
	$subject ||= $refSubject;
	$body ||= $quote;
	$body = $m->escHtml($body, 1) if $body;
	$m->dbToDisplay($board, $refMsg) if $refMsg;
	
	# Print message form
	print
		"<form action='message_add$m->{ext}' method='post'>\n",
		"<div class='frm'>\n",
		"<div class='hcl'>\n",
		"<span class='htt'>$lng->{msaSendTtl}</span>\n",
		"</div>\n",
		"<div class='ccl'>\n",
		"$lng->{msaSendRecv}<br/>\n";

	my $userNum = $m->fetchArray("
		SELECT COUNT(*) FROM $cfg->{dbPrefix}users");
	if ($userNum > $cfg->{maxListUsers}) {
		print "<input type='text' name='recvName' size='20' value='$recvName'/><br/>\n";
	}
	else {
		my $users = $m->fetchAllArray("
			SELECT id, userName FROM $cfg->{dbPrefix}users ORDER BY userName");
		print "<select name='uid' size='1'>\n";
		for my $listUser (@$users) {
			my $sel = $listUser->[1] eq $recvName ? "selected='selected'" : "";
			print "<option value='$listUser->[0]' $sel>$listUser->[1]</option>\n";
		}
		print "</select><br/>\n";
	}
	
	print
		"$lng->{msaSendSbj}<br/>\n",
		"<input type='text' name='subject' size='80' maxlength='$cfg->{maxSubjectLen}'",
		" value='$subject'/><br/><br/>\n",
		"$lng->{msaSendTxt}<br/>\n",
		$m->tagButtons(),
		"<textarea name='body' cols='80' rows='13'>$body</textarea><br/>\n",
		$cfg->{captcha} >= 3 ? MwfCaptcha::captchaInputs($m, 'msgCpt') : "",
		"<br/>\n",
		$m->submitButton('msaSendB', 'write', 'add'),
		$m->submitButton('msaSendPrvB', 'preview', 'preview'),
		"<input type='hidden' name='mid' value='$refMsgId'/>\n",
		$m->stdFormFields(),
		"</div>\n",
		"</div>\n",
		"</form>\n\n";

	# Print preview
	print
		"<div class='frm'>\n",
		"<div class='hcl'>\n",
		"<span class='htt'>$lng->{msaPrvTtl}</span>\n",
		"</div>\n",
		"<div class='ccl'>\n",
		$preview->{body}, "\n",
		"</div>\n",
		"</div>\n\n"
		if $preview;
	
	# Print referenced message
	print
		"<div class='frm msg'>\n",
		"<div class='hcl'>\n",
		"<span class='htt'>$lng->{msaRefTtl}</span> $recvName\n",
		"</div>\n",
		"<div class='ccl'>\n",
		"$refMsg->{body}\n",
		"</div>\n",
		"</div>\n\n"
		if $refMsgId;
	
	# Log action
	$m->logAction(3, 'msg', 'add', $userId, 0, 0, 0, $recvId);
	
	# Print footer
	$m->printFooter();
}
