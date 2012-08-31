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
no warnings qw(uninitialized redefine once);

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
my $optUserId = $m->paramInt('uid');
my $submitted = $m->paramBool('subm');
my $sourceAuth = $m->paramInt('auth');

# Select which user to edit
my $optUser = $optUserId && $user->{admin} ? $m->getUser($optUserId) : $user;
$optUser or $m->entryError($lng->{errUsrNotFnd});
$optUserId = $optUser->{id};

# Get subscribed topics
my $topics = $m->fetchAllHash("
	SELECT topics.id, topics.subject
	FROM $cfg->{dbPrefix}topicSubscriptions AS topicSubscriptions
		INNER JOIN $cfg->{dbPrefix}topics AS topics
			ON topics.id = topicSubscriptions.topicId
	WHERE topicSubscriptions.userId = $optUserId
	ORDER BY topics.lastPostTime");

# Process form
if ($submitted) {
	# Check request source authentication
	$sourceAuth == $user->{sourceAuth} or $m->formError($lng->{errSrcAuth});

	# Print form errors or finish action
	if (@{$m->{formErrors}}) { $m->printFormErrors() }
	else {
		# Transaction
		$m->dbBegin();
		eval {
			for my $topic (@$topics) {
				# Delete subscriptions
				if (!$m->paramBool("subscribe_$topic->{id}")) {
					$m->dbDo("
						DELETE FROM $cfg->{dbPrefix}topicSubscriptions 
						WHERE userId = $optUserId 
							AND topicId = $topic->{id}");
				}
			}
		};
		$@ ? $m->dbRollback() : $m->dbCommit();
		
		# Log action
		$m->logAction(1, 'user', 'topics', $userId, 0, 0, 0, $optUserId);
		
		# Redirect
		$m->redirect('user_options', uid => $optUserId, msg => 'OptChange');
	}
}

# Print form
if (!$submitted || @{$m->{formErrors}}) {
	# Print header
	$m->printHeader();

	# Print page bar
	my @navLinks = ({ url => $m->url('user_options', uid => $optUserId), 
		txt => 'comUp', ico => 'up' });
	$m->printPageBar(mainTitle => $lng->{utpTitle}, subTitle => $optUser->{userName}, 
		navLinks => \@navLinks);

	# Print topic subscription table
	print 
		"<form action='user_topics$m->{ext}' method='post'>\n",
		"<table class='tbl'>\n",
		"<tr class='hrw'>\n",
		"<th colspan='2'>$lng->{utpTpcStTtl}</th>\n",
		"</tr>\n";
		
	for my $topic (@$topics) {
		print
			"<tr class='crw'>\n",
			"<td>$topic->{subject}</td>\n",
			"<td class='shr'>",
			"<label><input type='checkbox' name='subscribe_$topic->{id}' checked='checked'/>",
			"$lng->{utpTpcStSubs}</label></td>\n",
			"</tr>\n";
	}

	# If no subscribed topics, display notification
	print
		"<tr class='crw'>\n",
		"<td colspan='2'>\n",
		"$lng->{utpEmpty}\n",
		"</td>\n",
		"</tr>\n",
		if !@$topics;
	
	print "</table>\n\n";

	# Print submit section
	print
		"<div class='frm'>\n",
		"<div class='hcl'>\n",
		"<span class='htt'>$lng->{utpSubmitTtl}</span>\n",
		"</div>\n",
		"<div class='ccl'>\n",
		$m->submitButton('utpChgB', 'edit'),
		"<input type='hidden' name='uid' value='$optUserId'/>\n",
		$m->stdFormFields(),
		"</div>\n",
		"</div>\n",
		"</form>\n\n";
	
	# Log action
	$m->logAction(3, 'user', 'topics', $userId, 0, 0, 0, $optUserId);
	
	# Print footer
	$m->printFooter();
}
