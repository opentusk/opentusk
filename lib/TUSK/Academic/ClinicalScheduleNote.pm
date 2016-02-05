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


package TUSK::Academic::ClinicalScheduleNote;

=head1 NAME

B<TUSK::Academic::ClinicalScheduleNote> - Class for manipulating entries in table clinical_schedule_note in tusk database

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
					'tablename' => 'clinical_schedule_note',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'clinical_schedule_note_id' => 'pk',
					'clinical_schedule_note' => '',
					'user_id' => '',
					'course_id' => '',
					'time_period_id' => '',
					'teaching_site_id' => '',
				    },
				    _attributes => {
					save_history => 0,
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

=item B<getClinicalScheduleNote>

my $string = $obj->getClinicalScheduleNote();

Get the value of the clinical_schedule_note field

=cut

sub getClinicalScheduleNote{
    my ($self) = @_;
    return $self->getFieldValue('clinical_schedule_note');
}

#######################################################

=item B<setClinicalScheduleNote>

$obj->setClinicalScheduleNote($value);

Set the value of the clinical_schedule_note field

=cut

sub setClinicalScheduleNote{
    my ($self, $value) = @_;
    $self->setFieldValue('clinical_schedule_note', $value);
}


#######################################################

=item B<getUserID>

my $string = $obj->getUserID();

Get the value of the user_id field

=cut

sub getUserID{
    my ($self) = @_;
    return $self->getFieldValue('user_id');
}

#######################################################

=item B<setUserID>

$obj->setUserID($value);

Set the value of the user_id field

=cut

sub setUserID{
    my ($self, $value) = @_;
    $self->setFieldValue('user_id', $value);
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

=item B<getTimePeriodID>

my $string = $obj->getTimePeriodID();

Get the value of the time_period_id field

=cut

sub getTimePeriodID{
    my ($self) = @_;
    return $self->getFieldValue('time_period_id');
}

#######################################################

=item B<setTimePeriodID>

$obj->setTimePeriodID($value);

Set the value of the time_period_id field

=cut

sub setTimePeriodID{
    my ($self, $value) = @_;
    $self->setFieldValue('time_period_id', $value);
}


#######################################################

=item B<getTeachingSiteID>

my $string = $obj->getTeachingSiteID();

Get the value of the teaching_site_id field

=cut

sub getTeachingSiteID{
    my ($self) = @_;
    return $self->getFieldValue('teaching_site_id');
}

#######################################################

=item B<setTeachingSiteID>

$obj->setTeachingSiteID($value);

Set the value of the teaching_site_id field

=cut

sub setTeachingSiteID{
    my ($self, $value) = @_;
    $self->setFieldValue('teaching_site_id', $value);
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

