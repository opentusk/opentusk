#! /usr/bin/env perl

# TODO Fix script to work with system root's my.cnf.

# use Modern::Perl;
use strict;
use warnings;
use utf8;

use Getopt::Long;
use Readonly;
use DBI;
use Carp;
use Sys::Hostname;
use TUSK::Constants;
use TUSK::DB::Baseline;

Readonly my $help_text => <<END_HELP;
Usage: perl baseline.pl [--create-admin]
                        [--create-school [--school-admin=<user>]]
                        [--verbose]

Set up a developer database for use with tusk. This script should be
run before upgrade.pl to set up a baseline database which can then be
upgraded to the latest development version.

This script relies on your ~/.my.cnf to connect to the MySQL database
with your username and password. To create schools your user must have
grant privileges.

The database connection information is read from tusk.conf. tusk.conf
must be properly configured before this script is run.

Examples:
  perl baseline.pl --verbose
  perl baseline.pl --create-school --school-admin=johndoe --create-admin

Options:
  --help            Print usage and exit
  --create-school   Create schools based on tusk.conf    [default: false]
  --school-admin=   TUSK user to set as school admin     [default: admin]
    <user>
  --create-admin    Automatically create admin user with [default: false]
                    default password
  --verbose         Show database creation progress      [default: false]
END_HELP

my (
    $show_help,
    $verbose,
    $run_create_school,
    $school_admin,
    $create_admin,
);

GetOptions(
    'help' => \$show_help,
    'verbose' => \$verbose,
    'create-school' => \$run_create_school,
    'school-admin' => \$school_admin,
    'create-admin' => \$create_admin,
);

if ($show_help) {
    print $help_text;
    exit;
}

# $school_admin //= 'admin';
$school_admin = defined $school_admin ? $school_admin : 'admin';

my $my_cnf = "$ENV{HOME}/.my.cnf";
my $hostname = hostname;
my $dbserver = $TUSK::Constants::Servers{$hostname} || 'localhost';
my $dbhost = $dbserver->{'WriteHost'};
my $dsn = "DBI:mysql:mysql:$dbhost;mysql_read_default_file=$my_cnf";
my $dbh = DBI->connect($dsn, undef, undef, { RaiseError => 1 });
confess $DBI::errstr if (! $dbh);

my $db_baseline = TUSK::DB::Baseline->new({
    dbh => $dbh,
    verbose => $verbose,
    create_school => $run_create_school,
    school_admin => $school_admin,
    create_admin => $create_admin,
});
$db_baseline->create_baseline();

END {
    if ($dbh) {
        $dbh->disconnect() if $dbh->ping();
    }
}
