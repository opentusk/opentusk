package HSDB45::Eval::Question::Body::AbstractRating;

use strict;
use base qw(HSDB45::Eval::Question::Body);

# INPUT:  none
# OUTPUT: the num_steps for the question (default 3)
# EFFECT: none
sub num_steps {
    my $self = shift();
    my $steps = $self->elt()->att('num_steps');
    return $steps || 3;
}

sub set_num_steps {
    my $self = shift;
    my $num_steps = shift;

    # Validation
    $num_steps = sprintf('%d', $num_steps);
    if ($num_steps < 3 or $num_steps % 2 == 0) {
	my $msg = "Number of steps must be a positive, odd integer and at least 3.";
	return wantarray ? (0, $msg) : 0;
    }

    $self->elt()->set_att('num_steps', $num_steps);
    $self->question()->set_field_values('body', $self->elt()->sprint());
    return wantarray ? (1, '') : 1;
}

sub show_numbers {
    my $self = shift;
    my $show_nums = $self->elt()->att('show_numbers');
    return ($show_nums && $show_nums eq 'yes') ? 1 : 0;
}

sub set_show_numbers {
    my $self = shift;
    my $show_nums = shift;
    $show_nums = $show_nums ? 'yes' : 'no';
    $self->elt()->set_att('show_numbers', $show_nums);
    $self->question()->set_field_values('body', $self->elt()->sprint());
    return wantarray ? (1, '') : 1;
}

# INPUT:  none
# OUTPUT: the low_text for the question
# EFFECT: none
sub low_text {
    my $self = shift();
    my $elt = $self->elt()->first_child('low_text');
    return $elt ? $elt->sprint(1) : undef;
}

# INPUT:  none
# OUTPUT: the mid_text for the question, or undef if there is none
# EFFECT: none
sub mid_text {
    my $self = shift();
    my $elt = $self->elt()->first_child('mid_text');
    return $elt ? $elt->sprint(1) : undef;
}

# INPUT:  none
# OUTPUT: the high_text for the question, or undef if there is none
# EFFECT: none
sub high_text {
    my $self = shift();
    my $elt = $self->elt()->first_child('high_text');
    return $elt ? $elt->sprint(1) : undef;
}

sub set_low_mid_high_text {
    my $self = shift;
    my ($low, $mid, $high) = @_;

    my ($r, $msg) = (1, '');

    my @afters = ('question_text');
    ($r, $msg) = $self->set_body_elt('low_text', $low, \@afters);
    return (wantarray ? ($r, $msg) : $r) unless $r;

    unshift @afters, 'low_text';
    ($r, $msg) = $self->set_body_elt('mid_text', $mid, \@afters);
    return (wantarray ? ($r, $msg) : $r) unless $r;

    unshift @afters, 'mid_text';
    ($r, $msg) = $self->set_body_elt('high_text', $high, \@afters);
    return (wantarray ? ($r, $msg) : $r) unless $r;

    $self->question()->set_field_values('body', $self->elt()->sprint());
    return (wantarray ? ($r, $msg) : $r);
}

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
    if ($style && $style ne 'radiobox' && $style ne 'dropdown') {
	return (0, "Style argument must be \"radiobox\" or \"dropdown\".");
    }
    if ($align && $align ne 'horizontal' && $align ne 'vertical') {
	return (0, "Align argument must be \"horizontal\" or \"vertical\".");
    }

    # Set the attributes
    $self->elt()->set_att('choice_align' => $align) if $align;
    $self->elt()->set_att('choice_style' => $style) if $style;
    $self->question()->set_field_values('body', $self->elt()->sprint());

    return wantarray ? (1, '') : 1;
}

sub low_number { return 1 }

sub interpret_response {
    my $self = shift;
    my $response = shift;
    # If the response is already numeric, we don't need to worry about it
    if ($response =~ /\-?\d+/) { return $response }
    # Check for NA, if it's available
    if ($self->na_available()) {
	if (ord($response) - ord('a') >= $self->num_steps) { return undef }
    }
    # If it's alpha, then interpret it as such; assume that 'a' maps to low_number(),
    # 'b' to low_number() + 1, etc.
    return (ord($response) - ord('a')) + low_number();
}

sub choices {
    my $self = shift();
    my @choices = ();
    for(my $i = 1; $i <= $self->num_steps(); ++$i) { push(@choices, $i); }
    return @choices;
}

1;
