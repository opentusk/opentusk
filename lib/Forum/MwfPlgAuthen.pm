#------------------------------------------------------------------------------
#    mwForum - Web-based discussion forum
#    Copyright (c) 1999-2007 Markus Wichitill
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#------------------------------------------------------------------------------

package MwfPlgAuthen;
use strict;
use warnings;
no warnings qw(uninitialized redefine);
$MwfPlgAuthen::VERSION = "2.7.3";

# Imports
use Forum::MwfMain;

# TUSK - added
use Forum::ForumKey;
use Apache::TicketTool;
use Apache::Constants qw(REDIRECT);
use HSDB4::Constants;
use HSDB4::SQLRow::User;
use TUSK::ErrorReport;
use Data::Dumper;


#------------------------------------------------------------------------------
# TUSK:
# Authenticate user via HTTP authentication on every request.
# Create account if necessary.
# The actual name/pwd verification is done by the webserver.
# 
sub authenRequestHttp
{
	my %params = @_;
	
	my $m = $params{"m"};
	my $cfg = $m->{"cfg"};
	# Get user's authenticated name from $m->{env}, 
	# where mwForum copies it from REMOTE_USER or the mod_perl equivalent.
	# This username is a user's UTLN from TUSK
	my $userName = $m->{env}{userAuth};

	# If there is no userName, it means we are trying to logout.
	if (!$userName) {
	    return $userName;
	}

	# Format the username so it can be used easily in an SQL statement
	my $userNameQ = $m->dbQuote($userName);

	# Search for the username in the forum database
	my $dbUser = $m->fetchHash("SELECT * FROM " . $m->{cfg}->{dbPrefix} . "users WHERE userName = " . $userNameQ);

	# if we don't find a user in the forum database, create a new user, and populate with information from TUSK
	if (!$dbUser) {
	    
	    # create a TUSK user object where we will extract new user information

	    my $user = HSDB4::SQLRow::User->new();
		my $shibUserID = -1;
                $shibUserID = TUSK::ShibbolethUser->isShibUser($userName);
                if($shibUserID > -1) {
                        # If we are a shib user and we are allowing shib users then make a ghost user
                        $user->makeGhost($shibUserID);
                } else {
                        # Otherwise look up the user id which will be nothing for a shib user or a guest
                        $user->lookup_key($userName);
                }

	    $m->{user_object} = $user;
	    my $realName = $user->first_name() . " " . $user->last_name();

	    # Insert user, we don't need to use dbQuote for these values because it will be called in the createUser fn.

	    my $userId = $m->createUser(
					userName => $userName,
					realName => $realName,
					email => $user->preferred_email() || $user->email(),
					extra1 => "",  # these "extra" fields cannot be null, or else the db will give an error
					extra2 => "",
					extra3 => "",
					admin => ($m->{forumAdmin} == 1) ? 1:0,
					);


	    # Check permissions table to see if this user is also a moderator for any boards
	    my $dbh = HSDB4::Constants::def_db_handle();
	    my $sth = $dbh->prepare("INSERT INTO $cfg->{dbPrefix}boardAdmins (userId, boardId) SELECT $userId as userId, permissions.boardId as boardId FROM $cfg->{dbPrefix}permissions as permissions WHERE permissions.userName = ? AND permissions = 'Moderator'");
	    $sth->execute($userName);
	    
	    # Get freshly created user
	    $dbUser = $m->getUser($userId);
	}

	# Update user's previous online time, actually, we don't need to do this, it is already done.
	# It is done when someone runs forum.pl (when someone really "logs in").  perfect for our uses, 
	# so TUSK can still display all new/unread content on the front page until someone actually clicks into the forum.



	# This query deletes old session data only
	$m->dbDo("DELETE FROM $cfg->{dbPrefix}sessions WHERE lastOnTime < $m->{now} - $cfg->{sessionTimeout} * 15");

	# This query would delete the session and the viewableBoard data associated with it.
	#$m->dbDo("DELETE $cfg->{dbPrefix}sessions, $cfg->{dbPrefix}variables 
        #          FROM $cfg->{dbPrefix}sessions, $cfg->{dbPrefix}variables
        #          WHERE $cfg->{dbPrefix}sessions.lastOnTime < $m->{now} - $cfg->{sessionTimeout} * 15
        #          AND $cfg->{dbPrefix}sessions.userId = $cfg->{dbPrefix}variables.userId
        #          AND $cfg->{dbPrefix}variables.value = 'viewableBoard'");
	
	

	
	# if the user is logging in, then we need to construct a list of viewable boards
	# and insert a new session, and log it.  Check if user is logging in by checking
	# for an entry in the sessions table.

	# Checking for a sessionId
	my $sessionId = $m->fetchArray("
            SELECT id FROM $cfg->{dbPrefix}sessions WHERE userId = $dbUser->{id}");

	# if there is no session id, then that means we are logging in
	# Create a new sessionid, log it, and create a list of viewable categories
	if (!$sessionId)
	{
	    # Insert session
	    #$m->{sessionId} = $m->randomId();
	    $sessionId = $m->randomId();

	    $m->dbDo("
		INSERT INTO $cfg->{dbPrefix}sessions (id, userId, lastOnTime, ip)
		VALUES ('$sessionId', $dbUser->{id}, $m->{now}, '$m->{env}{userIp}')");

	    # Log action
	    $m->logAction(1, 'user', 'login', $dbUser->{id});

	    # Delete old board list
	    $m->dbDo("
                    DELETE FROM $cfg->{dbPrefix}variables
                    WHERE userId = $dbUser->{id} AND value = 'viewableBoard'");

	    # Repopulate new board list
	    if ($dbUser->{admin})
            {
		$m->dbDo("INSERT INTO $cfg->{dbPrefix}variables (name, userId, value)
                          SELECT boards.id AS name,
                                 $dbUser->{id} AS userId,
                                 'viewableBoard' AS value
                          FROM $cfg->{dbPrefix}boards AS boards");
            }
	    else 
	    {

		# Find and store the list of boards that a user can see.
		my @keys = (ref $m->{board_keys} eq 'ARRAY') ? @{ $m->{board_keys} } : Forum::ForumKey::getBoardKeys($userName); # queries the tusk database
		my $keyList = Forum::ForumKey::formatKeyList(@keys);

		my $sql = "
                       SELECT boards.id AS name
                       FROM $cfg->{dbPrefix}boards AS boards LEFT JOIN $cfg->{dbPrefix}permissions ON (permissions.boardId=boards.id AND permissions.userName = '$userName')
                       WHERE boards.boardKey IN ($keyList) 
                           AND (permissions.userName is null  
                               OR permissions.permissions != 'Banned')
                       UNION DISTINCT
                       SELECT boardId AS name FROM $cfg->{dbPrefix}permissions WHERE userName = '$userName' AND permissions != 'Banned';
                        ";

		my $rows = $m->fetchAllArray($sql);
		
		foreach my $row (@$rows){
		    $m->dbDo("INSERT INTO $cfg->{dbPrefix}variables (name, userId, value) values('" . $row->[0] . "','" . $dbUser->{id} . "','viewableboard')");
		}
		# Filter additions and deletions of viewableBoards here, we could not do it before
		# because they were using board keys, which may be shared between boards (most boards
		# in the same category have the same key, the exception to this is the courses category.

	    }
	}
	
        # Return user
	return $dbUser;
}


#------------------------------------------------------------------------------
# Logout the user in TUSK.  This clears any mwforum.sessions entries for the
# user that is currently logging out.
sub logout
{
    my @params = @_;
    my $user_id = $params[0];

    my $r = Apache->request;
    my $m = MwfMain->new($r, 0, 1);
    my $cfg = $m->{"cfg"};
    my $user_idQ = $m->dbQuote($user_id);
    $m->logAction(1, 'user', 'logout', $user_idQ);

    if ($user_id) {
	my $sql = "DELETE $cfg->{dbPrefix}sessions FROM $cfg->{dbPrefix}sessions, $cfg->{dbPrefix}users WHERE sessions.userId = users.id AND users.userName = ?";
	my $dbh = HSDB4::Constants::def_db_handle();
	my $sth = $dbh->prepare($sql);
	$sth->execute($user_id);

	$sql = "DELETE $cfg->{dbPrefix}variables 
                FROM $cfg->{dbPrefix}variables, $cfg->{dbPrefix}users 
                WHERE variables.userId = users.id 
                AND (variables.value = 'viewableBoard' OR variables.name = 'is_author')
                AND users.userName = ?";
	$sth = $dbh->prepare($sql);
	$sth->execute($user_id);

    }

    return 1;
}






#------------------------------------------------------------------------------
# Authenticate user via email field in SSL client certificate on every request.
# Create account if necessary.
# The actual certificate verification is done by mod_ssl, the rest is similar
# to HTTP authentication.

sub authenRequestSsl
{
	my %params = @_;
	my $m = $params{m};
	
	# Shortcuts
	my $cfg = $m->{cfg};

	# Get user's email address and common name from certificate
	my $email;
	my $userName;
	if (MwfMain::MP) {
		$email = $m->{ap}->subprocess_env->{SSL_CLIENT_S_DN_Email};
		$userName = $m->{ap}->subprocess_env->{SSL_CLIENT_S_DN_CN} || $email;
	}
	else {
		$email = $ENV{SSL_CLIENT_S_DN_Email};
		$userName = $ENV{SSL_CLIENT_S_DN_CN} || $email;
	}

	# Return undef if cert is valid but email is empty
	return undef if !$email;
	
	# Get user
	my $emailQ = $m->dbQuote($email);
	my $dbUser = $m->fetchHash("
		SELECT * FROM $cfg->{dbPrefix}users WHERE email = $emailQ");
	
	# If there's no user account for that email address, create one
	if (!$dbUser) {
		# Insert user
		my $userId = $m->createUser(
			userName => $userName,
			email => $email,
		);
		
		# Get freshly created user
		$dbUser = $m->getUser($userId);
	}
	
	# Return user
	return $dbUser;
}

#------------------------------------------------------------------------------
# Authenticate user on login only, use normal cookie authentication after that.
# Validate name/pwd against external database, create account if necessary.

sub authenLoginSql
{
	my %params = @_;
	my $m = $params{m};
	my $userName = $params{userName};
	my $password = $params{password};
	
	# Shortcuts
	my $cfg = $m->{cfg};
	
	# For testing purposes, check name/pwd against mwForum users table
	# This would normally check an external data source
	my $userNameQ = $m->dbQuote($userName);
	my $extUser = $m->fetchHash("
		SELECT password, salt, email FROM $cfg->{dbPrefix}users WHERE userName = $userNameQ");
	$extUser && $extUser->{password} eq $m->md5($password . $extUser->{salt}) 
		or return undef;
	
	# Get local user
	my $dbUser = $m->fetchHash("
		SELECT * FROM $cfg->{dbPrefix}users WHERE userName = $userNameQ");
		
	# If the accepted password isn't the same as the local anymore, update local
	# since the mwForum cookies will be checked against that in future requests
	my $passwordMd5 = $m->md5($password . $dbUser->{salt});
	$m->dbDo("
		UPDATE $cfg->{dbPrefix}users SET password = '$passwordMd5' WHERE id = $dbUser->{id}")
		if $dbUser->{password} ne $passwordMd5;

	# If there's no local user for that name, create one
	if (!$dbUser) {
		# Insert user
		my $userId = $m->createUser(
			userName => $userName,
			email => $extUser->{email},
			password => $password,
			# [...]
		);
		
		# Get freshly created user
		$dbUser = $m->getUser($userId);
	}

	# Return user
	return $dbUser;
}

#------------------------------------------------------------------------------
1;
