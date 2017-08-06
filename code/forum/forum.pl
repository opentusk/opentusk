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
my $boardId = $m->paramInt('bid');

# Update user's previous online time
$m->dbDo("
	UPDATE $cfg->{dbPrefix}users SET prevOnTime = $user->{lastOnTime} WHERE id = $userId")
	if $userId && !$user->{manOldMark};

# Log action
$m->logAction(2, 'forum', 'enter', $userId);

# Redirect to board or main page
$m->redirect('board_show', bid => $boardId) if $boardId;
$m->redirect('forum_show');
