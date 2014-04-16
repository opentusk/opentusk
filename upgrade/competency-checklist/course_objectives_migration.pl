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
use TUSK::Competency::Course;
use TUSK::Competency::Hierarchy;

use TUSK::Enum::Data;
use TUSK::Course;

my $schools = HSDB4::Constants::getSchoolObject();

my $dbh = HSDB4::Constants::def_db_handle();
my %tusk_courses = ();
my %objectives = ();

main();

sub main {
    createTuskCourseObjects();
    %objectives = map { $_->getPrimaryKeyID() => $_->out_label() } HSDB4::SQLRow::Objective->new()->lookup_all();

    migrateCourseObjectives();
}

sub createTuskCourseObjects {
    foreach my $course_obj( @{ TUSK::Course->new()->lookup() } ){
	$tusk_courses{ $course_obj->getSchoolID() }{ $course_obj->getSchoolCourseCode() } = $course_obj->getPrimaryKeyID();  
    }
}

sub migrateCourseObjectives {
    my $competency_level_enum = TUSK::Enum::Data->new()->lookupReturnOne( "namespace=\"competency.level_id\" AND short_name =\"course\"" );
    my $competency_user_type = TUSK::Competency::UserType->new()->lookupReturnOne( "name = \"Competency\""  );				
    
    foreach my $school( @$schools ) {
	my $school_db = $school->getSchoolDb();
	my $sql = qq( SELECT * FROM $school_db\.link_course_objective);
	my $sth = $dbh->prepare( $sql );
	$sth->execute();
	my $course_objectives = $sth->fetchall_arrayref;
	$sth->finish;

	foreach my $course_objective ( @{ $course_objectives } ) {
	    my $competency = TUSK::Competency::Competency->new();
	    $competency->setFieldValues ({
		school_id => $school->getPrimaryKeyID(),
		description => $objectives{ $course_objective->[1] },
		competency_level_enum_id => $competency_level_enum->getPrimaryKeyID(),
		competency_user_type_id => $competency_user_type->getPrimaryKeyID()
	    });
	    $competency->save({user => 'migration'});
	    my $competency_hierarchy = TUSK::Competency::Hierarchy->new();
	    $competency_hierarchy->setFieldValues ({
		school_id => $school->getPrimaryKeyID(),
		lineage => '/',
                parent_competency_id => 0,
                child_competency_id => $competency->getPrimaryKeyID(),
		sort_order => 0,
		depth => 0
	    });
	    $competency_hierarchy->save({user => 'migration'});
	    processCourseRelationship($course_objective->[0], $course_objective->[1], $competency->getCompetencyID(), $school_db, $school->getPrimaryKeyID(), $course_objective->[2] , $course_objective->[3]);
	}
    }
}

sub processCourseRelationship {
    my ($hsdb45_course_id, $objective_id, $competency_id, $school_db, $school_id, $sort_order, $relationship) = @_;

    my $tusk_course_id = $tusk_courses{$school_id}{$hsdb45_course_id};
    if (!$tusk_course_id) {
	print "Warning: Corresponding course does not exist for objective ".$objective_id.". Skipping...\n"; 
	return;
    };
    my $tusk_competency_course = TUSK::Competency::Course->new();

    $tusk_competency_course->setFieldValues ({
	course_id => $tusk_course_id,
	competency_id => $competency_id,
	sort_order => $sort_order,
    });
    $tusk_competency_course->save( { user=> 'migration' });
}

