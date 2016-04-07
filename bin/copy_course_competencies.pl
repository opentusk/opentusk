#!/usr/bin/perl

##################################################################
# 
# Copy course level competencies from one course to another
#
##################################################################

use strict;
use warnings;

use Getopt::Long;
my ($school, $course_source, $course_target);

BEGIN {
    GetOptions("school=s" => \$school,
	       "source=s" => \$course_source,
	       "target=s" => \$course_target
	       );

    if (!$school || !$course_source || !$course_target) {
	print "Usage: copy_course_competencies --school=<school_name> --source=<source_course_id> --target =<target_course_id> \nExample: copy_course_competencies --school=Medical --source=6 --target=200\n";
	exit;
    }
}

use TUSK::Application::Competency::Copy;

main();

sub main {
    my $courses_for_copying = {
	school => $school,
	course_source => $course_source,
	course_target => $course_target
    };

    use Data::Dumper;
    
    my $copying_courses = TUSK::Application::Competency::Copy->new($courses_for_copying);
    $copying_courses->copyCompetencies();
}
