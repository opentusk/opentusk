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


package TUSK::FormBuilder::LinkFieldField;

=head1 NAME

B<TUSK::FormBuilder::LinkFieldField> - Class for manipulating entries in table form_builder_link_field_field in tusk database

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
use TUSK::FormBuilder::Field;
use TUSK::FormBuilder::FieldItem;
use TUSK::FormBuilder::LinkFieldItemItem;

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
					'tablename' => 'form_builder_link_field_field',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'link_field_field_id' => 'pk',
					'parent_field_id' => '',
					'child_field_id' => '',
					'root_field_id' => '',
					'depth_level' => '',
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
				    @_
				  );
    # Finish initialization...
    return $self;
}

### Get/Set methods

#######################################################

=item B<getRootFieldID>

my $string = $obj->getRootFieldID();

Get the value of the root_field_id field

=cut

sub getRootFieldID{
    my ($self) = @_;
    return $self->getFieldValue('root_field_id');
}

#######################################################

=item B<setRootFieldID>

$obj->setRootFieldID($value);

Set the value of the root_field_id field

=cut

sub setRootFieldID{
    my ($self, $value) = @_;
    $self->setFieldValue('root_field_id', $value);
}


#######################################################

=item B<getParentFieldID>

my $string = $obj->getParentFieldID();

Get the value of the parent_field_id field

=cut

sub getParentFieldID{
    my ($self) = @_;
    return $self->getFieldValue('parent_field_id');
}

#######################################################

=item B<setParentFieldID>

$obj->setParentFieldID($value);

Set the value of the parent_field_id field

=cut

sub setParentFieldID{
    my ($self, $value) = @_;
    $self->setFieldValue('parent_field_id', $value);
}


#######################################################

=item B<getChildFieldID>

my $string = $obj->getChildFieldID();

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

=item B<getDepthLevel>

my $string = $obj->getDepthLevel();

Get the value of the depth_level field

=cut

sub getDepthLevel{
    my ($self) = @_;
    return $self->getFieldValue('depth_level');
}

#######################################################

=item B<setDepthLevel>

$obj->setDepthLevel($value);

Set the value of the depth_level field

=cut

sub setDepthLevel{
    my ($self, $value) = @_;
    $self->setFieldValue('depth_level', $value);
}


=back
=cut

### Other Methods

sub getFieldObject {
    my ($self) = @_;
    return $self->getJoinObject("TUSK::FormBuilder::Field");
}

sub getFieldItemObject {
    my ($self) = @_;
    return $self->getJoinObject("TUSK::FormBuilder::FieldItem");
}

sub getLinkFieldItemItemObject {
    my ($self) = @_;
    return $self->getJoinObject("TUSK::FormBuilder::LinkFieldItemItem");
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

