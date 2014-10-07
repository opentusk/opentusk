# Copyright 2013 Tufts University
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


package TUSK::Core::HSDB45Tables::ClassMeeting;

=head1 NAME

B<TUSK::Core::HSDB45Tables::ClassMeeting> - Class for manipulating entries in table class_meeting in hsdb45 database

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
					'database' => '',
					'tablename' => 'class_meeting',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'class_meeting_id' => 'pk',
					'title' => '',
					'oea_code' => '',
					'course_id' => '',
					'type_id' => '',
					'meeting_date' => '',
					'starttime' => '',
					'endtime' => '',
					'location' => '',
					'is_duplicate' => '',
					'is_mandatory' => '',
					'modified' => '',
					'flagtime' => '',
					'body' => '',
				    },
				    _attributes => {
					save_history => 0,
					tracking_fields => 0,	
					no_created => 0,
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

=item B<getTitle>

my $string = $obj->getTitle();

Get the value of the title field

=cut

sub getTitle{
    my ($self) = @_;
    return $self->getFieldValue('title');
}

#######################################################

=item B<setTitle>

$obj->setTitle($value);

Set the value of the title field

=cut

sub setTitle{
    my ($self, $value) = @_;
    $self->setFieldValue('title', $value);
}


#######################################################

=item B<getOeaCode>

my $string = $obj->getOeaCode();

Get the value of the oea_code field

=cut

sub getOeaCode{
    my ($self) = @_;
    return $self->getFieldValue('oea_code');
}

#######################################################

=item B<setOeaCode>

$obj->setOeaCode($value);

Set the value of the oea_code field

=cut

sub setOeaCode{
    my ($self, $value) = @_;
    $self->setFieldValue('oea_code', $value);
}


#######################################################

=item B<getCourseID>

my $string = $obj->getCourseID();

Get the value of the course_id field

=cut

sub getCourseID{
    my ($self) = @_;
    return $self->getFieldValue('course_id');
}

#######################################################

=item B<setCourseID>

$obj->setCourseID($value);

Set the value of the course_id field

=cut

sub setCourseID{
    my ($self, $value) = @_;
    $self->setFieldValue('course_id', $value);
}


#######################################################

=item B<getTypeID>

my $string = $obj->getTypeID();

Get the value of the type_id field

=cut

sub getTypeID{
    my ($self) = @_;
    return $self->getFieldValue('type_id');
}

#######################################################

=item B<setTypeID>

$obj->setTypeID($value);

Set the value of the type_id field

=cut

sub setTypeID{
    my ($self, $value) = @_;
    $self->setFieldValue('type_id', $value);
}


#######################################################

=item B<getMeetingDate>

my $string = $obj->getMeetingDate();

Get the value of the meeting_date field

=cut

sub getMeetingDate{
    my ($self) = @_;
    return $self->getFieldValue('meeting_date');
}

#######################################################

=item B<setMeetingDate>

$obj->setMeetingDate($value);

Set the value of the meeting_date field

=cut

sub setMeetingDate{
    my ($self, $value) = @_;
    $self->setFieldValue('meeting_date', $value);
}


#######################################################

=item B<getStarttime>

my $string = $obj->getStarttime();

Get the value of the starttime field

=cut

sub getStarttime{
    my ($self) = @_;
    return $self->getFieldValue('starttime');
}

#######################################################

=item B<setStarttime>

$obj->setStarttime($value);

Set the value of the starttime field

=cut

sub setStarttime{
    my ($self, $value) = @_;
    $self->setFieldValue('starttime', $value);
}


#######################################################

=item B<getEndtime>

my $string = $obj->getEndtime();

Get the value of the endtime field

=cut

sub getEndtime{
    my ($self) = @_;
    return $self->getFieldValue('endtime');
}

#######################################################

=item B<setEndtime>

$obj->setEndtime($value);

Set the value of the endtime field

=cut

sub setEndtime{
    my ($self, $value) = @_;
    $self->setFieldValue('endtime', $value);
}


#######################################################

=item B<getLocation>

my $string = $obj->getLocation();

Get the value of the location field

=cut

sub getLocation{
    my ($self) = @_;
    return $self->getFieldValue('location');
}

#######################################################

=item B<setLocation>

$obj->setLocation($value);

Set the value of the location field

=cut

sub setLocation{
    my ($self, $value) = @_;
    $self->setFieldValue('location', $value);
}


#######################################################

=item B<getIsDuplicate>

my $string = $obj->getIsDuplicate();

Get the value of the is_duplicate field

=cut

sub getIsDuplicate{
    my ($self) = @_;
    return $self->getFieldValue('is_duplicate');
}

#######################################################

=item B<setIsDuplicate>

$obj->setIsDuplicate($value);

Set the value of the is_duplicate field

=cut

sub setIsDuplicate{
    my ($self, $value) = @_;
    $self->setFieldValue('is_duplicate', $value);
}


#######################################################

=item B<getIsMandatory>

my $string = $obj->getIsMandatory();

Get the value of the is_mandatory field

=cut

sub getIsMandatory{
    my ($self) = @_;
    return $self->getFieldValue('is_mandatory');
}

#######################################################

=item B<setIsMandatory>

$obj->setIsMandatory($value);

Set the value of the is_mandatory field

=cut

sub setIsMandatory{
    my ($self, $value) = @_;
    $self->setFieldValue('is_mandatory', $value);
}


#######################################################

=item B<getModified>

my $string = $obj->getModified();

Get the value of the modified field

=cut

sub getModified{
    my ($self) = @_;
    return $self->getFieldValue('modified');
}

#######################################################

=item B<setModified>

$obj->setModified($value);

Set the value of the modified field

=cut

sub setModified{
    my ($self, $value) = @_;
    $self->setFieldValue('modified', $value);
}


#######################################################

=item B<getFlagtime>

my $string = $obj->getFlagtime();

Get the value of the flagtime field

=cut

sub getFlagtime{
    my ($self) = @_;
    return $self->getFieldValue('flagtime');
}

#######################################################

=item B<setFlagtime>

$obj->setFlagtime($value);

Set the value of the flagtime field

=cut

sub setFlagtime{
    my ($self, $value) = @_;
    $self->setFieldValue('flagtime', $value);
}


#######################################################

=item B<getBody>

my $string = $obj->getBody();

Get the value of the body field

=cut

sub getBody{
    my ($self) = @_;
    return $self->getFieldValue('body');
}

#######################################################

=item B<setBody>

$obj->setBody($value);

Set the value of the body field

=cut

sub setBody{
    my ($self, $value) = @_;
    $self->setFieldValue('body', $value);
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

Copyright (c) Tufts University Sciences Knowledgebase, 2013.

=cut

1;

