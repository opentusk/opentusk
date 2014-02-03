#! /usr/bin/env perl

# Copyright 2013 Tufts University
#
# Licensed under the Educational Community License, Version 1.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.opensource.org/licenses/ecl1.php
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

use strict;
use warnings;
use utf8;

use FindBin;
use lib qq($FindBin::Bin/../../lib);

use Getopt::Long;
use TUSK::DB::Util qw(tusk_tables);

if (scalar(@ARGV) && $ARGV[0] eq '--help') {
    print usage();
    exit;
}

my @input_statements = process_input();

my @creates = process_sql(@input_statements);
print join("\n\n", @creates) . "\n";

sub process_input {
    my @creates;
    my @current;
  INPUT:
    while (my $line = <>) {
        chomp $line;
        if ($line =~ m{^\s*$}) {
            push @creates, join("\n", @current) if @current;
            @current = ();
            next INPUT;
        }
        push @current, $line;
    }
    push @creates, join("\n", @current) if @current;
    return @creates;
}

sub process_sql {
    my @stmts = @_;
    my @creates = grep m{\A \s* create \s+ table}ixms, @stmts;
    my @output_creates;
    foreach my $sql (@stmts) {
        my ($tbl, $history) = tusk_tables($sql);
        push @output_creates, $tbl, $history;
    }
    return @output_creates;
}

sub usage {
    return <<'END_USAGE';
Usage: perl bin/db/tusk_tables.pl [sqlfile1 [sqlfile2 ...]]

If file names are given, scans the files for create table statements
and adds created_by, created_on, modified_by, modified_on columns and
a history table for each input table. Otherwise uses stdin. Prints to
stdout.

SQL statements must be separated by a blank line for use in this
script.
END_USAGE
}
