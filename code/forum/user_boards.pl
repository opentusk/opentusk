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

# Get CGI parameters
my $optUserId = $m->paramInt('uid');
my $submitted = $m->paramBool('subm');
my $sourceAuth = $m->paramInt('auth');

# Select which user to edit
my $optUser = $optUserId && $user->{admin} ? $m->getUser($optUserId) : $user;
$optUser or $m->entryError($lng->{errUsrNotFnd});
$optUserId = $optUser->{id};

# Process form
if ($submitted) {
	# Check request source authentication
	$sourceAuth == $user->{sourceAuth} or $m->formError($lng->{errSrcAuth});

	# Print form errors or finish action
	if (@{$m->{formErrors}}) { $m->printFormErrors() }
	else {
		# Call authorization plugin
		$m->checkAuthz($user, 'userOpt');
		
		# Transaction
		$m->dbBegin();
		eval {

		        # TUSK begin
			# Get boards using TUSK methods
			my $boards = Forum::ForumKey::getViewableBoardsHash($m, $user);
			# TUSK end

			for my $board (@$boards) {
				# Update hidden boards
				my $set = $m->paramBool("hide_$board->{id}");
				$m->setRel($set, 'boardHiddenFlags', 'userId', 'boardId', $optUserId, $board->{id});
			
				# Update subscriptions
				if ($cfg->{subscriptions}) {
					$set = $m->paramBool("subscribe_$board->{id}") && $m->boardVisible($board);
					$m->setRel($set, 'boardSubscriptions', 'userId', 'boardId', $optUserId, $board->{id});
				}
			
				# Only admin can change admin status and membership
				if ($user->{admin}) {
					# Update admin status
					$set = $m->paramBool("admin_$board->{id}");
					$m->setRel($set, 'boardAdmins', 'userId', 'boardId', $optUserId, $board->{id});

					# Update membership
					$set = $m->paramBool("member_$board->{id}");
					$m->setRel($set, 'boardMembers', 'userId', 'boardId', $optUserId, $board->{id});
				}
			}
		};
		$@ ? $m->dbRollback() : $m->dbCommit();
		
		# Log action
		$m->logAction(1, 'user', 'boards', $userId, 0, 0, 0, $optUserId);
		
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
	$m->printPageBar(mainTitle => $lng->{ubdTitle}, subTitle => $optUser->{userName}, 
		navLinks => \@navLinks);
	
	# Print board status table
	my $colspan = $user->{admin} ? 5 : 3;
	print 
		"<form action='user_boards$m->{ext}' method='post'>\n",
		"<table class='tbl'>\n",
		"<tr class='hrw'>\n",
		"<th colspan='$colspan'>$lng->{ubdBrdStTtl}</th>\n",
		"</tr>\n";
		
	
	# TUSK begin
	# Added boardKey to sort order.  boardVisible checks the variables table for viewableboards.
	# this could be optimized if we also selected on the variables table here, then we
	# would not have to use the boardVisible function.
	# Get boards including status
	my $boards = $m->fetchAllHash("
		SELECT boards.*, 
			categories.title AS categTitle,
			boardSubscriptions.userId IS NOT NULL AS subs,
			boardHiddenFlags.userId IS NOT NULL AS hidden,
			boardAdmins.userId IS NOT NULL AS admin,
			boardMembers.userId IS NOT NULL AS member
		FROM ( $cfg->{dbPrefix}boards AS boards, $cfg->{dbPrefix}variables AS variables )
			INNER JOIN $cfg->{dbPrefix}categories AS categories
				ON categories.id = boards.categoryId
			LEFT JOIN $cfg->{dbPrefix}boardSubscriptions AS boardSubscriptions
				ON boardSubscriptions.userId = $optUserId
				AND boardSubscriptions.boardId = boards.id
			LEFT JOIN $cfg->{dbPrefix}boardHiddenFlags AS boardHiddenFlags
				ON boardHiddenFlags.userId = $optUserId
				AND boardHiddenFlags.boardId = boards.id
			LEFT JOIN $cfg->{dbPrefix}boardAdmins AS boardAdmins
				ON boardAdmins.userId = $optUserId
				AND boardAdmins.boardId = boards.id
			LEFT JOIN $cfg->{dbPrefix}boardMembers AS boardMembers
				ON boardMembers.userId = $optUserId
				AND boardMembers.boardId = boards.id
                WHERE variables.name = boards.id
                      AND variables.userId = $userId
                      AND variables.value = 'viewableBoard'
		      AND boards.private = 0 
		ORDER BY boards.boardKey, boards.pos");
	# TUSK end

	# Print board list
	my $checked = "checked='checked'";
	for my $board (@$boards) {
		my $boardId = $board->{id};
		my $subsDisabled = $cfg->{subscriptions} && $optUser->{email} ? "" : "disabled='disabled'";
		my $subs = $board->{subs} && $cfg->{subscriptions} && !$optUser->{dontEmail} ? $checked : "";
		my $hidden = $board->{hidden} ? $checked : "";
		my $admin = $board->{admin} ? $checked : "";
		my $member = $board->{member} ? $checked : "";
	
		# Subscription and hidden status
		print
			"<tr class='crw'>\n",
			"<td>$board->{categTitle} / $board->{title}</td>\n",
			"<td><label><input type='checkbox' name='subscribe_$boardId' $subs $subsDisabled/>",
			"$lng->{ubdBrdStSubs}</label></td>\n",
			"<td><label><input type='checkbox' name='hide_$boardId' $hidden/>",
			"$lng->{ubdBrdStHide}</label></td>\n";
	
		# Admin and member status
		print
			"<td><label><input type='checkbox' name='admin_$boardId' $admin/>Moderator</label></td>\n",
			"<td><label><input type='checkbox' name='member_$boardId' $member/>Member</label></td>\n",
			if $user->{admin};
	
		print 
			"</tr>\n";
	}
	
	print "</table>\n\n";
	

	# Print submit section
	print
		"<div class='frm'>\n",
		"<div class='hcl'>\n",
		"<span class='htt'>$lng->{ubdSubmitTtl}</span>\n",
		"</div>\n",
		"<div class='ccl'>\n",
		$m->submitButton('ubdChgB', 'edit'),
		"<input type='hidden' name='uid' value='$optUserId'/>\n",
		$m->stdFormFields(),
		"</div>\n",
		"</div>\n",
		"</form>\n\n";
	
	# Log action
	$m->logAction(3, 'user', 'boards', $userId, 0, 0, 0, $optUserId);
	
	# Print footer
	$m->printFooter();
}
