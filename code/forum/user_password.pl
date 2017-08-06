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
no warnings qw(uninitialized redefine once);

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

# Don't change password when auth plugin is used
!$cfg->{authenPlg}{login} && !$cfg->{authenPlg}{request}
	or $m->userError("Password change n/a when auth plugin is used.");

# Get CGI parameters
my $optUserId = $m->paramInt('uid');
my $password = $m->paramStr('password') || "";
my $passwordV = $m->paramStr('passwordV') || "";
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

	# Check password for validity
	$password eq $passwordV or $m->formError($lng->{errPwdDiffer});
	length($password) >= 3 or $m->formError($lng->{errPwdSize});
	$password =~ /^[\x20-\x7e]+$/ or $m->formError($lng->{errPwdChar});
	
	# Get salted password hash
	my $passwordMd5 = $m->md5($password . $optUser->{salt});
	my $passwordMd5Q = $m->dbQuote($passwordMd5);
	
	# Print form errors or finish action
	if (@{$m->{formErrors}}) { $m->printFormErrors() }
	else {
		# Transaction
		$m->dbBegin();
		eval {
			# Update user
			$m->dbDo("
				UPDATE $cfg->{dbPrefix}users SET password = $passwordMd5Q WHERE id = $optUserId");
			
			# Update cookies if password changed
			if ($passwordMd5 ne $user->{password} && $optUserId == $userId) {
				$m->setCookies($optUserId, $passwordMd5, $optUser->{tempLogin}, $optUser->{secureLogin});
			}
		};
		$@ ? $m->dbRollback() : $m->dbCommit();
		
		# Log action
		$m->logAction(1, 'user', 'passwd', $userId, 0, 0, 0, $optUserId);
		
		# Redirect
		$m->redirect('forum_show', msg => 'PwdChange');
	}
}

# Print form
if (!$submitted || @{$m->{formErrors}}) {
	# Print header
	$m->printHeader();

	# Print page bar
	my @navLinks = ({ url => $m->url('user_options', uid => $optUserId), 
		txt => 'comUp', ico => 'up' });
	$m->printPageBar(mainTitle => $lng->{pwdTitle}, subTitle => $optUser->{userName}, 
		navLinks => \@navLinks);

	# Print profile options
	print
		"<form action='user_password$m->{ext}' method='post'>\n",
		"<div class='frm'>\n",
		"<div class='hcl'>\n",
		"<span class='htt'>$lng->{pwdChgTtl}</span>\n",
		"</div>\n",
		"<div class='ccl'>\n",
		"$lng->{pwdChgT}<br/><br/>\n",
		"$lng->{pwdChgPwd}<br/>\n",
		"<input type='password' name='password' size='20' maxlength='15'/><br/>\n",
		"$lng->{pwdChgPwdV}<br/>\n",
		"<input type='password' name='passwordV' size='20' maxlength='15'/><br/><br/>\n",
		$m->submitButton('pwdChgB', 'edit'),
		"<input type='hidden' name='uid' value='$optUserId'/>\n",
		$m->stdFormFields(),
		"</div>\n",
		"</div>\n\n",
		"</form>\n\n";

	# Log action
	$m->logAction(3, 'user', 'passwd', $userId, 0, 0, 0, $optUserId);
	
	# Print footer
	$m->printFooter();
}
