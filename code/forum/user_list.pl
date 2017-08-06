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

# Print header
$m->printHeader();

# Check if user is allowed to see list
$cfg->{userList} or $m->userError($lng->{errFeatDisbl});
$userId or $m->regError() if $cfg->{userList} == 2;

# Get CGI parameters
my $page = $m->paramInt('pg') || 1;
my $search = $m->paramStr('search') || "";
my $field = $m->paramStrId('field') || 'regTime';
my $sort = $m->paramStrId('sort') || 'field';
my $order = $m->paramStrId('order') || 'desc';
my $hideEmpty = $m->paramBool('hide');

# Define values and names for selectable fields
my %fields = (
	userName => $lng->{uifProfUName},
	realName => $lng->{uifProfRName},
	homepage => $lng->{uifProfPage},
	occupation => $lng->{uifProfOccup},
	hobbies => $lng->{uifProfHobby},
	location => $lng->{uifProfLocat},
	icq => $lng->{uifProfIcq},
	avatar => $lng->{uifProfAvat},
	birthday => $lng->{uifProfBdate},
	regTime => $lng->{uifStatRegTm},
	postNum => $lng->{uifStatPNum},
);
$fields{extra1} = $cfg->{extra1} if $cfg->{extra1} && $cfg->{showExtra1};
$fields{extra2} = $cfg->{extra2} if $cfg->{extra2} && $cfg->{showExtra2};
$fields{extra3} = $cfg->{extra3} if $cfg->{extra3} && $cfg->{showExtra3};

# Enforce restrictions
$field = 'regTime' if !$fields{$field};
$order = 'desc' if $order !~ /^asc|desc$/;

# Preserve parameters in links
my @params = 
	(search => $search, field => $field, sort => $sort, order => $order, hide => $hideEmpty);

# Search for username
$search = $m->escHtml($search);
my $searchEsc = $m->dbEscLike($search);
my $like = $m->{pgsql} ? 'ILIKE' : 'LIKE';
my $searchStr = $search ? "AND $field $like " . $m->dbQuote("%$searchEsc%") : "";
my $hideEmptyStr = $hideEmpty ? "AND $field != ''" : "";

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

# Determine page buttons
my $usersPP = 25;
my $pageNum = int(@$users / $usersPP) + (@$users % $usersPP != 0);
my @pageLinks = ();
if ($pageNum > 1) {
	my $prevPage = $page - 1;
	my $nextPage = $page + 1;
	my $maxPageNum = $m->min($pageNum, 8);
	push @pageLinks, { url => $m->url('user_list', pg => $_, @params), 
		txt => $_, dsb => $_ == $page }
		for 1 .. $maxPageNum;
	push @pageLinks, { txt => "..." }, { 
		url => $m->url('user_list', pg => $pageNum, @params), 
		txt => $pageNum, dsb => $pageNum == $page }
		if $maxPageNum + 1 < $pageNum;
	push @pageLinks, { url => $m->url('user_list', pg => $prevPage, @params), 
		txt => 'comPgPrev', dsb => $page == 1 };
	push @pageLinks, { url => $m->url('user_list', pg => $nextPage, @params), 
		txt => 'comPgNext', dsb => $page == $pageNum };
}

# Get users on page
my @pageUserIds = @$users[($page - 1) * $usersPP .. $m->min($page * $usersPP, scalar @$users) - 1];
my $pageUserIdsStr = join(",", map($_->[0], @pageUserIds)) || "0";
$users = $m->fetchAllHash("
	SELECT id, userName, email, birthyear, $field 
	FROM $cfg->{dbPrefix}users
	WHERE id IN ($pageUserIdsStr)
	ORDER BY $orderStr");

# Print page bar
my @navLinks = ({ url => $m->url('forum_show'), txt => 'comUp', ico => 'up' });
$m->printPageBar(mainTitle => $lng->{uliTitle}, navLinks => \@navLinks, pageLinks => \@pageLinks);

# Determine listbox selections
my %state = (
	$sort => "selected='selected'",
	$order => "selected='selected'",
	"field$field" => "selected='selected'",
	hideEmpty => $hideEmpty ? "checked='checked'" : "",
);

# Print user list form
print
	"<form action='user_list$m->{ext}' method='get'>\n",
	"<div class='frm'>\n",
	"<div class='hcl'>\n",
	"<span class='htt'>$lng->{uliLfmTtl}</span>\n",
	"</div>\n",
	"<div class='ccl'>\n",
	"$lng->{uliLfmSearch}\n",
	"<input type='text' name='search' style='width: 100px' value='$search'/>\n",
	"$lng->{uliLfmField}\n",
	"<select name='field' size='1'>\n";

print "<option value='$_' $state{\"field$_\"}>$fields{$_}</option>\n"
	for sort({$fields{$a} cmp $fields{$b}} keys(%fields));

print
	"</select>\n",
	"$lng->{uliLfmSort}\n",
	"<select name='sort' size='1'>\n",
	"<option value='field' $state{field}>$lng->{uliLfmSrtFld}</option>\n",
	"<option value='userName' $state{userName}>$lng->{uliLfmSrtNam}</option>\n",
	"<option value='id' $state{id}>$lng->{uliLfmSrtUid}</option>\n",
	"</select>\n",
	"$lng->{uliLfmOrder}\n",
	"<select name='order' size='1'>\n",
	"<option value='desc' $state{desc}>$lng->{uliLfmOrdDsc}</option>\n",
	"<option value='asc' $state{asc}>$lng->{uliLfmOrdAsc}</option>\n",
	"</select>\n",
	"<input type='checkbox' name='hide' $state{hideEmpty}/>$lng->{uliLfmHide}\n",
	"<input type='submit' value='$lng->{uliLfmListB}'/>\n",
	$m->{sessionId} ? "<input type='hidden' name='sid' value='$m->{sessionId}'/>\n" : "",
	"</div>\n",
	"</div>\n",
	"</form>\n\n";

# Print user list header
print 
	"<table class='tbl'>\n",
	"<tr class='hrw'>\n",
	"<th class='shr'>$lng->{uliLstName}</th>\n",
	"<th>$fields{$field}</th>\n",
	"</tr>\n";

# Print user list
for my $listUser (@$users) {
	# Get string for selectable field
	my $fieldStr = "";
	$fieldStr = $listUser->{$field};
	if ($field eq 'avatar' && $fieldStr) { 
		$fieldStr = "<img src='$cfg->{attachUrlPath}/avatars/$fieldStr' alt=''/>" 
	}
	elsif ($field eq 'birthday' && $listUser->{birthyear}) {
		$fieldStr = "$listUser->{birthyear}-$fieldStr";
	}
	elsif ($field eq 'postNum') { $fieldStr .= " " . $m->formatUserRank($fieldStr) }
	elsif ($field =~ /Time$/) { $fieldStr = $m->formatTime($fieldStr, $user->{timezone}) }
	elsif ($fieldStr =~ /^https?:/) { $fieldStr = "<a href='$fieldStr'>$fieldStr</a>" }

	my $url = $m->url('user_info', uid => $listUser->{id});
	
	print
		"<tr class='crw'>\n",
		"<td><a href='$url'>$listUser->{userName}</a></td>\n",
		"<td>$fieldStr</td>\n",
		"</tr>\n";
}

print "</table>\n\n";

# Log action
$m->logAction(3, 'user', 'list', $userId);

# Print footer
$m->printFooter();
