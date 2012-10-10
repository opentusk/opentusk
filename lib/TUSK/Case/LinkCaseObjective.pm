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


package TUSK::Case::LinkCaseObjective;

=head1 NAME

B<TUSK::Case::LinkCaseObjective> - Class for manipulating entries in table link_case_objective in tusk database

=head1 DESCRIPTION

=head2 GET/SET METHODS

=over 4

=cut

use strict;
use TUSK::Core::Objective;

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
					'tablename' => 'link_case_objective',
					'usertoken' => 'ContentManager',
					},
				    _field_names => {
					'link_case_objective_id' => 'pk',
					'parent_case_id' => '',
					'child_objective_id' => '',
					'sort_order' => '',
				    },
				    _attributes => {
					save_history => 1,
					tracking_fields => 1,	
				    },
				    _levels => {
					reporting => 'warn',
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

=item B<getParentCaseID>

   $string = $obj->getParentCaseID();

Get the value of the parent_case_id field

=cut

sub getParentCaseID{
    my ($self) = @_;
    return $self->getFieldValue('parent_case_id');
}

#######################################################

=item B<setParentCaseID>

    $string = $obj->setParentCaseID($value);

Set the value of the parent_case_id field

=cut

sub setParentCaseID{
    my ($self, $value) = @_;
    $self->setFieldValue('parent_case_id', $value);
}


#######################################################

=item B<getChildObjectiveID>

   $string = $obj->getChildObjectiveID();

Get the value of the child_objective_id field

=cut

sub getChildObjectiveID{
    my ($self) = @_;
    return $self->getFieldValue('child_objective_id');
}

#######################################################

=item B<setChildObjectiveID>

    $string = $obj->setChildObjectiveID($value);

Set the value of the child_objective_id field

=cut

sub setChildObjectiveID{
    my ($self, $value) = @_;
    $self->setFieldValue('child_objective_id', $value);
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

    $string = $obj->setSortOrder($value);

Set the value of the sort_order field

=cut

sub setSortOrder{
    my ($self, $value) = @_;
    $self->setFieldValue('sort_order', $value);
}



=back

=cut

### Other Methods

#######################################################

=item B<lookupByRelation>

    $new_object = $obj->lookupByRelation($parent_id,$child_id);

Use the two ids passed to find a row that represents their relation.  Returns
undef if the relation is not found.

=cut

sub lookupByRelation{
    my ($self, $parent_id,$child_id) = @_;
    return $self->lookup("parent_case_id = $parent_id and child_objective_id = $child_id");
}

#######################################################

=item B<getObjective>

    $objective_object = $obj->getObjective();

Use the link to get the child object of this relation.  Returns a TUSK::Core::Objective

=cut

sub getObjective {
	my $self = shift;
	return TUSK::Core::Objective->new->lookupKey($self->getChildObjectiveID());
}


=head1 AUTHOR

TUSK <tuskdev@tufts.edu>

=head1 BUGS

None Reported.

=head1 SEE ALSO

B<TUSK::Core::SQLRow> - parent class

=head1 COPYRIGHT



=cut

1;

