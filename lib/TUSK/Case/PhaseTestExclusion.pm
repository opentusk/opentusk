package TUSK::Case::PhaseTestExclusion;

=head1 NAME

B<TUSK::Case::PhaseTestExclusion> - Class for manipulating entries in table case_phase_test_exclusion in tusk database

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
					'tablename' => 'case_phase_test_exclusion',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'phase_test_exclusion_id' => 'pk',
					'phase_id' => '',
					'test_id' => '',
					'alternate_value' => '',
					'alternate_content_id' => '',
					'feedback' => '',
					'correct' => '',
					'priority' => '',
					'include'=> '',
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

=item B<getPhaseID>

    $string = $obj->getPhaseID();

    Get the value of the phase_id field

=cut

sub getPhaseID{
    my ($self) = @_;
    return $self->getFieldValue('phase_id');
}

#######################################################

=item B<setPhaseID>

    $string = $obj->setPhaseID($value);

    Set the value of the phase_id field

=cut

sub setPhaseID{
    my ($self, $value) = @_;
    $self->setFieldValue('phase_id', $value);
}


#######################################################

=item B<getTestID>

    $string = $obj->getTestID();

    Get the value of the test_id field

=cut

sub getTestID{
    my ($self) = @_;
    return $self->getFieldValue('test_id');
}

#######################################################

=item B<setTestID>

    $string = $obj->setTestID($value);

    Set the value of the test_id field

=cut

sub setTestID{
    my ($self, $value) = @_;
    $self->setFieldValue('test_id', $value);
}


#######################################################

=item B<getAlternateValue>

    $string = $obj->getAlternateValue();

    Get the value of the alternate_value field

=cut

sub getAlternateValue{
    my ($self) = @_;
    return $self->getFieldValue('alternate_value');
}

#######################################################

=item B<setAlternateValue>

    $string = $obj->setAlternateValue($value);

    Set the value of the alternate_value field

=cut

sub setAlternateValue{
    my ($self, $value) = @_;
    $self->setFieldValue('alternate_value', $value);
}


#######################################################

=item B<getAlternateContentID>

    $string = $obj->getAlternateContentID();

    Get the value of the alternate_content_id field

=cut

sub getAlternateContentID{
    my ($self) = @_;
    return $self->getFieldValue('alternate_content_id');
}

#######################################################

=item B<setAlternateContentID>

    $string = $obj->setAlternateContentID($value);

    Set the value of the alternate_content_id field

=cut

sub setAlternateContentID{
    my ($self, $value) = @_;
    $self->setFieldValue('alternate_content_id', $value);
}


#######################################################

=item B<getFeedback>

    $string = $obj->getFeedback();

    Get the value of the feedback field

=cut

sub getFeedback{
    my ($self) = @_;
    return $self->getFieldValue('feedback');
}

#######################################################

=item B<setFeedback>

    $string = $obj->setFeedback($value);

    Set the value of the feedback field

=cut

sub setFeedback{
    my ($self, $value) = @_;
    $self->setFieldValue('feedback', $value);
}


#######################################################

=item B<getCorrect>

    $string = $obj->getCorrect();

    Get the value of the correct field

=cut

sub getCorrect{
    my ($self) = @_;
    return $self->getFieldValue('correct');
}

#######################################################

=item B<setCorrect>

    $string = $obj->setCorrect($value);

    Set the value of the correct field

=cut

sub setCorrect{
    my ($self, $value) = @_;
    $self->setFieldValue('correct', $value);
}

#######################################################

=item B<getPriority>

    $string = $obj->getPriority();

    Get the value of the priority field

=cut

sub getPriority{
    my ($self) = @_;
    return $self->getFieldValue('priority');
}

#######################################################

=item B<setPriority>

    $string = $obj->setPriority($value);

    Set the value of the priority field

=cut

sub setPriority{
    my ($self, $value) = @_;
    $self->setFieldValue('priority', $value);
}

#######################################################

=item B<getInclude>

    $string = $obj->getInclude();

    Get the value of the include field

=cut

sub getInclude{
    my ($self) = @_;
    return $self->getFieldValue('include');
}

#######################################################

=item B<setInclude>

    $string = $obj->setInclude($value);

    Set the value of the include field

=cut

sub setInclude{
    my ($self, $value) = @_;
    $self->setFieldValue('include', $value);
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

