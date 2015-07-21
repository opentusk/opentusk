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
    #refactorContentCourseSession();
    refactorSchool();
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
    print "Moving School Competencies...\n";
    my $school_competency_level = TUSK::Enum::Data->lookupReturnOne("namespace = 'competency.level_id' AND short_name = 'school'")->getPrimaryKeyID();
    my $school_competencies = TUSK::Competency::Competency->lookup("competency_level_enum_id = $school_competency_level");

    my $supporting_competency_types = TUSK::Competency::UserType->lookup("", undef, undef, undef, 
										 [TUSK::Core::JoinObject->new("TUSK::Enum::Data", { 
										     origkey => 'competency_type_enum_id', 
										     joinkey => 'enum_data_id', 
										     jointype => 'inner', 
										     joincond => 'namespace = "competency.user_type.id" AND short_name = "info"'})]);
    
    my @supporting_competency_type_ids;

    foreach my $supporting_competency_type (@{$supporting_competency_types}) {
	push @supporting_competency_type_ids, $supporting_competency_type->getPrimaryKeyID();
    }
									       

    my $temp_counter = 0;

    foreach my $school_competency(@{$school_competencies}) {
	$temp_counter++;
	if ($temp_counter <= 5) {
	    print "TITLE: " . $school_competency->getTitle() . "\n\n";
	    if ($school_competency->getDescription()) {
		my $description = $school_competency->getDescription();
		
		my $new_supporting_competency = TUSK::Competency::Competency->new();

=for

		$new_supporting_competency->setFieldValues({
		    title => $school_competency->getDescription(),
		    user_type_id => $school_competency_level,
		    #school_id = $school_competency->getSchoolID(),
		    #competency_level_enum_id => $supporting_level_id,
		    version_id => $school_competency->getVersionID(),
		    user => "script"
		});

		$new_supporting_competency->setFieldValues({
		    title => $school_competency->getDescription(),
		    user_type_id => $school_competency_level,
		    school_id = $school_competency->getSchoolID(),
		    competency_level_enum_id => $supporting_level_id,
		    version_id => $school_competency->getVersionID(),
		    user => "script"
		});

		print Dumper $supporting_competency_level;
=cut
	    }
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
