#!/usr/bin/env perl
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
use Forum::MwfConfig;
use Forum::MwfMain;
use Forum::MwfCGI;

#------------------------------------------------------------------------------

# Get user
connectDb();
authUser();

# Get CGI parameters
my $cgi = new Forum::MwfCGI;
my $uid = $cgi->param('uid') || "";
my $cid = $cgi->param('cid') || "";
my $bid = $cgi->param('bid') || "";
my $tid = $cgi->param('tid') || "";
my $pid = $cgi->param('pid') || "";
my $page = $cgi->param('pg') || "";
my $origin = $cgi->param('ori') || "";
my $action = $cgi->param('action') || "";
my $name = $cgi->param('name') || "";

unless ($cfg{'confirm'} || $bid) {
	# Execute action directly
	redirect("$action?uid=$uid&cid=$cid&bid=$bid&tid=$tid&pid=$pid&pg=$page&ori=$origin");
}
else {
	# Print header
	printHeader();

	# Determine entity type	
	my $type = "";
	if    ($uid) { $type = $lng->{'cnfTypeUser'}  }
	elsif ($cid) { $type = $lng->{'cnfTypeCateg'} }
	elsif ($bid) { $type = $lng->{'cnfTypeBoard'} }
	elsif ($tid) { $type = $lng->{'cnfTypeTopic'} }
	elsif ($pid) { $type = $lng->{'cnfTypePost'}  }

	# Print confirmation form
	print
		"<BR CLEAR='all'>\n\n",
		tableStart($lng->{'cnfTitle'}),
		cellStart(),
		"$lng->{'cnfQuestion'} $type '$name'$lng->{'cnfQuestion2'}<P>\n",
		"<FORM ACTION='$action' METHOD='POST'>\n",
		"<INPUT TYPE='hidden' NAME='uid' VALUE='$uid'>\n",
		"<INPUT TYPE='hidden' NAME='cid' VALUE='$cid'>\n",
		"<INPUT TYPE='hidden' NAME='bid' VALUE='$bid'>\n",
		"<INPUT TYPE='hidden' NAME='tid' VALUE='$tid'>\n",
		"<INPUT TYPE='hidden' NAME='pid' VALUE='$pid'>\n",
		"<INPUT TYPE='hidden' NAME='pg' VALUE='$page'>\n",
		"<INPUT TYPE='hidden' NAME='ori' VALUE='$origin'>\n",
		"<INPUT TYPE='submit' VALUE='$lng->{'cnfConfirmB'}'>\n",
		"</FORM>\n",
		cellEnd(),
		tableEnd();

	# Print footer
	printFooter();
}
