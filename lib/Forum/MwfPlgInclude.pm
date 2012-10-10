#------------------------------------------------------------------------------
#    mwForum - Web-based discussion forum
#    Copyright (c) 1999-2007 Markus Wichitill
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
#------------------------------------------------------------------------------

package MwfPlgInclude;
use strict;
use warnings;
no warnings qw(uninitialized redefine);
$MwfPlgInclude::VERSION = "2.7.1";

# Imports
use Forum::MwfMain;
use HTML::Mason::Interp;
use TUSK::Session;
use Data::Dumper;

$ENV{SCRIPT_FILENAME} =~ m/^(.*?)\/forum/;

my $comp_root = $1 . "/tusk/tmpl";

#------------------------------------------------------------------------------
# Print additional HTTP header lines

sub httpHeader
{
	my %params = @_;
	my $m = $params{m};

	if (MwfMain::MP) {
		$m->{ap}->headers_out->{'X-Foobar'} = 'foobar';
	}
	else {
		print	"X-Foobar: foobar\n";
	}
}

#------------------------------------------------------------------------------
# Print additional HTML header lines

sub htmlHeader
{
	my %params = @_;
	my $m = $params{m};

	print
		"<link rel='shortcut icon' href='/favicon.ico' type='image/x-icon'/>\n";
}

#------------------------------------------------------------------------------
# Print stuff at the top of the page

sub top
{
	my %params = @_;
	my $m = $params{m};
	my $cfg = $m->{cfg};


	my ($count, $is_author) = $m->fetchArray("SELECT count(*), value FROM $cfg->{dbPrefix}variables WHERE userId = $m->{user}->{id} AND name = 'is_author' GROUP BY value");

	if ($count != 1) {
	    $is_author = TUSK::Session::is_author({}, $m->{user_object});
	    $m->dbDo("INSERT INTO $cfg->{dbPrefix}variables (name, userId, value)
		VALUES ('is_author', $m->{user}->{id}, '$is_author')");
	}



	my $interp = HTML::Mason::Interp->new( comp_root => $comp_root );

	my $output = '';

	$interp->out_method(\$output);

	my $args = {
	    user => $m->{user_object},
	    nav_bar => [],
	    jsarray => [],
	    stylearray => [],
	    pagetitle => 'Title',
	    leftnav  => '',
	    type_path => '',
	    redHeaderBarText => 'Title',
	    headerimages => [],
	    noheader => 0,
	    nobody => 0,
	    form => '',
	    extratext => '',
	    check_timeperiod => 0,
	    displayLittleUserNavBar => 1,
	    top_tab_type => '',
	    metaData => [],
	    preRedHeaderText => '',
	    headerBarClass => '',
	    is_author => $is_author,
	    skip_header_bar => 1,
	    skip_head_tag => 1,
	};

	$interp->exec( '/prepend', req_hash => $args);

	print $output . "\n";

	    # Print static text
	#print "<a href='http://victor.tusk.tufts.edu'>HOME</a><br>";
}

#------------------------------------------------------------------------------
# Print stuff below the forum's top bar

sub middle
{
	my %params = @_;
	my $m = $params{m};

	# Only on forum page
	#if ($m->{env}{script} eq 'forum_show') {
	#    print "<div class='frm'><div class='hcl'>icon descriptions go here? this only shows up on the forum page</div></div>";
	#}
	
}

#------------------------------------------------------------------------------
# Print stuff at the bottom of the page

sub bottom
{
	my %params = @_;
	my $m = $params{m};
	my $lng = $m->{lng};
	my $env = $m->{env};
	my $envScript = $m->{env}->{script};

	print "
<div class='frm'>
<div class='hcl'>
<span class='nav'>
</span>
";

	if ($envScript eq "forum_show") {
	    print "
Board Icon Key
</div>
<div class='bcl'>
<div class='nbl'>
<img class='bic' src='$m->{stylePath}/board_nu.png' title='$lng->{comNewUnrdTT}' alt='$lng->{comOldRead}'/> New-Unread &nbsp&nbsp
<img class='bic' src='$m->{stylePath}/board_nr.png' title='$lng->{comNewUnrdTT}' alt='$lng->{comOldRead}'/> New-Read &nbsp&nbsp
<img class='bic' src='$m->{stylePath}/board_ou.png' title='$lng->{comNewUnrdTT}' alt='$lng->{comOldRead}'/> Old-Unread &nbsp&nbsp
<img class='bic' src='$m->{stylePath}/board_or.png' title='$lng->{comNewUnrdTT}' alt='$lng->{comOldRead}'/> Old-Read &nbsp&nbsp
";
	}
	elsif ($envScript eq "board_show") {
	    print "
Thread Icon Key
</div>
<div class='bcl'>
<div class='nbl'>
<img class='bic' src='$m->{stylePath}/topic_nu.png' title='$lng->{comNewUnrdTT}' alt='$lng->{comOldRead}'/> New-Unread &nbsp&nbsp
<img class='bic' src='$m->{stylePath}/topic_nr.png' title='$lng->{comNewUnrdTT}' alt='$lng->{comOldRead}'/> New-Read &nbsp&nbsp
<img class='bic' src='$m->{stylePath}/topic_ou.png' title='$lng->{comNewUnrdTT}' alt='$lng->{comOldRead}'/> Old-Unread &nbsp&nbsp
<img class='bic' src='$m->{stylePath}/topic_or.png' title='$lng->{comNewUnrdTT}' alt='$lng->{comOldRead}'/> Old-Read &nbsp&nbsp
";
	}
	elsif ($envScript eq "topic_show") {
	    print "
Post Icon Key
</div>
<div class='bcl'>
<div class='nbl'>
<img class='bic' src='$m->{stylePath}/post_nu.png' title='$lng->{comNewUnrdTT}' alt='$lng->{comOldRead}'/> New-Unread &nbsp&nbsp
<img class='bic' src='$m->{stylePath}/post_nr.png' title='$lng->{comNewUnrdTT}' alt='$lng->{comOldRead}'/> New-Read &nbsp&nbsp
<img class='bic' src='$m->{stylePath}/post_ou.png' title='$lng->{comNewUnrdTT}' alt='$lng->{comOldRead}'/> Old-Unread &nbsp&nbsp
<img class='bic' src='$m->{stylePath}/post_or.png' title='$lng->{comNewUnrdTT}' alt='$lng->{comOldRead}'/> Old-Read &nbsp&nbsp
";	    
	}

	print "</div></div></div>";


	# Load text from database
	#my $adtext = $m->fetchArray("SELECT adtext FROM ads WHERE foo = bar");
	#print	$adtext;

	my $interp = HTML::Mason::Interp->new( comp_root => $comp_root );

	my $output = '';

	$interp->out_method(\$output);

	$interp->exec( '/footer');

	print $output . "\n";
}

#-----------------------------------------------------------------------------
1;
