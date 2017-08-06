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

# Check if user is admin
$user->{admin} or $m->adminError();

# Get CGI parameters
my $sourceAuth = $m->paramInt('auth');

# Check request source authentication
$sourceAuth == $user->{sourceAuth} or $m->paramError($lng->{errSrcAuth});

# Get first category id
my $firstCatId = $m->fetchArray("
	SELECT MIN(id) FROM $cfg->{dbPrefix}categories");
$firstCatId 
	or $m->userError("Can't create board without existing category. Create a category first.");

# Get position
my $pos = $m->fetchArray("
	SELECT MAX(pos) + 1 FROM $cfg->{dbPrefix}boards WHERE categoryId = $firstCatId");
$pos ||= 1;

# Insert new board
$m->dbDo("
	INSERT INTO $cfg->{dbPrefix}boards (
		title, categoryId, pos, expiration, approve, private, announce, flat
	) VALUES (
		'New Board', $firstCatId, $pos, 0, 0, 1, 0, 0
	)");
my $boardId = $m->dbInsertId("$cfg->{dbPrefix}boards");

# Log action
$m->logAction(1, 'board', 'add', $userId, $boardId);

# Redirect to board options page
$m->redirect('board_options', bid => $boardId);
