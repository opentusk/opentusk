package TUSK::Eval::Association;

=head1 NAME

B<TUSK::Eval::Association> - Class for manipulating entries in table eval_association in tusk database

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
					'tablename' => 'eval_association',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'eval_association_id' => 'pk',
					'school_id' => '',
					'eval_id' => '',
					'evaluator_id' => '',
					'evaluatee_id' => '',
					'status_enum_id' => '',
					'status_date' => '',
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

=item B<getSchoolID>

my $string = $obj->getSchoolID();

Get the value of the school_id field

=cut

sub getSchoolID{
    my ($self) = @_;
    return $self->getFieldValue('school_id');
}

#######################################################

=item B<setSchoolID>

$obj->setSchoolID($value);

Set the value of the school_id field

=cut

sub setSchoolID{
    my ($self, $value) = @_;
    $self->setFieldValue('school_id', $value);
}


#######################################################

=item B<getEvalID>

my $string = $obj->getEvalID();

Get the value of the eval_id field

=cut

sub getEvalID{
    my ($self) = @_;
    return $self->getFieldValue('eval_id');
}

#######################################################

=item B<setEvalID>

$obj->setEvalID($value);

Set the value of the eval_id field

=cut

sub setEvalID{
    my ($self, $value) = @_;
    $self->setFieldValue('eval_id', $value);
}


#######################################################

=item B<getEvaluatorID>

my $string = $obj->getEvaluatorID();

Get the value of the evaluator_id field

=cut

sub getEvaluatorID{
    my ($self) = @_;
    return $self->getFieldValue('evaluator_id');
}

#######################################################

=item B<setEvaluatorID>

$obj->setEvaluatorID($value);

Set the value of the evaluator_id field

=cut

sub setEvaluatorID{
    my ($self, $value) = @_;
    $self->setFieldValue('evaluator_id', $value);
}


#######################################################

=item B<getEvaluateeID>

my $string = $obj->getEvaluateeID();

Get the value of the evaluatee_id field

=cut

sub getEvaluateeID{
    my ($self) = @_;
    return $self->getFieldValue('evaluatee_id');
}

#######################################################

=item B<setEvaluateeID>

$obj->setEvaluateeID($value);

Set the value of the evaluatee_id field

=cut

sub setEvaluateeID{
    my ($self, $value) = @_;
    $self->setFieldValue('evaluatee_id', $value);
}


#######################################################

=item B<getStatusEnumID>

my $string = $obj->getStatusEnumID();

Get the value of the status_enum_id field

=cut

sub getStatusEnumID {
    my ($self) = @_;
    return $self->getFieldValue('status_enum_id');
}

#######################################################

=item B<setStatusEnumID>

$obj->setStatus($value);

Set the value of the status_enum_id field

=cut

sub setStatusEnumID {
    my ($self, $value) = @_;
    $self->setFieldValue('status_enum_id', $value);
}


#######################################################

=item B<getStatusDate>

my $string = $obj->getStatusDate();

Get the value of the status_date field

=cut

sub getStatusDate{
    my ($self) = @_;
    return $self->getFieldValue('status_date');
}

#######################################################

=item B<setStatusDate>

$obj->setStatusDate($value);

Set the value of the status_date field

=cut

sub setStatusDate{
    my ($self, $value) = @_;
    $self->setFieldValue('status_date', $value);
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

