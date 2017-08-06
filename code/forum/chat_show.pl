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
$m->checkBan($userId) if $cfg->{banViewing};
$m->checkBlock();

# Check if chat is enabled
$cfg->{chat} or $m->userError($lng->{errFeatDisbl});

# Check if only registered users are allowed
$cfg->{chat} != 2 || $userId or $m->regError();

# Print header
$m->printHeader();

# Print page bar
my @navLinks = ({ url => $m->url('forum_show'), txt => 'comUp', ico => 'up' });
my @userLinks = ();
push @userLinks, { url => $m->url('chat_show', r => int(rand(9999999))),
	txt => 'chtRefresh', ico => 'refresh' };
push @userLinks, { url => $m->url('user_confirm', script => 'chat_delete', act => 'all'), 
	txt => 'chtDelAll', ico => 'delete' } 
	if $user->{admin};
$m->printPageBar(mainTitle => $lng->{chtTitle}, navLinks => \@navLinks, userLinks => \@userLinks);

# Get chat messages
my $chatReadTime = $user->{chatReadTime} || 2147483647;
my $chats = $m->fetchAllHash("
	SELECT chat.*, 
		chat.postTime > $chatReadTime AS unread,
		users.userName
	FROM $cfg->{dbPrefix}chat AS chat
		INNER JOIN $cfg->{dbPrefix}users AS users
			ON users.id = chat.userId
	ORDER BY chat.id DESC
	LIMIT $cfg->{chatMaxMsgs}");

# Print chat input field
print 
	"<form action='chat_add$m->{ext}' method='post'>\n",
	"<div class='frm'>\n",
	"<div class='hcl'>\n",
	"<span class='htt'>$lng->{chtAddTtl}</span>\n",
	"</div>\n",
	"<div class='ccl'>\n",
	"<textarea name='body' cols='80' rows='2'></textarea><br/>\n",
	$m->submitButton('chtAddB', 'write'),
	$m->stdFormFields(),
	"</div>\n",
	"</div>\n",
	"</form>\n\n",
	if $userId;

# Print chat messages
print
	"<div class='frm'>\n",
	"<div class='hcl'>\n",
	"<span class='htt'>$lng->{chtMsgsTtl}</span>\n",
	"</div>\n";

for my $chat (@$chats) {
	# Format output
	my $url = $m->url('user_info', uid => $chat->{userId});
	my $userNameStr = "<a href='$url'>$chat->{userName}</a>";
	my $shortTimeStr = $m->formatTime($chat->{postTime}, $user->{timezone}, "%H:%M");
	$shortTimeStr = "<b>$shortTimeStr</b>" if $chat->{unread};
	
	print 
		"<div class='ccl'>\n",
		"$userNameStr $shortTimeStr&gt; ", $chat->{body}, "\n",
		"</div>\n";
}

print	"</div>\n\n";
	
# Log action
$m->logAction(2, 'chat', 'show', $userId);

# Print footer
$m->printFooter();
