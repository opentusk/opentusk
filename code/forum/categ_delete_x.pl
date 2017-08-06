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

# Check if user is admin
$user->{'admin'} or adminError();

# Get CGI parameters
my $cgi = new Forum::MwfCGI;
my $categId = $cgi->param('cid');
$categId or paramError($lng->{'errCatIdMiss'});

# Only delete category when empty
my $query = "SELECT id FROM boards WHERE categoryId = $categId";
my $sth = query($query);
$sth->rows and userError("Category is not empty.");

# Delete category
$query = "DELETE FROM categories WHERE id = $categId";
$dbh->do($query) or dbError();

# Log action
logAction(1, 'category', 'delete', $user->primary_key, 0, 0, 0, $categId);

# Redirect back
redirect("categ_admin.pl");
