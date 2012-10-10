package TUSK::Application::FormBuilder::Delete;

use strict;
use TUSK::FormBuilder::Field;
use TUSK::FormBuilder::FieldItem;
use TUSK::FormBuilder::LinkFieldField;
use TUSK::FormBuilder::LinkFieldItemItem;


sub new {
    my ($class, $args) = @_;
    my $self = {field => $args->{field}};
    bless($self, $class);
    return $self;
}

##################################################################################
# Delete a field OR all the fields linked to a given field ie dynamic list field
# Also delete the field items for each deleted field
##################################################################################
sub deleteFieldsAndItems {
    my $self = shift;

	return unless (ref $self->{field} eq 'TUSK::FormBuilder::Field');

	my $field_id = $self->{field}->getPrimaryKeyID();

	if ($self->{field}->isDynamicList()) {  ### root field
        ### delete all the children in link_field_field, then delete itself later
		_deleteLinkFieldsAndItems(TUSK::FormBuilder::LinkFieldField->lookup("root_field_id = $field_id"));


	} elsif ($self->{field}->isChildOfDynamicList()) {  ### parent field but not root field
        ### delete children of existing fields including itself in link_field_field
		_deleteLinkFieldsAndItems($self->{field}->getChildDynamicList());
		return;  ## an early exit as we delete all we need for this field
	}

	if (my $link_form_field = TUSK::FormBuilder::LinkFormField->new()->lookupReturnOne('child_field_id = ' . $self->{field}->getPrimaryKeyID())) {
		$link_form_field->delete();
	}

	_deleteItems($field_id);  
    $self->{field}->delete();
}


sub _deleteLinkFieldsAndItems {
	my $link_fields = shift;

	foreach my $link_field (@$link_fields) {

		### delete link_field_item_item
		my $link_items = TUSK::FormBuilder::LinkFieldItemItem->lookup("link_field_field_id = " . $link_field->getPrimaryKeyID());
		foreach my $link_item (@$link_items) {
			$link_item->delete();
		}

		### delete the child field id in each record
		### that means we delete items for each child filed
		### then delete the child field itself
		if (my $child_field = TUSK::FormBuilder::Field->lookupKey($link_field->getChildFieldID())) {
			_deleteItems($child_field->getPrimaryKeyID());
			$child_field->delete();
		}

		$link_field->delete();
	}
}


sub _deleteItems {
	my $field_id = shift;
    ### delete all items for the given field id
	my $items = TUSK::FormBuilder::FieldItem->lookup("field_id = $field_id");
	foreach my $item (@$items) {
		$item->delete();
	}
}

1;
