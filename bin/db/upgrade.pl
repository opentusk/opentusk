#! /usr/bin/env perl

use strict;
use warnings;
use utf8;

use FindBin;
use lib qq($FindBin::Bin/../../lib);

use Getopt::Long;
use Readonly;
use DBI;
use Carp;

use TUSK::DB::Upgrade;
use TUSK::DB::Util qw(get_dsn get_my_cnf);
use MySQL::Password qw(get_prompt_pw);

Readonly my $help_text => <<END_HELP;
Usage: perl upgrade.pl [--all] [--verbose]
                       [--dbuser=<user> [--dbpw=<password>]]

Upgrade each tusk database to the latest version.

The database connection information is read from tusk.conf. tusk.conf
must be properly configured before this script is run.

If dbuser and dbpw are not set, this script tries to use your
~/.my.cnf to connect to the MySQL database with your username and
password. To create schools your user must have grant privileges. If
no my.cnf file can be find, this script will interactively prompt for
a database admin username and password.

The database connection information is read from tusk.conf. tusk.conf
must be properly configured before this script is run. If no database
host can be found, defaults to localhost.

Example:
  perl upgrade.pl --verbose --all

Options:
  --help            Print usage and exit
  --all             Run all upgrade scripts without prompting
  --dbuser=<user>   MySQL database admin user
  --dbpw=<password> MySQL database admin password
  --verbose         Show progress when used with --all
END_HELP

my (
    $show_help,
    $run_all,
    $verbose,
    $db_user,
    $db_pw,
);

GetOptions(
    'help' => \$show_help,
    'all' => \$run_all,
    'verbose' => \$verbose,
    'dbuser=s' => \$db_user,
    'dbpw=s' => \$db_pw,
);

if ($show_help) {
    print $help_text;
    exit;
}

$verbose = $verbose || (! $run_all);

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

my $upgrade_obj = TUSK::DB::Upgrade->new({
    dbh => $dbh,
    verbose => $verbose,
    db_user => $db_user,
    db_pw => $db_pw,
});

my $scripts_for = $upgrade_obj->upgrade_scripts_to_run();

print "Available upgrades to run:\n" if $verbose;
foreach my $db (sort(keys %{ $scripts_for })) {
    my @scripts = @{ $scripts_for->{$db} };
    print "$db: " if $verbose;
    if (scalar @scripts) {
        print join(q{, }, @scripts) if $verbose;
    }
    else {
        print "up-to-date" if $verbose;
    }
    print "\n" if $verbose;
}
DATABASE:
foreach my $db (sort(keys %{ $scripts_for })) {
    my @scripts = @{ $scripts_for->{$db} };
  SCRIPT:
    foreach my $update_script (@scripts) {
        # print opening comments in upgrade script
        if ($verbose) {
            print "\n";
            print "$update_script summary:\n";
            my $script_info = $upgrade_obj->script_info($update_script);
            open my $fh, '<', $script_info->{path};
          COMMENTS:
            while (<$fh>) {
                my $line = $_;
                chomp $line;
                # ignore blank lines
                next COMMENTS if $line eq q{};
                # Perl comments start with #, SQL comments with --
                my $comment_re = $script_info->{ext} eq 'pl' ? qr{\A \s* \#}xms
                    :                                          qr{\A \s* --}xms;
                print "$line\n" if $line =~ $comment_re;
                # Check if we're done with comments
                last COMMENTS if $line !~ $comment_re;
            }
            close $fh;
            print "\n";
        }
        if (! $run_all) {
            print "Apply $update_script to `$db` (y/[n])? ";
            my $response = <STDIN>;
            chomp ($response);
            $response = lc $response;
            next DATABASE if (! ($response eq 'y' || $response eq 'yes'));
        }
        $upgrade_obj->apply_script($update_script);
    }
}
