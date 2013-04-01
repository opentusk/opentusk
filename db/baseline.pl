#! /usr/bin/env perl

# TODO Fix script to work with system root's my.cnf.

# use Modern::Perl;
use strict;
use warnings;
use utf8;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Getopt::Long;
use Readonly;
use DBI;
use Carp;
use Sys::Hostname;
use TUSK::Constants;
use HSDB4::Constants;
use TUSK::DB::Baseline;
use TUSK::DB::Util qw(get_dsn get_my_cnf);
use MySQL::Password qw(get_prompt_pw);

Readonly my $help_text => <<END_HELP;
Usage: perl baseline.pl [--create-admin]
                        [--create-school [--school-admin=<user>]]
                        [--dbuser=<user> [--dbpw=<password>]]
                        [--verbose]

Set up a developer database for use with tusk. This script should be
run before upgrade.pl to set up a baseline database which can then be
upgraded to the latest development version.

If dbuser and dbpw are not set, this script tries to use your
~/.my.cnf to connect to the MySQL database with your username and
password. To create schools your user must have grant privileges. If
no my.cnf file can be find, this script will interactively prompt for
a database admin username and password.

The database connection information is read from tusk.conf. tusk.conf
must be properly configured before this script is run. If no database
host can be found, defaults to localhost.

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
  --dbuser=<user>   MySQL database admin user
  --dbpw=<password> MySQL database admin password
  --verbose         Show database creation progress      [default: false]
END_HELP

my (
    $show_help,
    $verbose,
    $run_create_school,
    $school_admin,
    $create_admin,
    $db_user,
    $db_pw,
);

$school_admin //= 'admin';

GetOptions(
    'help' => \$show_help,
    'verbose' => \$verbose,
    'create-school' => \$run_create_school,
    'school-admin=s' => \$school_admin,
    'create-admin' => \$create_admin,
    'dbuser=s' => \$db_user,
    'dbpw=s' => \$db_pw,
);

if ($show_help) {
    print $help_text;
    exit;
}

$school_admin //= 'admin';

my $dsn = get_dsn({
    default => 'localhost',
    verbose => $verbose,
    use_my_cnf => (! $db_user),
});
if ( (! $db_user) && (! -r get_my_cnf() )) {
    # no username or my.cnf available, so prompt
    ($db_user, $db_pw) = get_prompt_pw();
}
my $dbh = DBI->connect($dsn, $db_user, $db_pw, { RaiseError => 1 });
confess $DBI::errstr if (! $dbh);
HSDB4::Constants::set_def_db_handle($dbh);

my $db_baseline = TUSK::DB::Baseline->new({
    dbh => $dbh,
    verbose => $verbose,
    create_school => $run_create_school,
    school_admin => $school_admin,
    create_admin => $create_admin,
    db_user => $db_user,
    db_pw => $db_pw,
});
$db_baseline->create_baseline();

END {
    if ($dbh) {
        $dbh->disconnect() if $dbh->ping();
    }
}
