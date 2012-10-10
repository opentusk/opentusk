package TUSK::FormBuilder::SubjectAssessor;

=head1 NAME

B<TUSK::FormBuilder::SubjectAssessor> - Class for manipulating entries in table form_builder_subject_assessor in tusk database

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

our $STATUS = {
	unassigned => 0,
	assigned   => 1,
	selected_by_assessor => 2,
	deselected_by_assessor => 3,
};

sub new {
    # Find out what class we are
    my $class = shift;
    $class = ref $class || $class;
    # Call the super-class's constructor and give it all the values
    my $self = $class->SUPER::new ( 
				    _datainfo => {
					'database' => 'tusk',
					'tablename' => 'form_builder_subject_assessor',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'subject_assessor_id' => 'pk',
					'form_id' => '',
					'time_period_id' => '',
					'subject_id' => '',
					'assessor_id' => '',
					'status' => '',
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

=item B<getFormID>

my $string = $obj->getFormID();

Get the value of the form_id field

=cut

sub getFormID{
    my ($self) = @_;
    return $self->getFieldValue('form_id');
}

#######################################################

=item B<setFormID>

$obj->setFormID($value);

Set the value of the form_id field

=cut

sub setFormID{
    my ($self, $value) = @_;
    $self->setFieldValue('form_id', $value);
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

=item B<getSubjectID>

my $string = $obj->getSubjectID();

Get the value of the subject_id field

=cut

sub getSubjectID{
    my ($self) = @_;
    return $self->getFieldValue('subject_id');
}

#######################################################

=item B<setSubjectID>

$obj->setSubjectID($value);

Set the value of the subject_id field

=cut

sub setSubjectID{
    my ($self, $value) = @_;
    $self->setFieldValue('subject_id', $value);
}


#######################################################

=item B<getAssessorID>

my $string = $obj->getAssessorID();

Get the value of the assessor_id field

=cut

sub getAssessorID{
    my ($self) = @_;
    return $self->getFieldValue('assessor_id');
}

#######################################################

=item B<setAssessorID>

$obj->setAssessorID($value);

Set the value of the assessor_id field

=cut

sub setAssessorID{
    my ($self, $value) = @_;
    $self->setFieldValue('assessor_id', $value);
}


#######################################################

=item B<getStatus>

my $string = $obj->getStatus();

Get the value of the status field

=cut

sub getStatus{
    my ($self) = @_;
    return $self->getFieldValue('status');
}

#######################################################

=item B<setStatus>

$obj->setStatus($value);

Set the value of the status field

=cut

sub setStatus{
    my ($self, $value) = @_;
    $self->setFieldValue('status', $value);
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

