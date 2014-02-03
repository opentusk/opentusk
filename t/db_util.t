#! /usr/bin/env perl
# Test TUSK databases

use strict;
use warnings;
use utf8;

use Test::More;

use TUSK::DB::Util qw(tusk_tables);

my $test_count = 0;

my $tbl_sql = <<'END_SQL';
CREATE TABLE IF NOT EXISTS mytest1 (
  mytest1_id INT NOT NULL AUTO_INCREMENT,
  PRIMARY KEY mytest1_id
) engine=InnoDB default charset=utf8;
END_SQL

my ($tbl1, $history_tbl1) = tusk_tables($tbl_sql);

print "SQL:\n\n";
print $tbl1;
print "\nHistory SQL:\n\n";
print $history_tbl1;
print "\n";

done_testing($test_count);
