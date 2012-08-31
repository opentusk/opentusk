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

# Check if access should be denied
$userId or $m->regError();
$m->checkBan($userId);
$m->checkBlock();

# Get CGI parameters
my $ignUserId = $m->paramInt('uid');
my $userName = $m->paramStr('userName');
my $action = $m->paramStrId('act');
my $submitted = $m->paramBool('subm');
my $sourceAuth = $m->paramInt('auth');

# Get username from id or vice versa
if ($ignUserId) {
	$userName = $m->fetchArray("
		SELECT userName FROM $cfg->{dbPrefix}users WHERE id = $ignUserId");
	$userName or $m->formError($lng->{errUsrNotFnd});
}
else {	
	my $userNameQ = $m->dbQuote($userName);
	$ignUserId = $m->fetchArray("
		SELECT id FROM $cfg->{dbPrefix}users WHERE userName = $userNameQ");
	$ignUserId or $m->formError($lng->{errUsrNotFnd});
}

# Process form
if ($submitted) {
	# Check request source authentication
	$sourceAuth == $user->{sourceAuth} or $m->formError($lng->{errSrcAuth});

	# Process add ignore form
	if ($action eq 'add') {
		# Print form errors or finish action
		if (@{$m->{formErrors}}) { $m->printFormErrors() }
		else {
			# Add ignored user
			$m->setRel(1, 'userIgnores', 'userId', 'ignoredId', $userId, $ignUserId);
		
			# Log action
			$m->logAction(1, 'user', 'ignadd', $userId, 0, 0, 0, $ignUserId);
			
			# Redirect
			$m->redirect('user_ignore', msg => 'IgnoreAdd');
		}
	}
	# Process remove ignore form
	elsif ($action eq 'remove') {
		# Print form errors or finish action
		if (@{$m->{formErrors}}) { $m->printFormErrors() }
		else {
			# Remove ignored user
			$m->setRel(0, 'userIgnores', 'userId', 'ignoredId', $userId, $ignUserId);
		
			# Log action
			$m->logAction(1, 'user', 'ignrem', $userId, 0, 0, 0, $ignUserId);
	
			# Redirect
			$m->redirect('user_ignore', msg => 'IgnoreRem');
		}
	}
	else { $m->paramError($lng->{errParamMiss}) }
}

# Print form
if (!$submitted || @{$m->{formErrors}}) {
	# Print header
	$m->printHeader();

	# Print bar
	my @navLinks = ({ url => $m->url('user_options'), txt => 'comUp', ico => 'up' });
	$m->printPageBar(mainTitle => $lng->{uigTitle}, subTitle => $user->{userName}, 
		navLinks => \@navLinks);

	# Escape submitted values
	$userName = $m->escHtml($userName);
	
	# Print add form
	print
		"<form action='user_ignore$m->{ext}' method='post'>\n",
		"<div class='frm'>\n",
		"<div class='hcl'>\n",
		"<span class='htt'>$lng->{uigAddTtl}</span>\n",
		"</div>\n",
		"<div class='ccl'>\n",
		"$lng->{uigAddUser}<br/>\n";

	my $userNum = $m->fetchArray("
		SELECT COUNT(*) FROM $cfg->{dbPrefix}users");
	if ($userNum > $cfg->{maxListUsers}) {
		print "<input type='text' name='userName' size='20' value='$userName'/><br/><br/>\n";
	}
	else {
		my $users = $m->fetchAllArray("
			SELECT id, userName FROM $cfg->{dbPrefix}users ORDER BY userName");
		print "<select name='uid' size='10'>\n";
		for my $listUser (@$users) {
			my $sel = $listUser->[0] == $ignUserId ? "selected='selected'" : "";
			print "<option value='$listUser->[0]' $sel>$listUser->[1]</option>\n";
		}
		print "</select><br/><br/>\n";
	}

	print
		$m->submitButton('uigAddB', 'ignore'),
		"<input type='hidden' name='act' value='add'/>\n",
		$m->stdFormFields(),
		"</div>\n",
		"</div>\n",
		"</form>\n\n";
	
	# Get ignored users
	my $ignoredUsers = $m->fetchAllArray("
		SELECT ignoredUsers.id, ignoredUsers.userName
		FROM $cfg->{dbPrefix}userIgnores AS userIgnores
			INNER JOIN $cfg->{dbPrefix}users AS users
				ON users.id = userIgnores.userId
			INNER JOIN $cfg->{dbPrefix}users AS ignoredUsers
				ON ignoredUsers.id = userIgnores.ignoredId
		WHERE userIgnores.userId = $userId
		ORDER BY ignoredUsers.userName");
	
	if (@$ignoredUsers) {
		# Print remove form
		print
			"<form action='user_ignore$m->{ext}' method='post'>\n",
			"<div class='frm'>\n",
			"<div class='hcl'>\n",
			"<span class='htt'>$lng->{uigRemTtl}</span>\n",
			"</div>\n",
			"<div class='ccl'>\n",
			"$lng->{uigRemUser}<br/>\n",
			"<select name='uid' size='10'>\n";
		
		print "<option value='$_->[0]'>$_->[1]</option>\n" for @$ignoredUsers;
		
		print
			"</select><br/><br/>\n",
			$m->submitButton('uigRemB', 'remove'),
			"<input type='hidden' name='act' value='remove'/>\n",
			$m->stdFormFields(),
			"</div>\n",
			"</div>\n",
			"</form>\n\n";
	}
	
	# Log action
	$m->logAction(3, 'user', 'ignore', $userId);
	
	# Print footer
	$m->printFooter();
}
