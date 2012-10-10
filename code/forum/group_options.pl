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
my $groupId = $m->paramInt('gid');
my $title = $m->paramStr('title');
my $submitted = $m->paramBool('subm');
my $sourceAuth = $m->paramInt('auth');
$groupId or $m->paramError($lng->{errGrpIdMiss});

# Process form
if ($submitted) {
	# Check request source authentication
	$sourceAuth == $user->{sourceAuth} or $m->formError($lng->{errSrcAuth});

	# Check fields
	$title or $m->formError("Title is empty.");

	# Print form errors or finish action
	if (@{$m->{formErrors}}) { $m->printFormErrors() }
	else {
		# Update group
		my $titleQ = $m->dbQuote($m->escHtml($title));
		$m->dbDo("
			UPDATE $cfg->{dbPrefix}groups SET title = $titleQ WHERE id = $groupId");
		
		# Log action
		$m->logAction(1, 'group', 'options', $userId, 0, 0, 0, $groupId);
		
		# Redirect
		$m->redirect('group_admin');
	}
}

# Print form
if (!$submitted || @{$m->{formErrors}}) {
	# Print header
	$m->printHeader();

	# Get group
	my $group = $m->fetchHash("
		SELECT title FROM $cfg->{dbPrefix}groups WHERE id = $groupId");
	$group or $m->entryError($lng->{errCatNotFnd});

	# Print page bar
	my @navLinks = ({ url => $m->url('group_admin'), txt => 'comUp', ico => 'up' });
	$m->printPageBar(mainTitle => "Group", subTitle => $group->{title}, navLinks => \@navLinks);
	
	# Set submitted or database values
	$title = $submitted ? $m->escHtml($title) : $group->{title};
	
	# Print options form
	print
		"<form action='group_options$m->{ext}' method='post'>\n",
		"<div class='frm'>\n",
		"<div class='hcl'>\n",
		"<span class='htt'>Options</span>\n",
		"</div>\n",
		"<div class='ccl'>\n",
		"Title (50 chars)<br/>\n",
		"<input type='text' name='title' size='40' maxlength='50' value='$title'/><br/><br/>\n",
		$m->submitButton("Change", 'edit'),
		"<input type='hidden' name='gid' value='$groupId'/>\n",
		$m->stdFormFields(),
		"</div>\n",
		"</div>\n",
		"</form>\n\n";
	
	# Log action
	$m->logAction(3, 'group', 'options', $userId, 0, 0, 0, $groupId);
	
	# Print footer
	$m->printFooter();
}
