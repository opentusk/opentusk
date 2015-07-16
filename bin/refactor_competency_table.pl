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
    print "Moving Course Competencies...\n";

    print "Moving Content Competencies...\n";
    
    print "Moving Class Meeting Competencies...\n";
}

sub refactorSchool {

}
