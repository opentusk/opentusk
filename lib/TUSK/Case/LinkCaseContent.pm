package TUSK::Case::LinkCaseContent;

=head1 NAME

B<TUSK::Case::LinkCaseContent> - Class for manipulating entries in table link_case_content in tusk database

=head1 DESCRIPTION

=head2 GET/SET METHODS

=over 4

=cut

use strict;
use HSDB4::SQLRow::Content;

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
					'tablename' => 'link_case_content',
					'usertoken' => 'ContentManager',
					},
				    _field_names => {
					'link_case_content_id' => 'pk',
					'parent_case_id' => '',
					'child_content_id' => '',
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

=item B<getChildContentID>

   $string = $obj->getChildContentID();

Get the value of the child_content_id field

=cut

sub getChildContentID{
    my ($self) = @_;
    return $self->getFieldValue('child_content_id');
}

#######################################################

=item B<setChildContentID>

    $string = $obj->setChildContentID($value);

Set the value of the child_content_id field

=cut

sub setChildContentID{
    my ($self, $value) = @_;
    $self->setFieldValue('child_content_id', $value);
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

    $new_object = $obj->lookupByRelation($parent_id,$child_id);

Use the two ids passed to find a row that represents their relation.  Returns
undef if the relation is not found.

=cut

sub lookupByRelation{
    my ($self, $parent_id,$child_id,$link_type) = @_;
    return $self->lookup("parent_case_id = $parent_id ".
	" and child_content_id = $child_id and link_type = '$link_type'");
}

#######################################################

=item B<getContent>

    $objective_object = $obj->getContent();

Use the link to get the child object of this relation.  Returns a HSDB4::SQLRow::Content

=cut

sub getContent {
        my $self = shift;
	return HSDB4::SQLRow::Content->new->lookup_key($self->getChildContentID());
}


#######################################################

=head1 AUTHOR

TUSK <tuskdev@tufts.edu>

=head1 BUGS

None Reported.

=head1 SEE ALSO

B<TUSK::Core::SQLRow> - parent class

=head1 COPYRIGHT



=cut

1;

