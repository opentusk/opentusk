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


package TUSK::Core::SectionMeeting;

=head1 NAME

B<TUSK::Core::SectionMeeting> - Class for manipulating entries in table section_meeting in tusk database

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
					'tablename' => 'section_meeting',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'section_meeting_id' => 'pk',
					'section_id' => '',
					'meeting_type_id' => '',
					'label' => '',
					'meeting_date' => '',
					'starttime' => '',
					'endtime' => '',
					'location' => '',
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

=item B<getSectionID>

    $string = $obj->getSectionID();

    Get the value of the section_id field

=cut

sub getSectionID{
    my ($self) = @_;
    return $self->getFieldValue('section_id');
}

#######################################################

=item B<setSectionID>

    $string = $obj->setSectionID($value);

    Set the value of the section_id field

=cut

sub setSectionID{
    my ($self, $value) = @_;
    $self->setFieldValue('section_id', $value);
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

=item B<getMeetingDate>

    $string = $obj->getMeetingDate();

    Get the value of the meeting_date field

=cut

sub getMeetingDate{
    my ($self) = @_;
    return $self->getFieldValue('meeting_date');
}

#######################################################

=item B<setMeetingDate>

    $string = $obj->setMeetingDate($value);

    Set the value of the meeting_date field

=cut

sub setMeetingDate{
    my ($self, $value) = @_;
    $self->setFieldValue('meeting_date', $value);
}


#######################################################

=item B<getStarttime>

    $string = $obj->getStarttime();

    Get the value of the starttime field

=cut

sub getStarttime{
    my ($self) = @_;
    return $self->getFieldValue('starttime');
}

#######################################################

=item B<setStarttime>

    $string = $obj->setStarttime($value);

    Set the value of the starttime field

=cut

sub setStarttime{
    my ($self, $value) = @_;
    $self->setFieldValue('starttime', $value);
}


#######################################################

=item B<getEndtime>

    $string = $obj->getEndtime();

    Get the value of the endtime field

=cut

sub getEndtime{
    my ($self) = @_;
    return $self->getFieldValue('endtime');
}

#######################################################

=item B<setEndtime>

    $string = $obj->setEndtime($value);

    Set the value of the endtime field

=cut

sub setEndtime{
    my ($self, $value) = @_;
    $self->setFieldValue('endtime', $value);
}


#######################################################

=item B<getLocation>

    $string = $obj->getLocation();

    Get the value of the location field

=cut

sub getLocation{
    my ($self) = @_;
    return $self->getFieldValue('location');
}

#######################################################

=item B<setLocation>

    $string = $obj->setLocation($value);

    Set the value of the location field

=cut

sub setLocation{
    my ($self, $value) = @_;
    $self->setFieldValue('location', $value);
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

