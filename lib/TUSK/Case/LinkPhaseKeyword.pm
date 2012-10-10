package TUSK::Case::LinkPhaseKeyword;

=head1 NAME

B<TUSK::Case::LinkPhaseKeyword> - Class for manipulating entries in table link_phase_keyword in tusk database

=head1 DESCRIPTION

=head2 GET/SET METHODS

=over 4

=cut

use strict;
use TUSK::Core::Keyword;

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
					'tablename' => 'link_phase_keyword',
					'usertoken' => 'ContentManager',
					},
				    _field_names => {
					'link_phase_keyword_id' => 'pk',
					'parent_phase_id' => '',
					'child_keyword_id' => '',
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

=item B<getParentPhaseID>

   $string = $obj->getParentPhaseID();

Get the value of the parent_phase_id field

=cut

sub getParentPhaseID{
    my ($self) = @_;
    return $self->getFieldValue('parent_phase_id');
}

#######################################################

=item B<setParentPhaseID>

    $string = $obj->setParentPhaseID($value);

Set the value of the parent_phase_id field

=cut

sub setParentPhaseID{
    my ($self, $value) = @_;
    $self->setFieldValue('parent_phase_id', $value);
}


#######################################################

=item B<getChildKeywordID>

   $string = $obj->getChildKeywordID();

Get the value of the child_keyword_id field

=cut

sub getChildKeywordID{
    my ($self) = @_;
    return $self->getFieldValue('child_keyword_id');
}

#######################################################

=item B<setChildKeywordID>

    $string = $obj->setChildKeywordID($value);

Set the value of the child_keyword_id field

=cut

sub setChildKeywordID{
    my ($self, $value) = @_;
    $self->setFieldValue('child_keyword_id', $value);
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

######################################################


=item B<lookupByRelation>

    $new_object = $obj->lookupByRelation($parent_id,$child_id);

Use the two ids passed to find a row that represents their relation.  Returns
undef if the relation is not found.

=cut

sub lookupByRelation{
    my ($self, $parent_id,$child_id) = @_;
    return $self->lookup("parent_phase_id = $parent_id ".
        " and child_keyword_id = '$child_id' ");
}

#######################################################

=item B<getKeyword>

    $keyword_object = $obj->getKeyword();

Use the link to get the child object of this relation.  Returns a TUSK::Core::Keyword

=cut

sub getKeyword {
        my $self = shift;
        $self->{-keyword} = TUSK::Core::Keyword->lookupKey($self->getChildKeywordID());
        return $self->{-keyword};
}



#######################################################


=back

=cut

### Other Methods

=head1 AUTHOR

TUSK <tuskdev@tufts.edu>

=head1 BUGS

None Reported.

=head1 SEE ALSO

B<TUSK::Core::SQLRow> - parent class

=head1 COPYRIGHT



=cut

1;

