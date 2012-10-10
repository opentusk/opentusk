package HSDB45::Eval::Question::Results::Textual;

use strict;
use base qw(HSDB45::Eval::Question::Results);

sub is_numeric {
    return 0;
}

sub is_binnable {
    return 1;
}

1;
