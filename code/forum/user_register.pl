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

# Check if access should be denied
$m->checkBlock();

# Load additional modules
require Forum::MwfCaptcha if $cfg->{captcha};

# Check if user registration is disabled for normal users
!$cfg->{adminUserReg} && !$cfg->{authenPlg}{login} 
	|| $user->{admin} or $m->userError($lng->{errAdmUsrReg});

# Get CGI parameters
my $userName = $m->paramStr('userName');
my $email = $m->paramStr('email');
my $emailV = $m->paramStr('emailV');
my $password = $m->paramStr('password');
my $passwordV = $m->paramStr('passwordV');
my $extra1 = $m->paramStr('extra1') || "";
my $extra2 = $m->paramStr('extra2') || "";
my $extra3 = $m->paramStr('extra3') || "";
my $submitted = $m->paramBool('subm');

# Process form
if ($submitted) {
	# Don't set fields if they are not displayed in form
	$extra1 = "" if !$cfg->{regExtra1};
	$extra2 = "" if !$cfg->{regExtra2};
	$extra3 = "" if !$cfg->{regExtra3};
	
	# Check username for validity
	$m->checkUsername($userName);
	for (@{$cfg->{reservedNames}}) { 
		index(lc($userName), lc($_)) < 0 or $m->formError($lng->{errNamGone}) 
	}
	
	# Check authorization
	my $regUser = {
		userName => $userName,
		email => $email,
		extra1 => $extra1,
		extra2 => $extra2,
		extra3 => $extra3,
	};
	$m->checkAuthz($user, 'regUser', regUser => $regUser);
	
	# Check if username is free
	my $userNameQ = $m->dbQuote($userName);
	!$m->fetchArray("
		SELECT id FROM $cfg->{dbPrefix}users WHERE userName = $userNameQ") 
		or $m->formError($lng->{errNamGone});
	
	# Check if email address is valid and free
	if (!$cfg->{noEmailReq}) {
		$email eq $emailV or $m->formError($lng->{errEmlDiffer});
		$m->checkEmail($email);
		my $emailQ = $m->dbQuote($email);
		!$m->fetchArray("
			SELECT id FROM $cfg->{dbPrefix}users WHERE email = $emailQ") 
			or $m->formError($lng->{errEmlGone});
	}
	
	# Handle password
	if (!$cfg->{noEmailReq}) {
		# Generate initial password
		$password = "";
		my @chars = ('a'..'z', '2'..'9');
		for (1..8) { $password .= $chars[int(rand(@chars))] }
		$password =~ tr!loO!xyz!;
	}
	else {
		# Check password for validity
		$password eq $passwordV or $m->formError($lng->{errPwdDiffer});
		length($password) >= 3 or $m->formError($lng->{errPwdSize});
		$password =~ /^[\x20-\x7e]+$/ or $m->formError($lng->{errPwdChar});
	}
		
	# Check captcha
	MwfCaptcha::checkCaptcha($m, 'regCpt') if $cfg->{captcha};

	# Print form errors or finish action
	if (@{$m->{formErrors}}) { $m->printFormErrors() }
	else {
		# Insert user
		my $regUserId = $m->createUser(
			userName => $userName,
			password => $password,
			email => $email,
			extra1 => $extra1,
			extra2 => $extra2,
			extra3 => $extra3,
		);
		
		# Get inserted user
		$regUser = $m->getUser($regUserId);

		# Normal registration with email
		if (!$regUser->{admin} && !$cfg->{noEmailReq}) {
			# Create quick login ticket
			my $ticketId = $m->randomId();
			$m->dbDo("
				INSERT INTO $cfg->{dbPrefix}tickets (id, userId, issueTime, type)
				VALUES ('$ticketId', $regUser->{id}, $m->{now}, 'usrReg')");
			
			# Email account info to user
			$regUser->{password} = $password;
			$m->sendEmail($m->createEmail(
				type => 'userReg',
				user => $regUser,
				url => "$cfg->{baseUrl}$m->{env}{scriptUrlPath}/user_ticket$m->{ext}?t=$ticketId",
			));
		}
		# Email-less registration
		elsif ($cfg->{noEmailReq}) {
			# Add notification message about email
			my $emlUrl = $m->url('user_email');
			$m->addNote($regUserId, 'notEmlReg', usrNam => $userName, emlUrl => $emlUrl);

			# Set cookies
			my $passwordMd5 = $m->md5($password . $regUser->{salt});
			$m->setCookies($regUserId, $passwordMd5, $regUser->{tempLogin}, $regUser->{secureLogin});

			# Update user's previous online time
			$m->dbDo("
				UPDATE $cfg->{dbPrefix}users SET prevOnTime = $m->{now} WHERE id = $regUserId");
			
			# Insert session
			$m->{sessionId} = $m->randomId();
			$m->dbDo("
				INSERT INTO $cfg->{dbPrefix}sessions (id, userId, lastOnTime, ip)
				VALUES ('$m->{sessionId}', $regUserId, $m->{now}, '$m->{env}{userIp}')");
		}
		
		# Log action
		$m->logAction(1, 'user', 'register', $regUserId);
		
		# Redirect
		my $script = $cfg->{noEmailReq} ? 'forum_show' : 'user_login';
		$m->redirect($script, msg => 'AccntReg');
	}
}

# Print form
if (!$submitted || @{$m->{formErrors}}) {
	# Print header
	$m->printHeader();

	# Print page bar
	my @navLinks = ({ url => $m->url('forum_show'), txt => 'comUp', ico => 'up' });
	$m->printPageBar(mainTitle => $lng->{regTitle}, navLinks => \@navLinks);

	# Escape submitted values
	$userName = $m->escHtml($userName);
	$email = $m->escHtml($email);
	$emailV = $m->escHtml($emailV);
	$password = $m->escHtml($password);
	$passwordV = $m->escHtml($passwordV);
	$extra1 = $m->escHtml($extra1);
	$extra2 = $m->escHtml($extra2);
	$extra3 = $m->escHtml($extra3);

	# Replace script extensions in help text
	$lng->{lgiRegT} =~ s!\.pl!$m->{ext}!g;
	
	# Print user registration form
	print
		"<form action='user_register$m->{ext}' method='post'>\n",
		"<div class='frm'>\n",
		"<div class='hcl'>\n",
		"<span class='htt'>$lng->{regRegTtl}</span>\n",
		"</div>\n",
		"<div class='ccl'>\n",
		"$lng->{regRegT}<br/><br/>\n",
		"$lng->{regRegName}<br/>\n",
		"<input type='text' name='userName' size='40' maxlength='$cfg->{maxUserNameLen}'",
		" value='$userName'/><br/>\n";

	# Print email or password fields		
	if (!$cfg->{noEmailReq}) {
		print
			"$lng->{regRegEmail}<br/>\n",
			"<input type='text' name='email' size='40' maxlength='50' value='$email'/><br/>\n",
			"$lng->{regRegEmailV}<br/>\n",
			"<input type='text' name='emailV' size='40' maxlength='50' value='$emailV'/><br/>\n"
	}
	else {
		print
			"Password<br/>\n",
			"<input type='password' name='password' size='20' maxlength='15'/><br/>\n",
			"Repeat Password<br/>\n",
			"<input type='password' name='passwordV' size='20' maxlength='15'/><br/>\n"
			if $cfg->{noEmailReq};
	}

	# Print custom fields	
	print
		"$cfg->{longExtra1}<br/>\n",
		"<input type='text' name='extra1' size='40' maxlength='100' value='$extra1'/><br/>\n"
		if $cfg->{regExtra1};
	
	print
		"$cfg->{longExtra2}<br/>\n",
		"<input type='text' name='extra2' size='40' maxlength='100' value='$extra2'/><br/>\n"
		if $cfg->{regExtra2};
	
	print
		"$cfg->{longExtra3}<br/>\n",
		"<input type='text' name='extra3' size='40' maxlength='100' value='$extra3'/><br/>\n"
		if $cfg->{regExtra3};

	# Print button
	print
		$cfg->{captcha} ? MwfCaptcha::captchaInputs($m, 'regCpt') : "",
		"<br/>\n",
		$m->submitButton('regRegB', 'user'),
		$m->stdFormFields(),
		"</div>\n",
		"</div>\n",
		"</form>\n\n";

	# Log action
	$m->logAction(3, 'user', 'register');
	
	# Print footer
	$m->printFooter();
}
