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

#------------------------------------------------------------------------------

# Get user
connectDb();
authUser();

# Print HTTP header
printHttpHeader();

# Check if user is admin
$user->{'admin'} or adminError();

# Get first category id
my $query = "SELECT MIN(id) FROM categories";
my $sth = query($query);
my $firstCatId = $sth->fetchrow_array();
$firstCatId 
	or userError("Can't create board without existing category. Create a category first.");

# Insert new board
$query = "
	INSERT INTO boards SET
		id         = NULL,
		title      = 'New Board',
		categoryId = $firstCatId, 
		pos        = 999, 
		expiration = 0,
		markup     = 1, 
		approve    = 0, 
		score      = 0,
		private    = 1,
		announce   = 0,
		flat       = 0,
		shortDesc  = 'Short Description', 
		longDesc   = 'Long Description'";
$dbh->do($query) or dbError();
$query = "SELECT LAST_INSERT_ID()";
$sth = query($query);
my $boardId = $sth->fetchrow_array();

# Log action
logAction(1, 'board', 'create', $user->primary_key, $boardId);

# Redirect to board options page
redirect("board_options.pl?bid=$boardId&ori=brdAdm");
