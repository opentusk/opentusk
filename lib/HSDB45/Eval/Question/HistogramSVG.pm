package HSDB45::Eval::Question::HistogramSVG;

use strict;
use base ('Exporter');
use vars ('@EXPORT');

@EXPORT = qw/make_histogram_svg/;
use SVG;
use HSDB45::Eval::Results;
use HSDB45::Eval::Question::Results;

# Description: Draws a histogram
# Input: A ResponseStatistics object
# Output: SVG text
sub make_histogram_svg {
    my $stats = shift;
    die "Improper input object"
	unless $stats->isa('HSDB45::Eval::Question::Results');

    my $svg = SVG->new( width=>70, height=>50 );
    my $axes = $svg->group( id => 'axes',
			    style => { opacity => 1,
				       stroke => "black",
				       stroke-opacity => 1 } );
    $axes->line( id => 'xaxis',
		 x1 => 10, y1 => 10, x2 => 190, y2 => 10 );
    
    return $svg->xmlify();
}


1;
__END__;
