package HSDB45::Eval::Question::Body::MultipleChoice;

use strict;
use base qw(HSDB45::Eval::Question::Body::AbstractChoice);

# Description: Returns the multiple choice style value
# Input:
# Output: Either "dropdown" or "radiobox" (default)
sub choice_style {
    my $self = shift;
    my $style = $self->elt()->att( 'choice_style' );
    return $style || 'radiobox';
}

1;
