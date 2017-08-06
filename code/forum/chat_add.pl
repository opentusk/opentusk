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

# Check if chat is enabled
$cfg->{chat} or $m->userError($lng->{errFeatDisbl});

# Get CGI parameters
my $parentId = $m->paramInt('pid');
my $body = $m->paramStr('body');
my $sourceAuth = $m->paramInt('auth');

# Fake board
my $board = { flat => 1 };

# Check request source authentication
$sourceAuth == $user->{sourceAuth} or $m->paramError($lng->{errSrcAuth});

# Check body length
length($body) or $m->userError($lng->{errBdyEmpty});
length($body) <= $cfg->{chatMaxLength} or $m->userError($lng->{errBdyLen});

# Process text
my $chat = { isChat => 1, body => $body };
$m->editToDb($board, $chat);

# Any text left after filtering?
length($chat->{body}) or $m->userError($lng->{errBdyEmpty});

# Quote strings
my $bodyQ = $m->dbQuote($chat->{body});

# Insert chat message
$m->dbDo("
	INSERT INTO $cfg->{dbPrefix}chat (userId, postTime, body)
	VALUES ($userId, $m->{now}, $bodyQ)");
my $chatId = $m->dbInsertId("$cfg->{dbPrefix}chat");

# Expire old messages
$m->dbDo("
	DELETE FROM $cfg->{dbPrefix}chat WHERE postTime < $m->{now} - $cfg->{chatMaxAge} * 86400")
	if $cfg->{chatMaxAge};

# Log action
$m->logAction(1, 'chat', 'add', $userId, 0, 0, 0, $chatId);

# Redirect back to chat page
$m->redirect('chat_show', msg => 'ChatAdd');
