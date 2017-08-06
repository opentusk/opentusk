#!/usr/bin/env perl
#------------------------------------------------------------------------------
#    mwForum - Web-based discussion forum
#    Copyright (c) 1999-2001 Markus Wichitill <mwforum@mawic.de>
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
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#------------------------------------------------------------------------------

use strict;

# Imports
use CGI::Carp qw(fatalsToBrowser);
use DBI;
use Forum::MwfConfig;
use Forum::MwfMain;
use Forum::MwfCGI;

#------------------------------------------------------------------------------

# Get user
connectDb();
authUser();

# Print HTTP header
printHttpHeader();

# Check if user is registered, not banned and not blocked
$user->{'default'} and regError();
checkBan($user->primary_key);
checkBlock();

# Check if request is coming from this site
checkReferer();

# Get CGI parameters
my $cgi = new Forum::MwfCGI;
my $parentId = int($cgi->param('pid'));
my $body = $cgi->param('body');
my $notify = $cgi->param('notify') ? 1 : 0;
my $page = int($cgi->param('pg')) || 1;
my $origin = $cgi->param('ori');
$parentId or paramError($lng->{'errPrtIdMiss'});
$body or paramError($lng->{'errBdyEmpty'});

# Get parent post
my $query = "SELECT * FROM posts WHERE id = $parentId";
my $sth = query($query);
my $parent = $sth->fetchrow_hashref();
$parent or entryError($lng->{'errPrtNotFnd'});

# Get board
$query = "SELECT * FROM boards WHERE id = $parent->{'boardId'}";
$sth = query($query);
my $board = $sth->fetchrow_hashref();
my $boardAdmin = boardAdmin($user->primary_key, $board->{'id'});

# Get topic
$query = "SELECT * FROM topics WHERE id = $parent->{'topicId'}";
$sth = query($query);
my $topic = $sth->fetchrow_hashref();

# Check authorization
checkAuthz($user, 'newPost', $parent, $topic, $board);

# Check if user can see and write to board
boardVisible($board, $boardAdmin) or entryError($lng->{'errBrdNotFnd'});
boardWritable($board, $boardAdmin) || $board->{'announce'} == 2
	or userError($lng->{'errReadOnly'});

# Check if topic is locked
!$topic->{'locked'} || $user->{'admin'} || $boardAdmin
	or userError($lng->{'errTpcLocked'});

# Determine misc values
my $now = time();
my $approved = !$board->{'approve'} || $user->{'admin'} || $boardAdmin;
my $score = $user->{'baseScore'};

# Assemble "fake" post hash, body needed for editToDb(), rest for plugins
my $post = {
	'userId'   => $user->primary_key,
	'userName' => $board->{'anonymous'} ? $lng->{'comHidden'} : $user->{'userName'},
	'boardId'  => $board->{'id'},
	'topicId'  => $topic->{'id'},
	'approved' => $approved,
	'score'    => $score,
	'ip'       => $ENV{'REMOTE_ADDR'},
	'postTime' => $now,
	'body'     => $body,
};

# Translate text
editToDb($board, $post);

# Check body length
length($post->{'body'}) > $cfg{'maxBodyLen'} and userError($lng->{'errBdyLen'});

# Determine misc values
my $userNameQ = quote($user->{'userName'});
my $bodyQ = quote($post->{'body'});

# Check for dupe
#$query = "
#	SELECT id 
#	FROM posts 
#	WHERE parentId = $parentId 
#		AND user_id = '".$user->primary_key."' 
#		AND body = $bodyQ";
#$sth = query($query);
#$sth->fetchrow_array() and userError($lng->{'errDupe'});

# Set parentId to basePostId in non-threaded boards
my $insertParentId = $board->{'flat'} ? $topic->{'basePostId'} : $parentId;

# Insert post
$query = "
	INSERT INTO posts SET
		id          = NULL,
		user_id      = '".$user->primary_key."',
		userNameBak = '".$user->primary_key."',
		boardId     = $board->{'id'},
		topicId     = $topic->{'id'},
		parentId    = $insertParentId,
		notify      = $notify,
		approved    = $approved,
		score       = $score,
		ip          = '$ENV{'REMOTE_ADDR'}',
		postTime    = $now,
		body        = $bodyQ";
$dbh->do($query) or dbError();

# Mark read if there haven't been other new posts in the meantime
$query = "
	SELECT topics.lastPostTime <= topicReadTimes.lastReadTime
	FROM topics, topicReadTimes
	WHERE topics.id = $topic->{'id'}
		AND topicReadTimes.user_id = '".$user->primary_key."'
		AND topicReadTimes.topicId = topics.id";
$sth = query($query);
my $allRead = $sth->fetchrow_array();
if ($allRead) {
	$query = "
		REPLACE topicReadTimes SET
			user_id = '".$user->primary_key."',
			topicId = $topic->{'id'},
			lastReadTime = $now + 1";
	$dbh->do($query) or dbError();
}

# Get new post id
$query = "SELECT LAST_INSERT_ID()";
$sth = query($query);
my $postId = $sth->fetchrow_array();

# Update board/topic stats
$query = "
	UPDATE topics SET 
		postNum = postNum + 1, 
		lastPostTime = $now
	WHERE id = $topic->{'id'}";
$dbh->do($query) or dbError();
$query = "
	UPDATE boards SET 
		postNum = postNum + 1, 
		lastPostTime = $now
	WHERE id = $board->{'id'}";
$dbh->do($query) or dbError();

# Update user stats
$query = "UPDATE users SET postNum = postNum + 1 WHERE user_id = '".$user->primary_key."'";
$dbh->do($query) or dbError();

# Send notification email
if ($parent->{'notify'}) {
	# Determine link to post
	my $url = "$cfg{'baseUrl'}$cfg{'cgiPath'}/topic_show.pl?tid=$topic->{'id'}#$parentId";
	
	# Get user 
	my $receiver = getUser($parent->{'user_id'});

	# Send email
	sendEmail(createEmail({
		'type'   => 'replyNtf',
		'user'   => $receiver,
		'user2'  => $user,
		'board'  => $board,
		'topic'  => $topic,
		'parent' => $parent,
		'post'   => $post,
		'url'    => $url,
	})) if $receiver->{'id'} != $user->primary_key;
}

# Log action
logAction(1, 'post', 'reply', $user->primary_key, $board->{'id'}, $topic->{'id'}, $postId, $parentId);

# Redirect back to topic
$origin eq "newPst"
	? redirect("post_shownew.pl?msg=ReplyPost#$postId") 
	: redirect("topic_show.pl?tid=$topic->{'id'}&pg=$page&msg=ReplyPost#$postId");




