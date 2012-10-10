package TUSK::ImportTest;

use strict;
use base qw/Test::Unit::TestCase/;
use Test::Unit;
use TUSK::Import;
use TUSK::ImportLog;
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

sub test_sanity {
    assert(1, "Test::Unit is broken!");
}

sub test_new {
    my $import = TUSK::Import->new;
    assert($import->isa("TUSK::Import"),"Instantiating TUSK::Import object failed");
}

sub test_set_get_fields {
    my $import = TUSK::Import->new;
    my @set_fields = ("1","2","3","4");
    $import->set_fields(@set_fields);
    my @get_fields = $import->get_fields;
    assert (scalar @get_fields == 4,
	    "Incorrect number of items in set/get fields methods: ".
	    scalar @set_fields." set, ".
	    scalar @get_fields." from get");
    for (my $ii = 0; $ii < scalar @set_fields; $ii++) {
	assert($set_fields[$ii] == $get_fields[$ii],"set fields are not returned from get in correct order");
    }
}

sub test_push_get_log_items {
    my $import = TUSK::Import->new;
    my $log = TUSK::ImportLog->new("test");
    my $res = $import->push_log($log);
    $res = $import->push_log($log);
    assert($res,"could not push log item onto Import stack");
    my @log_items = $import->get_logs;
    assert(scalar @log_items == 2,"wrong number of log items returned from Import");
}

sub test_push_get_record_items {
    my $import = TUSK::Import->new;
    $import->set_fields("first","second","third");
    my $record = TUSK::ImportRecord->new($import);
    $record->set_field_values("one","two","three");
    my $res = $import->push_record($record);
    $import->clear_records;
    $res = $import->push_record($record);
    $res = $import->push_record($record);
    $res = $import->push_record($record);
    assert($res,"could not push record item onto Import stack");
    my @record_items = $import->get_records;
    assert(scalar @record_items == 3,"wrong number of record items returned from Import");
    assert($record->get_field_value("third") eq "three","Record values set incorrectly");
}

sub test_add_record {
    my $import = TUSK::Import->new;
    $import->add_log("test","testing this");
    assert($import->get_logs == 1,"add_record failed");
}

sub test_grep_records {
    my $import = TUSK::Import->new;
    $import->set_fields("first","second","third","fourth");
    my $record = TUSK::ImportRecord->new($import);
    $record->set_field_values("one","two","three","four");
    my $res = $import->push_record($record);
    $res = $import->push_record($record);
    $res = $import->push_record($record);
    $res = $import->push_record($record);
    $record->set_field_values("one","two","three","4");
    $res = $import->push_record($record);
    $res = $import->push_record($record);
    $res = $import->push_record($record);
    $res = $import->push_record($record);
    print "Records: ",scalar $import->get_records,"\n";
    #$import->grep_records("fourth","four");
    #print "Records: ",scalar $import->get_records,"\n";
    foreach my $r ($import->get_records) {
	foreach my $f ($import->get_fields) {
	    print "";
	}
print $_->get_fields,"\n";
    }
    assert($res,"could not push record item onto Import stack");
    
}

1;
