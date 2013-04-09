#! /usr/bin/env perl

use Modern::Perl;
use Getopt::Long;
use Readonly;
use DBI;
use Carp;
use TUSK::DB::Version;
use TUSK::DB::Upgrade;

Readonly my $help_text => <<END_HELP;
Usage: perl upgrade.pl [--all] [--verbose]

Upgrade each tusk database to the latest version.

The database connection information is read from tusk.conf. tusk.conf
must be properly configured before this script is run.

Example:
  perl upgrade.pl --verbose --all

Options:
  --help            Print usage and exit
  --all             Run all upgrade scripts without prompting
  --verbose         Show progress when used with --all
END_HELP

my (
    $show_help,
    $run_all,
    $verbose,
);

GetOptions(
    'help' => \$show_help,
    'all' => \$run_all,
    'verbose' => \$verbose,
);

if ($show_help) {
    print $help_text;
    exit;
}

$verbose = $verbose || (! $run_all);

my $upgrade_obj = TUSK::DB::Upgrade->new({verbose => $verbose});

my $scripts_for = $upgrade_obj->upgrade_scripts_to_run();

print "Available upgrades to run:\n" if $verbose;
foreach my $db (keys %{ $scripts_for }) {
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
foreach my $db (keys %{ $scripts_for }) {
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
                next COMMENTS if $line eq q{};
                if ($script_info->{ext} eq 'pl') {
                    if ($line =~ m{\A \s* #}xms) {
                        print "$line\n";
                    }
                    else {
                        last COMMENTS;
                    }
                }
                else {
                    if ($line =~ m{\A \s* --}xms) {
                        print "$line\n";
                    }
                    else {
                        last COMMENTS;
                    }
                }
            }
            close $fh;
            print "\n";
        }
        if (! $run_all) {
            print "Apply $update_script to `$db` (y/[n])? ";
            my $user_response = <STDIN>;
            chomp ($user_response);
            $user_response = lc $user_response;
            my $run_for_this_db = $user_response eq 'y'
                || $user_response eq 'yes';
            next DATABASE if ! $run_for_this_db;
        }
        $upgrade_obj->apply_script($update_script);
    }
}
