package HSDB45::Eval::Question::ResponseStatistics;

use strict;
#use XML::Twig;
use HSDB45::Eval::Question::ResponseGroup;
use HSDB45::Eval::Question::Histogram;
use vars qw($VERSION);

$VERSION = do { my @r = (q$Revision: 1.17 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
sub version { return $VERSION; }

my @mod_deps  = ('HSDB45::Eval::Question::ResponseGroup',
		 'HSDB45::Eval::Question::Histogram');
my @file_deps = ();

sub get_mod_deps {
    return @mod_deps;
}

sub get_file_deps {
    return @file_deps;
}

# Description: Constructor
# Input: HSDB45::Eval::Question::ResponseGroup object
# Output: Newly created HSDB45::Eval::Question::ResponseStatistics object
sub new {
    my $class = shift;
    $class = ref $class || $class;
    my $self = {};
    bless $self, $class;
    return $self->init (@_);
}

sub init {
    my $self = shift;
    $self->{-response_group} = shift;
    # First, get the counts
    $self->{-count} = $self->response_group()->interpreted_responses() || 0;
    $self->{-na_count} = $self->response_group()->undef_responses() || 0;

    # If the group is numeric then make statistics
    if ($self->is_numeric () && $self->count() > 0) {
	my $sum = 0;
	for my $resp ($self->response_group()->interpreted_responses()) {
	    $sum += $resp;
	}
	$self->{-mean} = sprintf( "%.2f", ($sum / $self->count ()) );
	$sum = 0;
	for my $resp ($self->response_group()->interpreted_responses()) { 
	    my $diff = $resp - $self->mean;
	    $sum += $diff * $diff;
	}
	if ($self->count() > 1) {
	    $self->{-standard_deviation} = sqrt ($sum / ($self->count () - 1));
	}
	# median (50), 25 & 75%
	my @responses = sort { $a <=> $b } $self->response_group()->interpreted_responses();
	my $count = scalar(@responses);
	my $midIndex = $count/2;
	my $quaterIndex = $count/4;
	my $threeQuaterIndex = ($count * 3)/4;

	if($count % 2) {
		$self->{-median25} = $responses[int($quaterIndex)];
		$self->{-median}   = $responses[int($midIndex)];
		$self->{-median75} = $responses[int($threeQuaterIndex)];
	} else {
		$self->{-median25} = ($responses[int($quaterIndex)] + $responses[int($quaterIndex+1)]) / 2;
		$self->{-median}   = ($responses[int($midIndex)] + $responses[int($midIndex + 1)]) / 2;
		$self->{-median75} = ($responses[int($threeQuaterIndex)] + $responses[int($threeQuaterIndex+1)]) / 2;
	}

	# Mode
	my %modeValues;
	foreach (@responses) {  $modeValues{$_}++;  }
	my $max = 0;
	foreach my $value (keys %modeValues) {
		if($modeValues{$value} > $max) {
			$self->{-mode} = $value;
			$max = $modeValues{$value};
		}
	}
    }

    # If the group is multi_binnable, then make a histogram for that
    if ($self->is_multibinnable()) {
	my @choices = $self->response_group()->parent_results()->question()->body()->choices();
	$self->{-histogram} = HSDB45::Eval::Question::Histogram->new(\@choices);
	for my $resp ($self->response_group()->interpreted_responses()) {
	    # Multiple responses (even interpreted ones) are separated by tabs
	    for my $subresp (split /\t/, $resp) {
		$self->histogram()->add_response( $subresp );
	    }
	}
    }
    # If the group is binnable then make a histogram
    elsif ($self->is_binnable()) {
	my @choices = $self->response_group()->parent_results()->question()->body()->choices();
	$self->{-histogram} = HSDB45::Eval::Question::Histogram->new(\@choices);
	for my $resp ( $self->response_group()->interpreted_responses() ) {
	    $self->histogram()->add_response( $resp );
	}
    }

    return $self;
}

sub response_group {
    my $self = shift;
    return $self->{-response_group};
}

sub is_binnable {
    my $self = shift;
    return $self->response_group ()->parent_results ()->is_binnable ();
}

sub is_multibinnable {
    my $self = shift;
    return $self->response_group ()->parent_results ()->is_multibinnable ();
}

sub is_numeric {
    my $self = shift;
    return $self->response_group ()->parent_results ()->is_numeric ();
}

sub count {
    my $self = shift;
    return $self->{-count};
}

sub na_count {
    my $self = shift;
    return $self->{-na_count};
}

sub histogram {
    my $self = shift;
    return $self->{-histogram};
}

sub mean {
    my $self = shift;
    return $self->{-mean};
}

sub standard_deviation {
    my $self = shift;
    return $self->{-standard_deviation};
}

sub mode {
	my $self = shift;
	return $self->{-mode};
}

sub median {
	my $self = shift;
	return $self->{-median};
}

sub median25 {
	my $self = shift;
	return $self->{-median25};
}

sub median75 {
	my $self = shift;
	return $self->{-median75};
}

1;
__END__
