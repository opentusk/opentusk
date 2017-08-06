#!/usr/bin/env perl
#------------------------------------------------------------------------------
#    mwForum - Web-based discussion forum
#    Copyright (c) 1999-2007 Markus Wichitill
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#------------------------------------------------------------------------------

use strict;
use warnings;
no warnings qw(uninitialized redefine);

# Imports
use Forum::MwfMain;

#------------------------------------------------------------------------------

# Init
my ($m, $cfg, $lng, $user) = MwfMain->new(@_);
my $userId = $user->{id};

# Check if access should be denied
$m->checkBan($userId);
$m->checkBlock();

# Print header
$m->printHeader();

# Print page bar
my @navLinks = ({ url => $m->url('forum_show'), txt => 'comUp', ico => 'up' });
$m->printPageBar(mainTitle => $lng->{fedTitle}, navLinks => \@navLinks);

# TUSK begin
# User should only see rss feeds for boards they can see.  modifying code.
# Get boards
my $boards = Forum::ForumKey::getViewableBoardsHash($m, $user);
=pod
my $boards = $m->fetchAllHash("
	SELECT boards.id, boards.title,
		categories.title AS categTitle
	FROM $cfg->{dbPrefix}boards AS boards
		INNER JOIN $cfg->{dbPrefix}categories AS categories
			ON categories.id = boards.categoryId
	WHERE boards.private = 0
	ORDER BY categories.pos, boards.pos");
=cut
# TUSK end
# Print feed list
my $path = "$cfg->{attachUrlPath}/xml";

# TUSK begin
# removing the all boards rss feeds because these contain all boards,
# even if some are supposed to be restricted for the user.
print "<table class='tbl'>\n";
=pod
print
	"<table class='tbl'>\n",
	"<tr class='crw'>\n",
	"<td>$lng->{fedAllBoards}</td>\n",
	"<td class='shr'><a href='$path/forum.atom10.xml'>Atom 1.0</a></td>\n",
	"<td class='shr'><a href='$path/forum.rss200.xml'>RSS 2.0</a></td>\n",
	"</tr>\n";

print

	"<tr class='crw'>\n",
	"<td>$lng->{fedAllBlogs}</td>\n",
	"<td class='shr'><a href='$path/blogs.atom10.xml'>Atom 1.0</a></td>\n",
	"<td class='shr'><a href='$path/blogs.rss200.xml'>RSS 2.0</a></td>\n",
	"</tr>\n"
	if $cfg->{blogs} == 1;
=cut
# TUSK end
	
for my $board (@$boards) {
# TUSK begin
# changing the rss link to be a random number generated from the bid.
    srand($board->{id});
    my $randBid = rand();       
    print
		"<tr class='crw'>\n",
		"<td>$board->{categTitle} / $board->{title}</td>\n",
#		"<td class='shr'><a href='$path/board$board->{id}.atom10.xml'>Atom 1.0</a></td>\n",
#		"<td class='shr'><a href='$path/board$board->{id}.rss200.xml'>RSS 2.0</a></td>\n",
		"<td class='shr'><a href='$path/board$randBid.atom10.xml'>Atom 1.0</a></td>\n",
		"<td class='shr'><a href='$path/board$randBid.rss200.xml'>RSS 2.0</a></td>\n",
		"</tr>\n";
# TUSK end
}

print
	"</table>\n";

# Log action
$m->logAction(3, 'forum', 'feeds', $userId);

# Print footer
$m->printFooter();
