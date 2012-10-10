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
