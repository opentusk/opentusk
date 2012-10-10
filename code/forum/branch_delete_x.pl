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

# Check if request is coming from this site
checkReferer();

# Get CGI parameters
my $cgi = new Forum::MwfCGI;
my $postId = int($cgi->param('pid'));
$postId or paramError($lng->{'errPstIdMiss'});

# Get base post
my $query = "
	SELECT id, boardId, topicId, parentId
	FROM posts	
	WHERE user_id = $postId";
my $sth = query($query);
my $basePost = $sth->fetchrow_hashref();
$basePost or entryError($lng->{'errPstNotFnd'});

# Branch base post can't be topic base post
$basePost->{'parentId'} or userError($lng->{'errPromoTpc'});

# Check if user is forum/board admin
$user->{'admin'} || boardAdmin($user->primary_key, $basePost->{'boardId'}) or adminError();

# Get posts
$query = "
	SELECT id, parentId
	FROM posts	
	WHERE topicId = $basePost->{'topicId'}";
$sth = query($query);
my $posts = $sth->fetchall_arrayref({});

# Put posts in by-parent lookup table
use vars qw(%postsByParent @branchPostIds);
%postsByParent = ();
for my $post (@$posts) { push @{$postsByParent{$post->{'parentId'}}}, $post }

# Get ids of posts that belong to branch
@branchPostIds = ();
getBranchPostIds($basePost->{'id'});
my $branchPostIds = join(",", @branchPostIds);

# Delete posts
$query = "DELETE FROM posts WHERE user_id IN ($branchPostIds)";
$dbh->do($query) or dbError();

# Update board and topic stats
recalcStats($basePost->{'boardId'}, $basePost->{'topicId'});

# Log action
logAction(1, 'branch', 'delete', $user->primary_key, 
	$basePost->{'boardId'}, $basePost->{'topicId'}, $postId);

# Redirect
redirect("topic_show.pl?tid=$basePost->{'topicId'}&msg=BrnDelete");

#------------------------------------------------------------------------------

# Recursive branch post search
sub getBranchPostIds
{
	my $postId = shift();
	
	push @branchPostIds, $postId;
	
	for my $child (@{$postsByParent{$postId}}) { 
		$child->{'id'} != $postId or printError("Integrity Error", "Post is its own parent?!");
		getBranchPostIds($child->{'id'});
	}
}
