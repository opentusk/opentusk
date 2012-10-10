package TUSK::FormBuilder::Attribute;

=head1 NAME

B<TUSK::FormBuilder::Attribute> - Class for manipulating entries in table form_builder_attribute in tusk database

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
use TUSK::FormBuilder::AttributeItem;
use TUSK::FormBuilder::AttributeType;

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
					'tablename' => 'form_builder_attribute',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'attribute_id' => 'pk',
					'attribute_name' => '',
					'attribute_type_id' => '',
					'field_id' => '',
					'sort_order' => '',
				    },
				    _attributes => {
					save_history => 1,
					tracking_fields => 1,	
				    },
				    _levels => {
					reporting => 'cluck',
					error => 0,
				    },
				    _default_order_bys => [ 'sort_order', 'form_builder_attribute_item__sort_order' ],
				    _default_join_objects => [ TUSK::Core::JoinObject->new("TUSK::FormBuilder::AttributeType"), TUSK::Core::JoinObject->new("TUSK::FormBuilder::AttributeItem", { joinkey => 'attribute_id'}) ],
				    @_
				  );
    # Finish initialization...
    return $self;
}

### Get/Set methods

#######################################################

=item B<getAttributeName>

    $string = $obj->getAttributeName();

    Get the value of the attribute_name field

=cut

sub getAttributeName{
    my ($self) = @_;
    return $self->getFieldValue('attribute_name');
}

#######################################################

=item B<setAttributeName>

    $obj->setAttributeName($value);

    Set the value of the attribute_name field

=cut

sub setAttributeName{
    my ($self, $value) = @_;
    $self->setFieldValue('attribute_name', $value);
}

#######################################################

=item B<getAttributeTypeID>

    $string = $obj->getAttributeTypeID();

    Get the value of the attribute_type_id field

=cut

sub getAttributeTypeID{
    my ($self) = @_;
    return $self->getFieldValue('attribute_type_id');
}

#######################################################

=item B<setAttributeTypeID>

    $obj->setAttributeTypeID($value);

    Set the value of the attribute_type_id field

=cut

sub setAttributeTypeID{
    my ($self, $value) = @_;
    $self->setFieldValue('attribute_type_id', $value);
}


#######################################################

=item B<getFieldID>

    $string = $obj->getFieldID();

    Get the value of the field_id field

=cut

sub getFieldID{
    my ($self) = @_;
    return $self->getFieldValue('field_id');
}

#######################################################

=item B<setFieldID>

    $obj->setFieldID($value);

    Set the value of the field_id field

=cut

sub setFieldID{
    my ($self, $value) = @_;
    $self->setFieldValue('field_id', $value);
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

    $obj->setSortOrder($value);

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

=item B<getAttributeTypeObject>

    $attribute_type_obj = $obj->getAttributeTypeObject();

    Return the associated AttributeType object

=cut

sub getAttributeTypeObject{
    my ($self) = @_;
    return $self->getJoinObject("TUSK::FormBuilder::AttributeType");
}

#######################################################

=item B<getAttributeTypeToken>

    $string = $obj->getAttributeTypeToken();

    Return the token field of the assoicated AttributeType object

=cut

sub getAttributeTypeToken{
    my ($self) = @_;
    my $attribute_type = $self->getAttributeTypeObject();
    return $attribute_type->getToken();
}

#######################################################

=item B<getItems>

    $array_ref = $obj->getItems();

    Return array ref of attribute items associated with this obj

=cut

sub getItems{
    my ($self) = @_;
    return $self->getJoinObjects("TUSK::FormBuilder::AttributeItem");
}

#######################################################

=item B<isValidItem>

    $int = $obj->isValidItem($item_id);

    Check to see if an item_id is related to this attribute

=cut

sub isValidItem{
    my ($self, $item_id) = @_;
    my $items = $self->getItems();
    foreach my $item (@$items){
	if ($item->getPrimaryKeyID() == $item_id){
	    return 1;
	}
    }

    return 0;
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

