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
my $boardId = $cgi->param('bid');
my $title = $cgi->param('title');
my $shortDesc  = $cgi->param('shortDesc');
my $longDesc = $cgi->param('longDesc');
my $locking = $cgi->param('locking');
my $expiration = $cgi->param('expiration');
my $pos = $cgi->param('pos');
my $m2fMailUser = $cgi->param('m2fMailUser');
my $categoryId = $cgi->param('categoryId');
my $markup = $cgi->param('markup') ? 1 : 0;
my $approve = $cgi->param('approve') ? 1 : 0;
my $score = $cgi->param('score') ? 1 : 0;
my $private = $cgi->param('private') ? 1 : 0;
my $anonymous = $cgi->param('anonymous') ? 1 : 0;
my $announce = $cgi->param('announce');
my $flat = $cgi->param('flat') ? 1 : 0;
my $origin = $cgi->param('ori');
$boardId or paramError($lng->{'errBrdIdMiss'});
$title or userError("Title is empty.");
$pos or userError("Position is empty or zero.");
$categoryId or userError("Category ID is empty or zero.");

# Quote strings
my $titleQ = quote(escHtml($title, 1));
my $shortDescQ = quote($shortDesc, 1);
my $longDescQ = quote($longDesc, 1);
my $m2fMailUserQ = quote(escHtml($m2fMailUser, 1));

# Mail user for Mail2Forum
my $m2fStr = $m2fMailUser ? "m2fMailUser = $m2fMailUserQ,\n" : "";

# Update board
my $query = "
	UPDATE boards SET
		title      = $titleQ,
		categoryId = $categoryId, 
		pos        = $pos, 
		expiration = $expiration,
		locking    = $locking,
		markup     = $markup, 
		approve    = $approve, 
		score      = $score,
		private    = $private,
		anonymous  = $anonymous,
		announce   = $announce,
		flat       = $flat,
		$m2fStr 
		shortDesc  = $shortDescQ, 
		longDesc   = $longDescQ
	WHERE id   = $boardId";
$dbh->do($query) or dbError();

# Log action
logAction(1, 'board', 'options', $user->primary_key, $boardId);

# Redirect
$origin eq "brdAdm"
	? redirect("board_admin.pl")
	: redirect("board_info.pl?bid=$boardId");
