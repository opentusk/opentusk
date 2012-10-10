package TUSK::GradeBook::LinkCourseGradeEventType;

=head1 NAME

B<TUSK::GradeBook::LinkCourseGradeEventType> - Class for manipulating entries in table link_course_grade_event_type in tusk database

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
					'tablename' => 'link_course_grade_event_type',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'link_course_grade_event_type_id' => 'pk',
					'drop_lowest' => '',
					'drop_highest' => '',
					'total_weight' => '',
					'grade_event_type_id' => '',
					'course_id' => '',
					'time_period_id' => '',
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

=item B<getDropLowest>

my $string = $obj->getDropLowest();

Get the value of the drop_lowest field

=cut

sub getDropLowest{
    my ($self) = @_;
    return $self->getFieldValue('drop_lowest');
}

#######################################################

=item B<setDropLowest>

$obj->setDropLowest($value);

Set the value of the drop_lowest field

=cut

sub setDropLowest{
    my ($self, $value) = @_;
    $self->setFieldValue('drop_lowest', $value);
}


#######################################################

=item B<getDropHighest>

my $string = $obj->getDropHighest();

Get the value of the drop_highest field

=cut

sub getDropHighest{
    my ($self) = @_;
    return $self->getFieldValue('drop_highest');
}

#######################################################

=item B<setDropHighest>

$obj->setDropHighest($value);

Set the value of the drop_highest field

=cut

sub setDropHighest{
    my ($self, $value) = @_;
    $self->setFieldValue('drop_highest', $value);
}


#######################################################

=item B<getTotalWeight>

my $string = $obj->getTotalWeight();

Get the value of the total_weight field

=cut

sub getTotalWeight{
    my ($self) = @_;
    return $self->getFieldValue('total_weight');
}

#######################################################

=item B<setTotalWeight>

$obj->setTotalWeight($value);

Set the value of the total_weight field

=cut

sub setTotalWeight{
    my ($self, $value) = @_;
    $self->setFieldValue('total_weight', $value);
}


#######################################################

=item B<getGradeEventTypeID>

my $string = $obj->getGradeEventTypeID();

Get the value of the grade_event_type_id field

=cut

sub getGradeEventTypeID{
    my ($self) = @_;
    return $self->getFieldValue('grade_event_type_id');
}

#######################################################

=item B<setGradeEventTypeID>

$obj->setGradeEventTypeID($value);

Set the value of the grade_event_type_id field

=cut

sub setGradeEventTypeID{
    my ($self, $value) = @_;
    $self->setFieldValue('grade_event_type_id', $value);
}


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

