#!/usr/bin/perl

# Copyright 2012 Tufts University
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

use Getopt::Long;
use TUSK::Medbiq::Report;
use HSDB4::DateTime;
use IO::File;

exit main(@ARGV) unless caller;

sub usage {
    return <<'END_USAGE';
Usage: perl export_ci.pl --school=<school_name>
                         --start-date=<YYYY-MM-DD>
                         --end-date=<YYYY-MM-DD>
			 --file=<filename_with_path>
END_USAGE
}

sub main {
    local @ARGV = @_;

    my (
        $help,
        $school,
        $start_date,
        $end_date,
	$file
    );

    GetOptions(
        'help' => \$help,
        'school=s' => \$school,
        'start-date=s' => \$start_date,
        'end-date=s' => \$end_date,
        'file=s' => \$file,
    );

    if ($help) {
        print usage;
        return 0;
    }
				   
    unless ($school) {
        warn "Error: The 'school' argument is required.";
        return 1;
    }

    unless ($start_date) {
        warn "Error: The 'start-date' argument is required.";
        return 1;
    }

    unless ($end_date) {
        warn "Error: The 'end-date' argument is required.";
        return 1;
    }

    unless ($file) {
        warn "Error: The 'file' argument is required.";
        return 1;
    }

    my $output = IO::File->new(">$file") or die "IO::File->new: $!";

    my $ci_report = TUSK::Medbiq::Report->new(
        school => $school,
        start_date => HSDB4::DateTime->new->in_mysql_date($start_date),
        end_date => HSDB4::DateTime->new->in_mysql_date($end_date),
        title => "$school Curriculum Inventory",
        description => '! ENTER DESCRIPTION HERE !',
        output => $output,
    );

    $ci_report->write_report();
    $output->close();

    return 0;
}
