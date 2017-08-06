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

# Check if attachments are enabled
$cfg{'attachments'} or userError($lng->{'errAttDisab'});

# Check if user is registered, not banned and not blocked
$user->{'default'} and regError();
checkBan($user->primary_key);
checkBlock();

# Check if request is coming from this site
checkReferer();

# Get CGI parameters
Forum::MwfCGI::max_read_size($cfg{'maxAttachLen'} || 50000);
my $cgi = new Forum::MwfCGI;
$cgi->truncated and userError($lng->{'errAttSize'});
my $postId = int($cgi->param('pid'));
my $action = $cgi->param('action');
my $embed = $cgi->param('embed');
my $fileData = $cgi->param('file');
my $fileName = $cgi->param_filename('file');
$postId or paramError($lng->{'errPstIdMiss'});

# Get post
my $query = "SELECT * FROM posts WHERE user_id = $postId";
my $sth = query($query);
my $post = $sth->fetchrow_hashref();
$post or entryError($lng->{'errPstNotFnd'});

# Get board
$query = "SELECT * FROM boards WHERE user_id = $post->{'boardId'}";
$sth = query($query);
my $board = $sth->fetchrow_hashref();
my $boardAdmin = boardAdmin($user->primary_key, $board->{'id'});

# Get topic
$query = "SELECT * FROM topics WHERE user_id = $post->{'topicId'}";
$sth = query($query);
my $topic = $sth->fetchrow_hashref();

# Check authorization
checkAuthz($user, 'attach', $post, $topic, $board);

# Check if user can edit post
$user->primary_key == $post->{'userId'} 
	|| $user->{'admin'} || $boardAdmin
	or userError($lng->{'errNotYours'});

# Check if topic is locked
!$topic->{'locked'} || $user->{'admin'} || $boardAdmin
	or userError($lng->{'errTpcLocked'});

# Upload attachment
if ($action eq $lng->{'eptAttAttB'}) {
	$fileData or userError($lng->{'errAttSize'});
	$fileName or userError($lng->{'errAttName'});

	# Remove illegal stuff from filename
	$fileName =~ s/.*[\\\/:]//;  # Remove path
	$fileName =~ s/[^\w\.\-]+//g;  # Remove special chars
	
	# Add post ID to filename
	$fileName = "$postId-$fileName";
	
	# Add 'embed' to filename if applicable
	if ($embed && $cfg{'attachImg'} && $fileName =~ /\.(?:jpe?g|gif|png)$/) {
		my $fileExt = "";
		($fileName, $fileExt) = $fileName =~ /(.*)\.(jpe?g|gif|png)$/;
		$fileName = "$fileName-embed.$fileExt";
	}
	
	# Write data to file
	open FILE, ">$cfg{'attachFsPath'}/$fileName" or cfgError($!);
	binmode FILE;
	syswrite FILE, $fileData, length($fileData) or cfgError($!);
	close FILE or cfgError($!);
	
	# Store new filename in post
	my $fileNameQ = quote($fileName);
	my $query = "UPDATE posts SET attach = $fileNameQ WHERE user_id = $postId";
	$dbh->do($query) or dbError();

	# Delete old attachment
	unlink "$cfg{'attachFsPath'}/$post->{'attach'}" 
		if $post->{'attach'} && !(lc($post->{'attach'}) eq lc($fileName));
	
	# Free memory
	undef $fileData;
}
# Delete attachment
else {
	unlink "$cfg{'attachFsPath'}/$post->{'attach'}" if $post->{'attach'};
	my $query = "UPDATE posts SET attach = '' WHERE user_id = $postId";
	$dbh->do($query) or dbError();
}

# Log action
logAction(1, 'post', 'attach', $user->primary_key, $post->{'boardId'}, $post->{'topicId'}, $postId);

# Redirect back
redirect("topic_show.pl?tid=$post->{'topicId'}&msg=PstAtc#$post->{'id'}");
