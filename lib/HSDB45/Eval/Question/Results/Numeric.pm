package HSDB45::Eval::Question::Results::Numeric;

use strict;
use base qw(HSDB45::Eval::Question::Results);

sub is_numeric {
    return 1;
}

sub is_binnable {
    return 0;
}

1;
