package TUSK::FormBuilder::Form::AttributeItem;

=head1 NAME

B<TUSK::FormBuilder::Form::AttributeItem> - Class for manipulating entries in table form_builder_form_attribute_item in tusk database

=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 INTERFACE


=head2 GET/SET METHODS

=over 4

=cut

use strict;
use TUSK::FormBuilder::Form::AttributeFieldItem;
use TUSK::FormBuilder::FieldItem;

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
					'tablename' => 'form_builder_form_attribute_item',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'attribute_item_id' => 'pk',
					'attribute_id' => '',
					'sort_order' => '',
					'title' => '',
					'description' => '',
					'min_value' => '',
					'max_value' => '',
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

=item B<getAttributeID>

my $string = $obj->getAttributeID();

Get the value of the attribute_id field

=cut

sub getAttributeID{
    my ($self) = @_;
    return $self->getFieldValue('attribute_id');
}

#######################################################

=item B<setAttributeID>

$obj->setAttributeID($value);

Set the value of the attribute_id field

=cut

sub setAttributeID{
    my ($self, $value) = @_;
    $self->setFieldValue('attribute_id', $value);
}


#######################################################

=item B<getSortOrder>

my $string = $obj->getSortOrder();

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

=item B<getTitle>

my $string = $obj->getTitle();

Get the value of the title field

=cut

sub getTitle{
    my ($self) = @_;
    return $self->getFieldValue('title');
}

#######################################################

=item B<setTitle>

$obj->setTitle($value);

Set the value of the title field

=cut

sub setTitle{
    my ($self, $value) = @_;
    $self->setFieldValue('title', $value);
}


#######################################################

=item B<getDescription>

my $string = $obj->getDescription();

Get the value of the description field

=cut

sub getDescription{
    my ($self) = @_;
    return $self->getFieldValue('description');
}

#######################################################

=item B<setDescription>

$obj->setDescription($value);

Set the value of the description field

=cut

sub setDescription{
    my ($self, $value) = @_;
    $self->setFieldValue('description', $value);
}


#######################################################

=item B<getMinValue>

my $string = $obj->getMinValue();

Get the value of the min_value field

=cut

sub getMinValue{
    my ($self) = @_;
    return $self->getFieldValue('min_value');
}

#######################################################

=item B<setMinValue>

$obj->setMinValue($value);

Set the value of the min_value field

=cut

sub setMinValue{
    my ($self, $value) = @_;
    $self->setFieldValue('min_value', $value);
}


#######################################################

=item B<getMaxValue>

my $string = $obj->getMaxValue();

Get the value of the max_value field

=cut

sub getMaxValue{
    my ($self) = @_;
    return $self->getFieldValue('max_value');
}

#######################################################

=item B<setMaxValue>

$obj->setMaxValue($value);

Set the value of the max_value field

=cut

sub setMaxValue{
    my ($self, $value) = @_;
    $self->setFieldValue('max_value', $value);
}



=back

=cut

### Other Methods

#######################################################

=item B<delete>

    $retval = $obj->delete();

	Before deleting this AttributeItem, delete any associated 
	FieldItems relying on this, as well as the AttributeFieldItem
	link.

=cut

sub delete{
	my ($self, $params) = @_;
	my $id = $self->getPrimaryKeyID();	
	my $attribute_field_items = TUSK::FormBuilder::Form::AttributeFieldItem->lookup("attribute_item_id = $id");
	foreach my $attribute_field_item (@$attribute_field_items) {
		my $field_item_id = $attribute_field_item->getFieldItemID();
		my $field_item = TUSK::FormBuilder::FieldItem->lookupReturnOne("item_id = $field_item_id");
		$field_item->delete($params);
		$attribute_field_item->delete($params);
	}
	
	return $self->SUPER::delete($params);
}

#######################################################


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

