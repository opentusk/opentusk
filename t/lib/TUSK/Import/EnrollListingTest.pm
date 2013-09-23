package TUSK::Import::EnrollListingTest;

use strict;
use base Test::Unit::TestCase;
use Test::Unit;
use TUSK::Import::EnrollListing;
use TUSK::Import;
use TUSK::ImportRecord;

sub new {
    my $self = shift()->SUPER::new(@_);
    return $self;
}

sub sql_files {
    return qw(base_import_course.sql base_import_time_period.sql base_import_teaching_site.sql base_import_eval.sql
	      base_import_course_teaching_site.sql base_import_course_user.sql import_eval_eval_question.sql);
}

sub set_up {
    return;
}

sub tear_down {
    return;
}

sub test_new {
    my $import = TUSK::Import::EnrollListing->new("regress","2A");
    assert($import->isa("TUSK::Import::EnrollListing"),"Instantiating TUSK::Import::EnrollListing object failed");
}

sub test_get_period {
    my $import = TUSK::Import::EnrollListing->new("regress","2A");
    assert($import->get_period eq "2A","Getting period failed");
}

sub test_get_school {
    my $import = TUSK::Import::EnrollListing->new("regress","2A");
    assert($import->get_school eq "regress","Getting period failed");
}

sub test__check_user_id {
    my $import = TUSK::Import::EnrollListing->new("regress","2A");
    assert($import->_check_user_id("mkruck01") eq "mkruck01","Lookup of user_id failed");
}

sub test__check_course {
    my $import = TUSK::Import::EnrollListing->new("regress","2A");
    my $course = $import->_check_course("PED300");
    assert($course,"Greating course failed");
    assert($course->primary_key == "210","Getting correct course_id from database failed") if ($course);
}

sub test__get_course_level {
    my $import = TUSK::Import::EnrollListing->new("regress","2A");
    assert($import->_get_course_level("PED300") == "300","Getting course level failed");
    assert($import->_get_course_level("MED423") == "423","Getting course level failed");
}

sub test__get_time_period {
    my $import = TUSK::Import::EnrollListing->new("regress","2A");
    assert($import->_get_time_period("1A") eq "1A","Getting time period failed");
    assert($import->_get_time_period("1A1B") eq "1A1B","Getting time period failed");
}

sub test__get_time_period_id {
    my $import = TUSK::Import::EnrollListing->new("regress","2A");
    assert($import->_get_time_period_id("1A six weeks","2002") == 29,"Getting time period id failed");
}

sub test__get_start_end_dates {
    my $import = TUSK::Import::EnrollListing->new("regress","2A");
    my ($start,$end) = $import->_get_start_end_dates("08/08/03");
    assert($start eq "2003-08-01","Getting start date failed");
    assert($end eq "2003-09-12","Getting end date failed");
}

sub test__link_course_student {
    my $import = TUSK::Import::EnrollListing->new("regress","1A");
    my $course = $import->_check_course("PED300");
    my $site = $import->_get_teaching_site($course,"Faulkner Hospital");
    my ($r,$msg) = $import->_link_course_student("","",$course,"mkruck01","1A",$site);
    assert($r,"Creating link between course and user failed");
}

sub test__get_teaching_site {
    my $import = TUSK::Import::EnrollListing->new("regress","1A");

    ## first test that the course lookup method works
    my $course = $import->_check_course("MED423");
    my $site = $import->_get_teaching_site($course);
    assert($site,"Getting site object failed (test 1)");
    assert($site->primary_key == 99,"Getting teaching site key failed (test 2)");
    
    ## then test the course grep method (uses the files site to grep out teaching sites)
    my $course = $import->_check_course("PSY431");
    my $site = $import->_get_teaching_site($course,"Faulkner Hospital");
    assert($site,"Getting site object failed (test 2)");
    assert($site->primary_key == 98,"Getting teaching site failed (test 2)");

    ## then test the lookup from the file
    my $course = $import->_check_course("MAN200");
    my $site = $import->_get_teaching_site($course,"Cardinal Cushing General Hospital");
    assert($site,"Getting site object failed (test 3)");
    assert($site->primary_key == 5,"Getting teaching site failed (test 3)");
}
1;
