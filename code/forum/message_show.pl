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
$m->checkBan($userId) if $cfg->{banViewing};
$m->checkBlock();

# Print header
$m->printHeader();

# Check if private messages are enabled
$cfg->{messages} or $m->userError($lng->{errFeatDisbl});

# Get CGI parameters
my $msgId = $m->paramInt('mid');
$msgId or $m->paramError($lng->{errMsgIdMiss});

# Print bar
my @navLinks = ({ url => $m->url('message_list'), txt => 'comUp', ico => 'up' });
$m->printPageBar(mainTitle => $lng->{mssTitle}, navLinks => \@navLinks);

# Fake board
my $board = { flat => 1 };

# Get message
my ($sent, $received) = $m->fetchArray("
	SELECT senderId = $userId, receiverId = $userId
	FROM $cfg->{dbPrefix}messages 
	WHERE id = $msgId");
my $joinUserId = $sent ? 'receiverId' : 'senderId';
my $msg = $m->fetchHash("
	SELECT messages.*, messages.sendTime > $user->{prevOnTime} AS new,
		users.id AS userId, users.userName, users.title AS userTitle
	FROM $cfg->{dbPrefix}messages AS messages
		INNER JOIN $cfg->{dbPrefix}users AS users
			ON users.id = messages.$joinUserId
	WHERE messages.id = $msgId");

# Check if user can see message
$received && $msg->{inbox} || $sent && $msg->{sentbox}
	or $m->entryError($lng->{errMsgNotFnd});

# Determine message icon attributes
my $imgSrc; 
my $imgTitle = "";
my $imgAlt = "";
if ($received) { 
	if ($msg->{hasRead} == 2) { 
		$imgSrc = "post_a"; $imgTitle = $lng->{comAnswerTT}; $imgAlt = $lng->{comAnswer};
	}
	elsif ($msg->{new} && !$msg->{hasRead}) { 
		$imgSrc = "post_nu"; $imgTitle = $lng->{comNewUnrdTT}; $imgAlt = $lng->{comNewUnrd};
	}
	elsif ($msg->{new}) { 
		$imgSrc = "post_nr"; $imgTitle = $lng->{comNewReadTT}; $imgAlt = $lng->{comNewRead};
	}
	elsif (!$msg->{hasRead}) { 
		$imgSrc = "post_ou"; $imgTitle = $lng->{comOldUnrdTT}; $imgAlt = $lng->{comOldUnrd};
	}
	else { 
		$imgSrc = "post_or"; $imgTitle = $lng->{comOldReadTT}; $imgAlt = $lng->{comOldRead};
	}
}
else {
	if ($msg->{new}) { 
		$imgSrc = "post_nr"; $imgTitle = $lng->{comNewReadTT}; $imgAlt = $lng->{comNewRead};
	}
	else { 
		$imgSrc = "post_or"; $imgTitle = $lng->{comOldReadTT}; $imgAlt = $lng->{comOldRead};
	}
}
my $imgAttr = "src='$m->{stylePath}/$imgSrc.png' title='$imgTitle' alt='$imgAlt'";

# Format output
my $infUrl = $m->url('user_info', uid => $msg->{userId});
my $addUrl = $m->url('message_add', mid => $msgId);
my $qotUrl = $m->url('message_add', mid => $msgId, quote => 1);
my $delUrl = $m->url('user_confirm', mid => $msgId, script => 'message_delete', 
	name => $msg->{subject});
my $userNameStr = "<a href='$infUrl'>$msg->{userName}</a>";
$userNameStr .= " " . $m->formatUserTitle($msg->{userTitle}) 
	if $msg->{userTitle} && $user->{showDeco};
my $sendTimeStr = $m->formatTime($msg->{sendTime}, $user->{timezone});
$m->dbToDisplay($board, $msg);
my $canQuote = $cfg->{quote} && eval { require Text::Flowed };
my $toFrom = $sent ? $lng->{mssTo} : $lng->{mssFrom};

# Print message form
print
	"<div class='frm msg'>\n",
	"<div class='hcl'>\n",
	"<img class='ico' $imgAttr/>\n",
	"<span class='htt'>$toFrom</span> $userNameStr\n",
	"<span class='htt'>$lng->{mssDate}</span> $sendTimeStr\n",
	"<span class='htt'>$lng->{mssSubject}</span> $msg->{subject}\n",
	"</div>\n",
	"<div class='ccl'>\n",
	"$msg->{body}\n",
	"</div>\n",
	"<div class='bcl'>\n",
	$received ? $m->buttonLink($addUrl, 'mssReply', 'write') : "",
	$received && $canQuote ? $m->buttonLink($qotUrl, 'mssQuote', 'write') : "",
	$m->buttonLink($delUrl, 'mssDelete', 'delete'),
	"</div>\n",
	"</div>\n\n";
	
# Update message status
$m->dbDo("
	UPDATE $cfg->{dbPrefix}messages SET hasRead = 1 WHERE id = $msgId") 
	if $received && !$msg->{hasRead};

# Log action
$m->logAction(2, 'msg', 'show', $userId, 0, 0, 0, $msgId);

# Print footer
$m->printFooter();
