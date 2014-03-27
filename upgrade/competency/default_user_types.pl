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

use Data::Dumper;

my $schools = HSDB4::Constants::getSchoolObject();

my $dbh = HSDB4::Constants::def_db_handle();

main();

sub main {
    foreach my $school ( @{$schools} ){
	my $sql = qq(SELECT enum_data_id, short_name FROM tusk.enum_data WHERE namespace = "competency.user_type.id");
	my $sth = $dbh->prepare($sql);

	$sth->execute();

	my $user_types = $sth->fetchall_hashref( 'short_name' );
	$sth->finish;
	
	foreach my $short_name( keys %{$user_types} ){
	    if ( $short_name eq 'competency' ){
		my $enum_id = $user_types->{$short_name}->{enum_data_id};
		print $enum_id;
		$sql = qq(INSERT INTO tusk.competency_user_type (name, competency_type_enum_id, school_id) VALUES( 'Competency', $enum_id, $school));
		$sth = $dbh->prepare($sql);
		$sth->execute();
		$sth->finish;

	    };
	}
	
    }
}
