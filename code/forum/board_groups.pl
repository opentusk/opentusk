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

# Get CGI parameters
my $boardId = $m->paramInt('bid');
my $submitted = $m->paramBool('subm');
my $sourceAuth = $m->paramInt('auth');

# Check if user is admin or moderator
$user->{admin} || $m->boardAdmin($userId, $boardId) or $m->adminError();

# Get board name
my $boardTitle = $m->fetchArray("
	SELECT title FROM $cfg->{dbPrefix}boards WHERE id = $boardId");
$boardTitle or $m->entryError($lng->{errBrdNotFnd});

# Process form
if ($submitted) {
	# Check request source authentication
	$sourceAuth == $user->{sourceAuth} or $m->formError($lng->{errSrcAuth});

	# Print form errors or finish action
	if (@{$m->{formErrors}}) { $m->printFormErrors() }
	else {
		# Transaction
		$m->dbBegin();
		eval {
			my $groups = $m->fetchAllHash("
				SELECT id FROM $cfg->{dbPrefix}groups");
			for my $group (@$groups) {
				# Update group moderator status
				my $set = $m->paramBool("admin_$group->{id}");
				$m->setRel($set, 'boardAdminGroups', 'groupId', 'boardId', $group->{id}, $boardId);
	
				# Update group membership
				$set = $m->paramBool("member_$group->{id}");
				$m->setRel($set, 'boardMemberGroups', 'groupId', 'boardId', $group->{id}, $boardId);
			}
		};
		$@ ? $m->dbRollback() : $m->dbCommit();
		
		# Log action
		$m->logAction(1, 'board', 'groups', $userId, $boardId);
		
		# Redirect
		$m->redirect('board_admin');
	}
}

# Print form
if (!$submitted || @{$m->{formErrors}}) {
	# Print header
	$m->printHeader();

	# Print page bar
	my @navLinks = ({ url => $m->url('board_show', bid => $boardId), txt => 'comUp', ico => 'up' });
	$m->printPageBar(mainTitle => $lng->{bgrTitle}, subTitle => $boardTitle, navLinks => \@navLinks);

	# Print board status table
	print 
		"<form action='board_groups$m->{ext}' method='post'>\n",
		"<table class='tbl'>\n",
		"<tr class='hrw'>\n",
		"<th colspan='3'>$lng->{bgrPermTtl}</th>\n",
		"</tr>\n";
		
	# Get groups including board status
	my $groups = $m->fetchAllHash("
		SELECT groups.id, groups.title,
			boardAdminGroups.groupId IS NOT NULL AS admin,
			boardMemberGroups.groupId IS NOT NULL AS member
		FROM $cfg->{dbPrefix}groups AS groups
			LEFT JOIN $cfg->{dbPrefix}boardAdminGroups AS boardAdminGroups
				ON boardAdminGroups.groupId = groups.id
				AND boardAdminGroups.boardId = $boardId
			LEFT JOIN $cfg->{dbPrefix}boardMemberGroups AS boardMemberGroups
				ON boardMemberGroups.groupId = groups.id
				AND boardMemberGroups.boardId = $boardId
		ORDER BY groups.title");

	# Print group list
	for my $group (@$groups) {
		my $admin = $group->{admin} ? "checked='checked'" : "";
		my $member = $group->{member} ? "checked='checked'" : "";
		my $url = $m->url('group_info', gid => $group->{id});
		print
			"<tr class='crw'>\n",
			"<td><a href='$url'>$group->{title}</a></td>\n",
			"<td class='shr'><label>",
			"<input type='checkbox' name='admin_$group->{id}' $admin/>$lng->{bgrModerator}",
			"</label></td>\n",
			"<td class='shr'><label>",
			"<input type='checkbox' name='member_$group->{id}' $member/>$lng->{bgrMember}",
			"</label></td>\n",
			"</tr>\n";
	}
	
	print "</table>\n\n";

	# Print submit section
	print
		"<div class='frm'>\n",
		"<div class='hcl'>\n",
		"<span class='htt'>$lng->{bgrChangeTtl}</span>\n",
		"</div>\n",
		"<div class='ccl'>\n",
		$m->submitButton('bgrChangeB', 'edit'),
		"<input type='hidden' name='bid' value='$boardId'/>\n",
		$m->stdFormFields(),
		"</div>\n",
		"</div>\n",
		"</form>\n\n";
	
	# Log action
	$m->logAction(3, 'board', 'groups', $userId, $boardId);
	
	# Print footer
	$m->printFooter();
}
