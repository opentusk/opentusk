#!/usr/bin/perl

use strict;
use warnings;
use MySQL::Password;
use HSDB4::Constants;
HSDB4::Constants::set_user_pw(get_user_pw);

main();

sub main {
    my $dbh = HSDB4::Constants::def_db_handle();
    my $sth = $dbh->prepare("show databases like 'hsdb45%'");
    $sth->execute();
    my $dbs = $sth->fetchall_arrayref();
    $sth->finish();

    foreach my $db (@{$dbs}) {
	my $table = 'eval';

	## add new column with the default "course" type
        eval {
		$sth = $dbh->do("alter table $db->[0]\.$table add eval_type_id smallint(2) NOT NULL default '1'");
	};

	if ($@) {
	    print "Failed to add ";
	} else {
	    print "Added ";
	}
	print "'eval_type_id' column to $db->[0]\.$table\n";
	print $@ . "\n";
    }
}


