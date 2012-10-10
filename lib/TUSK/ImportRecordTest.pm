package TUSK::ImportRecordTest;

use strict;
use base qw/Test::Unit::TestCase/;
use Test::Unit;
use TUSK::Import;
use TUSK::ImportRecord;

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
    my $import = TUSK::Import->new();
    my $record = TUSK::ImportRecord->new($import);
    assert($record->isa("TUSK::ImportRecord"),"Instantiating TUSK::Import::Record object failed");
}

sub test_import {
    my $import = TUSK::Import->new();
    my $record = TUSK::ImportRecord->new($import);
    assert($record->import->isa("TUSK::Import"),"Passing in a pulling out TUSK::Import failed");
}

sub test_set_field_values {
    my $import = TUSK::Import->new;
    $import->set_fields("one","two","three");
    my $record = TUSK::ImportRecord->new($import);
    $record->set_field_values("first","second","third");
}

sub test_set_field_value {
    my $import = TUSK::Import->new;
    $import->set_fields("one","two","three");
    my $record = TUSK::ImportRecord->new($import);
    $record->set_field_value("three","third");
    assert($record->get_field_value("three") eq "third","Getting proper field value failed");
}

sub test_get_field_value {
    my $import = TUSK::Import->new;
    $import->set_fields("one","two","three");
    my $record = TUSK::ImportRecord->new($import);
    $record->set_field_values("first","second","third");
    assert($record->get_field_value("one") eq "first","Getting proper field value failed");
    assert($record->get_field_value("three") eq "third","Getting proper field value failed");
}

sub test_get_field_count {
    my $import = TUSK::Import->new;
    $import->set_fields("one","two","three");
    my $record = TUSK::ImportRecord->new($import);
    $record->set_field_values("first","second","third");
    print "count: ".$record->get_field_count."\n";
    assert($record->get_field_count == 3,"Wrong count of fields returned")
}

1;
