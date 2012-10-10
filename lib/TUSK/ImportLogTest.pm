package TUSK::Import::LogTest;

use strict;
use base qw/Test::Unit::TestCase/;
use Test::Unit;
use TUSK::ImportLog;

sub new {
    my $self = shift()->SUPER::new(@_);
    return $self;
}

sub sql_files {
    return;
}

sub set_up {
    return;
}

sub tear_down {
    return;
}

sub test_new {
    my $log = TUSK::Import::Log->new("user");
    assert($log->isa("TUSK::Import::Log"),"Instantiating TUSK::Import::Log object failed");
    assert($log->get_type eq "user","Setting type failed");
}

sub test_set_get_message {
    my $log = TUSK::Import::Log->new;
    my $res = $log->set_message("the item failed");
    assert($res,"Could not set message in Import::Log");
    assert($log->get_message eq "the item failed","Could not get message in Import::Log"); 
}
1;
