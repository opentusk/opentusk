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

use strict;
use warnings;

use HSDB4::Constants;
use TUSK::Core::School;
use Data::Dumper;
my $dbh = HSDB4::Constants::def_db_handle();

my $schools = HSDB4::Constants::getSchoolObject();

foreach my $school( @$schools){
    my $school_id = $school->getPrimaryKeyID();
    my $school_name = $school->getSchoolName();
    my $title = $school_name . " version 1";
    my $description = "first version";
    my $sql = qq( INSERT INTO tusk.competency_version VALUES ( $school_id, $school_id, '$title', '$description', now(), 'migration', now() ));
    my $sth = $dbh->prepare( $sql );
    $sth->execute();
    $sth->finish;
    print $school->getPrimaryKeyID()."\n";    

}



