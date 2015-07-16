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

    print "Moving Content Competencies...\n";
    
    print "Moving Class Meeting Competencies...\n";
}

sub refactorSchool {

}

sub grabLevels {
    my $competency_levels = TUSK::Enum::Data->lookup("namespace = 'competency.level_id'");
    my %competency_levels_hash;
    foreach my $competency_level (@{$competency_levels}) {
	$competency_levels_hash{$competency_level->getPrimaryKeyID()} = $competency_level->getShortName();
    }
    return \%competency_levels_hash;
}
