#!/usr/bin/perl
#------------------------------------------------------------------------------
#    mwForum - Web-based discussion forum
#    Copyright (c) 1999-2001 Markus Wichitill <mwforum@mawic.de>
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#------------------------------------------------------------------------------

use strict;

# Imports
use CGI::Carp qw(fatalsToBrowser);
use DBI;
use Forum::MwfConfig;
use Forum::MwfMain;
use Forum::MwfCGI;

#------------------------------------------------------------------------------

# Get user
connectDb();
authUser();

# Print header
printHeader();

# Check if access should be denied
checkBlock();

# Print search bar
my @bar = (
	"forum_search.pl", "comUp", 1,
);
printBar($lng->{'serTitle'}, "", \@bar);

# Get CGI parameters
my $cgi = new Forum::MwfCGI;
my $boardId = int($cgi->param('board')) || 0;
my $mode = $cgi->param('mode') || 'phrase';
my $words = $cgi->param('words');
my $age = int($cgi->param('age')) || 365;
my $limit = int($cgi->param('limit')) || 100;
my $userId = $cgi->param('uid') ? int($cgi->param('uid')) : undef;
my $userName = $cgi->param('userName');
$words || $userName || $userId or userError($lng->{'errWordEmpty'});

# Get boards
my $query = "SELECT * FROM boards";
my $sth = query($query);
my $boards = $sth->fetchall_arrayref({});
my %boards = ();
for my $board (@$boards) { $boards{$board->{'id'}} = $board }

# Exclude boards from search
my @exclBoardIds = (0);
for my $board (@$boards) { 
	push(@exclBoardIds, $board->{'id'}), next unless boardVisible($board);
	push(@exclBoardIds, $board->{'id'}) if $board->{'anonymous'} and $userName || $userId;
}
my $exclBoardStr = "AND posts.boardId NOT IN (" . join(",", @exclBoardIds) . ")";

# Find user
if ($userName) {
	my $userNameQ = quote($userName);
	$query = "SELECT user_id FROM users WHERE user_id = $userNameQ";
	$sth = query($query);
	$userId = $sth->fetchrow_array();
	$userId or userError($lng->{'errUsrNotFnd'});
}
my $userStr = $userId ? "AND posts.user_id = '$userId'" : "";

# Find board
my $boardStr = $boardId ? "AND posts.boardId = $boardId" : "";

# Find words
my $relevStr = "";
my $wordStr = "";
my $orderStr = " posts.postTime DESC";
if ($mode eq 'phrase' && $words) {
	my $wordsEsc = $words;
	$wordsEsc =~ s!\\!\\\\!;  # Escape escape (quote will escape again)
	$wordsEsc =~ s!_!\\\_!;   # Escape underscore (MySQL simple regex placeholder)
	$wordsEsc =~ s!%!\\\%!;   # Escape percent sign (MySQL simple regex placeholder)
	my $wordsQ = quote("%$wordsEsc%");
	$wordStr = "AND  posts.body LIKE $wordsQ";
}
elsif (($mode eq 'or' || $mode eq 'and') && $words) {
	my $wordsEsc = $words;
	$wordStr = "AND (";
	$wordsEsc =~ s!\\!\\\\!;  # Escape escape (quote will escape again)
	$wordsEsc =~ s!_!\\\_!;   # Escape underscore (MySQL simple regex placeholder)
	$wordsEsc =~ s!%!\\\%!;   # Escape percent sign (MySQL simple regex placeholder)
	my @words = split(' ', $wordsEsc);
	@words or userError($lng->{'errWordEmpty'});
	for my $word (@words) {
		$word = quote("%$word%");
		$word = " posts.body LIKE $word" 
	}
	if ($mode eq "or") { $wordStr .= join(" OR ", @words) }
	elsif ($mode eq "and") { $wordStr .= join(" AND ", @words) }
	$wordStr .= ")";
}
elsif ($mode eq 'relev' && $words) {
	my $wordsQ = quote($words);
	$relevStr = "MATCH posts.body AGAINST ($wordsQ) AS relevance,";
	$wordStr = "AND (MATCH posts.body AGAINST ($wordsQ) > 0)";
	$orderStr = "relevance DESC";
}
elsif ($mode eq 'regex' && $words) {
	my $wordsQ = quote($words);
	$wordStr = "AND posts.body REGEXP $wordsQ";
}

# Other criteria
$age = min(max(1, $age), 9999);
$limit = min(max(1, $limit), 200);
my $now = time();

# Search posts
$query = "
	SELECT posts.id, posts.boardId, posts.topicId, posts.user_id, posts.postTime, 
		posts.userNameBak, $relevStr
		topics.subject,
		u.user_id, concat(u.firstname, ' ', u.lastname) as fullname
	FROM posts, topics
		LEFT JOIN hsdb4.user u  ON u.user_id = posts.user_id 
	WHERE topics.id = posts.topicId
		AND posts.postTime + $age * 86400 > $now 
		$userStr 
		$boardStr 
		$exclBoardStr 
		$wordStr
	ORDER BY $orderStr
	LIMIT $limit";
$sth = query($query);
my $posts = $sth->fetchall_arrayref({});

# Print table header
print
	"<BR>\n\n",
	tableStart(),
	"<TR>\n",
	"<TD><B>$lng->{'serTopic'}</B></TD>\n",
	$mode eq 'relev' ? "<TD WIDTH='15%'><B>$lng->{'serRelev'}</B></TD>\n" : "",
	"<TD WIDTH='15%'><B>$lng->{'serPoster'}</B></TD>\n",
	"<TD WIDTH='15%'><B>$lng->{'serPosted'}</B></TD>\n",
	"</TR>\n\n";

# Prepare highlight parameter
my $hilite = $words ? "&hilite=" . $cgi->url_encode($words) : "";

# Print found posts	
for my $post (@$posts) {
	# Prepare username string
	my $userNameStr = " - ";
	if ($boards{$post->{'boardId'}}{'anonymous'}) {
		$userNameStr = $lng->{'comHidden'};
	}
	else{
	    $userNameStr = "$post->{'fullname'}";
	}

	
	# Prepare other display strings
	$post->{'relevance'} =  "" unless ($post->{'relevance'});
	my $relevStr = substr($post->{'relevance'}, 0, 6);
	my $timeStr = '';
	if ($post->{'postTime'}) {
		$timeStr = formatTime($post->{'postTime'}, $user->{'timezone'}? $user->{'timezone'} : undef);
	}

	# Print post	
	print
		"<TR BGCOLOR='$cfg{'lightCellColor'}'>\n",
		"<TD NOWRAP>",
		"<A HREF='topic_show.pl?tid=$post->{'topicId'}$hilite#$post->{'id'}'>",
		"$post->{'subject'}</A></TD>\n",
		$mode eq 'relev' ? "<TD NOWRAP>$relevStr</TD>\n" : "",
		"<TD NOWRAP>$userNameStr</TD>\n",
		"<TD NOWRAP>$timeStr</TD>\n",
		"</TR>\n\n";
}

# If nothing found, display notification
my $colspan = $mode eq 'relev' ? 4 : 3;
print
	"<TR BGCOLOR='$cfg{'lightCellColor'}'><TD COLSPAN=$colspan>\n",
	"$lng->{'serNotFound'}\n",
	"</TD></TR>\n\n"
	unless @$posts;

print
	tableEnd();

# Log action
logAction(2, 'forum', 'search', $user->primary_key, $boardId);

# Print footer
printFooter();
