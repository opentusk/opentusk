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
my $postId = int($cgi->param('pid'));
my $subject = $cgi->param('subject');
my $body  = $cgi->param('body');
my $notify  = $cgi->param('notify') ? 1 : 0;
my $page = int($cgi->param('pg')) || 1;
my $origin = $cgi->param('ori');
$postId or paramError($lng->{'errPstIdMiss'});
$body or userError($lng->{'errBdyEmpty'});

# Get post
my $query = "SELECT * FROM posts WHERE id = $postId";
my $sth = query($query);
my $post = $sth->fetchrow_hashref();
$post or entryError($lng->{'errPstNotFnd'});

# Get board
$query = "SELECT * FROM boards WHERE id = $post->{'boardId'}";
$sth = query($query);
my $board = $sth->fetchrow_hashref();
my $boardAdmin = boardAdmin($user->primary_key, $board->{'id'});

# Get topic
$query = "SELECT * FROM topics WHERE id = $post->{'topicId'}";
$sth = query($query);
my $topic = $sth->fetchrow_hashref();

# Check authorization
checkAuthz($user, 'editPost', $post, $topic, $board);

# Check if user can edit post
$post->{'user_id'} = '' unless ($post->{'user_id'});
$user->primary_key eq $post->{'user_id'} || $user->{'admin'} || $boardAdmin
	or userError($lng->{'errNotYours'});

# Check if topic is locked
!$topic->{'locked'} || $user->{'admin'} || $boardAdmin
	or userError($lng->{'errTpcLocked'});

# Translate text
$post->{'subject'} = $subject;
$post->{'body'} = $body;
editToDb($board, $post);

# Check subject and body length etc
length($post->{'body'}) > $cfg{'maxBodyLen'} and userError($lng->{'errBdyLen'});
if (!$post->{'parentId'}) {
	length($post->{'subject'}) > $cfg{'maxSubjectLen'} and userError($lng->{'errSubLen'});
	$post->{'subject'} =~ /\w/ or userError($lng->{'errSubNoText'});
}

# Quote texts
my $subjectQ = quote($post->{'subject'}) unless $post->{'parentId'};
my $bodyQ = quote($post->{'body'});

# Update post
$query = "UPDATE posts SET body = $bodyQ, notify = $notify WHERE id = $postId";
$dbh->do($query) or dbError();

# Update topic subject if first post
unless ($post->{'parentId'}) {
	$query = "UPDATE topics SET subject = $subjectQ WHERE id = $post->{'topicId'}";
	$dbh->do($query) or dbError();
}

# Log action
logAction(1, 'post', 'edit', $user->primary_key, $board->{'id'}, $topic->{'id'}, $postId);

# Redirect back to topic
$origin eq "newPst"
	? redirect("post_shownew.pl?msg=PstChange#$postId") 
	: redirect("topic_show.pl?tid=$topic->{'id'}&pg=$page&msg=PstChange#$postId");
