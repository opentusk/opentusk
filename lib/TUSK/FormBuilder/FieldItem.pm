# Copyright 2012 Tufts University 
#
# Licensed under the Educational Community License, Version 1.0 (the "License"); 
# you may not use this file except in compliance with the License. 
# You may obtain a copy of the License at 
#
# http://www.opensource.org/licenses/ecl1.php 
#
# Unless required by applicable law or agreed to in writing, software 
# distributed under the License is distributed on an "AS IS" BASIS, 
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
# See the License for the specific language governing permissions and 
# limitations under the License.


package TUSK::FormBuilder::FieldItem;

=head1 NAME

B<TUSK::FormBuilder::FieldItem> - Class for manipulating entries in table form_builder_field_item in tusk database

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
					'tablename' => 'form_builder_field_item',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'item_id' => 'pk',
					'item_name' => '',
					'item_type_id' => '',
					'abbreviation' => '',
					'field_id' => '',
					'allow_user_defined_value' => '',
					'sort_order' => '',
					'content_id' => '',
				    },
				    _attributes => {
					save_history => 1,
					tracking_fields => 1,	
				    },
				    _levels => {
					reporting => 'cluck',
					error => 0,
				    },
				    _default_order_bys => ['sort_order'],
				    _default_join_objects => [TUSK::Core::JoinObject->new("TUSK::FormBuilder::ItemType")],
				    @_
				  );
    # Finish initialization...
    return $self;
}

### Get/Set methods

#######################################################

=item B<getItemName>

    $string = $obj->getItemName();

    Get the value of the item_name field

=cut

sub getItemName{
    my ($self) = @_;
    return $self->getFieldValue('item_name');
}

#######################################################

=item B<setItemName>

    $obj->setItemName($value);

    Set the value of the item_name field

=cut

sub setItemName{
    my ($self, $value) = @_;
    $self->setFieldValue('item_name', $value);
}

#######################################################

=item B<getItemTypeID>

    $string = $obj->getItemTypeID();

    Get the value of the item_type_id field

=cut

sub getItemTypeID{
    my ($self) = @_;
    return $self->getFieldValue('item_type_id');
}

#######################################################

=item B<setItemTypeID>

    $obj->setItemTypeID($value);

    Set the value of the item_type_id field

=cut

sub setItemTypeID{
    my ($self, $value) = @_;
    $self->setFieldValue('item_type_id', $value);
}

#######################################################

=item B<getAbbreviation>

    $string = $obj->getAbbreviation();

    Get the value of the abbreviation field

=cut

sub getAbbreviation{
    my ($self) = @_;
    return $self->getFieldValue('abbreviation');
}

#######################################################

=item B<setAbbreviation>

    $obj->setAbbreviation($value);

    Set the value of the abbreviation field

=cut

sub setAbbreviation{
    my ($self, $value) = @_;
    $self->setFieldValue('abbreviation', $value);
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

=item B<getAllowUserDefinedValue>

    $int = $obj->getAllowUserDefinedValue();

    Get the value of the allow_user_defined_value field

=cut

sub getAllowUserDefinedValue{
    my ($self) = @_;
    return $self->getFieldValue('allow_user_defined_value');
}

#######################################################

=item B<setAllowUserDefinedValue>

    $obj->setAllowUserDefinedValue($value);

    Set the value of the allow_user_defined_value field

=cut

sub setAllowUserDefinedValue{
    my ($self, $value) = @_;
    $self->setFieldValue('allow_user_defined_value', $value);
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

#######################################################

=item B<getContentID>

    $string = $obj->getContentID();

    Get the value of the content_id field

=cut

sub getContentID{
    my ($self) = @_;
    return $self->getFieldValue('content_id');
}


#######################################################

=item B<setContentID>

    $obj->setContentID($value);

    Set the value of the content_id field

=cut

sub setContentID{
    my ($self, $value) = @_;
    $value = undef unless ($value);
    $self->setFieldValue('content_id', $value);
}

#######################################################

=item B<getSingleDropDownValue>

    $string = $obj->getSingleDropDownValue();

    Method used in single dropdowns to allow for the user defined value functionality

=cut

sub getSingleDropDownValue{
    my ($self) = @_;
    return unless $self->getPrimaryKeyID();
    return $self->getPrimaryKeyID() . "#" . $self->getAllowUserDefinedValue();
}



=back

=cut

### Other Methods

#######################################################

=item B<getLevel>

    $string = $obj->getLevel();

    Get the value of the level field (user defined)

=cut

sub getLevel{
    my ($self) = @_;
    return $self->{'__level'};
}

#######################################################

=item B<setLevel>

    $obj->setLevel($value);

    Set the value of the level field (user defined)

=cut

sub setLevel{
    my ($self, $value) = @_;
    $value = undef unless ($value);
    $self->{'__level'} = $value;
}

#######################################################

=item B<getItemTypeObject>

    $item_type = $obj->getItemTypeObject();

    Method to return the joined object TUSK::FormBuilder::ItemType;

=cut

sub getItemTypeObject{
    my ($self) = @_;
    return $self->getJoinObject("TUSK::FormBuilder::ItemType");
}

#######################################################

=item B<getItemTypeToken>

    $string = $obj->getItemTypeToken();

    Method used to get the token field from the joined object TUSK::FormBuilder::ItemType

=cut

sub getItemTypeToken{
    my ($self) = @_;
    my $item_type = $self->getItemTypeObject();
    return 0 if (ref($item_type) ne 'TUSK::FormBuilder::ItemType');
    return $item_type->getToken();
}

#######################################################

=item B<isCatStart>

    $int = $obj->isCatStart();

    Check to see if this item is has CatStart as its item_type

=cut

sub isCatStart {
    my ($self) = @_;
    return ($self->getItemTypeToken() eq 'CatStart') ? 1 : 0;
}


#######################################################

=item B<isItemType>

    $int = $obj->isItemType();

    Check to see if this item is has item as its item_type

=cut

sub isItemType {
    my ($self) = @_;
    return ($self->getItemTypeToken() eq 'Item') ? 1 : 0;
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

