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

exit main(@ARGV) unless caller;

sub usage {
    return <<'END_USAGE';
Usage: perl export_ci.pl --school=<school_name>
END_USAGE
}

sub main {
    local @ARGV = @_;

    my (
        $help,
        $school,
    );
    GetOptions(
        'help' => \$help,
        'school=s' => \$school,
    );

    if ($help) {
        print usage;
        return 0;
    }

    if (! $school) {
        warn "Error: The 'school' argument is required.";
        return 1;
    }

    my $ci_report = TUSK::Medbiq::Report->new( school => $school );
    $ci_report->write_report;

    return 0;
}
