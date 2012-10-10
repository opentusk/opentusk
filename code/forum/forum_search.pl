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
my ($m, $cfg, $lng, $user) = MwfMain->new(@_);
my $userId = $user->{id};

# Check if access should be denied
$m->checkBan($userId) if $cfg->{banViewing};
$m->checkBlock();

# Check if search is enabled
$cfg->{forumSearch} || $user->{admin} or $m->userError($lng->{errFeatDisbl});

# Print header
$m->printHeader();

# Get CGI parameters
my $page = $m->paramInt('pg') || 1;
my $boardId = $m->paramStrId('board');  # Sanitize later
my $words = $m->paramStr('words');
my $userName = $m->paramStr('user');
my $searchUserId = $m->paramInt('uid');
my $minAge = $m->paramInt('min');
my $maxAge = $m->paramInt('max');
my $field = $m->paramStrId('field') || 'body';
my $sort = $m->paramStrId('sort') || 'time';
my $order = $m->paramStrId('order') || 'desc';
my $showBody = $m->paramBool('body') || $cfg->{showSearchBody};

# Get userName if only userId was specified
$userName = $m->fetchArray("
	SELECT userName FROM $cfg->{dbPrefix}users WHERE id = $searchUserId")
	if $searchUserId;

# Enforce restrictions
$field = 'body' if $field !~ /^body|subject$/;
$sort = 'time' if $sort !~ /^time|user$/;
$order = 'desc' if $order !~ /^asc|desc$/;

# Split and treat keywords early to show user what we don't support anyway
my @words = ();
my $wordsChanged = 0;
if ($cfg->{advSearch}) {
	# Make copy of original search string, but normalize its whitespace
	my $orgWords = $words;
	$orgWords =~ s/\s+/ /g;
	$orgWords =~ s/^\s//g;
	$orgWords =~ s/\s$//g;
	
	# Split and rejoin string, discarding stuff that can't be searched for
	$words =~ s![\+\*\(\)<>~]+! !g;
	@words = $words =~ /-?\"[^\"]+\"|-?[^\s\+\*\(\)<>~\[\]\{\}\^\$\@\%\'\?\|\.\\\/&=,;:`´]+/g;
#`
	@words = grep(length > 2, @words);
	my $stopwordRx = join("\$|^", defined($cfg->{stopWords}) ? @{$cfg->{stopWords}} : qw(able about above according accordingly across actually after afterwards again against ain't all allow allows almost alone along already also although always am among amongst an and another any anybody anyhow anyone anything anyway anyways anywhere apart appear appreciate appropriate are aren't around as aside ask asking associated at available away awfully be became because become becomes becoming been before beforehand behind being believe below beside besides best better between beyond both brief but by c'mon c's came can can't cannot cant cause causes certain certainly changes clearly co com come comes concerning consequently consider considering contain containing contains corresponding could couldn't course currently definitely described despite did didn't different do does doesn't doing don't done down downwards during each edu eg eight either else elsewhere enough entirely especially et etc even ever every everybody everyone everything everywhere ex exactly example except far few fifth first five followed following follows for former formerly forth four from further furthermore get gets getting given gives go goes going gone got gotten greetings had hadn't happens hardly has hasn't have haven't having he he's hello help hence her here here's hereafter hereby herein hereupon hers herself hi him himself his hither hopefully how howbeit however i'd i'll i'm i've ie if ignored immediate in inasmuch inc indeed indicate indicated indicates inner insofar instead into inward is isn't it it'd it'll it's its itself just keep keeps kept know knows known last lately later latter latterly least less lest let let's like liked likely little look looking looks ltd mainly many may maybe me mean meanwhile merely might more moreover most mostly much must my myself name namely nd near nearly necessary need needs neither never nevertheless new next nine no nobody non none noone nor normally not nothing novel now nowhere obviously of off often oh ok okay old on once one ones only onto or other others otherwise ought our ours ourselves out outside over overall own particular particularly per perhaps placed please plus possible presumably probably provides que quite qv rather rd re really reasonably regarding regardless regards relatively respectively right said same saw say saying says second secondly see seeing seem seemed seeming seems seen self selves sensible sent serious seriously seven several shall she should shouldn't since six so some somebody somehow someone something sometime sometimes somewhat somewhere soon sorry specified specify specifying still sub such sup sure t's take taken tell tends th than thank thanks thanx that that's thats the their theirs them themselves then thence there there's thereafter thereby therefore therein theres thereupon these they they'd they'll they're they've think third this thorough thoroughly those though three through throughout thru thus to together too took toward towards tried tries truly try trying twice two un under unfortunately unless unlikely until unto up upon us use used useful uses using usually value various very via viz vs want wants was wasn't way we we'd we'll we're we've welcome well went were weren't what what's whatever when whence whenever where where's whereafter whereas whereby wherein whereupon wherever whether which while whither who who's whoever whole whom whose why will willing wish with within without won't wonder would would wouldn't yes yet you you'd you'll you're you've your yours yourself yourselves zero));
	@words = grep(!/^$stopwordRx$/i, @words);
	$words = join(" ", @words);
	
	# If string got changed (except for whitespace changes), show notice
	$wordsChanged = 1 if $orgWords ne $words;
}

# Preserve parameters in links
my @params = (words => $words, user => $userName, min => $minAge, max => $maxAge,
	board => $boardId, field => $field, sort => $sort, order => $order, body => $showBody);

# Escape search strings
my $wordsEsc = $m->escHtml($words);
my $userNameEsc = $m->escHtml($userName);

# TUSK begin changed the way that visible boards are retrieved.
# Get visible boards
my $boards = Forum::ForumKey::getViewableBoardsHash($m, $user);
# TUSK end

@$boards or $m->userError($lng->{errAuthz});
my $boardIdsStr = join(",", map($_->{id}, @$boards));

# Determine checkbox and listbox states
my %state = (
	$boardId => "selected='selected'",
	$field => "selected='selected'",
	$sort => "selected='selected'",
	$order => "selected='selected'",
	showBody => $showBody ? "checked='checked'" : undef,
);

# Only count as submitted if words or username are specified
my $submitted = length($words) > 0 && $words !~ /^[\"\s]+$/ || length($userName) > 0;

# Search
my $posts = [];
my $pagePostIdsStr = "";
my @pageLinks = ();
if ($submitted) {
	# Limit to user
	if ($userName) {
		my $userNameQ = $m->dbQuote($userName);
		$searchUserId = $m->fetchArray("
			SELECT id FROM $cfg->{dbPrefix}users WHERE userName = $userNameQ");
		$searchUserId or $m->userError($lng->{errUsrNotFnd});
	}
	my $userStr = $searchUserId ? "AND posts.userId = $searchUserId" : "";
	
	# Limit to category or board
	my $boardStr = "";
	if ($boardId =~ /^bid(\d+)$/) {
		$boardStr = "AND posts.boardId = $1";
		$boardId = $1;
	} 
	elsif ($boardId =~ /^cid(\d+)$/) {
		$boardStr = "AND boards.categoryId = $1";
		$boardId = 0;
	}
	else { 
		$boardId = 0;
	}

	# Search words
	my $wordStr = "";
	my $subjectStr = "";
	if ($cfg->{advSearch} && $words) {
		for (@words) { 
			$_ = "$_*" if !/^"/;
			$_ = "+$_" if !/^-/;
		}
		my $wordsQ = $m->dbQuote(join(" ", @words));
		my $fieldStr = $field eq 'subject' ? 'topics.subject' : 'posts.body';
		$wordStr = "AND (MATCH $fieldStr AGAINST ($wordsQ IN BOOLEAN MODE))";
	}
	elsif ($words) {
		my $like = $m->{pgsql} ? 'ILIKE' : 'LIKE';
		my $fieldStr = $field eq 'subject' ? 'topics.subject' : 'posts.body';
		my $wordsLike = $m->dbEscLike($words);
		$wordStr = "AND (";
		@words = $wordsLike =~ /"[^"]+"|[^"\s]+/g;
		for my $word (@words) {
			$word =~ s/"//g;
			$word = $m->escHtml($word);
			$word = "$fieldStr $like " . $m->dbQuote("%$word%");
		}
		if (@words) { $wordStr .= join(" AND ", @words) . ")" }
		else { $wordStr = "" }
		$subjectStr = "AND posts.parentId = 0" if $field eq 'subject';
	}

	# Limit to age
	my $minAgeStr = $minAge ? "AND posts.postTime < $m->{now} - $minAge * 86400" : "";
	my $maxAgeStr = $maxAge ? "AND posts.postTime > $m->{now} - $maxAge * 86400" : "";

	# Order
	my $sortStr = 'posts.postTime';
	if ($sort eq 'time') { $sortStr = 'posts.postTime' }
	elsif ($sort eq 'user') { $sortStr = 'posts.userNameBak' }
	my $orderStr = "ORDER BY $sortStr $order";
	$orderStr .= ", posts.postTime DESC" if $order ne 'time';

	# Get ids of posts matching criteria
	$posts = $m->fetchAllArray("
		SELECT posts.id
		FROM $cfg->{dbPrefix}posts AS posts
			INNER JOIN $cfg->{dbPrefix}topics AS topics
				ON topics.id = posts.topicId
			INNER JOIN $cfg->{dbPrefix}boards AS boards	
				ON boards.id = posts.boardId
			LEFT JOIN $cfg->{dbPrefix}users AS users
				ON users.id = posts.userId
		WHERE posts.boardId IN ($boardIdsStr)
			$wordStr
			$subjectStr
			$userStr 
			$minAgeStr
			$maxAgeStr
			$boardStr 
		$orderStr
		LIMIT 500");

	# Page links
	my $postsPP = $showBody ? $user->{postsPP} : $user->{topicsPP};
	my $pageNum = int(@$posts / $postsPP) + (@$posts % $postsPP != 0);
	if ($pageNum > 1) {
		my $prevPage = $page - 1;
		my $nextPage = $page + 1;
		my $maxPageNum = $m->min($pageNum, 8);
		push @pageLinks, { url => $m->url('forum_search', pg => $_, @params), 
			txt => $_, dsb => $_ == $page }
			for 1 .. $maxPageNum;
		push @pageLinks, { txt => "..." }, {
			url => $m->url('forum_search', pg => $pageNum, @params), 
			txt => $pageNum, dsb => $pageNum == $page }
			if $maxPageNum + 1 < $pageNum;
		push @pageLinks, { url => $m->url('forum_search', pg => $prevPage, @params), 
			txt => 'comPgPrev', dsb => $page == 1 };
		push @pageLinks, { url => $m->url('forum_search', pg => $nextPage, @params), 
			txt => 'comPgNext', dsb => $page == $pageNum };
	}

	# Get posts on page
	my @pagePostIds = @$posts[($page-1) * $postsPP .. $m->min($page * $postsPP, scalar @$posts) - 1];
	$pagePostIdsStr = join(",", map($_->[0], @pagePostIds)) || "0";
	$posts = $m->fetchAllHash("
		SELECT posts.id, posts.boardId, posts.topicId, posts.userId, posts.postTime, 
			posts.userNameBak, posts.body,
			topics.subject,
			users.userName
		FROM $cfg->{dbPrefix}posts AS posts
			INNER JOIN $cfg->{dbPrefix}topics AS topics
				ON topics.id = posts.topicId
			INNER JOIN $cfg->{dbPrefix}boards AS boards
				ON boards.id = posts.boardId
			LEFT JOIN $cfg->{dbPrefix}users AS users
				ON users.id = posts.userId
		WHERE posts.id IN ($pagePostIdsStr)
		$orderStr");
}

# Print page bar
my @navLinks = ({ url => $m->url('forum_show'), txt => 'comUp', ico => 'up' });
$m->printPageBar(mainTitle => $lng->{seaTitle}, navLinks => \@navLinks, pageLinks => \@pageLinks);

# Display age 0 as empty string
$minAge = $minAge ? $minAge : "";
$maxAge = $maxAge ? $maxAge : "";

# Show advanced search options?
my $showAdvOpt = $cfg->{showAdvOpt} || $minAge || $maxAge || $field ne 'body' 
	|| $sort ne 'time' || $order ne 'desc' || $showBody ? 'block' : 'none';
my $showAdvLnk = $showAdvOpt eq 'block' ? "style='display: none'" : "";

# Print search keywords form
print
	"<form action='forum_search$m->{ext}' method='get'>\n",
	"<div class='frm'>\n",
	"<div class='hcl'>\n",
	"<span class='htt'>$lng->{seaTtl}</span>\n",
	"</div>\n",
	"<div class='ccl'>\n",
	"$lng->{seaWords}\n",
	"<input type='text' name='words' size='20' maxlength='100' value='$wordsEsc'/>\n",
	"$lng->{seaUser}\n",
	"<input type='text' name='user' size='10' maxlength='$cfg->{maxUserNameLen}' value='$userNameEsc'/>\n",
	"$lng->{seaBoard}\n",
	"<select name='board' size='1'>\n",
	"<option value='0'>$lng->{seaBoardAll}</option>\n";

my $lastCategoryId = 0;
for my $board (@$boards) {
	if ($lastCategoryId != $board->{categoryId}) {
		$lastCategoryId = $board->{categoryId};
		my $sel = $state{"cid$board->{categoryId}"};
		print "<option value='cid$board->{categoryId}' $sel>$board->{categTitle}</option>\n";
	}
	my $sel = $state{"bid$board->{id}"};
	print "<option value='bid$board->{id}' $sel>- $board->{title}</option>\n";
}

print
	"</select>\n",
	$m->submitButton('seaB', 'search'),
	"<script type='text/javascript'>$m->{cdataStart}\n",
	"	function showAdvOpt() { \n",
	"		document.getElementById(\"advLnk\").style.display = 'none'; \n",
	"		document.getElementById(\"advOpt\").style.display = ''; \n",
	"	}\n",
	"$m->{cdataEnd}</script>\n",
	"<a id='advLnk' href='javascript:showAdvOpt()' $showAdvLnk>$lng->{seaAdvOpt} &gt;&gt;</a>\n",
	"<div id='advOpt' style='display: $showAdvOpt; margin-top: 3px'>\n",
	"$lng->{seaMinAge}\n",
	"<input type='text' name='min' size='3' maxlength='4' value='$minAge'/>\n",
	"$lng->{seaMaxAge}\n",
	"<input type='text' name='max' size='3' maxlength='4' value='$maxAge'/>\n",
	"$lng->{seaField}\n",
	"<select name='field' size='1'>\n",
	"<option value='body' $state{body}>$lng->{seaFieldBody}</option>\n",
	"<option value='subject' $state{subject}>$lng->{seaFieldSubj}</option>\n",
	"</select>\n",
	"$lng->{seaSort}\n",
	"<select name='sort' size='1'>\n",
	"<option value='time' $state{time}>$lng->{seaSortTime}</option>\n",
	"<option value='user' $state{user}>$lng->{seaSortUser}</option>\n",
	"</select>\n",
	"$lng->{seaOrder}\n",
	"<select name='order' size='1'>\n",
	"<option value='desc' $state{desc}>$lng->{seaOrderDesc}</option>\n",
	"<option value='asc' $state{asc}>$lng->{seaOrderAsc}</option>\n",
	"</select>\n",
	"<label><input type='checkbox' name='body' value='1' $state{showBody}/>$lng->{seaShowBody}</label>\n",
	"</div>\n",
	$wordsChanged ? "<p>$lng->{seaWordsChng}</p>" : "",
	$m->{sessionId} ? "<input type='hidden' name='sid' value='$m->{sessionId}'/>\n" : "",
	"</div>\n",
	"</div>\n",
	"</form>\n\n";

# Print results
if ($submitted) {
	# Print table header
	print
		"<table class='tbl'>\n",
		"<tr class='hrw'>\n",
		"<th>$lng->{serTopic}</th>\n",
		"<th class='shr'>$lng->{serPoster}</th>\n",
		"<th class='shr'>$lng->{serPosted}</th>\n",
		"</tr>\n";

	# Prepare strings for local highlighting and hl link parameters
	my $hilite = $cfg->{advSearch} ? $words : $wordsEsc;
	if ($cfg->{advSearch}) {
		$hilite =~ s![\*\+\-\"\'\(\)\[\]\{\}\?\!\$\^\|\.~<>:;&%§`´#]! !g;  
		$hilite =~ s! {2,}! !g;
	}
	else { 
		$hilite =~ s!&quot;!!g 
	}

	# Highlighting of post bodies shown on this page
	my @hiliteWords = ();
	if ($showBody && $hilite) {
		# Escape regexp characters
		$hilite =~ s!([\(\)\[\]\{\}\.\*\+\?\^\$\|\\])!\\$1!g;
	
		# Split string and weed out stuff that could break entities
		@hiliteWords = split(' ', $hilite);
		@hiliteWords = grep(length > 2, @hiliteWords);
		@hiliteWords = grep(!/^(?:amp|quot|quo|uot|160)$/, @hiliteWords);
	}

	# Print found posts	
	for my $post (@$posts) {
		# Shortcuts
		my $postId = $post->{id};
		
		# Format output
		my $timeStr = $m->formatTime($post->{postTime}, $user->{timezone});
		my $userNameStr = $post->{userName} || $post->{userNameBak} || " - ";
		my $url = $m->url('user_info', uid => $post->{userId});
		$userNameStr = "<a href='$url'>$userNameStr</a>" if $post->{userId} > -1;
		$m->dbToDisplay({}, $post),
		$url = $m->url('topic_show', pid => $postId, hl => $hilite, tgt => "pid$postId");

		# Highlight keywords
		if ($showBody && @hiliteWords) {
			$post->{body} = ">$post->{body}<";
			$post->{body} =~ s|>(.*?)<|
				my $text = $1;
				eval { $text =~ s!($_)!<em>$1</em>!gi } for @hiliteWords;
				">$text<";
			|egs;
			$post->{body} = substr($post->{body}, 1, -1);
		}
	
		# Print post	
		print
			"<tr class='crw'>\n",
			"<td><a href='$url'>$post->{subject}</a></td>\n",
			"<td class='shr'>$userNameStr</td>\n",
			"<td class='shr'>$timeStr</td>\n",
			"</tr>\n";
			
		print
			"<tr class='crw'>\n",
			"<td colspan='3'>\n",
			$post->{body}, "\n",
			"</td>\n",
			"</tr>\n"
			if $showBody;
	}
	
	# If nothing found, display notification
	print
		"<tr class='crw'>\n",
		"<td colspan='3'>\n",
		"$lng->{serNotFound}\n",
		"</td>\n",
		"</tr>\n",
		if !@$posts;
	
	print	"</table>\n\n";
}

# Log action
my $stringId = $submitted && $cfg->{logSearchWords} && $words ? $m->logString($words) : 0;
$m->logAction($submitted ? 2 : 3, 'forum', 'search', $userId, $boardId, 0, 0, $stringId);

# Print footer
$m->printFooter();
