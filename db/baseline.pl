#! /usr/bin/env perl

# TODO Fix script to work with system root's my.cnf.

use Modern::Perl;
use Getopt::Long;
use Readonly;
use DBI;
use Carp;
use Sys::Hostname;
use Term::ReadKey;
use TUSK::Constants;
use TUSK::DB::Baseline;

Readonly my $help_text => <<END_HELP;
Usage: perl baseline.pl [--mwforum=<db>] [--fts=<db>]
                        [--hsdb4=<db>] [--tusk=<db>]
                        [--create-admin]
                        [--create-school [--school-admin=<user>]]
                        [--verbose]

Set up a developer database for use with tusk. This script should be
run before upgrade.pl to set up a baseline database which can then be
upgraded to the latest development version.

This script relies on your ~/.my.cnf to connect to the MySQL database
with your username and password. To create schools your user must have
grant privileges.

The database connection information is read from tusk.conf. If your
tusk.conf does not contain a database setting for the current
hostname, this script will try to use `localhost'.

Examples:
  perl baseline.pl --verbose
  perl baseline.pl --create-school --school-admin=johndoe --create-admin

Options:
  --help            Print usage and exit
  --mwforum=<db>    Database to use for forum data       [default: mwforum]
  --fts=<db>        Database to use for full text search [default: fts]
  --hsdb4=<db>      Database to use for legacy data      [default: hsdb4]
  --tusk=<db>       Database to use for TUSK webapp      [default: tusk]
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
    $mwforum_db,
    $fts_db,
    $hsdb4_db,
    $tusk_db,
    $run_create_school,
    $school_admin,
    $create_admin,
);

GetOptions(
    'help' => \$show_help,
    'verbose' => \$verbose,
    'mwforum=s' => \$mwforum_db,
    'fts=s' => \$fts_db,
    'hsdb4=s' => \$hsdb4_db,
    'tusk=s' => \$tusk_db,
    'create-school' => \$run_create_school,
    'school-admin' => \$school_admin,
    'create-admin' => \$create_admin,
);

# Set defaults
$mwforum_db //= 'mwforum';
$fts_db //= 'fts';
$hsdb4_db //= 'hsdb4';
$tusk_db //= 'tusk';
$school_admin //= 'admin';

if ($show_help) {
    print $help_text;
    exit;
}

$school_admin //= 'admin';

my $my_cnf = "$ENV{HOME}/.my.cnf";
my $hostname = hostname;
my $dbserver = $TUSK::Constants::Servers{$hostname} || 'localhost';
my $dbhost = $dbserver->{'WriteHost'};
my $dsn = "DBI:mysql:mysql:$dbhost;mysql_read_default_file=$my_cnf";
my $dbh = DBI->connect($dsn, undef, undef, { RaiseError => 1 });
confess $DBI::errstr if (! $dbh);

my $db_baseline = TUSK::DB::Baseline->new({
    dbh => $dbh,
    mwforum => $mwforum_db,
    fts => $fts_db,
    hsdb4 => $hsdb4_db,
    tusk => $tusk_db,
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
