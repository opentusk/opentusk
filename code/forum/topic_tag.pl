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

# Get CGI parameters
my $topicId = $m->paramInt('tid');
my $tag = $m->paramStrId('tag');
my $submitted = $m->paramBool('subm');
my $sourceAuth = $m->paramInt('auth');
$topicId or $m->paramError($lng->{errTpcIdMiss});

# Get topic
my ($boardId, $basePostId, $oldTag) = $m->fetchArray("
	SELECT boardId, basePostId, tag FROM $cfg->{dbPrefix}topics WHERE id = $topicId");
$boardId or $m->entryError($lng->{errTpcNotFnd});

# Check if user is allowed to tag topic
my $boardAdmin = $user->{admin} || $m->boardAdmin($userId, $boardId);
if ($cfg->{allowTopicTags} == 0) { 
	$m->userError($lng->{errFeatDisbl}); 
}
elsif ($cfg->{allowTopicTags} == 1) {
	# Check if user is admin or moderator in board
	$boardAdmin or $m->adminError();
}
elsif ($cfg->{allowTopicTags} == 2) {
	# Check if user is topic creator
	my $topicUserId = $m->fetchArray("
		SELECT userId FROM $cfg->{dbPrefix}posts WHERE id = $basePostId");
	$userId == $topicUserId || $boardAdmin or $m->userError($lng->{errCheat});
}

# Process form
if ($submitted) {
	# Check request source authentication
	$sourceAuth == $user->{sourceAuth} or $m->formError($lng->{errSrcAuth});

	# Print form errors or finish action
	if (@{$m->{formErrors}}) { $m->printFormErrors() }
	else {
		# Update topic
		$m->dbDo("
			UPDATE $cfg->{dbPrefix}topics SET tag = '$tag' WHERE id = $topicId");

		# Log action
		$m->logAction(1, 'topic', 'tag', $userId, $boardId, $topicId);
		
		# Redirect
		$m->redirect('board_show', bid => $boardId, tid => $topicId, msg => 'TpcTag', 
			tgt => "tid$topicId");
	}
}

# Print form
if (!$submitted || @{$m->{formErrors}}) {
	# Print header
	$m->printHeader();

	# Get subject
	my $subject = $m->fetchArray("
		SELECT subject FROM $cfg->{dbPrefix}topics WHERE id = $topicId");
	$subject or $m->entryError($lng->{errTpcNotFnd});

	# Print page bar
	my @navLinks = ({ url => $m->url('topic_show', tid => $topicId), txt => 'comUp', ico => 'up' });
	$m->printPageBar(mainTitle => $lng->{ttgTitle}, subTitle => $subject, navLinks => \@navLinks);
	
	# Print tag form
	my $chk = !$oldTag ? "checked='checked'" : "";
	print
		"<form action='topic_tag$m->{ext}' method='post'>\n",
		"<div class='frm'>\n",
		"<div class='hcl'>\n",
		"<span class='htt'>$lng->{ttgTagTtl}</span>\n",
		"</div>\n",
		"<div class='ccl'>\n",
		"<input type='radio' name='tag' value='' $chk/><br/>\n";
	
	for my $key (sort keys %{$cfg->{topicTags}}) {
		$chk = $key eq $oldTag ? "checked='checked'" : "";
		print
			"<label><input type='radio' name='tag' value='$key' $chk/>",
			$m->formatTopicTag($key), "</label><br/>\n";
	}
	
	print
		"<br/>\n",
		$m->submitButton('ttgTagB', 'tag'),
		"<input type='hidden' name='tid' value='$topicId'/>\n",
		$m->stdFormFields(),
		"</div>\n",
		"</div>\n",
		"</form>\n\n";

	# Log action
	$m->logAction(3, 'topic', 'tag', $userId, 0, $topicId);
	
	# Print footer
	$m->printFooter();
}
