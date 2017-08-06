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

# Print header
$m->printHeader();

# Get CGI parameters
my $postId = $m->paramInt('pid');
$postId or $m->paramError($lng->{errPstIdMiss});

# Get post's board/topic ids
my $post = $m->fetchHash("
	SELECT id, boardId, topicId, parentId
	FROM $cfg->{dbPrefix}posts	
	WHERE id = $postId");
$post or $m->entryError($lng->{errPstNotFnd});

# Get topic base post id
my $basePostId = $m->fetchArray("
	SELECT basePostId FROM $cfg->{dbPrefix}topics WHERE id = $post->{topicId}");

# Branch base post can't be topic base post
$post->{parentId} or $m->userError($lng->{errPromoTpc});

# Check if user is admin or moderator
$user->{admin} || $m->boardAdmin($userId, $post->{boardId}) or $m->adminError();

# Print page bar
my @navLinks = ({ url => $m->url('topic_show', pid => $postId), txt => 'comUp', ico => 'up' });
$m->printPageBar(mainTitle => $lng->{brnTitle}, navLinks => \@navLinks);

# Get boards
my $boards = $m->fetchAllHash("
	SELECT boards.*,
		categories.title AS categTitle
	FROM $cfg->{dbPrefix}boards AS boards
		INNER JOIN $cfg->{dbPrefix}categories AS categories
			ON categories.id = boards.categoryId
	ORDER BY categories.pos, boards.pos");
@$boards = grep($m->boardVisible($_), @$boards);
@$boards = grep($m->boardWritable($_), @$boards);

# Print promotion form
print
	"<form action='branch_promote$m->{ext}' method='post'>\n",
	"<div class='frm'>\n",
	"<div class='hcl'>\n",
	"<span class='htt'>$lng->{brnPromoTtl}</span>\n",
	"</div>\n",
	"<div class='ccl'>\n",
	"$lng->{brnPromoSbj}<br/>\n",
	"<input type='text' name='subject' size='80' maxlength='$cfg->{maxSubjectLen}'/><br/>\n",
	"$lng->{brnPromoBrd}<br/>\n",
	"<select name='bid' size='1'>\n";

for my $board (@$boards) {
	my $sel = $board->{id} eq $post->{boardId} ? "selected='selected'" : '';
	print "<option value='$board->{id}' $sel>$board->{categTitle} / $board->{title}</option>\n";
}

print
	"</select><br/>\n",
	"<label><input type='checkbox' name='link' checked='checked'/>",
	"$lng->{brnPromoLink}</label><br/><br/>\n",
	$m->submitButton('brnPromoB', 'topic'),
	"<input type='hidden' name='pid' value='$postId'/>\n",
	$m->stdFormFields(),
	"</div>\n",
	"</div>\n",
	"</form>\n\n";

# Print move branch form
print
	"<form action='branch_move$m->{ext}' method='post'>\n",
	"<div class='frm'>\n",
	"<div class='hcl'>\n",
	"<span class='htt'>$lng->{brnMoveTtl}</span>\n",
	"</div>\n",
	"<div class='ccl'>\n",
	"$lng->{brnMovePrnt}<br/>\n",
	"<input type='text' name='parent' size='8' maxlength='8' value='$basePostId'/><br/><br/>\n",
	$m->submitButton('brnMoveB', 'move'),
	"<input type='hidden' name='pid' value='$postId'/>\n",
	$m->stdFormFields(),
	"</div>\n",
	"</div>\n",
	"</form>\n\n";

# Print delete form
print
	"<form action='branch_delete$m->{ext}' method='post'>\n",
	"<div class='frm'>\n",
	"<div class='hcl'>\n",
	"<span class='htt'>$lng->{brnDeleteTtl}</span>\n",
	"</div>\n",
	"<div class='ccl'>\n",
	$m->submitButton('brnDeleteB', 'delete'),
	"<input type='hidden' name='pid' value='$postId'/>\n",
	$m->stdFormFields(),
	"</div>\n",
	"</div>\n",
	"</form>\n\n";

# Log action
$m->logAction(3, 'branch', 'admin', $userId, $post->{boardId}, $post->{topicId}, $postId);

# Print footer
$m->printFooter();
