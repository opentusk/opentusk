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

#------------------------------------------------------------------------------

# Get user
connectDb();
authUser();

# Print HTTP header
printHttpHeader();

# Check if user is admin
$user->{'admin'} or adminError();

# Insert new category
my $query = "
	INSERT INTO categories SET
		id    = NULL,
		title = 'New Category',
		pos   = 255";
$dbh->do($query) or dbError();
$query = "SELECT LAST_INSERT_ID()";
my $sth = query($query);
my $categId = $sth->fetchrow_array();

# Log action
logAction(1, 'category', 'create', $user->primary_key, 0, 0, 0, $categId);

# Redirect to category options page
redirect("categ_options.pl?cid=$categId");
