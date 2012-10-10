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


package TUSK::FormBuilder::LinkFormField;

=head1 NAME

B<TUSK::FormBuilder::LinkFormField> - Class for manipulating entries in table link_form_field in tusk database

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
					'tablename' => 'link_form_field',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'link_form_field_id' => 'pk',
					'parent_form_id' => '',
					'child_field_id' => '',
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

=item B<getParentFormID>

    $string = $obj->getParentFormID();

    Get the value of the parent_form_id field

=cut

sub getParentFormID{
    my ($self) = @_;
    return $self->getFieldValue('parent_form_id');
}

#######################################################

=item B<setParentFormID>

    $obj->setParentFormID($value);

    Set the value of the parent_form_id field

=cut

sub setParentFormID{
    my ($self, $value) = @_;
    $self->setFieldValue('parent_form_id', $value);
}


#######################################################

=item B<getChildFieldID>

    $string = $obj->getChildFieldID();

    Get the value of the child_field_id field

=cut

sub getChildFieldID{
    my ($self) = @_;
    return $self->getFieldValue('child_field_id');
}

#######################################################

=item B<setChildFieldID>

    $obj->setChildFieldID($value);

    Set the value of the child_field_id field

=cut

sub setChildFieldID{
    my ($self, $value) = @_;
    $self->setFieldValue('child_field_id', $value);
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

### Other Methods


#######################################################

=item B<getFieldObject>

    $field = $obj->getFieldObject();

    Return the field object joined to 

=cut

sub getFieldObject{
    my ($self) = @_;
    return $self->getJoinObject('TUSK::FormBuilder::Field');
}

=back

=cut


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

