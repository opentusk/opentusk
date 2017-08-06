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

# Create xml directory
my $xmlPath = "$cfg->{attachFsPath}/xml";
mkdir $xmlPath if !-d $xmlPath;

#------------------------------------------------------------------------------
# Generate Atom/RSS feeds

if ($cfg->{rssLink}) {
	# Generate separate files for boards
	my $boards = $m->fetchAllHash("
		SELECT id, title FROM $cfg->{dbPrefix}boards WHERE private = 0");
	
	for my $board (@$boards) {
		my $boardId = $board->{id};
# TUSK begin
# changing the filename to be a random number generated from the bid.
		srand($boardId);
		my $randBid = rand();

		#my $rss200File = "$xmlPath/board$boardId.rss200.xml";
		#my $atom10File = "$xmlPath/board$boardId.atom10.xml";
		my $rss200File = "$xmlPath/board$randBid.rss200.xml";
		my $atom10File = "$xmlPath/board$randBid.atom10.xml";
# TUSK end

		my $rss200Time = (stat($rss200File))[9];
		my $atom10Time = (stat($atom10File))[9];
	
		# Get time of latest post
		my $lastPostTime = $m->fetchArray("
			SELECT MAX(lastPostTime) FROM $cfg->{dbPrefix}topics WHERE boardId = $boardId");
	
		# Get latest edit time of posts
		my $lastEditTime = $m->fetchArray("
			SELECT MAX(editTime)
			FROM $cfg->{dbPrefix}posts
			WHERE boardId = $boardId
				AND approved = 1");
		my $updateTime = $lastEditTime > $lastPostTime ? $lastEditTime : $lastPostTime;
	
		# Get latest posts
		my $posts = $m->fetchAllHash("
			SELECT posts.id, posts.userId, posts.body, posts.postTime, posts.editTime,
				topics.subject, topics.postNum,
				boards.title AS boardTitle,
				users.userName
			FROM $cfg->{dbPrefix}posts AS posts
				INNER JOIN $cfg->{dbPrefix}topics AS topics
					ON topics.id = posts.topicId
				INNER JOIN $cfg->{dbPrefix}boards AS boards
					ON boards.id = posts.boardId
				INNER JOIN $cfg->{dbPrefix}users AS users
					ON users.id = posts.userId
			WHERE posts.boardId = $boardId
				AND posts.approved = 1
			ORDER BY posts.postTime DESC
			LIMIT $cfg->{rssItems}");
		
		# Write file	
		writeRss200($rss200File, $posts, $board->{title}) 
			if $updateTime > $rss200Time || !-f $rss200File;
		writeAtom10($atom10File, $posts, $board->{title}) 
			if $updateTime > $atom10Time || !-f $atom10File;
	}
	
	# Generate single file for whole forum
	my $rss200File = "$xmlPath/forum.rss200.xml";
	my $atom10File = "$xmlPath/forum.atom10.xml";
	my $rss200Time = (stat($rss200File))[9];
	my $atom10Time = (stat($atom10File))[9];
	
	# Get time of latest post
	my $lastPostTime = $m->fetchArray("
		SELECT MAX(topics.lastPostTime)
		FROM $cfg->{dbPrefix}topics AS topics
			INNER JOIN $cfg->{dbPrefix}boards AS boards
				ON boards.id = topics.boardId
		WHERE boards.private = 0
			AND boards.id NOT IN ($cfg->{rssExclude})");
	
	# Get latest edit time of posts
	my $lastEditTime = $m->fetchArray("
		SELECT MAX(posts.editTime)
		FROM $cfg->{dbPrefix}posts AS posts
			INNER JOIN $cfg->{dbPrefix}boards AS boards
				ON boards.id = posts.boardId
		WHERE posts.approved = 1
			AND boards.private = 0
			AND boards.id NOT IN ($cfg->{rssExclude})");
	my $updateTime = $lastEditTime > $lastPostTime ? $lastEditTime : $lastPostTime;
	
	# Get latest posts
	my $posts = $m->fetchAllHash("
		SELECT posts.id, posts.userId, posts.body, posts.postTime, posts.editTime,
			topics.subject, topics.postNum,
			boards.title AS boardTitle,
			users.userName
		FROM $cfg->{dbPrefix}posts AS posts
			INNER JOIN $cfg->{dbPrefix}topics AS topics
				ON topics.id = posts.topicId
			INNER JOIN $cfg->{dbPrefix}boards AS boards
				ON boards.id = posts.boardId
			INNER JOIN $cfg->{dbPrefix}users AS users
				ON users.id = posts.userId
		WHERE posts.approved = 1
			AND boards.private = 0
			AND boards.id NOT IN ($cfg->{rssExclude})
		ORDER BY posts.postTime DESC
		LIMIT $cfg->{rssItems}");
	
	# Write file	
	writeRss200($rss200File, $posts) if $updateTime > $rss200Time || !-f $rss200File;
	writeAtom10($atom10File, $posts) if $updateTime > $atom10Time || !-f $atom10File;
	
	# Generate single file for blog posts (not comments)
	$rss200File = "$xmlPath/blogs.rss200.xml";
	$atom10File = "$xmlPath/blogs.atom10.xml";
	$rss200Time = (stat($rss200File))[9];
	$atom10Time = (stat($atom10File))[9];
	
	# Get time of latest post
	$lastPostTime = $m->fetchArray("
		SELECT MAX(postTime) FROM $cfg->{dbPrefix}posts WHERE boardId < 0 AND parentId = 0");
	
	# Get latest edit time of posts
	$lastEditTime = $m->fetchArray("
		SELECT MAX(editTime) FROM $cfg->{dbPrefix}posts WHERE boardId < 0 AND parentId = 0");
	$updateTime = $lastEditTime > $lastPostTime ? $lastEditTime : $lastPostTime;
	
	# Get latest posts
	$posts = $m->fetchAllHash("
		SELECT posts.id, posts.userId, posts.body, posts.postTime, posts.editTime,
			topics.subject, topics.postNum,
			users.userName
		FROM $cfg->{dbPrefix}posts AS posts
			INNER JOIN $cfg->{dbPrefix}topics AS topics
				ON topics.id = posts.topicId
			INNER JOIN $cfg->{dbPrefix}users AS users
				ON users.id = posts.userId
		WHERE posts.boardId < 0
			AND posts.parentId = 0
		ORDER BY posts.postTime DESC
		LIMIT $cfg->{rssItems}");
	
	# Write file	
	writeRss200($rss200File, $posts, "Blogs") if $updateTime > $rss200Time || !-f $rss200File;
	writeAtom10($atom10File, $posts, "Blogs") if $updateTime > $atom10Time || !-f $atom10File;
}

#------------------------------------------------------------------------------
# Generate microsummary with last post time (e.g. for FF Live Titles)

if ($cfg->{microsummary}) {
	my $msumFile = "$xmlPath/microsummary.txt";
	my $msumTime = (stat($msumFile))[9];
	
	# Get last post time
	my $lastPostTime = $m->fetchArray("
		SELECT MAX(posts.postTime)
		FROM $cfg->{dbPrefix}posts AS posts
			INNER JOIN $cfg->{dbPrefix}boards AS boards
				ON boards.id = posts.boardId
		WHERE posts.approved = 1
			AND boards.private = 0");
	my $lastPostTimeStr = $m->formatTime($lastPostTime, $cfg->{userTimezone});
	
	# Open file
	if ($lastPostTime > $msumTime || !-f $msumFile) {
		open my $fh, ">$msumFile" or die ($msumFile . " " . $!);
		binmode $fh, ':utf8' if $m->{gcfg}{utf8};
		print $fh "$cfg->{forumName} ($lastPostTimeStr)";
		close $fh;
	}
}

#------------------------------------------------------------------------------
# Write RSS 2.0 feed

sub writeRss200
{
	my $file = shift();
	my $posts = shift();
	my $boardTitle = shift();
	
	# Open file
	open my $fh, ">$file" or die ($file . " " . $!);
	binmode $fh, ':utf8' if $m->{gcfg}{utf8};

	# Format values
	my $title = $cfg->{forumName};
	$title .= " - $boardTitle" if $boardTitle;
	my $buildDate = $m->formatTime($m->{now}, 0, "%a, %d %b %Y %H:%M:%S GMT");
	my $desc = $m->escHtml($cfg->{rssDesc});
	
	# Print header
	print $fh
		"<?xml version='1.0' encoding='$cfg->{charset}'?>\n",
		"<rss version='2.0'>\n",
		"  <channel>\n",
		"    <title>$title</title>\n",
		"    <link>$cfg->{baseUrl}$cfg->{scriptUrlPath}/forum$m->{ext}</link>\n",
		"    <description>$desc</description>\n",
		"    <lastBuildDate>$buildDate</lastBuildDate>\n",
		"    <ttl>120</ttl>\n",
		"    <generator>mwForum $MwfMain::VERSION</generator>\n";
	
	# Print items
	my $itemLink = "$cfg->{baseUrl}$cfg->{scriptUrlPath}/topic_show$m->{ext}?pid=";
	for my $post (@$posts) {
		# Format values
		my $postId = $post->{id};
		my $subject = $post->{subject};
		$subject =~ s!&#39;!'!g;
		$subject =~ s!&quot;!"!g;
		$subject =~ s!&lt;!!g;
		$subject =~ s!&gt;!!g;
		my $postCopy = { %$post };
		$m->dbToDisplay({}, $postCopy);
		my $pubDate = $m->formatTime($post->{postTime}, 0, "%a, %d %b %Y %H:%M:%S GMT");

		# Print entry
		print $fh
			"    <item>\n",
			"      <guid isPermaLink='false'>$itemLink$postId</guid>\n",
			"      <link>$itemLink$postId</link>\n",
			"      <title>$subject</title>\n",
			"      <author>$post->{userName}</author>\n",
			"      <pubDate>$pubDate</pubDate>\n",
			"      <category>$post->{boardTitle}</category>\n",
			"      <description>\n",
			"        <![CDATA[$postCopy->{body}]]>\n",
			"      </description>\n",
			"    </item>\n";
	}
	
	# End file
	print $fh 
		"  </channel>\n",
		"</rss>\n";

	close $fh;
}

#------------------------------------------------------------------------------
# Write Atom 1.0 feed

sub writeAtom10
{
	my $file = shift();
	my $posts = shift();
	my $boardTitle = shift();
	
	# Open file
	open my $fh, ">$file" or die ($file . " " . $!);
	binmode $fh, ':utf8' if $m->{gcfg}{utf8};
	
	# Format values
	my $title = $cfg->{forumName};
	$title .= " - $boardTitle" if $boardTitle;
	my $updated = $m->formatTime($m->{now}, 0, "%Y-%m-%dT%TZ");
	my $fileName = $file;
	$fileName =~ s/.*[\\\/:]//;
	my $desc = $m->escHtml($cfg->{rssDesc});
	
	# Print header
	print $fh
		"<?xml version='1.0' encoding='$cfg->{charset}'?>\n",
		"<feed xmlns='http://www.w3.org/2005/Atom'",
		" xmlns:slash='http://purl.org/rss/1.0/modules/slash/'",
		" xml:base='$cfg->{baseUrl}'>\n",
		"  <id>$cfg->{baseUrl}$cfg->{scriptUrlPath}/forum$m->{ext}</id>\n",
		"  <link rel='self' href='$cfg->{baseUrl}$cfg->{attachUrlPath}/xml/$fileName'/>\n",
		"  <link rel='alternate' href='$cfg->{baseUrl}$cfg->{scriptUrlPath}/forum$m->{ext}'/>\n",
		"  <title>$title</title>\n",
		"  <subtitle>$desc</subtitle>\n",
		"  <updated>$updated</updated>\n",
		"  <generator version='$MwfMain::VERSION' uri='http://www.mwforum.org/'>mwForum</generator>\n",
	;

	# Print entries
	my $itemLink = "$cfg->{baseUrl}$cfg->{scriptUrlPath}/topic_show$m->{ext}?pid=";
	my $authorLink = "$cfg->{baseUrl}$cfg->{scriptUrlPath}/user_info$m->{ext}?uid=";
	for my $post (@$posts) {
		# Format values
		my $postId = $post->{id};
		my $postCopy = { %$post };
		$m->dbToDisplay({}, $postCopy);
		$post->{editTime} ||= $post->{postTime};
		my $published = $m->formatTime($post->{postTime}, 0, "%Y-%m-%dT%TZ");
		my $updated = $m->formatTime($post->{editTime}, 0, "%Y-%m-%dT%TZ");
		my $comments = $post->{postNum} - 1;

		# Print entry
		print $fh
			"  <entry>\n",
			"    <id>$itemLink$postId</id>\n",
			"    <link href='$itemLink$postId'/>\n",
			"    <title>$post->{subject}</title>\n",
			"    <author><name>$post->{userName}</name></author>\n",
			"    <published>$published</published>\n",
			"    <updated>$updated</updated>\n",
			"    <category term='$post->{boardTitle}'/>\n",
			"    <slash:comments>$comments</slash:comments>\n",
			"    <content type='html'>\n",
			"      <![CDATA[$postCopy->{body}]]>\n",
			"    </content>\n",
			"  </entry>\n";
	}
	
	print	$fh "</feed>\n";
	close $fh;
}
