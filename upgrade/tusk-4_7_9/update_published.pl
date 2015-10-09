#!/usr/bin/perl

use strict;
use warnings;
use HSDB4::Constants;

my $table = 'eval';

my $dbh = HSDB4::Constants::def_db_handle();
my $sth = $dbh->prepare("SHOW DATABASES LIKE 'hsdb45%'");
$sth->execute();
my $dbs = $sth->fetchall_arrayref();
$sth->finish();

foreach (@$dbs) {
	my $db = $_->[0];

	# add the new column 'published'
	eval {
		$sth = $dbh->do("ALTER TABLE $db.$table ADD published TINYINT(1) NOT NULL DEFAULT 0");
	};

	if ($@) {
		print "Failed to add ";
	} else {
		print "Added ";
	}
	print "'published' column to $db.$table\n";
	print "$@\n" if ($@);
}
