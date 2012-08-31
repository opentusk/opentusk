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
$m->checkBan($userId);
$m->checkBlock();

# Print header
$m->printHeader();

# Get CGI parameters
my $infUserId = $m->paramInt('uid');

# Handle special user IDs
$m->printNote($lng->{errUsrDel}) if $infUserId == 0;
$m->printNote($lng->{errUsrFake}) if $infUserId == -1;

# Get user
my $infUser = $m->getUser($infUserId);
$infUser or $m->entryError($lng->{errUsrNotFnd});
my $userTitle = $infUser->{title} ? $m->formatUserTitle($infUser->{title}) : "";

# User button links
my @userLinks = ();
push @userLinks, { url => $m->url('message_add', uid => $infUserId), 
	txt => 'uifMessage', ico => 'write' }
	if $userId && $cfg->{messages};
push @userLinks, { url => $m->url('user_ignore', uid => $infUserId), 
	txt => 'uifIgnore', ico => 'ignore' }
	if $userId;
push @userLinks, { url => $m->url('blog_show', bid => -$infUserId), 
	txt => 'uifBlog', ico => 'blog' }
	if $cfg->{blogs} && ($cfg->{blogs} != 2 || $userId);
push @userLinks, { url => $m->url('forum_search', uid => $infUserId, mode => 'uid'), 
	txt => 'uifListPst', ico => 'search' };
	
# Admin button links
my @adminLinks = ();
if ($user->{admin}) {
	push @adminLinks, { url => $m->url('user_options', uid => $infUserId, ori => 1), 
		txt => "Options", ico => 'option' };
	push @adminLinks, { url => $m->url('user_groups', uid => $infUserId, ori => 1), 
		txt => "Groups", ico => 'group' };
	push @adminLinks, { url => $m->url('user_boards', uid => $infUserId, ori => 1), 
		txt => "Boards", ico => 'board' };
	push @adminLinks, { url => $m->url('user_topics', uid => $infUserId, ori => 1), 
		txt => "Topics", ico => 'topic' }
		if $cfg->{subscriptions};
	push @adminLinks, { url => $m->url('user_ban', uid => $infUserId), 
		txt => "Ban", ico => 'ban' };
	push @adminLinks, { url => $m->url('user_migrate', uid => $infUserId), 
		txt => "Migrate", ico => 'merge' };
	push @adminLinks, { url => $m->url('user_notify', uid => $infUserId), 
		txt => "Notify", ico => 'write' };
	push @adminLinks, { url => $m->url('user_confirm', uid => $infUserId, script => 'user_delete',
		name => $infUser->{userName}), txt => "Delete", ico => 'delete' };
}

# Print bar
my @navLinks = ({ url => $m->url('forum_show'), txt => 'comUp', ico => 'up' });
$m->printPageBar(mainTitle => $lng->{uifTitle}, subTitle => "$infUser->{userName} $userTitle", 
	navLinks => \@navLinks, userLinks => \@userLinks, adminLinks => \@adminLinks);

# Prepare values
my $email;
if (!$userId || ($infUser->{hideEmail} && !$user->{admin})) {
	$email = $lng->{comHidden};
} 
else {
	$email = $infUser->{email} ? "<a href='mailto:$infUser->{email}'>$infUser->{email}</a>" : " - ";
	$email .= " $lng->{comHidden}" if $infUser->{hideEmail};
}
my $homepage = $infUser->{homepage};
$homepage =~ s!(https?://[^<>\'\"\s\{\}\|\\\^\[\]\)`]+)!<a href='$1'>$1</a>!g;
my $birthdate = "";
$birthdate = $infUser->{birthyear} . "-" if $infUser->{birthyear};
$birthdate .= $infUser->{birthday};

# GeoIP
my $country = "";
if ($cfg->{geoIp}) {
	my $geoIp = undef;
	if (eval { require Geo::IP }) {
		$geoIp = Geo::IP->open($cfg->{geoIp});
	}
	elsif (eval { require Geo::IP::PurePerl }) {
		$geoIp = Geo::IP::PurePerl->open($cfg->{geoIp});
	}
	if ($geoIp) {
		$country = $geoIp->country_name_by_addr($infUser->{lastIp});
	}
}

# Print user profile
print
	"<table class='tbl'>\n",
	"<tr class='hrw'>\n",
	"<th colspan='2'>$lng->{uifProfTtl}</th>\n",
	"</tr>\n";

print
	"<tr class='crw'>\n",
	"<td class='hco'>$lng->{uifProfAvat}</td>\n",
	"<td><img src='$cfg->{attachUrlPath}/avatars/$infUser->{avatar}' alt=''/></td>\n",
	"</tr>\n"
	if $cfg->{avatars} && $infUser->{avatar};

print
	"<tr class='crw'>\n",
	"<td class='hco'>$lng->{uifProfEml}</td>\n",
	"<td>$email</td>\n",
	"</tr>\n";

print	
	"<tr class='crw'>\n",
	"<td class='hco'>$lng->{uifProfRName}</td>\n",
	"<td>$infUser->{realName}</td>\n",
	"</tr>\n"
	if $infUser->{realName};

print	
	"<tr class='crw'>\n",
	"<td class='hco'>$lng->{uifProfBdate}</td>\n",
	"<td>$birthdate</td>\n",
	"</tr>\n"
	if $birthdate;

print	
	"<tr class='crw'>\n",
	"<td class='hco'>$lng->{uifProfPage}</td>\n",
	"<td>$homepage</td>\n",
	"</tr>\n"
	if $homepage;

print	
	"<tr class='crw'>\n",
	"<td class='hco'>$lng->{uifProfOccup}</td>\n",
	"<td>$infUser->{occupation}</td>\n",
	"</tr>\n"
	if $infUser->{occupation};

print	
	"<tr class='crw'>\n",
	"<td class='hco'>$lng->{uifProfHobby}</td>\n",
	"<td>$infUser->{hobbies}</td>\n",
	"</tr>\n"
	if $infUser->{hobbies};

print	
	"<tr class='crw'>\n",
	"<td class='hco'>$lng->{uifProfLocat}</td>\n",
	"<td>$infUser->{location}</td>\n",
	"</tr>\n"
	if $infUser->{location};

print
	"<tr class='crw'>\n",
	"<td class='hco'>$lng->{uifProfGeoIp}</td>\n",
	"<td>$country</td>\n",
	"</tr>\n"
	if $country;

print
	"<tr class='crw'>\n",
	"<td class='hco'>$lng->{uifProfIcq}</td>\n",
	"<td>$infUser->{icq}</td>\n",
	"</tr>\n"
	if $infUser->{icq};

# Print configurable user fields
print
	"<tr class='crw'>\n",
	"<td class='hco'>$cfg->{extra1}</td>\n",
	"<td>$infUser->{extra1}</td>\n",
	"</tr>\n"
	if length($infUser->{extra1}) && $cfg->{extra1} && ($cfg->{showExtra1} || $user->{admin});
	
print
	"<tr class='crw'>\n",
	"<td class='hco'>$cfg->{extra2}</td>\n",
	"<td>$infUser->{extra2}</td>\n",
	"</tr>\n"
	if length($infUser->{extra2}) && $cfg->{extra2} && ($cfg->{showExtra2} || $user->{admin});

print
	"<tr class='crw'>\n",
	"<td class='hco'>$cfg->{extra3}</td>\n",
	"<td>$infUser->{extra3}</td>\n",
	"</tr>\n"
	if length($infUser->{extra3}) && $cfg->{extra3} && ($cfg->{showExtra3} || $user->{admin});

# Print signature
if ($infUser->{signature}) {
	my $fakePost = {};
	$fakePost->{body} = $infUser->{signature};
	$m->dbToDisplay({}, $fakePost);
	print
		"<tr class='crw'>\n",
		"<td class='hco'>$lng->{uifProfSig}</td>\n",
		"<td>$fakePost->{body}</td>\n",
		"</tr>\n";
}

print "</table>\n\n";

# Format stats
my $blogNum = $m->fetchArray("
	SELECT COUNT(*) FROM $cfg->{dbPrefix}topics WHERE boardId = -$infUserId");
my $ignoredNum = $m->fetchArray("
	SELECT COUNT(*) FROM $cfg->{dbPrefix}userIgnores WHERE ignoredId = $infUserId");
my $regTimeStr = $m->formatTime($infUser->{regTime}, $user->{timezone});
my $lastIpStr = $infUser->{lastIp}
	? $infUser->{lastIp} : " - ";
$lastIpStr .= " (" . $m->escHtml($infUser->{host}) . ")" if $infUser->{host};
my $userAgentStr = $infUser->{userAgent}
	? $infUser->{userAgent} : " - ";
my $lastOnTimeStr = $infUser->{lastOnTime}
	? $m->formatTime($infUser->{lastOnTime}, $user->{timezone}) : " - ";
my $prevOnTimeStr = $infUser->{prevOnTime}
	? $m->formatTime($infUser->{prevOnTime}, $user->{timezone}) : " - ";
my $bounceStr = $infUser->{bounceNum} / ($cfg->{bounceFactor} || 3);
	
# Print public user stats	
print
	"<table class='tbl'>\n",
	"<tr class='hrw'>\n",
	"<th colspan='2'>$lng->{uifStatTtl}</th>\n",
	"</tr>\n";

print
	"<tr class='crw'>\n",
	"<td class='hco'>$lng->{uifStatRank}</td>\n",
	"<td>" . $m->formatUserRank($infUser->{postNum}) . "</td>\n",
	"</tr>\n"
	if @{$cfg->{userRanks}};

print	
	"<tr class='crw'>\n",
	"<td class='hco'>$lng->{uifStatPNum}</td>\n",
	"<td>$infUser->{postNum}</td>\n",
	"</tr>\n";

print
	"<tr class='crw'>\n",
	"<td class='hco'>$lng->{uifStatBNum}</td>\n",
	"<td>$blogNum</td>\n",
	"</tr>\n"
	if $cfg->{blogs};

print
	"<tr class='crw'>\n",
	"<td class='hco'>$lng->{uifStatRegTm}</td>\n",
	"<td>$regTimeStr</td>\n",
	"</tr>\n";
	
# Print non-public user stats	
print
	"<tr class='crw'>\n",
	"<td class='hco'>$lng->{uifStatLOTm}</td>\n",
	"<td>$lastOnTimeStr</td>\n",
	"</tr>\n",
	"<tr class='crw'>\n",
	"<td class='hco'>$lng->{uifStatLRTm}</td>\n",
	"<td>$prevOnTimeStr</td>\n",
	"</tr>\n"
	if $userId == $infUserId || $user->{admin};

# Print user's last IP
print
	"<tr class='crw'>\n",
	"<td class='hco'>$lng->{uifStatLIp}</td>\n",
	"<td>$lastIpStr</td>\n",
	"</tr>\n"
	if $cfg->{showUserIp} || $user->{admin};

# Print admin-only user stats
print
	"<tr class='crw'>\n",
	"<td class='hco'>User Agent</td>\n",
	"<td>$userAgentStr</td>\n",
	"</tr>\n",
	"<tr class='crw'>\n",
	"<td class='hco'>Ignored By</td>\n",
	"<td>$ignoredNum users</td>\n",
	"</tr>\n",
	"<tr class='crw'>\n",
	"<td class='hco'>Bounced Emails</td>\n",
	"<td>$bounceStr</td>\n",
	"</tr>\n",
	if $user->{admin};

print "</table>\n\n";

# Print non-public admin and member status info
if ($userId == $infUserId || $user->{admin}) {
	# Get member groups
	my $groups = $m->fetchAllArray("
		SELECT groups.id, groups.title
		FROM $cfg->{dbPrefix}groupMembers AS groupMembers
			INNER JOIN $cfg->{dbPrefix}groups AS groups
				ON groups.id = groupMembers.groupId
		WHERE groupMembers.userId = $infUserId
		ORDER BY groups.title");
	for (@$groups) { 
		my $url = $m->url('group_info', gid => $_->[0]);
		$_ = "<a href='$url'>$_->[1]</a>";
	}
	my $groupStr = join(",\n", @$groups) || " - ";
	
	# Print member groups
	print
		"<div class='frm'>\n",
		"<div class='hcl'>\n",
		"<span class='htt'>$lng->{uifGrpMbrTtl}</span>\n",
		"</div>\n",
		"<div class='ccl'>\n",
		$groupStr, "\n",
		"</div>\n",
		"</div>\n\n";

	# Get admin boards
	my $boards = $m->fetchAllArray("
		SELECT boards.id, boards.title
		FROM $cfg->{dbPrefix}boardAdmins AS boardAdmins
			INNER JOIN $cfg->{dbPrefix}boards AS boards
				ON boards.id = boardAdmins.boardId
			INNER JOIN $cfg->{dbPrefix}categories AS categories
				ON categories.id = boards.categoryId
		WHERE boardAdmins.userId = $infUserId
		ORDER BY categories.pos, boards.pos");
	for (@$boards) { 
		my $url = $m->url('board_info', bid => $_->[0]);
		$_ = "<a href='$url'>$_->[1]</a>";
	}
	my $boardStr = join(",\n", @$boards) || " - ";
	
	# Print admin boards
	print
		"<div class='frm'>\n",
		"<div class='hcl'>\n",
		"<span class='htt'>$lng->{uifBrdAdmTtl}</span>\n",
		"</div>\n",
		"<div class='ccl'>\n",
		$boardStr, "\n",
		"</div>\n",
		"</div>\n\n";

	# Get member boards
	$boards = $m->fetchAllArray("
		SELECT boards.id, boards.title 
		FROM $cfg->{dbPrefix}boardMembers AS boardMembers
			INNER JOIN $cfg->{dbPrefix}boards AS boards
				ON boards.id = boardMembers.boardId
			INNER JOIN $cfg->{dbPrefix}categories AS categories
				ON categories.id = boards.categoryId
		WHERE boardMembers.userId = $infUserId
		ORDER BY categories.pos, boards.pos");
	for (@$boards) { 
		my $url = $m->url('board_info', bid => $_->[0]);
		$_ = "<a href='$url'>$_->[1]</a>";
	}
	$boardStr = join(",\n", @$boards) || " - ";

	# Print member boards
	print
		"<div class='frm'>\n",
		"<div class='hcl'>\n",
		"<span class='htt'>$lng->{uifBrdMbrTtl}</span>\n",
		"</div>\n",
		"<div class='ccl'>\n",
		$boardStr, "\n",
		"</div>\n",
		"</div>\n\n";

	# Get subcribed boards
	$boards = $m->fetchAllArray("
		SELECT boards.id, boards.title 
		FROM $cfg->{dbPrefix}boardSubscriptions AS boardSubscriptions
			INNER JOIN $cfg->{dbPrefix}boards AS boards
				ON boards.id = boardSubscriptions.boardId
			INNER JOIN $cfg->{dbPrefix}categories AS categories
				ON categories.id = boards.categoryId
		WHERE boardSubscriptions.userId = $infUserId
		ORDER BY categories.pos, boards.pos");
	for (@$boards) { 
		my $url = $m->url('board_info', bid => $_->[0]);
		$_ = "<a href='$url'>$_->[1]</a>";
	}
	$boardStr = join(",\n", @$boards) || " - ";

	# Print subcribed boards
	print
		"<div class='frm'>\n",
		"<div class='hcl'>\n",
		"<span class='htt'>$lng->{uifBrdSubTtl}</span>\n",
		"</div>\n",
		"<div class='ccl'>\n",
		$boardStr, "\n",
		"</div>\n",
		"</div>\n\n";
}

# Log action
$m->logAction(3, 'user', 'info', $userId, 0, 0, 0, $infUserId);

# Print footer
$m->printFooter();
