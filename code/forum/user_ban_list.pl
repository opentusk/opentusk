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
my @navLinks = ({ url => $m->url('user_admin'), txt => 'comUp', ico => 'up' });
$m->printPageBar(mainTitle => "Bans", navLinks => \@navLinks);

# Get bans
my $bans = $m->fetchAllHash("
	SELECT userBans.*, users.userName 
	FROM $cfg->{dbPrefix}userBans AS userBans
		INNER JOIN $cfg->{dbPrefix}users AS users
			ON users.id = userBans.userId
	ORDER BY users.userName");

# Print ban list
print
	"<table class='tbl'>\n",
	"<tr class='hrw'>\n",
	"<th>Username</th>\n",
	"<th>Time</th>\n",
	"<th>Duration</th>\n",
	"<th>Reason</th>\n",
	"<th>Internal</th>\n",
	"<th>Commands</th>\n",
	"</tr>\n";

for my $ban (@$bans) {
	my $banUserId = $ban->{userId};
	my $timeStr = $m->formatTime($ban->{banTime}, $user->{timezone});
	my $durationStr = $ban->{duration} ? $ban->{duration} . " days" : "infinite";
	my $infUrl = $m->url('user_info', uid => $banUserId);
	my $banUrl = $m->url('user_ban', uid => $banUserId);
	my $delUrl = $m->url('user_confirm', uid => $banUserId, script => 'user_delete', 
		name => $ban->{userName}, ori => 1);

	print
		"<tr class='crw'>\n",
		"<td><a href='$infUrl'>$ban->{userName}</a></td>\n",
		"<td>$timeStr</td>\n",
		"<td>$durationStr</td>\n",
		"<td>$ban->{reason}</td>\n",
		"<td>$ban->{intReason}</td>\n",
		"<td class='shr'>\n",
		"<a class='btl' href='$banUrl'>Unban</a>\n",
		"<a class='btl' href='$delUrl'>Delete</a>\n",
		"</td>\n",
		"</tr>\n";
}

print "</table>\n\n";

# Log action
$m->logAction(3, 'user', 'listbans', $userId);

# Print footer
$m->printFooter();
