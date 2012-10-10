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


package HSDB45::Course::XMLRenderer;

use strict;
use XML::Twig;
use Carp;
use HSDB45::Course;
use HSDB4::SQLRow::User;
use HSDB4::DateTime;
use TUSK::Constants;

# Description: Constructor for a HSDB45::Course::XMLRenderer
# Input: The HSDB45::Eval::Course object and HSDB45::Eval::Course::Body object to be rendered
# Output: The new HSDB45::Course::XMLRenderer object
sub new {
    my $input = shift;
    my $class = ref $input || $input;
    my $self = {};
    bless($self, $class);
    return $self->init( @_ );
}

# Description: Private initializer for the XMLRenderer
# Input: The HSDB45::Eval::Course object and HSDB45::Eval::Course::Body object to be rendered
# Output: The new HSDB45::Course::XMLRenderer object
sub init {
    my $self = shift();
    my $course = shift();
    my $body = shift();
    $self->{-course} = $course;
    $self->{-body} = $body;
    $self->{-error} = undef;
    return $self;
}

# Description: Accessor for the Course object
# Input: none
# Output: The Course object
sub course {
    my $self = shift();
    return $self->{-course};
}

# Description: Accessor for the Body object
# Input: none
# Output: The Body object
sub body {
    my $self = shift();
    return $self->{-body};
}

# Description: Renders the xml text as per HSCML/Rules/course.dtd
# Input: none
# Output: a string containing the xml text
sub xml_text {
    my $self = shift();
    my $path = shift;
    $path = $TUSK::Constants::XMLRulesPath unless ($path);
    unless($self->{-xml_text}) {
	my $course_elt = XML::Twig::Elt->new('course',
					     {'course-id' => $self->course()->course_id(),
					      'school'    => $self->course()->school()});

	my $title_elt = XML::Twig::Elt->new('title', {}, $self->course()->title());
	$title_elt->paste('last_child', $course_elt);

	if($self->course()->abbreviation()) {
	    my $abbreviation_elt = XML::Twig::Elt->new('abbreviation', {}, $self->course()->abbreviation());
	    $abbreviation_elt->paste('last_child', $course_elt);
	}

	if($self->course()->color()) {
	    my $color_elt = XML::Twig::Elt->new('color', {}, $self->course()->color());
	    $color_elt->paste('last_child', $course_elt);
	}

	my $registrar_code_elt = XML::Twig::Elt->new('registrar-code', {}, $self->course()->registrar_code());
	$registrar_code_elt->paste('last_child', $course_elt);

	my $faculty_list_elt = XML::Twig::Elt->new('faculty-list');
	foreach my $user ($self->course()->child_users()) {
	    my $full_user_name = "";
	    $full_user_name .= $user->first_name();
	    $full_user_name .= " " . $user->middle_name() if($user->middle_name());
	    $full_user_name .= " " . $user->last_name();
	    $full_user_name .= ", " . $user->degree() if($user->degree());

	    my @role_elts = ();
	    foreach my $role (split(',', $user->roles())) {
		push(@role_elts, XML::Twig::Elt->new('course-user-role', {'role' => $role}));
	    }


	    my $user_elt = XML::Twig::Elt->new('course-user',
					       { 'user-id' => $user->user_id(),
						 'name'    => $full_user_name
						 },
					       @role_elts
					       );
	    $user_elt->paste('last_child', $faculty_list_elt);
	}
	$faculty_list_elt->paste('last_child', $course_elt);

	if($self->course()->child_courses()) {
	    my $sub_course_list_elt = XML::Twig::Elt->new('sub-course-list');
	    foreach my $sub_course ($self->course()->child_courses()) {
		my $sub_course_elt = XML::Twig::Elt->new('sub-course',
							 {'course-id' => $sub_course->course_id(),
							  'school'    => $sub_course->school()},
							 $sub_course->out_label());
		$sub_course_elt->paste('last_child', $sub_course_list_elt);
	    }
	    $sub_course_list_elt->paste('last_child', $course_elt);
	}

	my $teaching_site_list_elt = new XML::Twig::Elt('teaching-site-list');
	foreach my $teaching_site ($self->course()->child_teaching_sites()) {
	    my $teaching_site_elt = XML::Twig::Elt->new('teaching-site',
							{'teaching-site-id' => $teaching_site->site_id()});
	    my $site_name_elt = XML::Twig::Elt->new('site-name',
						    {},
						    $teaching_site->site_name());
	    $site_name_elt->paste('last_child', $teaching_site_elt);
	    my $site_location_elt = XML::Twig::Elt->new('site-location', {}, $teaching_site->site_city_state());
	    $site_location_elt->paste('last_child', $teaching_site_elt);
	    $teaching_site_elt->paste('last_child', $teaching_site_list_elt);
	}
	$teaching_site_list_elt->paste('last_child', $course_elt);

	my $learning_objective_list_elt = XML::Twig::Elt->new('learning-objective-list');
	foreach my $learning_objective ($self->course()->child_objectives()) {
	    my $objective_ref_elt = XML::Twig::Elt->new('objective-ref',
							{'objective-id',
							 $learning_objective->objective_id()},
							 $learning_objective->out_label());
	    $objective_ref_elt->paste('last_child', $learning_objective_list_elt);
	}
	$learning_objective_list_elt->paste('last_child', $course_elt);

	my $content_list_elt = XML::Twig::Elt->new('content-list');
	foreach my $content_item ($self->course()->active_child_content()) {
	    my $authors = join (', ', map { $_->out_abbrev } $content_item->child_authors());
	    my $content_elt = XML::Twig::Elt->new('content-ref',
						  {'content-id'   => $content_item->content_id(),
					           'content-type' => $content_item->content_type(),
						   'authors'      => $authors},
						  $content_item->title());
	    $content_elt->paste('last_child', $content_list_elt);
	}
	$content_list_elt->paste('last_child', $course_elt);

	# add schedule stuff here by looping through the ClassMeeting objects

	my $schedule_elt = XML::Twig::Elt->new('schedule');
	foreach my $class_meeting ($self->course()->class_meetings()) {
	    my $meeting_date = $class_meeting->out_starttime()->out_string_date_short();
	    my $start_time   = $class_meeting->out_starttime()->out_string_time();
	    my $end_time     = $class_meeting->out_endtime()->out_string_time();
            my $class_meeting_elt = XML::Twig::Elt->new('class-meeting',
                                                        {'class-meeting-id' => $class_meeting->class_meeting_id(),
                                                         'meeting-date'     => $meeting_date,
                                                         'start-time'       => $start_time,
                                                         'end-time'         => $end_time,
                                                         'location'         => $class_meeting->location(),
                                                         'type'             => $class_meeting->type(),
                                                         'title'            => $class_meeting->title() });
		foreach my $user ($class_meeting->child_users()) {
		    my $full_user_name = "";
		    $full_user_name .= $user->first_name();
		    $full_user_name .= " " . $user->middle_name() if($user->middle_name());
		    $full_user_name .= " " . $user->last_name();
		    $full_user_name .= ", " . $user->degree() if($user->degree());

		    my $user_elt = XML::Twig::Elt->new('class-meeting-user',
						       { 'user-id' => $user->user_id(),
							 'name'    => $full_user_name
						 },
					       );
		    $user_elt->paste('last_child', $class_meeting_elt);
		}

	    $class_meeting_elt->paste('last_child', $schedule_elt);
	}
	$schedule_elt->paste('last_child', $course_elt);

	if(defined($self->body()->elt())) {
	    if($self->body()->attendance_policy()) {
		$self->body()->attendance_policy()->copy()->paste('last_child', $course_elt);
	    }
	    else {
		warn "No attendance-policy for course_id=" . $self->body()->course_id();
	    }

	    if($self->body()->grading_policy()) {
		$self->body()->grading_policy()->copy()->paste('last_child', $course_elt);
	    }
	    else {
		warn "No grading-policy for course_id=" . $self->body()->course_id();
	    }

	    if($self->body()->reading_list()) {
		$self->body()->reading_list()->copy()->paste('last_child', $course_elt);
	    }

	    if($self->body()->course_description()) {
		$self->body()->course_description()->copy()->paste('last_child', $course_elt);
	    }
	    else {
		warn "No course-description for course_id=" . $self->body()->course_id();
	    }

	    if($self->body()->tutoring_services()) {
		$self->body()->tutoring_services()->copy()->paste('last_child', $course_elt);
	    }
	    else {
		warn "No tutoring-services for course_id=" . $self->body()->course_id();
	    }

	    if($self->body()->course_structure()) {
		$self->body()->course_structure()->copy()->paste('last_child', $course_elt);
	    }
	    else {
		warn "No course-structure for course_id=" . $self->body()->course_id();
	    }

	    if($self->body()->student_evaluation()) {
		$self->body()->student_evaluation()->copy()->paste('last_child', $course_elt);
	    }
	    else {
		warn "No student-evaluation for course_id=" . $self->body()->course_id();
	    }

	    if($self->body()->equipment_list()) {
		$self->body()->equipment_list()->copy()->paste('last_child', $course_elt);
	    }
	    else {
		warn "No equipment-list for course_id=" . $self->body()->course_id();
	    }

	    if($self->body()->course_other()) {
		$self->body()->course_other()->copy()->paste('last_child', $course_elt);
	    }
	    else {
		warn "No course-other for course_id=" . $self->body()->course_id();
	    }
	}

	$self->{-xml_text} = "<?xml version=\"1.0\"?>\n<!DOCTYPE course SYSTEM \"".$path."course.dtd\">".$course_elt->sprint();
	}

	return $self->{-xml_text};
	}

	sub error {
	my $self = shift;
	my $msg = shift;
	if ($msg) { 
		$self->{-error} = $msg 
	}
	return $self->{-error};
	}

	# Description: applies an xsl transform to the xml of the course object
	# Input: a string containing the path of the style sheet to be applied, and a hash of parameters
	# Output: a string containing the transformed XML
	sub transform {
	my $self = shift();
	my $stylesheet_path = shift();
	my $parser = XML::LibXML->new();
	my $xslt = XML::LibXSLT->new();
	my $source = eval { $parser->parse_string($self->xml_text()) } ;
	if ($@){
	$self->error($@);
	return "";
	}
	my $style_doc = $parser->parse_file($stylesheet_path);
	my $stylesheet = $xslt->parse_stylesheet($style_doc);
	my $results =  eval { $stylesheet->transform($source, XML::LibXSLT::xpath_to_string(@_)) }; 
    if ($@){
	$self->error($@);
	return "";
    }
    return $stylesheet->output_string($results);
}

1;
__END__
