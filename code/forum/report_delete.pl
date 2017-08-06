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

# Get CGI parameters
my $repUserId = $m->paramInt('uid');
my $postId = $m->paramInt('pid');
my $sourceAuth = $m->paramInt('auth');
$postId or $m->paramError($lng->{errPstIdMiss});

# Check request source authentication
$sourceAuth == $user->{sourceAuth} or $m->paramError($lng->{errSrcAuth});

# Get post
my $post = $m->fetchHash("	
	SELECT boardId, topicId FROM $cfg->{dbPrefix}posts WHERE id = $postId");
$post or $m->entryError($lng->{errPstNotFnd});

# Check if user is admin or moderator
my $boardAdmin = $user->{admin} || $m->boardAdmin($userId, $post->{boardId});
$boardAdmin or $m->adminError();

# Remove post from list
$m->dbDo("
	DELETE FROM $cfg->{dbPrefix}postReports 
	WHERE userId = $repUserId
		AND postId = $postId");

# Log action
$m->logAction(1, 'report', 'delete', $userId, $post->{boardId}, $post->{topicId}, $postId);

# Redirect back to list
$m->redirect('report_list', msg => 'PstRemRep');
