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

# Script to import course objectives from hsdb4 course tables to the new TUSK::Competency table.

use strict;
use warnings;

use HSDB4::Constants;
use TUSK::Constants;
use HSDB4::SQLRow::Objective;

use TUSK::Competency::Competency;
use TUSK::Competency::UserType;

use TUSK::Enum::Data;

my $schools = HSDB4::Constants::getSchoolObject();

my $dbh = HSDB4::Constants::def_db_handle();

main();

sub main {
    my $sql = qq(SELECT enum_data_id, short_name FROM tusk.enum_data WHERE namespace = "competency.user_type.id");
    my $sth = $dbh->prepare($sql);

    $sth->execute();

    my $user_types = $sth->fetchall_hashref( 'short_name' );
    $sth->finish;
    
    foreach my $school( @{$schools}) {
	my $current_school_id =  $school->getPrimaryKeyID;

	$sql = qq(INSERT INTO tusk.competency_user_type (name, competency_type_enum_id, school_id, modified_by, modified_on) VALUES( 'Competency', $user_types->{competency}->{enum_data_id}, $current_school_id, 'script', now()));
	$sth = $dbh->prepare($sql);
	$sth->execute();
	$sth->finish;

	$sql = qq(INSERT INTO tusk.competency_user_type (name, competency_type_enum_id, school_id, modified_by, modified_on) VALUES( 'Competency Category', $user_types->{category}->{enum_data_id}, $current_school_id, 'script', now()));
	$sth = $dbh->prepare($sql);
	$sth->execute();
	$sth->finish;

	$sql = qq(INSERT INTO tusk.competency_user_type (name, competency_type_enum_id, school_id, modified_by, modified_on) VALUES( 'Supporting Information', $user_types->{info}->{enum_data_id}, $current_school_id, 'script', now()));
	$sth = $dbh->prepare($sql);
	$sth->execute();
	$sth->finish;
    }


#following sets all competency_level_id to refer to 'school' as all the existing competencies before the upgrade on the competency table are school competencies.

    $sql =qq(SELECT enum_data_id FROM tusk.enum_data WHERE namespace="competency.level_id" AND short_name="school");
    $sth = $dbh->prepare($sql);
    $sth->execute();
    my $school_level_id = $sth->fetchall_arrayref;    
    $sth->finish();
    
    $sql = qq(UPDATE course_test_temp.competency SET competency_level_enum_id = $school_level_id->[0]->[0]);
    $sth = $dbh->prepare($sql);
    $sth->execute();
    $sth->finish;

}
