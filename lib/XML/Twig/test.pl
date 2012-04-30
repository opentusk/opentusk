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


#!/usr/bin/perl -w

use strict;
use XML::Twig;
use XML::Twig::Compare;
use Test::Unit;

my ($twig, $base_elt, $test_elt);
sub set_up {
    $twig = XML::Twig->new ();
    $twig->parsefile ('base_test.xml');
    $base_elt = $twig->first_elt ();
}

sub make_elt {
    my $filename = shift;
    $twig->parsefile ($filename);
    $test_elt = $twig->first_elt ();
}

sub test_identity {
    make_elt ('base_test.xml');
    assert (compare_elts ($base_elt, $test_elt), 
	    "Same Elt failed to compare true.");
}

sub test_att_order {
    make_elt ('att_order.xml');
    assert (compare_elts ($base_elt, $test_elt), 
	    "Elts with switched attributes failed to compare true.");
}

sub test_comment_space {
    make_elt ('comment_space.xml');
    assert (compare_elts ($base_elt, $test_elt), 
	    "Elts which differ by space and comments failed to compare true.");
}

sub test_add_att {
    make_elt ('add_att.xml');
    assert (! compare_elts ($base_elt, $test_elt), 
	    "Elts with an added attribute failed to compare false.");
}

sub test_add_child {
    make_elt ('add_child.xml');
    assert (! compare_elts ($base_elt, $test_elt), 
	    "Elts with an added child failed to compare false.");
}

sub test_add_text {
    make_elt ('add_text.xml');
    assert (! compare_elts ($base_elt, $test_elt), 
	    "Elts with added text failed to compare false.");
}

sub test_change_att {
    make_elt ('change_att.xml');
    assert (! compare_elts ($base_elt, $test_elt), 
	    "Elts with different attribute values failed to compare false.");
}

sub test_change_child_gi {
    make_elt ('change_child_gi.xml');
    assert (! compare_elts ($base_elt, $test_elt), 
	    "Elts with change child GI's failed to compare false.");
}

sub test_change_text {
    make_elt ('change_text.xml');
    assert (! compare_elts ($base_elt, $test_elt), 
	    "Elts with change text failed to compare false.");
}

sub test_child_order {
    make_elt ('child_order.xml');
    assert (! compare_elts ($base_elt, $test_elt), 
	    "Elts with changed child order failed to compare false.");
}

sub test_delete_att {
    make_elt ('delete_att.xml');
    assert (! compare_elts ($base_elt, $test_elt), 
	    "Elts with deleted attributes failed to compare false.");
}

sub test_remove_child {
    make_elt ('remove_child.xml');
    assert (! compare_elts ($base_elt, $test_elt), 
	    "Elts with removed children failed to compare false.");
}

create_suite ();
run_suite ();

1;
