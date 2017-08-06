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
$userId or $m->regError();
$m->checkBan($userId);
$m->checkBlock();

# Get CGI parameters
my $boardId = $m->paramInt('bid');

# Print header
$m->printHeader();

# Print page bar
my @navLinks = ({ url => $m->url('forum_show'), txt => 'comUp', ico => 'up' });
$m->printPageBar(mainTitle => $lng->{repTitle}, navLinks => \@navLinks);

# Determine which boards user can and wants to see
my $boardIdStr = ""; 
if ($user->{admin} && $boardId) {
	$boardIdStr = "WHERE posts.boardId = $boardId";
}
elsif (!$user->{admin}) {
	if ($boardId) {
		$m->boardAdmin($userId, $boardId) or $m->adminError();
		$boardIdStr = "WHERE posts.boardId = $boardId";
	}
	else {
		my $boards = $m->fetchAllArray("
			SELECT id FROM $cfg->{dbPrefix}boards");
		@$boards = grep($m->boardAdmin($userId, $_->[0]), @$boards);
		$boardIdStr = join(",", map($_->[0], @$boards));
		$boardIdStr or $m->adminError();
		$boardIdStr = "WHERE posts.boardId IN (" . $boardIdStr . ")";
	}
}

# Get reported posts
my $posts = $m->fetchAllHash("
	SELECT postReports.userId AS reporterId, postReports.reason,
		posts.id, posts.userId, posts.userNameBak, posts.topicId, posts.postTime, posts.body,
		topics.subject,
		users.userName,
		reporters.id AS reporterId, reporters.userName AS reporterName
	FROM $cfg->{dbPrefix}postReports AS postReports
		INNER JOIN $cfg->{dbPrefix}posts AS posts
			ON posts.id = postReports.postId
		INNER JOIN $cfg->{dbPrefix}topics AS topics
			ON topics.id = posts.topicId
		LEFT JOIN $cfg->{dbPrefix}users AS users
			ON users.id = posts.userId
		LEFT JOIN $cfg->{dbPrefix}users AS reporters 
			ON reporters.id = postReports.userId
	$boardIdStr
	ORDER BY posts.postTime DESC");

# Fake board
my $fakeBoard = { flat => 1 };

# Print reports
for my $post (@$posts) {
	# Shortcuts
	my $postId = $post->{id};

	# Format output
	my $timeStr = $m->formatTime($post->{postTime}, $user->{timezone});
	my $userNameStr = $post->{userName} || $post->{userNameBak} || " - ";
	my $infUrl = $m->url('user_info', uid => $post->{userId});
	$userNameStr = "<a href='$infUrl'>$userNameStr</a>" if $post->{userId} > -1;
	my $reporterNameStr = $post->{reporterName} || " - ";
	$infUrl = $m->url('user_info', uid => $post->{reporterId});
	$reporterNameStr = "<a href='$infUrl'>$reporterNameStr</a>";
	my $fakePost = { body => $post->{reason} };
	$m->dbToDisplay($fakeBoard, $fakePost);
	$m->dbToDisplay($fakeBoard, $post);
	my $shwUrl = $m->url('topic_show', tid => $post->{topicId}, pid => $postId, tgt => "pid$postId");

	# Print post
	print
		"<div class='frm'>\n",
		"<div class='hcl'>\n",
		"<span class='htt'>$lng->{repBy}</span> $reporterNameStr\n",
		"<span class='htt'>$lng->{repOn}</span> $timeStr\n",
		"</div>\n",
		"<div class='ccl'>\n",
		"$fakePost->{body}\n",
		"</div>\n",
		"<div class='ccl'>\n",
		"$lng->{repTopic}:\n",
		"<a href='$shwUrl'>$post->{subject}</a><br/>\n",
		"$lng->{repPoster}: $userNameStr<br/><br/>\n",
		"$post->{body}<br/><br/>\n",
		"<form action='report_delete$m->{ext}' method='post'>\n",
		$m->submitButton('repDeleteB', 'remove'),
		"<input type='hidden' name='uid' value='$post->{reporterId}'/>\n",
		"<input type='hidden' name='pid' value='$postId'/>\n",
		$m->stdFormFields(),
		"</form>\n",
		"</div>\n",
		"</div>\n\n";
}

# If list is empty, display notification
print
	"<div class='frm'>\n",
	"<div class='ccl'>\n",
	"$lng->{repEmpty}\n",
	"</div>\n",
	"</div>\n\n"
	if !@$posts;

# Log action
$m->logAction(2, 'report', 'list', $userId);

# Print footer
$m->printFooter();
