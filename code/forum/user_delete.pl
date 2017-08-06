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
my $delUserId = $m->paramInt('uid');
my $sourceAuth = $m->paramInt('auth');
$delUserId or $m->paramError($lng->{errUsrIdMiss});

# Check request source authentication
$sourceAuth == $user->{sourceAuth} or $m->paramError($lng->{errSrcAuth});

# Don't delete user #1
$delUserId != 1 
	or $m->userError("If you really want to delete user #1, you'll have to do so manually.");

# Delete user
$m->deleteUser($delUserId);

# Log action
$m->logAction(1, 'user', 'delete', $userId, 0, 0, 0, $delUserId);

# Redirect back
$m->redirect('user_admin');
