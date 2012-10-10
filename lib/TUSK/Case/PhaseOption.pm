package TUSK::Case::PhaseOption;

=head1 NAME

B<TUSK::Case::PhaseOption> - Class for manipulating entries in table phase_option in tusk database

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
					'tablename' => 'phase_option',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'phase_option_id' => 'pk',
					'phase_id' => '',
					'option_text' => '',
					'correct' => '',
					'feedback' => '',
					'soap_type'=>'', 
					'sort_order' => '',
				    },
				    _attributes => {
					save_history => 1,
					tracking_fields => 1,	
				    },
				    _levels => {
					reporting => 'warn',
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

=item B<getOptionText>

    $string = $obj->getOptionText();

    Get the value of the option_text field

=cut

sub getOptionText{
    my ($self) = @_;
    return $self->getFieldValue('option_text');
}

#######################################################

=item B<setOptionText>

    $string = $obj->setOptionText($value);

    Set the value of the option_text field

=cut

sub setOptionText{
    my ($self, $value) = @_;
    $self->setFieldValue('option_text', $value);
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

=item B<getSoapType>

    $string = $obj->getSoapType();

    Get the value of the soap_type field

=cut

sub getSoapType{
    my ($self) = @_;
    return $self->getFieldValue('soap_type');
}

#######################################################

=item B<setSoapType>

    $string = $obj->setSoapType($value);

    Set the value of the soap_type field

=cut

sub setSoapType{
    my ($self, $value) = @_;
    $self->setFieldValue('soap_type', $value);
}

#######################################################

=item B<getSortOrder>

    $string = $obj->getSortOrder();

    Get the value of the sort_order field

=cut

sub getSortOrder{
    my ($self) = @_;
    return $self->getFieldValue('sort_order');
}

#######################################################

=item B<setSortOrder>

    $string = $obj->setSortOrder($value);

    Set the value of the sort_order field

=cut

sub setSortOrder{
    my ($self, $value) = @_;
    $self->setFieldValue('sort_order', $value);
}



=back

=cut

### Other Methods

sub getPhaseOptionSelectionObject {
	my $self = shift;
	return $self->getJoinObject("TUSK::Case::PhaseOptionSelection");

}
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

