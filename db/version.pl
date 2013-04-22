#! /usr/bin/env perl

# use Modern::Perl;
use strict;
use warnings;
use utf8;

use FindBin;
use lib qq($FindBin::Bin/../lib);

use Getopt::Long;
use Readonly;
use DBI;
use Carp;
use TUSK::DB::Version;

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

my $version_string_ref = $db_version->version_string_hashref();
foreach my $db (keys %{$version_string_ref}) {
    my $ver = $version_string_ref->{$db};
    print "$db version: ";
    print $ver;
    print ' (run baseline.pl to setup versioning)' if $ver eq 'unversioned';
    print "\n";
}
