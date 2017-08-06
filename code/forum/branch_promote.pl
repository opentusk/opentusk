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

# Get CGI parameters
my $postId = $m->paramInt('pid');
my $newBoardId = $m->paramInt('bid');
my $subject = $m->paramStr('subject');
my $link = $m->paramBool('link');
my $sourceAuth = $m->paramInt('auth');
$postId or $m->paramError($lng->{errPstIdMiss});
$subject or $m->userError($lng->{errSubEmpty});

# Check request source authentication
$sourceAuth == $user->{sourceAuth} or $m->paramError($lng->{errSrcAuth});

# Get branch base post
my ($oldBoardId, $oldTopicId, $oldParentId, $oldPostTime) = $m->fetchArray("
	SELECT boardId, topicId, parentId, postTime FROM $cfg->{dbPrefix}posts WHERE id = $postId");
$oldBoardId or $m->entryError($lng->{errPstNotFnd});
$newBoardId ||= $oldBoardId;

# Branch base post can't be topic base post
$oldParentId or $m->userError($lng->{errPromoTpc});

# Get destination board
my $newBoard = $m->fetchHash("
	SELECT * FROM $cfg->{dbPrefix}boards WHERE id = $newBoardId");
$newBoard or $m->entryError($lng->{errBrdNotFnd});

# Check if user is admin or moderator in source board
$user->{admin} || $m->boardAdmin($userId, $oldBoardId) or $m->adminError();

# Check if user has write access to destination board
$m->boardVisible($newBoard) or $m->entryError($lng->{errBrdNotFnd});
$m->boardWritable($newBoard) or $m->userError($lng->{errReadOnly});

# Get IDs of posts that belong to branch
my $posts = $m->fetchAllHash("
	SELECT id, parentId FROM $cfg->{dbPrefix}posts WHERE topicId = $oldTopicId");
our %postsByParent = ();
push @{$postsByParent{$_->{parentId}}}, $_ for @$posts;
our @branchPostIds = ();
getBranchPostIds($postId);
sub getBranchPostIds
{
	my $pid = shift();
	push @branchPostIds, $pid;
	for my $child (@{$postsByParent{$pid}}) { 
		$child->{id} != $pid or printError("Integrity Error", "Post is its own parent?!");
		getBranchPostIds($child->{id});
	}
}
my $branchPostIdsStr = join(",", @branchPostIds);

# Get last post time from branch posts
my $branchLastPostTime = $m->fetchArray("
	SELECT MAX(postTime) FROM $cfg->{dbPrefix}posts WHERE id IN ($branchPostIdsStr)");

# Transaction
my $newTopicId = undef;
my $oldMarkerId = undef;
$m->dbBegin();
eval {
	if ($link) {
		# Insert new topic
		my $subjectQ = $m->dbQuote($m->escHtml($subject));
		$m->dbDo("
			INSERT INTO $cfg->{dbPrefix}topics (subject, boardId, lastPostTime)
			VALUES ($subjectQ, $newBoardId, $branchLastPostTime)");
		$newTopicId = $m->dbInsertId("$cfg->{dbPrefix}topics");
	
		# Insert marker post in old topic
		$m->setLanguage($cfg->{language});
		my $url = $m->url('topic_show', tid => $newTopicId);
		my $bodyQ = $m->dbQuote("[<a class='url' href='$url'>$lng->{brnProLnkBdy}</a>]");
		$m->dbDo("
			INSERT INTO $cfg->{dbPrefix}posts (
				userId, userNameBak, boardId, topicId, parentId, 
				approved, postTime, body
			) VALUES (
				-2, '', $oldBoardId, $oldTopicId, $oldParentId, 
				1, $oldPostTime, $bodyQ
			)");
		$oldMarkerId = $m->dbInsertId("$cfg->{dbPrefix}posts");
	
		# Insert marker post in new topic
		$url = $m->url('topic_show', tid => $oldTopicId, pid => $oldMarkerId, tgt => "pid$oldMarkerId");
		$m->setLanguage();
		my $linkText = $lng->{brnProLnkBdy};
		$m->setLanguage($user->{language});
		$bodyQ = $m->dbQuote("[<a class='url' href='$url'>$linkText</a>]");
		$m->dbDo("
			INSERT INTO $cfg->{dbPrefix}posts (
				userId, userNameBak, boardId, topicId, parentId, 
				approved, postTime, body
			) VALUES (
				-2, '', $newBoardId, $newTopicId, 0, 
				1, $branchLastPostTime, $bodyQ
			)");
		my $newMarkerId = $m->dbInsertId("$cfg->{dbPrefix}posts");
		$m->setLanguage();
	
		# Update new topic's base post id
		$m->dbDo("
			UPDATE $cfg->{dbPrefix}topics SET basePostId = $newMarkerId WHERE id = $newTopicId");
	
		# Update base post's parentId
		$m->dbDo("
			UPDATE $cfg->{dbPrefix}posts SET parentId = $newMarkerId WHERE id = $postId");
	}
	else {
		# Insert topic
		my $subjectQ = $m->dbQuote($m->escHtml($subject));
		$m->dbDo("
			INSERT INTO $cfg->{dbPrefix}topics (subject, boardId, basePostId, lastPostTime)
			VALUES ($subjectQ, $newBoardId, $postId, $m->{now})");
		$newTopicId = $m->dbInsertId("$cfg->{dbPrefix}topics");
		
		# Update base post's parentId
		$m->dbDo("
			UPDATE $cfg->{dbPrefix}posts SET parentId = 0 WHERE id = $postId");
	}		

	# Update posts
	$m->dbDo("
		UPDATE $cfg->{dbPrefix}posts SET
			boardId = $newBoardId,
			topicId = $newTopicId
		WHERE id IN ($branchPostIdsStr)");

	# Update statistics
	if ($oldBoardId != $newBoardId) {
		# Update board stats
		$m->recalcStats($oldBoardId, $oldTopicId);
		$m->recalcStats($newBoardId, $newTopicId);
	}
	else {
		# Only update topic stats
		$m->recalcStats(undef, $oldTopicId);
		$m->recalcStats(undef, $newTopicId);
	}

	# Duplicate topicReadTimes for new topic
	if ($m->{mysql}) {
		my $topicReadTimes = $m->fetchAllArray("
			SELECT userId, lastReadTime FROM $cfg->{dbPrefix}topicReadTimes WHERE topicId = $oldTopicId");
		if (@$topicReadTimes) {
			my $topicReadTimesStr = join(",", map("($_->[0], $newTopicId, $_->[1])", @$topicReadTimes));
			$m->dbDo("
				INSERT INTO $cfg->{dbPrefix}topicReadTimes (userId, topicId, lastReadTime)
				VALUES $topicReadTimesStr");
		}
	}
	else {
		$m->dbDo("
			INSERT INTO $cfg->{dbPrefix}topicReadTimes (userId, topicId, lastReadTime)
			SELECT userId, $newTopicId, lastReadTime 
			FROM $cfg->{dbPrefix}topicReadTimes 
			WHERE topicId = $oldTopicId");
	}
};
$@ ? $m->dbRollback() : $m->dbCommit();

# Log action
$m->logAction(1, 'branch', 'promote', $userId, $oldBoardId, $oldTopicId, $postId, $newTopicId);

# Redirect
$m->redirect('topic_show', tid => $oldTopicId, pid => $postId, msg => 'BrnPromo', 
	tgt => "pid$oldMarkerId");
