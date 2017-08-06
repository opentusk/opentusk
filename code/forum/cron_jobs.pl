#!/usr/bin/env perl
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

#------------------------------------------------------------------------------

# Init
my ($m, $cfg, $lng) = MwfMain->newShell();

#------------------------------------------------------------------------------
# Begin one big transaction

$m->dbBegin();
eval {

#------------------------------------------------------------------------------
# Expire old topics

# Get boards	
my $boards = $m->fetchAllHash("
	SELECT id, expiration FROM $cfg->{dbPrefix}boards WHERE expiration > 0");

# For each board
for my $board (@$boards) {
	# Get topics
	my $topics = $m->fetchAllArray("
		SELECT id
		FROM $cfg->{dbPrefix}topics 
		WHERE boardId = $board->{id}
			AND lastPostTime > 0
			AND lastPostTime < $m->{now} - $board->{expiration} * 86400
			AND sticky = 0");

	$m->deleteTopic($_->[0]) for @$topics;
}

#------------------------------------------------------------------------------
# Expire old topics in blogs

if ($cfg->{blogExpiration}) {
	# Get topics
	my $topics = $m->fetchAllArray("
		SELECT id
		FROM $cfg->{dbPrefix}topics 
		WHERE boardId < 0
			AND lastPostTime > 0
			AND lastPostTime < $m->{now} - $cfg->{blogExpiration} * 86400");
	
	$m->deleteTopic($_->[0]) for @$topics;
}

#------------------------------------------------------------------------------
# Lock old topics

# Get boards	
$boards = $m->fetchAllHash("
	SELECT id, locking FROM $cfg->{dbPrefix}boards WHERE locking > 0");

# Lock topics
$m->dbDo("
	UPDATE $cfg->{dbPrefix}topics SET 
		locked = 1 
	WHERE boardId = $_->{id}
		AND locked = 0
		AND sticky = 0
		AND lastPostTime < $m->{now} - $_->{locking} * 86400")
	for @$boards;

#------------------------------------------------------------------------------
# Lock huge, performance-killing topics

if ($cfg->{hugeTpcLocking}) {
	$m->dbDo("
		UPDATE $cfg->{dbPrefix}topics SET
			locked = 1
		WHERE locked = 0
			AND postNum >= $cfg->{hugeTpcLocking}");
}

#------------------------------------------------------------------------------
# Lock polls in locked topics

if ($cfg->{polls} && $cfg->{pollLocking}) {
	# Get locked topics with unlocked polls
	my $topics = $m->fetchAllArray("
		SELECT pollId
		FROM $cfg->{dbPrefix}topics AS topics
			INNER JOIN $cfg->{dbPrefix}polls AS polls
				ON polls.id = topics.pollId
		WHERE topics.locked = 1
			AND polls.locked = 0");

	# For each topic
	for my $topic (@$topics) {
		# Consolidate votes
		my $voteSums = $m->fetchAllArray("
			SELECT optionId, COUNT(*)
			FROM $cfg->{dbPrefix}pollVotes
			WHERE pollId = $topic->[0]
			GROUP BY optionId");
		
		# Set option sums
		$m->dbDo("
			UPDATE $cfg->{dbPrefix}pollOptions SET votes = $_->[1] WHERE id = $_->[0]")
			for @$voteSums;
		
		# Mark poll as locked
		$m->dbDo("
			UPDATE $cfg->{dbPrefix}polls SET locked = 1 WHERE id = $topic->[0]");
	
		# Delete individual votes
		$m->dbDo("
			DELETE FROM $cfg->{dbPrefix}pollVotes WHERE pollId = $topic->[0]");
	}
}

#------------------------------------------------------------------------------
# Lock polls after x days

if ($cfg->{polls} && $cfg->{pollLockTime}) {
	# Get topics with unlocked polls
	my $topics = $m->fetchAllArray("
		SELECT pollId
		FROM $cfg->{dbPrefix}topics AS topics
			INNER JOIN $cfg->{dbPrefix}polls AS polls
				ON polls.id = topics.pollId
		WHERE polls.locked = 0
			AND topics.lastPostTime < $m->{now} - $cfg->{pollLockTime} * 86400");

	# For each topic
	for my $topic (@$topics) {
		# Consolidate votes
		my $voteSums = $m->fetchAllArray("
			SELECT optionId, COUNT(*)
			FROM $cfg->{dbPrefix}pollVotes
			WHERE pollId = $topic->[0]
			GROUP BY optionId");
		
		# Set option sums
		$m->dbDo("
			UPDATE $cfg->{dbPrefix}pollOptions SET votes = $_->[1] WHERE id = $_->[0]")
			for @$voteSums;
		
		# Mark poll as locked
		$m->dbDo("
			UPDATE $cfg->{dbPrefix}polls SET locked = 1 WHERE id = $topic->[0]");
	
		# Delete individual votes
		$m->dbDo("
			DELETE FROM $cfg->{dbPrefix}pollVotes WHERE pollId = $topic->[0]");
	}
}

#------------------------------------------------------------------------------
# Recalc board/topic statistics

# Recalculate boards stats
$boards = $m->fetchAllArray("
	SELECT id FROM $cfg->{dbPrefix}boards");
for my $board (@$boards) {
	my ($postNum, $lastPostTime) = $m->fetchArray("
		SELECT COUNT(*), MAX(postTime) FROM $cfg->{dbPrefix}posts WHERE boardId = $board->[0]");
	$lastPostTime ||= 0;
	$m->dbDo("
		UPDATE $cfg->{dbPrefix}boards SET
			postNum = $postNum,
			lastPostTime = $lastPostTime 
		WHERE id = $board->[0]");
}	

# Recalculate topics stats
my $topics = $m->fetchAllArray("
	SELECT id FROM $cfg->{dbPrefix}topics");
for my $topic (@$topics) {
	my ($postNum, $lastPostTime) = $m->fetchArray("
		SELECT COUNT(*), MAX(postTime) FROM $cfg->{dbPrefix}posts WHERE topicId = $topic->[0]");
	$lastPostTime ||= 0;
	$m->dbDo("
		UPDATE $cfg->{dbPrefix}topics SET
			postNum = $postNum,
			lastPostTime = $lastPostTime
		WHERE id = $topic->[0]");
}	

#------------------------------------------------------------------------------
# Expire users that haven't logged in for a while

if ($cfg->{userExpiration}) {
	my $havingStr = $cfg->{noUserPostsExp} ? "HAVING COUNT(posts.id) = 0" : "";
	
	my $users = $m->fetchAllArray("
		SELECT users.id
		FROM $cfg->{dbPrefix}users AS users
			LEFT JOIN $cfg->{dbPrefix}posts AS posts
				ON posts.userId = users.id
		WHERE users.admin = 0
			AND users.lastOnTime < $m->{now} - $cfg->{userExpiration} * 86400
			AND users.regTime < $m->{now} - $cfg->{userExpiration} * 86400
		GROUP BY users.id
		$havingStr");
	
	$m->deleteUser($_->[0]) for @$users;
}

#------------------------------------------------------------------------------
# Expire users that have never logged in

if ($cfg->{acctExpiration}) {
	my $users = $m->fetchAllArray("
		SELECT id
		FROM $cfg->{dbPrefix}users 
		WHERE regTime = lastOnTime
			AND regTime < $m->{now} - $cfg->{acctExpiration} * 86400");
		
	$m->deleteUser($_->[0]) for @$users;
}

#------------------------------------------------------------------------------
# Expire board and topic subscriptions

if ($cfg->{subsExpiration}) {
	my $users = $m->fetchAllArray("
		SELECT id 
		FROM $cfg->{dbPrefix}users 
		WHERE lastOnTime < $m->{now} - $cfg->{subsExpiration} * 86400");

	for my $user (@$users) {
		$m->dbDo("
			DELETE FROM $cfg->{dbPrefix}boardSubscriptions WHERE userId = $user->[0]");
		$m->dbDo("
			DELETE FROM $cfg->{dbPrefix}topicSubscriptions WHERE userId = $user->[0]");
	}
}

#------------------------------------------------------------------------------
# Expire user bans

$m->dbDo("
	DELETE FROM $cfg->{dbPrefix}userBans 
	WHERE duration > 0	
		AND banTime < $m->{now} - duration * 86400");

#------------------------------------------------------------------------------
# Expire topic read times

if ($cfg->{maxUnreadDays}) {
	$m->dbDo("
		DELETE FROM $cfg->{dbPrefix}topicReadTimes
		WHERE lastReadTime < $m->{now} - $cfg->{maxUnreadDays} * 86400");
}

#------------------------------------------------------------------------------
# Expire chat messages (also happens in chat_add)

if ($cfg->{chatMaxAge}) {
	$m->dbDo("
		DELETE FROM $cfg->{dbPrefix}chat
		WHERE postTime < $m->{now} - $cfg->{chatMaxAge} * 86400");
}

#------------------------------------------------------------------------------
# Expire private messages

if ($cfg->{msgExpiration}) {
	$m->dbDo("
		DELETE FROM $cfg->{dbPrefix}messages
		WHERE sendTime < $m->{now} - $cfg->{msgExpiration} * 86400");
}

#------------------------------------------------------------------------------
# Expire notification messages

$m->dbDo("
	DELETE FROM $cfg->{dbPrefix}notes WHERE sendTime < $m->{now} - 21 * 86400");

#------------------------------------------------------------------------------
# Expire tickets

$m->dbDo("
	DELETE FROM $cfg->{dbPrefix}tickets WHERE issueTime < $m->{now} - 3 * 86400");

#------------------------------------------------------------------------------
# Expire birthdays

if ($cfg->{bdayExpiration}) {
	$m->dbDo("
		UPDATE $cfg->{dbPrefix}users SET 
			birthyear = 0,
			birthday = ''
		WHERE lastOnTime < $m->{now} - $cfg->{bdayExpiration} * 86400");
}

#------------------------------------------------------------------------------
# Change request source authentication values

my $rndStr = undef;
if ($m->{mysql}) { $rndStr = "FLOOR(RAND() * 2147483647)" }
elsif ($m->{pgsql}) { $rndStr = "FLOOR(RANDOM() * 2147483647)" }
elsif ($m->{sqlite}) { $rndStr = "RANDOM() & 2147483647" }
$m->dbDo("
	UPDATE $cfg->{dbPrefix}users SET sourceAuth = $rndStr");

#------------------------------------------------------------------------------
# Decrease users.bounceNum and reset countermeasures

if ($cfg->{bounceTrshWarn} || $cfg->{bounceTrshCncl} || $cfg->{bounceTrshDsbl}) {
	my $bounceFactor = $cfg->{bounceFactor} || 3;
	my $dsblTrsh = $cfg->{bounceTrshDsbl} * $bounceFactor;

	# Decrease bounceNum	
	$m->dbDo("
		UPDATE $cfg->{dbPrefix}users SET bounceNum = bounceNum - 1 WHERE bounceNum > 0");

	# Reset users.dontEmail if disable threshold is used
	$m->dbDo("
		UPDATE $cfg->{dbPrefix}users SET dontEmail = 0 WHERE bounceNum < $dsblTrsh") 
		if $dsblTrsh;
}

#------------------------------------------------------------------------------
# End big transaction

};
$@ ? $m->dbRollback() : $m->dbCommit();

#------------------------------------------------------------------------------
# Call local script

system "cron_jobs_local$m->{ext}" if -x "cron_jobs_local$m->{ext}";

#------------------------------------------------------------------------------
# Optimize tables (except logs)

if ($m->{mysql}) {
	$m->dbDo("OPTIMIZE TABLE $cfg->{dbPrefix}attachments");
	$m->dbDo("OPTIMIZE TABLE $cfg->{dbPrefix}boardAdminGroups");
	$m->dbDo("OPTIMIZE TABLE $cfg->{dbPrefix}boardAdmins");
	$m->dbDo("OPTIMIZE TABLE $cfg->{dbPrefix}boardHiddenFlags");
	$m->dbDo("OPTIMIZE TABLE $cfg->{dbPrefix}boardMemberGroups");
	$m->dbDo("OPTIMIZE TABLE $cfg->{dbPrefix}boardMembers");
	$m->dbDo("OPTIMIZE TABLE $cfg->{dbPrefix}boards");
	$m->dbDo("OPTIMIZE TABLE $cfg->{dbPrefix}boardSubscriptions");
	$m->dbDo("OPTIMIZE TABLE $cfg->{dbPrefix}categories");
	$m->dbDo("OPTIMIZE TABLE $cfg->{dbPrefix}chat");
	$m->dbDo("OPTIMIZE TABLE $cfg->{dbPrefix}config");
	$m->dbDo("OPTIMIZE TABLE $cfg->{dbPrefix}groupMembers");
	$m->dbDo("OPTIMIZE TABLE $cfg->{dbPrefix}groups");
	$m->dbDo("OPTIMIZE TABLE $cfg->{dbPrefix}messages");
	$m->dbDo("OPTIMIZE TABLE $cfg->{dbPrefix}notes");
	$m->dbDo("OPTIMIZE TABLE $cfg->{dbPrefix}pollOptions");
	$m->dbDo("OPTIMIZE TABLE $cfg->{dbPrefix}polls");
	$m->dbDo("OPTIMIZE TABLE $cfg->{dbPrefix}pollVotes");
	$m->dbDo("OPTIMIZE TABLE $cfg->{dbPrefix}postReports");
	$m->dbDo("OPTIMIZE TABLE $cfg->{dbPrefix}posts");
	$m->dbDo("OPTIMIZE TABLE $cfg->{dbPrefix}postTodos");
	$m->dbDo("OPTIMIZE TABLE $cfg->{dbPrefix}sessions");
	$m->dbDo("OPTIMIZE TABLE $cfg->{dbPrefix}tickets");
	$m->dbDo("OPTIMIZE TABLE $cfg->{dbPrefix}topicReadTimes");
	$m->dbDo("OPTIMIZE TABLE $cfg->{dbPrefix}topics");
	$m->dbDo("OPTIMIZE TABLE $cfg->{dbPrefix}topicSubscriptions");
	$m->dbDo("OPTIMIZE TABLE $cfg->{dbPrefix}userBans");
	$m->dbDo("OPTIMIZE TABLE $cfg->{dbPrefix}userIgnores");
	$m->dbDo("OPTIMIZE TABLE $cfg->{dbPrefix}users");
	$m->dbDo("OPTIMIZE TABLE $cfg->{dbPrefix}variables");
}
elsif ($m->{pgsql}) {
	$m->dbDo("VACUUM ANALYZE $cfg->{dbPrefix}attachments");
	$m->dbDo("VACUUM ANALYZE $cfg->{dbPrefix}boardAdminGroups");
	$m->dbDo("VACUUM ANALYZE $cfg->{dbPrefix}boardAdmins");
	$m->dbDo("VACUUM ANALYZE $cfg->{dbPrefix}boardHiddenFlags");
	$m->dbDo("VACUUM ANALYZE $cfg->{dbPrefix}boardMemberGroups");
	$m->dbDo("VACUUM ANALYZE $cfg->{dbPrefix}boardMembers");
	$m->dbDo("VACUUM ANALYZE $cfg->{dbPrefix}boards");
	$m->dbDo("VACUUM ANALYZE $cfg->{dbPrefix}boardSubscriptions");
	$m->dbDo("VACUUM ANALYZE $cfg->{dbPrefix}categories");
	$m->dbDo("VACUUM ANALYZE $cfg->{dbPrefix}chat");
	$m->dbDo("VACUUM ANALYZE $cfg->{dbPrefix}config");
	$m->dbDo("VACUUM ANALYZE $cfg->{dbPrefix}groupMembers");
	$m->dbDo("VACUUM ANALYZE $cfg->{dbPrefix}groups");
	$m->dbDo("VACUUM ANALYZE $cfg->{dbPrefix}messages");
	$m->dbDo("VACUUM ANALYZE $cfg->{dbPrefix}notes");
	$m->dbDo("VACUUM ANALYZE $cfg->{dbPrefix}pollOptions");
	$m->dbDo("VACUUM ANALYZE $cfg->{dbPrefix}polls");
	$m->dbDo("VACUUM ANALYZE $cfg->{dbPrefix}pollVotes");
	$m->dbDo("VACUUM ANALYZE $cfg->{dbPrefix}postReports");
	$m->dbDo("VACUUM ANALYZE $cfg->{dbPrefix}posts");
	$m->dbDo("VACUUM ANALYZE $cfg->{dbPrefix}postTodos");
	$m->dbDo("VACUUM ANALYZE $cfg->{dbPrefix}sessions");
	$m->dbDo("VACUUM ANALYZE $cfg->{dbPrefix}tickets");
	$m->dbDo("VACUUM ANALYZE $cfg->{dbPrefix}topicReadTimes");
	$m->dbDo("VACUUM ANALYZE $cfg->{dbPrefix}topics");
	$m->dbDo("VACUUM ANALYZE $cfg->{dbPrefix}topicSubscriptions");
	$m->dbDo("VACUUM ANALYZE $cfg->{dbPrefix}userBans");
	$m->dbDo("VACUUM ANALYZE $cfg->{dbPrefix}userIgnores");
	$m->dbDo("VACUUM ANALYZE $cfg->{dbPrefix}users");
	$m->dbDo("VACUUM ANALYZE $cfg->{dbPrefix}variables");
}	
elsif ($m->{sqlite}) {
	$m->dbDo("VACUUM");
	$m->dbDo("ANALYZE", 1);
}	

#------------------------------------------------------------------------------
# Log action

$m->logAction(1, 'cron', 'exec');
