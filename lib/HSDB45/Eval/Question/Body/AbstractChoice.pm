package HSDB45::Eval::Question::Body::AbstractChoice;

use strict;
use base qw(HSDB45::Eval::Question::Body);
use XML::EscapeText::HSCML qw(:html);

# Description: Adds labels to all the <choice> elements if they don't already have them
# Input:
# Output:
sub setup_labels {
    my $self = shift;

    # If we've already done it, we don't need to do it again.
    return if $self->{-setup_labels};

    my %used_labels = ();
    my $label = 'a';
    for my $choice_elt ( $self->elt()->children( 'choice' ) ) {
	if ( $choice_elt->att('stored_value') ) {
	    $used_labels{ $choice_elt->att('stored_value') } = 1;
	}
	else {
	    # Get the next unused label
	    while ( $used_labels{$label} ) { $label++ }
	    $choice_elt->set_att( 'stored_value' => $label );
	    $used_labels{ $label } = 1;
	}
    }
    $self->{-setup_labels} = 1;
}

# INPUT:  none
# OUTPUT: returns the list of the choice labels
# EFFECT: none
sub choice_labels {
    my $self = shift();
    $self->setup_labels();
    my @labels = ();
    for my $choice_elt ( $self->elt()->children( 'choice' ) ) {
	push @labels, $choice_elt->att( 'stored_value' );
    }
    return @labels;
}

# Description: Turns a label of a choice into the choice text itself
# Input: The choice label ('a', 'b', 'c', etc.)
# Output: The choice text (undef if can't find the choice; this is the case, 
#    e.g., if NA is chosen)
sub interpret_response {
    my $self = shift;
    my $label = shift;
    $self->setup_labels;
    my ($choice_elt) = $self->elt()->get_xpath( "choice[\@stored_value=\"$label\"]" );
    return $choice_elt ? $choice_elt->sprint(1) : undef;
}

sub choices {
    my $self = shift();
    my @choices = ();
    $self->setup_labels();
    foreach my $choice_label ($self->choice_labels()) {
	push(@choices, $self->interpret_response($choice_label));
    }
    return @choices;
}

sub set_choices {
    my $self = shift;
    my @choices = @_;

    # Kill all of the old ones
    for ($self->elt()->children('choice')) { $_->delete() }

    # Now, add the new ones
    for my $choice (grep { $_ } @choices) {
	my $new_elt = XML::Twig::Elt->new('choice', $html_inline->xml_escape($choice));
	$new_elt->set_asis();
	$new_elt->paste('last_child', $self->elt());
    }

    $self->question()->set_field_values('body', $self->elt()->sprint());
    return 1;
}

sub num_columns {
    my $self = shift;
    my $num_cols =  $self->elt()->att('num_columns');
    return $num_cols || 0;
}

sub set_num_columns {
    my $self = shift;
    my $num_cols = shift;
    $num_cols =~ s/\D//g;
    if ($num_cols) {
	# Kill non-digits
	# Make sure it's 0 to 6
	$num_cols = ($num_cols > 6 ? 6 : $num_cols);
	$num_cols = ($num_cols < 1 ? 1 : $num_cols);
	$self->elt()->set_att('num_columns', $num_cols);
    }
    else {
	$self->elt()->del_att('num_columns') if $self->elt()->att('num_columns');
    }
    $self->question()->set_field_values('body', $self->elt()->sprint());
    return 1;
}

# Description: Returns the desired alignment for the choices
# Input:
# Output: "horiontal" (default) or "vertical"
sub choice_align {
    my $self = shift;
    my $align = $self->elt()->att( 'choice_align' );
    return $align || "horizontal";
}

1;
