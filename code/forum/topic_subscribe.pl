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

# Check if access should be denied
$userId or $m->regError();
$m->checkBan($userId);
$m->checkBlock();

# Check if subscriptions are enabled
$cfg->{subscriptions} or $m->userError($lng->{errFeatDisbl});

# Get CGI parameters
my $action = $m->paramStrId('act');
my $topicId = $m->paramInt('tid');
my $submitted = $m->paramBool('subm');
my $sourceAuth = $m->paramInt('auth');
$topicId or $m->paramError($lng->{errTpcIdMiss});

# Get topic
my ($boardId, $subject) = $m->fetchArray("
	SELECT boardId, subject FROM $cfg->{dbPrefix}topics WHERE id = $topicId");
$boardId or $m->entryError($lng->{errTpcNotFnd});

# Get board
my $board = $m->fetchHash("
	SELECT * FROM $cfg->{dbPrefix}boards WHERE id = $boardId");

# Check if user can see board
$m->boardVisible($board) or $m->entryError($lng->{errTpcNotFnd});

# Check if user is already subscribed
my $subscribed = $m->fetchArray("
	SELECT 1
	FROM $cfg->{dbPrefix}topicSubscriptions 
	WHERE userId = $userId 
		AND topicId = $topicId");

# Process form
if ($submitted) {
	# Check request source authentication
	$sourceAuth == $user->{sourceAuth} or $m->formError($lng->{errSrcAuth});

	# Process subscribe form
	if ($action eq 'subscribe' && !$subscribed) {
		# Print form errors or finish action
		if (@{$m->{formErrors}}) { $m->printFormErrors() }
		else {
			# Add topic subscription
			$m->dbDo("
				INSERT INTO $cfg->{dbPrefix}topicSubscriptions (userId, topicId) 
				VALUES ($userId, $topicId)");
			
			# Log action
			$m->logAction(1, 'topic', 'sub', $userId, $boardId, $topicId);
			
			# Redirect back to topic
			$m->redirect('topic_show', tid => $topicId, msg => 'TpcSub');
		}
	}
	# Process unsubscribe form
	elsif ($action eq 'unsubscribe' && $subscribed) {
		# Print form errors or finish action
		if (@{$m->{formErrors}}) { $m->printFormErrors() }
		else {
			# Remove topic subscription
			$m->dbDo("
				DELETE FROM $cfg->{dbPrefix}topicSubscriptions 
				WHERE userId = $userId 
					AND topicId = $topicId");

			# Log action
			$m->logAction(1, 'topic', 'unsub', $userId, $boardId, $topicId);
		
			# Redirect back to topic
			$m->redirect('topic_show', tid => $topicId, msg => 'TpcUnsub');
		}
	}
	else {
		# Redirect back to topic if nothing to do
		$m->redirect('topic_show', tid => $topicId);
	}
}

# Print form
if (!$submitted || @{$m->{formErrors}}) {
	# Print header
	$m->printHeader();

	# Print page bar
	my @navLinks = ({ url => $m->url('topic_show', tid => $topicId), txt => 'comUp', ico => 'up' });
	$m->printPageBar(mainTitle => $lng->{tsbTitle}, subTitle => $subject, navLinks => \@navLinks);

	if (!$subscribed) {
		# Print subscribe form
		print
			"<form action='topic_subscribe$m->{ext}' method='post'>\n",
			"<div class='frm'>\n",
			"<div class='hcl'>\n",
			"<span class='htt'>$lng->{tsbSubTtl}</span>\n",
			"</div>\n",
			"<div class='ccl'>\n",
			"$lng->{tsbSubT}<br/><br/>\n",
			$m->submitButton('tsbSubB', 'subscribe'),
			"<input type='hidden' name='tid' value='$topicId'/>\n",
			"<input type='hidden' name='act' value='subscribe'/>\n",
			$m->stdFormFields(),
			"</div>\n",
			"</div>\n",
			"</form>\n\n";
	}
	else {
		# Print unsubscribe form
		print
			"<form action='topic_subscribe$m->{ext}' method='post'>\n",
			"<div class='frm'>\n",
			"<div class='hcl'>\n",
			"<span class='htt'>$lng->{tsbUnsubTtl}</span>\n",
			"</div>\n",
			"<div class='ccl'>\n",
			$m->submitButton('tsbUnsubB', 'remove'),
			"<input type='hidden' name='tid' value='$topicId'/>\n",
			"<input type='hidden' name='act' value='unsubscribe'/>\n",
			$m->stdFormFields(),
			"</div>\n",
			"</div>\n",
			"</form>\n\n";
	}

	# Log action
	$m->logAction(3, 'topic', 'sub', $userId, $boardId, $topicId);

	# Print footer
	$m->printFooter();
}
