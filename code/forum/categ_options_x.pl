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
my $categId = $cgi->param('cid');
my $title = $cgi->param('title');
my $page = $cgi->param('page');
my $pos = $cgi->param('pos');
$categId or paramError($lng->{'errCatIdMiss'});
$title or userError("Title is empty.");
$page or userError("Page is empty or zero.");
$pos or userError("Position is empty or zero.");

# Quote strings
my $titleQ = quote(escHtml($title, 1));

# Update category
my $query = "
	UPDATE categories SET
		title = $titleQ,
		page = $page, 
		pos = $pos 
	WHERE id = $categId";
$dbh->do($query) or dbError();

# Log action
logAction(1, 'category', 'options', $user->primary_key, 0, 0, 0, $categId);

# Redirect
redirect("categ_admin.pl");




