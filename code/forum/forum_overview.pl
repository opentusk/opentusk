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
our ($m, $cfg, $lng, $user) = MwfMain->new(@_);
our $userId = $user->{id};

# Check if access should be denied
$userId or $m->regError();
$m->checkBan($userId) if $cfg->{banViewing};
$m->checkBlock();

# Get CGI parameters
our $action = $m->paramStrId('act');
our $onlyBoardId = $m->paramInt('bid');
our $onlyTopicId = $m->paramInt('tid');

# Shortcuts
our $blog = $action eq 'blogs' ? 1 : 0;

# Print header
$m->printHeader();

# Print page bar
my @navLinks = ({ url => $m->url('forum_show'), txt => 'comUp', ico => 'up' });
my @userLinks = ();
push @userLinks, { url => $m->url('user_posts_mark', act => 'old', time => $m->{now}, auth => 1), 
	txt => 'ovwMarkOld', ico => 'markold' }
	if $action eq 'new' && !$onlyBoardId && !$onlyTopicId;
push @userLinks, { url => $m->url('forum_overview', act => 'blogs'), 
	txt => 'ovwBlogs', ico => 'blog' }
	if $action eq 'new' && !$onlyBoardId && !$onlyTopicId && $cfg->{blogs};
my $title = "";
if ($action eq 'new') { $title = $lng->{ovwTitleNew} }
elsif ($action eq 'unread') { $title = $lng->{ovwTitleUnr} }
elsif ($action eq 'todo') { $title = $lng->{ovwTitleTdo} }
elsif ($action eq 'blogs') { $title = $lng->{ovwTitleBlg} }
else { $m->paramError($lng->{errParamMiss}) }
$m->printPageBar(mainTitle => $title, navLinks => \@navLinks, userLinks => \@userLinks);

# Get board id if only one topic is displayed
if ($onlyTopicId) {
	$onlyBoardId = $m->fetchArray("
		SELECT boardId FROM $cfg->{dbPrefix}topics WHERE id = $onlyTopicId");
}

# Get boards
my $boards = [];
my $table = $blog ? 'topics.boardId' : 'boards.id';
my $onlyBoardStr = $onlyBoardId ? "AND $table = $onlyBoardId" : "";
if ($blog) {
	my $bloggers = $m->fetchAllHash("
		SELECT users.id, users.userName
		FROM $cfg->{dbPrefix}users AS users
			INNER JOIN $cfg->{dbPrefix}topics AS topics
				ON topics.boardId = -users.id
		WHERE topics.lastPostTime > $user->{prevOnTime}
			$onlyBoardStr
		GROUP BY users.id, users.userName");
	push @$boards, $m->getBlogBoard($_) for @$bloggers;
}
else {
	$boards = $m->fetchAllHash("
		SELECT boards.*
		FROM $cfg->{dbPrefix}boards AS boards
			INNER JOIN $cfg->{dbPrefix}categories AS categories
				ON categories.id = boards.categoryId
			LEFT JOIN $cfg->{dbPrefix}boardHiddenFlags AS boardHiddenFlags
				ON boardHiddenFlags.userId = $userId
				AND boardHiddenFlags.boardId = boards.id
		WHERE boardHiddenFlags.boardId IS NULL
			$onlyBoardStr
		ORDER BY categories.pos, boards.pos");
}

# Prepare values
my @topicReadTimes = ();
my $lowestUnreadTime = $m->max($user->{fakeReadTime}, $m->{now} - $cfg->{maxUnreadDays} * 86400);
our $postsPrinted = 0;

# For each board
our $board = undef;
our %postsById = ();
our %postsByParent = ();
BOARD: for $board (@$boards) {
	my $boardId = $board->{id};
	my $boardAdmin = $user->{admin} || $m->boardAdmin($userId, $board->{id});
	next BOARD if !($boardAdmin || $m->boardVisible($board));
	
	# Get topics
	my $onlyTopicStr = $onlyTopicId ? "AND topics.id = $onlyTopicId" : "";
	my $topics = undef;
	if ($action eq 'new' || $blog) {
		$topics = $m->fetchAllHash("
			SELECT topics.*,
				topicReadTimes.lastReadTime
			FROM $cfg->{dbPrefix}topics AS topics
				LEFT JOIN $cfg->{dbPrefix}topicReadTimes AS topicReadTimes
					ON topicReadTimes.userId = $userId
					AND topicReadTimes.topicId = topics.id
			WHERE topics.boardId = $boardId
				$onlyTopicStr
				AND topics.lastPostTime > $user->{prevOnTime}
			ORDER BY topics.lastPostTime");
	}
	elsif ($action eq 'unread') {
		$topics = $m->fetchAllHash("
			SELECT topics.*,
				topicReadTimes.lastReadTime
			FROM $cfg->{dbPrefix}topics AS topics
				LEFT JOIN $cfg->{dbPrefix}topicReadTimes AS topicReadTimes
					ON topicReadTimes.userId = $userId
					AND topicReadTimes.topicId = topics.id
			WHERE topics.boardId = $boardId
				$onlyTopicStr
				AND topics.lastPostTime > $lowestUnreadTime
				AND (topics.lastPostTime > topicReadTimes.lastReadTime
					OR topicReadTimes.topicId IS NULL)
			ORDER BY topics.lastPostTime");
	}		
	elsif ($action eq 'todo') {
		$topics = $m->fetchAllHash("
			SELECT DISTINCT topics.*
			FROM $cfg->{dbPrefix}topics AS topics
				INNER JOIN $cfg->{dbPrefix}postTodos AS postTodos
					ON postTodos.userId = $userId
				INNER JOIN $cfg->{dbPrefix}posts AS posts
					ON posts.topicId = topics.id
					AND posts.id = postTodos.postId
			WHERE topics.boardId = $boardId
				$onlyTopicStr
			ORDER BY topics.lastPostTime");
	}
	
	next BOARD if !@$topics;

	# Print board bar
	my $title = $blog ? $lng->{blgTitle} : $lng->{brdTitle};
	my $url = $m->url('board_show', bid => $boardId);
	print
		"<div class='frm'>\n",
		"<div class='hcl'>\n",
		"<span class='htt'>$title</span>\n",
		"<a href='$url'>$board->{title}</a>\n",
		"</div>\n",
		"</div>\n";
		
	# For each topic
	TOPIC: for my $topic (@$topics) {
		# Shortcuts
		my $topicId = $topic->{id};

		# Get posts 
		# Skip signature and attachments, this is a quick overview page
		my $apprvStr = $user->{admin} || !$board->{approve} ? "" : "AND posts.approved";
		my $topicLowestUnreadTime = $m->max($lowestUnreadTime, $topic->{lastReadTime});
		my $posts = undef;
		if ($action eq 'new' || $blog) {
			# Get new posts
			$posts = $m->fetchAllHash("
				SELECT posts.id, posts.userId, posts.parentId, posts.approved,
					posts.postTime, posts.body, posts.userNameBak, 
					posts.postTime > $topicLowestUnreadTime AS unread,
					users.userName, 
					boardAdmins.userId AS boardAdmin,
					userIgnores.userId IS NOT NULL AS ignored,
					1 AS new
				FROM $cfg->{dbPrefix}posts AS posts
					LEFT JOIN $cfg->{dbPrefix}users AS users
						ON users.id = posts.userId
					LEFT JOIN $cfg->{dbPrefix}boardAdmins AS boardAdmins
						ON boardAdmins.userId = posts.userId
						AND boardAdmins.boardId = posts.boardId
					LEFT JOIN $cfg->{dbPrefix}userIgnores AS userIgnores
						ON userIgnores.userId = $userId
						AND userIgnores.ignoredId = posts.userId
				WHERE posts.topicId = $topicId
					AND posts.postTime > $user->{prevOnTime}
					AND posts.userId > -2
					$apprvStr
				ORDER BY posts.postTime");
		}
		elsif ($action eq 'unread') {
			# Get unread posts
			$posts = $m->fetchAllHash("
				SELECT posts.id, posts.userId, posts.parentId, posts.approved,
					posts.postTime, posts.body, posts.userNameBak, 
					posts.postTime > $user->{prevOnTime} AS new,
					users.userName, 
					boardAdmins.userId AS boardAdmin,
					userIgnores.userId IS NOT NULL AS ignored,
					1 AS unread
				FROM $cfg->{dbPrefix}posts AS posts
					LEFT JOIN $cfg->{dbPrefix}users	AS users
						ON users.id = posts.userId
					LEFT JOIN $cfg->{dbPrefix}boardAdmins AS boardAdmins
						ON boardAdmins.userId = posts.userId
						AND boardAdmins.boardId = posts.boardId
					LEFT JOIN $cfg->{dbPrefix}userIgnores AS userIgnores
						ON userIgnores.userId = $userId
						AND userIgnores.ignoredId = posts.userId
				WHERE posts.topicId = $topicId
					AND posts.postTime > $topicLowestUnreadTime
					AND posts.userId > -2
					$apprvStr
				ORDER BY posts.postTime");
		}			
		elsif ($action eq 'todo') {
			$posts = $m->fetchAllHash("
				SELECT posts.id, posts.userId, posts.parentId, posts.approved,
					posts.postTime, posts.body, posts.userNameBak, 
					posts.postTime > $user->{prevOnTime} AS new,
					users.userName, 
					boardAdmins.userId AS boardAdmin,
					userIgnores.userId IS NOT NULL AS ignored
				FROM $cfg->{dbPrefix}posts AS posts
					INNER JOIN $cfg->{dbPrefix}postTodos AS postTodos
						ON postTodos.userId = $userId
						AND postTodos.postId = posts.id
					LEFT JOIN $cfg->{dbPrefix}users AS users
						ON users.id = posts.userId
					LEFT JOIN $cfg->{dbPrefix}boardAdmins AS boardAdmins
						ON boardAdmins.userId = posts.userId
						AND boardAdmins.boardId = posts.boardId
					LEFT JOIN $cfg->{dbPrefix}userIgnores AS userIgnores
						ON userIgnores.userId = $userId
						AND userIgnores.ignoredId = posts.userId
				WHERE posts.topicId = $topicId
					$apprvStr
				ORDER BY posts.postTime");
		}

		next TOPIC if !@$posts;

		# Add topic read time when showing new or unread posts
		push @topicReadTimes, [ $userId, $topicId, $m->{now} ]
			if $action eq 'new' || $blog || $action eq 'unread';

		# Print topic bar
		$url = $m->url('topic_show', tid => $topicId, tgt => 'fp');
		my $subject = "<a href='$url'>$topic->{subject}</a>";
		$subject .= " " . $lng->{tpcLocked} if $topic->{locked};
		print
			"<div class='frm' style='margin-left: $user->{indent}%'>\n",
			"<div class='hcl'>\n",
			"<span class='htt'>$lng->{tpcTitle}</span>\n",
			"$subject\n",
			"</div>\n",
			"</div>\n";

		# Build post lookup tables
		%postsById = map(($_->{id} => $_), @$posts);  # Posts by id - hash of hashrefs
		push @{$postsByParent{$_->{parentId}}}, $_ for @$posts; 

		# For each post
		for my $post (@$posts) {
			printPost($post->{id}, 2) if !$postsById{$post->{parentId}};

			# Limit number of posts printed
			$postsPrinted++;
			#last BOARD if $postsPrinted >= $cfg->{maxPostsPP};
		}
	}			
}

sub printPost
{
	my $postId = shift();
	my $depth = shift();

	# Shortcuts
	my $post = $postsById{$postId};
	my $postUserId = $post->{userId};
	my $indent = $board->{flat} ? $user->{indent} * 2 : $m->min(70, $user->{indent} * $depth);

	# Print post
	if (!$post->{ignored}) {
		# Format output
		$m->dbToDisplay($board, $post);
		my $postTimeStr = $m->formatTime($post->{postTime}, $user->{timezone});
		my $invisImg = !$post->{approved} ? " <img class='ico' src='$m->{stylePath}/post_i.png'"
			. " title='$lng->{tpcInvisTT}' alt='$lng->{brdInvis}'/> " : "";

		# Format username
		my $userNameStr = $post->{userName} || $post->{userNameBak} || " - ";
		my $url = $m->url('user_info', uid => $postUserId);
		$userNameStr = "<a href='$url'>$userNameStr</a>" if $postUserId > -1;

		# Determine variable post icon attributes
		my $imgSrc; 
		my $imgTitle = "";
		my $imgAlt = "";
		if ($post->{new} && $post->{unread}) { 
			$imgSrc = "post_nu"; $imgTitle = $lng->{comNewUnrdTT}; $imgAlt = $lng->{comNewUnrd};
		}
		elsif ($post->{new}) { 
			$imgSrc = "post_nr"; $imgTitle = $lng->{comNewReadTT}; $imgAlt = $lng->{comNewRead};
		}
		elsif ($post->{unread}) { 
			$imgSrc = "post_ou"; $imgTitle = $lng->{comOldUnrdTT}; $imgAlt = $lng->{comOldUnrd};
		}
		else { 
			$imgSrc = "post_or"; $imgTitle = $lng->{comOldReadTT}; $imgAlt = $lng->{comOldRead};
		}
		my $imgAttr = "src='$m->{stylePath}/$imgSrc.png' title='$imgTitle' alt='$imgAlt'";

		# Print post			
		$url = $m->url('topic_show', pid => $postId, tgt => "pid$postId");
		print
			"<div class='frm pst' id='pid$postId' style='margin-left: $indent%'>\n",
			"<div class='hcl'>\n",
			"<a href='$url'>\n<img class='ico' $imgAttr/></a>\n",
			$invisImg,
			"<span class='usr'><span class='htt'>$lng->{tpcBy}</span> $userNameStr</span>\n",
			"<span class='htt'>$lng->{tpcOn}</span> $postTimeStr\n",
			"</div>\n",
			"<div class='ccl'>\n",
			"$post->{body}\n";

		# Print remove-todo button
		print
			"<br/><br/>\n",
			"<form action='todo_delete$m->{ext}' method='post'>\n",
			$m->submitButton('ovwTdoRemove', 'remove'),
			"<input type='hidden' name='pid' value='$postId'/>\n",
			"<input type='hidden' name='tid' value='$onlyTopicId'/>\n",
			"<input type='hidden' name='bid' value='$onlyBoardId'/>\n",
			$m->stdFormFields(),
			"</form>\n",
			if $action eq 'todo';
			
		print
			"</div>\n",
			"</div>\n\n";
	}
	else {
		# Print hidden post bar
		print
			"<div class='frm hps' style='margin-left: $indent%'>\n",
			"<div class='hcl'>\n",
			"$lng->{tpcHidTtl} $lng->{tpcHidIgnore}\n",
			"</div>\n",
			"</div>\n\n";
	}

	for my $child (@{$postsByParent{$postId}}) {
		$child->{id} != $postId or $m->printError("Integrity Error", "Post is its own parent?!");
		printPost($child->{id}, $depth + 1);
	}
}

# If empty list, print notification
print
	"<div class='frm'>\n",
	"<div class='ccl'>\n",
	$lng->{ovwEmpty}, "\n",
	"</div>\n",
	"</div>\n\n",
	if !$postsPrinted;

# If cut off at max posts, print notification
#print
#	"<div class='frm'>\n",
#	"<div class='ccl'>\n",
#	"$lng->{ovwMaxCutoff}\n",
#	"</div>\n",
#	"</div>\n\n",
#	if $postsPrinted && $postsPrinted == $cfg->{maxPostsPP};

# Update topic read times
if (@topicReadTimes) {
	# DBMS-optimized, since this entails so many replacements
	if ($m->{mysql}) {
		my $topicReadTimes = "";
		for (@topicReadTimes) { $topicReadTimes .= "(" . join(",", @$_) . ")," }
		chop $topicReadTimes;
		$m->dbDo("
			REPLACE INTO $cfg->{dbPrefix}topicReadTimes (userId, topicId, lastReadTime)
			VALUES $topicReadTimes");
	}
	elsif ($m->{sqlite}) {
		my $updSth = $m->dbPrepare("
			REPLACE INTO $cfg->{dbPrefix}topicReadTimes (userId, topicId, lastReadTime)
			VALUES (?, ?, ?)");
		$m->dbBegin();
		$m->dbExecute($updSth, $_->[0], $_->[1], $_->[2]) for @topicReadTimes;
		$m->dbCommit();
	}
	else {
		my $delSth = $m->dbPrepare("
			DELETE FROM $cfg->{dbPrefix}topicReadTimes
			WHERE userId = ?
				AND topicId = ?");
		my $insSth = $m->dbPrepare("
			INSERT INTO $cfg->{dbPrefix}topicReadTimes (userId, topicId, lastReadTime)
			VALUES (?, ?, ?)");
		$m->dbBegin();
		for (@topicReadTimes) {
			$m->dbExecute($delSth, $_->[0], $_->[1]);
			$m->dbExecute($insSth, $_->[0], $_->[1], $_->[2]);
		}
		$m->dbCommit();
	}
}

# Log action
$m->logAction(2, 'overvw', $action, $userId, $onlyBoardId, $onlyTopicId);

# Print footer
$m->printFooter();
