package TUSK::GradeBook::LinkCourseCustomScale;

=head1 NAME

B<TUSK::GradeBook::LinkCourseCustomScale> - Class for manipulating entries in table link_course_custom_scale in tusk database

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
					'tablename' => 'link_course_custom_scale',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'link_course_custom_scale_id' => 'pk',
					'course_id' => '',
					'lower_bound' => '',
					'grade' => '',
				    },
				    _attributes => {
					save_history => 1,
					tracking_fields => 1,	
				    },
				    _levels => {
					reporting => '-c',
					error => 0,
				    },
				    @_
				  );
    # Finish initialization...
    return $self;
}

### Get/Set methods

#######################################################

=item B<getCourseID>

my $string = $obj->getCourseID();

Get the value of the course_id field

=cut

sub getCourseID{
    my ($self) = @_;
    return $self->getFieldValue('course_id');
}

#######################################################

=item B<setCourseID>

$obj->setCourseID($value);

Set the value of the course_id field

=cut

sub setCourseID{
    my ($self, $value) = @_;
    $self->setFieldValue('course_id', $value);
}


#######################################################

=item B<getLowerBound>

my $string = $obj->getLowerBound();

Get the value of the lower_bound field

=cut

sub getLowerBound{
    my ($self) = @_;
    return $self->getFieldValue('lower_bound');
}

#######################################################

=item B<setLowerBound>

$obj->setLowerBound($value);

Set the value of the lower_bound field

=cut

sub setLowerBound{
    my ($self, $value) = @_;
    $self->setFieldValue('lower_bound', $value);
}


#######################################################

=item B<getGrade>

my $string = $obj->getGrade();

Get the value of the grade field

=cut

sub getGrade{
    my ($self) = @_;
    return $self->getFieldValue('grade');
}

#######################################################

=item B<setGrade>

$obj->setGrade($value);

Set the value of the grade field

=cut

sub setGrade{
    my ($self, $value) = @_;
    $self->setFieldValue('grade', $value);
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

