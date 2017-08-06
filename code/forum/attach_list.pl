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

# TUSK begin adding lib
use Forum::ForumKey;
# TUSK end

#------------------------------------------------------------------------------

# Init
my ($m, $cfg, $lng, $user) = MwfMain->new(@_);
my $userId = $user->{id};

# Print header
$m->printHeader();

# Check if user is allowed to see list
$cfg->{attachList} || $user->{admin} or $m->userError($lng->{errFeatDisbl});
$userId or $m->regError() if $cfg->{attachList} == 2;

# Get CGI parameters
my $page = $m->paramInt('pg') || 1;
my $search = $m->paramStr('search') || "";
my $boardId = $m->paramStrId('board') || "0";  # Sanitize later
my $sort = $m->paramStr('sort') || 'attachments.id';
my $order = $m->paramStr('order') || 'desc';
my $gallery = $m->paramBool('gallery') || 0;

# Enforce restrictions
$sort = 'attachments.id' if $sort !~ /^(?:attachments\.id|fileName|userNameBak)$/;
$order = 'desc' if $order !~ /^(?:asc|desc)$/;
$gallery = 0 if !$cfg->{attachGallery};

# Preserve parameters in links
my @params = (search => $search, board => $boardId, sort => $sort, order => $order, 
	gallery => $gallery);

# Get visible boards with attachments enabled

# TUSK begin: changed the way viewable boards are calculated.
my $boards = Forum::ForumKey::getViewableBoardsHash($m, $user);
# TUSK end

my $boardIdsStr = join(",", map($_->{id}, @$boards)) || "0";

# Search filename
$search = $m->escHtml($search);
my $searchLike = $m->dbEscLike($search);
my $searchStr = $search ? "AND attachments.fileName LIKE " . $m->dbQuote("%$searchLike%") : "";

# Determine checkbox and listbox states
my %state = (
	$boardId => "selected='selected'",
	$sort => "selected='selected'",
	$order => "selected='selected'",
	gallery => $gallery ? "checked='checked'" : undef,
);

# Limit to category or board
my $boardJoinStr = "";
my $boardStr = "";
if ($boardId =~ /^bid(\d+)$/) {
	$boardStr = "AND posts.boardId = $1";
	$boardId = $1;
} 
elsif ($boardId =~ /^cid(\d+)$/) {
	$boardJoinStr = "INNER JOIN $cfg->{dbPrefix}boards AS boards ON boards.id = posts.boardId";
	$boardStr = "AND boards.categoryId = $1";
	$boardId = 0;
}
else { 
	$boardId = 0;
}

# Get ids of attachments
my $galleryStr = $gallery ? "AND attachments.webImage > 0" : "";
my $orderStr = "$sort $order";
my $attachments = $m->fetchAllArray("
	SELECT attachments.id
	FROM $cfg->{dbPrefix}attachments AS attachments
		INNER JOIN $cfg->{dbPrefix}posts AS posts
			ON posts.id = attachments.postId
		$boardJoinStr
	WHERE posts.boardId IN ($boardIdsStr)
		$searchStr
		$galleryStr
		$boardStr
	ORDER BY $orderStr");
	
# Page links
my $attachmentsPP = $gallery ? 12 : 25;
my $pageNum = int(@$attachments / $attachmentsPP) + (@$attachments % $attachmentsPP != 0);
my @pageLinks = ();
if ($pageNum > 1) {
	my $prevPage = $page - 1;
	my $nextPage = $page + 1;
	my $maxPageNum = $m->min($pageNum, 8);
	push @pageLinks, { url => $m->url('attach_list', pg => $_, @params), 
		txt => $_, dsb => $_ == $page }
		for 1 .. $maxPageNum;
	push @pageLinks, { txt => "..." }, { 
		url => $m->url('attach_list', pg => $pageNum, @params),
		txt => $pageNum, dsb => $pageNum == $page }
		if $maxPageNum + 1 < $pageNum;
	push @pageLinks, { url => $m->url('attach_list', pg => $prevPage, @params), 
		txt => 'comPgPrev', dsb => $page == 1 };
	push @pageLinks, { url => $m->url('attach_list', pg => $nextPage, @params), 
		txt => 'comPgNext', dsb => $page == $pageNum };
}

# Get attachments on page
my @pageAttachIds = @$attachments[($page - 1) * $attachmentsPP 
	.. $m->min($page * $attachmentsPP, scalar @$attachments) - 1];
my $pageAttachIdsStr = join(",", map($_->[0], @pageAttachIds)) || "0";
$attachments = $m->fetchAllHash("
	SELECT attachments.*, 
		posts.userId, posts.userNameBak
	FROM $cfg->{dbPrefix}attachments AS attachments
		INNER JOIN $cfg->{dbPrefix}posts AS posts
			ON posts.id = attachments.postId
	WHERE attachments.id IN ($pageAttachIdsStr)
	ORDER BY $orderStr");

# Print page bar
my @navLinks = ({ url => $m->url('forum_show'), txt => 'comUp', ico => 'up' });
$m->printPageBar(mainTitle => $lng->{aliTitle}, navLinks => \@navLinks, pageLinks => \@pageLinks);

# Print attachment list form
print
	"<form action='attach_list$m->{ext}' method='get'>\n",
	"<div class='frm'>\n",
	"<div class='hcl'>\n",
	"<span class='htt'>$lng->{aliLfmTtl}</span>\n",
	"</div>\n",
	"<div class='ccl'>\n",
	"$lng->{aliLfmSearch}\n",
	"<input type='text' name='search' style='width: 100px' value='$search'/>\n",
	"$lng->{aliLfmBoard}\n",
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
	"$lng->{aliLfmSort}\n",
	"<select name='sort' size='1'>\n",
	"<option value='attachments.id' $state{'attachments.id'}>$lng->{aliLfmSrtPTm}</option>\n",
	"<option value='fileName' $state{fileName}>$lng->{aliLfmSrtFNm}</option>\n",
	"<option value='userNameBak' $state{userNameBak}>$lng->{aliLfmSrtUNm}</option>\n",
	"</select>\n",
	"$lng->{aliLfmOrder}\n",
	"<select name='order' size='1'>\n",
	"<option value='desc' $state{desc}>$lng->{aliLfmOrdDsc}</option>\n",
	"<option value='asc' $state{asc}>$lng->{aliLfmOrdAsc}</option>\n",
	"</select>\n",
	$cfg->{attachGallery} ? "<label><input type='checkbox' name='gallery' value='1' "
		. "$state{gallery}/>$lng->{aliLfmGall}</label>\n" : "",
	"<input type='submit' value='$lng->{aliLfmListB}'/>\n",
	$m->{sessionId} ? "<input type='hidden' name='sid' value='$m->{sessionId}'/>\n" : "",
	"</div>\n",
	"</div>\n",
	"</form>\n\n";

# Print normal attachment list
if (!$gallery) {
	print 
		"<table class='tbl'>\n",
		"<tr class='hrw'>\n",
		"<th>$lng->{aliLstFile}</th>\n",
		"<th class='shr' style='width: 10%'>$lng->{aliLstSize}</th>\n",
		"<th class='shr' style='width: 10%'>$lng->{aliLstPost}</th>\n",
		"<th class='shr'>$lng->{aliLstUser}</th>\n",
		"</tr>\n";
	
	for my $attach (@$attachments) {
		my $postId = $attach->{postId};
		my $postIdMod = $postId % 100;
		my $postUrl = $m->url('topic_show', pid => $postId, tgt => "pid$postId");
		my $size = -s "$cfg->{attachFsPath}/$postIdMod/$postId/$attach->{fileName}";
		$size = sprintf("%.1fk", $size/1024);
		my $userNameStr = $attach->{userNameBak} || " - ";
		my $userUrl = $m->url('user_info', uid => $attach->{userId});
		
		print
			"<tr class='crw'>\n",
			"<td><a href='$cfg->{attachUrlPath}/$postIdMod/$postId/$attach->{fileName}'>",
			"$attach->{fileName}</a></td>\n",
			"<td>$size</td>\n",
			"<td><a href='$postUrl'>$postId</a></td>\n",
			"<td><a href='$userUrl'>$userNameStr</a></td>\n",
			"</tr>\n";
	}
	
	print "</table>\n\n";
}
# Print attachment image gallery
else {
	print	"<table class='tbl igl'>\n<tr class='crw'>\n";
	for (my $i=0; $i < @$attachments; $i++) {
		print "</tr><tr class='crw'>\n" if $i && $i % 4 == 0;
		
		# Determine values
		my $attach = @$attachments[$i];
		my $postId = $attach->{postId};
		my $postIdMod = $postId % 100;
		my $imgFsPath = "$cfg->{attachFsPath}/$postIdMod/$postId/$attach->{fileName}";
		my $imgUrlPath = "$cfg->{attachUrlPath}/$postIdMod/$postId/$attach->{fileName}";
		my $thbFsPath = $imgFsPath;
		my $thbUrlPath = $imgUrlPath;
		$thbFsPath =~ s!\.(?:jpg|png|gif)$!.thb.jpg!i;
		$thbUrlPath =~ s!\.(?:jpg|png|gif)$!.thb.jpg!i;
		my $imgSize = -s $imgFsPath;
		my $imgSizeStr = sprintf("%.1fk", $imgSize / 1024);
		my $useThb = -f $thbFsPath || $m->addThumbnail($imgFsPath);
		my $postUrl = $m->url('topic_show', pid => $postId, tgt => "pid$postId");
		my $src = $useThb ? $thbUrlPath : $imgUrlPath;
		my $abbrName = $m->abbr($attach->{fileName}, 25);
		
		# Print image and file size
		if ($useThb >= 0) { 
			print
				"<td>\n<a href='$postUrl'><img class='igl' src='$src' alt=''/></a><br/>\n",
				"<a href='$imgUrlPath'>$abbrName</a><br/> $imgSizeStr\n</td>\n";
		}
		else {
			print $imgSize ? "<td>?</td>\n" : "<td>404</td>\n";
		}
	}

	# Print rest of table
	my $empty = 4 - @$attachments % 4; 
	$empty = 0 if $empty == 4;
	print "<td></td>\n" while $empty-- > 0;
	print	"</tr>\n</table>\n\n";
}

# Log action
$m->logAction(3, 'attach', 'list', $userId, $boardId);

# Print footer
$m->printFooter();
