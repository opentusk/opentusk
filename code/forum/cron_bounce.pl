#!/usr/bin/perl
use FindBin;
use lib "$FindBin::Bin/../../lib";

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

BEGIN {
    $ENV{COMMAND_LINE} = 1;
}

use strict;
use warnings;
no warnings qw(uninitialized redefine);

# Imports
use Forum::MwfMain;
require Mail::POP3Client;

#------------------------------------------------------------------------------

# Init
my ($m, $cfg, $lng) = MwfMain->newShell();

# Connect to POP3 account
my $pop = Mail::POP3Client->new(
	USER      => $cfg->{bouncePopUser},
	PASSWORD  => $cfg->{bouncePopPwd},
	HOST      => $cfg->{bouncePopHost} || 'localhost',
	AUTH_MODE => $cfg->{bouncePopAuth} || 'BEST',
	PORT      => $cfg->{bouncePopPort} || 110,
	TIMEOUT   => $cfg->{bouncePopTout} || 20,
	USESSL    => $cfg->{bouncePopSsl}  || 0,
	DEBUG     => $cfg->{bouncePopDbg}  || 0,
);
$pop->Alive() or die "POP3 connection failed.";

# Retrieve messages
my @emails = ();
my $mailNum = $pop->Count();
defined($mailNum) && $mailNum != -1 or die "POP3 connection failed ($!).";
for my $i (1 .. $mailNum) {
	push @emails, scalar $pop->Body($i);
	$pop->Delete($i);
}

# Close connection
$pop->Close();

# For each email
for my $email (@emails) {
	# Get auth value from email
	my ($auth) = $email =~ /X\-mwForum\-BounceAuth: (\d+)/i;

	# If no auth value found, log and next
	if (!$auth) { 
		$m->logAction(3, 'bounce', 'noauth');
		next;
	}

	# Get user with auth value
	my $authUser = $m->fetchHash("
		SELECT id, email, bounceNum, dontEmail, language 
		FROM $cfg->{dbPrefix}users 
		WHERE bounceAuth = $auth");
	
	# If no user for auth value found, log and next
	if (!$authUser) { 
		$m->logAction(2, 'bounce', 'nouser');
		next;
	}
	
	# Look for users address in email
	if ($email !~ /$authUser->{email}/i) {
		$m->logAction(2, 'bounce', 'noemail');
		next;
	}

	# Log authenticated user
	my $authUserId = $authUser->{id};
	$m->logAction(1, 'bounce', 'auth', $authUserId);
	
	# Update user's bounceNum
	my $bounceFactor = $cfg->{bounceFactor} || 3;
	my $oldBounceNum = $authUser->{bounceNum};
	my $newBounceNum = $oldBounceNum + $bounceFactor;
	$m->dbDo("
		UPDATE $cfg->{dbPrefix}users SET bounceNum = $newBounceNum WHERE id = $authUserId");
	
	# Take action depending on configured policy
	my $warnTrsh = $cfg->{bounceTrshWarn} * $bounceFactor;
	my $cnclTrsh = $cfg->{bounceTrshCncl} * $bounceFactor;
	my $dsblTrsh = $cfg->{bounceTrshDsbl} * $bounceFactor;
	
	if ($warnTrsh && $oldBounceNum < $warnTrsh && $newBounceNum >= $warnTrsh) {
		# Add notification if there isn't already one
		$m->setLanguage($authUser->{language});
		my $bodyQ = $m->dbQuote($m->{lng}{bncWarning});
		$m->setLanguage();
		my $warned = $m->fetchArray("
			SELECT 1 
			FROM $cfg->{dbPrefix}notes
			WHERE userId = $authUserId 
				AND body = $bodyQ");
		$m->addNote($authUserId, 'bncWarning') if !$warned;
	}
	elsif ($cnclTrsh && $oldBounceNum < $cnclTrsh && $newBounceNum >= $cnclTrsh) {
		# Cancel subscriptions and clear email notification options
		$m->dbDo("
			DELETE FROM $cfg->{dbPrefix}boardSubscriptions WHERE userId = $authUserId");
		$m->dbDo("
			DELETE FROM $cfg->{dbPrefix}topicSubscriptions WHERE userId = $authUserId");
		$m->dbDo("
			UPDATE $cfg->{dbPrefix}users SET msgNotify = 0 WHERE id = $authUserId");
	}
	elsif ($dsblTrsh && $oldBounceNum < $dsblTrsh && $newBounceNum >= $dsblTrsh) {
		# Set dontEmail flag unless it's already set
		$m->dbDo("
			UPDATE $cfg->{dbPrefix}users SET dontEmail = 1 WHERE id = $authUserId") 
			if !$authUser->{dontEmail};
	}
}
