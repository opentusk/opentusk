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

# Check if user is admin
$user->{admin} or $m->adminError();

# Get CGI parameters
my $categId = $m->paramInt('cid');
my $sourceAuth = $m->paramInt('auth');
$categId or $m->paramError($lng->{errCatIdMiss});

# Check request source authentication
$sourceAuth == $user->{sourceAuth} or $m->paramError($lng->{errSrcAuth});

# Only delete category when empty
!$m->fetchArray("
	SELECT id FROM $cfg->{dbPrefix}boards WHERE categoryId = $categId") 
	or $m->userError("Category is not empty.");

# Delete category
$m->dbDo("
	DELETE FROM $cfg->{dbPrefix}categories WHERE id = $categId");

# Log action
$m->logAction(1, 'categ', 'delete', $userId, 0, 0, 0, $categId);

# Redirect back
$m->redirect('categ_admin');
