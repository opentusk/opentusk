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

my ($m, $cfg, $lng) = MwfMain->newShell(allowCgi => 1, upgrade => 1);
my $dbh = $m->{dbh};

# Autoflush stdout
$| = 1;
print "mwForum installation running...\n";
print "Creating tables...\n";

#------------------------------------------------------------------------------
# SQL

my $sql = "

CREATE TABLE config (
	name         VARCHAR(14) PRIMARY KEY DEFAULT '', -- Forum option name
	value        TEXT NOT NULL DEFAULT '',           -- Forum option value
	parse        VARCHAR(10) NOT NULL DEFAULT ''     -- ''=scalar, 'hash', 'array'
);

CREATE TABLE users (
	id           INT PRIMARY KEY AUTO_INCREMENT,     -- User id
	userName     VARCHAR(255) NOT NULL DEFAULT '',   -- Account name
	realName     VARCHAR(255) NOT NULL DEFAULT '',   -- Real name
	email        VARCHAR(255) NOT NULL DEFAULT '',   -- Email address
	password     VARCHAR(32) NOT NULL DEFAULT '',    -- Password MD5
	salt         INT NOT NULL DEFAULT 0,             -- Password salt, secret from cookie thieves
	title        TEXT NOT NULL DEFAULT '',           -- Title displayed after username in some places
	admin        TINYINT NOT NULL DEFAULT 0,         -- Is user a forum admin?
	hideEmail    TINYINT NOT NULL DEFAULT 0,         -- Hide email address from other users?
	dontEmail    TINYINT NOT NULL DEFAULT 0,         -- Don't send email to this user?
	notify       TINYINT NOT NULL DEFAULT 0,         -- Notify of post replies?
	msgNotify    TINYINT NOT NULL DEFAULT 0,         -- Send important notification by email?
	manOldMark   TINYINT NOT NULL DEFAULT 0,         -- Mark posts as old manually only?
	tempLogin    TINYINT NOT NULL DEFAULT 0,         -- Use temporary cookies?
	secureLogin  TINYINT NOT NULL DEFAULT 0,         -- Use secure (SSL-only) cookies?
	privacy      TINYINT NOT NULL DEFAULT 0,         -- Don't show name on online-users list
	homepage     VARCHAR(255) NOT NULL DEFAULT '',   -- Homepage URL
	occupation   VARCHAR(255) NOT NULL DEFAULT '',   -- Job
	hobbies      VARCHAR(255) NOT NULL DEFAULT '',   -- Hobbies
	location     VARCHAR(255) NOT NULL DEFAULT '',   -- Geographical location
	icq          VARCHAR(255) NOT NULL DEFAULT '',   -- Instant messenger IDs
	avatar       VARCHAR(255) NOT NULL DEFAULT '',   -- Avatar image extension if available
	signature    TEXT NOT NULL DEFAULT '',           -- Signature
	extra1       TEXT NOT NULL DEFAULT '',           -- Configurable profile field
	extra2       TEXT NOT NULL DEFAULT '',           -- Configurable profile field
	extra3       TEXT NOT NULL DEFAULT '',           -- Configurable profile field
	birthyear    SMALLINT NOT NULL DEFAULT 0,        -- Birthyear
	birthday     VARCHAR(5) NOT NULL DEFAULT '',     -- Birthday, format MM-DD
	timezone     VARCHAR(10) NOT NULL DEFAULT '',    -- Timezone for time display localization
	language     VARCHAR(80) NOT NULL DEFAULT '',    -- Language name
	style        VARCHAR(80) NOT NULL DEFAULT '',    -- CSS design name
	fontFace     VARCHAR(80) NOT NULL DEFAULT '',    -- Font face name
	fontSize     TINYINT NOT NULL DEFAULT 0,         -- Font size in points
	boardDescs   TINYINT NOT NULL DEFAULT 0,         -- Show board descriptions?
	showDeco     TINYINT NOT NULL DEFAULT 0,         -- Show user titles, ranks, smileys, topic tags?
	showAvatars  TINYINT NOT NULL DEFAULT 0,         -- Show avatar images?
	showImages   TINYINT NOT NULL DEFAULT 0,         -- Show embedded images?
	showSigs     TINYINT NOT NULL DEFAULT 0,         -- Show signatures?
	collapse     TINYINT NOT NULL DEFAULT 0,         -- Auto-collapse topic branches?
	indent       TINYINT NOT NULL DEFAULT 0,         -- Threading indent in percent
	topicsPP     SMALLINT NOT NULL DEFAULT 0,        -- Topics per board page
	postsPP      SMALLINT NOT NULL DEFAULT 0,        -- Posts per topic page
	regTime      INT NOT NULL DEFAULT 0,             -- Registration timestamp
	lastOnTime   INT NOT NULL DEFAULT 0,             -- New calc: last visit to any page
	prevOnTime   INT NOT NULL DEFAULT 0,             -- New calc: lastOnTime from previous session
	fakeReadTime INT NOT NULL DEFAULT 0,             -- Read calc: set to curr time when forcing read
	lastTopicId  INT NOT NULL DEFAULT 0,             -- Read calc: Last visited topic
	lastTopicTime INT NOT NULL DEFAULT 0,            -- Read calc: Last visited topic timestamp
	chatReadTime INT NOT NULL DEFAULT 0,             -- Read calc (chat): set to curr time in chat_show
	lastIp       VARCHAR(15) NOT NULL DEFAULT '',    -- IP user had when hitting main page
	userAgent    VARCHAR(255) NOT NULL DEFAULT '',   -- Browser used when hitting main page
	postNum      INT NOT NULL DEFAULT 0,             -- Number of posts made
	bounceNum    INT NOT NULL DEFAULT 0,             -- Number of email bounces received * factor
	bounceAuth   INT NOT NULL DEFAULT 0,             -- Random bounce authentication value
	sourceAuth   INT NOT NULL DEFAULT 0,             -- Random request source authentication value
	gpgKeyId     VARCHAR(18) NOT NULL DEFAULT '',    -- OpenPGP key id
	gpgCompat    TINYINT NOT NULL DEFAULT 0          -- GnuPG compatibility mode
);
CREATE UNIQUE INDEX users_userName ON users (userName);

CREATE TABLE userBans (
	userId       INT PRIMARY KEY DEFAULT 0,
	banTime      INT NOT NULL DEFAULT 0,             -- Ban timestamp
	duration     SMALLINT NOT NULL DEFAULT 0,        -- Duration in days
	reason       TEXT NOT NULL DEFAULT '',           -- Reason shown in ban error message
	intReason    TEXT NOT NULL DEFAULT ''            -- Internal reason only shown to admins
);

CREATE TABLE userIgnores (
	userId       INT NOT NULL DEFAULT 0,             -- Ignoring user
	ignoredId    INT NOT NULL DEFAULT 0,             -- Ignored user
	PRIMARY KEY (userId, ignoredId)
);

CREATE TABLE groups (
	id           INT PRIMARY KEY AUTO_INCREMENT,     -- Group id
	title        VARCHAR(255) NOT NULL DEFAULT ''    -- Group name
);

CREATE TABLE groupMembers (
	userId       INT NOT NULL DEFAULT 0,             -- Member id
	groupId      INT NOT NULL DEFAULT 0,             -- Group id
	PRIMARY KEY (userId, groupId)
);

CREATE TABLE categories (
	id           INT PRIMARY KEY AUTO_INCREMENT,
	title        VARCHAR(255) NOT NULL DEFAULT '',   -- Category name
	pos          SMALLINT NOT NULL DEFAULT 0         -- Position in list
);

CREATE TABLE boards (
	id           INT PRIMARY KEY AUTO_INCREMENT,     -- Board id
	title        VARCHAR(255) NOT NULL DEFAULT '',   -- Board name
	categoryId   INT NOT NULL DEFAULT 0,             -- Parent category
	pos          SMALLINT NOT NULL DEFAULT 0,        -- Position in list (category local)
	expiration   SMALLINT NOT NULL DEFAULT 0,        -- Topics expire x days after last post
	locking      SMALLINT NOT NULL DEFAULT 0,        -- Topics are locked x days after last post
	approve      TINYINT NOT NULL DEFAULT 0,         -- Approval moderation active?
	private      TINYINT NOT NULL DEFAULT 0,         -- Contents visible to? 0=all, 1=m&m, 2=reg.
	list         TINYINT NOT NULL DEFAULT 0,         -- List board even if contents not visible?
	anonymous    TINYINT NOT NULL DEFAULT 0,         -- User id not saved with posts?
	unregistered TINYINT NOT NULL DEFAULT 0,         -- Can unregistered visitors post?
	announce     TINYINT NOT NULL DEFAULT 0,         -- Who can post? 0=all, 1=m&m, 2=all can reply
	flat         TINYINT NOT NULL DEFAULT 0,         -- Flatmode, no threading/indenting?
	attach       TINYINT NOT NULL DEFAULT 0,         -- Enable file attachments?
	shortDesc    VARCHAR(255) NOT NULL DEFAULT '',   -- Short description for forum page
	longDesc     TEXT NOT NULL DEFAULT '',           -- Long description for board info page
	postNum      INT NOT NULL DEFAULT 0,             -- Number of posts (cached)
	lastPostTime INT NOT NULL DEFAULT 0              -- Time of latest post (cached)
);

CREATE TABLE boardMembers (
	userId       INT NOT NULL DEFAULT 0,             -- User id
	boardId      INT NOT NULL DEFAULT 0,             -- Board id
	PRIMARY KEY (userId, boardId)
);

CREATE TABLE boardMemberGroups (
	groupId      INT NOT NULL DEFAULT 0,             -- Group id
	boardId      INT NOT NULL DEFAULT 0,             -- Board id
	PRIMARY KEY (groupId, boardId)
);

CREATE TABLE boardAdmins (
	userId       INT NOT NULL DEFAULT 0,             -- User id
	boardId      INT NOT NULL DEFAULT 0,             -- Board id
	PRIMARY KEY (userId, boardId)
);

CREATE TABLE boardAdminGroups (
	groupId      INT NOT NULL DEFAULT 0,             -- Group id
	boardId      INT NOT NULL DEFAULT 0,             -- Board id
	PRIMARY KEY (groupId, boardId)
);

CREATE TABLE boardHiddenFlags (
	userId       INT NOT NULL DEFAULT 0,             -- User id
	boardId      INT NOT NULL DEFAULT 0,             -- Board id
	PRIMARY KEY (userId, boardId)
);

CREATE TABLE boardSubscriptions (
	userId       INT NOT NULL DEFAULT 0,             -- User id
	boardId      INT NOT NULL DEFAULT 0,             -- Board id
	PRIMARY KEY (userId, boardId)
);

CREATE TABLE topics (
	id           INT PRIMARY KEY AUTO_INCREMENT,
	subject      TEXT NOT NULL DEFAULT '',           -- Subject text
	tag          VARCHAR(20) NOT NULL DEFAULT '',    -- Tag key
	boardId      INT NOT NULL DEFAULT 0,             -- Parent board id
	basePostId   INT NOT NULL DEFAULT 0,             -- First post id
	pollId       INT NOT NULL DEFAULT 0,             -- Poll id
	locked       TINYINT NOT NULL DEFAULT 0,         -- No new posts allowed?
	sticky       TINYINT NOT NULL DEFAULT 0,         -- Put at top of topic list?
	hitNum       INT NOT NULL DEFAULT 0,             -- Number of requests
	postNum      INT NOT NULL DEFAULT 0,             -- Number of posts (cached)
	lastPostTime INT NOT NULL DEFAULT 0              -- Time of latest post (cached)
);
CREATE INDEX topics_lastPostTime ON topics (lastPostTime);

CREATE TABLE topicReadTimes (
	userId       INT NOT NULL DEFAULT 0,             -- User id
	topicId      INT NOT NULL DEFAULT 0,             -- Topic id
	lastReadTime INT NOT NULL DEFAULT 0,             -- Timestamp of last visit
	PRIMARY KEY (userId, topicId)
);

CREATE TABLE topicSubscriptions (
	userId       INT NOT NULL DEFAULT 0,             -- User id
	topicId      INT NOT NULL DEFAULT 0,             -- Topic id
	PRIMARY KEY (userId, topicId)
);

CREATE TABLE posts (
	id           INT PRIMARY KEY AUTO_INCREMENT,     -- Post id
	userId       INT NOT NULL DEFAULT 0,             -- Poster's id
	userNameBak  VARCHAR(60) NOT NULL DEFAULT '',    -- Copy of poster's username at post-time
	boardId      INT NOT NULL DEFAULT 0,             -- Parent board
	topicId      INT NOT NULL DEFAULT 0,             -- Parent topic
	parentId     INT NOT NULL DEFAULT 0,             -- Parent post
	approved     TINYINT NOT NULL DEFAULT 0,         -- Approved by moderator?
	ip           VARCHAR(15) NOT NULL DEFAULT '',    -- IP of user at post-time
	postTime     INT NOT NULL DEFAULT 0,             -- Posting timestamp
	editTime     INT NOT NULL DEFAULT 0,             -- Edit timestamp
	body         TEXT NOT NULL DEFAULT ''            -- Post text
);
CREATE INDEX posts_userId   ON posts (userId);
CREATE INDEX posts_topicId  ON posts (topicId);
CREATE INDEX posts_parentId ON posts (parentId);
CREATE INDEX posts_postTime ON posts (postTime);

CREATE TABLE postTodos (
	userId       INT NOT NULL DEFAULT 0,             -- User id
	postId       INT NOT NULL DEFAULT 0,             -- Post id
	PRIMARY KEY (userId, postId)
);

CREATE TABLE postReports (
	userId       INT NOT NULL DEFAULT 0,             -- Reporting user id
	postId       INT NOT NULL DEFAULT 0,             -- Reported post id
	reason       TEXT NOT NULL DEFAULT '',           -- Reason for appeal
	PRIMARY KEY (userId, postId)
);

CREATE TABLE attachments (
	id           INT PRIMARY KEY AUTO_INCREMENT,     -- Attachment id
	postId       INT NOT NULL DEFAULT 0,             -- Post id
	webImage     TINYINT NOT NULL DEFAULT 0,         -- 0=no, 1=valid web image, 2=embedded
	fileName     VARCHAR(255) NOT NULL DEFAULT ''    -- Filename
);
CREATE INDEX attachments_postId ON attachments (postId);

CREATE TABLE variables (
	name         VARCHAR(10) NOT NULL DEFAULT '',    -- Variable name
	userId       INT NOT NULL DEFAULT 0,             -- User id
	value        VARCHAR(255) NOT NULL DEFAULT '',   -- Value
	PRIMARY KEY (name, userId)
);

CREATE TABLE log (
	level        TINYINT NOT NULL DEFAULT 0,         -- Log level
	entity       CHAR(6) NOT NULL DEFAULT '',        -- Entity name
	action       CHAR(8) NOT NULL DEFAULT '',        -- Action name
	userId       INT NOT NULL DEFAULT 0,             -- Executive user id
	boardId      INT NOT NULL DEFAULT 0,             -- Board id
	topicId      INT NOT NULL DEFAULT 0,             -- Topic id
	postId       INT NOT NULL DEFAULT 0,             -- Post id
	extraId      INT NOT NULL DEFAULT 0,             -- Action-dependent (usually target id)
	logTime      INT NOT NULL DEFAULT 0,             -- Logging timestamp
	ip           CHAR(15) NOT NULL DEFAULT ''        -- IP
);

CREATE TABLE logStrings (
	id           INT PRIMARY KEY AUTO_INCREMENT,     -- Id, usually referenced by log.extraId
	string       TEXT NOT NULL DEFAULT ''            -- String
);

CREATE TABLE polls (
	id           INT PRIMARY KEY AUTO_INCREMENT,     -- Poll id
	title        TEXT NOT NULL DEFAULT '',           -- Poll title/question
	locked       TINYINT NOT NULL DEFAULT 0,         -- Poll ended and votes consolidated?
	multi        TINYINT NOT NULL DEFAULT 0          -- Allow one vote per option?
);

CREATE TABLE pollOptions (
	id           INT PRIMARY KEY AUTO_INCREMENT,     -- Poll option id
	pollId       INT NOT NULL DEFAULT 0,             -- Poll id
	title        TEXT NOT NULL DEFAULT '',           -- Option title
	votes        INT NOT NULL DEFAULT 0              -- Sum of votes when poll locked
);
CREATE INDEX pollOptions_pollId ON pollOptions (pollId);

CREATE TABLE pollVotes (
	pollId       INT NOT NULL DEFAULT 0,             -- Poll id
	userId       INT NOT NULL DEFAULT 0,             -- Voter id
	optionId     INT NOT NULL DEFAULT 0,             -- Poll option id
	PRIMARY KEY (pollId, userId, optionId)
);

CREATE TABLE messages (
	id           INT PRIMARY KEY AUTO_INCREMENT,     -- Message id
	senderId     INT NOT NULL DEFAULT 0,             -- Sender's id
	receiverId   INT NOT NULL DEFAULT 0,             -- Recipient's id
	sendTime     INT NOT NULL DEFAULT 0,             -- Posting timestamp
	hasRead      TINYINT NOT NULL DEFAULT 0,         -- Did user read message?
	inbox        TINYINT NOT NULL DEFAULT 0,         -- Is in inbox?
	sentbox      TINYINT NOT NULL DEFAULT 0,         -- Is in sentbox?
	subject      TEXT NOT NULL DEFAULT '',           -- Message subject
	body         TEXT NOT NULL DEFAULT ''            -- Message text
);
CREATE INDEX messages_senderId ON messages (senderId);
CREATE INDEX messages_receiverId ON messages (receiverId);

CREATE TABLE notes (
	id           INT PRIMARY KEY AUTO_INCREMENT,     -- Notification id
	userId       INT NOT NULL DEFAULT 0,             -- Recipient's id
	sendTime     INT NOT NULL DEFAULT 0,             -- Sending timestamp
	body         TEXT NOT NULL DEFAULT ''            -- Message text
);
CREATE INDEX notes_userId ON notes (userId);

CREATE TABLE chat (
	id           INT PRIMARY KEY AUTO_INCREMENT,     -- Entry id
	userId       INT NOT NULL DEFAULT 0,             -- Poster's id
	postTime     INT NOT NULL DEFAULT 0,             -- Timestamp
	body         TEXT NOT NULL DEFAULT ''            -- Chat text
);

CREATE TABLE tickets (
	id           VARCHAR(32) PRIMARY KEY,            -- Ticket id
	userId       INT NOT NULL DEFAULT 0,             -- User's id
	issueTime    INT NOT NULL DEFAULT 0,             -- Creation timestamp
	type         VARCHAR(6) NOT NULL DEFAULT '',     -- Type
	data         VARCHAR(255) NOT NULL DEFAULT ''    -- Type-dependent data
);

CREATE TABLE sessions (
	id           CHAR(32) PRIMARY KEY,               -- Session id
	userId       INT NOT NULL DEFAULT 0,             -- Users id
	lastOnTime   INT NOT NULL DEFAULT 0,             -- Last visit to any page
	ip           CHAR(15) NOT NULL DEFAULT ''        -- IP
);

INSERT INTO variables (name, value) VALUES ('version', '2.11.2');

";

#------------------------------------------------------------------------------

# Add prefix to table names
$sql =~ s! TABLE ! TABLE $cfg->{dbPrefix}!g;
$sql =~ s! ON ! ON $cfg->{dbPrefix}!g;
$sql =~ s! INTO ! INTO $cfg->{dbPrefix}!g;

# Change SQL for PgSQL and SQLite
if ($m->{pgsql}) {
	$sql =~ s!INT PRIMARY KEY AUTO_INCREMENT!SERIAL PRIMARY KEY!g;
	$sql =~ s! TINYINT ! SMALLINT !g;
}
elsif ($m->{sqlite}) {
	$sql =~ s!AUTO_INCREMENT!AUTOINCREMENT!g;
	$sql =~ s! INT ! INTEGER !g;
}

# Execute separate queries
for (grep(/\w/, split(";", $sql))) { 
	$dbh->do($_) or print "$DBI::errstr ($_)";
}

print "mwForum installation done.\n";

#------------------------------------------------------------------------------
