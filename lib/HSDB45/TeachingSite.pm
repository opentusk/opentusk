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


package HSDB45::TeachingSite;

use strict;

BEGIN {
    use base qw(HSDB4::SQLRow);
    use HSDB4::SQLLink;

    use vars qw($VERSION);
    
    $VERSION = do { my @r = (q$Revision: 1.8 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
}

# Non-exported package globals go here
use vars ();

# File-private lexicals
my $tablename = "teaching_site";
my $primary_key_field = "teaching_site_id";
my @fields = qw(teaching_site_id
		site_name
		site_city_state
		modified
		body);
my %blob_fields = (body => 1);
my %numeric_fields = ();

my %cache = ();

# Creation methods

sub new {
    # Find out what class we are
    my $class = shift;
    $class = ref $class || $class;
    # Call the super-class's constructor and give it all the values
    my $self = $class->SUPER::new ( _tablename => $tablename,
				    _fields => \@fields,
				    _blob_fields => \%blob_fields,
				    _numeric_fields => \%numeric_fields,
				    _primary_key_field => $primary_key_field,
				    _cache => \%cache,
				    @_);
    # Finish initialization...
    return $self;
}

sub site_name {
    my $self = shift();
    return $self->field_value('site_name');
}

sub site_city_state {
    my $self = shift();
    return $self->field_value('site_city_state');
}

sub body {
    my $self = shift();
    return $self->field_value('body');
}

sub site_id {
    my $self = shift();
    return $self->field_value('teaching_site_id');
}

sub split_by_school { return 1; }

sub delete {
    my ($self, $un, $pw) = @_;
    my @courses = $self->parent_courses();
    foreach my $course (@courses){
	$self->delete_course_link($course, $un, $pw);
    }
    return $self->SUPER::delete($un, $pw);
}

sub delete_course_link {
    my ($self, $course, $un, $pw) = @_;

    # remove course_user_site
    my $user_sites =TUSK::Course::User::Site->lookup("teaching_site_id = " . $self->primary_key(), undef, undef, undef, [TUSK::Core::JoinObject->new('TUSK::Course::User', { joinkey => 'user_id', jointype => 'inner', joincond => "course_id = " . $course->primary_key() . " AND school_id = " . $course->getSchool()->getPrimaryKeyID() })]);
    foreach my $user_site (@$user_sites) {
	$user_site->delete({user => $un});
    }

    # change teaching_site_id to 0 for all matching link_course_student records
    my @students = $course->child_students();
    foreach my $user (@students){
	if ($user->aux_info('teaching_site_id') == $self->primary_key()){
	    my ($r, $msg) = $course->student_link()->update(-user => $un, -password => $pw,
					 -parent_id => $course->primary_key(),
					 -child_id => $user->primary_key(),
					 teaching_site_id => 0);
	}
    }

    # delete link_course_teaching_site record
    my ($r, $msg) =  $self->course_link()->delete (-user => $un, -password => $pw,
						   -parent_id => $course->primary_key(),
						   -child_id => $self->primary_key());
}

#
# >>>>> Linked objects <<<<<
#

sub course_link {
    my $self = shift;
    my $db = $self->school_db();
    return $HSDB4::SQLLinkDefinition::LinkDefs{"$db\.link_course_teaching_site"};
}

sub parent_courses {
    my $self = shift;
    unless ($self->{-parent_courses}) {
	$self->{-parent_courses} = 
	    $self->course_link()->get_parents( $self->primary_key(), @_ );
    }
    return $self->{-parent_courses}->parents();
}


#
# >>>>>  Input Methods <<<<<
#

sub in_xml {
    #
    # Suck in a bunch of XML and push it into the appropriate places
    #

    my $self = shift;
}

sub in_fdat_hash {
    #
    # Read in a hash of key => value pairs and make changes
    #

    my $self = shift;
    while (my ($key, $val) = splice(@_, 0, 2)) {
    }
}

#
# >>>>>  Output Methods  <<<<<
#

sub out_html_div {
    #
    # Formatted blob of HTML
    #

    my $self = shift;
}

sub out_xml {
    #
    # An XML representation of the row
    #

}

sub out_html_row {
    # 
    # A four-column HTML row
    #

    my $self = shift;
}

sub out_label {
    #
    # A label for the object: its title
    #

    my $self = shift;
    if ($self->site_city_state()) {
	return sprintf("%s (%s)", $self->site_name(), $self->site_city_state());
    }
    else {
	return $self->site_name();
    }
}

sub out_abbrev {
    #
    # An abbreviation for the object: the first twenty characters of its
    # title
    #

    my $self = shift;

}

1;
__END__

=head1 NAME

B<HSDB45::TeachingSite> - 

=head1 SYNOPSIS

    use HSDB45::TeachingSite;
    
=head1 DESCRIPTION

=head1 METHODS

=head2 Linked Objects



=head2 Input Methods

B<in_xml()> is not yet implemenented.

B<in_fdat_hash()> is not yet implemented.

=head2 Output Methods

B<out_html_div()> 

B<out_xml()> is not yet implemented.

B<out_html_row()> 

B<out_label()> 

B<out_abbrev()> 

=head1 AUTHOR

Tarik Alkasab <talkas01@tufts.edu>

=head1 SEE ALSO

L<HSDB4>, L<HSDB4::SQLRow>.

=cut

