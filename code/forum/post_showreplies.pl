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

# Get CGI parameters
my $cgi = new Forum::MwfCGI;
my $msg = $cgi->param('msg');
my $userId = int($cgi->param('uid')) || $user->primary_key;
my $showOld = $cgi->param('old');

# Only admins may list replies of other users
$userId = $user->primary_key unless $user->{'admin'};

# Print header
printHeader($msg);

# Check if access should be denied
checkBlock();

# Check if user is registered
$user->{'default'} and regError();

# Print bar
my @bar = (
	$showOld ? () : ("post_showreplies.pl?uid=$userId&old=1", "srpShowOld", 1),
	"forum_show.pl", "comUp", 1
);
printBar($lng->{'srpTitle'}, $user->{'userName'}, \@bar);

# Get boards
my $query = "SELECT * FROM boards WHERE anonymous = 0";
my $sth = query($query);
my $boards = $sth->fetchall_arrayref({});
my %boards = ();
my $boardIds = "0";
for my $board (@$boards) { 
	$boards{$board->{'id'}} = $board;
	$boardIds .= "," . $board->{'id'};
}

# Search posts
my $ageRel = $showOld ? "<" : ">";
my $query = "
	SELECT replies.id, replies.boardId, replies.topicId, replies.user_id, 
		replies.postTime, replies.userNameBak,
		topics.subject,
		users.user_id
	FROM posts, posts AS replies, topics
		LEFT JOIN users ON users.id = replies.user_id 
	WHERE posts.user_id = '$userId'
		AND posts.postTime $ageRel $user->{'lastReadTime'}
		AND posts.boardId IN ($boardIds)
		AND replies.parentId = posts.id
		AND topics.id = posts.topicId
	ORDER BY postTime DESC
	LIMIT 100";
my $sth = query($query);
my $posts = $sth->fetchall_arrayref({});

# Print table header
print
	"<BR>\n\n",
	tableStart(),
	"<TR>\n",
	"<TD><B>$lng->{'srpTopic'}</B></TD>\n",
	"<TD WIDTH='15%'><B>$lng->{'srpPoster'}</B></TD>\n",
	"<TD WIDTH='15%'><B>$lng->{'srpPosted'}</B></TD>\n",
	"</TR>\n\n";

# Print found posts	
for my $post (@$posts) {
	# Prepare username string
	my $userNameStr = " - ";
	if ($post->{'userName'}) {
		$userNameStr = "$post->{'userName'}";
	}
	elsif ($post->{'userNameBak'}) {
		$userNameStr = "$post->{'userNameBak'}";
	}
	
	# Prepare other display strings
	my $timeStr = formatTime($post->{'postTime'}, $user->{'timezone'});

	# Print post	
	print
		"<TR BGCOLOR='$cfg{'lightCellColor'}'>\n",
		"<TD NOWRAP>",
		"<A HREF='topic_show.pl?tid=$post->{'topicId'}#$post->{'id'}'>",
		"$post->{'subject'}</A></TD>\n",
		"<TD NOWRAP>$userNameStr</TD>\n",
		"<TD NOWRAP>$timeStr</TD>\n",
		"</TR>\n\n";
}

# If nothing found, display notification
print
	"<TR BGCOLOR='$cfg{'lightCellColor'}'><TD COLSPAN=3>\n",
	"$lng->{'srpNotFound'}\n",
	"</TD></TR>\n\n"
	unless @$posts;

print
	tableEnd();

# Log action
logAction(2, 'post', 'showreplies', $user->primary_key);

# Print footer
printFooter();
