package TUSK::FormBuilder::Form::AttributeFieldItem;

=head1 NAME

B<TUSK::FormBuilder::Form::AttributeFieldItem> - Class for manipulating entries in table form_builder_form_attribute_field_item in tusk database

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
					'tablename' => 'form_builder_form_attribute_field_item',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'attribute_field_item_id' => 'pk',
					'attribute_item_id' => '',
					'field_item_id' => '',
					'comment_required' => '',
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

=item B<getAttributeItemID>

my $string = $obj->getAttributeItemID();

Get the value of the attribute_item_id field

=cut

sub getAttributeItemID{
    my ($self) = @_;
    return $self->getFieldValue('attribute_item_id');
}

#######################################################

=item B<setAttributeItemID>

$obj->setAttributeItemID($value);

Set the value of the attribute_item_id field

=cut

sub setAttributeItemID{
    my ($self, $value) = @_;
    $self->setFieldValue('attribute_item_id', $value);
}


#######################################################

=item B<getFieldItemID>

my $string = $obj->getFieldItemID();

Get the value of the field_item_id field

=cut

sub getFieldItemID{
    my ($self) = @_;
    return $self->getFieldValue('field_item_id');
}

#######################################################

=item B<setFieldItemID>

$obj->setFieldItemID($value);

Set the value of the field_item_id field

=cut

sub setFieldItemID{
    my ($self, $value) = @_;
    $self->setFieldValue('field_item_id', $value);
}



#######################################################

=item B<getCommentRequired>

my $string = $obj->getCommentRequired();

Get the value of the comment_required field

=cut

sub getCommentRequired{
    my ($self) = @_;
    return $self->getFieldValue('comment_required');
}

#######################################################

=item B<setCommentRequired>

$obj->setCommentRequired($value);

Set the value of the comment_required field

=cut

sub setCommentRequired{
    my ($self, $value) = @_;
    $self->setFieldValue('comment_required', $value);
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

