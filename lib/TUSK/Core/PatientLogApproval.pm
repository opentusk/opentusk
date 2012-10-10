package TUSK::Core::PatientLogApproval;

=head1 NAME

B<TUSK::Core::PatientLogApproval> - Class for manipulating entries in table patient_log_approval in tusk database

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
use Carp qw(cluck croak confess);

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
					'tablename' => 'patient_log_approval',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'patient_log_approval_id' => 'pk',
					'form_id' => '',
					'user_id' => '',
					'approved_by' => '',
					'approval_time' => '',
				    },
				    _attributes => {
					save_history => 0,
					tracking_fields => 0,	
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

=item B<getPatientLogApprovalID>

    $string = $obj->getPatientLogApprovalID();

    Get the value of the patient_log_approval_id field

=cut

sub getPatientLogApprovalID{
    my ($self) = @_;
    return $self->getFieldValue('patient_log_approval_id');
}

#######################################################

=item B<getFormID>

    $string = $obj->getFormID();

    Get the value of the form_id field

=cut

sub getFormID{
    my ($self) = @_;
    return $self->getFieldValue('form_id');
}

#######################################################

=item B<setFormID>

    $string = $obj->setFormID($value);

    Set the value of the form_id field

=cut

sub setFormID{
    my ($self, $value) = @_;
    $self->setFieldValue('form_id', $value);
}


#######################################################

=item B<getUserID>

    $string = $obj->getUserID();

    Get the value of the user_id field

=cut

sub getUserID{
    my ($self) = @_;
    return $self->getFieldValue('user_id');
}

#######################################################

=item B<setUserID>

    $string = $obj->setUserID($value);

    Set the value of the user_id field

=cut

sub setUserID{
    my ($self, $value) = @_;
    $self->setFieldValue('user_id', $value);
}

#######################################################

=item B<getApprovedBy>

    $string = $obj->getApprovedBy();

    Get the value of the approved_by field

=cut

sub getApprovedBy{
    my ($self) = @_;
    return $self->getFieldValue('approved_by');
}

#######################################################

=item B<setApprovedBy>

    $string = $obj->setApprovedBy($value);

    Set the value of the approved_by field

=cut

sub setApprovedBy{
    my ($self, $value) = @_;
    $self->setFieldValue('approved_by', $value);
}

#######################################################

=item B<getApprovalTime>

    $string = $obj->getApprovalTime();

    Get the value of the approval_time field

=cut

sub getApprovalTime{
    my ($self) = @_;
    return $self->getFieldValue('approval_time');
}

#######################################################

=item B<setApprovalTime>

    $string = $obj->setApprovalTime($value);

    Set the value of the approval_time field

=cut

sub setApprovalTime{
    my ($self, $value) = @_;
    $self->setFieldValue('approval_time', $value);
}

#######################################################


### Other Methods

#######################################################

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

