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
my ($script) = $m->paramStr('script') =~ /^([a-zA-Z1-9_]+)$/;
my $act = $m->paramStrId('act');
my $uid = $m->paramInt('uid');
my $gid = $m->paramInt('gid');
my $cid = $m->paramInt('cid');
my $bid = $m->paramInt('bid');
my $tid = $m->paramInt('tid');
my $pid = $m->paramInt('pid');
my $mid = $m->paramInt('mid');
my $pollId = $m->paramInt('pollId');
my $name = $m->paramStr('name');
my $notify = $m->paramBool('notify');

# Print header
$m->printHeader();

# Determine entity type	
my $entity = "";
if ($pollId) { $entity = $lng->{cnfTypePoll} }
elsif ($uid) { $entity = $lng->{cnfTypeUser} }
elsif ($gid) { $entity = $lng->{cnfTypeGroup} }
elsif ($cid) { $entity = $lng->{cnfTypeCateg} }
elsif ($bid) { $entity = $lng->{cnfTypeBoard} }
elsif ($tid) { $entity = $lng->{cnfTypeTopic} }
elsif ($pid) { $entity = $lng->{cnfTypePost} }
elsif ($mid) { $entity = $lng->{cnfTypeMsg} }

# Determine question
my $question = "";
if ($entity) {
	$name = $m->deescHtml($name);
	$name = $m->escHtml($name);
	$question = "$lng->{cnfQuestion} $entity \"$name\"$lng->{cnfQuestion2}";
}
elsif ($script eq 'message_delete') {
	$question = $lng->{cnfDelAllMsg};
}
elsif ($script eq 'chat_delete') {
	$question = $lng->{cnfDelAllCht};
}

# Print confirmation form
print
	"<form action='$script$m->{ext}' method='post'>\n",
	"<div class='frm'>\n",
	"<div class='hcl'>\n",
	"<span class='htt'>$lng->{cnfTitle}</span>\n",
	"</div>\n",
	"<div class='ccl'>\n",
	"$question<br/><br/>\n";
	
my $checked = $cfg->{noteDefMod} ? "checked='checked'" : "";
print
	"<label><input type='checkbox' name='notify' $checked/>$lng->{notNotify}</label><br/>\n",
	"<input type='text' name='reason' size='80'/><br/><br/>\n"
	if $notify;
	
print
	$m->submitButton('cnfDeleteB', 'delete'),
	"<input type='hidden' name='act' value='$act'/>\n",
	"<input type='hidden' name='uid' value='$uid'/>\n",
	"<input type='hidden' name='gid' value='$gid'/>\n",
	"<input type='hidden' name='cid' value='$cid'/>\n",
	"<input type='hidden' name='bid' value='$bid'/>\n",
	"<input type='hidden' name='tid' value='$tid'/>\n",
	"<input type='hidden' name='pid' value='$pid'/>\n",
	"<input type='hidden' name='mid' value='$mid'/>\n",
	"<input type='hidden' name='pollId' value='$pollId'/>\n",
	$m->stdFormFields(),
	"</div>\n",
	"</div>\n",
	"</form>\n\n";

# Print footer
$m->printFooter();
