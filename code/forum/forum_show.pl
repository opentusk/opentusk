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

# TUSK begin Imports
use Forum::ForumKey;
use Data::Dumper;
use HSDB45::Course;
# TUSK end Imports

#------------------------------------------------------------------------------

# Init
my ($m, $cfg, $lng, $user) = MwfMain->new(@_);
my $userId = $user->{id};

# Check if access should be denied
$m->checkBan($userId) if $cfg->{banViewing};
$m->checkBlock();

# Get CGI parameters
my $jumpBoardId = $m->paramInt('bid');

# Print header
$m->printHeader();

# Print category visibility toggling script
print <<"EOSCRIPT"
<script type='text/javascript'>$m->{cdataStart}
	var mwfCategState = "";
	
	function mwfToggleCategState(categId) {
		var calledByScript = arguments[1];
		var categ = document.getElementById('cat' + categId);
		var toggle = document.getElementById('tgl' + categId);
		if (!categ || !toggle) return;
		if (categ.style.display != 'none') {
			categ.style.display = 'none';
			toggle.src = '$m->{stylePath}/nav_plus.png';
			toggle.title = '$lng->{frmCtgExpand}';
			toggle.alt = '+';
		}
		else {
			categ.style.display = '';
			toggle.src = '$m->{stylePath}/nav_minus.png';
			toggle.title = '$lng->{frmCtgCollap}';
			toggle.alt = '-';
		}
		if (!calledByScript) mwfSaveCategStates();
	}

	function mwfSaveCategStates() {
		mwfCategState = "";
		var tbodies = document.getElementsByTagName('tbody');
		for (var i=0; i < tbodies.length; i++) {
			if (tbodies[i].id.indexOf('cat') == 0) {
				var state = tbodies[i].style.display == 'none' ? 0 : 1;
				mwfCategState += tbodies[i].id.substr(3) + ":" + state + "-";
			}
		}
		var domain = "$cfg->{cookieDomain}" ? "domain=$cfg->{cookieDomain}" : "";
		var path = "$cfg->{cookiePath}" ? "path=$cfg->{cookiePath}" : "path=$m->{env}{scriptUrlPath}; ";
		document.cookie = "$cfg->{cookiePrefix}catstat=" + mwfCategState + "; "
			+ domain + path + "expires=Mon, 16-Mar-2020 00:00:00 GMT";
	}

	function mwfParseCategStates() {
		var match = document.cookie.match(new RegExp("$cfg->{cookiePrefix}catstat=([^;]+)"));
		if (match) mwfCategState = match[1];
	}
	mwfParseCategStates();
$m->{cdataEnd}</script>\n
EOSCRIPT
;

# Get categories
my $categs = $m->fetchAllHash("
	SELECT id, title FROM $cfg->{dbPrefix}categories ORDER BY pos, categorykey");

# TUSK begin boardfetch
# We have already compiled a list of viewable boards on login.
# Call the appropriate function from the ForumKey pkg to retrieve
# the hash, and remove the boardVisible check.

my $course_key = '';

if ($m->paramDefined('school') && $m->paramDefined('course_id')){
    $course_key = $m->paramInt('school') . '-'
	. $m->paramInt('course_id') . '-%-%';
}

my $boards = Forum::ForumKey::getBoardsHashnoHidden($m, $user, $course_key, $m->paramStr('start_date'), $m->paramStr('end_date'));

=pod --------------- DELETED BY TUSK ---------------
# Get boards
my $boards = $m->fetchAllHash("
	SELECT boards.*
	FROM $cfg->{dbPrefix}boards AS boards
		LEFT JOIN $cfg->{dbPrefix}boardHiddenFlags AS boardHiddenFlags
			ON boardHiddenFlags.userId = $userId
			AND boardHiddenFlags.boardId = boards.id
	WHERE boardHiddenFlags.boardId IS NULL
	ORDER BY boards.pos");
for my $board (@$boards) {
	$board->{visible} = $m->boardVisible($board);
	$board->{visible} = 2 if !$board->{visible} && $board->{list};
}
@$boards = grep($_->{visible}, @$boards);
      --------------- DELETED BY TUSK ---------------
=cut
# TUSK end

my %boards = ();
my $adminBoards = [];
my $boardIdsStr = "0";
my $jumpCategId = 0;
for my $board (@$boards) { 
	my $boardId = $board->{id};
	$boards{$boardId} = $board;
	push @$adminBoards, $board if $userId && $m->boardAdmin($userId, $boardId);
	# TUSK begin removed {visible} check because all boards in array should be visible.
	$boardIdsStr .= "," . $boardId;
	# TUSK end
	$jumpCategId = $board->{categoryId} if $boardId == $jumpBoardId;
}

# User button links
my @userLinks = ();
push @userLinks, { url => $m->url('user_posts_mark', act => 'read', time => $m->{now}, auth => 1), 
	txt => 'frmMarkRd', ico => 'markread' }
	if $userId;
push @userLinks, { url => $m->url('forum_overview', act => 'new'), 
	txt => 'comShowNew', ico => 'shownew' }
	if $userId;
push @userLinks, { url => $m->url('forum_overview', act => 'unread'), 
	txt => 'comShowUnr', ico => 'showunread' }
	if $userId;
push @userLinks, { url => $m->url('forum_overview', act => 'todo'), 
	txt => 'comShowTdo', ico => 'todo' }
	if $userId;
push @userLinks, { url => $m->url('user_list'), txt => 'frmUsers', ico => 'user' }
	if $cfg->{userList} == 1 || $cfg->{userList} == 2 && $userId;
push @userLinks, { url => $m->url('attach_list'), txt => 'frmAttach', ico => 'attach' }
	if $cfg->{attachList} == 1 || $cfg->{attachList} == 2 && $userId 
	|| $cfg->{attachList} == 3 && $user->{admin};
push @userLinks, { url => $m->url('forum_feeds'), txt => 'comFeeds', ico => 'feed' } 
	if $cfg->{rssLink};
push @userLinks, { url => $m->url('forum_info'), txt => 'frmInfo', ico => 'info' };

# Admin button links
my @adminLinks = ();
if ($user->{admin}) {
	my $reportNum = $m->fetchArray("
		SELECT COUNT(*) FROM $cfg->{dbPrefix}postReports");
	push @adminLinks, { url => $m->url('forum_options'), txt => "Options", ico => 'option' };
	push @adminLinks, { url => $m->url('user_admin'), txt => "Users", ico => 'user' };
	push @adminLinks, { url => $m->url('group_admin'), txt => "Groups", ico => 'group' };
	push @adminLinks, { url => $m->url('board_admin'), txt => "Boards", ico => 'board' };
	push @adminLinks, { url => $m->url('categ_admin'), txt => "Categories", ico => 'category' };
	push @adminLinks, { url => $m->url('forum_purge'), txt => "Purge", ico => 'delete' };
	push @adminLinks, { url => $m->url('cron_admin'), txt => "Cronjobs", ico => 'cron' };
	push @adminLinks, { url => $m->url('report_list'), 
		txt => "<em class='eln'>Reports ($reportNum)</em>", ico => 'report' } 
		if $reportNum;
}
elsif (@$adminBoards) {
	my $adminBoardIdsStr = join(",", map($_->{id}, @$adminBoards));
	my $reportNum = $m->fetchArray("
		SELECT COUNT(*) 
		FROM $cfg->{dbPrefix}postReports AS postReports
			INNER JOIN $cfg->{dbPrefix}posts AS posts
				ON posts.id = postReports.postId
		WHERE posts.boardId IN ($adminBoardIdsStr)");
	if ($reportNum) {
		push @adminLinks, { url => $m->url('report_list'), 
				txt => "<em class='eln'>$lng->{brdAdmRep} ($reportNum)</em>", ico => 'report' };
	}
}

# Print page bar
$m->printPageBar(mainTitle => '', userLinks => \@userLinks, 
	adminLinks => \@adminLinks);

# Print notifications
if ($userId) {
	my $notes = $m->fetchAllHash("
		SELECT id, body, sendTime
		FROM $cfg->{dbPrefix}notes
		WHERE userId = $userId
		ORDER BY id DESC");
	if (@$notes) {
		print
			"<div class='frm ntf'>\n",
			"<div class='hcl'>\n",
			"$lng->{frmNotTtl}\n",
			"</div>\n",
			"<div class='ccl not'>\n",
			"<table class='tiv'>\n";
		for my $note (@$notes) {
			$note->{body} =~ s!$m->{ext}\?!$m->{ext}?sid=$m->{sessionId};! if $m->{sessionId};
			my $timeStr = $m->formatTime($note->{sendTime}, $user->{timezone});
			print "<tr><td class='shr'>$timeStr: </td><td>$note->{body}</td></tr>\n";
		}
		my $url = $m->url('note_delete', auth => 1);
		print
			"</table>\n",
			"<form action='note_delete$m->{ext}' method='post'>\n",
			$m->submitButton('frmNotDelB', 'remove'),
			$m->stdFormFields(),
			"</form>\n",
			"</div>\n",
			"</div>\n\n";
	}
}

# New posts/read posts statistics
if ($userId) {
	if (!$cfg->{skipNewComp}) {
		# Get new post numbers
		my $approvedStr = $user->{admin} ? "" : "AND approved = 1";
		my $stats = $m->fetchAllArray("
			SELECT boardId, COUNT(*) AS newNum
			FROM $cfg->{dbPrefix}posts 
			WHERE boardId IN ($boardIdsStr)
				AND postTime > $user->{prevOnTime}
				$approvedStr
			GROUP BY boardId");
		$boards{$_->[0]}{newNum} = $_->[1] for @$stats;
	}

	# Check whether there's at least one unread topic
	my $lowestUnreadTime = $m->max($user->{fakeReadTime}, $m->{now} - $cfg->{maxUnreadDays} * 86400);
	if ($cfg->{skipUnreadComp}) { 
		for my $board (@$boards) { $board->{hasUnread} = 1 }
	}
	else {
		my $stats = $m->fetchAllArray("
			SELECT boards.id, COUNT(topics.id) > 0 AS hasUnread
			FROM $cfg->{dbPrefix}boards AS boards
				INNER JOIN $cfg->{dbPrefix}topics AS topics
					ON topics.boardId = boards.id
				LEFT JOIN $cfg->{dbPrefix}topicReadTimes AS topicReadTimes
					ON topicReadTimes.userId = $userId
					AND topicReadTimes.topicId = topics.id 
			WHERE boards.id IN ($boardIdsStr)
				AND topics.lastPostTime > $lowestUnreadTime
				AND (topics.lastPostTime > topicReadTimes.lastReadTime 
					OR topicReadTimes.topicId IS NULL)
			GROUP BY boards.id");
		$boards{$_->[0]}{hasUnread} = $_->[1] for @$stats;
	}
}

# Print table
print "<table class='tbl'>\n";

# Print categories/boards
my $boardsPrinted = 0;
for my $categ (@$categs) {
	my $categId = $categ->{id};
	my $categPrinted = 0;

	for my $board (@$boards) {
		my $boardId = $board->{id};

		# Skip boards not in current category
		next if $board->{categoryId} != $categId;

		# Format output
		my $lastPostTimeStr = $board->{lastPostTime} > 0 
			? $m->formatTime($board->{lastPostTime}, $user->{timezone}) : " - ";

		# Format new number string
		my $url = $m->url('forum_overview', act => 'new', bid => $boardId);
		my $newNumStr = $board->{newNum} ? " <a href='$url'>($board->{newNum} $lng->{frmNew})</a>" : "";

		# Determine variable board icon attributes
		my $imgSrc; 
		my $imgTitle = "";
		my $imgAlt = "";
		if (!$userId) { $imgSrc = "board_ou" }
		else {
			if ($board->{newNum} && $board->{hasUnread}) { 
				$imgSrc = "board_nu"; $imgTitle = $lng->{comNewUnrdTT}; $imgAlt = $lng->{comNewUnrd};
			}
			elsif ($board->{newNum}) { 
				$imgSrc = "board_nr"; $imgTitle = $lng->{comNewReadTT}; $imgAlt = $lng->{comNewRead};
			}
			elsif ($board->{hasUnread}) { 
				$imgSrc = "board_ou"; $imgTitle = $lng->{comOldUnrdTT}; $imgAlt = $lng->{comOldUnrd};
			}
			else { 
				$imgSrc = "board_or"; $imgTitle = $lng->{comOldReadTT}; $imgAlt = $lng->{comOldRead};
			}
		}
		my $imgAttr = "src='$m->{stylePath}/$imgSrc.png' title='$imgTitle' alt='$imgAlt'";

		# Print category header, if not done already for this category
		if (!$categPrinted) {
		    my $categTitle = $categ->{title};
		    if ($m->paramDefined('school') && $m->paramDefined('course_id')){
			my $course = HSDB45::Course->new(_school => $m->paramInt('school'))->lookup_key($m->paramInt('course_id'));
			$categTitle = $course->title() . " <a style=\"font-weight:normal\" href=\"/view/course/" . $m->paramInt('school') . "/" . $m->paramInt('course_id') . "\">[Course Homepage]</a>";
							 
		    }
			print
				"<tbody>\n",
				"<tr class='hrw'>\n",
				"<th class='icl'>\n",
				"<a id='cid$categId'></a>\n",
				"<img class='ico' id='tgl$categId' src='$m->{stylePath}/nav_minus.png'",
				" onclick='mwfToggleCategState($categId)' title='$lng->{frmCtgCollap}' alt='-'/>\n",
				"</th>\n",
				"<th>$categTitle</th>\n",
				"<th class='shr'>$lng->{frmPosts}</th>\n",
				"<th class='shr'>$lng->{frmLastPost}</th>\n",
				"</tr>\n",
				"</tbody>\n\n",
				"<tbody id='cat$categId'>\n";

			$categPrinted = 1;
		}

		# Print board
		# TUSK begin removed if/else, retrieved boards should always be printed

		$url = $m->url('board_show', bid => $boardId);
		print 
		    "<tr class='crw'>\n",
		    "<td class='icl'><img class='ico' $imgAttr/></td>\n",
		    "<td><a id='bid$boardId' href='$url'>$board->{title}</a>",
		    $user->{boardDescs} && $board->{shortDesc} 
		? "<div class='bds'>$board->{shortDesc}</div>" : "",
		"</td>\n",
		"<td class='shr'>$board->{postNum} $newNumStr</td>\n",
		"<td class='shr'>$lastPostTimeStr</td>\n",
		"</tr>\n";
		
		# TUSK end

		# At least one board printed
		$boardsPrinted++;
	}

	print "</tbody>\n\n" if $categPrinted;
}

# Print notification that there were no visible boards
print "<tr class='crw'><td>$lng->{frmNoBoards}</td></tr>\n" if !$boardsPrinted;

# End table
print "</table>\n\n";

# Print category visibility toggling script
$cfg->{collapseCategs} ||= 0;
print <<"EOSCRIPT"
<script type='text/javascript'>$m->{cdataStart}
	function mwfInitCategStates() {
		var tbodies = document.getElementsByTagName('tbody');
		for (var i=0; i < tbodies.length; i++) {
			var tbody = tbodies[i];
			var categId = tbody.id.substr(3);
			if (tbody.id.indexOf('cat') == 0) {
				var match = mwfCategState.match(new RegExp(categId + ":(1|0)"));
				var collapsed = 0;
				if (match) collapsed = match[1] == 0;
				else if ($cfg->{collapseCategs} && tbody.id != 'cat$cfg->{collapseCategs}'
					&& tbody.id != 'cat$jumpCategId')
					collapsed = 1;
				if (collapsed) mwfToggleCategState(categId, 1);
			}
		}
	}
	mwfInitCategStates();
$m->{cdataEnd}</script>\n
EOSCRIPT
;

# Users online in the last five minutes
my $onlUserStr = "";
if ($cfg->{showOnlUsers} && ($userId || $cfg->{showOnlUsers} == 2)) {
	my $privacyStr = $user->{admin} ? "" : "AND privacy = 0";
	my $users = $m->fetchAllArray("
		SELECT id, userName
		FROM $cfg->{dbPrefix}users
		WHERE $m->{now} - lastOnTime < 300
			AND lastOnTime != regTime
			$privacyStr
		ORDER BY lastOnTime DESC
		LIMIT 50");
	for (@$users) { 
		my $url = $m->url('user_info', uid => $_->[0]);
		$_ = "<a href='$url'>$_->[1]</a>";
	}
	$onlUserStr = join(",\n", @$users) || " ";
}

# Newest users
my $newUserStr = "";
if ($cfg->{showNewUsers} && ($userId || $cfg->{showNewUsers} == 2)) {
	my $users = $m->fetchAllArray("
		SELECT id, userName
		FROM $cfg->{dbPrefix}users
		WHERE $m->{now} - regTime < 86400 * 3
			AND privacy = 0
		ORDER BY regTime DESC
		LIMIT 10");
	for (@$users) {
		my $url = $m->url('user_info', uid => $_->[0]);
		$_ = "<a href='$url'>$_->[1]</a>";
	}
	$newUserStr = join(",\n", @$users) || undef;
}

# Birthday boys/girls
my $bdayUserStr = "";
if ($cfg->{showBdayUsers} && ($userId || $cfg->{showBdayUsers} == 2)) {
	my (undef, undef, undef, undef, undef, $year) = localtime(time);
	$year += 1900;
	my $day = $m->formatTime($m->{now}, $user->{timezone}, "%m-%d");
	my $users = $m->fetchAllHash("
		SELECT id, userName, birthyear, $year - birthyear AS age
		FROM $cfg->{dbPrefix}users
		WHERE birthday = '$day'
		LIMIT 50");
	for (@$users) {
		my $url = $m->url('user_info', uid => $_->{id});
		$_->{userName} .= " ($_->{age})" if $_->{birthyear};
		$_ = "<a href='$url'>$_->{userName}</a>";
	}
	$bdayUserStr = join(",\n", @$users) || undef;
}

# Blogs with new topics
my $blogUserStr = "";
if ($cfg->{blogs} && $cfg->{showNewBlgTpcs} && $userId) {
	my $users = $m->fetchAllArray("
		SELECT users.id, users.userName, COUNT(posts.id)
		FROM $cfg->{dbPrefix}topics AS topics
			INNER JOIN $cfg->{dbPrefix}posts AS posts
				ON posts.topicId = topics.id
			INNER JOIN $cfg->{dbPrefix}users AS users
				ON users.id = -topics.boardId
		WHERE topics.boardId < 0
			AND posts.postTime > $user->{prevOnTime}
		GROUP BY topics.boardId, users.id, users.userName
		LIMIT 50");
	for (@$users) { 
		my $url = $m->url('blog_show', bid => -$_->[0]);
		$_ = "<a href='$url'>$_->[1] ($_->[2])</a>" 
	}
	$blogUserStr = join(",\n", @$users) || undef;
}

print
	"<div class='frm sta'>\n",
	"<div class='hcl'>\n",
	"$lng->{frmStats}\n",
	"</div>\n",
	"<div class='ccl'>\n"
	if $onlUserStr || $newUserStr || $bdayUserStr || $blogUserStr;

print 
	"<div>\n",
	"<span title='$lng->{frmOnlUsrTT}'>$lng->{frmOnlUsr}:\n",
	"$onlUserStr\n",
	"</span>\n",
	"</div>\n"
	if $onlUserStr;

print
	"<div>\n",
	"<span title='$lng->{frmNewUsrTT}'>$lng->{frmNewUsr}:\n",
	"$newUserStr\n",
	"</span>\n",
	"</div>\n"
	if $newUserStr;

print
	"<div>\n",
	"<span title='$lng->{frmBdayUsrTT}'>$lng->{frmBdayUsr}:\n",
	"$bdayUserStr\n",
	"</span>\n",
	"</div>\n"
	if $bdayUserStr;

print
	"<div>\n",
	"<span title='$lng->{frmBlgPstTT}'>$lng->{frmBlgPst}:\n",
	"$blogUserStr\n",
	"</span>\n",
	"</div>\n"
	if $blogUserStr;

print 
	"</div>\n</div>\n\n"
	if $onlUserStr || $newUserStr || $bdayUserStr || $blogUserStr;

# Log action
$m->logAction(2, 'forum', 'show', $userId);

# Print footer
$m->printFooter();
