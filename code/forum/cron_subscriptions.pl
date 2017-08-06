#!/usr/bin/env perl
use FindBin;
use lib "$FindBin::Bin/../../lib";

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

BEGIN {
    $ENV{COMMAND_LINE} = 1;
}

use strict;
use warnings;
no warnings qw(uninitialized redefine);

# Imports
use Forum::MwfMain;

#------------------------------------------------------------------------------

# Init

my ($m, $cfg, $lng) = MwfMain->newShell();


if ($cfg->{subscriptions}) {
	my $debug = 0;

	# Transaction
	$m->dbBegin();
	eval {
		# Get last sent time	
		my $lastSentTime = $m->max($m->getVar('crnSubLst') || 0, $m->{now} - 86400 * 5);
		
		# Get boards
		my $boards = $m->fetchAllHash("
			SELECT * 
			FROM $cfg->{dbPrefix}boards
			WHERE lastPostTime > $lastSentTime");
		
		# Board subscriptions
		for my $board (@$boards) {
			# Get posts
			my $posts = $m->fetchAllHash("
				SELECT posts.postTime, posts.body, posts.userNameBak, 
					topics.subject
				FROM $cfg->{dbPrefix}posts AS posts
					INNER JOIN $cfg->{dbPrefix}topics AS topics
						ON topics.id = posts.topicId
				WHERE posts.postTime > $lastSentTime
					AND posts.boardId = $board->{id}
					AND posts.approved = 1
				ORDER BY posts.topicId, posts.postTime");
			next if !@$posts;
		
			# Concatenate all posts
			my $subject = "$cfg->{forumName} - $lng->{subSubjBrd} '$board->{title}'";
			my $body = $subject . "\n\n" 
				. $lng->{subNoReply} . "\n\n" 
				. "-" x 70 . "\n\n";
			for my $post (@$posts) {
				$m->dbToEmail($board, $post);
				my $timeStr = $m->formatTime($post->{postTime});
				$body = $body
					. $lng->{subTopic} . $post->{subject} . "\n"
					. $lng->{subBy} . $post->{userNameBak} . "\n"
					. $lng->{subOn} . $timeStr . "\n\n"
					. $post->{body}
					. "\n\n" . "-" x 70 . "\n\n";
			}
			
			# Get recipients
			my $receivers = $m->fetchAllHash("
				SELECT users.*
				FROM $cfg->{dbPrefix}boardSubscriptions AS boardSubscriptions
					INNER JOIN $cfg->{dbPrefix}users AS users
						ON users.id = boardSubscriptions.userId
				WHERE boardSubscriptions.boardId = $board->{id}
					AND users.email <> ''
					AND users.dontEmail = 0");
			next if !@$receivers;
			
			for my $receiver (@$receivers) { 
				# Check if user still has read access
				next if !$m->boardVisible($board, $receiver);
				
				# Send email			
				print "Sending to $receiver->{email}...\n" if $debug;
				$m->sendEmail(user => $receiver, subject => $subject, body => $body);
			}
		}
	
		# Topic subscriptions
		for my $board (@$boards) {
			# Get topics
			my $topics = $m->fetchAllHash("
				SELECT id, subject
				FROM $cfg->{dbPrefix}topics
				WHERE lastPostTime > $lastSentTime
					AND boardId = $board->{id}");
			
			# For each topic
			for my $topic (@$topics) {
				# Get posts
				my $posts = $m->fetchAllHash("
					SELECT posts.postTime, posts.body, posts.userNameBak
					FROM $cfg->{dbPrefix}posts AS posts
					WHERE posts.postTime > $lastSentTime
						AND posts.topicId = $topic->{id}
						AND posts.approved = 1
					ORDER BY posts.postTime");
				next if !@$posts;
			
				# Concatenate all posts
				my $subject = "$cfg->{forumName} - $lng->{subSubjTpc} '$topic->{subject}'";
				my $body = $subject . "\n\n"
					. $lng->{subNoReply} . "\n\n" 
					. "-" x 70 . "\n\n";
				for my $post (@$posts) {
					$m->dbToEmail($board, $post);
					my $timeStr = $m->formatTime($post->{postTime});
					$body = $body
						. $lng->{subBy} . $post->{userNameBak} . "\n"
						. $lng->{subOn} . $timeStr . "\n\n"
						. $post->{body}
						. "\n\n" . "-" x 70 . "\n\n";
				}
			
				# Get recipients
				my $receivers = $m->fetchAllHash("
					SELECT users.*
					FROM $cfg->{dbPrefix}topicSubscriptions AS topicSubscriptions
						INNER JOIN $cfg->{dbPrefix}users AS users
							ON users.id = topicSubscriptions.userId
					WHERE topicSubscriptions.topicId = $topic->{id}
						AND users.email <> ''
						AND users.dontEmail = 0");
				next if !@$receivers;
			
				for my $receiver (@$receivers) { 
					# Check if user still has read access
					next if !$m->boardVisible($board, $receiver);
					
					# Send email
					print "Sending to $receiver->{email}...\n" if $debug;
					$m->sendEmail(user => $receiver, subject => $subject, body => $body);
				}
			}
		}
		
		# Set last sent time
		$m->setVar('crnSubLst', $m->{now}, 0);
	};
	$@ ? $m->dbRollback() : $m->dbCommit();
}

# Log action
$m->logAction(1, 'cron', 'subscr');
