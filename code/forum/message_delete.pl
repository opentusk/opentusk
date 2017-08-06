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

# Check if private messages are enabled
$cfg->{messages} or $m->userError($lng->{errFeatDisbl});

# Get CGI parameters
my $action = $m->paramStrId('act');
my $msgId = $m->paramInt('mid');
my $sourceAuth = $m->paramInt('auth');

# Check request source authentication
$sourceAuth == $user->{sourceAuth} or $m->paramError($lng->{errSrcAuth});

if ($action eq 'allread') {
	# Delete all read messages
	$m->dbDo("
		UPDATE $cfg->{dbPrefix}messages SET inbox = 0 WHERE receiverId = $userId AND hasRead");
	$m->dbDo("
		UPDATE $cfg->{dbPrefix}messages SET sentbox = 0 WHERE senderId = $userId");
	$m->dbDo("
		DELETE FROM $cfg->{dbPrefix}messages WHERE inbox = 0 AND sentbox = 0");

	# Log action
	$m->logAction(1, 'msg', 'delallrd', $userId, 0, 0, 0, $msgId);
}
else {
	$msgId or $m->paramError($lng->{errMsgIdMiss});

	# Get message
	my $msg = $m->fetchHash("
		SELECT senderId, receiverId, inbox, sentbox FROM $cfg->{dbPrefix}messages WHERE id = $msgId");
	$msg or $m->entryError($lng->{errMsgNotFnd});
	my $received = $msg->{receiverId} == $userId;
	my $sent = $msg->{senderId} == $userId;
	
	# Check if user can see message
	$received && $msg->{inbox} || $sent && $msg->{sentbox}
		or $m->entryError($lng->{errMsgNotFnd});

	# Delete or remove from box	
	if (($received && $sent)
		|| ($received && $msg->{inbox} && !$msg->{sentbox})
		|| ($sent && $msg->{sentbox} && !$msg->{inbox})) {
		# Delete message
		$m->dbDo("
			DELETE FROM $cfg->{dbPrefix}messages WHERE id = $msgId");
	}
	elsif ($received && $msg->{inbox} && $msg->{sentbox}) {
		# Remove from inbox
		$m->dbDo("
			UPDATE $cfg->{dbPrefix}messages SET inbox = 0 WHERE id = $msgId");
	}
	elsif ($sent && $msg->{sentbox} && $msg->{inbox}) {
		# Remove from sentbox
		$m->dbDo("
			UPDATE $cfg->{dbPrefix}messages SET sentbox = 0 WHERE id = $msgId");
	}
	else {
		$m->entryError($lng->{errMsgNotFnd});
	}
		
	# Log action
	$m->logAction(1, 'msg', 'delete', $userId, 0, 0, 0, $msgId);
}

# Redirect back to list
$m->redirect('message_list', msg => 'MsgDel');
