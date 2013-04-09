#!/usr/bin/perl
# Test to see if referenced packages are installed

use strict;
use warnings;
use Test::More 'no_plan';
use Test::Files;
use TUSK::Constants;

my $test_count = 0;
my $path = $TUSK::Constants::ServerRoot;
my @liblist = `grep -r '^\\s*\\(require\\|use\\)\\b\\s*[a-zA-Z]\\+.*;' $path | sed 's/^\\s*//'`;

foreach my $statement (@liblist) {
	$statement =~ s/[\n|\r|\t]//g;
	$statement =~ s/^(\/[^\:]+)\:\s*(require|use)\s+(base\s*)?(qw\s*\W)?\s*['"\/]?\s*([a-zA-Z]+)([a-zA-Z0-9_:\-]*).*?$/$1,$5$6/g;
	my ($filepath, $package) = split(',', $statement);
	require_ok($package) || diag("$package referenced in [$filepath] but not found.");
	$test_count++;
}

done_testing($test_count);
