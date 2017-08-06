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
$m->checkBan($userId) if $cfg->{banViewing};
$m->checkBlock();

# Print header
$m->printHeader();

# Get CGI parameters
my $boardId = $m->paramInt('bid');
$boardId or $m->paramError($lng->{errBrdIdMiss});

# Get board
my $board = $m->fetchHash("
	SELECT * FROM $cfg->{dbPrefix}boards WHERE id = $boardId");
$board or $m->entryError($lng->{errBrdNotFnd});

# Is board visible to user?
$m->boardVisible($board) or $m->entryError($lng->{errBrdNotFnd});

# Print page bar
my @navLinks = ({ url => $m->url('board_show', bid => $boardId), txt => 'comUp', ico => 'up' });
$m->printPageBar(mainTitle => $lng->{bifTitle}, subTitle => $board->{title}, 
	navLinks => \@navLinks);

# Prepare strings
my $descStr = $board->{longDesc} || $board->{shortDesc};
my $privStr = $lng->{"bifOptPriv$board->{private}"};
my $anncStr = $lng->{"bifOptAnnc$board->{announce}"};
my $unrgStr = $board->{unregistered} ? $lng->{bifOptUnrgY} : $lng->{bifOptUnrgN};
my $anonStr = $board->{anonymous} ? $lng->{bifOptAnonY} : $lng->{bifOptAnonN};
my $aprvStr = $board->{approve} ? $lng->{bifOptAprvY} : $lng->{bifOptAprvN};
my $flatStr = $board->{flat} ? $lng->{bifOptFlatY} : $lng->{bifOptFlatN};
my $attcStr = $board->{attach} ? $lng->{bifOptAttcY} : $lng->{bifOptAttcN};
my $lockStr = $board->{locking} ? "$board->{locking} $lng->{bifOptLockT}" : "-";
my $expiStr = $board->{expiration} ? "$board->{expiration} $lng->{bifOptExpT}" : "-";

# Print board options
print
	"<table class='tbl'>\n",
	"<tr class='hrw'>\n",
	"<th colspan='2'>$lng->{bifOptTtl}</th>\n",
	"</tr>\n",
	"<tr class='crw'>\n",
	"<td class='hco'>$lng->{bifOptDesc}</td>\n",
	"<td>$descStr</td>\n",
	"</tr>\n",
	"<tr class='crw'>\n",
	"<td class='hco'>$lng->{bifOptPriv}</td>\n",
	"<td>$privStr</td>\n",
	"</tr>\n",
	"<tr class='crw'>\n",
	"<td class='hco'>$lng->{bifOptAnnc}</td>\n",
	"<td>$anncStr</td>\n",
	"</tr>\n",
	"<tr class='crw'>\n",
	"<td class='hco'>$lng->{bifOptUnrg}</td>\n",
	"<td>$unrgStr</td>\n",
	"</tr>\n",
	"<tr class='crw'>\n",
	"<td class='hco'>$lng->{bifOptAnon}</td>\n",
	"<td>$anonStr</td>\n",
	"</tr>\n",
	"<tr class='crw'>\n",
	"<td class='hco'>$lng->{bifOptAprv}</td>\n",
	"<td>$aprvStr</td>\n",
	"</tr>\n",
	"<tr class='crw'>\n",
	"<td class='hco'>$lng->{bifOptFlat}</td>\n",
	"<td>$flatStr</td>\n",
	"</tr>\n",
	"<tr class='crw'>\n",
	"<td class='hco'>$lng->{bifOptAttc}</td>\n",
	"<td>$attcStr</td>\n",
	"</tr>\n",
	"<tr class='crw'>\n",
	"<td class='hco'>$lng->{bifOptLock}</td>\n",
	"<td>$lockStr</td>\n",
	"</tr>\n",
	"<tr class='crw'>\n",
	"<td class='hco'>$lng->{bifOptExp}</td>\n",
	"<td>$expiStr</td>\n",
	"</tr>\n",
	"</table>\n\n";

# Get moderators
my $admins = $m->fetchAllArray("
	SELECT users.id, users.userName 
	FROM $cfg->{dbPrefix}boardAdmins AS boardAdmins
		INNER JOIN $cfg->{dbPrefix}users AS users
			ON users.id = boardAdmins.userId
	WHERE boardAdmins.boardId = $boardId
	ORDER BY users.userName
	LIMIT 500");
for (@$admins) { 
	my $url = $m->url('user_info', uid => $_->[0]);
	$_ = "<a href='$url'>$_->[1]</a>";
}

# Get moderator groups
my $adminGroups = $m->fetchAllArray("
	SELECT groups.id, groups.title, groupMembers.userId
	FROM $cfg->{dbPrefix}boardAdminGroups AS boardAdminGroups
		INNER JOIN $cfg->{dbPrefix}groups AS groups
			ON groups.id = boardAdminGroups.groupId
		LEFT JOIN $cfg->{dbPrefix}groupMembers AS groupMembers
			ON groupMembers.userId = $userId
			AND groupMembers.groupId = groups.id
	WHERE boardAdminGroups.boardId = $boardId
	ORDER BY groups.title");
for (@$adminGroups) { 
	if ($_->[2] || $user->{admin}) {
		my $url = $m->url('group_info', gid => $_->[0]);
		$_ = "<a class='grp' href='$url'>$_->[1]</a>";
	}
	else { $_ = $_->[1] }
}

# Print moderators
my $adminStr = join(",\n", @$adminGroups, @$admins) || " - ";
print
	"<div class='frm'>\n",
	"<div class='hcl'>\n",
	"<span class='htt'>$lng->{bifAdmsTtl}</span>\n",
	"</div>\n",
	"<div class='ccl'>\n",
	$adminStr, "\n",
	"</div>\n",
	"</div>\n\n";

# Get members
my $members = $m->fetchAllArray("
	SELECT users.id, users.userName 
	FROM $cfg->{dbPrefix}boardMembers AS boardMembers
		INNER JOIN $cfg->{dbPrefix}users AS users
			ON users.id = boardMembers.userId 
	WHERE boardMembers.boardId = $boardId
	ORDER BY users.userName
	LIMIT 500");
for (@$members) { 
	my $url = $m->url('user_info', uid => $_->[0]);
	$_ = "<a href='$url'>$_->[1]</a>";
}

# Get member groups
my $memberGroups = $m->fetchAllArray("
	SELECT groups.id, groups.title, groupMembers.userId
	FROM $cfg->{dbPrefix}boardMemberGroups AS boardMemberGroups
		INNER JOIN $cfg->{dbPrefix}groups AS groups
			ON groups.id = boardMemberGroups.groupId
		LEFT JOIN $cfg->{dbPrefix}groupMembers AS groupMembers
			ON groupMembers.userId = $userId
			AND groupMembers.groupId = groups.id
	WHERE boardMemberGroups.boardId = $boardId
	ORDER BY groups.title");
for (@$memberGroups) { 
	if ($_->[2] || $user->{admin}) {
		my $url = $m->url('group_info', gid => $_->[0]);
		$_ = "<a class='grp' href='$url'>$_->[1]</a>";
	}
	else { $_ = $_->[1] }
}

# Print members
my $memberStr = join(",\n", @$memberGroups, @$members) || " - ";
print
	"<div class='frm'>\n",
	"<div class='hcl'>\n",
	"<span class='htt'>$lng->{bifMbrsTtl}</span>\n",
	"</div>\n",
	"<div class='ccl'>\n",
	$memberStr, "\n",
	"</div>\n",
	"</div>\n\n";

if ($user->{admin}) {
	# Get subscribers
	my $subscribers = $m->fetchAllArray("
		SELECT users.id, users.userName 
		FROM $cfg->{dbPrefix}boardSubscriptions AS boardSubscriptions
			INNER JOIN $cfg->{dbPrefix}users AS users
				ON users.id = boardSubscriptions.userId 
		WHERE boardSubscriptions.boardId = $boardId
		ORDER BY users.userName");
	for (@$subscribers) { 
		my $url = $m->url('user_info', uid => $_->[0]);
		$_ = "<a href='$url'>$_->[1]</a>";
	}
	my $subscriberStr = join(",\n", @$subscribers) || " - ";

	# Print subscribers
	print
		"<div class='frm'>\n",
		"<div class='hcl'>\n",
		"<span class='htt'>Subscribers</span>\n",
		"</div>\n",
		"<div class='ccl'>\n",
		$subscriberStr, "\n",
		"</div>\n",
		"</div>\n\n";
}
	
# Log action
$m->logAction(3, 'board', 'info', $userId, $boardId);

# Print footer
$m->printFooter();
