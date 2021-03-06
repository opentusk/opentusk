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


package TUSK::ClassMeeting::Group;

=head1 NAME

B<TUSK::ClassMeeting::Group> - Class for manipulating entries in table class_meeting_group in tusk database

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
					'tablename' => 'class_meeting_group',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'class_meeting_group_id' => 'pk',
					'class_meeting_id1' => '',
					'class_meeting_id2' => '',
					'school_id' => '',
				    },
				    _attributes => {
					save_history => 1,
					tracking_fields => 1,	
					no_created => 1,
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

=item B<getClassMeetingId1>

my $string = $obj->getClassMeetingId1();

Get the value of the class_meeting_id1 field

=cut

sub getClassMeetingId1{
    my ($self) = @_;
    return $self->getFieldValue('class_meeting_id1');
}

#######################################################

=item B<setClassMeetingId1>

$obj->setClassMeetingId1($value);

Set the value of the class_meeting_id1 field

=cut

sub setClassMeetingId1{
    my ($self, $value) = @_;
    $self->setFieldValue('class_meeting_id1', $value);
}


#######################################################

=item B<getClassMeetingId2>

my $string = $obj->getClassMeetingId2();

Get the value of the class_meeting_id2 field

=cut

sub getClassMeetingId2{
    my ($self) = @_;
    return $self->getFieldValue('class_meeting_id2');
}

#######################################################

=item B<setClassMeetingId2>

$obj->setClassMeetingId2($value);

Set the value of the class_meeting_id2 field

=cut

sub setClassMeetingId2{
    my ($self, $value) = @_;
    $self->setFieldValue('class_meeting_id2', $value);
}


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

