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
my $memberId = $m->paramInt('uid');
my $userName = $m->paramStr('userName');
my $action = $m->paramStrId('act');
my $submitted = $m->paramBool('subm');
my $sourceAuth = $m->paramInt('auth');
$boardId or $m->paramError($lng->{errBrdIdMiss});

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

	# Check if user exists or get user id from name
	if ($memberId) {
		$m->fetchArray("
			SELECT 1 FROM $cfg->{dbPrefix}users WHERE id = $memberId") 
			or $m->formError($lng->{errUsrNotFnd});
	}
	else {	
		my $userNameQ = $m->dbQuote($userName);
		$memberId = $m->fetchArray("
			SELECT id FROM $cfg->{dbPrefix}users WHERE userName = $userNameQ");
		$memberId or $m->formError($lng->{errUsrNotFnd});
	}

	# Process add member form
	if ($action eq 'add') {
		# Print form errors or finish action
		if (@{$m->{formErrors}}) { $m->printFormErrors() }
		else {
			# Add membership
			$m->setRel(1, 'boardMembers', 'userId', 'boardId', $memberId, $boardId);
		
			# Log action
			$m->logAction(1, 'board', 'addmembr', $userId, $boardId, 0, 0, $memberId);
			
			# Redirect
			$m->redirect('board_members', bid => $boardId, msg => 'MemberAdd');
		}
	}
	# Process remove member form
	elsif ($action eq 'remove') {
		# Print form errors or finish action
		if (@{$m->{formErrors}}) { $m->printFormErrors() }
		else {
			# Remove membership
			$m->setRel(0, 'boardMembers', 'userId', 'boardId', $memberId, $boardId);
			$m->setRel(0, 'boardSubscriptions', 'userId', 'boardId', $memberId, $boardId);
		
			# Log action
			$m->logAction(1, 'board', 'remmembr', $userId, $boardId, 0, 0, $memberId);
	
			# Redirect
			$m->redirect('board_members', bid => $boardId, msg => 'MemberRem');
		}
	}
	else { $m->paramError($lng->{errParamMiss}) }
}

# Print form
if (!$submitted || @{$m->{formErrors}}) {
	# Print header
	$m->printHeader();

	# Print page bar
	my @navLinks = ({ url => $m->url('board_show', bid => $boardId), txt => 'comUp', ico => 'up' });
	$m->printPageBar(mainTitle => $lng->{mbrTitle}, subTitle => $boardTitle, navLinks => \@navLinks);

	# Escape submitted values
	$userName = $m->escHtml($userName);
	
	# Print add form
	print
		"<form action='board_members$m->{ext}' method='post'>\n",
		"<div class='frm'>\n",
		"<div class='hcl'>\n",
		"<span class='htt'>$lng->{mbrAddTtl}</span>\n",
		"</div>\n",
		"<div class='ccl'>\n",
		"$lng->{mbrAddUser}<br/>\n";

	my $userNum = $m->fetchArray("
		SELECT COUNT(*) FROM $cfg->{dbPrefix}users");
	if ($userNum > $cfg->{maxListUsers}) {
		print "<input type='text' name='userName' size='20' value=''/><br/><br/>\n";
	}
	else {
		my $users = $m->fetchAllArray("
			SELECT id, userName FROM $cfg->{dbPrefix}users ORDER BY userName");
		print "<select name='uid' size='10'>\n";
		print "<option value='$_->[0]'>$_->[1]</option>\n" for @$users;
		print "</select><br/><br/>\n";
	}

	print
		$m->submitButton('mbrAddB', 'user'),
		"<input type='hidden' name='bid' value='$boardId'/>\n",
		"<input type='hidden' name='act' value='add'/>\n",
		$m->stdFormFields(),
		"</div>\n",
		"</div>\n",
		"</form>\n\n";
	
	# Get members
	my $members = $m->fetchAllArray("
		SELECT users.id, users.userName
		FROM $cfg->{dbPrefix}users AS users
			INNER JOIN $cfg->{dbPrefix}boardMembers AS boardMembers
				ON boardMembers.userId = users.id
				AND boardMembers.boardId = $boardId
		ORDER BY users.userName");
	
	if (@$members) {
		# Print remove form
		print
			"<form action='board_members$m->{ext}' method='post'>\n",
			"<div class='frm'>\n",
			"<div class='hcl'>\n",
			"<span class='htt'>$lng->{mbrRemTtl}</span>\n",
			"</div>\n",
			"<div class='ccl'>\n",
			"$lng->{mbrRemUser}<br/>\n",
			"<select name='uid' size='10'>\n";
		
		print "<option value='$_->[0]'>$_->[1]</option>\n" for @$members;
		
		print
			"</select><br/><br/>\n",
			$m->submitButton('mbrRemB', 'remove'),
			"<input type='hidden' name='bid' value='$boardId'/>\n",
			"<input type='hidden' name='act' value='remove'/>\n",
			$m->stdFormFields(),
			"</div>\n",
			"</div>\n",
			"</form>\n\n";
	}
	
	# Log action
	$m->logAction(3, 'board', 'member', $userId, $boardId);
	
	# Print footer
	$m->printFooter();
}
