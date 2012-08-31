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


package TUSK::Core::Section;

=head1 NAME

B<TUSK::Core::Section> - Class for manipulating entries in table section in tusk database

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
use TUSK::Core::User;
use TUSK::Core::LinkUserSection;
use TUSK::Core::SectionMeeting;
use TUSK::Core::Offering;
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
					'tablename' => 'section',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'section_id' => 'pk',
					'offering_id' => '',
					'meeting_type_id' => '',
					'teaching_site_id' => '',
					'number' => '',
					'label' => '',
					'short_label' => '',
					'description' => '',
					'body' => '',
					'schedule_color' => '',
					'schedule_flag_time' => '',
				    },
				    _attributes => {
					save_history => 0,
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

=item B<getOfferingID>

    $string = $obj->getOfferingID();

    Get the value of the offering_id field

=cut

sub getOfferingID{
    my ($self) = @_;
    return $self->getFieldValue('offering_id');
}

#######################################################

=item B<setOfferingID>

    $string = $obj->setOfferingID($value);

    Set the value of the offering_id field

=cut

sub setOfferingID{
    my ($self, $value) = @_;
    $self->setFieldValue('offering_id', $value);
}


#######################################################

=item B<getMeetingTypeID>

    $string = $obj->getMeetingTypeID();

    Get the value of the meeting_type_id field

=cut

sub getMeetingTypeID{
    my ($self) = @_;
    return $self->getFieldValue('meeting_type_id');
}

#######################################################

=item B<setMeetingTypeID>

    $string = $obj->setMeetingTypeID($value);

    Set the value of the meeting_type_id field

=cut

sub setMeetingTypeID{
    my ($self, $value) = @_;
    $self->setFieldValue('meeting_type_id', $value);
}


#######################################################

=item B<getTeachingSiteID>

    $string = $obj->getTeachingSiteID();

    Get the value of the teaching_site_id field

=cut

sub getTeachingSiteID{
    my ($self) = @_;
    return $self->getFieldValue('teaching_site_id');
}

#######################################################

=item B<setTeachingSiteID>

    $string = $obj->setTeachingSiteID($value);

    Set the value of the teaching_site_id field

=cut

sub setTeachingSiteID{
    my ($self, $value) = @_;
    $self->setFieldValue('teaching_site_id', $value);
}


#######################################################

=item B<getNumber>

    $string = $obj->getNumber();

    Get the value of the number field

=cut

sub getNumber{
    my ($self) = @_;
    return $self->getFieldValue('number');
}

#######################################################

=item B<setNumber>

    $string = $obj->setNumber($value);

    Set the value of the number field

=cut

sub setNumber{
    my ($self, $value) = @_;
    $self->setFieldValue('number', $value);
}


#######################################################

=item B<getLabel>

    $string = $obj->getLabel();

    Get the value of the label field

=cut

sub getLabel{
    my ($self) = @_;
    return $self->getFieldValue('label');
}

#######################################################

=item B<setLabel>

    $string = $obj->setLabel($value);

    Set the value of the label field

=cut

sub setLabel{
    my ($self, $value) = @_;
    $self->setFieldValue('label', $value);
}


#######################################################

=item B<getShortLabel>

    $string = $obj->getShortLabel();

    Get the value of the short_label field

=cut

sub getShortLabel{
    my ($self) = @_;
    return $self->getFieldValue('short_label');
}

#######################################################

=item B<setShortLabel>

    $string = $obj->setShortLabel($value);

    Set the value of the short_label field

=cut

sub setShortLabel{
    my ($self, $value) = @_;
    $self->setFieldValue('short_label', $value);
}


#######################################################

=item B<getDescription>

    $string = $obj->getDescription();

    Get the value of the description field

=cut

sub getDescription{
    my ($self) = @_;
    return $self->getFieldValue('description');
}

#######################################################

=item B<setDescription>

    $string = $obj->setDescription($value);

    Set the value of the description field

=cut

sub setDescription{
    my ($self, $value) = @_;
    $self->setFieldValue('description', $value);
}


#######################################################

=item B<getBody>

    $string = $obj->getBody();

    Get the value of the body field

=cut

sub getBody{
    my ($self) = @_;
    return $self->getFieldValue('body');
}

#######################################################

=item B<setBody>

    $string = $obj->setBody($value);

    Set the value of the body field

=cut

sub setBody{
    my ($self, $value) = @_;
    $self->setFieldValue('body', $value);
}


#######################################################

=item B<getScheduleColor>

    $string = $obj->getScheduleColor();

    Get the value of the schedule_color field

=cut

sub getScheduleColor{
    my ($self) = @_;
    return $self->getFieldValue('schedule_color');
}

#######################################################

=item B<setScheduleColor>

    $string = $obj->setScheduleColor($value);

    Set the value of the schedule_color field

=cut

sub setScheduleColor{
    my ($self, $value) = @_;
    $self->setFieldValue('schedule_color', $value);
}


#######################################################

=item B<getScheduleFlagTime>

    $string = $obj->getScheduleFlagTime();

    Get the value of the schedule_flag_time field

=cut

sub getScheduleFlagTime{
    my ($self) = @_;
    return $self->getFieldValue('schedule_flag_time');
}

#######################################################

=item B<setScheduleFlagTime>

    $string = $obj->setScheduleFlagTime($value);

    Set the value of the schedule_flag_time field

=cut

sub setScheduleFlagTime{
    my ($self, $value) = @_;
    $self->setFieldValue('schedule_flag_time', $value);
}



=back

=cut

### Other Methods

#######################################################

=item B<getOffering>

    $obj = $obj->getOffering();

    Gets the Offering object for this section. Returns an object.

=cut

sub getOffering {
    my ($self) = @_;
    my $offering = TUSK::Core::Offering->new->passValues($self);
    return $offering->lookupKey($self->getOfferingID);
}

#######################################################

=item B<getSectionMeetings>

    $arrayref = $obj->getSectionMeetings();

    Gets all SectionMeeting objects for this section. Returns an arrayref.

=cut

sub getSectionMeetings {
    my ($self) = @_;
    my $meeting = TUSK::Core::SectionMeeting->new;
    return $meeting->lookup("section_id = ".$self->getPrimaryKeyID,["meeting_date","starttime"]);
}

#######################################################

=item B<getUsersWithRole>

    $obj = $obj->getUsersWithRole();

    Gets the User objects for this section, joined with their Role object. Returns an arrayref to li
st of User objects.

=cut

sub getUsersWithRole {
    my ($self) = @_;
    return  TUSK::Core::LinkUserOffering->new->passValues($self)->lookup("link_user_offering.offering_id= ".$self->getPrimaryKeyID , ["link_user_offering.sort_order"]); 
}

#######################################################

=item B<addUserRole>

    $string = $obj->addUserRole($user_id,$role_id,$sort_order);

    Link a user to this Section with a specific role.

=cut

sub addUserRole {
    my ($self, $user_id, $role_id, $sort_order) = @_;
    my $link_object = TUSK::Core::LinkUserSection->new->passValues($self); 
    $link_object->setFieldValues({"section_id" => $self->getPrimaryKeyID,
				  "user_id" => $user_id,
				  "role_id" => $role_id,
				  "sort_order" => $sort_order,
			      });
    $link_object->save;
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

