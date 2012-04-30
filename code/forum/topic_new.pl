#!/usr/bin/perl
#------------------------------------------------------------------------------
#    mwForum - Web-based discussion forum
#    Copyright (c) 1999-2001 Markus Wichitill <mwforum@mawic.de>
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#------------------------------------------------------------------------------

use strict;

# Imports
use CGI::Carp qw(fatalsToBrowser);
use DBI;
use Forum::MwfConfig;
use Forum::MwfMain;
use Forum::MwfCGI;

#------------------------------------------------------------------------------

# Get user
connectDb();
authUser();

# Print header
printHeader();

# Check if user is registered, not banned and not blocked
$user->{'default'} and regError();
checkBan($user->primary_key);
checkBlock();

# Get CGI parameters
my $cgi = new Forum::MwfCGI;
my $boardId = int($cgi->param('bid'));
$boardId or paramError($lng->{'errBrdIdMiss'});

# Get board
my $query = "SELECT * FROM boards WHERE id = $boardId";
my $sth = query($query);
my $board = $sth->fetchrow_hashref();
$board or entryError($lng->{'errBrdNotFnd'});

# Check authorization
checkAuthz($user, 'newTopic', $board);

# Check if user can see board
boardVisible($board) or entryError($lng->{'errBrdNotFnd'});

# Print bar
my @bar = (
	"board_show.pl?bid=$boardId", "comUp", 1
);
printBar($lng->{'ntpTitle'}, $board->{'title'}, \@bar);

# Prepare values
my $editWidth = $cfg{'editWidth'};
my $editHeight = $cfg{'editHeight'};
my $notifyChecked = $user->{'notify'} ? "CHECKED" : "";

# Print new post form
print
	"<BR>\n\n",
	tableStart($lng->{'ntpTpcTtl'}),
	cellStart(),
	"<FORM ACTION='topic_new_x.pl' METHOD='post' onsubmit=\"return checkform(this);\">\n",
	"$lng->{'ntpTpcSbj'}<BR>\n",
	"<INPUT TYPE='text' NAME='subject' SIZE=$editWidth MAXLENGTH='$cfg{'maxSubjectLen'}'><P>\n",
	"$lng->{'ntpTpcBody'}<BR>\n",
	"<TEXTAREA COLS=$editWidth ROWS=$editHeight NAME='body' WRAP='soft'></TEXTAREA><P>\n",
	"<INPUT TYPE='submit' VALUE='$lng->{'ntpTpcB'}'> &nbsp;&nbsp;\n",
	#"<INPUT TYPE='checkbox' NAME='notify' $notifyChecked>$lng->{'ntpTpcNtfy'}\n",
	"<INPUT TYPE='hidden' NAME='bid' VALUE='$boardId'>\n",
	"</FORM>\n",
	cellEnd(),
	tableEnd();

# Log action
logAction(3, 'topic', 'new', $user->primary_key, $boardId);

# Print footer
printFooter();
