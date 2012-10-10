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
my $categId = $m->paramInt('cid');
my $title = $m->paramStr('title');
my $pos = $m->paramInt('pos');
my $submitted = $m->paramBool('subm');
my $sourceAuth = $m->paramInt('auth');
$categId or $m->paramError($lng->{errCatIdMiss});

# Process form
if ($submitted) {
	# Check request source authentication
	$sourceAuth == $user->{sourceAuth} or $m->formError($lng->{errSrcAuth});

	# Get category
	my $oldPos = $m->fetchArray("
		SELECT pos FROM $cfg->{dbPrefix}categories WHERE id = $categId");
	$oldPos or $m->entryError($lng->{errCatNotFnd});

	# Check fields
	$title or $m->formError("Title is empty.");

	# Print form errors or finish action
	if (@{$m->{formErrors}}) { $m->printFormErrors() }
	else {
		# Update category
		my $titleQ = $m->dbQuote($m->escHtml($title));
		$m->dbDo("
			UPDATE $cfg->{dbPrefix}categories SET title = $titleQ WHERE id = $categId");

		# Update positions
		if ($pos > -1) {
			$pos = $pos - 1 if $pos > $oldPos;
			$m->dbDo("
				UPDATE $cfg->{dbPrefix}categories SET pos = pos - 1 WHERE pos > $oldPos");
			$m->dbDo("
				UPDATE $cfg->{dbPrefix}categories SET pos = pos + 1 WHERE pos > $pos");
			$m->dbDo("
				UPDATE $cfg->{dbPrefix}categories SET pos = $pos + 1 WHERE id = $categId");
		}
		
		# Log action
		$m->logAction(1, 'categ', 'options', $userId, 0, 0, 0, $categId);
		
		# Redirect
		$m->redirect('categ_admin');
	}
}

# Print form
if (!$submitted || @{$m->{formErrors}}) {
	# Print header
	$m->printHeader();

	# Get category
	my $categ = $m->fetchHash("
		SELECT title, pos FROM $cfg->{dbPrefix}categories WHERE id = $categId");
	$categ or $m->entryError($lng->{errCatNotFnd});
	
	# Get other categories
	my $categs = $m->fetchAllHash("
		SELECT title, pos FROM $cfg->{dbPrefix}categories WHERE id <> $categId ORDER BY pos");

	# Print page bar
	my @navLinks = ({ url => $m->url('categ_admin'), txt => 'comUp', ico => 'up' });
	$m->printPageBar(mainTitle => "Category", navLinks => \@navLinks);

	# Set submitted or database values
	$title = $submitted ? $m->escHtml($title) : $categ->{title};
	
	# Print options form
	print
		"<form action='categ_options$m->{ext}' method='post'>\n",
		"<div class='frm'>\n",
		"<div class='hcl'>\n",
		"<span class='htt'>Options</span>\n",
		"</div>\n",
		"<div class='ccl'>\n",
		"Title (50 chars)<br/>\n",
		"<input type='text' name='title' size='40' maxlength='50' value='$title'/><br/>\n",
		"Position<br/>\n",
		"<select name='pos' size='1'>\n",
		"<option value='-1' selected='selected'>Unchanged</option>\n",
		"<option value='0'>Top</option>\n";

	print "<option value='$_->{pos}'>Below \"$_->{title}\"</option>\n" for @$categs;

	print
		"</select><br/><br/>\n",
		$m->submitButton("Change", 'edit'),
		"<input type='hidden' name='cid' value='$categId'/>\n",
		$m->stdFormFields(),
		"</div>\n",
		"</div>\n",
		"</form>\n\n";
	
	# Log action
	$m->logAction(3, 'categ', 'options', $userId, 0, 0, 0, $categId);
	
	# Print footer
	$m->printFooter();
}
