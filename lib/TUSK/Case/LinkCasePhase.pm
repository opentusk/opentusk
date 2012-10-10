package TUSK::Case::LinkCasePhase;

=head1 NAME

B<TUSK::Case::LinkCasePhase> - Class for manipulating entries in table link_case_phase in tusk database

=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 INTERFACE


=head2 GET/SET METHODS

=over 4

=cut

use strict;
use Carp;

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
					'tablename' => 'link_case_phase',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'link_case_phase_id' => 'pk',
					'parent_case_id' => '',
					'child_phase_id' => '',
					'sort_order' => '',
					'phase_hidden' => '',
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

=item B<getParentCaseID>

    $string = $obj->getParentCaseID();

    Get the value of the parent_case_id field

=cut

sub getParentCaseID{
    my ($self) = @_;
    return $self->getFieldValue('parent_case_id');
}

#######################################################

=item B<setParentCaseID>

    $string = $obj->setParentCaseID($value);

    Set the value of the parent_case_id field

=cut

sub setParentCaseID{
    my ($self, $value) = @_;
    $self->setFieldValue('parent_case_id', $value);
}


#######################################################

=item B<getChildPhaseID>

    $string = $obj->getChildPhaseID();

    Get the value of the child_phase_id field

=cut

sub getChildPhaseID{
    my ($self) = @_;
    return $self->getFieldValue('child_phase_id');
}

#######################################################

=item B<setChildPhaseID>

    $string = $obj->setChildPhaseID($value);

    Set the value of the child_phase_id field

=cut

sub setChildPhaseID{
    my ($self, $value) = @_;
    $self->setFieldValue('child_phase_id', $value);
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


#######################################################

=item B<getPhaseHidden>

    $string = $obj->getPhaseHidden();

    Get the value of the phase_hidden field

=cut

sub getPhaseHidden{
    my ($self) = @_;
    return $self->getFieldValue('phase_hidden');
}

#######################################################

=item B<setPhaseHidden>

    $string = $obj->setPhaseHidden($value);

    Set the value of the phase_hidden field

=cut

sub setPhaseHidden{
    my ($self, $value) = @_;
    $self->setFieldValue('phase_hidden', $value);
}



=back

=cut

### Other Methods

#######################################################

=item B<lookupByRelation>

    $obj_arrayref = $obj->lookupByRelation($parent_id, $child_id);

    Returns an arrayref of objects that have those relations 

=cut

sub lookupByRelation {
	my $self = shift;
	my $parent_id = shift;
	my $child_id = shift;
	return TUSK::Case::LinkCasePhase->lookup(" parent_case_id = $parent_id  and child_phase_id = $child_id " );
}

#######################################################

=item B<getPhases>

    $obj_arrayref = $obj->getPhases($case_obj);

    Returns an arrayref of phases that have the parent case. 
 
=cut

sub getPhases{
	my $class = shift;
	my $case = shift or confess "Case object needs to be passed";
	my $cond = shift;
	return TUSK::Case::Phase->lookup($cond, ['sort_order ASC','phase_id ASC'], undef, undef, [ TUSK::Core::JoinObject->new("TUSK::Case::LinkCasePhase", {origkey=>'phase_id', joinkey=>'child_phase_id', cond => "parent_case_id = " . $case->getPrimaryKeyID()})]);

}

#######################################################

=item B<getPhaseObject>

    $phase_obj = $obj->getPhaseObject();

    Returns an arrayref of phases that are returned from the join object.

=cut

sub getPhaseObject {
	my $self = shift;
	return $self->getJoinObject('TUSK::Case::Phase');

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

