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
my $postId = int($cgi->param('pid'));
my $origin = $cgi->param('ori');
$postId or paramError($lng->{'errPstIdMiss'});

# Get post
my $query = "SELECT * FROM posts WHERE id = $postId";
my $sth = query($query);
my $post = $sth->fetchrow_hashref();
$post or entryError($lng->{'errPstNotFnd'});

# Check authorization
checkAuthz($user, 'editPost', $post);

# Check if user can delete post
$user->primary_key =~ /$post->{'user_id'}/ 
	|| $user->{'admin'} || boardAdmin($user->primary_key, $post->{'boardId'})
	or userError($lng->{'errNotYours'});

# Check for children
$query = "
	SELECT id IS NOT NULL 
	FROM posts 
	WHERE parentId = $postId
	LIMIT 1";
$sth = query($query);
my $hasChildren = $sth->fetchrow_array();

# Delete post
my $topicDeleted = 0;
if ($hasChildren) {
	# Only delete post body to preserve thread integrity
	$query = "
		UPDATE posts SET 
			body = '$lng->{'eptDeleted'}', 
			notify = 0,
			attach = ''
		WHERE id = $postId";
	$dbh->do($query) or dbError();
} 
else {
	# Transaction
	begin();
	eval {
		# Delete topic if only one post
		if ($post->{'parentId'} == 0) {
			$query = "DELETE FROM topics WHERE id = $post->{'topicId'}";
			$dbh->do($query) or dbError();
			$topicDeleted = 1;
		}		

		# Really delete post
		$query = "DELETE FROM posts WHERE id = $postId";
		$dbh->do($query) or dbError();
	};
	$@ ? rollback() : commit();
}
	
# Delete attachment
unlink "$cfg{'attachFsPath'}/$post->{'attach'}" if $post->{'attach'};

# Update board/topic stats
recalcStats($post->{'boardId'}, $post->{'topicId'});

# Log action
logAction(1, 'post', 'delete', $user->primary_key, $post->{'boardId'}, $post->{'topicId'}, $postId);

# Redirect back
if ($origin eq "newPst") { redirect("post_shownew.pl?msg=PstDel") }
elsif ($topicDeleted) { redirect("board_show.pl?bid=$post->{'boardId'}&msg=PstTpcDel") }
else { redirect("topic_show.pl?tid=$post->{'topicId'}&msg=PstDel#$post->{'parentId'}") }
