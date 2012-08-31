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
my $ticketId = $m->paramStrId('t');

# Get ticket
my $ticket = $m->fetchHash("
	SELECT * 
	FROM $cfg->{dbPrefix}tickets 
	WHERE id = '$ticketId'
		AND issueTime > $m->{now} - 2 * 86400");
$ticket or $m->entryError($lng->{errTktNotFnd});

# Get user
my $dbUser = $m->getUser($ticket->{userId});
$dbUser or $m->entryError($lng->{errUsrNotFnd});

# Login ticket (freshly registered)
if ($ticket->{type} eq 'usrReg') {
	# Set cookies
	$m->setCookies($dbUser->{id}, $dbUser->{password}, $dbUser->{tempLogin}, $dbUser->{secureLogin});

	# Delete old sessions
	$m->dbDo("
		DELETE FROM $cfg->{dbPrefix}sessions 
		WHERE lastOnTime < $m->{now} - $cfg->{sessionTimeout} * 60");

	# Insert session
	$m->{sessionId} = $m->randomId();
	$m->dbDo("
		INSERT INTO $cfg->{dbPrefix}sessions (id, userId, lastOnTime, ip)
		VALUES ('$m->{sessionId}', $dbUser->{id}, $m->{now}, '$m->{env}{userIp}')");

	# Delete user's login tickets
	$m->dbDo("
		DELETE FROM $cfg->{dbPrefix}tickets WHERE userId = $dbUser->{id} AND type = 'usrReg'");

	# Log action
	$m->logAction(1, 'user', 'tkusrreg', $dbUser->{id});

	# Redirect		
	$m->redirect('forum');
}
# Login ticket (forgot password)
elsif ($ticket->{type} eq 'fgtPwd') {
	# Set cookies
	$m->setCookies($dbUser->{id}, $dbUser->{password}, $dbUser->{tempLogin}, $dbUser->{secureLogin});

	# Delete old sessions
	$m->dbDo("
		DELETE FROM $cfg->{dbPrefix}sessions 
		WHERE lastOnTime < $m->{now} - $cfg->{sessionTimeout} * 60");

	# Insert session
	$m->{sessionId} = $m->randomId();
	$m->dbDo("
		INSERT INTO $cfg->{dbPrefix}sessions (id, userId, lastOnTime, ip)
		VALUES ('$m->{sessionId}', $dbUser->{id}, $m->{now}, '$m->{env}{userIp}')");

	# Delete user's login tickets
	$m->dbDo("
		DELETE FROM $cfg->{dbPrefix}tickets WHERE userId = $dbUser->{id} AND type = 'fgtPwd'");

	# Log action
	$m->logAction(1, 'user', 'tkfgtpwd', $dbUser->{id});

	# Redirect		
	$m->redirect('user_password', msg => 'TkaFgtPwd');
}
# Email change ticket
elsif ($ticket->{type} eq 'emlChg') {
	# Change email address
	my $emailQ = $m->dbQuote($ticket->{data});
	$m->dbDo("
		UPDATE $cfg->{dbPrefix}users SET email = $emailQ WHERE id = $dbUser->{id}");
	
	# Delete all email change tickets
	$m->dbDo("
		DELETE FROM $cfg->{dbPrefix}tickets WHERE userId = $dbUser->{id} AND type = 'emlChg'");

	# Log action
	$m->logAction(1, 'user', 'tkemlchg', $dbUser->{id});
	
	# Redirect		
	$m->redirect('forum_show', msg => 'TkaEmlChg');
}
