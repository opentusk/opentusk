#! /bin/env perl

use strict;
use warnings;
use utf8;

use Getopt::Long;
use HSDB4::Constants;
use TUSK::Constants;

my (
    $help,
    $verbose,
);

GetOptions(
    'help' => \$help,
    'verbose' => \$verbose,
);

sub usage {
    return <<END_USAGE;
Usage: perl legacy_version.pl [--verbose]

Discover and show the version of TUSK for the current database.
Use the verbose option to also show the database hostname.

Example:
  perl legacy_version.pl --verbose

Options:
  --help       Print usage and exit
  --verbose    Show extra database information    [default: false]
END_USAGE
}

if ($help) {
    print usage();
    exit;
}

my $dbh = HSDB4::Constants::def_db_handle();

my $hsdb4 = defined %TUSK::Constants::Databases
    ? $TUSK::Constants::Databases{hsdb4} : 'hsdb4';
my $tusk = defined %TUSK::Constants::Databases
    ? $TUSK::Constants::Databases{tusk} : 'tusk';
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

sub value_exists {
    my ($db, $table, $column, $value) = @_;
    my $safe_value = $dbh->quote($value);
    return query_defined(
        "select * from `$db`.`$table` where `$column` like $safe_value"
    );
}

my @legacy_version_checks = (
    '4.0/OpenTUSK (already version tracked, run version.pl)' =>
        table_exists($tusk, 'schema_change_log'),
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
    '3.8.0' => negate(column_exists($tusk,
                                    'link_phase_quiz', 'allow_resubmit')),
    '3.8.1' => negate(value_exists($tusk,
                                   'search_query_field_type',
                                   'search_query_field_name',
                                   'include_deleted_content')),
    '3.8.2' => negate(table_exists($tusk, 'patient_log_approval')),
    '3.8.3' => negate(table_exists($tusk, 'form_builder_form_grade_event')),
    '3.8.4' => negate(table_exists($tusk, 'case_rule_element_type')),
    '3.9.0, 3.9.1, 3.9.2' => negate(table_exists($tusk, 'class_meeting_type')),
    '3.9.3, 3.9.4, 3.9.5' => negate(column_exists($tusk,
                                                  'assignment', 'sort_order')),
    '3.9.6' => negate(table_exists($tusk, 'process_tracker')),
    '3.10.0' => sub {
        return 'varchar(350)' ne lc( $dbh->selectrow_hashref(
            "show columns from competency in `$tusk` like 'title'"
        )->{Type} );
    },
    '3.10.1' => sub {
        return (
            lc( $dbh->selectrow_hashref(
                "show create table `$hsdb4`.user"
            )->{'Create Table'} ) !~ m/utf8/xms
        );
    },
    '3.11.0/3.12.0/4.0/OpenTUSK (ready to run baseline.pl)' =>
        negate(table_exists($tusk, 'schema_change_log')),
);

my $len = scalar @legacy_version_checks;
my $i = 0;

if ($verbose) {
    my $dbhost = $dbh->get_info(13);
    print "Database hostname: $dbhost\n";
}

while ($i < $len) {
    if ( $legacy_version_checks[$i+1]->() ) {
        print "Database for TUSK version: " . $legacy_version_checks[$i] . "\n";
        last;
    }
    $i += 2;
}
