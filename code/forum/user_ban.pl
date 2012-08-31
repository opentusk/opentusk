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
my $action = $m->paramStrId('act');
my $banUserId = $m->paramInt('uid');
my $reason = $m->paramStr('reason');
my $intReason = $m->paramStr('intReason');
my $duration = $m->paramInt('duration');
my $resetEmail = $m->paramBool('resetEmail');
my $deleteMsgs = $m->paramBool('deleteMsgs');
my $submitted = $m->paramBool('subm');
my $sourceAuth = $m->paramInt('auth');
$banUserId or $m->paramError($lng->{errUsrIdMiss});

# Check if user exists
$m->fetchArray("
	SELECT id FROM $cfg->{dbPrefix}users WHERE id = $banUserId") 
	or $m->entryError($lng->{errUsrNotFnd});

# Process form
if ($submitted) {
	# Check request source authentication
	$sourceAuth == $user->{sourceAuth} or $m->formError($lng->{errSrcAuth});

	# Process ban form
	if ($action eq 'ban') {
		# Check if user isn't already banned
		!$m->fetchArray("
			SELECT userId FROM $cfg->{dbPrefix}userBans WHERE userId = $banUserId") 
			or $m->userError("User is already banned.");
			
		# Print form errors or finish action
		if (@{$m->{formErrors}}) { $m->printFormErrors() }
		else {
			# Prepare values
			$duration = $m->min($m->max(0, $duration), 999);
			$duration ||= 0;
			my $reasonQ = $m->dbQuote($reason);
			my $intReasonQ = $m->dbQuote($intReason);
			
			# Transaction
			$m->dbBegin();
			eval {
				# Insert ban
				$m->dbDo("
					INSERT INTO $cfg->{dbPrefix}userBans (userId, banTime, duration, reason, intReason)
					VALUES ($banUserId, $m->{now}, $duration, $reasonQ, $intReasonQ)");

				# Reset email subscriptions and notifications
				if ($resetEmail) {
					$m->dbDo("
						DELETE FROM $cfg->{dbPrefix}boardSubscriptions WHERE userId = $banUserId");
					$m->dbDo("
						UPDATE $cfg->{dbPrefix}users SET msgNotify = 0 WHERE id = $banUserId");
				}

				# Delete outgoing messages
				$m->dbDo("
					DELETE FROM $cfg->{dbPrefix}messages WHERE senderId = $banUserId") 
					if $deleteMsgs;
			};
			$@ ? $m->dbRollback() : $m->dbCommit();

			# Log action
			$m->logAction(1, 'user', 'ban', $userId, 0, 0, 0, $banUserId);
		}
	}
	# Process unban form
	elsif ($action eq 'unban') {
		# Check if user is already banned
		$m->fetchArray("
			SELECT userId FROM $cfg->{dbPrefix}userBans WHERE userId = $banUserId") 
			or $m->userError("User is not banned.");
		
		# Print form errors or finish action
		if (@{$m->{formErrors}}) { $m->printFormErrors() }
		else {
			# Delete ban
			$m->dbDo("
				DELETE FROM $cfg->{dbPrefix}userBans WHERE userId = $banUserId");

			# Log action
			$m->logAction(1, 'user', 'unban', $userId, 0, 0, 0, $banUserId);
		}
	}	
	else { $m->paramError($lng->{errParamMiss}) }
	
	# Redirect back
	$m->redirect('user_ban_list');
}

# Print form
if (!$submitted || @{$m->{formErrors}}) {
	# Print header
	$m->printHeader();
	
	# Get user
	my $banUser = $m->getUser($banUserId);
	$banUser or $m->entryError($lng->{errUsrNotFnd});
	
	# Print page bar
	my @navLinks = ({ url => $m->url('user_info', uid => $banUserId), txt => 'comUp', ico => 'up' });
	$m->printPageBar(mainTitle => "User", subTitle => $banUser->{userName}, navLinks => \@navLinks);
	
	# Check if user is already banned
	my $ban = $m->fetchHash("
		SELECT * FROM $cfg->{dbPrefix}userBans WHERE userId = $banUserId");
	
	if ($ban) {
		# Print unban form
		print
			"<form action='user_ban$m->{ext}' method='post'>\n",
			"<div class='frm'>\n",
			"<div class='hcl'>\n",
			"<span class='htt'>Unban User</span>\n",
			"</div>\n",
			"<div class='ccl'>\n",
			"User is currently banned. Duration: $ban->{duration} days.\n",
			"<br/><br/>Public reason: $ban->{reason}\n",
			"<br/><br/>Internal reason: $ban->{intReason}<br/><br/>\n",
			$m->submitButton("Unban", 'remove'),
			"<input type='hidden' name='uid' value='$banUserId'/>\n",
			"<input type='hidden' name='act' value='unban'/>\n",
			$m->stdFormFields(),
			"</div>\n",
			"</div>\n",
			"</form>\n\n";
	}
	else {
		# Escape submitted values
		$reason = $m->escHtml($reason);
		$intReason = $m->escHtml($intReason);
			
		# Print ban form
		print
			"<form action='user_ban$m->{ext}' method='post'>\n",
			"<div class='frm'>\n",
			"<div class='hcl'>\n",
			"<span class='htt'>Ban User</span>\n",
			"</div>\n",
			"<div class='ccl'>\n",
			"Public Reason (shown to banned user)<br/>\n",
			"<input type='text' name='reason' size='80' value='$reason'/><br/>\n",
			"Internal Reason (only shown to admins)<br/>\n",
			"<input type='text' name='intReason' size='80' value='$intReason'/><br/>\n",
			"Duration (in days, 0 = unlimited)<br/>\n",
			"<input type='text' name='duration' size='4' maxlength='3' value='$duration'/><br/><br/>\n",
			"<label><input type='checkbox' name='resetEmail'/>",
			" Reset email subscriptions and notifications</label><br/>\n",
			"<label><input type='checkbox' name='deleteMsgs'/>",
			" Delete sent private messages</label><br/><br/>\n",
			$m->submitButton("Ban", 'ban'),
			"<input type='hidden' name='uid' value='$banUserId'/>\n",
			"<input type='hidden' name='act' value='ban'/>\n",
			$m->stdFormFields(),
			"</div>\n",
			"</div>\n",
			"</form>\n\n";
	}
	
	# Log action
	$m->logAction(3, 'user', 'ban', $userId, 0, 0, 0, $banUserId);
	
	# Print footer
	$m->printFooter();
}
