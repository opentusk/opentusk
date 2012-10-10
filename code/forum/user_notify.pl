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
my $recvId = $m->paramInt('uid');
my $body = $m->paramStr('body');
my $submitted = $m->paramBool('subm');
my $sourceAuth = $m->paramInt('auth');

# Fake board
my $board = { flat => 1 };

# Process form
if ($submitted) {
	# Check request source authentication
	$sourceAuth == $user->{sourceAuth} or $m->formError($lng->{errSrcAuth});

	# Translate text
	my $note = { isNote => 1, body => $body };
	$m->editToDb($board, $note);
	
	# Print form errors or finish action
	if (@{$m->{formErrors}}) { $m->printFormErrors() }
	else {
		# Insert notification message
		$m->addNote($recvId, $note->{body});
			
		# Log action
		$m->logAction(1, 'note', 'add', $userId, 0, 0, 0, $recvId);
		
		# Redirect back to message list
		$m->redirect('user_info', uid => $recvId);
	}
}

# Print form
if (!$submitted || @{$m->{formErrors}}) {
	# Print header
	$m->printHeader();

	# Print page bar
	my @navLinks = ({ url => $m->url('message_list'), txt => 'comUp', ico => 'up' });
	$m->printPageBar(mainTitle => "Notification Message", navLinks => \@navLinks);
	
	# Prepare other values
	$body = $m->escHtml($body, 1) if $body;
	
	# Print notification message form
	print
		"<form action='user_notify$m->{ext}' method='post'>\n",
		"<div class='frm'>\n",
		"<div class='hcl'>\n",
		"<span class='htt'>Send Notification Message</span>\n",
		"</div>\n",
		"<div class='ccl'>\n",
		"Text<br/>\n",
		"<textarea name='body' cols='80' rows='3'>$body</textarea><br/>\n",
		"<br/>\n",
		$m->submitButton('Send', 'write', 'add'),
		"<input type='hidden' name='uid' value='$recvId'/>\n",
		$m->stdFormFields(),
		"</div>\n",
		"</div>\n",
		"</form>\n\n";

	# Log action
	$m->logAction(3, 'note', 'add', $userId, 0, 0, 0, $recvId);
	
	# Print footer
	$m->printFooter();
}
