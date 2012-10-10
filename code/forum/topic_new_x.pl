#!/usr/bin/perl
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
my $boardId = int($cgi->param('bid'));
my $subject = $cgi->param('subject');
my $body = $cgi->param('body');
my $notify = $cgi->param('notify') ? 1 : 0;
$boardId or paramError($lng->{'errBrdIdMiss'});
$subject or userError($lng->{'errSubEmpty'});
$body or userError($lng->{'errBdyEmpty'});

# Get board
my $query = "SELECT * FROM boards WHERE id = $boardId";
my $sth = query($query);
my $board = $sth->fetchrow_hashref();
$board or entryError($lng->{'errBrdNotFnd'});
my $boardAdmin = boardAdmin($user->primary_key, $boardId);

# Check authorization
checkAuthz($user, 'newTopic', $board);

# Check if user can see and write to board
boardVisible($board, $boardAdmin) or entryError($lng->{'errBrdNotFnd'});
boardWritable($board, $boardAdmin) or userError($lng->{'errReadOnly'});

# Check subject length before escaping special chars (DB will clip much too long strings)
length($subject) > $cfg{'maxSubjectLen'} and userError($lng->{'errSubLen'});

# Translate text
my $post = {'subject' => $subject, 'body' => $body};
editToDb($board, $post);

# Check body length etc.
$post->{'subject'} =~ /.+/ or userError($lng->{'errSubNoText'});
length($post->{'body'}) > $cfg{'maxBodyLen'} and userError($lng->{'errBdyLen'});

# Determine misc values
my $score = $user->{'baseScore'};
my $approved = !$board->{'approve'} || $user->{'admin'} || $boardAdmin;
my $now = time();
my $userNameQ = quote($user->{'userName'});
my $subjectQ = quote($post->{'subject'});
my $bodyQ = quote($post->{'body'});

# Check for dupe
#$query = "
#	SELECT id FROM posts 
#	WHERE boardId = $boardId 
#		AND user_id = '".$user->primary_key."' 
#		AND body = $bodyQ";
#$sth = query($query);
#$sth->fetchrow_array() and userError($lng->{'errDupe'});

# Transaction
my $topicId = 0;
my $postId = 0;
begin();
eval {
	# Insert topic
	$query = "
		INSERT INTO topics SET 
			id           = NULL,
			subject      = $subjectQ,
			boardId      = $boardId,
			protected    = 0,
			locked       = 0,
			hitNum       = 1,
			postNum      = 1,
			lastPostTime = $now";
	$dbh->do($query) or dbError();
	
	# Get new topic id
	$query = "SELECT LAST_INSERT_ID()";
	$sth = query($query);
	$topicId = $sth->fetchrow_array();
	
	# Insert post
	$query = "
		INSERT INTO posts SET
			id          = NULL,
			user_id      = '".$user->primary_key."',
			userNameBak = '".$user->primary_key."',
			boardId     = $boardId,
			topicId     = $topicId,
			parentId    = 0,
			notify      = $notify,
			approved    = $approved,
			score       = $score,
			ip          = '$ENV{'REMOTE_ADDR'}',
			postTime    = $now,
			body        = $bodyQ";
	$dbh->do($query) or dbError();
	
	# Get new post id
	$query = "SELECT LAST_INSERT_ID()";
	$sth = query($query);
	$postId = $sth->fetchrow_array();

	# Update topic's basePostId
	$query = "UPDATE topics SET basePostId = $postId WHERE id = $topicId";
	$dbh->do($query) or dbError();
	
	# Update board stats
	$query = "
		UPDATE boards SET 
			postNum = postNum + 1, 
			lastPostTime = $now
		WHERE id = $boardId";
	$dbh->do($query) or dbError();

	# Update user stats
	$query = "UPDATE users SET postNum = postNum + 1 WHERE user_id = '".$user->primary_key."'";
	$dbh->do($query) or dbError();
};
$@ ? rollback() : commit();

# Log action
logAction(1, 'topic', 'new', $user->primary_key, $boardId, $topicId, $postId);

# Redirect back to topic
redirect("topic_show.pl?tid=$topicId&msg=NewPost");
