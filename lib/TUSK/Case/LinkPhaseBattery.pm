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


package TUSK::Case::LinkPhaseBattery;

=head1 NAME

B<TUSK::Case::LinkPhaseBattery> - Class for manipulating entries in table link_phase_battery in tusk database

=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 INTERFACE


=head2 GET/SET METHODS

=over 4

=cut

use strict;
use Carp;

BEGIN {
    require Exporter;
    require TUSK::Core::SQLRow;

    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
    
    @ISA = qw(TUSK::Core::SQLRow Exporter);
    @EXPORT = qw( );
    @EXPORT_OK = qw( );
}

use vars @EXPORT_OK;
use TUSK::Case::Battery;

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
					'tablename' => 'link_phase_battery',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'link_phase_battery_id' => 'pk',
					'parent_phase_id' => '',
					'child_battery_id' => '',
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

=item B<getParentPhaseID>

    $string = $obj->getParentPhaseID();

    Get the value of the parent_phase_id field

=cut

sub getParentPhaseID{
    my ($self) = @_;
    return $self->getFieldValue('parent_phase_id');
}

#######################################################

=item B<setParentPhaseID>

    $string = $obj->setParentPhaseID($value);

    Set the value of the parent_phase_id field

=cut

sub setParentPhaseID{
    my ($self, $value) = @_;
    $self->setFieldValue('parent_phase_id', $value);
}


#######################################################

=item B<getChildBatteryID>

    $string = $obj->getChildBatteryID();

    Get the value of the child_battery_id field

=cut

sub getChildBatteryID{
    my ($self) = @_;
    return $self->getFieldValue('child_battery_id');
}

#######################################################

=item B<setChildBatteryID>

    $string = $obj->setChildBatteryID($value);

    Set the value of the child_battery_id field

=cut

sub setChildBatteryID{
    my ($self, $value) = @_;
    $self->setFieldValue('child_battery_id', $value);
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


#######################################################

=item B<getBatteries>

    $battery_array = TUSK::Case::LinkPhaseBattery->getBatteries($phase_id);

    Get all of the child batteries for a given phase

=cut

sub getBatteries {
    my $class = shift;
    my $phase = shift;
    if (ref($class) ne ''){
 	confess "This method getBatteries needs to be called statically."
    } elsif (!$phase->isa('TUSK::Case::Phase')){
 	confess "This method getBatteries needs a TUSK::Case::Phase object "
    }
    my $phase_id = $phase->getPrimaryKeyID(); 
    my $battery_type = $phase->getBatteryType();
    
    return TUSK::Case::Battery->lookup(undef, undef, undef, undef, [ TUSK::Core::JoinObject->new("TUSK::Case::LinkPhaseBattery", {origkey=>'battery_id', joinkey=>'child_battery_id', cond => "link_phase_battery.parent_phase_id = $phase_id and battery_type = '$battery_type'"}) ]);
}


=back

=cut

### Other Methods

#######################################################

=item B<getBattery>

    $objective_object = $obj->getBattery();

Use the link to get the child object of this relation.  Returns a TUSK::Case::Battery

=cut

sub getBattery {
        my $self = shift;
        return TUSK::Case::Battery->new->lookupKey($self->getChildBatteryID());
}


#######################################################


=item B<lookupByRelation>

    $new_object = $obj->lookupByRelation($parent_id,$child_id);

Use the two ids passed to find a row that represents their relation.  Returns
undef if the relation is not found.

=cut

sub lookupByRelation{
    my ($self, $parent_id,$child_id) = @_;
    return $self->lookup("parent_phase_id = $parent_id ".
        " and child_battery_id = '$child_id' ");
}

######################################################

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

