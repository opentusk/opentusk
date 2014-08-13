#!/usr/bin/perl

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

# Script copies URIs from the Competency table and inserts them to the new feature_link table. 
# Removes URIs from the Competency table at the end.
# IMPORTANT : It is highly recommended that you create a backup of your competency table
# before running this script.

use strict;
use warnings;

use HSDB4::Constants;
use HSDB4::SQLRow::Objective;
use TUSK::Constants;
use TUSK::Enum::Data;

use TUSK::Competency::Competency;
use TUSK::Feature::Link;

use Data::Dumper; #remove for production

my $dbh = HSDB4::Constants::def_db_handle();
my $schools = HSDB4::Constants::getSchoolObject();

main();

sub main {
    getURIsFromCompetencyTable();
}

sub getURIsFromCompetencyTable {
    my $competency_level_enum_id = TUSK::Enum::Data->lookupReturnOne( "namespace=\"competency.level_id\" AND short_name =\"national\"" )->getPrimaryKeyID;
    print $competency_level_enum_id. "\n";
}

