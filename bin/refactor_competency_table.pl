#!/usr/bin/perl

##################################################################
#
# Tool to Refactor and Optimize Competency Table
#
# Better optimizes the way different competencies are stored in TUSK by
# standardizing across competency levels. After the script all competencies
# will be stored in the 'title' field in the 'competency' table and the 
# 'description' field will be removed.
#
# NOTE:
#
#
# Usage: 
##################################################################

use strict;
use warnings;

use HSDB4::Constants;

use TUSK::Enum::Data;

use TUSK::Application::Competency::Competency;
use TUSK::Competency::Competency;
use TUSK::Competency::Hierarchy;

main();

sub main {
    refactorContentCourseSession();
}

sub refactorContentCourseSession {
    use Data::Dumper; #remove this
    
    my $competency_levels = grabLevels();
    print Dumper $competency_levels;

    print "Moving Course Competencies...\n";
    my $course_competencies = TUSK::Competency::Competency->lookup("competency_level_enum_id = $competency_levels->{course}");

    my $temp_counter = 0;

    foreach my $course_competency (@{$course_competencies}) {
	$temp_counter++;
	if ($temp_counter > 5) {
	    last;
	}

	$course_competency->setTitle($course_competency->getDescription());
	$course_competency->save({user => "script"});
	print $course_competency->getTitle();
	print "\n\n";
    }

    print "Moving Content Competencies...\n";

    my $content_competencies = TUSK::Competency::Competency->lookup("competency_level_enum_id = $competency_levels->{content}");

    $temp_counter = 0;

    foreach my $content_competency (@{$content_competencies}) {
	$temp_counter++;
	if ($temp_counter > 5) {
	    last;
	}

	$content_competency->setTitle($content_competency->getDescription());
	$content_competency->save({user => "script"});
	print $content_competency->getTitle();
	print "\n\n";
    }

    
    print "Moving Class Meeting Competencies...\n";

    my $class_meeting_competencies = TUSK::Competency::Competency->lookup("competency_level_enum_id = $competency_levels->{class_meet}");

    $temp_counter = 0;

    foreach my $class_meeting_competency (@{$class_meeting_competencies}) {
	$temp_counter++;
	if ($temp_counter > 5) {
	    last;
	}

	$class_meeting_competency->setTitle($class_meeting_competency->getDescription());
	$class_meeting_competency->save({user => "script"});
	print $class_meeting_competency->getTitle();
	print "\n\n";
    }
}

sub refactorSchool {

}

sub grabLevels {
    my $competency_levels = TUSK::Enum::Data->lookup("namespace = 'competency.level_id'");
    my %competency_levels_hash;
    foreach my $competency_level (@{$competency_levels}) {
	$competency_levels_hash{$competency_level->getShortName()} = $competency_level->getPrimaryKeyID();
    }
    return \%competency_levels_hash;
}
