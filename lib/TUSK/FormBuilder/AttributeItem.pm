package TUSK::FormBuilder::AttributeItem;

=head1 NAME

B<TUSK::FormBuilder::AttributeItem> - Class for manipulating entries in table form_builder_attribute_item in tusk database

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
					'tablename' => 'form_builder_attribute_item',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'item_id' => 'pk',
					'item_name' => '',
					'abbreviation' => '',
					'attribute_id' => '',
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
				    _default_order_bys => ['sort_order'],
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

=item B<getAttributeID>

    $string = $obj->getAttributeID();

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

