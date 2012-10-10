package TUSK::FormBuilder::Response;

=head1 NAME

B<TUSK::FormBuilder::Response> - Class for manipulating entries in table form_builder_response in tusk database

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
use TUSK::FormBuilder::ResponseAttribute;


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
					'tablename' => 'form_builder_response',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'response_id' => 'pk',
					'entry_id' => '',
					'field_id' => '',
					'item_id' => '',
					'text' => '',
					'active_flag' => '',
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

=item B<getEntryID>

    $string = $obj->getEntryID();

    Get the value of the entry_id field

=cut

sub getEntryID{
    my ($self) = @_;
    return $self->getFieldValue('entry_id');
}

#######################################################

=item B<setEntryID>

    $obj->setEntryID($value);

    Set the value of the entry_id field

=cut

sub setEntryID{
    my ($self, $value) = @_;
    $self->setFieldValue('entry_id', $value);
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

=item B<getItemID>

    $string = $obj->getItemID();

    Get the value of the item_id field

=cut

sub getItemID{
    my ($self) = @_;
    return $self->getFieldValue('item_id');
}

#######################################################

=item B<setItemID>

    $obj->setItemID($value);

    Set the value of the item_id field

=cut

sub setItemID{
    my ($self, $value) = @_;
    $self->setFieldValue('item_id', $value);
}


#######################################################

=item B<getText>

    $string = $obj->getText();

    Get the value of the text field

=cut

sub getText{
    my ($self) = @_;
    return $self->getFieldValue('text');
}

#######################################################

=item B<setText>

    $obj->setText($value);

    Set the value of the text field

=cut

sub setText{
    my ($self, $value) = @_;
    $self->setFieldValue('text', $value);
}

#######################################################

=item B<getActiveFlag>

    $string = $obj->getActiveFlag();

    Get the value of the active_flag field

=cut

sub getActiveFlag{
    my ($self) = @_;
    return $self->getFieldValue('active_flag');
}

#######################################################

=item B<setActiveFlag>

    $obj->setActiveFlag($value);

    Set the value of the active_flag field

=cut

sub setActiveFlag{
    my ($self, $value) = @_;
    $self->setFieldValue('active_flag', $value);
}



=back

=cut

### Other Methods
#######################################################

=item B<getResponseAttributes>

    $arrayref = $obj->getResponseAttributes();

    Get an arrayref of Response Attribute objects that are tied to this entry

=cut

sub getResponseAttributes{
    my ($self) = @_;
    return TUSK::FormBuilder::ResponseAttribute->new()->lookup('response_id = ' . $self->getPrimaryKeyID());
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

