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
use Apache::Request;
use Apache::Constants qw(REDIRECT);

#------------------------------------------------------------------------------

# Init
my ($m, $cfg, $lng, $user) = MwfMain->new(@_);
my $userId = $user->{id};

# Check if access should be denied
$userId or $m->regError();
$m->checkBan($userId);
$m->checkBlock();

# Get CGI parameters
my $action = $m->paramStrId('act');
my $time = $m->paramInt('time');
my $sourceAuth = $m->paramInt('auth');
my $redirect_to_home = $m->paramInt('redirect_to_home');

# Check request source authentication
$sourceAuth == $user->{sourceAuth} or $m->paramError($lng->{errSrcAuth});

if ($action eq 'old') {
	# Mark messages as old by setting prevOnTime
	$m->dbDo("
		UPDATE $cfg->{dbPrefix}users SET prevOnTime = $time WHERE id = $userId");

	# Log action
	$m->logAction(1, 'user', 'markold', $userId);
}
elsif ($action eq 'read') {
	# Mark messages as read by setting fakeReadTime
	$m->dbDo("
		UPDATE $cfg->{dbPrefix}users SET fakeReadTime = $time WHERE id = $userId");

	# Log action
	$m->logAction(1, 'user', 'markread', $userId);
}
else { $m->paramError($lng->{errParamMiss}) }

# Redirect to user admin page
if ($redirect_to_home){
    my $r = Apache->request();
    $r->header_out(Location => '/?msg=All+discussions+messages+are+now+marked+as+read' );
    $r->status(REDIRECT);
}
else{
    $m->redirect('forum_show', msg => $action eq 'old' ? 'MarkOld' : 'MarkRead');
}

