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


package TUSK::FormBuilder::Field;

=head1 NAME

B<TUSK::FormBuilder::Field> - Class for manipulating entries in table form_builder_field in tusk database

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

use TUSK::FormBuilder::FieldType;
use TUSK::FormBuilder::LinkFormField;
use TUSK::FormBuilder::FieldItem;
use TUSK::FormBuilder::Attribute;
use TUSK::FormBuilder::ItemType;
use TUSK::FormBuilder::Constants;

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
					'tablename' => 'form_builder_field',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'field_id' => 'pk',
					'field_name' => '',
					'abbreviation' => '',
					'field_description' => '',
					'field_type_id' => '',
					'item_sort' => '',
					'default_report' => '',
					'required' => '',
					'private' => '',
					'fillin_size' => '',
					'show_comment' => '',
					'trailing_text' => '',
					'weight' => '',
				    },
				    _attributes => {
					save_history => 1,
					tracking_fields => 1,	
				    },
				    _levels => {
					reporting => 'cluck',
					error => 0,
				    },
				    _default_join_objects => [TUSK::Core::JoinObject->new("TUSK::FormBuilder::FieldType")],
				    @_
				  );
    # Finish initialization...
    return $self;
}

### Get/Set methods

#######################################################

=item B<getFieldName>

    $string = $obj->getFieldName();

    Get the value of the field_name field

=cut

sub getFieldName{
    my ($self) = @_;
    return $self->getFieldValue('field_name');
}

#######################################################

=item B<setFieldName>

    $obj->setFieldName($value);

    Set the value of the field_name field

=cut

sub setFieldName{
    my ($self, $value) = @_;
    $self->setFieldValue('field_name', $value);
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

=item B<getFieldDescription>

    $string = $obj->getFieldDescription();

    Get the value of the field_description field

=cut

sub getFieldDescription{
    my ($self) = @_;
    return $self->getFieldValue('field_description');
}

#######################################################

=item B<setFieldDescription>

    $obj->setFieldDescription($value);

    Set the value of the field_description field

=cut

sub setFieldDescription{
    my ($self, $value) = @_;
    $self->setFieldValue('field_description', $value);
}


#######################################################

=item B<getFieldTypeID>

    $string = $obj->getFieldTypeID();

    Get the value of the field_type field

=cut

sub getFieldTypeID{
    my ($self) = @_;
    return $self->getFieldValue('field_type_id');
}

#######################################################

=item B<setFieldTypeID>

    $obj->setFieldTypeID($value);

    Set the value of the field_type field

=cut

sub setFieldTypeID{
    my ($self, $value) = @_;
    if ($value) {
	$value = int($value); # make sure we got an int
	$self->setFieldValue('field_type_id', $value);
    }
}


#######################################################

=item B<getItemSort>

    $string = $obj->getItemSort();

    Get the value of the item_sort field

=cut

sub getItemSort{
    my ($self) = @_;
    return $self->getFieldValue('item_sort');
}

#######################################################

=item B<setItemSort>

    $obj->setItemSort($value);

    Set the value of the item_sort field

=cut

sub setItemSort{
    my ($self, $value) = @_;
    $self->setFieldValue('item_sort', $value);
}


=back

=cut


#######################################################

=item B<getDefaultReport>

    $string = $obj->getDefaultReport();

    Get the value of the default_report field

=cut

sub getDefaultReport{
    my ($self) = @_;
    return $self->getFieldValue('default_report');
}

#######################################################

=item B<setDefaultReport>

    $obj->setDefaultReport($value);

    Set the value of the default_report field

=cut

sub setDefaultReport{
    my ($self, $value) = @_;
    $self->setFieldValue('default_report', $value);
}


=back

=cut

#######################################################

=item B<getRequired>

    $string = $obj->getRequired();

    Get the value of the required field

=cut

sub getRequired{
    my ($self) = @_;
    return $self->getFieldValue('required');
}

#######################################################

=item B<setRequired>

    $obj->setRequired($value);

    Set the value of the required field

=cut

sub setRequired{
    my ($self, $value) = @_;
    $self->setFieldValue('required', $value);
}


=back

=cut

#######################################################

=item B<getPrivate>

    $string = $obj->getPrivate();

    Get the value of the private field

=cut

sub getPrivate{
    my ($self) = @_;
    return $self->getFieldValue('private');
}

#######################################################

=item B<setPrivate>

    $obj->setPrivate($value);

    Set the value of the private field

=cut

sub setPrivate{
    my ($self, $value) = @_;
    $self->setFieldValue('private', $value);
}


=back

=cut

#######################################################

=item B<getFillinSize>

    $string = $obj->getFillinSize();

    Get the value of the fillin_size field

=cut

sub getFillinSize{
    my ($self) = @_;
    return $self->getFieldValue('fillin_size');
}

=back

=cut

#######################################################

=item B<setFillinSize>

    $obj->setFillinSize($value);

    Set the value of the fillin_size field

=cut

sub setFillinSize{
    my ($self, $value) = @_;
    $self->setFieldValue('fillin_size', $value);
}


=back

=cut

#######################################################

=item B<getTrailingText>

    $string = $obj->getTrailingText();

    Get the value of the trailing_text field

=cut

sub getTrailingText{
    my ($self) = @_;
    return $self->getFieldValue('trailing_text');
}

=back

=cut

#######################################################

=item B<setTrailingText>

    $obj->setTrailingText($value);

    Set the value of the trailing_text field

=cut

sub setTrailingText{
    my ($self, $value) = @_;
    $self->setFieldValue('trailing_text', $value);
}


=cut

#######################################################

=item B<getWeight>

    $string = $obj->getWeight();

    Get the value of the weight field

=cut

sub getWeight{
    my ($self) = @_;
    return $self->getFieldValue('weight');
}

#######################################################

=item B<setWeight>

    $obj->setWeight($value);

    Set the value of the weight field
=cut

sub setWeight {
    my ($self, $value) = @_;
    $self->setFieldValue('weight', $value);
}

=back


=cut

#######################################################

=item B<getShowComment>

    $string = $obj->getShowComment();

    Get the value of the show_comment field

=cut

sub getShowComment{
    my ($self) = @_;
    return $self->getFieldValue('show_comment');
}

=back

=cut

#######################################################

=item B<setShowComment>

    $obj->setShowComment($value);

    Set the value of the show_comment field

=cut

sub setShowComment{
    my ($self, $value) = @_;
    $self->setFieldValue('show_comment', $value);
}


=back


=cut


### Other Methods

#######################################################

=item B<getFieldTypeObject>

    $field_type_object = $obj->getFieldTypeObject();

    Get the field type object associated with this object

=cut

sub getFieldTypeObject{
    my ($self) = @_;
    return $self->getJoinObject("TUSK::FormBuilder::FieldType");
}

#######################################################

=item B<getLinkFormFieldObject>

    $link_object = $obj->getLinkFormFieldObject();

    Get the link_form_field object associated with this object

=cut

sub getLinkFormFieldObject{
    my ($self) = @_;
    return $self->getJoinObject("TUSK::FormBuilder::LinkFormField");
}

#######################################################

=item B<getFieldTypeLabel>

    $string = $obj->getFieldTypeLabel();

    Get the field type label

=cut

sub getFieldTypeLabel{
    my ($self) = @_;
    my $field_type =  $self->getFieldTypeObject();

    return $field_type->getLabel();
}

#######################################################

=item B<getFieldTypeToken>

    $string = $obj->getFieldTypeToken();

    Get the field type token

=cut

sub getFieldTypeToken{
    my ($self) = @_;
    my $field_type =  $self->getFieldTypeObject();

    return $field_type->getToken();
}

#######################################################

=item B<getFieldTypeDropDownValue>

    $string = $obj->getFieldTypeDropDownValue();

    Get the field type drop down value

=cut

sub getFieldTypeDropDownValue{
    my ($self) = @_;
    my $field_type =  $self->getFieldTypeObject();
    return 0 unless (ref $field_type eq 'TUSK::FormBuilder::FieldType');

    return $field_type->getDropDownValue();
}

#######################################################

=item B<isFillIn>

    $int = $obj->isFillIn();

    Check to see if this field object is a fill in

=cut

sub isFillIn{
    my ($self) = @_;
    my $field_type =  $self->getFieldTypeObject();
    return $field_type->checkToken('FillIn');
}


#######################################################

=item B<isEssay>

    $int = $obj->isEssay();

    Check to see if this field object is a essay

=cut

sub isEssay{
    my ($self) = @_;
    my $field_type =  $self->getFieldTypeObject();
    return $field_type->checkToken('Essay');
}

#######################################################

=item B<isSingleSelect>

    $int = $obj->isSingleSelect();

    Check to see if this field object is a single select

=cut

sub isSingleSelect{
    my ($self) = @_;
    my $field_type =  $self->getFieldTypeObject();
    return $field_type->checkToken('SingleSelect');
}

#######################################################

=item B<isMultiSelect>

    $int = $obj->isMultiSelect();

    Check to see if this field object is a multi select

=cut

sub isMultiSelect{
    my ($self) = @_;
    my $field_type =  $self->getFieldTypeObject();
    return $field_type->checkToken('MultiSelect');
}

#######################################################

=item B<isSingleSelectAllowMultiple>

    $int = $obj->isSingleSelectAllowMultiple();

    Check to see if this field object is a single select allow multiple

=cut

sub isSingleSelectAllowMultiple{
    my ($self) = @_;
    my $field_type =  $self->getFieldTypeObject();
    return $field_type->checkToken('SingleSelectAllowMulti');
}

#######################################################

=item B<isMultiSelectWithAttributes>

    $int = $obj->isMultiSelectWithAttributes();

    Check to see if this field object is a multi select with attributes

=cut

sub isMultiSelectWithAttributes{
    my ($self) = @_;
    my $field_type =  $self->getFieldTypeObject();
    return $field_type->checkToken('MultiSelectWithAttributes');
}


#######################################################

=item B<isSingleSelect>

    $int = $obj->isSingleSelect();

    Check to see if this field object is a single select

=cut

sub isSingleSelectWithSubFields {
    my ($self) = @_;
    my $field_type =  $self->getFieldTypeObject();
    return $field_type->checkToken('SingleSelectWithSubFields');
}


#######################################################

=item B<isDynamicList>

    $int = $obj->isDynamicList();

    Check to see if this field object is a dynamic list

=cut

sub isDynamicList {
    my ($self) = @_;
	if ($self->getPrimaryKeyID()) {
		my $field_type =  $self->getFieldTypeObject();
		return $field_type->checkToken('DynamicList');
	} 
	return 0;
}


#######################################################

=item B<isChildOfDynamicList>

    $int = $obj->isChildOfDynamicList();

    Check to see if this field object is a child of dynamic list field

=cut

sub isChildOfDynamicList {
    my ($self) = @_;
	### figure out root_field_id of current field then get all fields under the same root_field_id
	my $curr_link = TUSK::FormBuilder::LinkFieldField->lookupReturnOne("child_field_id = " . $self->getPrimaryKeyID());
	if ($curr_link) {
		### this will help figure out which one are we in the list
		$self->{depth_level} = $curr_link->getDepthLevel() - 1;
		$self->{dynamic_list} = TUSK::FormBuilder::LinkFieldField->lookup("root_field_id = " . $curr_link->getRootFieldID(), [ 'depth_level' ]);

		if (scalar @{$self->{dynamic_list}} && ref $self->{dynamic_list}[0] eq 'TUSK::FormBuilder::LinkFieldField') {
			return 1;
		}
	}
	return 0;
}


#######################################################

=item B<getChildDynamicList>

    $int = $obj->getChildDynamicList();

    list of child fields including the current field
=cut

sub getChildDynamicList {
	my $self = shift;

	if (my $num_child_fields = scalar @{$self->{dynamic_list}}) {
		return [ @{$self->{dynamic_list}}[$self->{depth_level}..$num_child_fields-1] ];
	} 

	return undef;
}

#######################################################

=item B<isCheckList>

    $int = $obj->isCheckList();

    Check to see if this field object is a checklist

=cut

sub isCheckList {
    my ($self) = @_;
    my $field_type =  $self->getFieldTypeObject();
    return $field_type->checkToken('CheckList');
}


#######################################################

=item B<isHeading>

    $int = $obj->isHeading();

    Check to see if this field object is an Heading

=cut

sub isHeading {
    my ($self) = @_;
    my $field_type =  $self->getFieldTypeObject();
    return $field_type->checkToken('Heading');
}

#######################################################

=item B<hasSubFields>

    $int = $obj->hasSubFields();

    Check to see if this field object has sub fields

=cut

sub hasSubFields {
    my ($self) = @_;
    my $field_type =  $self->getFieldTypeObject();
    return $field_type->checkToken('ScalingWithSubFields') || $field_type->checkToken('SingleSelectWithSubFields');
}


#######################################################

=item B<isRubric>

    $int = $obj->isRubric();

    Check to see if this field object is rubric

=cut

sub isRubric {
    my ($self) = @_;
    my $field_type =  $self->getFieldTypeObject();
    return $field_type->checkToken('ScalingWithSubFields') || $field_type->checkToken('Scaling');
}


#######################################################

=item B<getItems>

    $array_ref = $obj->getItems($cond);

    Return an array ref of FieldItems associated with this obj; You can give a cond if you wish

=cut

sub getItems{
    my ($self, $cond) = @_;
    $cond = " and " . $cond if ($cond);
    return TUSK::FormBuilder::FieldItem->new()->lookup('field_id = ' . $self->getPrimaryKeyID() . $cond);
}


sub getItemsWithFieldLinks {
    my ($self) = @_;
    my $link = TUSK::FormBuilder::LinkFieldField->new();
    $link->join_debug();
    return $link->lookup('', undef, undef, undef, [ 
	    TUSK::Core::JoinObject->new("TUSK::FormBuilder::FieldItem", { origkey => 'child_field_id', joinkey => 'field_id', joincond => 'field_id = ' . $self->getPrimaryKeyID(), jointype => 'left'}), 
	    TUSK::Core::JoinObject->new("TUSK::FormBuilder::LinkFieldFieldItem", { origkey => 'link_field_field_id', joinkey => 'link_field_field_id', jointype => 'right'}) ]);
}


#######################################################

=item B<getNonCatItems>

    $array_ref = $obj->getNonCatItems($cond);

    Return an array ref of FieldItems associated with this obj that are of type ITEM; You can give a cond if you wish

=cut

sub getNonCatItems{
    my ($self, $cond) = @_;
    my $item_type = TUSK::FormBuilder::ItemType->new()->lookup("token = 'Item'");
    $cond = $cond . " and " if ($cond);
    $cond .= "form_builder_field_item.item_type_id = " . $item_type->[0]->getPrimaryKeyID(); 
    return $self->getItems($cond);
}

#######################################################

=item B<getAttributes>

    $array_ref = $obj->getAttributes();

    Return an array ref of Attributes associated with this obj

=cut

sub getAttributes{
    my ($self) = @_;
    return TUSK::FormBuilder::Attribute->new()->lookup('field_id = ' . $self->getPrimaryKeyID());
}

#######################################################

=item B<isValidItem>

    $int = $obj->isValidItem($item_id);

    checks to see if an item_id belongs to this field

=cut

sub isValidItem{
    my ($self, $item_id) = @_;
    my $item = TUSK::FormBuilder::FieldItem->new()->lookup('field_id = ' . $self->getPrimaryKeyID() . '  and item_id = ' . $item_id);
    return scalar(@$item);
}



sub getShortName{
    my ($self) = @_;
    if ($self->getAbbreviation()){
	return $self->getAbbreviation()
    }elsif (length($self->getFieldName()) > 20){
	return substr($self->getFieldName(), 0, 16) . "...";
    }else{
	return $self->getFieldName();
    }

}

sub getDefaultReportFlags {
	my $self = shift;
	
	my $flag = $self->getDefaultReport();

	return (exists $TUSK::FormBuilder::Constants::map_default_report_flags->{$flag}) ? $TUSK::FormBuilder::Constants::map_default_report_flags->{$flag} : { $flag => 1 };
}


sub setDefaultReportFlags {
	my ($self, $values) = @_;
	my $num = 0;

	if (ref $values eq 'ARRAY') {
		foreach my $val (@$values) {
			$num += $val;
		}
	} else {
		$num = $values;
	}

	$self->setDefaultReport($num);
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

