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

# TUSK begin
use Data::Dumper;
# TUSK end

#------------------------------------------------------------------------------

# Init
my ($m, $cfg, $lng, $user) = MwfMain->new(@_);
my $userId = $user->{id};

# Check if access should be denied
$m->checkBan($userId) if $cfg->{banViewing};
$m->checkBlock();

# Get CGI parameters
my $boardId = $m->paramStr('bid');  # int() later
my $jumpTopicId = $m->paramInt('tid');
my $page = $m->paramInt('pg') || 1;

# TUSK begin adding different sort methods
my $sort = $m->paramStr('sort');
# TUSK end

# Redirect if board ID is special
$m->redirect('forum_show', tgt => $boardId) if $boardId =~ /^cid/;
$m->redirect('forum_show') if $boardId eq '0';
$boardId = int($boardId || 0);
$m->redirect('blog_show', bid => $boardId, tgt => "tid$jumpTopicId") if $boardId <0 && $jumpTopicId;
$m->redirect('blog_show', bid => $boardId) if $boardId < 0;

# Get boardId and stickyness from topic
my $jumpTopicSticky = 0;
($boardId, $jumpTopicSticky) = $m->fetchArray("
	SELECT boardId, sticky FROM $cfg->{dbPrefix}topics WHERE id = $jumpTopicId")
	if $jumpTopicId;
$boardId or $m->paramError($lng->{errBrdIdMiss});

# Get board/category
my $board = $m->fetchHash("
	SELECT boards.*,
		categories.id AS categId, categories.title AS categTitle
	FROM $cfg->{dbPrefix}boards AS boards
		INNER JOIN $cfg->{dbPrefix}categories AS categories
			ON categories.id = boards.categoryId
	WHERE boards.id = $boardId");
$board or $m->entryError($lng->{errBrdNotFnd});

# Check if user can see and write to board
my $boardAdmin = $user->{admin} || $m->boardAdmin($userId, $board->{id});
$boardAdmin || $m->boardVisible($board) or $m->entryError($lng->{errBrdNotFnd});
my $boardWritable = $boardAdmin || $m->boardWritable($board);

# Print header
$m->printHeader($board->{title}, $board);

my $course_url = '';

if ($board->{categTitle} eq 'Courses' && $board->{boardkey} =~ /(\d+)-(\d+)-/){
    my ($school_id, $course_id) = ($1, $2);
    $course_url = $school_id . '/' . $course_id;
}

# Set current page to a requested topic's page	
my $topicsPP = $m->min($user->{topicsPP}, $cfg->{maxTopicsPP}) || $cfg->{maxTopicsPP};

if ($jumpTopicSticky) { $page = 1 }
elsif ($jumpTopicId) {
	my $jumpTopicTime = $m->fetchArray("
		SELECT lastPostTime FROM $cfg->{dbPrefix}topics WHERE id = $jumpTopicId");
	$page = $m->fetchArray("
		SELECT COUNT(*) / $topicsPP + 1
		FROM $cfg->{dbPrefix}topics
		WHERE boardId = $boardId
			AND (sticky = 1 OR lastPostTime > $jumpTopicTime)")
		if $jumpTopicTime;
	$page = int($page);
}

# Page links
my @pageLinks = ();
my $topicNum = $m->fetchArray("
	SELECT COUNT(*) FROM $cfg->{dbPrefix}topics WHERE boardId = $boardId");
my $pageNum = int($topicNum / $topicsPP) + ($topicNum % $topicsPP != 0);
if ($pageNum > 1) {
	my $prevPage = $page - 1;
	my $nextPage = $page + 1;
	my $maxPageNum = $m->min($pageNum, 8);
	push @pageLinks, { url => $m->url('board_show', bid => $boardId, pg => $_), 
		txt => $_, dsb => $_ == $page }
		for 1 .. $maxPageNum;
	push @pageLinks, { txt => "..." }, { 
		url => $m->url('board_show', bid => $boardId, pg => $pageNum), 
		txt => $pageNum, dsb => $pageNum == $page }
		if $maxPageNum + 1 < $pageNum;
	push @pageLinks, { url =>$m->url('board_show', bid => $boardId, pg => $prevPage), 
		txt => 'comPgPrev', dsb => $page == 1 };
	push @pageLinks, { url => $m->url('board_show', bid => $boardId, pg => $nextPage), 
		txt => 'comPgNext', dsb => $page == $pageNum };
}

# Navigation button links
my @navLinks = ();
push @navLinks, { url => $m->url('prevnext', bid => $boardId, dir => 'prev'), 
	txt => 'brdPrev', ico => 'prev' };
push @navLinks, { url => $m->url('prevnext', bid => $boardId, dir => 'next'), 
	txt => 'brdNext', ico => 'next' };
push @navLinks, { url => $m->url('forum_show', bid => $boardId, tgt => "bid$boardId"), 
	txt =>'comUp', ico => 'up' };

# User button links
my @userLinks = ();
push @userLinks, { url => $m->url('topic_add', bid => $boardId), 
	txt => 'brdNewTpc', ico => 'write' } 
	if $boardWritable;
push @userLinks, { url => $m->url('forum_overview', act => 'new', bid => $boardId), 
	txt => 'comShowNew', ico => 'shownew' } 
	if $userId;
push @userLinks, { url => $m->url('forum_overview', act => 'unread', bid => $boardId), 
	txt => 'comShowUnr', ico => 'showunread' }
	if $userId;
push @userLinks, { url => $m->url('forum_overview', act => 'todo', bid => $boardId), 
	txt => 'comShowTdo', ico => 'todo' } 
	if $userId;
push @userLinks, { url => $m->url('board_info', bid => $boardId), 
	txt => 'brdInfo', ico => 'info' };

# Admin button links
my @adminLinks = ();
if ($boardAdmin) {
	my $reportNum = $m->fetchArray("
		SELECT COUNT(*)
		FROM $cfg->{dbPrefix}postReports AS postReports
			INNER JOIN $cfg->{dbPrefix}posts AS posts
				ON posts.id = postReports.postId
			INNER JOIN $cfg->{dbPrefix}boards AS boards
				ON boards.id = posts.boardId
		WHERE boards.id = $boardId");
	if ($user->{admin}) {
		push @adminLinks, { url => $m->url('board_options', bid => $boardId, ori => 1), 
			txt => 'Options', ico => 'option' };
		push @adminLinks, { url => $m->url('board_members', bid => $boardId), 
			txt => 'Members', ico => 'user' };
		push @adminLinks, { url => $m->url('board_groups', bid => $boardId, ori => 1), 
			txt => 'Groups', ico => 'group' };
		push @adminLinks, { url => $m->url('user_confirm', bid => $boardId, script => 'board_delete', 
			name => $board->{title}), txt => 'Delete', ico => 'delete' };
		push @adminLinks, { url => $m->url('report_list', bid => $boardId), 
			txt => "<em class='eln'>Reports ($reportNum)</em>", ico => 'report' } 
			if $reportNum;
	}
	else {
		push @adminLinks, { url => $m->url('board_members', bid => $boardId), 
			txt => 'brdAdmMbr', ico => 'user' };
		push @adminLinks, { url => $m->url('board_groups', bid => $boardId, ori => 1), 
			txt => 'brdAdmGrp', ico => 'group' };
		push @adminLinks, { url => $m->url('report_list', bid => $boardId), 
			txt => "<em class='eln'>$lng->{brdAdmRep} ($reportNum)</em>", ico => 'report' }
			if $reportNum;
	}
}

# Print page bar
my $url = $m->url('forum_show', tgt => "cid" . $board->{categoryId});
my $categStr = "<a href='$url'>$board->{categTitle}</a> / ";
my $pageStr = $page > 1 ? " ($lng->{comPgTtl} $page)" : "";
# TUSK bolded the board title on the board_show page
$m->printPageBar(mainTitle => $lng->{brdTitle}, subTitle => $categStr . "<b>" .$board->{title} . "</b>" . $pageStr . (($course_url) ? " <a href=\"/view/course/" . $course_url . "\">[Course Homepage]</a>" : ""), 
	navLinks => \@navLinks, pageLinks => \@pageLinks, userLinks => \@userLinks, 
	adminLinks => \@adminLinks);

# Get topics
my $offset = ($page - 1) * $topicsPP;
my $limitStr = $m->{mysql} ? "LIMIT $offset, $topicsPP" : "LIMIT $topicsPP OFFSET $offset";
my $stickyStr = $cfg->{skipStickySort} ? "" : "sticky DESC,";

# TUSK begin 
# allowing different sort orders
my ($topicurl, $viewsurl, $posterurl, $postsurl, $lastposturl) = ("topic", "views", "poster", "posts", "lastpost");
if ($sort eq "topic") {
    $sort = "subject ASC, lastPostTime DESC";
    $topicurl = "topicr";
}
elsif ($sort eq "topicr") {
    $sort = "subject DESC, lastPostTime DESC";
}
elsif ($sort eq "views") {
    $sort = "hitNum DESC, lastPostTime DESC";
    $viewsurl = "viewsr";
}
elsif ($sort eq "viewsr") {
    $sort = "hitNum ASC, lastPostTime DESC";
}
elsif ($sort eq "posts") {
    $sort = "postNum DESC, lastPostTime DESC";
    $postsurl = "postsr";
}
elsif ($sort eq "postsr") {
    $sort = "postNum ASC, lastPostTime DESC";
}
elsif ($sort eq "poster") {
    $sort = "users.realName ASC, topics.lastPostTime DESC";
    $posterurl = "posterr";
}
elsif ($sort eq "posterr") {
    $sort = "users.realName DESC, topics.lastPostTime DESC";
}
elsif ($sort eq "lastpostr") {
    $sort = "lastPostTime ASC";
}
else {
    $sort = "lastPostTime DESC";
    $lastposturl = "lastpostr";
}

my $topics;

if ($sort eq "users.realName ASC, topics.lastPostTime DESC" || $sort eq "users.realName DESC, topics.lastPostTime DESC") {
    $topics = $m->fetchAllHash("
        SELECT topics.id, topics.subject, topics.tag, topics.pollId, topics.locked, topics.sticky, topics.postNum, topics.lastPostTime, topics.hitNum
	FROM $cfg->{dbPrefix}topics as topics, $cfg->{dbPrefix}users as users, $cfg->{dbPrefix}posts as posts
	WHERE topics.boardId = $boardId
              AND topics.basePostId = posts.id
              AND (posts.userId = users.id OR posts.userId = '-1')
        GROUP BY topics.subject
	ORDER BY $stickyStr $sort
	$limitStr");
}
else {
    $topics = $m->fetchAllHash("
	SELECT id, subject, tag, pollId, locked, sticky, postNum, lastPostTime, hitNum
	FROM $cfg->{dbPrefix}topics
	WHERE boardId = $boardId
	ORDER BY $stickyStr $sort
	$limitStr");
}
# TUSK end


# Put topics in by-id lookup table and concat their IDs for the next query
my %topics = map(($_->{id} => $_), @$topics);
my $topicIdsStr = join(",", map($_->{id}, @$topics)) || "0";

# Get base post data for topics on page
my $posts = $m->fetchAllArray("
	SELECT posts.topicId, posts.userId, posts.approved, posts.userNameBak, users.realName 
	FROM $cfg->{dbPrefix}posts as posts, $cfg->{dbPrefix}users as users
	WHERE topicId IN ($topicIdsStr)AND parentId = 0 AND (posts.userNameBak = 'anonymous' OR posts.userNameBak = users.userName) GROUP BY topicId");

for (@$posts) {
	$topics{$_->[0]}{userId} = $_->[1];
	$topics{$_->[0]}{approved} = $_->[2];
	$topics{$_->[0]}{userNameBak} = $_->[3];
	$topics{$_->[0]}{realName} = $_->[4];
}

@$topics = grep($_->{approved} || $boardAdmin || $userId && $userId == $_->{userId}, @$topics);
$topicIdsStr = join(",", map($_->{id}, @$topics)) || "0";


# TUSK begin
# adding users.realName to the fetched values
# if you use posts.userId, it refers to the last poster's (last person to reply)  name
# posts.userNameBak refers to the original poster's name.

# Get new post and unread numbers for topics on page
my $lowestUnreadTime = $m->max($user->{fakeReadTime}, $m->{now} - $cfg->{maxUnreadDays} * 86400);
if ($userId) {
	my $stats = $m->fetchAllArray("
		SELECT topics.id, 
			SUM(CASE WHEN posts.postTime > $user->{prevOnTime} THEN 1 ELSE 0 END) AS newNum,
			SUM(CASE WHEN topics.lastPostTime > $lowestUnreadTime
				AND (topics.lastPostTime > topicReadTimes.lastReadTime
				OR topicReadTimes.topicId IS NULL) THEN 1 ELSE 0 END) AS unreadNum 
		FROM $cfg->{dbPrefix}topics AS topics
			INNER JOIN $cfg->{dbPrefix}posts AS posts
				ON posts.topicId = topics.id
			LEFT JOIN $cfg->{dbPrefix}topicReadTimes AS topicReadTimes
				ON topicReadTimes.userId = $userId
				AND topicReadTimes.topicId = topics.id 
		WHERE topics.id IN ($topicIdsStr)
			AND posts.approved = 1
		GROUP BY topics.id");
	for (@$stats) {
		$topics{$_->[0]}{newNum} = $_->[1];
		$topics{$_->[0]}{unreadNum} = $_->[2];
	}
}
# TUSK end

# Print long description
print
	"<div class='frm dsc'>\n",
	"<div class='ccl'>\n",
	"$board->{longDesc}\n",
	"</div>\n",
	"</div>\n\n"
	if $cfg->{boardPageDesc} && $board->{longDesc} && $user->{boardDescs};

# TUSK begin modifying the topic display page, adding different sort orders
# Print table header
print 
	"<table class='tbl'>\n",
	"<tr class='hrw'>\n",
	"<th><a href='" . $m->url('board_show', bid => $boardId, sort=> $topicurl) . "' class='table_heading'>$lng->{brdTopic}</a></th>\n",
        "<th class='sshr'><a href='" . $m->url('board_show', bid => $boardId, sort=> $viewsurl) . "' class='table_heading'>$lng->{brdPostViews}</a></th>\n",
             
	"<th class='shr'><a href='" . $m->url('board_show', bid => $boardId, sort=> $posterurl) . "' class='table_heading'>$lng->{brdPoster}</a></th>\n",
	"<th class='sshr'><a href='" . $m->url('board_show', bid => $boardId, sort=> $postsurl) . "' class='table_heading'>$lng->{brdPosts}</a></th>\n",
	"<th class='shr'><a href='" . $m->url('board_show', bid => $boardId, sort=> $lastposturl) . "' class='table_heading'>$lng->{brdLastPost}</a></th>\n",
	"</tr>\n";
# TUSK end

# Print topics
for my $topic (@$topics) {
	# Use #fp target if there're new or unread posts, but not if all of them are new or unread
	my $fp = $topic->{unreadNum} || $topic->{newNum}
		&& !($topic->{unreadNum} == $topic->{postNum} || $topic->{newNum} == $topic->{postNum})
		? "fp" : "";
		
	# Format output
	my $lastPostTimeStr = $m->formatTime($topic->{lastPostTime}, $user->{timezone});
# TUSK begin
# adding real name to userNameStr
	my $userNameStr;
	if ($topic->{userNameBak} eq "anonymous") {
	    $userNameStr = "anonymous";
	} else {
	    $userNameStr = $topic->{realName} || $topic->{userName} || $topic->{userNameBak} || " - ";
	}
# TUSK end
	my $url = $m->url('user_info', uid => $topic->{userId});
	$userNameStr = "<a href='$url'>$userNameStr</a>" if ($userNameStr ne "anonymous" && $userNameStr ne " - ");
	my $subject = $topic->{sticky} ? "<span class='stk'>$topic->{subject}</span>" : $topic->{subject};
	$url = $m->url('forum_overview', act => 'new', tid => $topic->{id});
	my $newNumStr = $topic->{newNum} ? "<a href='$url'>($topic->{newNum} $lng->{brdNew})</a>" : "";
	my $lockImg = $topic->{locked} ? " <img class='ico' src='$m->{stylePath}/topic_l.png'"
		. " title='$lng->{brdLockedTT}' alt='$lng->{brdLocked}'/>" : "";
	my $invisImg = !$topic->{approved} ? " <img class='ico' src='$m->{stylePath}/post_i.png'"
		. " title='$lng->{brdInvisTT}' alt='$lng->{brdInvis}'/>" : "";
	my $pollImg = $topic->{pollId} ? " <img class='ico' src='$m->{stylePath}/topic_poll.png'"
		. " title='$lng->{brdPollTT}' alt='$lng->{brdPoll}'/>" : "";
	my $tag = $topic->{tag} && $cfg->{allowTopicTags} && $user->{showDeco} 
		? " " . $m->formatTopicTag($topic->{tag}) : "";
	
	# Determine variable topic icon attributes
	my $imgSrc = ""; 
	my $imgTitle = "";
	my $imgAlt = "";
	if (!$userId) { $imgSrc = "topic_ou" }
	else {
		if ($topic->{newNum} && $topic->{unreadNum}) { 
			$imgSrc = "topic_nu"; $imgTitle = $lng->{comNewUnrdTT}; $imgAlt = $lng->{comNewUnrd};
		}
		elsif ($topic->{newNum}) { 
			$imgSrc = "topic_nr"; $imgTitle = $lng->{comNewReadTT}; $imgAlt = $lng->{comNewRead};
		}
		elsif ($topic->{unreadNum}) { 
			$imgSrc = "topic_ou"; $imgTitle = $lng->{comOldUnrdTT}; $imgAlt = $lng->{comOldUnrd};
		}
		else { 
			$imgSrc = "topic_or"; $imgTitle = $lng->{comOldReadTT}; $imgAlt = $lng->{comOldRead};
		}
	}
	my $imgAttr = "class='ico' src='$m->{stylePath}/$imgSrc.png' title='$imgTitle' alt='$imgAlt'";

	# Print topic
	$url = $m->url('topic_show', tid => $topic->{id}, tgt => $fp);
	print 
		"<tr class='crw'>\n",
		"<td>\n",
		"<a id='tid$topic->{id}' href='$url'>\n",
		"<img $imgAttr/>$lockImg$invisImg$pollImg\n",
		"$subject</a>$tag\n",
		"</td>\n",
# TUSK begin adding in number of topic views
	        "<td class='sshr'>$topic->{hitNum}</td>\n",
# TUSK end
		"<td class='shr'>$userNameStr</td>\n",
		"<td class='sshr'>$topic->{postNum} $newNumStr</td>\n",
		"<td class='shr'>$lastPostTimeStr</td>\n",
		"</tr>\n";

}

print "</table>\n\n";

# Log action
$m->logAction(2, 'board', 'show', $userId, $boardId);

# Print footer
$m->printFooter(undef, undef, $boardId);
