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

# Get CGI parameters
my $optUserId = $m->paramInt('uid');
my $email = $m->paramStr('email') || "";
my $emailV = $m->paramStr('emailV') || "";
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

	# Check email for validity
	$email eq $emailV or $m->formError($lng->{errEmlDiffer});
	$m->checkEmail($email);
	
	# Did email change or was is set after being empty?
	my $emailChanged = $optUser->{email} && $optUser->{email} ne $email;
	my $emailAdded = !$optUser->{email} && $email;
	
	# Check if email is free
	my $emailQ = $m->dbQuote($email);
	!$m->fetchArray("
		SELECT id FROM $cfg->{dbPrefix}users WHERE email = $emailQ AND id <> $optUserId")
		or $m->formError($lng->{errEmlGone});
	
	# Print form errors or finish action
	if (@{$m->{formErrors}}) { $m->printFormErrors() }
	else {
		# Transaction
		$m->dbBegin();
		eval {
			# If email changed by non-admin, send ticket
			if (($emailChanged || $emailAdded) && !$user->{admin}) {
				# Delete previous tickets
				$m->dbDo("
					DELETE FROM $cfg->{dbPrefix}tickets WHERE userId = $optUserId AND type = 'emlChg'");
				
				# Create ticket
				my $ticketId = $m->randomId();
				$m->dbDo("
					INSERT INTO $cfg->{dbPrefix}tickets (id, userId, issueTime, type, data)
					VALUES ('$ticketId', $optUserId, $m->{now}, 'emlChg', $emailQ)");
				
				# Email ticket to user
				$optUser->{email} = $email;
				$m->sendEmail($m->createEmail(
					type => 'emlChg', 
					user => $optUser, 
					url => "$cfg->{baseUrl}$m->{env}{scriptUrlPath}/user_ticket$m->{ext}?t=$ticketId",
				));
			}
			elsif ($user->{admin}) {
				# Update email directly if changed by admin
				$m->dbDo("
					UPDATE $cfg->{dbPrefix}users SET email = $emailQ WHERE id = $optUserId");
			}
		};
		$@ ? $m->dbRollback() : $m->dbCommit();
		
		# Log action
		$m->logAction(1, 'user', 'options', $userId, 0, 0, 0, $optUserId);
		
		# Redirect
		$m->redirect('forum_show', msg => 'OptChange');
	}
}

# Print form
if (!$submitted || @{$m->{formErrors}}) {
	# Print header
	$m->printHeader();

	# Print page bar
	my @navLinks = ({ url => $m->url('user_options'), txt => 'comUp', ico => 'up' });
	$m->printPageBar(mainTitle => $lng->{emlTitle}, subTitle => $optUser->{userName}, 
		navLinks => \@navLinks);
	
	# Set submitted or database values
	$email = $submitted ? $m->escHtml($email) : $optUser->{email};
	$emailV = $submitted ? $m->escHtml($emailV) : $optUser->{email};
	
	# Print email options
	print
		"<form action='user_email$m->{ext}' method='post'>\n",
		"<div class='frm'>\n",
		"<div class='hcl'>\n",
		"<span class='htt'>$lng->{emlChgTtl}</span>\n",
		"</div>\n",
		"<div class='ccl'>\n",
		"<p>$lng->{emlChgT}</p>\n",
		"$lng->{emlChgAddr}<br/>\n",
		"<input type='text' name='email' size='40' maxlength='100' value='$email'/><br/>\n",
		"$lng->{emlChgAddrV}<br/>\n",
		"<input type='text' name='emailV' size='40' maxlength='100' value='$emailV'/><br/>\n",
		"<br/>\n",
		$m->submitButton($lng->{emlChgB}, 'edit'),
		"<input type='hidden' name='uid' value='$optUserId'/>\n",
		$m->stdFormFields(),
		"</div>\n",
		"</div>\n",
		"</form>\n\n";
	
	# Log action
	$m->logAction(3, 'user', 'options', $userId, 0, 0, 0, $optUserId);
	
	# Print footer
	$m->printFooter();
}
