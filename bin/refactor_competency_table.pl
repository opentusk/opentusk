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
#    Moves Competency information for course-level, session-level
#    and content-level competencies from 'description' to 'title'
#    field. Version code changes follows this new pattern for
#    consistency with national-level and school-level competencies.
#
# Usage: 
# > perl refactor_competency_table.pl
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
    print "Starting Competency Table Refactor script....\n...\n\n";
    refactorContentCourseSession();
    print "Finished running Competency Table Refactor script\n"
}

sub refactorContentCourseSession {
    my $competency_levels = grabLevels();

    print "Moving Course Competencies...\n\n";
    my $course_competencies = TUSK::Competency::Competency->lookup("competency_level_enum_id = $competency_levels->{course}");

    foreach my $course_competency (@{$course_competencies}) {
        $course_competency->setTitle($course_competency->getDescription());
        $course_competency->save({user => "script"});
        print "Processing Competency: " . $course_competency->getTitle();
        print "\n\n";
    }

    print "\n\nMoving Content Competencies...\n\n";

    my $content_competencies = TUSK::Competency::Competency->lookup("competency_level_enum_id = $competency_levels->{content}");

    foreach my $content_competency (@{$content_competencies}) {
        $content_competency->setTitle($content_competency->getDescription());
        $content_competency->save({user => "script"});
        print "Processing Competency: " . $content_competency->getTitle();
        print "\n\n";
    }

    print "\n\nMoving Class Meeting Competencies...\n\n";

    my $class_meeting_competencies = TUSK::Competency::Competency->lookup("competency_level_enum_id = $competency_levels->{class_meet}");

    foreach my $class_meeting_competency (@{$class_meeting_competencies}) {
        $class_meeting_competency->setTitle($class_meeting_competency->getDescription());
        $class_meeting_competency->save({user => "script"});
        print "Processing Competency: " . $class_meeting_competency->getTitle();
        print "\n\n";
    }
}

sub grabLevels {
    my $competency_levels = TUSK::Enum::Data->lookup("namespace = 'competency.level_id'");
    my %competency_levels_hash;
    foreach my $competency_level (@{$competency_levels}) {
        $competency_levels_hash{$competency_level->getShortName()} = $competency_level->getPrimaryKeyID();
    }
    return \%competency_levels_hash;
}
