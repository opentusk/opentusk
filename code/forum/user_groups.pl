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
my $optUserId = $m->paramInt('uid');
my $submitted = $m->paramBool('subm');
my $sourceAuth = $m->paramInt('auth');

# Select which user to edit
my $optUser = $optUserId && $user->{admin} ? $m->getUser($optUserId) : $user;
$optUser or $m->entryError($lng->{errUsrNotFnd});
$optUserId = $optUser->{id};

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
			# Update group membership
			my $groups = $m->fetchAllHash("
				SELECT id FROM $cfg->{dbPrefix}groups");
			for my $group (@$groups) {
				my $set = $m->paramBool("member_$group->{id}");
				$m->setRel($set, 'groupMembers', 'userId', 'groupId', $optUserId, $group->{id});
			}
		};
		$@ ? $m->dbRollback() : $m->dbCommit();
		
		# Log action
		$m->logAction(1, 'user', 'groups', $userId, 0, 0, 0, $optUserId);
		
		# Redirect
		$m->redirect('user_admin');
	}
}

# Print form
if (!$submitted || @{$m->{formErrors}}) {
	# Print header
	$m->printHeader();

	# Print page bar
	my @navLinks = ({ url => $m->url('user_info', uid => $optUserId), txt => 'comUp', ico => 'up' });
	$m->printPageBar(mainTitle => "User", subTitle => $optUser->{userName}, navLinks => \@navLinks);
	
	# Print group status table
	print 
		"<form action='user_groups$m->{ext}' method='post'>\n",
		"<table class='tbl'>\n",
		"<tr class='hrw'>\n",
		"<th colspan='2'>Group Membership</th>\n",
		"</tr>\n";
		
	# Get groups including status
	my $groups = $m->fetchAllHash("
		SELECT groups.id, groups.title,
			groupMembers.userId IS NOT NULL AS member
		FROM $cfg->{dbPrefix}groups AS groups
			LEFT JOIN $cfg->{dbPrefix}groupMembers AS groupMembers
				ON groupMembers.userId = $optUserId
				AND groupMembers.groupId = groups.id
		ORDER BY groups.title");

	# Print group list
	for my $group (@$groups) {
		my $member = $group->{member} ? "checked='checked'" : '';
		my $url = $m->url('group_info', gid => $group->{id});
		print
			"<tr class='crw'>\n",
			"<td><a href='$url'>$group->{title}</a></td>\n",
			"<td class='shr'><label>",
			"<input type='checkbox' name='member_$group->{id}' $member/>Member",
			"</label></td>\n",
			"</tr>\n";
	}
	
	print "</table>\n\n";

	# Print submit section
	print
		"<div class='frm'>\n",
		"<div class='hcl'>\n",
		"<span class='htt'>Change Membership</span>\n",
		"</div>\n",
		"<div class='ccl'>\n",
		$m->submitButton("Change", 'edit'),
		"<input type='hidden' name='uid' value='$optUserId'/>\n",
		$m->stdFormFields(),
		"</div>\n",
		"</div>\n",
		"</form>\n\n";
	
	# Log action
	$m->logAction(3, 'user', 'groups', $userId, 0, 0, 0, $optUserId);
	
	# Print footer
	$m->printFooter();
}
