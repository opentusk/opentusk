# Copyright 2012 Tufts University 
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



package HSDB45::Authorization;

use strict;
use XML::Twig;
use HSDB4::SQLRow::User;
use HSDB45::Course;
use TUSK::Constants;

BEGIN {
    use vars qw($VERSION);
    $VERSION = do { my @r = (q$Revision: 1.13 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
}

sub version { return $VERSION }

# dependencies for things that relate to caching
my @mod_deps  = ('HSDB4::SQLRow::User',
		 'HSDB45::Course');
my @file_deps = ();

sub get_mod_deps {
    return @mod_deps;
}

sub get_file_deps {
    return @file_deps;
}


#
# Sub takes nothing and returns blessed Authorization object
#
sub new {
    #
    # creates a new class
    #
    my $class = shift;
    $class = ref $class || $class;
    my $self = {};
    bless $self, $class;
    return $self;
}

#
# sub takes a user_id and a content object and determines if the user can view it
#
sub can_user_view_content {
    my $self = shift;
    my $user_id = shift;
    my $content = shift;


    # Return access if there is no content passed
    # this allows the missing page handler to take care of the 
    # problem
    return 1 unless $content->primary_key();

    # Get the read access of this content
    my $access = $content->read_access;

    # If the access is None, then absolutely lock it
    return 0 if $access eq 'None';

    # If it's a public document, then it's OK
    return 1 if $access eq 'Guests';

    # Otherwise, guests are not authorized
    return 0 if HSDB4::Constants::is_guest($user_id) || !$user_id;

    # If we are the TUSK::Constants::ShibbolethUserID then we need to check the shib rules for courses and then see if this content is somehow related to this course
    my $shibUserID = -1;
    $shibUserID = TUSK::Shibboleth::User->isShibUser($user_id);
    if($shibUserID > -1) {
	my $courseShares = TUSK::Course::CourseSharing->new()->getCurrentSharedCourses($shibUserID);
	if(scalar(@{$courseShares})) {return 1;}
	return 0;
    }

    my $user = HSDB4::SQLRow::User->new->lookup_key($user_id);

    # always allow authors to view their content
    return 1 if ($content->is_user_author($user_id));

    # if access is Authors and we have gotten this far then we know user is not an author
    return 0 if ($access eq 'Authors');

    # we have a real user
    return 1 if (($access eq 'All Users') && (!$user->restricted));

    # we've already returned true for 'All Users' access, now reject if no affiliation
    return 0 if (!$user->affiliation);

    # If it's for HSDB users, and the user isn't restricted then it's OK, since we just threw out the guests
    return 1 if (($access eq 'HSDB Users') && (!$user->restricted));

    ## now we're left with restricted users and read access of Authors, Course Faculty, Course Users

    my $course = $content->course;
    ## likewise for course faculty
    if ($access eq 'Course Faculty' || $access eq 'Course Users') {
	return 1 if ($course->user_primary_role($user_id));
	return 0 if ($access eq 'Course Faculty');
    }
    ## remaining status is restricted users or read_access to Course Users
    ## if the content is marked for course users, or the user is restricted, this check and return
    ## meets both criterion
    ## need to check if user is linked to the course (link_course_student)
    return 1 if ($course->is_child_student($user_id));

    ## or if user is linked to a user group that is linked to the course (link_course_user_group,link_user_group_user)
    foreach ($course->child_user_groups) {
	return 1 if ($_->contains_user($user_id));
    }

    ## the user has failed to meet any of the requirements to get at this content, return a failure
    return 0;
}

sub valid_account {
	my $self = shift;
	my $user_id = shift;
	my $shibUser = $TUSK::Constants::shibbolethUserID;
	return 1 if ($user_id =~ /$shibUser/);

	my $user = HSDB4::SQLRow::User->new()->lookup_key($user_id);
	return 1 if ($user->active && !$user->is_expired);
	return 0;
}

1;
