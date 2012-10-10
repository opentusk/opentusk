package HSDB45::Course::Body;

use strict;
use XML::Twig;
use HSDB45::Course;
use Carp qw(confess);
use TUSK::Constants;

BEGIN {
    use vars qw($VERSION);
    $VERSION = do { my @r = (q$Revision: 1.9 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
}

sub version { return $VERSION }

# dependencies for things that relate to caching
my @mod_deps  = ('HSDB45::Course');

my @file_deps = ();

sub get_mod_deps {
    return @mod_deps;
}

sub get_file_deps {
    return @file_deps;
}


# Description: Constructor for a HSDB45::Course::Body
# Input: The Eval::Course object which contains it
# Output: The new HSDB45::Course::Body object
sub new {
    my $input = shift;
    my $class = ref $input || $input;
    my $twig = XML::Twig->new();
    my $self = {-twig => $twig};
    bless($self, $class);
    return $self->init( @_ );
}

# Description: Private initializer for the question
# Input: The Eval::Course object
# Output: The properly (re-)blessed Body object
sub init {
    my $self = shift;
    my $course = shift;
    $self->{-course} = $course;
    my $bodytext = $course->field_value('body');
    if (not $bodytext) {
	my $id = $course->primary_key();
	$bodytext = qq[<?xml version="1.0"?>\n];
	$bodytext .= qq[<!DOCTYPE dbcourse SYSTEM "http://]. $TUSK::Constants::Domain .qq[/DTD/course.dtd">\n];
	$bodytext .= qq[<dbcourse course-id="$id">\n];
	for (qw(attendance-policy grading-policy course-description tutoring-services 
		course-structure student-evaluation equipment-list course-other)) {
	    $bodytext .= qq[  <$_></$_>\n];
	}
	$bodytext .= qq[</dbcourse>\n];
    }
    eval { $self->twig->parse( $bodytext ); };
    if ($@) {
	confess "Could not parse course body (course_id=", $course->primary_key(), ") $@";
    }
    else {
	$self->{-elt} = $self->twig->first_elt();
    }
    return $self;
}

# Description: generate a dtd-compliant twig with no actual data
# Input:
# Output:
sub create{
        my $self = shift;

        my $course = $self->course;
        my $dbc = XML::Twig::Elt->new('dbcourse',
                {'course-id' => $course->primary_key });

        foreach (map { XML::Twig::Elt->new($_) }
                qw/attendance-policy grading-policy course-description
                 tutoring-services student-evaluation equipment-list
                 course-other course-structure/)
        {
                $_->paste('last_child', $dbc);
        }
        $self->{-elt} = $dbc;

        return $self;
}

# Description: Accessor for the Course object to which this Body belongs
# Input:
# Output: The Course object
sub course {
    my $self = shift;
    return $self->{-course};
}

# Description: Accessor for the XML::Twig::Elt which represents the Body
# Input:
# Output: The XML::Twig::Elt object
sub elt {
    my $self = shift;
    return $self->{-elt};
}

sub get_element{
    my $self = shift();
    my $element = shift();
    return $self->elt()->first_child($element);
}

sub attendance_policy {
    my $self = shift();
    return $self->elt()->first_child("attendance-policy");
}

sub grading_policy {
    my $self = shift();
    return $self->elt()->first_child("grading-policy");
}

sub reading_list {
    my $self = shift();
    return $self->elt()->first_child("reading-list");
}

sub course_description {
    my $self = shift();
    return $self->elt()->first_child("course-description");
}

sub tutoring_services {
    my $self = shift();
    return $self->elt()->first_child("tutoring-services");
}

sub course_structure {
    my $self = shift();
    return $self->elt()->first_child("course-structure");
}

sub student_evaluation {
    my $self = shift();
    return $self->elt()->first_child("student-evaluation");
}

sub equipment_list {
    my $self = shift();
    return $self->elt()->first_child("equipment-list");
}

sub course_other {
    my $self = shift();
    return $self->elt()->first_child("course-other");
}

# Description: Gets the course_id, if it's set for the body
# Input:
# Output: The ID, or undef if there is none
sub course_id {
    my $self = shift();
    return $self->elt()->att('course-id');
}

# Description: Gets the twig for this object
# Input:
# Output: the twig
sub twig {
    my $self = shift();
    return $self->{-twig};
}

1;
__END__

