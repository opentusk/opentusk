package HSDB45::UserGroupTest;

use strict;
use base qw/Test::Unit::TestCase/;
use Test::Unit;
use HSDB45::UserGroup;

sub sql_files {
    return ();
}

sub new {
    my $self = shift()->SUPER::new(@_);
    return $self;
}

sub set_up {

}

sub tear_down {

}

sub test_nothing {
    assert(1, "Test::Unit is broken!");
}

1;
