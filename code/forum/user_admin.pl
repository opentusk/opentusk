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
my $page = $m->paramInt('pg') || 1;
my $search = $m->paramStr('search') || "";
my $field = $m->paramStrId('field') || $m->getVar('usrAdmFld', $userId) || 'realName';
my $sort = $m->paramStrId('sort') || $m->getVar('usrAdmSrt', $userId) || 'userName';
my $order = $m->paramStrId('order') || $m->getVar('usrAdmOrd', $userId) || 'desc';
my $hideEmpty = $m->paramDefined('search')
	? $m->paramBool('hide') : $m->getVar('usrAdmHid', $userId) || 0;
	
# Define values and names for selectable fields
my %fields = (
	userName => "Username",
	realName => "Real Name",
	email => "Email Address",
	title => "Title",
	admin => "Administrator",
	hideEmail => "Hide Email",
	dontEmail => "Disable Email",
	notify => "Reply Notifications",
	msgNotify => "Email Notifications",
	manOldMark => "Manual Old Marking",
	tempLogin => "Temporary Login",
	secureLogin => "Secure Login",
	privacy => "Hide Online Status",
	homepage => "Website",
	occupation => "Occupation",
	hobbies => "Hobbies",
	location => "Location",
	icq => "Instant Messengers",
	signature => "Signature",
	avatar => "Avatar",
	extra1 => "Extra 1",
	extra2 => "Extra 2",
	extra3 => "Extra 3",
	birthyear => "Birthyear",
	birthday => "Birthday",
	timezone => "Timezone",
	language => "Language",
	style => "Style",
	fontFace => "Font Face",
	fontSize => "Font Size",
	boardDescs => "Show Board Desc.",
	showDeco => "Show Decorations",
	showAvatars => "Show Avatars",
	showImages => "Show Embed. Imgs",
	showSigs => "Show Signatures",
	collapse => "Collapse Branches",
	indent => "Threading Indent",
	topicsPP => "Topics Per Page",
	postsPP => "Posts Per Page",
	regTime => "Registration Time",
	lastOnTime => "Last Online Time",
	prevOnTime => "Prev. Online Time",
	lastIp => "IP Address",
	userAgent => "Browser",
	postNum => "Post Number",
	bounceNum => "Bounce Number",
	gpgKeyId => "OpenPGP Key ID",
);
$field = 'realName' if !($fields{$field});

# Save options
$m->setVar('usrAdmFld', $field, $userId);
$m->setVar('usrAdmSrt', $sort, $userId);
$m->setVar('usrAdmOrd', $order, $userId);
$m->setVar('usrAdmHid', $hideEmpty, $userId);

# Search for username
$search = $m->escHtml($search);
my $searchEsc = $m->dbEscLike($search);
my $like = $m->{pgsql} ? 'ILIKE' : 'LIKE';
my $searchStr = $search ? "AND $field $like " . $m->dbQuote("%$searchEsc%") : "";
my $hideEmptyStr = $hideEmpty ? "AND $field <> ''" : "";

# Sort list by
my $orderStr = "";
if ($sort eq 'userName') { $orderStr = "userName $order" }
elsif ($sort eq 'field') { $orderStr = "$field $order, id ASC" }
else { $orderStr = "id $order" }

# Get ids of users
my $users = $m->fetchAllArray("
	SELECT id
	FROM $cfg->{dbPrefix}users 
	WHERE 1 = 1
		$searchStr 
		$hideEmptyStr
	ORDER BY $orderStr");

# Page links
my $usersPP = 100;
my $pageNum = int(@$users / $usersPP) + (@$users % $usersPP != 0);
my @pageLinks = ();
if ($pageNum > 1) {
	my $prevPage = $page - 1;
	my $nextPage = $page + 1;
	my $maxPageNum = $m->min($pageNum, 8);
	push @pageLinks, { url => $m->url('user_admin', pg => $_), 
		txt => $_, dsb => $_ == $page }
		for 1 .. $maxPageNum;
	push @pageLinks, { txt => "..." }, { 
		url => $m->url('user_admin', pg => $pageNum), 
		txt => $pageNum, dsb => $pageNum == $page }
		if $maxPageNum + 1 < $pageNum;
	push @pageLinks, { url => $m->url('user_admin', pg => $prevPage), 
		txt => 'comPgPrev', dsb => $page == 1 };
	push @pageLinks, { url => $m->url('user_admin', pg => $nextPage), 
		txt => 'comPgNext', dsb => $page == $pageNum };
}

# Get users on page
my @pageUserIds = @$users[($page - 1) * $usersPP .. $m->min($page * $usersPP, scalar @$users) - 1];
my $pageUserIdsStr = join(",", map($_->[0], @pageUserIds)) || "0";
$users = $m->fetchAllHash("
	SELECT id, userName, email, $field 
	FROM $cfg->{dbPrefix}users
	WHERE id IN ($pageUserIdsStr)
	ORDER BY $orderStr");

# Print page bar
my @navLinks = ({ url => $m->url('forum_show'), txt => 'comUp', ico => 'up' });
my @adminLinks = ({ url => $m->url('user_ban_list'), txt => "Bans", ico => 'ban' });
$m->printPageBar(mainTitle => "User Administration", navLinks => \@navLinks,
	pageLinks => \@pageLinks, adminLinks => \@adminLinks);


# Determine listbox/checkbox status
my %state = (
	$sort => "selected='selected'",
	$order => "selected='selected'",
	"field$field" => "selected='selected'",
	hideEmpty => $hideEmpty ? "checked='checked'" : "",
);

# Print user list form
print
	"<form action='user_admin$m->{ext}' method='get'>\n",
	"<div class='frm'>\n",
	"<div class='hcl'>\n",
	"<span class='htt'>List Users</span>\n",
	"</div>\n",
	"<div class='ccl'>\n",
	"Search\n",
	"<input type='text' name='search' style='width: 100px' value='$search'/>\n",
	"Field\n",
	"<select name='field' size='1'>\n";

print "<option value='$_' $state{\"field$_\"}>$fields{$_}</option>\n"
	for sort({$fields{$a} cmp $fields{$b}} keys(%fields));

print
	"</select>\n",
	"Sort\n",
	"<select name='sort' size='1'>\n",
	"<option value='userName' $state{userName}>Username</option>\n",
	"<option value='id' $state{id}>ID</option>\n",
	"<option value='field' $state{field}>Field</option>\n",
	"</select>\n",
	"Order\n",
	"<select name='order' size='1'>\n",
	"<option value='asc' $state{asc}>Asc</option>\n",
	"<option value='desc' $state{desc}>Desc</option>\n",
	"</select>\n",
	"<input type='checkbox' name='hide' $state{hideEmpty}/>Hide empty\n",
	"<input type='submit' value='List'/>\n",
	$m->{sessionId} ? "<input type='hidden' name='sid' value='$m->{sessionId}'/>\n" : "",
	"</div>\n",
	"</div>\n",
	"</form>\n\n";

# Print user list header
print 
	"<table class='tbl'>\n",
	"<tr class='hrw'>\n",
	"<th>Username</th>\n",
	"<th>Email</th>\n",
	"<th>$field</th>\n",
	"<th>Commands</th>\n",
	"</tr>\n";

# Print user list
for my $listUser (@$users) {
	my $listUserId = $listUser->{id};

	# Get string for selectable field
	my $fieldStr = $listUser->{$field};
	if ($field eq 'avatar' && $fieldStr) { 
		$fieldStr = "<img src='$cfg->{attachUrlPath}/avatars/$fieldStr' alt=''/>" 
	}
	elsif ($field =~ /Time$/) { $fieldStr = $m->formatTime($fieldStr, $user->{timezone}) }
	elsif ($fieldStr =~ /^https?:/) { $fieldStr = "<a href='$fieldStr'>$fieldStr</a>" }
	
	my $infUrl = $m->url('user_info', uid => $listUserId);
	my $optUrl = $m->url('user_options', uid => $listUserId, ori => 1);
	my $brdUrl = $m->url('user_boards', uid => $listUserId, ori => 1);
	my $grpUrl = $m->url('user_groups', uid => $listUserId, ori => 1);
	my $delUrl = $m->url('user_confirm', uid => $listUserId, script => 'user_delete', 
		name => $listUser->{userName}, ori => 1);

	print
		"<tr class='crw'>\n",
		"<td><a href='$infUrl'>$listUser->{userName}</a></td>\n",
		"<td><a href='mailto:$listUser->{email}'>$listUser->{email}</a></td>\n",
		"<td>$fieldStr</td>\n",
		"<td class='shr'>\n",
		"<a class='btl' href='$optUrl'>Opt</a>\n",
		"<a class='btl' href='$brdUrl'>Brd</a>\n",
		"<a class='btl' href='$grpUrl'>Grp</a>\n",
		"<a class='btl' href='$delUrl'>Del</a>\n",
		"</td>\n",
		"</tr>\n";
}

print "</table>\n\n";

# Log action
$m->logAction(3, 'user', 'admin', $userId);

# Print footer
$m->printFooter();
