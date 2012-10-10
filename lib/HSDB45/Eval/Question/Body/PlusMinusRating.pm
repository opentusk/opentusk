package HSDB45::Eval::Question::Body::PlusMinusRating;

use strict;
use base qw(HSDB45::Eval::Question::Body::AbstractRating);

sub low_number {
    my $self = shift;
    return -int($self->num_steps/2);
}

1;
__END__
