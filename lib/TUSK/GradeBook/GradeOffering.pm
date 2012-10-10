package TUSK::GradeBook::GradeOffering;

=head1 NAME

B<TUSK::GradeBook::GradeOffering> - Class for manipulating entries in table grade_offering in tusk database

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
					'tablename' => 'grade_offering',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'grade_offering_id' => 'pk',
					'course_id' => '',
					'time_period_id' => '',
					'root_grade_category_id' => '',
					'final_grade_event_id' => '',
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

=item B<getTimePeriodID>

my $string = $obj->getTimePeriodID();

Get the value of the time_period_id field

=cut

sub getTimePeriodID{
    my ($self) = @_;
    return $self->getFieldValue('time_period_id');
}

#######################################################

=item B<setTimePeriodID>

$obj->setTimePeriodID($value);

Set the value of the time_period_id field

=cut

sub setTimePeriodID{
    my ($self, $value) = @_;
    $self->setFieldValue('time_period_id', $value);
}


#######################################################

=item B<getRootGradeCategoryID>

my $string = $obj->getRootGradeCategoryID();

Get the value of the root_grade_category_id field

=cut

sub getRootGradeCategoryID{
    my ($self) = @_;
    return $self->getFieldValue('root_grade_category_id');
}

#######################################################

=item B<setRootGradeCategoryID>

$obj->setRootGradeCategoryID($value);

Set the value of the root_grade_category_id field

=cut

sub setRootGradeCategoryID{
    my ($self, $value) = @_;
    $self->setFieldValue('root_grade_category_id', $value);
}

#######################################################

=item B<getFinalGradeEventID>

    $string = $obj->getFinalGradeEventID();

    Get the value of the final_grade_event_id field

=cut

sub getFinalGradeEventID{
    my ($self) = @_;
    return $self->getFieldValue('final_grade_event_id');
}

#######################################################

=item B<setFinalGradeEventID>

    $string = $obj->setFinalGradeEventID($value);

    Set the value of the final_grade_event_id field

=cut

sub setFinalGradeEventID{
    my ($self, $value) = @_;
    $self->setFieldValue('final_grade_event_id', $value);
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

