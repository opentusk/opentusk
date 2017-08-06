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

# Check if user is admin
$user->{admin} or $m->adminError();

# Get CGI parameters
my $boardId = $m->paramInt('bid');
my $title = $m->paramStr('title');
my $shortDesc  = $m->paramStr('shortDesc');
my $longDesc = $m->paramStr('longDesc');
my $locking = $m->paramInt('locking');
my $expiration = $m->paramInt('expiration');
my $catPos = $m->paramStr('catPos');
my $approve = $m->paramBool('approve');
my $anonymous = $m->paramBool('anonymous');
my $unregistered = $m->paramBool('unregistered');
my $private = $m->paramInt('private');
my $list = $m->paramBool('list');
my $announce = $m->paramInt('announce');
my $flat = $m->paramBool('flat');
my $attach = $m->paramBool('attach');
my $submitted = $m->paramBool('subm');
my $sourceAuth = $m->paramInt('auth');
$boardId or $m->paramError($lng->{errBrdIdMiss});

# Parse category/position
my ($categId, $pos) = $catPos =~ /(\-?\d+) (\-?\d+)/;

# Process form
if ($submitted) {
	# Check request source authentication
	$sourceAuth == $user->{sourceAuth} or $m->formError($lng->{errSrcAuth});

	# Get board
	my ($oldCategId, $oldPos) = $m->fetchArray("
		SELECT categoryId, pos FROM $cfg->{dbPrefix}boards WHERE id = $boardId");
	$oldCategId or $m->entryError($lng->{errBrdNotFnd});

	# Check fields
	$title or $m->formError("Title is empty.");
	$categId or $m->formError("Category ID is empty or zero.");

	# Print form errors or finish action
	if (@{$m->{formErrors}}) { $m->printFormErrors() }
	else {
		# Quote strings
		my $titleQ = $m->dbQuote($m->escHtml($title));
		my $shortDescQ = $m->dbQuote($shortDesc);
		my $longDescQ = $m->dbQuote($longDesc);
		
		# Update board
		$m->dbDo("
			UPDATE $cfg->{dbPrefix}boards SET
				title      = $titleQ,
				expiration = $expiration,
				locking    = $locking,
				approve    = $approve, 
				private    = $private,
				list       = $list,
				anonymous  = $anonymous,
				unregistered = $unregistered,
				announce   = $announce,
				flat       = $flat,
				attach     = $attach,
				shortDesc  = $shortDescQ, 
				longDesc   = $longDescQ
			WHERE id = $boardId");

		# Update category and positions
		if ($categId > -1 && $pos > -1) {
			$pos = $pos - 1 if $pos > $oldPos && $categId == $oldCategId;
			$m->dbDo("
				UPDATE $cfg->{dbPrefix}boards SET 
					pos = pos - 1
				WHERE categoryId = $oldCategId
					AND pos > $oldPos");
			$m->dbDo("
				UPDATE $cfg->{dbPrefix}boards SET 
					pos = pos + 1 
				WHERE categoryId = $categId
					AND pos > $pos");
			$m->dbDo("
				UPDATE $cfg->{dbPrefix}boards SET 
					categoryId = $categId,
					pos = $pos + 1 
				WHERE id = $boardId");
		}
		
		# Log action
		$m->logAction(1, 'board', 'options', $userId, $boardId);
		
		# Redirect
		$m->redirect('board_admin');
	}
}

# Print form
if (!$submitted || @{$m->{formErrors}}) {
	# Print header
	$m->printHeader();

	# Get board
	my $board = $m->fetchHash("
		SELECT * FROM $cfg->{dbPrefix}boards WHERE id = $boardId");
	$board or $m->entryError($lng->{errBrdNotFnd});
	
	# Get categories
	my $categs = $m->fetchAllHash("
		SELECT id, title FROM $cfg->{dbPrefix}categories ORDER BY pos");

	# Print page bar
	my @navLinks = ({ url => $m->url('board_show', bid => $boardId), txt => 'comUp', ico => 'up' });
	$m->printPageBar(mainTitle => "Board", subTitle => $board->{title}, navLinks => \@navLinks);
	
	# Set submitted or database values
	$title = $submitted ? $m->escHtml($title) : $board->{title};
	$shortDesc = $submitted ? $m->escHtml($shortDesc) : $m->escHtml($board->{shortDesc});
	$longDesc = $submitted ? $m->escHtml($longDesc) : $m->escHtml($board->{longDesc});
	$locking = $submitted ? $locking : $board->{locking};
	$expiration = $submitted ? $expiration : $board->{expiration};
	$flat = $submitted ? $flat : $board->{flat};
	$attach = $submitted ? $attach : $board->{attach};
	$approve = $submitted ? $approve : $board->{approve};
	$unregistered = $submitted ? $unregistered : $board->{unregistered};
	$anonymous = $submitted ? $anonymous : $board->{anonymous};
	$private = $submitted ? $private : $board->{private};
	$list = $submitted ? $list : $board->{list};
	$announce = $submitted ? $announce : $board->{announce};

	# Determine checkbox, radiobutton and listbox states
	my $checked = "checked='checked'";
	my %state = (
		flat => $flat ? $checked : undef,
		approve => $approve ? $checked : undef,
		unregistered => $unregistered ? $checked : undef,
		anonymous => $anonymous ? $checked : undef,
		list => $list ? $checked : undef,
		"private$private" => $checked,
		"announce$announce" => $checked,
		"attach$attach" => $checked,
		"category$categId" => "selected='selected'",
	);
	$state{attach} = "disabled='disabled'" if !$cfg->{attachments};
	
	# Print options form
	print
		"<form action='board_options$m->{ext}' method='post'>\n",
		"<div class='frm'>\n",
		"<div class='hcl'>\n",
		"<span class='htt'>Options</span>\n",
		"</div>\n",
		"<div class='ccl'>\n",
		"Title (50 chars)<br/>\n",
		"<input type='text' name='title' size='40' maxlength='50' value='$title'/><br/>\n",
		"Short Description (200 chars, shown on forum page, HTML enabled)<br/>\n",
		"<input type='text' name='shortDesc' size='80' maxlength='200' value='$shortDesc'/><br/>\n",
		"Long Description (shown on board info and optionally board page, HTML enabled)<br/>\n",
		"<input type='text' name='longDesc' size='80' value='$longDesc'/><br/>\n",
		"Locking (days after that inactive topics get locked, 0 = never)<br/>\n",
		"<input type='text' name='locking' size='4' maxlength='4' value='$locking'/><br/>\n",
		"Expiration (days after that inactive topics get deleted, 0 = never)<br/>\n",
		"<input type='text' name='expiration' size='4' maxlength='4' value='$expiration'/><br/>\n",
		"Category and position<br/>\n",
		"<select name='catPos' size='1'>\n",
		"<option value='-1 -1' selected='selected'>Unchanged</option>\n";

	# Print category/position list
	for my $cat (@$categs) {
		print "<option value='$cat->{id} 0'>Top of \"$cat->{title}\"</option>\n";
		my $boards = $m->fetchAllHash("
			SELECT title, pos 
			FROM $cfg->{dbPrefix}boards 
			WHERE categoryId = $cat->{id} 
				AND id <> $boardId
			ORDER BY pos");
		print "<option value='$cat->{id} $_->{pos}'>- Below \"$_->{title}\"</option>\n" for @$boards;
	}

	print 
		"</select><br/><br/>\n",
		"Read Access:<br/>\n",
		"<label><input type='radio' name='private' value='1' $state{private1}/>",
		"Only moderators and members can read board</label><br/>\n",
		"<label><input type='radio' name='private' value='2' $state{private2}/>",
		"Only registered users can read board</label><br/>\n",
		"<label><input type='radio' name='private' value='0' $state{private0}/>",
		"Everybody can read board</label><br/>\n",
		"<label><input type='checkbox' name='list' $state{list}/>",
		"List board on forum page even if user has no access</label><br/><br/>\n",
		"Write Access:<br/>\n",
		"<label><input type='radio' name='announce' value='1' $state{announce1}/>",
		"Only moderators and members can post</label><br/>\n",
		"<label><input type='radio' name='announce' value='2' $state{announce2}/>",
		"Only moderators and members can start topics, all users can reply</label><br/>\n",
		"<label><input type='radio' name='announce' value='0' $state{announce0}/>",
		"All users can post</label><br/>\n",
		"<label><input type='checkbox' name='unregistered' $state{unregistered}/>",
		"Unregistered Posting (unregistered guests can post)</label><br/>\n",
		"<label><input type='checkbox' name='anonymous' $state{anonymous}/>",
		"Anonymous (user ID isn't saved with posts)</label><br/><br/>\n",
		"Attachments:<br/>\n",
		"<label><input type='radio' name='attach' value='0' $state{attach0}/>",
		"Disable</label><br/>\n",
		"<label><input type='radio' name='attach' value='2' $state{attach2}/>",
		"Enable uploading for admins and moderators only</label><br/>\n",
		"<label><input type='radio' name='attach' value='1' $state{attach1}/>",
		"Enable uploading for all registered users</label><br/><br/>\n",
		"Miscellaneous Options:<br/>\n",
		"<label><input type='checkbox' name='flat' $state{flat}/>",
		"Non-Threaded (no post indentation in topics)</label><br/>\n",
		"<label><input type='checkbox' name='approve' $state{approve}/>",
		"Moderation (posts have to be approved by moderators to be visible)</label><br/><br/>\n",
		$m->submitButton("Change", 'edit'),
		"<input type='hidden' name='bid' value='$boardId'/>\n",
		$m->stdFormFields(),
		"</div>\n",
		"</div>\n",
		"</form>\n\n";
	
	# Log action
	$m->logAction(3, 'board', 'options', $userId, $boardId);
	
	# Print footer
	$m->printFooter();
}
