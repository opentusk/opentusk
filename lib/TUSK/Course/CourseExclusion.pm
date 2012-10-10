package TUSK::Course::CourseExclusion;

=head1 NAME

B<TUSK::Course::CourseExclusion> - Class for manipulating entries in table class_meeting_keyword in tusk database

=head1 DESCRIPTION

=head2 GET/SET METHODS

=over 4

=cut

use strict;
use TUSK::Course;

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
					'tablename' => 'course_exclusion',
					'usertoken' => 'ContentManager',
					},
				    _field_names => {
					'course_exclusion_id' => 'pk',
					'course_id' => '',
					'course_exclusion_type_id' => '',
				    },
				    _attributes => {
					save_history => 1,
					tracking_fields => 1,	
				    },
				    _levels => {
					reporting => 'warn',
					error => 0,
				    },
				    _default_order_bys => ['course_exclusion_id'],
				    @_
				  );
    # Finish initialization...
    return $self;
}

### Get/Set methods

#######################################################

=item B<getCourseID>

   $string = $obj->getCourseID();

Get the value of the school_id field

=cut

sub getCourseID{
    my ($self) = @_;
    return $self->getFieldValue('school_id');
}

#######################################################

=item B<setCourseID>

    $obj->setCourseID($value);

Set the value of the school_id field

=cut

sub setCourseID{
    my ($self, $value) = @_;
    $self->setFieldValue('course_id', $value);
}

#######################################################

=item B<getCourseExclusionTypeID>

   $string = $obj->getCourseExclusionTypeID();

Get the value of the course_exclusion_type_id field

=cut

sub getCourseExclusionTypeID{
    my ($self) = @_;
    return $self->getFieldValue('course_exclusion_type_id');
}

#######################################################

=item B<setCourseExclusionTypeID>

    $string = $obj->setCourseExclusionTypeID($value);

Set the value of the course_exclusion_type_id field

=cut

sub setCourseExclusionTypeID{
    my ($self, $value) = @_;
    $self->setFieldValue('course_exclusion_type_id', $value);
}



=back

=cut

=head1 AUTHOR

TUSK <tuskdev@tufts.edu>

=head1 BUGS

None Reported.

=head1 SEE ALSO

B<TUSK::Core::SQLRow> - parent class

=head1 COPYRIGHT



=cut

1;

