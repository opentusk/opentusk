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


package TUSK::Search::FTSFunctions;

use strict;

# Module filled with static methods used with MySQL's FTS
#

sub add_plusses_to_search_string{
    my ($string) = @_;

    my $fragments = [];

    # do all sorts of crazy things (meaning we put a + before any first level parans).  We only do this if they have used parans in their search.
    
    if ($string =~ /[\(\)]/){
	my @chars = split(//, $string);
	
	my $paran_fragment = '';
	my $paran_count = 0;

	foreach my $char (@chars){

	    if ($char eq '('){
		$paran_fragment .= $char;
		$paran_count++;
	    }
	    elsif ($char eq ')'){
		$paran_count--;
		$paran_fragment .= $char;
	    }elsif ($paran_count){
		$paran_fragment .= $char;
	    }
		
	    if ($paran_fragment && $paran_count == 0){
		$string =~ s/\Q$paran_fragment\E//;
		push (@$fragments, $paran_fragment);
		$paran_fragment = '';
	    }
	}
	if ($paran_fragment){
	    $string =~ s/\Q$paran_fragment\E//;
	    push (@$fragments, $paran_fragment);
	}
    }


    while ($string =~ s/("[^\"]+")//){
	push (@$fragments, $1);
    }

    $string =~ s/^ *//;
    $string =~ s/ *$//;

    push(@$fragments, split(/ +/, $string));
    
    foreach my $fragment (@$fragments){
	if ($fragment !~ /^[\+\-]/){
	    $fragment = "+" . $fragment;
	}
    }

    return join(' ', @$fragments);
}

1;
