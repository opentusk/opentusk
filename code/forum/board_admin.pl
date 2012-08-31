#!/usr/bin/perl
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

# Get CGI parameters
my $field = $m->paramStrId('field') || $m->getVar('brdAdmFld', $userId) || 'pos';;
my $sort = $m->paramStrId('sort') || $m->getVar('brdAdmSrt', $userId) || 'categPos';
my $order = $m->paramStrId('order') || $m->getVar('brdAdmOrd', $userId) || 'asc';

# Save options
$m->setVar('brdAdmFld', $field, $userId);
$m->setVar('brdAdmSrt', $sort, $userId);
$m->setVar('brdAdmOrd', $order, $userId);

# Print page bar
my @navLinks = ({ url => $m->url('forum_show'), txt => 'comUp', ico => 'up' });
$m->printPageBar(mainTitle => "Board Administration", navLinks => \@navLinks);

# Print create board form
print
	"<form action='board_add$m->{ext}' method='post'>\n",
	"<div class='frm'>\n",
	"<div class='hcl'>\n",
	"<span class='htt'>Create Board</span>\n",
	"</div>\n",
	"<div class='ccl'>\n",
	$m->submitButton("Create", 'board'),
	$m->stdFormFields(),
	"</div>\n",
	"</div>\n",
	"</form>\n\n";

# Define values and names for selectable fields
my %fields = (
	pos => "Position",
	categoryId => "Category ID",
	shortDesc => "Short Description",
	longDesc => "Long Description",
	private => "Read Access",
	announce => "Write Access",
	unregistered => "Unregistered",
	anonymous => "Anonymous",
	approve => "Moderation",
	flat => "Non-Threaded",
	attach => "Attachments",
	locking => "Topic Locking",
	expiration => "Topic Expiration",
);

# Determine listbox selections
my %state = (
	$sort => "selected='selected'",
	$order => "selected='selected'",
	"field$field" => "selected='selected'",
);

# Print board list form
print
	"<form action='board_admin$m->{ext}' method='get'>\n",
	"<div class='frm'>\n",
	"<div class='hcl'>\n",
	"<span class='htt'>List Boards</span>\n",
	"</div>\n",
	"<div class='ccl'>\n",
	"Field \n",
	"<select name='field' size='1'>\n";

print "<option value='$_' $state{\"field$_\"}>$fields{$_}</option>\n"
	for sort({$fields{$a} cmp $fields{$b}} keys(%fields));

print
	"</select>\n",
	"Sort \n",
	"<select name='sort' size='1'>\n",
	"<option value='categPos' $state{categPos}>Categ/Pos</option>\n",
	"<option value='title' $state{title}>Title</option>\n",
	"<option value='id' $state{id}>ID</option>\n",
	"<option value='field' $state{field}>Field</option>\n",
	"</select>\n",
	"Order \n",
	"<select name='order' size='1'>\n",
	"<option value='asc' $state{asc}>Ascending</option>\n",
	"<option value='desc' $state{desc}>Descending</option>\n",
	"</select>\n",
	"<input type='submit' value='List'/>\n",
	$m->{sessionId} ? "<input type='hidden' name='sid' value='$m->{sessionId}'/>\n" : "",
	"</div>\n",
	"</div>\n",
	"</form>\n\n";
	
# Sort list by
if ($sort eq 'field') { 
	$sort = $field;
}
elsif ($sort eq 'categPos') { 
	$sort = "categories.pos, boards.pos";
	$order = "";
}
$order = "DESC" if $order eq 'desc';

# Get boards
my $boards = $m->fetchAllHash("
	SELECT boards.id, boards.title, boards.$field, 
		categories.title AS categTitle
	FROM $cfg->{dbPrefix}boards AS boards
		INNER JOIN $cfg->{dbPrefix}categories AS categories
			ON categories.id = boards.categoryId
	ORDER BY $sort $order");

# Print board list
print
	"<table class='tbl'>\n",
	"<tr class='hrw'>\n",
	"<th>Title</th>\n",
	"<th>$field</th>\n",
	"<th>Commands</th>\n",
	"</tr>\n";

for my $board (@$boards) {
	my $boardId = $board->{id};
	my $nameStr = $m->abbr($board->{categTitle}, 30) . " / " . $m->abbr($board->{title}, 30);
	my $infUrl = $m->url('board_info', bid => $boardId);
	my $optUrl = $m->url('board_options', bid => $boardId, ori => 1);
	my $mbrUrl = $m->url('board_members', bid => $boardId);
	my $grpUrl = $m->url('board_groups', bid => $boardId, ori => 1);
	my $delUrl = $m->url('user_confirm', bid => $boardId, script => 'board_delete', 
		name => $board->{title}, ori => 1);
	print
		"<tr class='crw'>\n",
		"<td><a href='$infUrl'>$nameStr</a></td>\n",
		"<td>$board->{$field}</td>\n",
		"<td class='shr'>\n",
		"<a class='btl' href='$optUrl'>Opt</a>\n",
		"<a class='btl' href='$mbrUrl'>Mbr</a>\n",
		"<a class='btl' href='$grpUrl'>Grp</a>\n",
		"<a class='btl' href='$delUrl'>Del</a>\n",
		"</td></tr>\n";
}

print "</table>\n\n";

# Log action
$m->logAction(3, 'board', 'admin', $userId);

# Print footer
$m->printFooter();
