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


package TUSK::ClassMeeting::Type;

=head1 NAME

B<TUSK::ClassMeeting::Type> - Class for manipulating entries in table class_meeting_type in tusk database

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

use TUSK::Core::School;
use HSDB45::ClassMeeting;


sub new {
    # Find out what class we are
    my $class = shift;
    $class = ref $class || $class;
    # Call the super-class's constructor and give it all the values
    my $self = $class->SUPER::new ( 
				    _datainfo => {
					'database' => 'tusk',
					'tablename' => 'class_meeting_type',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'class_meeting_type_id' => 'pk',
					'school_id' => '',
					'label' => '',
					'curriculum_method_enum_id' => '',
					'code' => '',
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

=item B<getSchoolID>

my $string = $obj->getSchoolID();

Get the value of the school_id field

=cut

sub getSchoolID{
    my ($self) = @_;
    return $self->getFieldValue('school_id');
}

#######################################################

=item B<setSchoolID>

$obj->setSchoolID($value);

Set the value of the school_id field

=cut

sub setSchoolID{
    my ($self, $value) = @_;
    $self->setFieldValue('school_id', $value);
}


#######################################################

=item B<getLabel>

my $string = $obj->getLabel();

Get the value of the label field

=cut

sub getLabel{
    my ($self) = @_;
    return $self->getFieldValue('label');
}

#######################################################

=item B<setLabel>

$obj->setLabel($value);

Set the value of the label field

=cut

sub setLabel{
    my ($self, $value) = @_;
    $self->setFieldValue('label', $value);
}


#######################################################

=item B<getCurriculumMethodEnumID>

my $string = $obj->getCurriculumMethodEnumID();

Get the value of the curriculum_method_enum_id field

=cut

sub getCurriculumMethodEnumID{
    my ($self) = @_;
    return $self->getFieldValue('curriculum_method_enum_id');
}

#######################################################

=item B<setCurriculumMethodEnumID>

$obj->setCurriculumMethodEnumID($value);

Set the value of the curriculum_method_enum_id field

=cut

sub setCurriculumMethodEnumID{
    my ($self, $value) = @_;
    $self->setFieldValue('curriculum_method_enum_id', $value);
}



#######################################################

=item B<getCode>

my $string = $obj->getCode();

Get the value of the code field

=cut

sub getCode{
    my ($self) = @_;
    return $self->getFieldValue('code');
}

#######################################################

=item B<setCode>

$obj->setCode($value);

Set the value of the code field

=cut

sub setCode{
    my ($self, $value) = @_;
    $self->setFieldValue('code', $value);
}


=back

=cut

### Other Methods


#######################################################

=item B<getSchoolTypes>

$obj->getSchoolTypes($school_id);

Get the class_meeting_type records, returned in alpha 
order provided a school id.

=cut

sub getSchoolTypes {
    my ($class, $id) = @_;
    return $class->lookup("school_id=$id", ['label ASC'], undef, undef, [
	 TUSK::Core::JoinObject->new('TUSK::Enum::Data', {
	     origkey => 'curriculum_method_enum_id',
	     joinkey => 'enum_data_id',
	 }),
    ]);
}


#######################################################

=item B<getCurriculumMethodDisplayName>

$obj->getCurriculumMethodDisplayName($school_id);

Return a display name of curriculum method

=cut

sub getCurriculumMethodDisplayName {
    my $self = shift;
    if (my $method = $self->getJoinObject('TUSK::Enum::Data')) {
	return $method->getDisplayName();
    }
    return '';
}


#######################################################

=item B<hasLinkedMeetings>

$obj->hasLinkedMeetings();

Given the class_meeting_type, see if there are any
meetings of that type.

=cut

sub hasLinkedMeetings {
	my ($self) = @_;

	my $school = TUSK::Core::School->new()->lookupKey($self->getSchoolID());
	my $meeting_count = HSDB45::ClassMeeting->new(_school => $school->getSchoolName())->lookup_conditions('type_id=' . $self->getPrimaryKeyID());

	return $meeting_count;
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

