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
$m->checkBan($userId) if $cfg->{banViewing};
$m->checkBlock();

# Get CGI parameters
our $topicId = $m->paramInt('tid');
our $targetPostId = $m->paramInt('pid');
our $page = $m->paramInt('pg');
our $reveal = $m->paramBool('rvl');
my $showResults = $m->paramBool('results');
my $hilite = $m->paramStr('hl');
$topicId || $targetPostId or $m->paramError($lng->{errTPIdMiss});

# Get missing topicId from post
if (!$topicId && $targetPostId) {
	$topicId = $m->fetchArray("
		SELECT topicId FROM $cfg->{dbPrefix}posts WHERE id = $targetPostId");
	$topicId or $m->paramError($lng->{errPstNotFnd});
}

# Get topic
our $topic = $m->fetchHash("
	SELECT topics.*, 
		topicReadTimes.lastReadTime
	FROM $cfg->{dbPrefix}topics AS topics
		LEFT JOIN $cfg->{dbPrefix}topicReadTimes AS topicReadTimes
			ON topicReadTimes.userId = $userId
			AND topicReadTimes.topicId = $topicId
	WHERE topics.id = $topicId");
$topic or $m->entryError($lng->{errTpcNotFnd});
$topic->{lastReadTime} ||= 0;
our $boardId = $topic->{boardId};
my $pollId = $topic->{pollId};

# Is this a blog topic?
our $blog = $cfg->{blogs} && $boardId < 0 ? 1 : 0;
our $blogger = $blog ? $m->getUser(abs($boardId)) : undef;

# Get board/category
our $board = undef;
if ($blog) { $board = $m->getBlogBoard($blogger) }
else {
	$board = $m->fetchHash("
		SELECT boards.*, 
			categories.id AS categId, categories.title AS categTitle
		FROM $cfg->{dbPrefix}boards AS boards
			INNER JOIN $cfg->{dbPrefix}categories AS categories
				ON categories.id = boards.categoryId
		WHERE boards.id = $boardId");
}
our $flat = $board->{flat};

# Get poll
my $poll = $pollId ? $m->fetchHash("
	SELECT * FROM $cfg->{dbPrefix}polls WHERE id = $pollId") : undef;

# Check if user can see and write to topic
our $boardAdmin = $user->{admin} || $m->boardAdmin($userId, $boardId);
$boardAdmin || $m->boardVisible($board) or $m->entryError($lng->{errTpcNotFnd});
our $boardWritable = $boardAdmin || $m->boardWritable($board, 1);

# Print header
$m->printHeader($topic->{subject});

# Print branch visibility toggling script
our $autoCollapsing = !$flat && $user->{collapse};
our $stylePath = $m->{stylePath};
print <<"EOSCRIPT"
<script type='text/javascript'>$m->{cdataStart}
	function mwfToggleBranch(postId) {
		var branch = document.getElementById('brn' + postId);
		var toggle = document.getElementById('tgl' + postId);
		if (!branch || !toggle) return;
		if (branch.style.display != 'none') {
			branch.style.display = 'none';
			toggle.src = '$stylePath/nav_plus.png';
			toggle.title = '$lng->{tpcBrnExpand}';
			toggle.alt = '+';
		}
		else {
			branch.style.display = '';
			toggle.src = '$stylePath/nav_minus.png';
			toggle.title = '$lng->{tpcBrnCollap}';
			toggle.alt = '-';
		}
	}

	function mwfExpandAllBranches() {
		var divs = document.getElementsByTagName('div');
		for (var i=0; i < divs.length; i++) {
			if (divs[i].id.indexOf('brn') == 0) divs[i].style.display = '';
		}
		var imgs = document.getElementsByTagName('img');
		for (var i=0; i < imgs.length; i++) {
			if (imgs[i].id.indexOf('tgl') == 0) {
				imgs[i].src = '$stylePath/nav_minus.png';
				imgs[i].title = '$lng->{tpcBrnCollap}';
				imgs[i].alt = '-';
			}
		}
	}
$m->{cdataEnd}</script>\n
EOSCRIPT
;

# Get minimal version of all topic posts
my $sameTopic = $topicId == $user->{lastTopicId};
my $topicReadTime = $sameTopic ? $user->{lastTopicTime} : $topic->{lastReadTime};
my $lowestUnreadTime = $m->max($topicReadTime, $user->{fakeReadTime}, 
	$m->{now} - $cfg->{maxUnreadDays} * 86400);
my $posts = $m->fetchAllHash("
	SELECT id, parentId,
		postTime > $user->{prevOnTime} AS new,
		postTime > $lowestUnreadTime AS unread
	FROM $cfg->{dbPrefix}posts
	WHERE topicId = $topicId
	ORDER BY postTime");

# Build post lookup tables
our %postsById = map(($_->{id} => $_), @$posts);  # Posts by id - hash of hashrefs
our %postsByParent = ();  # Posts by parent id - hash of arrayrefs of hashrefs
push @{$postsByParent{$_->{parentId}}}, $_ for @$posts; 

# Determine page numbers and collect IDs of new or unread posts
our $postsPP = $m->min($user->{postsPP}, $cfg->{maxPostsPP}) || $cfg->{maxPostsPP};
our $postPos = 0;
our $firstUnrPostPage = undef;
our $firstNewPostPage = undef;
our $firstUnrPostId = undef;
our $firstNewPostId = undef;
our @newUnrPostIds = ();
our $basePost = $postsById{$topic->{basePostId}};
preparePost($basePost->{id});
sub preparePost
{
	my $postId = shift();

	# Shortcuts
	my $post = $postsById{$postId};
	
	# Assign page numbers to posts
	$post->{page} = int($postPos / $postsPP) + 1;

	# Set current page to a requested post's page	
	$page = $post->{page} if $postId == $targetPostId;

	# Determine first unread post and its page
	if (!$page && !$firstUnrPostPage && $post->{unread}) {
		$firstUnrPostPage = $post->{page};
		$firstUnrPostId = $postId;
	}

	# Determine first new post and its page
	if (!$page && !$firstNewPostPage && $post->{new}) {
		$firstNewPostPage = $post->{page};
		$firstNewPostId = $postId;
	}

	# Add new/unread post ID to list
	push @newUnrPostIds, $postId if $userId && ($post->{new} || $post->{unread});

	# Recurse through children
	$postPos++;
	for my $child (@{$postsByParent{$postId}}) {
		$child->{id} != $postId or $m->printError("Integrity Error", "Post is its own parent?!");
		preparePost($child->{id});
	}
}

# Jump to first unread post if available, to first new post otherwise
our $firstNewUnrPostId = undef;
if ($userId && !$page) {
	$page = $firstUnrPostPage || $firstNewPostPage ;
	$firstNewUnrPostId = $firstUnrPostId || $firstNewPostId;
}

# Get the full content of those posts that are on the current page
# Note: full posts are not copied to @$posts and %postsByParent
$page ||= 1;
my $pagePostIdsStr = join(",", map($_->{page} == $page ? $_->{id} : (), @$posts));
$pagePostIdsStr or $m->paramError($lng->{errPstNotFnd});
my $pagePosts = $m->fetchAllHash("
	SELECT posts.*, 
		posts.postTime > $user->{prevOnTime} AS new,
		posts.postTime > $lowestUnreadTime AS unread,
		users.userName, users.title AS userTitle, 
		users.postNum AS userPostNum,	users.avatar, users.signature,
		boardAdmins.userId IS NOT NULL AS boardAdmin,
		userIgnores.userId IS NOT NULL AS ignored
	FROM $cfg->{dbPrefix}posts AS posts
		LEFT JOIN $cfg->{dbPrefix}users AS users
			ON users.id = posts.userId
		LEFT JOIN $cfg->{dbPrefix}boardAdmins AS boardAdmins
			ON boardAdmins.userId = posts.userId
			AND boardAdmins.boardId = $boardId
		LEFT JOIN $cfg->{dbPrefix}userIgnores AS userIgnores
			ON userIgnores.userId = $userId
			AND userIgnores.ignoredId = posts.userId
	WHERE posts.id IN ($pagePostIdsStr)");
for my $post (@$pagePosts) { 
	$post->{page} = $page;
	$postsById{$post->{id}} = $post;
}
$basePost = $postsById{$topic->{basePostId}};

# Remove ignored posts from @newUnrPostIds
@newUnrPostIds = grep(!$postsById{$_}{ignored}, @newUnrPostIds) if !$reveal;

# Mark branches that shouldn't be auto-collapsed
if ($autoCollapsing) {
	for (@newUnrPostIds) {
		my $post = $postsById{$_};
		while ($post = $postsById{$post->{parentId}}) {
			last if $post->{noCollapse};
			$post->{noCollapse} = 1;
		}
	}

	if ($targetPostId) {
		my $post = $postsById{$targetPostId};
		while ($post = $postsById{$post->{parentId}}) {
			last if $post->{noCollapse};
			$post->{noCollapse} = 1;
		}
	}
}

# Get attachments
if ($board->{attach}) {
	my $attachments = $m->fetchAllHash("
		SELECT * 
		FROM $cfg->{dbPrefix}attachments
		WHERE postId IN ($pagePostIdsStr)
		ORDER BY webImage, id");
	push @{$postsById{$_->{postId}}{attachments}}, $_ for @$attachments;
}

# GeoIP
our $geoIp = undef;
our %geoCache;
if ($cfg->{geoIp}) {
	if (eval { require Geo::IP }) {
		$geoIp = Geo::IP->open($cfg->{geoIp});
	}
	elsif (eval { require Geo::IP::PurePerl }) {
		$geoIp = Geo::IP::PurePerl->open($cfg->{geoIp});
	}
}

# Google highlighting
my ($googleWords) = $m->{env}{referrer} =~ /www\.google.*?q=(.*?)(?:&|$)/;
if ($googleWords && $googleWords !~ /^related:/) {
	$googleWords = s!\+! !g;
	$googleWords = s!%([0-9a-fA-F]{2})!chr hex $1!eg;
	$hilite = $googleWords;
}

# Highlighting
our @hiliteWords = ();
if ($hilite) {
	# Escape regexp characters
	$hilite =~ s!([\(\)\[\]\{\}\.\*\+\?\^\$\|\\])!\\$1!g;

	# Split string and weed out stuff that could break entities
	@hiliteWords = split(' ', $hilite);
	@hiliteWords = grep(length > 2, @hiliteWords);
	@hiliteWords = grep(!/^(?:amp|quot|quo|uot|160)$/, @hiliteWords);
}

# Poll shortcuts
my $polls = $cfg->{polls};
my $canPoll = ($polls == 2 && $boardAdmin || $polls == 1)
	&& ($userId && $userId == $basePost->{userId} || $boardAdmin);

# Page links
our $postNum = $topic->{postNum};
my @pageLinks = ();
my $pageNum = int($postNum / $postsPP) + ($postNum % $postsPP != 0);
if ($pageNum > 1) {
	my $prevPage = $page - 1;
	my $nextPage = $page + 1;
	my $maxPageNum = $m->min($pageNum, 8);
	push @pageLinks, { url => $m->url('topic_show', tid => $topicId, pg => $_), 
		txt => $_, dsb => $_ == $page }
		for 1 .. $maxPageNum;
	push @pageLinks, { txt => "..." }, { 
		url => $m->url('topic_show', tid => $topicId, pg => $pageNum), 
		txt => $pageNum, dsb => $pageNum == $page }
		if $maxPageNum + 1 < $pageNum;
	push @pageLinks, { url => $m->url('topic_show', tid => $topicId, pg => $prevPage), 
		txt => 'comPgPrev', dsb => $page == 1 };
	push @pageLinks, { url => $m->url('topic_show', tid => $topicId, pg => $nextPage), 
		txt => 'comPgNext', dsb => $page == $pageNum };
}

# Navigation button links
my @navLinks = ();
push @navLinks, { url => $m->url('prevnext', tid => $topicId, dir => 'prev'), 
	txt => 'tpcPrev', ico => 'prev' }
	if !$blog;
push @navLinks, { url => $m->url('prevnext', tid => $topicId, dir => 'next'), 
	txt => 'tpcNext', ico => 'next' }
	if !$blog;
push @navLinks, { url => $m->url('board_show', bid => $boardId, tid => $topicId, 
	tgt => "tid$topicId"), txt => 'comUp', ico => 'up' };

# User button links
my @userLinks = ();
push @userLinks, { url => $m->url('poll_add', tid => $topicId), txt => 'tpcPolAdd', ico => 'poll' }
	if !$poll && $canPoll && !$topic->{locked};
push @userLinks, { url => $m->url('topic_tag', tid => $topicId), txt => 'tpcTag', ico => 'tag' }
	if !$blog
	&& ($userId && $userId == $basePost->{userId} || $boardAdmin)
	&& ($cfg->{allowTopicTags} == 2 || $cfg->{allowTopicTags} == 1 && $boardAdmin);
push @userLinks, { url => $m->url('topic_subscribe', tid => $topicId), 
	txt => 'tpcSubs', ico => 'subscribe' }
	if !$blog && $userId && $cfg->{subscriptions};
push @userLinks, { url => $m->url('forum_overview', act => 'new', tid => $topicId), 
	txt => 'comShowNew', ico => 'shownew' }
	if !$blog && $userId;
push @userLinks, { url => $m->url('forum_overview', act => 'unread', tid => $topicId), 
	txt => 'comShowUnr', ico => 'showunread' }
	if !$blog && $userId;
push @userLinks, { url => $m->url('forum_overview', act => 'todo', tid => $topicId), 
	txt => 'comShowTdo', ico => 'todo' }
	if !$blog && $userId;
	
# Admin button links	
my @adminLinks = ();
if ($boardAdmin) {
	push @adminLinks, { url => $m->url('topic_stick', tid => $topicId, 
		act => $topic->{sticky} ? 'unstick' : 'stick', auth => 1), 
		txt => $topic->{sticky} ? 'tpcAdmUnstik' : 'tpcAdmStik', ico => 'stick' }
		if !$blog;
	push @adminLinks, { url => $m->url('topic_lock', tid => $topicId, 
		act => $topic->{locked} ? 'unlock' : 'lock', auth => 1), 
		txt => $topic->{locked} ? 'tpcAdmUnlock' : 'tpcAdmLock', ico => 'lock' };
	push @adminLinks, { url => $m->url('topic_move', tid => $topicId), 
		txt => 'tpcAdmMove', ico => 'move' }
		if !$blog;
	push @adminLinks, { url => $m->url('topic_merge', tid => $topicId), 
		txt => 'tpcAdmMerge', ico => 'merge' }
		if !$blog;
	push @adminLinks, { url => $m->url('user_confirm', script => 'topic_delete', tid => $topicId,
		notify => ($basePost->{userId} != $userId ? 1 : 0), name => $topic->{subject}), 
		txt => 'tpcAdmDelete', ico => 'delete' };
}

# Print page bar
our $url = $m->url('forum_show', tgt => "cid" . $board->{categoryId} );
my $categStr = $blog ? "" : "<a href='$url'>$board->{categTitle}</a> / ";
$url = $m->url('board_show', bid => $boardId, tid => $topicId, tgt => "tid$topicId");
my $boardStr = "<a href='$url'>$board->{title}</a> / ";
my $lockStr = $topic->{locked} ? " $lng->{tpcLocked}" : "";
my $pageStr = $page > 1 ? " ($lng->{comPgTtl} $page)" : "";
my $hitStr = $cfg->{topicHits} ? " ($topic->{hitNum} $lng->{tpcHits})" : "";
$m->printPageBar(
	mainTitle => $blog ? $lng->{tpcBlgTitle} : $lng->{tpcTitle}, 
	subTitle => $categStr . $boardStr . "<b>" . $topic->{subject} . "</b>"  . $lockStr . $pageStr . $hitStr, 
	navLinks => \@navLinks, pageLinks => \@pageLinks, userLinks => \@userLinks, 
	adminLinks => \@adminLinks);

# Print poll
if ($poll && $polls) {
	# Print poll header
	my $lockedStr = $poll->{locked} ? $lng->{tpcPolLocked} : "";
	print
		"<div class='frm pol'>\n",
		"<div class='hcl'>\n",
		"<span class='htt'>$lng->{tpcPolTtl}</span>\n",
		"$poll->{title} $lockedStr\n",
		"</div>\n",
		"<div class='ccl'>\n";

	# Check if user already voted
	my $voted = $m->fetchArray("
		SELECT userId FROM $cfg->{dbPrefix}pollVotes WHERE pollId = $pollId AND userId = $userId") 
		? 1 : 0;

	# Print results
	if ($voted || $poll->{multi} || $showResults || !$userId || !$boardWritable 
		|| $topic->{locked} || $poll->{locked}) {

		my $options = undef;
		my $voteSum = undef;

		if ($poll->{locked}) {
			# Get consolidated results
			$options = $m->fetchAllHash("
				SELECT id, title, votes 
				FROM $cfg->{dbPrefix}pollOptions 
				WHERE pollId = $pollId
				ORDER BY id");

			# Get sum of votes
			$voteSum = $m->fetchArray("
				SELECT SUM(votes) FROM $cfg->{dbPrefix}pollOptions WHERE pollId = $pollId") || 1;
		}
		else {
			# Get results from votes
			$options = $m->fetchAllHash("
				SELECT pollOptions.id, pollOptions.title,
					COUNT(pollVotes.optionId) AS votes
				FROM $cfg->{dbPrefix}pollOptions AS pollOptions
					LEFT JOIN $cfg->{dbPrefix}pollVotes AS pollVotes
						ON pollVotes.pollId = $pollId
						AND pollVotes.optionId = pollOptions.id
				WHERE pollOptions.pollId = $pollId
				GROUP BY pollOptions.id, pollOptions.title");

			# Get sum of votes
			$voteSum = $m->fetchArray("
				SELECT COUNT(*) FROM $cfg->{dbPrefix}pollVotes WHERE pollId = $pollId") || 1;
		}

		# Print results
		print	"<table class='plr'>\n";

		for my $option (@$options) {
			my $votes = $option->{votes};
			my $percent = sprintf("%.0f", $votes / $voteSum * 100);
			my $width = $percent * 4;
			print	
				"<tr>\n",
				"<td class='plo'>$option->{title}</td>\n",
				"<td class='plv'>$votes</td>\n",
				"<td class='plp'>$percent\%</td>\n",
				"<td class='plg'><img class='plb' src='$stylePath/poll_bar.png'",
				" style='width: ${width}px' alt=''/></td>\n",
				"</tr>\n";
		}

		print	"</table>\n";
	}
	
	# Print poll form
	if ((!$voted || $poll->{multi})
		&& (!$showResults && $userId && $boardWritable 
		&& !$topic->{locked} && !$poll->{locked})) {
			
		# Get poll options
		my $options = $m->fetchAllHash("
			SELECT id, title 
			FROM $cfg->{dbPrefix}pollOptions 
			WHERE pollId = $pollId
			ORDER BY id");
		
		# Get user's votes to disable options in multi-vote polls
		my $votes = $m->fetchAllArray("
			SELECT optionId FROM $cfg->{dbPrefix}pollVotes WHERE pollId = $pollId AND userId = $userId");
		
		print
			"<form action='poll_vote$m->{ext}' method='post'>\n",
			"<div>\n";
	
		# Print poll options
		for my $option (@$options) {
			my $disabled = "";
			for my $vote (@$votes) { 
				$disabled = "disabled='disabled' checked='checked'", last if $vote->[0] == $option->{id} 
			}

			if ($poll->{multi}) {
				print
					"<label><input type='checkbox' name='option_$option->{id}' $disabled/>",
					" $option->{title}</label><br/>\n";
			}
			else {
				print
					"<label><input type='radio' name='option' value='$option->{id}'/>",
					" $option->{title}</label><br/>\n";
			}
		}

		$url = $m->url('topic_show', tid => $topicId, results => 1);	
		print
			"<br/>",
			$m->submitButton('tpcPolVote', 'poll'),
			$poll->{multi} ? "" 
				: "<a href='$url'>$lng->{tpcPolShwRes}</a>\n",
			"<input type='hidden' name='tid' value='$topicId'/>\n",
			$m->stdFormFields(),
			"</div>\n",
			"</form>\n";
	}

	print "</div>\n";

	# Print lock poll button
	my @btlLines = ();
	if ($canPoll && !$poll->{locked}) {
		$url = $m->url('poll_lock', tid => $topicId, auth => 1);
		push @btlLines,
			"<a href='$url' title='$lng->{tpcPolLockTT}'>$lng->{tpcPolLock}</a>\n";
	}

	# Print delete poll button
	if ($canPoll && (!$poll->{locked} || $boardAdmin)) {
		$url = $m->url('user_confirm', tid => $topicId, pollId => $pollId, script => 'poll_delete',
			auth => 1, name => $poll->{title});
		push @btlLines,
			"<a href='$url' title='$lng->{tpcPolDelTT}'>$lng->{tpcPolDel}</a>\n";
	}

	# Print button cell if not empty
	print
		"<div class='bcl'>\n",
		@btlLines,
		"</div>\n"
		if @btlLines;

	print "</div>\n\n";
}

# Shortcuts
our $showAvatars = $cfg->{avatars} && $user->{showAvatars};

# Determine position number of first and last posts on current page
our $firstPostPos = $postsPP * ($page - 1);
our $lastPostPos = $postsPP ? $postsPP * $page - 1 : @$posts - 1;

# Recursively print posts
$postPos = 0;
printPost($basePost->{id}, 0);
sub printPost
{
	my $postId = shift();
	my $depth = shift();

	# Shortcuts
	my $post = $postsById{$postId};
	my $postUserId = $post->{userId};
	my $childNum = @{$postsByParent{$postId}};

	# Branch collapsing flags
	my $printBranchToggle = !$flat && $childNum && $post->{page} == $page;
	my $collapsed = $autoCollapsing && @newUnrPostIds && !$post->{noCollapse} ? 1 : 0;

	# Print if on current page
	if ($post->{page} == $page) {
		# Shortcuts
		my $parentId = $post->{parentId};
		my $indent = $flat ? 0 : $m->min(70, $user->{indent} * $depth);

		# Print post
		if ((!$post->{ignored} || $reveal)
			&& ($post->{approved} || $boardAdmin || $userId && $userId == $postUserId)) {
				
			# Format times
			my $postTimeStr = $m->formatTime($post->{postTime}, $user->{timezone});
			my $editTimeStr = undef;
			if ($post->{editTime}) {
				$editTimeStr = $m->formatTime($post->{editTime}, $user->{timezone});
				$editTimeStr = "<em>$editTimeStr</em>" 
					if $post->{editTime} > $user->{prevOnTime} && !$post->{new};
				$editTimeStr = "<span class='htt'>$lng->{tpcEdited}</span> $editTimeStr\n";
			}
			
			# Format username
			$url = $m->url('user_info', uid => $postUserId);
			my $userNameStr = $post->{userName} || $post->{userNameBak} || " - ";

			# TUSK begin changing the username so it is a full name
			if ($userNameStr ne " - " && $userNameStr ne "anonymous") {
			    my $userNameStrQ = $m->dbQuote($userNameStr);
			    $userNameStr = $m->fetchArray("SELECT realName FROM $cfg->{dbPrefix}users WHERE userName = $userNameStrQ");
			}
			# TUSK end

			$userNameStr = "<a href='$url'>$userNameStr</a>" if $postUserId > -1;
			$userNameStr = "<span title='$lng->{tpcBrdAdmTT}'>@</span>" . $userNameStr 
				if $post->{boardAdmin} && $cfg->{boardAdminAmp};
			$userNameStr .= " " . $m->formatUserTitle($post->{userTitle})
				if $post->{userTitle} && $user->{showDeco};
			$userNameStr .= " " . $m->formatUserRank($post->{userPostNum})
				if @{$cfg->{userRanks}} && !$post->{userTitle} && $user->{showDeco};
			
			# Format GeoIP flag
			if ($geoIp) {
				my $code = $geoCache{$post->{ip}};
				if (!defined($code)) {
					$code = lc($geoIp->country_code_by_addr($post->{ip})) || "";
					$geoCache{$post->{ip}} = $code;
				}
				$code = "" if $code && $code eq $cfg->{geoIpSkip};
				if ($code) {
					my $country = $geoCache{$code};
					if (!defined($country)) {
						$country = $geoIp->country_name_by_addr($post->{ip}) || "";
						$country =~ s/'/&#39;/g;
						$geoCache{$code} = $country;
					}
					$userNameStr .= " <img class='flg' src='$cfg->{dataPath}/flags/$code.png'"
					. " alt='[$code]' title='$country'/>";
				}
			}
			
			# Format misc values
			$m->dbToDisplay($board, $post);
			my $pstClasses = "frm pst";
			$pstClasses .= " new" if $post->{postTime} > $user->{prevOnTime};
			$pstClasses .= " tgt" if $postId == $targetPostId;
			my $invisImg = !$post->{approved} ? " <img class='ico' src='$m->{stylePath}/post_i.png'"
				. " title='$lng->{tpcInvisTT}' alt='$lng->{tpcInvis}'/> " : "";
				
			# Highlight search keywords
			if (@hiliteWords) {
				$post->{body} = ">$post->{body}<";
				$post->{body} =~ s|>(.*?)<|
					my $text = $1;
					eval { $text =~ s!($_)!<em>$1</em>!gi } for @hiliteWords;
					">$text<";
				|egs;
				$post->{body} = substr($post->{body}, 1, -1);
			}

			# Determine variable post icon attributes
			my $imgSrc; 
			my $imgTitle = "";
			my $imgAlt = "";
			if (!$userId) { $imgSrc = "post_ou" }
			else {
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
			}
			my $imgAttr = "src='$stylePath/$imgSrc.png' title='$imgTitle' alt='$imgAlt'";

			# Print post header
			print
				"<div class='$pstClasses' id='pid$postId' style='margin-left: $indent%'>\n",
				"<div class='hcl'>\n",
				"<span class='nav'>\n";

			# Print navigation buttons
			if (!$flat) {
				if (($post->{unread} || $post->{new} || $postPos == $firstPostPos) 
					&& @newUnrPostIds && @newUnrPostIds < $postNum && $postNum > 2 
					&& $postId != $newUnrPostIds[-1]) {
						
					# Print goto next new/unread post button
					my $nextPostId = undef;
					if ($postPos == 0) { $nextPostId = $newUnrPostIds[0] }
					else {
						for my $i (0 .. @newUnrPostIds) { 
							if ($newUnrPostIds[$i] == $postId) {
								$nextPostId = $newUnrPostIds[$i+1];
								last;
							}
						}
					}
					if ($nextPostId) {
						$url = $postsById{$nextPostId}{page} == $page ? "#pid$nextPostId" 
							: $m->url('topic_show', tid => $topicId, pid => $nextPostId, tgt => "pid$nextPostId");
						print
							"<a href='$url'><img class='ico' src='$stylePath/post_nn.png'",
							" title='$lng->{tpcNxtPstTT}' alt='$lng->{tpcNxtPst}'/></a>\n";
					}
				}

				# Print jump to parent post button
				$url = $postsById{$parentId}{page} == $page	? "#pid$parentId" 
					: $m->url('topic_show', tid => $topicId, pid => $parentId, tgt => "pid$parentId");
				print
					"<a href='$url'><img class='ico' src='$stylePath/nav_up.png'",
					" title='$lng->{tpcParentTT}' alt='$lng->{tpcParent}'/></a>\n"
					if $parentId;
			}
			elsif ($postPos == 0 && @newUnrPostIds && @newUnrPostIds < $postNum && $postNum > 2) {
				# Print one goto new/unread post button in non-threaded boards
				my ($nextPostId) = @newUnrPostIds;
				my $url = $postsById{$nextPostId}{page} == $page ? "#pid$nextPostId" 
					: $m->url('topic_show', tid => $topicId, pid => $nextPostId, tgt => "pid$nextPostId");
				print
					"<a href='$url'><img class='ico' src='$stylePath/post_nn.png'",
					" title='$lng->{tpcNxtPstTT}' alt='$lng->{tpcNxtPst}'/></a>\n";
			}

			print "</span>\n";

			# Print branch toggle icon
			if ($printBranchToggle) {
				my $img = $collapsed ? 'nav_plus' : 'nav_minus';
				my $alt = $collapsed ? '+' : '-';
				print 
					"<img class='ico' id='tgl$postId' src='$stylePath/$img.png'",
					" onclick='mwfToggleBranch($postId)' ondblclick='mwfExpandAllBranches()'",
					" title='$lng->{tpcBrnCollap}' alt='$alt'/>\n";
			}

			$url = $m->url('topic_show', pid => $postId, tgt => "pid$postId");
			print
				$postId == $firstNewUnrPostId	? "<a id='fp'></a>" : "",
				"<a href='$url'><img class='ico' $imgAttr/></a>\n",
				$invisImg,
				$postUserId > -2 ? "<span class='htt'>$lng->{tpcBy}</span> $userNameStr\n" : "",
				"<span class='htt'>$lng->{tpcOn}</span> $postTimeStr\n", 
				$editTimeStr;
			
			# Print IP
			print "<span class='htt'>IP</span> $post->{ip}\n" 
				if $cfg->{showPostIp} == 1 && $boardAdmin && (!$blog || $user->{admin})
				|| $cfg->{showPostIp} == 2 && $userId;
			
			print
				"</div>\n",
				"<div class='ccl'>\n";

			# Print avatar
			print
				"<img class='ava' src='$cfg->{attachUrlPath}/avatars/$post->{avatar}' alt=''/>\n"
				if $showAvatars && $post->{avatar};

			# Print body
			print 
				$post->{body}, "\n",
				"</div>\n";

			# Print reply button
			my @btlLines = ();
			if (($boardWritable && !$topic->{locked} || $boardAdmin) && $postUserId != -2) {
				$url = $m->url('post_add', pid => $postId);
				push @btlLines, $m->buttonLink($url, 'tpcReply', 'write');
			}

			# Print reply with quote button
			if (($boardWritable && !$topic->{locked} || $boardAdmin)
				&& $cfg->{quote} && ($flat || $cfg->{quote} == 2)
				&& $postUserId != -2) {
				$url = $m->url('post_add', pid => $postId, quote => 1);
				push @btlLines, $m->buttonLink($url, 'tpcQuote', 'write');
			}

			# Print edit button
			if ($userId && $userId == $postUserId && !$topic->{locked} || $boardAdmin) {
				$url = $m->url('post_edit', pid => $postId);
				push @btlLines, $m->buttonLink($url, 'tpcEdit', 'edit');
			}

			# Print delete button
			if ($userId && $userId == $postUserId && !$topic->{locked} || $boardAdmin) {
				$url = $m->url('user_confirm', script => 'post_delete', pid => $postId, 
					notify => ($postUserId != $userId ? 1 : 0), name => $postId);
				push @btlLines, $m->buttonLink($url, 'tpcDelete', 'delete');
			}

			# Print attach button
			if (($userId && $userId == $postUserId && !$topic->{locked} || $boardAdmin)
				&& ($board->{attach} == 1 || $board->{attach} == 2 && $boardAdmin)
				&& $postUserId != -2) {
				$url = $m->url('post_attach', pid => $postId);
				push @btlLines, $m->buttonLink($url, 'tpcAttach', 'attach');
			}

			# Print todo button
			if ($userId && !$blog && $postUserId != -2) {
				$url = $m->url('todo_add', pid => $postId);
				push @btlLines, $m->buttonLink($url, 'tpcTodo', 'todo');
			}

			# Print report button
			if ($userId && $userId != $postUserId && !$blog && $postUserId != -2) {
				$url = $m->url('report_add', pid => $postId);
				push @btlLines, $m->buttonLink($url, 'tpcReport', 'report');
			}

			# Print branch button
			if ($boardAdmin && !$flat && $post->{parentId} && !$blog && $postUserId != -2) {
				$url = $m->url('branch_admin', pid => $postId);
				push @btlLines, $m->buttonLink($url, 'tpcBranch', 'branch');
			}

			# Print approve button
			if ($boardAdmin && !$post->{approved} && !$blog && $postUserId != -2) {
				$url = $m->url('post_approve', pid => $postId, auth => 1);
				push @btlLines, $m->buttonLink($url, 'tpcApprv', 'approve');
			}

			# Print button cell if there're button links
			print
				"<div class='bcl'>\n",
				@btlLines,
				"</div>\n"
				if @btlLines;

			print "</div>\n\n";
		}
		else {
			# Print hidden post bar
			my $reason = "";
			$reason .= $lng->{tpcHidIgnore} if $post->{ignored};
			$reason .= $lng->{tpcHidUnappr} if !$post->{approved};
			$url = $m->url('topic_show', tid => $topicId, pid => $postId, rvl => 1, tgt => "pid$postId");

			print
				"<div class='frm hps' style='margin-left: $indent%'>\n",
				"<div class='hcl'>\n",
				"<a id='pid$postId'></a>\n";

			print
				"<a href='$url' title='$lng->{tpcRevealTT}'>"
				if $post->{approved} || $user->{admin};

			print "$lng->{tpcHidTtl} $reason";

			print "</a>\n" if $post->{approved} || $user->{admin};

			print 
				"</div>\n",
				"</div>\n\n";
		}
	}

	# Print div for branch collapsing
	if ($printBranchToggle) {
		print "<div id='brn$postId'>";
		print "<script type='text/javascript'>",
			"document.getElementById('brn$postId').style.display = 'none'</script>" 
			if $collapsed;
		print "\n";
	}
	
	# Print children recursively
	$postPos++;
	for my $child (@{$postsByParent{$postId}}) {
		return if $postPos > $lastPostPos && !$printBranchToggle;
		$child->{id} != $postId or $m->printError("Integrity Error", "Post is its own parent?!");
		printPost($child->{id}, $depth + 1);
	}

	print "</div>\n" if $printBranchToggle;
}

# Repeat page bar
$m->printPageBar(repeat => 1);

# Update topic read data
if ($userId && !$sameTopic) {
	# Transaction
	$m->dbBegin();
	eval {
		if ($topic->{lastPostTime} > $lowestUnreadTime) {
			# Replace topic's last read time
			$m->dbDo("
				DELETE FROM $cfg->{dbPrefix}topicReadTimes 
				WHERE topicId = $topicId 
					AND userId = $userId");
			$m->dbDo("
				INSERT INTO $cfg->{dbPrefix}topicReadTimes (topicId, userId, lastReadTime)
				VALUES ($topicId, $userId, $m->{now})");
		}
	
		# Update user stats
		my $lastTopicTime = $topic->{lastReadTime} || 0;
		$m->dbDo("
			UPDATE $cfg->{dbPrefix}users SET 
				lastTopicId = $topicId,
				lastTopicTime = $lastTopicTime
			WHERE id = $userId");
	};
	$@ ? $m->dbRollback() : $m->dbCommit();
}

# Update topic hit stats
$m->dbDo("
	UPDATE $cfg->{dbPrefix}topics SET hitNum = hitNum + 1 WHERE id = $topicId") 
	if $cfg->{topicHits};

# Log action
$m->logAction(2, 'topic', 'show', $userId, $boardId, $topicId);

# Print footer
$m->printFooter(undef, undef, $boardId);
