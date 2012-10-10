package TUSK::Core::LinkCourseCourse;

=head1 NAME

B<TUSK::Core::LinkCourseCourse> - Class for manipulating entries in table link_course_course in tusk database

=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 INTERFACE


=head2 GET/SET METHODS

=over 4

=cut

use strict;

BEGIN {
    require Exporter;
    require TUSK::Core::SQLRow;

    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
    
    @ISA = qw(TUSK::Core::SQLRow Exporter);
    @EXPORT = qw( );
    @EXPORT_OK = qw( );
}

use vars @EXPORT_OK;

# Non-exported package globals go here
use vars ();

sub new {
    # Find out what class we are
    my $class = shift;
    $class = ref $class || $class;
    # Call the super-class's constructor and give it all the values
    my $self = $class->SUPER::new ( 
				    _datainfo => {
					'database' => 'tusk',
					'tablename' => 'link_course_course',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'link_course_course_id' => 'pk',
					'parent_course_id' => '',
					'child_course_id' => '',
				    },
				    _attributes => {
					save_history => 1,
					tracking_fields => 1,	
				    },
				    _levels => {
					reporting => 'cluck',
					error => 0,
				    },
				    @_
				  );
    # Finish initialization...
    return $self;
}

### Get/Set methods

#######################################################

=item B<getParentCourseID>

    $string = $obj->getParentCourseID();

    Get the value of the parent_course_id field

=cut

sub getParentCourseID{
    my ($self) = @_;
    return $self->getFieldValue('parent_course_id');
}

#######################################################

=item B<setParentCourseID>

    $string = $obj->setParentCourseID($value);

    Set the value of the parent_course_id field

=cut

sub setParentCourseID{
    my ($self, $value) = @_;
    $self->setFieldValue('parent_course_id', $value);
}

#######################################################

=item B<getChildCourseID>

    $string = $obj->getChildCourseID();

    Get the value of the child_course_id field

=cut

sub getChildCourseID{
    my ($self) = @_;
    return $self->getFieldValue('child_course_id');
}

#######################################################

=item B<setChildCourseID>

    $string = $obj->setChildCourseID($value);

    Set the value of the child_course_id field

=cut

sub setChildCourseID{
    my ($self, $value) = @_;
    $self->setFieldValue('child_course_id', $value);
}

=back

=cut

### Other Methods

=head1 BUGS

None Reported.

=head1 SEE ALSO

B<TUSK::Core::SQLRow> - parent class

=head1 AUTHOR

TUSK Development Team <tuskdev@tufts.edu>

=head1 COPYRIGHT

Copyright (c) Tufts University Sciences Knowledgebase, 2004.

=cut

1;

