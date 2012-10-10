#!/usr/bin/perl -w

use strict;
use MySQL::Password;
use HSDB4::Constants;
use TUSK::Core::School;
HSDB4::Constants::set_user_pw(get_user_pw);
use Data::Dumper;

main();

sub main {

	my $dbh = HSDB4::Constants::def_db_handle();
	my $sth = $dbh->prepare("show databases like 'hsdb45%'");
	$sth->execute();
	my $dbs = $sth->fetchall_arrayref();

	foreach my $db (@$dbs) {
        eval {
			$sth = $dbh->do('alter table ' . $db->[0] .  '.link_course_student add elective tinyint(1) NOT NULL default 0');
		};

		print "Added 'elective' column to " . $db->[0] . ".link_course_student\n" unless ($@);
	}

}
