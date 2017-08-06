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
our ($m, $cfg, $lng) = MwfMain->newShell(allowCgi => 1, upgrade => 1);
our $dbh = $m->{dbh};

# Autoflush stdout
$| = 1;
print "mwForum upgrade running...\n";

# Don't use this script for SQLite
#!$m->{sqlite} or $m->cfgError("Upgrade script not compatible with SQLite.");

# Determine old version 
our $newVersion = undef;
our $oldVersion = $m->fetchArray("
	SELECT value FROM $cfg->{dbPrefix}variables WHERE name = 'version'");
if (!$oldVersion) {
	# Work around missing version entries of new installations before 2.7.3
	if (existsColumn('topics', 'tag')) { $oldVersion = "2.7.2" }
	elsif (is270()) { $oldVersion = "2.7.0" }
	elsif (existsColumn('groups', 'id')) { $oldVersion = "2.5.1" }
	elsif (existsColumn('users', 'birthyear')) { $oldVersion = "2.5.0" }
	elsif (existsColumn('boards', 'attach')) { $oldVersion = "2.3.2" }
	else { $oldVersion = "2.3.1" }
}
our $oldVersionDec = tripletToDecimal($oldVersion);
print "Previous installation/upgrade version: $oldVersion\n";

#------------------------------------------------------------------------------
# Workaround helpers

sub existsColumn
{
	my $table = shift();
	my $column = shift();
	
	my $sth = $dbh->prepare("
		SELECT $column FROM $cfg->{dbPrefix}$table LIMIT 1");
	return 0 if !$sth;
	return $sth->execute() ? 1 : 0;
}

sub is270
{
	my $tz = $m->fetchArray("
		SELECT timezone FROM $cfg->{dbPrefix}users LIMIT 1");
	$tz =~ /^[+-]?\d+$/ ? return 1 : 0;
}

#------------------------------------------------------------------------------
# Convert "1.2.3" string into number

sub tripletToDecimal
{
	my $triplet = shift();

	my ($a,$b,$c) = split(/\./, $triplet);
	return $a*1000000 + $b*1000 + $c;
}

#------------------------------------------------------------------------------
# Modify SQL as necessary and execute as separate queries

sub upgradeLayout
{
	my $sql = shift();
	my $ignoreError = shift() || 0;

	# Add prefix to table names
	if ($cfg->{dbPrefix}) {
		$sql =~ s! ON ! ON $cfg->{dbPrefix}!g;
		$sql =~ s! INTO ! INTO $cfg->{dbPrefix}!g;
		$sql =~ s! FROM ! FROM $cfg->{dbPrefix}!g;
		$sql =~ s! TABLE ! TABLE $cfg->{dbPrefix}!g;
		$sql =~ s!UPDATE !UPDATE $cfg->{dbPrefix}!g;
	}
	
	# Change SQL for PgSQL and SQLite
	if ($m->{pgsql} || $m->{sqlite}) {
		$sql =~ s! AFTER \w+!!g;
	}
	if ($m->{pgsql}) {
		$sql =~ s!INT PRIMARY KEY AUTO_INCREMENT!SERIAL PRIMARY KEY!g;
		$sql =~ s! TINYINT ! SMALLINT !g;
	}
	elsif ($m->{sqlite}) {
		$sql =~ s!AUTO_INCREMENT!AUTOINCREMENT!g;
		$sql =~ s! INT ! INTEGER !g;
		$sql =~ s!.+ DROP .+!!g;
	}

	# Execute separate queries
	for (grep(/\w/, split(";", $sql))) {
		my $rv = $dbh->do($_);
		print "Error: $DBI::errstr\n" if !$rv && !$ignoreError;
	}
}

#------------------------------------------------------------------------------
#------------------------------------------------------------------------------

$newVersion = "2.3.2";

if ($oldVersionDec < tripletToDecimal($newVersion)) {
	print "$newVersion: upgrading database layout...\n";
	upgradeLayout("
		ALTER TABLE boards ADD attach TINYINT NOT NULL DEFAULT 0 AFTER flat;
		ALTER TABLE messages ADD inbox TINYINT NOT NULL DEFAULT 0 AFTER box;
		ALTER TABLE messages ADD sentbox TINYINT NOT NULL DEFAULT 0 AFTER inbox;
		UPDATE messages SET inbox = 1 WHERE box = 0;
		UPDATE messages SET sentbox = 1 WHERE box = 1;
		ALTER TABLE messages DROP box;
	");
	print "$newVersion: done.\n";
}

#------------------------------------------------------------------------------

$newVersion = "2.5.0";

if ($oldVersionDec < tripletToDecimal($newVersion)) {
	print "$newVersion: upgrading database layout...\n";
	upgradeLayout("
		ALTER TABLE posts DROP signature;
		ALTER TABLE boards DROP markup;
		ALTER TABLE posts DROP score;
		ALTER TABLE boards DROP score;
		ALTER TABLE users DROP votesLeft;
		ALTER TABLE users DROP votesDaily;
		ALTER TABLE users DROP threshold;
		ALTER TABLE users DROP baseScore;
		ALTER TABLE users ADD birthyear SMALLINT NOT NULL DEFAULT 0 AFTER extra3;
		ALTER TABLE users ADD birthday VARCHAR(5) NOT NULL DEFAULT '' AFTER birthyear;
		CREATE TABLE sessions (
			id           CHAR(32) PRIMARY KEY,
			userId       INT NOT NULL DEFAULT 0,
			lastOnTime   INT NOT NULL DEFAULT 0,
			ip           CHAR(15) NOT NULL DEFAULT ''
		);
	");
	print "$newVersion: done.\n";

	# Statically markup/highlight quotes
	print "$newVersion: statically highlighting quotes...\n";
	my $changeSum = 0;
	$m->dbBegin();
	eval {
		my $posts = $m->fetchAllHash("
			SELECT id, body FROM $cfg->{dbPrefix}posts");
		my $updSth = $m->dbPrepare("
			UPDATE $cfg->{dbPrefix}posts SET body = ? WHERE id = ?");
		for my $post (@$posts) {
			my $changeNum = $post->{body} =~
				s~(^|<br/>)((?:&gt;).*?)(?=(?:<br/>)+(?!&gt;)|$)~$1<blockquote>$2</blockquote>~g;
			$post->{body} =~ s~</blockquote>(?:<br/>){2,}~</blockquote><br/>~g;
			if ($changeNum) {
				$m->dbExecute($updSth, $post->{body}, $post->{id});
				$changeSum += $changeNum;
			}
		}
	};
	$@ ? $m->dbRollback() : $m->dbCommit();
	print "$newVersion: done ($changeSum).\n";
}

#------------------------------------------------------------------------------

$newVersion = "2.5.1";

if ($oldVersionDec < tripletToDecimal($newVersion)) {
	print "$newVersion: upgrading database layout...\n";
	upgradeLayout("
		CREATE TABLE groups (
			id           INT PRIMARY KEY AUTO_INCREMENT,
			title        VARCHAR(255) NOT NULL DEFAULT ''
		);
		CREATE TABLE groupMembers (
			userId       INT NOT NULL DEFAULT 0,
			groupId      INT NOT NULL DEFAULT 0,
			PRIMARY KEY (userId, groupId)
		);
		CREATE TABLE boardMemberGroups (
			groupId      INT NOT NULL DEFAULT 0,
			boardId      INT NOT NULL DEFAULT 0,
			PRIMARY KEY (groupId, boardId)
		);
		CREATE TABLE boardAdminGroups (
			groupId      INT NOT NULL DEFAULT 0,
			boardId      INT NOT NULL DEFAULT 0,
			PRIMARY KEY (groupId, boardId)
		);
		ALTER TABLE users ADD showImages TINYINT NOT NULL DEFAULT 0 AFTER showAvatars;
		UPDATE users SET showImages = 1;
	");
	print "$newVersion: done.\n";
}

#------------------------------------------------------------------------------

$newVersion = "2.7.0";

if ($oldVersionDec < tripletToDecimal($newVersion)) {
	print "$newVersion: upgrading database layout...\n";
	upgradeLayout("
		UPDATE users SET timezone = '0';
		UPDATE config SET value = '0' WHERE name = 'userTimezone';
	");
	print "$newVersion: done.\n";

	# Fix blockquotes to conform to standard, they need a block inside
	print "$newVersion: fixing blockquotes...\n";
	my $changeSum = 0;
	$m->dbBegin();
	eval {
		my $posts = $m->fetchAllHash("
			SELECT id, body FROM $cfg->{dbPrefix}posts");
		my $updSth = $m->dbPrepare("
			UPDATE $cfg->{dbPrefix}posts SET body = ? WHERE id = ?");
		for my $post (@$posts) {
			my $changeNum = $post->{body} =~
				s~<blockquote>(?!<p>)(.*?)</blockquote>~<blockquote><p>$1</p></blockquote>~g;
			if ($changeNum) {
				$m->dbExecute($updSth, $post->{body}, $post->{id});
				$changeSum += $changeNum;
			}
		}
	};
	$@ ? $m->dbRollback() : $m->dbCommit();
	print "$newVersion: done ($changeSum).\n";
}

#------------------------------------------------------------------------------

$newVersion = "2.7.2";

if ($oldVersionDec < tripletToDecimal($newVersion)) {
	print "$newVersion: upgrading database layout...\n";
	upgradeLayout("
		ALTER TABLE topics ADD tag      VARCHAR(20) NOT NULL DEFAULT '' AFTER subject;
		ALTER TABLE users  ADD showDeco TINYINT NOT NULL DEFAULT 0 AFTER boardDescs;
		UPDATE users SET showDeco = 1;
	");
	print "$newVersion: done.\n";
}

#------------------------------------------------------------------------------

$newVersion = "2.9.0";

if ($oldVersionDec < tripletToDecimal($newVersion)) {
	print "$newVersion: upgrading database layout...\n";
	upgradeLayout("
		CREATE TABLE topicSubscriptions (
			userId       INT NOT NULL DEFAULT 0,
			topicId      INT NOT NULL DEFAULT 0,
			PRIMARY KEY (userId, topicId)
		);
		CREATE TABLE notes (
			id           INT PRIMARY KEY AUTO_INCREMENT,
			userId       INT NOT NULL DEFAULT 0,
			sendTime     INT NOT NULL DEFAULT 0,
			body         TEXT NOT NULL DEFAULT ''
		);
		CREATE INDEX notes_userId ON notes (userId);
		ALTER TABLE users DROP adminMsg;
		ALTER TABLE posts DROP notify;
		UPDATE users SET notify = 1;
		UPDATE users SET msgNotify = 0;
		UPDATE config SET value = '1' WHERE name = 'notify';
		UPDATE config SET value = '0' WHERE name = 'msgNotify';
	");
	print "$newVersion: done.\n";
}

#------------------------------------------------------------------------------

$newVersion = "2.9.2";

if ($oldVersionDec < tripletToDecimal($newVersion)) {
	print "$newVersion: upgrading database layout...\n";
	upgradeLayout("
		CREATE TABLE attachments (
			id           INT PRIMARY KEY AUTO_INCREMENT,
			postId       INT NOT NULL DEFAULT 0,
			webImage     TINYINT NOT NULL DEFAULT 0,
			fileName     VARCHAR(255) NOT NULL DEFAULT ''
		);
		DELETE FROM tickets WHERE type = 'cptcha';
	");
	print "$newVersion: done.\n";
	
	# Move attachments to their own table
	print "$newVersion: moving attachment entries to their own table...\n";
	my $changeSum = 0;
	$m->dbBegin();
	eval {
		my $posts = $m->fetchAllArray("
			SELECT id, attach, attachEmbed FROM $cfg->{dbPrefix}posts WHERE attach <> '' ORDER BY id");
		for my $post (@$posts) {
			my $webImage = $post->[1] =~ /\.(?:jpg|png|gif)$/i ? 1 : 0;
			$webImage = 2 if $post->[2] && $webImage;
			$m->dbDo("
				INSERT INTO $cfg->{dbPrefix}attachments (postId, webImage, fileName)
				VALUES ($post->[0], $webImage, '$post->[1]')");
			$changeSum++;
		}
	};
	print "$newVersion: done ($changeSum).\n";

	print "$newVersion: upgrading database layout, part 2...\n";
	upgradeLayout("
		ALTER TABLE posts DROP attach;
		ALTER TABLE posts DROP attachEmbed;
		CREATE INDEX attachments_postId ON attachments (postId);
	");
	print "$newVersion: done.\n";
}

#------------------------------------------------------------------------------

$newVersion = "2.11.0";

if ($oldVersionDec < tripletToDecimal($newVersion)) {
	print "$newVersion: upgrading database layout...\n";
	upgradeLayout("
		ALTER TABLE boards ADD list TINYINT NOT NULL DEFAULT 0 AFTER private;
		CREATE INDEX messages_senderId ON messages (senderId);
	");
	print "$newVersion: done.\n";
}

#------------------------------------------------------------------------------

$newVersion = "2.11.1";

if ($oldVersionDec < tripletToDecimal($newVersion)) {
	print "$newVersion: upgrading database layout...\n";
	upgradeLayout("
		DROP INDEX email ON users;
		DROP INDEX users_email ON users;
	", 1);
	print "$newVersion: done.\n";
}

#------------------------------------------------------------------------------
#------------------------------------------------------------------------------

# Insert new version variable
$m->dbDo("
	DELETE FROM $cfg->{dbPrefix}variables WHERE name = 'version'");
$m->dbDo("
	INSERT INTO $cfg->{dbPrefix}variables (name, value) VALUES ('version', '$newVersion')");
print "mwForum upgrade done.\n";
