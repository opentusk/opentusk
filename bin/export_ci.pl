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

# exit main(@ARGV) unless caller;

# TESTING
exit main(
    '--school' => 'Medical',
    '--start-date' => '2012-06-01',
    '--end-date' => '2013-06-01',
) unless caller;

sub usage {
    return <<'END_USAGE';
Usage: perl export_ci.pl --school=<school_name>
                         --start-date=<YYYY-MM-DD>
                         --end-date=<YYYY-MM-DD>
END_USAGE
}

sub main {
    local @ARGV = @_;

    my (
        $help,
        $school,
        $start_date,
        $end_date
    );
    GetOptions(
        'help' => \$help,
        'school=s' => \$school,
        'start-date=s' => \$start_date,
        'end-date=s' => \$end_date,
    );

    if ($help) {
        print usage;
        return 0;
    }

    if ( ! $school ) {
        warn "Error: The 'school' argument is required.";
        return 1;
    }
    if ( ! $start_date ) {
        warn "Error: The 'start-date' argument is required.";
        return 1;
    }
    if ( ! $end_date ) {
        warn "Error: The 'end-date' argument is required.";
        return 1;
    }

    my $ci_report = TUSK::Medbiq::Report->new(
        school => $school,
        start_date => HSDB4::DateTime->new->in_mysql_date($start_date),
        end_date => HSDB4::DateTime->new->in_mysql_date($end_date),
    );
    $ci_report->write_report;

    return 0;
}
