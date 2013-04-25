#! /bin/env perl

use strict;
use warnings;
use utf8;

use HSDB4::Constants;
use TUSK::Constants;

my $dbh = HSDB4::Constants::def_db_handle();

my $hsdb4 = $TUSK::Constants::Databases{hsdb4};
my $tusk = $TUSK::Constants::Databases{tusk};
my @schools = HSDB4::Constants::schools();

sub query_defined {
    my $query = shift;
    return sub { return ( defined $dbh->selectrow_arrayref($query) ); };
}

sub negate {
    my $sub = shift;
    return sub { return ( ! $sub->() ); };
}

sub column_exists {
    my ($db, $table, $column) = @_;
    return query_defined("show columns from `$table` in `$db` like '$column'");
}

sub table_exists {
    my ($db, $table) = @_;
    return query_defined("show tables from `$db` like '$table'");
}

my @legacy_version_checks = (
    'Pre 3.6.14' => negate(column_exists($hsdb4, 'user', 'uid')),
    '3.6.14 and 3.6.15' => negate(table_exists($tusk, 'competency')),
    '3.7.0 and 3.7.1' => sub {
        return if (scalar(@schools) < 1);
        my $db = HSDB4::Constants::get_school_db($schools[0]);
        return table_exists($db, 'eval_secret')->();
    },
    '3.7.2' => negate(table_exists($tusk, 'quiz_question_keyword')),
    '3.7.3' => negate(table_exists($tusk, 'grade_scale')),
    '3.7.4' => negate(table_exists($tusk, 'competency_relationship')),
    '3.7.5' => negate(table_exists($tusk, 'form_builder_assessment')),
);

my $len = scalar @legacy_version_checks;
my $i = 0;

while ($i < $len) {
    if ( $legacy_version_checks[$i+1]->() ) {
        print "Database for TUSK version: " . $legacy_version_checks[$i] . "\n";
        last;
    }
    $i += 2;
}
