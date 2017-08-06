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

# Get CGI parameters
my $userIp = $m->paramStr('userIp');
my $userName = $m->paramStr('userName');
my $userAgent = $m->paramStr('userAgent');
my $postIp = $m->paramStr('postIp');
my $postBody = $m->paramStr('postBody');
my $maxAge = $m->paramInt('maxAge') || 1;
my $deleteBranches = $m->paramBool('deleteBranches');
my $deleteTopics = $m->paramBool('deleteTopics');
my $action = $m->paramStrId('act');
my $delete = $m->paramBool('delete');
my $preview = $m->paramBool('preview');
my $submitted = $m->paramBool('subm');
my $sourceAuth = $m->paramInt('auth');

# Preview data
my $users = [];
my $posts = [];

# Process form
if ($submitted) {
	# Check request source authentication
	$sourceAuth == $user->{sourceAuth} or $m->formError($lng->{errSrcAuth});

	# Process delete users and their posts form
	if ($action eq 'users') {
		# Check criteria
		$userIp || $userName || $userAgent or $m->formError("All criteria are empty.");
		
		# Print form errors or finish action
		if (@{$m->{formErrors}}) { $m->printFormErrors() }
		else {
			# Transaction
			$m->dbBegin();
			eval {
				# Search spammers
				my $userIpLike = $m->dbEscLike($userIp);
				my $userNameLike = $m->dbEscLike($userName);
				my $userAgentLike = $m->dbEscLike($userAgent);
				my $userIpQ = $m->dbQuote("$userIpLike%");
				my $userNameQ = $m->dbQuote("%$userNameLike%");
				my $userAgentQ = $m->dbQuote("%$userAgentLike%");
				my $userIpStr = $userIp ? "lastIp LIKE $userIpQ" : "";
				my $userNameStr = $userName ? "userName LIKE $userNameQ" : "";
				my $userAgentStr = $userAgent ? "userAgent LIKE $userAgentQ" : "";
				my $searchStr = join(" OR ", grep($_, $userIpStr, $userNameStr, $userAgentStr));
				$users = $m->fetchAllArray("
					SELECT id, userName 
					FROM $cfg->{dbPrefix}users 
					WHERE regTime > $m->{now} - $maxAge * 86400
						AND ($searchStr)
					ORDER BY id");
				my $userIdsStr = join(",", map($_->[0], @$users)) || "0";

				if (!$preview) {
					# Delete topics started by spammers
					if ($deleteTopics) {
						my $topics = $m->fetchAllArray("
							SELECT topicId
							FROM $cfg->{dbPrefix}posts
							WHERE userId IN ($userIdsStr)
								AND parentId = 0");
						$m->deleteTopic($_->[0]) for @$topics;
					}
	
					# Delete posts
					my $posts = $m->fetchAllArray("
						SELECT id, topicId FROM $cfg->{dbPrefix}posts WHERE userId IN ($userIdsStr)");
					my $postIdsStr = join(",", map($_->[0], @$posts)) || "0";
					my $children = $m->fetchAllArray("
						SELECT parentId FROM $cfg->{dbPrefix}posts WHERE parentId IN ($postIdsStr)");
					my %children = ();
					$children{$_->[0]} = 1 for @$children;
					$m->deletePost($_->[0], 0, $children{$_->[0]}, 0) for @$posts;
	
					# Update all board and affected topic stats
					my $boards = $m->fetchAllArray("
						SELECT id FROM $cfg->{dbPrefix}boards");
					$m->recalcStats($_->[0]) for @$boards;
					my %topics = ();
					$topics{$_->[1]} = 1 for @$posts;
					$m->recalcStats(undef, $_) for keys(%topics);
				}
			};
			$@ ? $m->dbRollback() : $m->dbCommit();
	
			# Log action
			$m->logAction(1, 'forum', 'purge', $userId);
		}
	}
	# Process delete posts form
	elsif ($action eq 'posts') {
		# Check criteria
		$postIp || $postBody or $m->formError("All criteria are empty.");

		# Print form errors or finish action
		if (@{$m->{formErrors}}) { $m->printFormErrors() }
		else {
			# Transaction
			$m->dbBegin();
			eval {
				# Search posts
				my $postIpLike = $m->dbEscLike($postIp);
				my $postBodyLike = $m->dbEscLike($postBody);
				my $postIpQ = $m->dbQuote("$postIpLike%");
				my $postBodyQ = $m->dbQuote("%$postBodyLike%");
				my $postIpStr = $postIp ? "ip LIKE $postIpQ" : "";
				my $postBodyStr = $postBody ? "body LIKE $postBodyQ" : "";
				my $searchStr = join(" OR ", grep($_, $postIpStr, $postBodyStr));
				$posts = $m->fetchAllArray("
					SELECT id, topicId 
					FROM $cfg->{dbPrefix}posts 
					WHERE postTime > $m->{now} - $maxAge * 86400
						AND ($searchStr)
					ORDER BY id");
				my $postIdsStr = join(",", map($_->[0], @$posts)) || "0";

				if (!$preview) {
					# Delete topics started by spam posts
					if ($deleteTopics) {
						my $topics = $m->fetchAllArray("
							SELECT topicId
							FROM $cfg->{dbPrefix}posts
							WHERE id IN ($postIdsStr)
								AND parentId = 0");
						$m->deleteTopic($_->[0]) for @$topics;
					}

					# Delete posts
					my $children = $m->fetchAllArray("
						SELECT parentId FROM $cfg->{dbPrefix}posts WHERE parentId IN ($postIdsStr)");
					my %children = ();
					$children{$_->[0]} = 1 for @$children;
					$m->deletePost($_->[0], 0, $children{$_->[0]}, 0) for @$posts;
	
					# Update all board and affected topic stats
					my $boards = $m->fetchAllArray("
						SELECT id FROM $cfg->{dbPrefix}boards");
					$m->recalcStats($_->[0]) for @$boards;
					my %topics = ();
					$topics{$_->[1]} = 1 for @$posts;
					$m->recalcStats(undef, $_) for keys(%topics);
				}
			};
			$@ ? $m->dbRollback() : $m->dbCommit();
	
			# Log action
			$m->logAction(1, 'forum', 'purge', $userId);
		}
	}
}

# Print header
$m->printHeader();

# Print page bar
my @navLinks = ({ url => $m->url('forum_show'), txt => 'comUp', ico => 'up' });
$m->printPageBar(mainTitle => "Forum Purge", navLinks => \@navLinks);

# Escape submitted values
$userIp = $m->escHtml($userIp);
$userName = $m->escHtml($userName);
$userAgent = $m->escHtml($userAgent);
$postIp = $m->escHtml($postIp);
$postBody = $m->escHtml($postBody);
my $deleteTopicsSel = $deleteTopics ? "checked='checked'" : "";

# Print warning
print
	"<div class='frm'>\n",
	"<div class='hcl'>\n",
	"<span class='htt'><em>Warning</em></span>\n",
	"</div>\n",
	"<div class='ccl'>\n",
	"This feature is meant to be used for mass-deleting spam and troll accounts and posts.",
	" Since it's easy to accidentally delete too much, it should only be used by experienced admins",
	" who know what they're doing. Make a database backup and use the preview feature before deleting.\n",
	"</div>\n",
	"</div>\n\n";

# Print user/post purge form
print
	"<form class='prg' action='forum_purge$m->{ext}' method='post'>\n",
	"<div class='frm'>\n",
	"<div class='hcl'>\n",
	"<span class='htt'>Purge Users and their Posts</span>\n",
	"</div>\n",
	"<div class='ccl'>\n",
	"Delete all user accounts matching any of the following criteria, as well as their posts:",
	"<br/><br/>\n",
	"IP starting with<br/>\n",
	"<input type='text' name='userIp' size='20' value='$userIp'/><br/>\n",
	"Username containing<br/>\n",
	"<input type='text' name='userName' size='20' value='$userName'/><br/>\n",
	"User agent containing<br/>\n",
	"<input type='text' name='userAgent' size='40' value='$userAgent'/><br/>\n",
	"Registered during the last x days<br/>\n",
	"<input type='text' name='maxAge' size='4' value='$maxAge'/><br/>\n",
	"<br/>\n",
	"<label><input type='checkbox' name='deleteTopics' $deleteTopicsSel/>",
	"Delete complete topics started by matching users</label><br/>\n",
	"<br/>\n",
	$m->submitButton("Delete", 'delete', 'delete'),
	$m->submitButton("Preview", 'preview', 'preview'),
	"<input type='hidden' name='act' value='users'/>\n",
	$m->stdFormFields(),
	"</div>\n",
	"</div>\n",
	"</form>\n\n";
	
if ($submitted && $action eq 'users') {
	print
		"<div class='frm'>\n",
		"<div class='hcl'>\n",
		"<span class='htt'>Affected Users</span>\n",
		"</div>\n",
		"<div class='ccl'>\n";
		
	for (@$users) {
		my $url = $m->url('user_info', uid => $_->[0]);
		$_ = "<a href='$url'>$_->[1]</a>";
	}
	my $usersStr = join(",\n", @$users) || " - ";

	print 
		$usersStr, "\n",
		"</div>\n",
		"</div>\n\n";
}

# Print posts purge form
print
	"<form class='prg' action='forum_purge$m->{ext}' method='post'>\n",
	"<div class='frm'>\n",
	"<div class='hcl'>\n",
	"<span class='htt'>Purge Posts</span>\n",
	"</div>\n",
	"<div class='ccl'>\n",
	"Delete all posts matching any of the following criteria:",
	"<br/><br/>\n",
	"IP starting with<br/>\n",
	"<input type='text' name='postIp' size='20' value='$postIp'/><br/>\n",
	"Post body containing<br/>\n",
	"<input type='text' name='postBody' size='40' value='$postBody'/><br/>\n",
	"Posted during the last x days<br/>\n",
	"<input type='text' name='maxAge' size='4' value='$maxAge'/><br/>\n",
	"<br/>\n",
	"<label><input type='checkbox' name='deleteTopics' $deleteTopicsSel/>",
	"Delete complete topics started by matching posts</label><br/>\n",
	"<br/>\n",
	$m->submitButton("Delete", 'delete', 'delete'),
	$m->submitButton("Preview", 'preview', 'preview'),
	"<input type='hidden' name='act' value='posts'/>\n",
	$m->stdFormFields(),
	"</div>\n",
	"</div>\n",
	"</form>\n\n";

if ($submitted && $action eq 'posts') {
	print
		"<div class='frm'>\n",
		"<div class='hcl'>\n",
		"<span class='htt'>Affected Posts</span>\n",
		"</div>\n",
		"<div class='ccl'>\n";
		
	for (@$posts) {
		my $url = $m->url('topic_show', pid => $_->[0], tgt => "pid$_->[0]");
		$_ = "<a href='$url'>$_->[0]</a>";
	}
	my $postsStr = join(",\n", @$posts) || " - ";

	print 
		$postsStr, "\n",
		"</div>\n",
		"</div>\n\n";
}

# Log action
$m->logAction(3, 'forum', 'purge', $userId);

# Print footer
$m->printFooter();
