#! /usr/bin/perl -w
use strict;

use TUSK::Core::ServerConfig;
use HSDB4::Constants;
use TUSK::Core::School;
use Getopt::Std;

my $testrun = 1;
our ($opt_t, $opt_l);
getopts("tl");

if ($opt_l) {        # if we want to run as live script (not test mode)
	$testrun = 0;
}
else { 
	print "##########\nYou have indicated that you would like to run the script in TEST MODE.\nScript will not perform any real actions, but only indicate what it would have done in LIVE MODE.\n##########\n"; 
}



if (! -d 'sql_dumps') {
	if ($testrun) {
		print "Would have made sql_dumps directory.\n";
	}
	else {
		print "Making sql_dumps directory.\n";
		mkdir("sql_dumps") || die $!;
	}
}
else {
	print "sql_dumps directory already exists.\n";
}

my $host = TUSK::Core::ServerConfig::dbWriteHost();
my %dumped;
foreach my $s (HSDB4::Constants::schools()) {
	my $school = TUSK::Core::School->new()->lookupReturnOne("school_name='$s'");
	if (!defined $school) {
		print "Error: no school found with name '$s.' If that is a problem, it is not recommended to proceed with the upgrade.\n";
	}

	my $db = HSDB4::Constants::get_school_db($s);
	if (!defined $db) {
		print "Error: after call to HSDB4::Constants::get_school_db(), script could not find a db for school with name '$s'. Therefore, we could not identify any data for backing up. Do not proceed with the upgrade if this is a problem.\n";
		next;
	}

	unless ($dumped{$db}++) {
		my $stmt = "mysqldump -h $host $db class_meeting > sql_dumps/$db.sql";
		if ($testrun) {
			print "$stmt\n";
		}
		else {
			print "going to do backup $db.class_meeting\n";
			system($stmt);
		}
	}
}
