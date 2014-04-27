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
use TUSK::Constants;
use HSDB4::SQLRow::Objective;

use TUSK::Competency::Competency;
use TUSK::Competency::Course;
use TUSK::Competency::Content;
use TUSK::Competency::ClassMeeting;
use TUSK::Course;

my $schools = HSDB4::Constants::getSchoolObject();

my $dbh = HSDB4::Constants::def_db_handle();
my %tusk_courses = ();
my %objectives = ();

main();

sub main{
    createTuskCourseObjects();
    %objectives = map { $_->getPrimaryKeyID() => $_->out_label() } HSDB4::SQLRow::Objective->new()->lookup_all();

#comment the functions out below as intended

    migrateContentObjectives();
    migrateClassMeetingObjectives();
}

sub createTuskCourseObjects{
    foreach my $course_obj( @{ TUSK::Course->new()->lookup() } ){
	$tusk_courses{ $course_obj->getSchoolID() }{ $course_obj->getSchoolCourseCode() } = $course_obj->getPrimaryKeyID();  
    }
}

sub migrateContentObjectives{
    my $sql = qq( SELECT hsdb4.link_content_objective.parent_content_id,
		      hsdb4.link_content_objective.child_objective_id,
		      hsdb4.link_content_objective.sort_order,
		      hsdb4.link_content_objective.relationship,
		      tusk.school.school_id FROM hsdb4.link_content_objective 
		  INNER JOIN hsdb4.content ON hsdb4.content.content_id = hsdb4.link_content_objective.parent_content_id 
		  INNER JOIN tusk.school ON hsdb4.content.school = tusk.school.school_name;);    
    my $sth = $dbh->prepare( $sql );
    $sth->execute();
    my $content_objectives = $sth->fetchall_arrayref();
    $sth->finish;

    $sql = qq( SELECT objective_id, body FROM hsdb4.objective);
    $sth = $dbh->prepare( $sql );
    $sth->execute();
    my $content_objectives_body = $sth->fetchall_hashref('objective_id');
    $sth->finish;

    foreach my $content_objective ( @{$content_objectives} ){
	my $competency = TUSK::Competency::Competency->new();

	$competency->setFieldValues({
	    school_id => $content_objective->[4],
	    description => $content_objectives_body->{$content_objective->[1]}->{'body'},
	    competency_level => "content_objective",
	});
	$competency->save( { user => 'migration' });
	processContentRelationship( $content_objective->[0], $content_objective->[1], $competency->getCompetencyID(), $content_objective->[2], $content_objective->[3] );
    }
}

sub migrateClassMeetingObjectives {
    my $sql = qq( SELECT * FROM tusk\.class_meeting_objective);
    my $sth = $dbh->prepare( $sql );
    $sth->execute();
    my $class_meeting_objectives = $sth->fetchall_arrayref;
    $sth->finish;

    foreach my $class_meeting_objective ( @{ $class_meeting_objectives } ){
	my $competency = TUSK::Competency::Competency->new();

    	$competency->setFieldValues({
	    school_id => $class_meeting_objective->[3],
	    description => $objectives{ $class_meeting_objective->[2] },
	    competency_level => "class_meeting_objective",
	});
	$competency->save( { user => 'migration' } );
	processClassMeetingRelationship( $class_meeting_objective->[1], $class_meeting_objective->[2], $competency->getCompetencyID(), $class_meeting_objective->[3] );
    }
}

sub processContentRelationship {
    my ( $parent_content_id, $objective_id, $competency_id, $sort_order, $relationship ) = @_; 

    my $tusk_content_competency = TUSK::Competency::Content->new();

    $tusk_content_competency->setFieldValues({
	content_id => $parent_content_id,
	competency_id => $competency_id,
	sort_order => $sort_order,
	relationship => $relationship,
    });
    $tusk_content_competency->save( { user => 'migration' });
}

sub processClassMeetingRelationship {
    my ( $class_meeting_id, $objective_id, $competency_id, $sort_order ) = @_;

    my $tusk_class_meeting_competency = TUSK::Competency::ClassMeeting->new();

    $tusk_class_meeting_competency->setFieldValues({
	class_meeting_id => $class_meeting_id,
	competency_id => $competency_id,
	sort_order => $sort_order,
    });
    $tusk_class_meeting_competency->save( { user => 'migration' });

}




