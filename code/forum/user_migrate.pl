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
my $oldUserId = $m->paramInt('uid');
my $newUserId = $m->paramInt('newUserId');
my $userName = $m->paramStr('userName');
my $submitted = $m->paramBool('subm');
my $sourceAuth = $m->paramInt('auth');
$oldUserId or $m->paramError($lng->{errUsrIdMiss});

# Process form
if ($submitted) {
	# Check request source authentication
	$sourceAuth == $user->{sourceAuth} or $m->formError($lng->{errSrcAuth});

	# Check if old users exist
	$m->fetchArray("
		SELECT id FROM $cfg->{dbPrefix}users WHERE id = $oldUserId") 
		or $m->formError($lng->{errUsrNotFnd});

	# Check if user exists or get user id from name
	if ($newUserId) {
		$m->fetchArray("
			SELECT 1 FROM $cfg->{dbPrefix}users WHERE id = $newUserId") 
			or $m->formError($lng->{errUsrNotFnd});
	}
	else {	
		my $userNameQ = $m->dbQuote($userName);
		$newUserId = $m->fetchArray("
			SELECT id FROM $cfg->{dbPrefix}users WHERE userName = $userNameQ");
		$newUserId or $m->formError($lng->{errUsrNotFnd});
	}
	
	# Print form errors or finish action
	if (@{$m->{formErrors}}) { $m->printFormErrors() }
	else {
		# Transaction
		$m->dbBegin();
		eval {
			# Change ownership of posts
			my $userNameQ = $m->dbQuote($userName);
			$m->dbDo("
				UPDATE $cfg->{dbPrefix}posts SET 
					userId = $newUserId,
					userNameBak = $userNameQ
				WHERE userId = $oldUserId");

			# Change ownership of messages
			$m->dbDo("
				UPDATE $cfg->{dbPrefix}messages SET senderId = $newUserId WHERE senderId = $oldUserId");
			$m->dbDo("
				UPDATE $cfg->{dbPrefix}messages SET receiverId = $newUserId WHERE receiverId = $oldUserId");
		};
		$@ ? $m->dbRollback() : $m->dbCommit();
		
		# Log action
		$m->logAction(1, 'user', 'migrate', $userId, 0, 0, 0, $newUserId);
		
		# Redirect back
		$m->redirect('user_info', uid => $oldUserId);
	}
}


# Print form
if (!$submitted || @{$m->{formErrors}}) {
	# Print header
	$m->printHeader();

	# Check if user exists
	my $oldUserName = $m->fetchArray("
		SELECT userName FROM $cfg->{dbPrefix}users WHERE id = $oldUserId");
	$oldUserName or $m->entryError($lng->{errUsrNotFnd});

	# Print page bar
	my @navLinks = ({ url => $m->url('user_info', uid => $oldUserId), txt => 'comUp', ico => 'up' });
	$m->printPageBar(mainTitle => "User", subTitle => $oldUserName, navLinks => \@navLinks);

	# Print target user form
	print
		"<form action='user_migrate$m->{ext}' method='post'>\n",
		"<div class='frm'>\n",
		"<div class='hcl'>\n",
		"<span class='htt'>Migrate User</span>\n",
		"</div>\n",
		"<div class='ccl'>\n",
		"Change ownership of ${oldUserName}'s posts and messages to the specified user.<br/><br/>",
		"Username<br/>\n";

	my $userNum = $m->fetchArray("
		SELECT COUNT(*) FROM $cfg->{dbPrefix}users");
	if ($userNum > $cfg->{maxListUsers}) {
		print "<input type='text' name='userName' size='20' value=''/><br/><br/>\n";
	}
	else {
		my $users = $m->fetchAllArray("
			SELECT id, userName FROM $cfg->{dbPrefix}users ORDER BY userName");
		print "<select name='newUserId' size='10'>\n";
		print "<option value='$_->[0]'>$_->[1]</option>\n" for @$users;
		print "</select><br/><br/>\n";
	}

	print
		$m->submitButton("Migrate", 'merge'),
		"<input type='hidden' name='uid' value='$oldUserId'/>\n",
		$m->stdFormFields(),
		"</div>\n",
		"</div>\n",
		"</form>\n\n";
	
	# Log action
	$m->logAction(3, 'user', 'migrate', $userId, 0, 0, 0, $oldUserId);
	
	# Print footer
	$m->printFooter();
}
