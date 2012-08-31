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
$m->checkBlock();

# Get CGI parameters
my $userName = $m->paramStr('userName');
my $password = $m->paramStr('password');
my $remember = $m->paramBool('remember');
my $action = $m->paramStrId('act');
my $submitted = $m->paramBool('subm');

# Process form
if ($submitted) {
	# Process login	form
	if ($action eq 'login') {
		my $dbUser = undef;
		if ($cfg->{authenPlg}{login}) {
			# Call login authentication plugin
			$dbUser = $m->callPlugin($cfg->{authenPlg}{login}, 
				userName => $userName, password => $password);
			$dbUser or $m->formError($lng->{errUsrNotFnd});
		}
		else {
			# Get user
			$userName or $m->formError($lng->{errNamEmpty});
			my $userNameQ = $m->dbQuote($userName);
			$dbUser = $m->fetchHash("
				SELECT * FROM $cfg->{dbPrefix}users WHERE userName = $userNameQ");
			$dbUser = $m->fetchHash("
				SELECT * FROM $cfg->{dbPrefix}users WHERE email = $userNameQ")
				if !$dbUser && $userName =~ /\@/;
			if (!$dbUser) {
				$m->logError("Login attempt with non-existent username $userName");
				$m->formError($lng->{errUsrNotFnd});
			}

			# Check password
			$password or $m->formError($lng->{errPwdEmpty});
			if ($dbUser && $password) {
				my $passwordMd5 = $m->md5($password . $dbUser->{salt});
				if ($passwordMd5 ne $dbUser->{password}) {
					$m->logError("Login attempt with invalid password for user $userName");
					$m->formError($lng->{errPwdWrong});
				}
			}
		}
		
		# Print form errors or finish action
		if (@{$m->{formErrors}}) { $m->printFormErrors() }
		else {
			# Set cookies
			my $passwordMd5 = $m->md5($password . $dbUser->{salt});
			$m->setCookies($dbUser->{id}, $passwordMd5, !$remember, $dbUser->{secureLogin});

			# Update user's previous online time and remember-me selection
			my $tempLogin = $remember ? 0 : 1;
			$m->dbDo("
				UPDATE $cfg->{dbPrefix}users SET 
					prevOnTime = $dbUser->{lastOnTime},
					tempLogin = $tempLogin
				WHERE id = $dbUser->{id}")
				if !$dbUser->{manOldMark};
			
			# Delete old sessions
			$m->dbDo("
				DELETE FROM $cfg->{dbPrefix}sessions 
				WHERE lastOnTime < $m->{now} - $cfg->{sessionTimeout} * 60");

			# Insert session
			$m->{sessionId} = $m->randomId();
			$m->dbDo("
				INSERT INTO $cfg->{dbPrefix}sessions (id, userId, lastOnTime, ip)
				VALUES ('$m->{sessionId}', $dbUser->{id}, $m->{now}, '$m->{env}{userIp}')");
				
			# Log action
			$m->logAction(1, 'user', 'login', $dbUser->{id});
		
			# Redirect
			$m->redirect('forum_show');
		}
	} 
	# Process forgot password form
	elsif ($action eq 'fgtPwd') {
		# Get user
		my $userNameQ = $m->dbQuote($userName);
		my $dbUser = $m->fetchHash("
			SELECT * FROM $cfg->{dbPrefix}users WHERE userName = $userNameQ");
		$dbUser = $m->fetchHash("
			SELECT * FROM $cfg->{dbPrefix}users WHERE email = $userNameQ")
			if !$dbUser && $userName =~ /\@/;
		$dbUser or $m->formError($lng->{errUsrNotFnd});

		# Print form errors or finish action
		if (@{$m->{formErrors}}) { $m->printFormErrors() }
		else {
			# Don't send email to banned users or defective accounts
			$m->checkBan($dbUser->{id});
			$dbUser->{email} or $m->userError($lng->{errNoEmail});
			!$dbUser->{dontEmail} or $m->userError($lng->{errDontEmail});
			
			# Delete previous tickets
			$m->dbDo("
				DELETE FROM $cfg->{dbPrefix}tickets WHERE userId = $dbUser->{id} AND type = 'fgtPwd'");
			
			# Create ticket
			my $ticketId = $m->randomId();
			$m->dbDo("
				INSERT INTO $cfg->{dbPrefix}tickets (id, userId, issueTime, type)
				VALUES ('$ticketId', $dbUser->{id}, $m->{now}, 'fgtPwd')");
			
			# Email ticket to user
			$m->sendEmail($m->createEmail(
				type => 'fgtPwd', 
				user => $dbUser, 
				url => "$cfg->{baseUrl}$m->{env}{scriptUrlPath}/user_ticket$m->{ext}?t=$ticketId",
			));
		
			# Log action
			$m->logAction(1, 'user', 'fgtpwd', $dbUser->{id});
		
			# Redirect to forum page
			$m->redirect('forum_show', msg => 'TksFgtPwd');
		}
	} 
}

# Print forms
if (!$submitted || @{$m->{formErrors}}) {
	# Print header
	$m->printHeader();

	# Print page bar
	my @navLinks = ({ url => $m->url('forum_show'), txt => 'comUp', ico => 'up' });
	$m->printPageBar(mainTitle => $lng->{lgiTitle}, navLinks => \@navLinks);

	# Set submitted or database values
	$remember = $submitted ? $remember : !$user->{tempLogin};

	# Escape submitted values
	$userName = $m->escHtml($userName);

	# Determine checkbox, radiobutton and listbox states
	my %state = (
		remember => $remember ? "checked='checked'" : undef,
	);
	
	# Replace script extensions in help text
	$lng->{lgiLoginT} =~ s!\.pl!$m->{ext}!g;
	
	# Print login form
	print
		"<form action='user_login$m->{ext}' method='post'>\n",
		"<div class='frm'>\n",
		"<div class='hcl'>\n",
		"<span class='htt'>$lng->{lgiLoginTtl}</span>\n",
		"</div>\n",
		"<div class='ccl'>\n",
		"$lng->{lgiLoginT}<br/><br/>\n",
		"$lng->{lgiLoginName}<br/>\n",
		"<input type='text' name='userName' size='40' maxlength='50' value='$userName'/><br/>\n",
		"$lng->{lgiLoginPwd}<br/>\n",
		"<input type='password' name='password' size='40' maxlength='15'/><br/>\n",
		"<label><input type='checkbox' name='remember' $state{remember}/>",
		" $lng->{lgiLoginRmbr}</label><br/><br/>\n",
		$m->submitButton('lgiLoginB', 'login'),
		"<input type='hidden' name='act' value='login'/>\n",
		$m->stdFormFields(),
		"</div>\n",
		"</div>\n",
		"</form>\n\n";
	
	# Print forgot password form
	print
		"<form action='user_login$m->{ext}' method='post'>\n",
		"<div class='frm'>\n",
		"<div class='hcl'>\n",
		"<span class='htt'>$lng->{lgiFpwTtl}</span>\n",
		"</div>\n",
		"<div class='ccl'>\n",
		"$lng->{lgiFpwT}<br/><br/>\n",
		"$lng->{lgiLoginName}<br/>\n",
		"<input type='text' name='userName' size='40' maxlength='50' value='$userName'/><br/><br/>\n",
		$m->submitButton('lgiFpwB', 'subscribe'),
		"<input type='hidden' name='act' value='fgtPwd'/>\n",
		$m->stdFormFields(),
		"</div>\n",
		"</div>\n",
		"</form>\n\n"
		if !$cfg->{authenPlg}{request};
	
	# Log action
	$m->logAction(3, 'user', 'login', $userId);
	
	# Print footer
	$m->printFooter();
}
