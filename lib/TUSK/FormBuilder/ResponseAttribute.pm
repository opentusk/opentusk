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


package TUSK::FormBuilder::ResponseAttribute;

=head1 NAME

B<TUSK::FormBuilder::ResponseAttribute> - Class for manipulating entries in table form_builder_response_attribute in tusk database

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
					'tablename' => 'form_builder_response_attribute',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'response_attribute_id' => 'pk',
					'response_id' => '',
					'attribute_id' => '',
					'attribute_item_id' => '',
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

=item B<getResponseID>

    $string = $obj->getResponseID();

    Get the value of the response_id field

=cut

sub getResponseID{
    my ($self) = @_;
    return $self->getFieldValue('response_id');
}

#######################################################

=item B<setResponseID>

    $obj->setResponseID($value);

    Set the value of the response_id field

=cut

sub setResponseID{
    my ($self, $value) = @_;
    $self->setFieldValue('response_id', $value);
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

=item B<getAttributeItemID>

    $string = $obj->getAttributeItemID();

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

