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

# Get CGI parameters
my $topicId = $m->paramInt('tid');
my $action = $m->paramStrId('act');
my $sourceAuth = $m->paramInt('auth');
$topicId or $m->paramError($lng->{errTpcIdMiss});

# Check request source authentication
$sourceAuth == $user->{sourceAuth} or $m->paramError($lng->{errSrcAuth});

# Get board id
my $boardId = $m->fetchArray("
	SELECT boardId FROM $cfg->{dbPrefix}topics WHERE id = $topicId");
$boardId or $m->entryError($lng->{errTpcNotFnd});

# Check if user is admin or moderator
$user->{admin} || $m->boardAdmin($userId, $boardId) or $m->adminError();

# Lock or unlock
my $locked = $action eq "lock" ? 1 : 0;

# Update
$m->dbDo("
	UPDATE $cfg->{dbPrefix}topics SET locked = $locked WHERE id = $topicId");

# Log action
$m->logAction(1, 'topic', $locked ? 'lock' : 'unlock', $userId, $boardId, $topicId);

# Redirect back
$m->redirect('topic_show', tid => $topicId, msg => $locked ? "TpcLock" : "TpcUnlock");
