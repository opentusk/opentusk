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

# Check if access should be denied
$m->checkBan($userId) if $cfg->{banViewing};
$m->checkBlock();

# Print header
$m->printHeader();

# Get CGI parameters
my $groupId = $m->paramInt('gid');
$groupId or $m->paramError($lng->{errGrpIdMiss});

# Get group name
my $groupTitle = $m->fetchArray("
	SELECT title FROM $cfg->{dbPrefix}groups WHERE id = $groupId");
$groupTitle or $m->entryError($lng->{errGrpNotFnd});

# Check if user can see group
my $groupMember = $m->fetchArray("
	SELECT 1 
	FROM $cfg->{dbPrefix}groupMembers 
	WHERE groupId = $groupId
		AND userId = $userId");
$groupMember || $user->{admin} or $m->entryError($lng->{errGrpNotFnd});

# Admin button links
my @adminLinks = ();
if ($user->{admin}) {
	push @adminLinks, { url => $m->url('group_options', gid => $groupId, ori => 1), 
		txt => "Options", ico => 'option' };
	push @adminLinks, { url => $m->url('group_members', gid => $groupId), 
		txt => "Members", ico => 'user' };
	push @adminLinks, { url => $m->url('group_boards', gid => $groupId, ori => 1), 
	txt => "Boards", ico => 'board' };
	push @adminLinks, { url => $m->url('user_confirm', gid => $groupId, script => 'group_delete', 
		name => $groupTitle), txt => "Delete", ico => 'delete' };
}

# Print page bar
my @navLinks = ({ url => $m->url('group_admin'), txt => 'comUp', ico => 'up' });
$m->printPageBar(mainTitle => $lng->{griTitle}, subTitle => $groupTitle,
	navLinks => \@navLinks, adminLinks => \@adminLinks);

# Get members
my $members = $m->fetchAllArray("
	SELECT users.id, users.userName 
	FROM $cfg->{dbPrefix}groupMembers AS groupMembers
		INNER JOIN $cfg->{dbPrefix}users AS users
			ON users.id = groupMembers.userId
	WHERE groupMembers.groupId = $groupId
	ORDER BY users.userName
	LIMIT 500");
for (@$members) { 
	my $url = $m->url('user_info', uid => $_->[0]);
	$_ = "<a href='$url'>$_->[1]</a>";
}
my $memberStr = join(",\n", @$members) || " - ";

# Print members
print
	"<div class='frm'>\n",
	"<div class='hcl'>\n",
	"<span class='htt'>$lng->{griMbrTtl}</span>\n",
	"</div>\n",
	"<div class='ccl'>\n",
	$memberStr, "\n",
	"</div>\n",
	"</div>\n\n";

# Get admin boards
my $boards = $m->fetchAllArray("
	SELECT boards.id, boards.title
	FROM $cfg->{dbPrefix}boardAdminGroups AS boardAdminGroups
		INNER JOIN $cfg->{dbPrefix}boards AS boards
			ON boards.id = boardAdminGroups.boardId
		INNER JOIN $cfg->{dbPrefix}categories AS categories
			ON categories.id = boards.categoryId
	WHERE boardAdminGroups.groupId = $groupId
	ORDER BY categories.pos, boards.pos");
for (@$boards) { 
	my $url = $m->url('board_info', bid => $_->[0]);
	$_ = "<a href='$url'>$_->[1]</a>";
}
my $boardsStr = join(",\n", @$boards) || " - ";

# Print admin boards
print
	"<div class='frm'>\n",
	"<div class='hcl'>\n",
	"<span class='htt'>$lng->{griBrdAdmTtl}</span>\n",
	"</div>\n",
	"<div class='ccl'>\n",
	$boardsStr, "\n",
	"</div>\n",
	"</div>\n\n";

# Get member boards
$boards = $m->fetchAllArray("
	SELECT boards.id, boards.title 
	FROM $cfg->{dbPrefix}boardMemberGroups AS boardMemberGroups
		INNER JOIN $cfg->{dbPrefix}boards AS boards
			ON boards.id = boardMemberGroups.boardId
		INNER JOIN $cfg->{dbPrefix}categories AS categories
			ON categories.id = boards.categoryId
	WHERE boardMemberGroups.groupId = $groupId
	ORDER BY categories.pos, boards.pos");
for (@$boards) { 
	my $url = $m->url('board_info', bid => $_->[0]);
	$_ = "<a href='$url'>$_->[1]</a>";
}
$boardsStr = join(",\n", @$boards) || " - ";

# Print member boards
print
	"<div class='frm'>\n",
	"<div class='hcl'>\n",
	"<span class='htt'>$lng->{griBrdMbrTtl}</span>\n",
	"</div>\n",
	"<div class='ccl'>\n",
	$boardsStr, "\n",
	"</div>\n",
	"</div>\n\n";

# Log action
$m->logAction(3, 'group', 'info', $userId, 0, 0, 0, $groupId);

# Print footer
$m->printFooter();
