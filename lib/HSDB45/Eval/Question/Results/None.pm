package HSDB45::Eval::Question::Results::None;

use strict;
use base qw(HSDB45::Eval::Question::Results);

sub is_numeric {
    return 0;
}

sub is_binnable {
    return 0;
}

1;
