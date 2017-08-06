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

# Check if blogs are enabled
$cfg->{blogs} or $m->userError($lng->{errFeatDisbl});

# Check if only registered users are allowed
$cfg->{blogs} != 2 || $userId or $m->regError();

# Get CGI parameters
my $boardId = $m->paramInt('bid') || -$userId;
my $jumpTopicId = $m->paramInt('tid');
my $page = $m->paramInt('pg') || 1;

# Get missing boardId from topic
$boardId = $m->fetchArray("
	SELECT boardId FROM $cfg->{dbPrefix}topics WHERE id = $jumpTopicId")
	if !$boardId && $jumpTopicId;
$boardId or $m->paramError($lng->{errBrdIdMiss});
$boardId < 0 or $m->paramError("Invalid blog ID.");

# Get blogger and board
my $blogger = $m->getUser(abs($boardId));
my $board = $m->getBlogBoard($blogger);

# Check if user can see and write to board
my $boardAdmin = $user->{admin} || $m->boardAdmin($userId, $board->{id});
$boardAdmin || $m->boardVisible($board) or $m->entryError($lng->{errBrdNotFnd});
my $boardWritable = $boardAdmin || $m->boardWritable($board);

# Print header
$m->printHeader("$lng->{blgTitle}: $board->{title}");

# Set current page to a requested topic's page	
my $topicsPP = $m->min($user->{topicsPP}, $cfg->{maxTopicsPP}) || $cfg->{maxTopicsPP};
if ($jumpTopicId) {
	my $jumpTopicTime = $m->fetchArray("
		SELECT posts.postTime 
		FROM $cfg->{dbPrefix}topics AS topics
			INNER JOIN $cfg->{dbPrefix}posts AS posts
				ON posts.id = topics.basePostId
		WHERE topics.id = $jumpTopicId");
	$page = $m->fetchArray(" 
		SELECT COUNT(topics.id) / $topicsPP + 1
		FROM $cfg->{dbPrefix}topics AS topics
			INNER JOIN $cfg->{dbPrefix}posts AS posts
				ON posts.id = topics.basePostId
		WHERE topics.boardId = $boardId
			AND (posts.postTime > $jumpTopicTime)")
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
	push @pageLinks, { url => $m->url('blog_show', bid => $boardId, pg => $_), 
		txt => $_, dsb => $_ == $page }
		for 1 .. $maxPageNum;
	push @pageLinks, { txt => "..." }, { 
		url => $m->url('blog_show', bid => $boardId, pg => $pageNum), 
		txt => $pageNum, dsb => $pageNum == $page }
		if $maxPageNum + 1 < $pageNum;
	push @pageLinks, { url =>$m->url('blog_show', bid => $boardId, pg => $prevPage), 
		txt => 'comPgPrev', dsb => $page == 1 };
	push @pageLinks, { url => $m->url('blog_show', bid => $boardId, pg => $nextPage), 
		txt => 'comPgNext', dsb => $page == $pageNum };
}

# User button links
my @userLinks = ();
push @userLinks, { url => $m->url('topic_add', bid => $boardId), 
	txt => 'brdNewTpc', ico => 'write' } 
	if $boardWritable;
push @userLinks, { url => $m->url('forum_overview', act => 'blogs', bid => $boardId), 
	txt => 'comShowNew', ico => 'shownew' } 
	if $userId;

# Print page bar
my @navLinks = ({ url => $m->url('user_info', uid => $blogger->{id}), 
	txt => 'comUp', ico => 'up' });
$m->printPageBar(mainTitle => $lng->{blgTitle}, subTitle => $blogger->{userName}, 
	navLinks => \@navLinks, pageLinks => \@pageLinks,	userLinks => \@userLinks);

# Get topics
my $offset = ($page - 1) * $topicsPP;
my $limitStr = $m->{mysql} ? "LIMIT $offset, $topicsPP" : "LIMIT $topicsPP OFFSET $offset";
my $topics = $m->fetchAllHash("
	SELECT topics.*, 
		posts.postTime, posts.body
	FROM $cfg->{dbPrefix}topics AS topics
		INNER JOIN $cfg->{dbPrefix}posts AS posts
			ON posts.id = topics.basePostId
	WHERE topics.boardId = $boardId
	ORDER BY posts.postTime DESC
	$limitStr");

# Put topics in by-id lookup table and concat their IDs for the next query
my %topics = map(($_->{id} => $_), @$topics);
my $topicIdsStr = join(",", map($_->{id}, @$topics)) || "0";

# Get new post and unread numbers
my $lowestUnreadTime = $m->max($user->{fakeReadTime}, $m->{now} - $cfg->{maxUnreadDays} * 86400);
if ($userId && !$m->{pgsql}) {
	my $topicStats = $m->fetchAllArray("
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

	for my $topic (@$topicStats) {
		$topics{$topic->[0]}{newNum} = $topic->[1];
		$topics{$topic->[0]}{unreadNum} = $topic->[2];
	}
}

# Print topic base posts
for my $topic (@$topics) {
	# Shortcuts
	my $topicId = $topic->{id};

	# Use #fp target if there're new or unread posts, but not if all of them are new or unread
	my $fp = $topic->{unreadNum} || $topic->{newNum}
		&& !($topic->{unreadNum} == $topic->{postNum} || $topic->{newNum} == $topic->{postNum})
		? "fp" : "";
	
	# Format output
	my $postTimeStr = $m->formatTime($topic->{postTime}, $user->{timezone});
	my $commentNum = $topic->{postNum} - 1;
	$m->dbToDisplay($board, $topic);
	my $url = $m->url('topic_show', tid => $topicId, tgt => $fp);

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

	# Lock icon
	my $lockImg = $topic->{locked} ? " <img class='ico' src='$m->{stylePath}/topic_l.png'"
		. " title='$lng->{brdLockedTT}' alt='$lng->{brdLocked}'/>" : "";

	# Poll icon
	my $pollImg = $topic->{pollId} ? " <img class='ico' src='$m->{stylePath}/topic_poll.png'"
		. " title='$lng->{brdPollTT}' alt='$lng->{brdPoll}'/>" : "";

	print
		"<div class='frm blg'>\n",
		"<div class='hcl'>\n",
		"<a href='$url'><img $imgAttr/></a>$lockImg$pollImg\n",
		"<span class='htt'>$lng->{blgSubject}</span> $topic->{subject}\n",
		"<span class='htt'>$lng->{blgDate}</span> $postTimeStr\n",
		"</div>\n",
		"<div class='ccl'>\n",
		"$topic->{body}\n",
		"</div>\n",
		"<div class='bcl'>\n",
		"<a href='$url' title='$lng->{blgCommentTT}'>",
		"$lng->{blgComment} ($commentNum)</a>\n",
		"</div>\n",
		"</div>\n\n";
}

# Print expiration note	
if ($cfg->{blogExpiration}) {
	print
		"<div class='frm'>\n",
		"<div class='ccl'>\n",
		$m->formatStr($lng->{blgExpire}, { days => $cfg->{blogExpiration} }), "\n",
		"</div>\n",
		"</div>\n\n";
}

# Log action
$m->logAction(2, 'blog', 'show', $userId, $boardId);

# Print footer
$m->printFooter();
