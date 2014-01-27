package TUSK::Eval::Entry;

=head1 NAME

B<TUSK::Eval::Entry> - Class for manipulating entries in table eval_entry in tusk database

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
					'tablename' => 'eval_entry',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'eval_entry_id' => 'pk',
					'school_id' => '',
					'eval_id' => '',
					'evaluator_code' => '',
					'evaluatee_id' => '',
					'teaching_site_id' => '',
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

=item B<getEvaluatorCode>

my $string = $obj->getEvaluatorCode();

Get the value of the evaluator_code field

=cut

sub getEvaluatorCode{
    my ($self) = @_;
    return $self->getFieldValue('evaluator_code');
}

#######################################################

=item B<setEvaluatorCode>

$obj->setEvaluatorCode($value);

Set the value of the evaluator_code field

=cut

sub setEvaluatorCode{
    my ($self, $value) = @_;
    $self->setFieldValue('evaluator_code', $value);
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

=item B<getTeachingSiteID>

my $string = $obj->getTeachingSiteID();

Get the value of the teaching_site_id field

=cut

sub getTeachingSiteID{
    my ($self) = @_;
    return $self->getFieldValue('teaching_site_id');
}

#######################################################

=item B<setTeachingSiteID>

$obj->setTeachingSiteID($value);

Set the value of the teaching_site_id field

=cut

sub setTeachingSiteID{
    my ($self, $value) = @_;
    $self->setFieldValue('teaching_site_id', $value);
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

