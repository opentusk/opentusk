package HSDB45::Eval::Question::Body::YesNo;

use base qw(HSDB45::Eval::Question::Body::AbstractChoice);

sub choice_labels {
    return qw/a b/;
}

sub setup_labels {
    return;
}

# Description: Turns a label of a choice into the choice text itself
# Input: The choice label ('a' or 'b')
# Output: The choice text (Yes or No)
#    e.g., if NA is chosen)
sub interpret_response {
    my $self = shift;
    my $label = shift;
    my $choice;
    if ($label eq 'a' || $label eq 'A' || $label eq '1') { $choice = 'Yes' }
    elsif ($label eq 'b' || $label eq 'B' || $label eq '2') { $choice = 'No' }
    return $choice;
}

1;
