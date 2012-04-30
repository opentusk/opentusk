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

# Check if user is admin
$user->{'admin'} or adminError();

# Get CGI parameters
my $cgi = new Forum::MwfCGI;
my $boardId = $cgi->param('bid');
my $origin = $cgi->param('ori');
$boardId or paramError($lng->{'errBrdIdMiss'});

# Transaction
begin();
eval {
	# Delete board
	my $query = "DELETE FROM boards WHERE id = $boardId";
	$dbh->do($query) or dbError();
	
	# Delete topics
	$query = "DELETE FROM topics WHERE boardId = $boardId";
	$dbh->do($query) or dbError();

	# Delete posts
	$query = "DELETE FROM posts WHERE boardId = $boardId";
	$dbh->do($query) or dbError();
	
	# Delete all associated users
	$query = "DELETE FROM hsdb4.link_forum_user WHERE parent_forum_id = $boardId";
	$dbh->do($query) or dbError();
	
	# Delete admins
	$query = "DELETE FROM hsdb4.link_forum_user WHERE parent_forum_id = $boardId";
	$dbh->do($query) or dbError();

	# Delete hidden-flags
	$query = "DELETE FROM boardHiddenFlags WHERE boardId = $boardId";
	$dbh->do($query) or dbError();

	# Delete attachments
	$query = "SELECT attach FROM posts WHERE boardId = $boardId AND attach != ''";
	my $sth = query($query);
	my $attachments = $sth->fetchall_arrayref();
	for my $attachment (@$attachments) {
		unlink "$cfg{'attachFsPath'}/$attachment->[0]";
	}
};
$@ ? rollback() : commit();

# Log action
logAction(1, 'board', 'delete', $user->primary_key, $boardId);

# Redirect
$origin eq "brdAdm"
	? redirect("board_admin.pl")
	: redirect("forum_show.pl");
