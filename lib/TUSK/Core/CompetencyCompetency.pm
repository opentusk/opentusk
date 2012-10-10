package TUSK::Core::CompetencyCompetency;

=head1 NAME

B<TUSK::Core::CompetencyCompetency> - Class for manipulating entries in table competency_competency in tusk database

=head1 DESCRIPTION

=head2 GET/SET METHODS

=over 4

=cut

use strict;
use TUSK::Core::Competency;

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
					'tablename' => 'competency_competency',
					'usertoken' => 'ContentManager',
					},
				    _field_names => {
					'competency_competency_id' => 'pk',
					'parent_competency_id' => '',
					'child_competency_id' => '',
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
				    _default_order_bys => ['sort_order'],
				    @_
				  );
    # Finish initialization...
    return $self;
}

### Get/Set methods

#######################################################

=item B<getParentCompetencyID>

   $string = $obj->getParentCompetencyID();

Get the value of the parent_competency_id field

=cut

sub getParentCompetencyID{
    my ($self) = @_;
    return $self->getFieldValue('parent_competency_id');
}

#######################################################

=item B<setParentCompetencyID>

    $string = $obj->setParentCompetencyID($value);

Set the value of the parent_competency_id field

=cut

sub setParentCompetencyID{
    my ($self, $value) = @_;
    $self->setFieldValue('parent_competency_id', $value);
}

#######################################################

=item B<getChildCompetencyID>

   $string = $obj->getChildCompetencyID();

Get the value of the child_competency_id field

=cut

sub getChildCompetencyID{
    my ($self) = @_;
    return $self->getFieldValue('child_competency_id');
}

#######################################################

=item B<setChildCompetencyID>

    $string = $obj->setChildCompetencyID($value);

Set the value of the child_competency_id field

=cut

sub setChildCompetencyID{
    my ($self, $value) = @_;
    $self->setFieldValue('child_competency_id', $value);
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

#######################################################

=item B<lookupByRelation>

    $new_object = $obj->lookupByRelation($parent_competency_id,$child_competency_id);

Use the two ids passed to find a row that represents their relation.  Returns
undef if the relation is not found.

=cut

sub lookupByRelation{
    my ($self, $parent_competency_id, $child_competency_id) = @_;
    return $self->lookup("parent_competency_id = $parent_competency_id and child_competency_id = $child_competency_id");
}

#######################################################

=item B<getParentCompetency>

    $competency_object = $obj->getParentCompetency();

Use the link to get the parent object of this relation.  Returns a TUSK::Core::Competency

=cut

sub getParentCompetency {
	my $self = shift;
	return TUSK::Core::Competency->new->lookupKey($self->getParentCompetencyID());
}

#######################################################

=item B<getChildCompetency>

    $competency_object = $obj->getChildCompetency();

Use the link to get the child object of this relation.  Returns a TUSK::Core::Competency

=cut

sub getChildCompetency {
	my $self = shift;
	return TUSK::Core::Competency->new->lookupKey($self->getChildCompetencyID());
}

#######################################################

=item B<getParentCompetencies>

    $new_object = $obj->getParentCompetencies($child_competency_id);

=cut

sub getParentCompetencies{
    my ($self, $child_competency_id) = @_;
    return $self->lookup("child_competency_id = $child_competency_id");
}

#######################################################

=item B<getChildCompetencies>

    $new_object = $obj->getChildCompetencies($parent_competency_id);

=cut

sub getChildCompetencies{
    my ($self, $parent_competency_id) = @_;
    return $self->lookup("parent_competency_id = $parent_competency_id");
}

#######################################################

=item B<getNextSortOrder>

    $new_object = $obj->getNextSortOrder($parent_competency_id);

=cut

sub getNextSortOrder{
    my ($self, $parent_competency_id) = @_;
	my $max_sort_order = -1;
    foreach( @{$self->lookup("parent_competency_id = $parent_competency_id")} ) {
		if ($_->getSortOrder > $max_sort_order) { $max_sort_order = $_->getSortOrder; }
	}
	return $max_sort_order+1;
}

=head1 AUTHOR

TUSK <tuskdev@tufts.edu>

=head1 BUGS

None Reported.

=head1 SEE ALSO

B<TUSK::Core::SQLRow> - parent class

=head1 COPYRIGHT



=cut

1;

