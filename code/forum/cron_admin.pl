#!/usr/bin/env perl
use FindBin;
use lib "$FindBin::Bin/../../lib";

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
my $action = $m->paramStrId('act');
my $submitted = $m->paramBool('subm');
my $sourceAuth = $m->paramInt('auth');

# Process form
if ($submitted) {
	# Check request source authentication
	$sourceAuth == $user->{sourceAuth} or $m->formError($lng->{errSrcAuth});

	# Print form errors or finish action
	if (@{$m->{formErrors}}) { $m->printFormErrors() }
	else {
		# Execute script
		$ENV{MWF_ALLOWCGI} = 1;
		if ($action eq 'main') {
			system "perl cron_jobs$m->{ext}";
		}
		elsif ($action eq 'subs') {
			system "perl cron_subscriptions$m->{ext}";
		}
		elsif ($action eq 'bounce') {
			system "perl cron_bounce$m->{ext}";
		}
		elsif ($action eq 'rss') {
			system "perl cron_rss$m->{ext}";
		}
		$ENV{MWF_ALLOWCGI} = 0;
		
		# Redirect to cronjob admin page
		$m->redirect('cron_admin', msg => 'CronExec');
	}
}

# Print form
if (!$submitted || @{$m->{formErrors}}) {
	# Print header
	$m->printHeader();

	# Print page bar
	my @navLinks = ({ url => $m->url('forum_show'), txt => 'comUp', ico => 'up' });
	$m->printPageBar(mainTitle => "Cronjob Admin", navLinks => \@navLinks);

	# Print execution form
	print
		"<div class='frm'>\n",
		"<div class='hcl'>\n",
		"<span class='htt'>Execute Cronjobs</span>\n",
		"</div>\n",
		"<div class='ccl'>\n",
		"Note: if you execute cronjobs using this page, and a cronjob takes a long time,",
		" webservers might terminate the cronjob prematurely (default timeout on Apache is 5min).",
		" This might in the worst case leave the database in an inconsistent state.",
		" If possible, start cronjobs using an actual cron daemon resp. task scheduler.",
		"<br/><br/>\n",
		"<form action='cron_admin$m->{ext}' method='post'>\n",
		"<div>\n",
		$m->submitButton("Main Cronjob (cron_jobs)", 'cron'), "<br/>\n",
		"<input type='hidden' name='act' value='main'/>\n",
		$m->stdFormFields(),
		"</div>\n",
		"</form>\n",
		"<form action='cron_admin$m->{ext}' method='post'>\n",
		"<div>\n",
		$m->submitButton("Subscriptions (cron_subscriptions)", 'subscribe'), "<br/>\n",
		"<input type='hidden' name='act' value='subs'/>\n",
		$m->stdFormFields(),
		"</div>\n",
		"</form>\n",
		"<form action='cron_admin$m->{ext}' method='post'>\n",
		"<div>\n",
		$m->submitButton("Bounce Handler (cron_bounce)", 'subscribe'), "<br/>\n",
		"<input type='hidden' name='act' value='bounce'/>\n",
		$m->stdFormFields(),
		"</div>\n",
		"</form>\n",
		"<form action='cron_admin$m->{ext}' method='post'>\n",
		"<div>\n",
		$m->submitButton("Feed Writer (cron_rss)", 'feed'), "<br/>\n",
		"<input type='hidden' name='act' value='rss'/>\n",
		$m->stdFormFields(),
		"</div>\n",
		"</form>\n",
		"</div>\n",
		"</div>\n",
	
	# Log action
	$m->logAction(3, 'cron', 'admin', $userId);
	
	# Print footer
	$m->printFooter();
}
