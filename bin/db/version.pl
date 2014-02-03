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
use TUSK::DB::Version;
use TUSK::DB::Legacy;
use TUSK::DB::Upgrade;

Readonly my $help_text => <<END_HELP;
Usage: perl version.pl

Print out the version information for each tusk database.

The database connection information is read from tusk.conf. tusk.conf
must be properly configured before this script is run.

Example:
  perl version.pl

Options:
  --help            Print usage and exit
END_HELP

my (
    $show_help,
);

GetOptions(
    'help' => \$show_help,
);

if ($show_help) {
    print $help_text;
    exit;
}

my $db_version = TUSK::DB::Version->new();
my $legacy_version = TUSK::DB::Legacy->new();
my $is_legacy;

my $upgrade_obj = TUSK::DB::Upgrade->new();
my $scripts_for = $upgrade_obj->upgrade_scripts_to_run();

my $version_string_ref = $db_version->version_string_hashref();
foreach my $db (sort(keys %{$version_string_ref})) {
    my $ver = $version_string_ref->{$db};
    my $is_versioned = $ver ne 'unversioned';
    $is_legacy = 1 if (! $is_versioned);
    $scripts_for->{$db} = [] if (! exists $scripts_for->{$db});
    print "$db schema version: ";
    print $ver;
    print ' (run baseline.pl to setup versioning)' if (! $is_versioned);
    if ($is_versioned && scalar(@{ $scripts_for->{$db} }) > 0) {
        print ' (upgrades available)';
    }
    print "\n";
}
if ($is_legacy) {
    my @version_list = $legacy_version->version_list();
    print "Legacy database for TUSK version(s): "
        . join(q{, }, @version_list)
        . "\n";
}
