#!/usr/bin/perl -w

use strict;

use MySQL::Password;
HSDB4::Constants::set_user_pw (get_user_pw);
use HSDB4::SQLRow::User;

my $user = HSDB4::SQLRow::User->new()->lookup_key('psilev01');

use HTML::Mason;

use FindBin;

print "Content-type: text/html\n\n";

$ENV{SCRIPT_FILENAME} =~ m/^(.*?)\/forum/;

my $comp_root = $1 . "/tusk/tmpl";

my $interp = HTML::Mason::Interp->new( comp_root => $comp_root );

my $output = '';

$interp->out_method(\$output);

my $args = {
    user => $user,
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
    displayLittleUserNavBar => 0,
    top_tab_type => '',
    metaData => [],
    preRedHeaderText => '',
    headerBarClass => '',
    is_author => 1,
};


$interp->exec( '/prepend', %$args);

print $output . "\n";
print <<EOF;
dw<br>
d<br>
w<br>
dw<br>
dwdw<br>
EOF
