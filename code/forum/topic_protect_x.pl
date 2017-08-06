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
my $topicId = int($cgi->param('tid'));
$topicId or paramError($lng->{'errTpcIdMiss'});

# Get topic
my $query = "SELECT boardId, protected FROM topics WHERE id = $topicId";
my $sth = query($query);
my ($boardId, $protected) = $sth->fetchrow_array();
$boardId or entryError($lng->{'errTpcNotFnd'});

# Check if user is forum/board admin
$user->{'admin'} || boardAdmin($user->primary_key, $boardId) or adminError();

# Toggle flag
$protected = $protected ? 0 : 1;

# Update topic
$query = "UPDATE topics SET protected = $protected WHERE id = $topicId";
$dbh->do($query) or dbError();

# Log action
logAction(1, 'topic', $protected ? 'protect' : 'unprotect', $user->primary_key, $boardId, $topicId);

# Redirect back
my $msg = $protected ? "TpcProt" : "TpcUnprot";
redirect("topic_show.pl?tid=$topicId&msg=$msg");



