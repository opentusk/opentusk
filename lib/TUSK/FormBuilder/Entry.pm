package TUSK::FormBuilder::Entry;

=head1 NAME

B<TUSK::FormBuilder::Entry> - Class for manipulating entries in table form_builder_entry in tusk database

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

use TUSK::FormBuilder::Response;

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
					'tablename' => 'form_builder_entry',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'entry_id' => 'pk',
					'user_id' => '',
					'date' => '',
					'form_id' => '',
					'time_period_id' => '',
					'complete_date' => '',
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

=item B<getUserID>

    $string = $obj->getUserID();

    Get the value of the user_id field

=cut

sub getUserID{
    my ($self) = @_;
    return $self->getFieldValue('user_id');
}

#######################################################

=item B<setUserID>

    $obj->setUserID($value);

    Set the value of the user_id field

=cut

sub setUserID{
    my ($self, $value) = @_;
    $self->setFieldValue('user_id', $value);
}


#######################################################

=item B<getDate>

    $string = $obj->getDate();

    Get the value of the date field

=cut

sub getDate{
    my ($self) = @_;
    return $self->getFieldValue('date');
}

#######################################################

=item B<setDate>

    $obj->setDate($value);

    Set the value of the date field

=cut

sub setDate{
    my ($self, $value) = @_;
    $self->setFieldValue('date', $value);
}


#######################################################

=item B<getFormID>

    $string = $obj->getFormID();

    Get the value of the form_id field

=cut

sub getFormID{
    my ($self) = @_;
    return $self->getFieldValue('form_id');
}

#######################################################

=item B<setFormID>

    $obj->setFormID($value);

    Set the value of the form_id field

=cut

sub setFormID{
    my ($self, $value) = @_;
    $self->setFieldValue('form_id', $value);
}

#######################################################

=item B<getTimePeriodID>

    $string = $obj->getTimePeriodID();

    Get the value of the time_period_id field

=cut

sub getTimePeriodID{
    my ($self) = @_;
    return $self->getFieldValue('time_period_id');
}

#######################################################

=item B<setTimePeriodID>

    $obj->setTimePeriodID($value);

    Set the value of the time_period_id field

=cut

sub setTimePeriodID{
    my ($self, $value) = @_;
    $self->setFieldValue('time_period_id', $value);
}

#######################################################

=item B<getCompleteDate>

    $string = $obj->getCompleteDate();

    Get the value of the complete_date field

=cut

sub getCompleteDate{
    my ($self) = @_;
    return $self->getFieldValue('complete_date');
}

#######################################################

=item B<setCompleteDate>

    $obj->setCompleteDate($value);

    Set the value of the complete_date field

=cut

sub setCompleteDate{
    my ($self, $value) = @_;
    $self->setFieldValue('complete_date', $value);
}



=back

=cut

### Other Methods

#######################################################

=item B<getResponses>

    $arrayref = $obj->getResponses();

    Get an arrayref of Response objects that are tied to this entry

=cut

sub getResponses{
    my ($self) = @_;
    return TUSK::FormBuilder::Response->new()->lookup('active_flag and entry_id = ' . $self->getPrimaryKeyID());
}

=item B<getFullResponses>

    $arrayref = $obj->getFullResponses();

    Get an arrayref of Response objects that also have all the associated objects ('FieldItem', 'ResponseAttribute', 'AttributeItem', 'Field', 'LinkFormField') use getJoinObject and getJoinObjects to retrieve the info.

=cut

sub getFullResponses{
    my ($self, $all_responses) = @_;

    my $active_flag;
    
    $active_flag = "active_flag and " unless ($all_responses);

    return TUSK::FormBuilder::Response->new()->lookup($active_flag . ' entry_id = ' . $self->getPrimaryKeyID(), 
						      ['link_form_field.sort_order', 'active_flag desc', 'form_builder_field_item.sort_order'], 
						      undef, 
						      undef, 
						      [
						       TUSK::Core::JoinObject->new('TUSK::FormBuilder::FieldItem'),
						       TUSK::Core::JoinObject->new('TUSK::FormBuilder::ResponseAttribute', { joinkey => 'response_id' }),
						       TUSK::Core::JoinObject->new('TUSK::FormBuilder::AttributeItem', { origkey => 'form_builder_response_attribute.attribute_item_id'}),
						     TUSK::Core::JoinObject->new('TUSK::FormBuilder::Field'),
						     TUSK::Core::JoinObject->new('TUSK::FormBuilder::LinkFormField', { origkey => 'form_builder_field.field_id', joinkey => 'child_field_id'}),

						       ]
						      );

}

=item B<getResponseData>

    $arrayref = $obj->getResponseData();

    Call $obj->getFullResponses and process the output into a nice compact data structure

=cut


sub getResponseData{
    my ($self) = @_;
    
    my $data = [];
    my $previous_field;

    my $responses = $self->getFullResponses(1);

    foreach my $response (@$responses){
	my $field = $response->getJoinObject('TUSK::FormBuilder::Field');
	
	if (scalar(@$data) == 0 or $response->getFieldID() ne $data->[-1]->{id}){
	    push (@$data, { name => $field->getFieldName(), id => $response->getFieldID(), values => [] });
	}
	
	my $value;
	my $item = $response->getJoinObject('TUSK::FormBuilder::FieldItem');

	if ($item && ref($item) eq 'TUSK::FormBuilder::FieldItem' && $item->getPrimaryKeyID()){
	    $value = $item->getItemName();
	    
	    my $attribute_text = [];

	    my $attributes = $response->getJoinObjects('TUSK::FormBuilder::AttributeItem');
	    my @attribute_values;
	    foreach my $attr (@$attributes){
		push (@attribute_values, $attr->getItemName()) if ($attr->getItemName());
	    }

	    push (@attribute_values, $response->getText()) if ($response->getText());

	    if (scalar(@attribute_values)){
		$value .= '&nbsp;(' . join(', ', @attribute_values) . ')';
	    }
	} else {
	    $value = $response->getText();
	}
	
	push (@{$data->[-1]->{values}}, { value => $value, active => $response->getActiveFlag() });
    }

    return $data;
}

=item B<delete>

    my $int = $obj->delete();

    Deletes the entry along with any responses and response attributes.

=cut

sub delete{
    my ($self, $user_id) = @_;

    my $responses = $self->getResponses();

    foreach my $response (@$responses){
	my $response_attributes = $response->getResponseAttributes();

	foreach my $response_attribute (@$response_attributes){
		$response_attribute->delete({'user' => $user_id});
	}

	$response->delete({'user' => $user_id});
    }
    
    return $self->SUPER::delete({'user' => $user_id});
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

