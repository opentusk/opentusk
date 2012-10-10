package TUSK::FormBuilder::LinkFieldItemItem;

=head1 NAME

B<TUSK::FormBuilder::LinkFieldItemItem> - Class for manipulating entries in table form_builder_link_field_item_item in tusk database

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
					'tablename' => 'form_builder_link_field_item_item',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'link_field_item_item_id' => 'pk',
					'link_field_field_id' => '',
					'parent_item_id' => '',
					'child_item_id' => '',
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

=item B<getLinkFieldFieldID>

my $string = $obj->getLinkFieldFieldID();

Get the value of the link_field_field_id field

=cut

sub getLinkFieldFieldID{
    my ($self) = @_;
    return $self->getFieldValue('link_field_field_id');
}

#######################################################

=item B<setLinkFieldFieldID>

$obj->setLinkFieldFieldID($value);

Set the value of the link_field_field_id field

=cut

sub setLinkFieldFieldID{
    my ($self, $value) = @_;
    $self->setFieldValue('link_field_field_id', $value);
}


#######################################################

=item B<getParentItemID>

my $string = $obj->getParentItemID();

Get the value of the parent_item_id field

=cut

sub getParentItemID{
    my ($self) = @_;
    return $self->getFieldValue('parent_item_id');
}

#######################################################

=item B<setFieldItemID>

$obj->setParentItemID($value);

Set the value of the parent_item_id field

=cut

sub setParentItemID{
    my ($self, $value) = @_;
    $self->setFieldValue('parent_item_id', $value);
}


#######################################################

=item B<getChildItemID>

my $string = $obj->getChildItemID();

Get the value of the child_item_id field

=cut

sub getChildItemID{
    my ($self) = @_;
    return $self->getFieldValue('child_item_id');
}

#######################################################

=item B<setChildItemID>

$obj->setChildItemID($value);

Set the value of the child_item_id field

=cut

sub setChildItemID{
    my ($self, $value) = @_;
    $self->setFieldValue('child_item_id', $value);
}



=back

=cut

### Other Methods

sub getFieldItemObject {
    my ($self) = @_;
    return $self->getJoinObject("TUSK::FormBuilder::FieldItem");
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

