# Copyright 2012 Tufts University 
#
# Licensed under the Educational Community License, Version 1.0 (the "License"); 
# you may not use this file except in compliance with the License. 
# You may obtain a copy of the License at 
#
# http://www.opensource.org/licenses/ecl1.php 
#
# Unless required by applicable law or agreed to in writing, software 
# distributed under the License is distributed on an "AS IS" BASIS, 
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
# See the License for the specific language governing permissions and 
# limitations under the License.


#!/usr/bin/env perl -w

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
