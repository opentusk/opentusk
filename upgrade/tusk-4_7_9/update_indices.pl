#!/usr/bin/perl

use strict;
use warnings;
use HSDB4::Constants;

my $table = 'link_course_student';

my $dbh = HSDB4::Constants::def_db_handle();
my $sth = $dbh->prepare("SHOW DATABASES LIKE 'hsdb45%'");
$sth->execute();
my $dbs = $sth->fetchall_arrayref();
$sth->finish();

foreach (@$dbs) {
	my $db = $_->[0];

	# add new indicies
	eval {
		$sth = $dbh->do("ALTER TABLE $db.$table ADD INDEX parent_course_id (parent_course_id)");
		$sth = $dbh->do("ALTER TABLE $db.$table ADD INDEX child_user_id (child_user_id)");
		$sth = $dbh->do("ALTER TABLE $db.$table ADD INDEX time_period_id (time_period_id)");
		$sth = $dbh->do("ALTER TABLE $db.$table ADD INDEX teaching_site_id (teaching_site_id)");
	};

	if ($@) {
		print "Failed to add ";
	} else {
		print "Added ";
	}
	print "indices to $db.$table\n";
	print "$@\n" if ($@);
}
