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

# Get CGI parameters
my $cgi = new Forum::MwfCGI;
my $msg = $cgi->param('msg');
my $onlyBoardId   = ($cgi->param('bid')) ? int($cgi->param('bid')) : 0;
my $onlyTopicId   = ($cgi->param('tid')) ? int($cgi->param('tid')) : 0;
my $onlyRepliesTo = ($cgi->param('uid')) ? int($cgi->param('uid')) : 0;

# Print header
printHeader($msg);

# Check if access should be denied
checkBlock();

# Check if user is registered
$user->{'default'} and regError();

# Print section bar
my @bar = (
	"forum_show.pl", "comUp", 1
);
printBar($lng->{'nplTitle'}, "", \@bar);

# Get boards
my $onlyBoardStr = $onlyBoardId ? "AND boards.id = $onlyBoardId" : "";
my $anonBoardStr = $onlyRepliesTo ? "AND boards.anonymous = 0" : "";
my $query = "
	SELECT boards.* 
	FROM boards, categories
	WHERE categories.id = boards.categoryId
		$onlyBoardStr
		$anonBoardStr
	ORDER BY categories.page, categories.pos, boards.pos";
my $sth = query($query);
my $boards = $sth->fetchall_arrayref({});

# Prepare values
my $user_id = $user->primary_key;
my $now = time();
my @topicReadTimes = ();
my $maxPosts = 300;
my $postsPrinted = 0;
my $firstBoard = 1;

# Determine fixed icon attributes
my $imgAlign = browserAttr('middleImgAlign');
my $imgFixAttr = "WIDTH=$cfg{'iconSize'} HEIGHT=$cfg{'iconSize'} BORDER=0 $imgAlign";

# For each board
BOARD: for my $board (@$boards) {
	my $boardId = $board->{'id'};
	my $boardAdmin = boardAdmin($user_id, $board->{'id'}) || $user->{'admin'};
	my $boardWritable = boardWritable($board, undef, $boardAdmin);
	next BOARD unless boardVisible($board, $boardAdmin);
	
	# Get topics
	my $onlyTopicStr = $onlyTopicId ? "AND topics.id = $onlyTopicId" : "";
	my $query = "
		SELECT topics.*
		FROM topics, posts
		WHERE topics.id = posts.topicId
			AND topics.boardId = $boardId
			$onlyTopicStr
			AND posts.boardId = $boardId
			AND posts.postTime > $user->{'lastReadTime'}
		GROUP BY posts.topicId
		ORDER BY topics.lastPostTime";
	my $sth = query($query);
	my $topics = $sth->fetchall_arrayref({});
	next BOARD unless @$topics;

	# Print board bar
	print "<BR CLEAR='all'>" unless $firstBoard;
	$firstBoard = 0;
		
	print
		"<BR>\n\n",
		tableStart(undef, undef, "100%", "right"),
		"<TR><TD>\n",
		"<TABLE WIDTH='100%' BORDER=0 CELLSPACING=0 CELLPADDING=0>\n",
		"<TR><TD>\n",
		"<B>$lng->{'brdTitle'}</B>\n",
		"<A HREF='board_show.pl?bid=$boardId'>$board->{'title'}</A>\n",
		"</TD><TD ALIGN='right'>\n",
		"</TD></TR>\n",
		"</TABLE>\n",
		"</TD></TR>\n",
		tableEnd();
		
	# For each topic
	TOPIC: for my $topic (@$topics) {
		my $topicId = $topic->{'id'};

		# Get posts
		my $apprvStr = $user->{'admin'} ? "" : "AND (NOT boards.approve OR posts.approved)";
		my $parentStr1 = $onlyRepliesTo ? ", posts AS parents" : "";
		my $parentStr2 = $onlyRepliesTo 
			? "AND parents.id = posts.parentId AND parents.user_id = '".$user->primary_key."'" : "";
		$query = "
			SELECT posts.id, posts.user_id, posts.parentId, posts.approved, posts.score, 
				posts.postTime, posts.body, posts.attach, posts.userNameBak,
				u.user_id, concat(u.firstname, ' ', u.lastname) as fullname
			FROM posts $parentStr1, boards
				LEFT JOIN hsdb4.user u	ON u.user_id = posts.user_id
			WHERE posts.boardId = $boardId 
				AND posts.topicId = $topicId
				AND posts.postTime > $user->{'lastReadTime'}
				$parentStr2
				AND boards.id = $boardId
				$apprvStr
			ORDER BY posts.postTime desc";
		$sth = query($query);
		my $posts = $sth->fetchall_arrayref({});
		next TOPIC unless @$posts;

		# Add topic read time to update list
		push @topicReadTimes, "('$user_id',$topicId,$now)";

		# Print topic bar
		print
			"<BR CLEAR='all'><BR>\n\n",
			tableStart(undef, undef, "95%", "right"),
			"<TR><TD>\n",
			"<TABLE WIDTH='100%' BORDER=0 CELLSPACING=0 CELLPADDING=0>\n",
			"<TR><TD>\n",
			"<B>$lng->{'tpcTitle'}</B>\n",
			"<A HREF='topic_show.pl?tid=$topicId'>$topic->{'subject'}</A>\n",
			"</TD><TD ALIGN='right'>\n",
			"</TD></TR>\n",
			"</TABLE>\n",
			"</TD></TR>\n",
			tableEnd();

		# For each post
		POST: for my $post (@$posts) {
			my $postId = $post->{'id'};

			# Prepare username string
			my $userNameStr = " - ";
			if ($board->{'anonymous'}) {
				$userNameStr = $lng->{'comHidden'};
			}
			else{
			    $userNameStr = "$post->{'fullname'}";
			}


			# Prepare other display strings
			my $postTimeStr = formatTime($post->{'postTime'}, $user->{'timezone'});
			dbToDisplay($board, $post);

			# Determine variable post icon attributes
			my $imgSrc; 
			my $imgTitle = "";
			my $imgAlt = "";
			if ($board->{'approve'} && !$post->{'approved'}) { 
				$imgSrc = "post_i"; $imgTitle = $lng->{'tpcInvisTT'}; $imgAlt = $lng->{'tpcInvis'};
			}
			else {  # Read status isn't shown here 
				$imgSrc = "post_nu"; $imgTitle = $lng->{'comNewUnrdTT'}; $imgAlt = $lng->{'comNewUnrd'};
			}
			my $imgVarAttr = "SRC='$cfg{'nonCgiPath'}/$imgSrc.gif' TITLE='$imgTitle' ALT='$imgAlt'";

			# Print post			
			print
				"<BR CLEAR='all'><BR>\n\n",
				tableStart(undef, undef, "90%", "right"),
				"<TR><TD BGCOLOR='$cfg{'darkCellColor'}'>\n",
				"<TABLE WIDTH='100%' BORDER=0 CELLSPACING=0 CELLPADDING=0>\n",
				"<TR><TD><A NAME='$postId' HREF='topic_show.pl?tid=$topicId#$postId'>\n",
				"<IMG $imgVarAttr $imgFixAttr></A>\n",
				"<B>$lng->{'tpcBy'}</B> $userNameStr\n",
				"<B>$lng->{'tpcOn'}</B> $postTimeStr\n";
			
			print 		
				"<B>$lng->{'tpcScore'}</B> $post->{'score'}\n"
				if $board->{'score'};
			
			print		
				"</TD><TD ALIGN='right'>\n";

			# Print buttons unless disabled
			if ($cfg{'showNewButtons'}) {
				print
					"[<A HREF='post_approve_x.pl?pid=$postId&ori=newPst' TITLE='$lng->{'tpcApprvTT'}'>",
					"$lng->{'tpcApprv'}</A>]\n"
					if $boardAdmin && $board->{'approve'} && !$post->{'approved'};
			
				print
					"[<A HREF='post_moderate_x.pl?pid=$postId&dir=1&ori=newPst' TITLE='$lng->{'tpcModUTT'}'>",
					"$lng->{'tpcModU'}</A>]\n",
					"[<A HREF='post_moderate_x.pl?pid=$postId&dir=0' TITLE='$lng->{'tpcModDTT'}'>",
					"$lng->{'tpcModD'}</A>]\n"
					if $board->{'score'} && $user->{'votesLeft'} and $user_id != $post->{'user_id'};
	
				print
					"[<A HREF='confirm.pl?action=post_delete_x.pl&pid=$postId&ori=newPst",
					"&name=$post->{'id'}' TITLE='$lng->{'nplDeleteTT'}'>",
					"$lng->{'nplDelete'}</A>]\n"
					if $boardAdmin;
			
				my $EditTime = 1;
				$EditTime = (time() - $post->{'postTime'}) > ($cfg{'editPostTime'} * 60) ? 0 : 1 if ($cfg{'editPostTime'});

				print
					"[<A HREF='post_edit.pl?pid=$postId&ori=newPst' TITLE='$lng->{'tpcEditTT'}'>",
					"$lng->{'tpcEdit'}</A>]\n"
					if ($boardAdmin or (!$topic->{'locked'} && $user_id eq $post->{'user_id'}) && $EditTime);
		
				print
					"[<A HREF='post_reply.pl?pid=$postId&ori=newPst' TITLE='$lng->{'tpcReplyTT'}'>",
					"$lng->{'tpcReply'}</A>]\n"
					if !$board->{'flat'} and ($boardAdmin or !$topic->{'locked'} && $boardWritable);
			}
		
			print
				"</TD></TR>\n",
				"</TABLE>\n",
				"</TD></TR>\n",
				cellStart(),
				"$post->{'body'}\n",
				cellEnd(),
				tableEnd();
			
			# Limit number of posts printed
			$postsPrinted++;
			last BOARD if $postsPrinted == $maxPosts;
		}
	}			
}

# If empty list, print notification
print
	"<P>\n",
	tableStart(),
	cellStart(),
	"$lng->{'nplEmpty'}\n",
	cellEnd(),
	tableEnd()
	unless $postsPrinted;

# If cut off at max posts, print notification
print
	"<P>\n",
	tableStart(),
	cellStart(),
	"$lng->{'nplMaxCutoff'}\n",
	cellEnd(),
	tableEnd()
	if $postsPrinted == $maxPosts;

# Update topic read times
if (@topicReadTimes) {
	my $topicReadTimes = join(",", @topicReadTimes);
	$query = "
		REPLACE topicReadTimes (user_id, topicId, lastReadTime)
		VALUES $topicReadTimes";
	$dbh->do($query) or dbError();
}

# Log action
logAction(2, 'post', 'shownew', $user_id, $onlyBoardId, $onlyTopicId);

# Print footer
print "<BR CLEAR='all'><BR>\n\n";
printFooter();




