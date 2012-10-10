package HSDB45::Course::Formatter;

use strict;
use vars qw($VERSION);
use base qw(XML::Formatter);
use XML::Twig;
use XML::EscapeText qw(:escape);
use HSDB45::Course;
use TUSK::Constants;

$VERSION = do { my @r = (q$Revision: 1.11 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

sub version { return $VERSION; }

# dependencies for things that relate to caching
my @mod_deps  = ('HSDB45::Course');
my @file_deps = ();

sub get_mod_deps {
    return @mod_deps;
}

sub get_file_deps {
    return @file_deps;
}

sub new {
    my $incoming = shift;
    my $school = shift();
    my $id = shift();
    my $object = class_expected()->new(_school => $school, _id => $id);
    my $self = $incoming->SUPER::new($object);
    $self->{-doctype_decl} = 'course';
    $self->{-dtd_decl} = 'http://'. $TUSK::Constants::Domain .'.tufts.edu/DTD/course.dtd';
    $self->{-stylesheet_decl} = 'http://'. $TUSK::Constants::Domain .'/XSL/Course/course.xsl';
    return $self;
}

sub new_from_path {
    my $incoming = shift();
    my $path = shift();
    my $object = class_expected()->lookup_path($path);
    my $self = $incoming->SUPER::new($object);
    $self->{-doctype_decl} = 'course';
    $self->{-dtd_decl} = 'http://tusk.tufts.edu/DTD/course.dtd';
    $self->{-stylesheet_decl} = 'http://tusk.tufts.edu/XSL/Course/course.xsl';
    return $self;
}

sub class_expected { return 'HSDB45::Course' }

sub modified_since {
    my $self = shift;
    my $comp_date = shift;
}

sub course {
    my $self = shift;
    ref $self or die "Screwed up self object: $self";
    return $self->object();
}

sub faculty_list_elt {
    my $self = shift;

    my $faculty_list_elt = XML::Twig::Elt->new('faculty-list');
    foreach my $user ($self->course()->child_users()) {
	my $full_user_name = "";

	$full_user_name .= $user->first_name();
	$full_user_name .= " " . $user->middle_name() if($user->middle_name());
	$full_user_name .= " " . $user->last_name();
	$full_user_name .= ", " . $user->degree() if($user->degree());
	$full_user_name = make_pcdata($full_user_name);

	my @role_elts = ();
	foreach my $role (split(',', $user->roles())) {
	    $role = make_pcdata($role);
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
    return $faculty_list_elt;
}

sub sub_course_list_elt {
    my $self = shift;

    my $sub_course_list_elt = XML::Twig::Elt->new('sub-course-list');
    foreach my $sub_course ($self->course()->child_courses()) {
	my $sub_course_elt = 
	  XML::Twig::Elt->new('sub-course',
			      {'course-id' => $sub_course->course_id(),
			       'school'    => $sub_course->school()},
			      make_pcdata($sub_course->out_label()),
			      );
	$sub_course_elt->set_asis();
	$sub_course_elt->paste('last_child', $sub_course_list_elt);
    }
    return $sub_course_list_elt;
}

sub teaching_site_list_elt {
    my $self = shift;

    my $teaching_site_list_elt = new XML::Twig::Elt('teaching-site-list');
    foreach my $teaching_site ($self->course()->child_teaching_sites()) {
	my $teaching_site_elt = 
	  XML::Twig::Elt->new('teaching-site',
			      {'teaching-site-id' => $teaching_site->site_id()}
			      );
	my $site_name_elt = XML::Twig::Elt->new('site-name',
						{},
						make_pcdata($teaching_site->site_name()));
	$site_name_elt->set_asis();
	$site_name_elt->paste('last_child', $teaching_site_elt);
	my $site_location_elt = 
	  XML::Twig::Elt->new('site-location', {}, 
			      make_pcdata($teaching_site->site_city_state()));
	$site_location_elt->set_asis();
	$site_location_elt->paste('last_child', $teaching_site_elt);
	$teaching_site_elt->paste('last_child', $teaching_site_list_elt);
    }
    return $teaching_site_list_elt;
}

sub learning_objective_list_elt {
    my $self = shift;

    my $learning_objective_list_elt = XML::Twig::Elt->new('learning-objective-list');
    foreach my $learning_objective ($self->course()->child_objectives()) {
	my $objective_ref_elt = 
	  XML::Twig::Elt->new('objective-ref',
			      { 'objective-id' => $learning_objective->objective_id() },
			      make_pcdata($learning_objective->out_label())
			      );
	$objective_ref_elt->set_asis();
	$objective_ref_elt->paste('last_child', $learning_objective_list_elt);
    }
    return $learning_objective_list_elt;
}

sub content_list_elt {

    my $self = shift;

    my $content_list_elt = XML::Twig::Elt->new('content-list');

    foreach my $content_item ($self->course()->active_child_content()) {
	my $authors = ($content_item->type() eq 'External')
	    ? $content_item->child_authors()
	    : join(', ', map { $_->out_abbrev } $content_item->child_authors());

	my $content_elt = 
	  XML::Twig::Elt->new( 'content-ref',
			       { 'content-id'   => $content_item->content_id(),
				 'content-type' => $content_item->content_type(),
				 'authors'      => $authors },
			       make_pcdata($content_item->title()));
	$content_elt->set_asis();
	$content_elt->paste('last_child', $content_list_elt);
    }

    return $content_list_elt;
}

sub schedule_elt {
    my $self = shift;

    # add schedule stuff here by looping through the ClassMeeting objects
    my $schedule_elt = XML::Twig::Elt->new('schedule');
    foreach my $class_meeting ($self->course()->class_meetings()) {
	my $meeting_date = $class_meeting->out_starttime()->out_string_date_short();
	my $start_time   = $class_meeting->out_starttime()->out_string_time();
	my $end_time     = $class_meeting->out_endtime()->out_string_time();
	my $class_meeting_elt = 
	  XML::Twig::Elt->new('class-meeting',
			      {'class-meeting-id' => $class_meeting->class_meeting_id(),
			       'meeting-date'     => $meeting_date,
			       'start-time'       => $start_time,
			       'end-time'         => $end_time,
			       'location'         => (make_pcdata($class_meeting->location()) or ''),
			       'type'             => (make_pcdata($class_meeting->type()) or ''),
			       'title'            => (make_pcdata($class_meeting->title()) or ''),
			       });
	$class_meeting_elt->paste('last_child', $schedule_elt);
    }
    return $schedule_elt;
}

sub get_xml_elt {
    my $self = shift;

    my $atts;
    { 
	my $associate = $self->course()->field_value('associate_users');
	$associate = $associate eq 'User Group' ? 'Group' : 'Enrollment';
	$atts = { 'associate-users' => $associate,
		  'course-id' => $self->course()->primary_key(),
		  school => $self->course()->school(),
	      };
    }

    my $course_elt = XML::Twig::Elt->new('course', $atts);

    # Do the title
    my $title_elt = XML::Twig::Elt->new('title', {}, 
					make_pcdata($self->course()->title()));
    $title_elt->set_asis();
    $title_elt->paste('last_child', $course_elt);

    # Add the abbreviation
    if($self->course()->abbreviation()) {
	my $abbreviation_elt = 
	  XML::Twig::Elt->new('abbreviation', {}, 
			      make_pcdata($self->course()->abbreviation()));
	$abbreviation_elt->set_asis();
	$abbreviation_elt->paste('last_child', $course_elt);
    }

    # Add the color
    if($self->course()->color()) {
	my $color_elt = XML::Twig::Elt->new('color', {}, 
					    make_pcdata($self->course()->color()));
	$color_elt->set_asis();
	$color_elt->paste('last_child', $course_elt);
    }

    # Add the registrar code
    my $registrar_code_elt = 
      XML::Twig::Elt->new('registrar-code', {}, make_pcdata($self->course()->registrar_code()));
    $registrar_code_elt->set_asis();
    $registrar_code_elt->paste('last_child', $course_elt);

    # Faculty list
    $self->faculty_list_elt()->paste('last_child', $course_elt);
    
    # Sub courses
    if($self->course()->child_courses()) {
	$self->sub_course_list_elt()->paste('last_child', $course_elt);
    }

    # Teaching sites
    if ($self->course()->child_teaching_sites()) {
	$self->teaching_site_list_elt()->paste('last_child', $course_elt);
    }

    # Learning objectives
    if ($self->course()->child_objectives()) {
	$self->learning_objective_list_elt()->paste('last_child', $course_elt);
    }

    # Add content list
    $self->content_list_elt()->paste('last_child', $course_elt);

    # Add the schedule
    if ($self->course()->class_meetings()) {
	$self->schedule_elt()->paste('last_child', $course_elt);
    }

    # Add body elements for the body, if it's there
    my $body = $self->course()->body();
    return $course_elt unless $body;

    $body->attendance_policy() &&
	$body->attendance_policy()->copy()->paste('last_child', $course_elt);
	
    $body->grading_policy() &&
	$body->grading_policy()->copy()->paste('last_child', $course_elt);

    $body->reading_list() &&
	$body->reading_list()->copy()->paste('last_child', $course_elt);

    $body->course_description() &&
	$body->course_description()->copy()->paste('last_child', $course_elt);

    $body->tutoring_services() &&
	$body->tutoring_services()->copy()->paste('last_child', $course_elt);

    $body->course_structure() &&
	$body->course_structure()->copy()->paste('last_child', $course_elt);

    $body->student_evaluation() &&
	$body->student_evaluation()->copy()->paste('last_child', $course_elt);

    $body->equipment_list() &&
	$body->equipment_list()->copy()->paste('last_child', $course_elt);

    $body->course_other() &&
	$body->course_other()->copy()->paste('last_child', $course_elt);

    return $course_elt;
}

1;
