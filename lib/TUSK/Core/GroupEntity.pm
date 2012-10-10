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


package TUSK::Core::GroupEntity;

=head1 NAME

B<TUSK::Core::GroupEntity> - Class for manipulating entries in table group_entity in tusk database

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
    require TUSK::Core::Offering;
    require TUSK::Core::TimePeriod;

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
					'tablename' => 'group_entity',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'group_entity_id' => 'pk',
					'school_id' => '',
					'group_entity_type_id' => '',
					'label' => '',
					'short_label' => '',
					'description' => '',
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
						    TUSK::Core::JoinObject->new("TUSK::Core::School"), 
						    TUSK::Core::JoinObject->new("TUSK::Core::GroupEntityType"), 
						    ],

				    @_
				  );
    # Finish initialization...
    return $self;
}

### Get/Set methods

#######################################################

=item B<getSchoolID>

    $string = $obj->getSchoolID();

    Get the value of the school_id field

=cut

sub getSchoolID{
    my ($self) = @_;
    return $self->getFieldValue('school_id');
}

#######################################################

=item B<setSchoolID>

    $string = $obj->setSchoolID($value);

    Set the value of the school_id field

=cut

sub setSchoolID{
    my ($self, $value) = @_;
    $self->setFieldValue('school_id', $value);
}


#######################################################

=item B<getGroupEntityTypeID>

    $string = $obj->getGroupEntityTypeID();

    Get the value of the group_entity_type_id field

=cut

sub getGroupEntityTypeID{
    my ($self) = @_;
    return $self->getFieldValue('group_entity_type_id');
}

#######################################################

=item B<setGroupEntityTypeID>

    $string = $obj->setGroupEntityTypeID($value);

    Set the value of the group_entity_type_id field

=cut

sub setGroupEntityTypeID{
    my ($self, $value) = @_;
    $self->setFieldValue('group_entity_type_id', $value);
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

=item B<getCode>

    $string = $obj->getCode();

    Get the value of the code field

=cut

sub getCode{
    my ($self) = @_;
    return $self->getFieldValue('code');
}

#######################################################

=item B<setCode>

    $string = $obj->setCode($value);

    Set the value of the code field

=cut

sub setCode{
    my ($self, $value) = @_;
    $self->setFieldValue('code', $value);
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

=back

=cut

#######################################################

=item B<getSchoolName>

    $string = $obj->getSchoolName();

    Get the value of the school name joined field

=cut

sub getSchoolName{
    my ($self) = @_;
    return $self->getJoinValue('school', 'school_name');
}

=back

=cut

#######################################################

=item B<getGroupEntityTypeLabel>

    $string = $obj->getGroupEntityTypeLabel();

    Get the value of the label joined field

=cut

sub getGroupEntityTypeLabel{
    my ($self) = @_;
    return $self->getJoinValue('group_entity_type', 'label');
}

=back

=cut

### Other Methods

#######################################################

=item B<getLatestOffering>

    $offering_ref = $obj->getLatestOffering();

    Get the latest offering object from this GroupEntity. Returns a blessed offering.

=cut

sub getLatestOffering {
    my ($self) = @_;
    my $latest = $self->getAllOfferings([ "time_period.start_date desc" ], 1);
    return $$latest[0];
}

#######################################################

=item B<getAllOfferings>

    $offering_ref = $obj->getAllOfferings();

    Get all offerings for this GroupEntity.

=cut

sub getAllOfferings {
    my ($self, $orderby, $limit) = @_;
    $orderby = ["time_period.start_date"] unless ($orderby);
    return TUSK::Core::Offering->new->passValues($self)->lookup("offering.group_entity_id = " . $self->getPrimaryKeyID, $orderby, undef, $limit);
}

#######################################################

=item B<getOfferingsOnDate>

    $array_ref = $obj->getOfferingOnDate($mysql_date);

    Get the offering objects from this GroupEntity for a specific date. Returns a blessed offering.

=cut

sub getOfferingsOnDate {
    my ($self,$date) = @_;
    my $offering = TUSK::Core::Offering->new->passValues($self);
    return $offering->lookupJoin(TUSK::Core::TimePeriod->new->passValues($self),
				 "start_date < '$date' ".
				 "and end_date > '$date' ".
				 "and offering.time_period_id = time_period.time_period_id ".
				 "and group_entity_id = ".$self->getPrimaryKeyID);
}

#######################################################

=item B<getSchool>

    $school_ref = $obj->getSchool();

    Get the School object for this GroupEntity.

=cut

sub getSchool {
    my ($self) = @_;
    my $school = TUSK::Core::School->new->passValues($self);
    return $school->lookupKey($self->getSchoolID);
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

