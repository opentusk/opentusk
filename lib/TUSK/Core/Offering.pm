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


package TUSK::Core::Offering;

=head1 NAME

B<TUSK::Core::Offering> - Class for manipulating entries in table offering in tusk database

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
use TUSK::Core::LinkUserOffering;
use TUSK::Core::TimePeriod;
use TUSK::Core::GroupEntity;
use TUSK::Core::Role;

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
					'tablename' => 'offering',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'offering_id' => 'pk',
					'group_entity_id' => '',
					'time_period_id' => '',
				    },
				    _attributes => {
					save_history => 0,
					tracking_fields => 1,	
				    },
				    _levels => {
					reporting => 'cluck',
					error => 0,
				    },
				    _default_join_objects => [
						      TUSK::Core::JoinObject->new("TUSK::Core::TimePeriod"),
						      ],
				    @_
				  );
    # Finish initialization...
    return $self;
}

### Get/Set methods

#######################################################

=item B<getGroupEntityID>

    $string = $obj->getGroupEntityID();

    Get the value of the group_entity_id field

=cut

sub getGroupEntityID{
    my ($self) = @_;
    return $self->getFieldValue('group_entity_id');
}

#######################################################

=item B<setGroupEntityID>

    $string = $obj->setGroupEntityID($value);

    Set the value of the group_entity_id field

=cut

sub setGroupEntityID{
    my ($self, $value) = @_;
    $self->setFieldValue('group_entity_id', $value);
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

    $string = $obj->setTimePeriodID($value);

    Set the value of the time_period_id field

=cut

sub setTimePeriodID{
    my ($self, $value) = @_;
    $self->setFieldValue('time_period_id', $value);
}

=back

=cut

#######################################################

=item B<getTimePeriodObject>

    $obj = $obj->getTimePeriodObject();

    Get the TUSK::Core::TimePeriod object linked to this object

=cut

sub getTimePeriodObject{
    my ($self) = @_;
    return $self->getJoinObject("TUSK::Core::TimePeriod");
}

=back

=cut


### Other Methods

#######################################################

=item B<getUsersWithRole>

    $obj = $obj->getUsersWithRole();

    Gets the User objects for this offering, joined with the Link and Role object. Returns an arrayref to list of User objects.

=cut

sub getUsersWithRole {
    my ($self) = @_;
    return  TUSK::Core::LinkUserOffering->new->passValues($self)->lookup("link_user_offering.offering_id= ".$self->getPrimaryKeyID , ["link_user_offering.sort_order"]);
}

#######################################################

=item B<addUserRole>

    $obj->addUserRole($user_id,$role_id,$sort_order);

    Link a user to this Offering with a specific role.

=cut

sub addUserRole {
    my ($self, $user_id, $role_id, $sort_order) = @_;
    my $link_object = TUSK::Core::LinkUserOffering->new->passValues($self); 
    $link_object->setFieldValues({"offering_id" => $self->getPrimaryKeyID,
				  "user_id" => $user_id,
				  "role_id" => $role_id,
				  "sort_order" => $sort_order,
			      });
    $link_object->save;
}

#######################################################

=item B<getGroupEntity>

    $obj = $obj->getGroupEntity();

    Get the GroupEntity object for this offering.

=cut

sub getGroupEntity{
    my ($self) = @_;
    my $group_entity = TUSK::Core::GroupEntity->new()->passValues($self);
    return $group_entity->lookupKey($self->getGroupEntityID);
}

#######################################################

=item B<getSections>

    $arrayref = $obj->getSections();

    Get Section objects for this offering. Returns an arrayref.

=cut

sub getSections{
    my ($self) = @_;
    my $section = TUSK::Core::Section->new()->passValues($self);
    return $section->lookup("offering_id = ".$self->getPrimaryKeyID);
}

#######################################################

=item B<getSectionsWithType>

    $arrayref = $obj->getSections();

    Get Section objects for this offering, with included Type object. Returns an arrayref.

=cut

sub getSectionsWithType {
    my ($self) = @_;
    my $section = TUSK::Core::Section->new()->passValues($self);
    return $section->lookupJoin(TUSK::Core::MeetingType->new->passValues($self),
				"section.meeting_type_id = meeting_type.meeting_type_id ".
				"and offering_id = ".$self->getPrimaryKeyID);
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

