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


package HSDB45::Eval::Question::Body::Count;

use strict;
use base qw(HSDB45::Eval::Question::Body);
use POSIX;

# INPUT:  none
# OUTPUT: the choice style of the question
# EFFECT: none
sub choice_style {
    my $self = shift();
    my $style =  $self->elt()->att('choice_style');
    return $style || 'radiobox';
}

# INPUT:  none
# OUTPUT: the choice alignment of the question
# EFFECT: none
sub choice_align {
    my $self = shift();
    my $style =  $self->elt()->att('choice_align');
    return $style || 'horizontal';
}

sub set_choice_style_align {
    my $self = shift;
    my ($style, $align) = @_;

    # Validation
    if ($style ne 'radiobox' && $style ne 'dropdown') {
	return (0, "Style argument must be \"radiobox\" or \"dropdown\".");
    }
    if ($align ne 'horizontal' && $align ne 'vertical') {
	return (0, "Align argument must be \"horizontal\" or \"vertical\".");
    }

    # Set the attributes
    $self->elt()->set_att('choice_align' => $align);
    $self->elt()->set_att('choice_style' => $style);
    $self->question()->set_field_values('body', $self->elt()->sprint());

    return wantarray ? (1, '') : 1;
}

sub low_bound {
    my $self = shift;
    if (my $elt = $self->elt()->first_child('low_bound')) {
	return $elt->sprint(1);
    }
    return 0;
}

sub lower_than_bound {
    my $self = shift;
    if (my $elt = $self->elt()->first_child('low_bound')) {
	if ($elt->att('lower_than_bound') && $elt->att('lower_than_bound') eq 'no') {
	    return 0;
	}
	else {
	    return 1;
	}
    }
    return 0;
}

sub high_bound {
    my $self = shift;
    if (my $elt = $self->elt()->first_child('high_bound')) {
	return $elt->sprint(1);
    }
    return 0;
}

sub higher_than_bound {
    my $self = shift;
    if (my $elt = $self->elt()->first_child('high_bound')) {
	if ($elt->att('higher_than_bound') && $elt->att('higher_than_bound') eq 'no') {
	    return 0;
	}
	else {
	    return 1;
	}
    }
    return 0;
}

sub set_low_high_bound {
    my $self = shift;
    my ($low_bound, $high_bound, $lower, $higher) = @_;

    # Validation
    $low_bound = sprintf('%d', $low_bound);
    $low_bound ||= 0;
    $high_bound = sprintf('%d', $high_bound);
    if ($low_bound < 0) {
	my $msg = "Low bound must be an integer greater than or equal to 0.";
	return wantarray ? (0, $msg) : 0;
    }
    if ($high_bound <= $low_bound) {
	my $msg = "High bound must be an integer greater than the low bound.";
	return wantarray ? (0, $msg) : 0;
    }

    $self->set_body_elt('low_bound', $low_bound, ['question_text']);
    $self->set_body_elt('high_bound', $high_bound, ['low_bound', 'question_text']);
    my $elt = $self->elt->first_child('low_bound');
    if($elt) { $elt->set_att('lower_than_bound', $lower ? 'yes' : 'no'); }
    $elt = $self->elt->first_child('high_bound');
warn("-->\n-->\n--> Got a higher_than_bound with a value of $higher\n-->\n-->\n");
    if($elt) { $elt->set_att('higher_than_bound', $higher ? 'yes' : 'no'); }

    $self->question()->set_field_values('body', $self->elt()->sprint());
    return 1;
}

sub interval {
    my $self = shift;
    if (my $elt = $self->elt()->first_child('interval')) {
	return $elt->sprint(1);
    }
    return 1;
}

sub set_interval {
    my $self = shift;
    my $interval = shift;

    # Validation
    $interval = sprintf('%d', $interval);
    if ($interval < 1) {
	my $msg = "Interval must be an integer greater than or equal to 1.";
	return wantarray ? (0, $msg) : 0;
    }
    if ($interval >= ($self->high_bound() - $self->low_bound())) {
	my $msg = "Interval must be less than the difference between the bounds.";
	return wantarray ? (0, $msg) : 0;
    }

    $self->set_body_elt('interval', $interval, [ 'high_bound' ]);
    $self->question()->set_field_values('body', $self->elt()->sprint());
    return 1;
}

sub resp_cache {
    my $self = shift;
    unless ($self->{-resp_cache}) {
	$self->make_resp_cache();
    }
    return $self->{-resp_cache} 
}

sub make_resp_cache {
    my $self = shift;

    my $letter = 'a';
    my %cache = ();
    if ($self->lower_than_bound()) { 
	$cache{$letter++} = 'Less than ' . $self->low_bound();
    }
    my $count = $self->low_bound();
    my $interval = $self->interval();
    my $high = $self->high_bound();
    while ($count < $high) {
	if ($interval == 1) {
	    $cache{$letter++} = $count;
	}
	elsif ($interval == 2) {
	    $cache{$letter++} = ($count < $high) ? 
		sprintf("%d or %d", $count, $count+1) : $count;
	}
	else {
	    if ($count == $high) {
		$cache{$letter++} = $count;
	    }
	    elsif ($count == $high-1) {
		$cache{$letter++} = sprintf("%d or %d", $count, $count+1);
	    }
	    else {
		my $upper = $count + $self->interval();
		$upper = $upper < $high ? $upper : $high;
		$cache{$letter++} = sprintf("%d to %d", $count, $upper);
	    }
	}
	$count += $interval;
    }
    if ($self->higher_than_bound()) {
	$cache{$letter++} = 'More than ' . $high;
    }
    $self->{-resp_cache} = \%cache;
}

sub interpret_response {
    my $self = shift;
    my $resp = shift;

    return $self->resp_cache()->{$resp};
}

sub choices {
    my $self = shift;

    my @options = sort keys %{$self->resp_cache()};
    return map { $self->resp_cache()->{$_} } @options;
}

1;
