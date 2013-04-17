#! /usr/bin/env perl
# Test TUSK databases

use strict;
use warnings;
use utf8;

use Test::More;
use Test::DatabaseRow;
use DBI;

use HSDB4::Constants qw(get_school_db);
use TUSK::Constants;

my $test_count = 0;

my $dbh = HSDB4::Constants::def_db_handle();
ok(defined $dbh, "Database connected");
$test_count += 1;

local $Test::DatabaseRow::dbh = $dbh;

foreach my $db ('mwforum', 'fts', 'hsdb4', 'tusk') {
    ok($dbh->do('use `' . $TUSK::Constants::Databases{$db} . '`;'),
       "use $db database");
}
$test_count += 4;

foreach my $school_name (keys %TUSK::Constants::Schools) {
    my $school = $TUSK::Constants::Schools{$school_name};
    my $school_db = get_school_db($school_name);
    $dbh->do('use `' . $TUSK::Constants::Databases{tusk} . '`;');
    all_row_ok(
        table => 'school',
        where => [ school_name => $school_name ],
        tests => {
            'eq' => {
                school_display => $school->{DisplayName},
                school_db => $school_db,
            }
        },
        description => (
            "$school_name school in tusk.conf matches data in tusk.school "
                . "table"
        ),
    );
    ok($dbh->do("use `$school_db`;"), "use $school_db database");
    $test_count += 2;
    foreach my $group qw(SchoolWideUserGroup SchoolAdmin EvalAdmin) {
        row_ok(
            table => 'user_group',
            where => [
                user_group_id => $school->{Groups}->{$group},
            ],
            description => "$group in $school_name",
        );
        $test_count += 1;
    }
}

done_testing($test_count);
