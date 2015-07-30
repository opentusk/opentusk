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
    print "Starting Competency Table Refactor script....\n...\n\n";
    refactorContentCourseSession();
    refactorSchool();
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

sub refactorSchool {
    print "\n\nMoving School Competencies...\n\n";
    my $school_competency_level = TUSK::Enum::Data->lookupReturnOne("namespace = 'competency.level_id' AND short_name = 'school'")->getPrimaryKeyID();
    my $school_competencies = TUSK::Competency::Competency->lookup("competency_level_enum_id = $school_competency_level");

    my $supporting_competency_types = TUSK::Competency::UserType->lookup("", undef, undef, undef,
                                                                                 [TUSK::Core::JoinObject->new("TUSK::Enum::Data", {
                                                                                     origkey => 'competency_type_enum_id',
                                                                                     joinkey => 'enum_data_id',
                                                                                     jointype => 'inner',
                                                                                     joincond => 'namespace = "competency.user_type.id" AND short_name = "info"'})]);

    my %supporting_competency_type_ids;

    foreach my $supporting_competency_type (@{$supporting_competency_types}) {
        $supporting_competency_type_ids{$supporting_competency_type->getSchoolID()} = $supporting_competency_type->getPrimaryKeyID();
    }

    my $temp_counter = 0;

    foreach my $school_competency(@{$school_competencies}) {
            if ($school_competency->getTitle()) {
                print "Processing Competency: " . $school_competency->getTitle() . "\n\n";
            }
            if ($school_competency->getDescription()) {
                my $description = $school_competency->getDescription();

                my $new_supporting_competency = TUSK::Competency::Competency->new();

                $new_supporting_competency->setFieldValues({
                    title => $school_competency->getDescription(),
                    competency_user_type_id => $supporting_competency_type_ids{$school_competency->getSchoolID()},
                    school_id => $school_competency->getSchoolID(),
                    competency_level_enum_id => $school_competency_level,
                    version_id => $school_competency->getVersionID(),
                });

                $new_supporting_competency->save({user => 'script'});

                my $new_hierarchy = TUSK::Competency::Hierarchy->new();

                $new_hierarchy->setFieldValues({
                    school_id => $school_competency->getSchoolID(),
                    lineage => "/" . $school_competency->getPrimaryKeyID() . "/",
                    parent_competency_id => $school_competency->getPrimaryKeyID(),
                    child_competency_id => $new_supporting_competency->getPrimaryKeyID(),
                    sort_order => 0,
                    depth => 1
                });

                $new_hierarchy->save({user => 'script'});
            }
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
