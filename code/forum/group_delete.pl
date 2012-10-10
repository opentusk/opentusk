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
my $groupId = $m->paramInt('gid');
my $sourceAuth = $m->paramInt('auth');
$groupId or $m->paramError($lng->{errGrpIdMiss});

# Check request source authentication
$sourceAuth == $user->{sourceAuth} or $m->paramError($lng->{errSrcAuth});

# Transaction
$m->dbBegin();
eval {
	# Delete board moderator permissions
	$m->dbDo("
		DELETE FROM $cfg->{dbPrefix}boardAdminGroups WHERE groupId = $groupId");

	# Delete board member permissions
	$m->dbDo("
		DELETE FROM $cfg->{dbPrefix}boardMemberGroups WHERE groupId = $groupId");

	# Delete group memberships
	$m->dbDo("
		DELETE FROM $cfg->{dbPrefix}groupMembers WHERE groupId = $groupId");

	# Delete group
	$m->dbDo("
		DELETE FROM $cfg->{dbPrefix}groups WHERE id = $groupId");
};
$@ ? $m->dbRollback() : $m->dbCommit();

# Log action
$m->logAction(1, 'group', 'delete', $userId, 0, 0, 0, $groupId);

# Redirect back
$m->redirect('group_admin');
