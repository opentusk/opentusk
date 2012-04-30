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
my $parentId = int($cgi->param('pid'));
my $page = ($cgi->param('pg') && int($cgi->param('pg'))) ? int($cgi->param('pg')) : 1;
my $origin = $cgi->param('ori');
$parentId or paramError($lng->{'errPrtIdMiss'});

# Get parent post
my $query = "SELECT * FROM posts WHERE id = $parentId";
my $sth = query($query);
my $parent = $sth->fetchrow_hashref();
$parent or entryError($lng->{'errPrtNotFnd'});

# Get board
$query = "SELECT * FROM boards WHERE id = $parent->{'boardId'}";
$sth = query($query);
my $board = $sth->fetchrow_hashref();
my $boardAdmin = boardAdmin($user->primary_key, $board->{'id'});

# Get topic
$query = "SELECT * FROM topics WHERE id = $parent->{'topicId'}";
$sth = query($query);
my $topic = $sth->fetchrow_hashref();

# Check authorization
checkAuthz($user, 'newPost', $parent, $topic, $board);

# Check if user can see board
boardVisible($board, $boardAdmin) or entryError($lng->{'errBrdNotFnd'});

# Check if topic is locked
!$topic->{'locked'} || $user->{'admin'} || $boardAdmin
	or userError($lng->{'errTpcLocked'});

# Print bar
my @bar = (
	"topic_show.pl?tid=$parent->{'topicId'}#$parentId", "comUp", 1,
);
printBar($lng->{'rplTitle'}, $topic->{'subject'}, \@bar);

# Quote parent post body
my $quoted = undef;
if ($cfg{'quote'} 
	and $board->{'flat'} || $cfg{'quoteThreaded'} 
	and eval { require Mail::QuoteWrap }) 
{
	eval {  # Catch QuoteWrap fatal bugs
		my $parentCopy = { 'body' => $parent->{'body'} };
		dbToEdit($board, $parentCopy);
		my @unquoted = split("\n", $parentCopy->{'body'});
		@unquoted = grep(!/^\s+$/, @unquoted);  # QuoteWrap bug workaround
		my $quote = Mail::QuoteWrap->create(\@unquoted, $cfg{'quoteCols'}, 
			'>', '>', { 'leftMargin' => 1 });
		$quote->quotify();
		$quote->format();
		$quoted = join("\n", @{$quote->text()});
	}
}

# Prepare other values
dbToDisplay($board, $parent);
my $editWidth = $cfg{'editWidth'};
my $editHeight = $cfg{'editHeight'};
my $notifyChecked = $user->{'notify'} == 2 ? "CHECKED" : "";
$quoted = "" unless ($quoted);
$origin = "" unless ($origin);

# Print reply form
print
	"<BR>\n\n",
	tableStart($lng->{'rplReplyTtl'}),
	cellStart(),
	"<FORM ACTION='post_reply_x.pl' METHOD='post' onsubmit=\"return checkform(this);\">\n",
	"$lng->{'rplReplyBody'}<BR>\n",
	"<TEXTAREA COLS=$editWidth ROWS=$editHeight NAME='body' WRAP='soft'>$quoted</TEXTAREA><P>\n",
	"<INPUT TYPE='submit' VALUE='$lng->{'rplReplyB'}'> &nbsp;&nbsp;\n",
	#"<INPUT TYPE='checkbox' NAME='notify' $notifyChecked>$lng->{'rplReplyNtfy'}\n",
	"<INPUT TYPE='hidden' NAME='pid' VALUE='$parentId'>\n",
	"<INPUT TYPE='hidden' NAME='pg' VALUE='$page'>\n",
	"<INPUT TYPE='hidden' NAME='ori' VALUE='$origin'>\n",
	"</FORM>\n",
	cellEnd(),
	tableEnd();

# Print parent post
print
	"<BR>\n\n",
	tableStart($lng->{'rplReplyResp'}),
	cellStart(),
	"$parent->{'body'}\n",
	cellEnd(),
	tableEnd();

# Log action
logAction(3, 'post', 'reply', $user->primary_key, $board->{'id'}, $topic->{'id'}, 0, $parentId);

# Print footer
printFooter();

