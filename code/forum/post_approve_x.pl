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

# Check if request is coming from this site
checkReferer();

# Get CGI parameters
my $cgi = new Forum::MwfCGI;
my $postId = int($cgi->param('pid'));
my $page = int($cgi->param('pg')) || 1;
my $origin = $cgi->param('ori');
$postId or paramError($lng->{'errPstIdMiss'});

# Get post
my $query = "SELECT boardId, topicId FROM posts WHERE user_id = $postId";
my $sth = query($query);
my ($boardId, $topicId) = $sth->fetchrow_array();
$boardId or entryError($lng->{'errPstNotFnd'});

# Check if user is forum/board admin
$user->{'admin'} || boardAdmin($user->primary_key, $boardId) or adminError();

# Update post
my $now = time();
$query = "UPDATE posts SET approved = 1 WHERE user_id = $postId";
$dbh->do($query) or dbError();

# Log action
logAction(1, 'post', 'approve', $user->primary_key, $boardId, $topicId, $postId);

# Redirect back
$origin eq "newPst"
	? redirect("post_shownew.pl?msg=PstApprv#$postId") 
	: redirect("topic_show.pl?tid=$topicId&pg=$page&msg=PstApprv#$postId");
