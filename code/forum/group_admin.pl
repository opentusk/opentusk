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

# Check if user is admin
$user->{admin} or $m->adminError();

# Print header
$m->printHeader();

# Print page bar
my @navLinks = ({ url => $m->url('forum_show'), txt => 'comUp', ico => 'up' });
$m->printPageBar(mainTitle => "Group Administration", navLinks => \@navLinks);

# Print create board form
print
	"<form action='group_add$m->{ext}' method='post'>\n",
	"<div class='frm'>\n",
	"<div class='hcl'>\n",
	"<span class='htt'>Create Group</span>\n",
	"</div>\n",
	"<div class='ccl'>\n",
	$m->submitButton("Create", 'group'),
	$m->stdFormFields(),
	"</div>\n",
	"</div>\n",
	"</form>\n\n";

# Get groups
my $groups = $m->fetchAllHash("
	SELECT id, title FROM $cfg->{dbPrefix}groups ORDER BY title");

# Print group list
print
	"<table class='tbl'>\n",
	"<tr class='hrw'>\n",
	"<th>Title</th>\n",
	"<th>Commands</th>\n",
	"</tr>\n";

for my $group (@$groups) {
	my $groupId = $group->{id};
	my $infUrl = $m->url('group_info', gid => $groupId);
	my $optUrl = $m->url('group_options', gid => $groupId, ori => 1);
	my $mbrUrl = $m->url('group_members', gid => $groupId);
	my $brdUrl = $m->url('group_boards', gid => $groupId, ori => 1);
	my $delUrl = $m->url('user_confirm', gid => $groupId, script => 'group_delete', 
		name => $group->{title}, ori => 1);
	print
		"<tr class='crw'>\n",
		"<td><a href='$infUrl'>$group->{title}</a></td>\n",
		"<td class='shr'>\n",
		"<a class='btl' href='$optUrl'>Opt</a>\n",
		"<a class='btl' href='$mbrUrl'>Mbr</a>\n",
		"<a class='btl' href='$brdUrl'>Brd</a>\n",
		"<a class='btl' href='$delUrl'>Del</a>\n",
		"</td></tr>\n";
}

print "</table>\n\n";

# Log action
$m->logAction(3, 'group', 'admin', $userId);

# Print footer
$m->printFooter();
