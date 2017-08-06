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

# Get CGI parameters
my $sourceAuth = $m->paramInt('auth');

# Check request source authentication
$sourceAuth == $user->{sourceAuth} or $m->paramError($lng->{errSrcAuth});

# Delete notifications
$m->dbDo("
	DELETE FROM $cfg->{dbPrefix}notes WHERE userId = $userId");

# Log action
$m->logAction(1, 'note', 'delete', $userId);

# Redirect to forum page
$m->redirect('forum_show', msg => 'NotesDel');
