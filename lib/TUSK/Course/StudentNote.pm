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


package TUSK::Course::StudentNote;

=head1 NAME

B<TUSK::Course::StudentNote> - Class for manipulating entries in table course_student_note in tusk database

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
					'tablename' => 'course_student_note',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'course_student_note_id' => 'pk',
					'course_id' => '',
					'student_id' => '',
					'date' => '',
					'note' => '',
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

=item B<getStudentID>

my $string = $obj->getStudentID();

Get the value of the student_id field

=cut

sub getStudentID{
    my ($self) = @_;
    return $self->getFieldValue('student_id');
}

#######################################################

=item B<setStudentID>

$obj->setStudentID($value);

Set the value of the student_id field

=cut

sub setStudentID{
    my ($self, $value) = @_;
    $self->setFieldValue('student_id', $value);
}


#######################################################

=item B<getDate>

my $string = $obj->getDate();

Get the value of the date field

=cut

sub getDate{
    my ($self) = @_;
    return $self->getFieldValue('date');
}

#######################################################

=item B<setDate>

$obj->setDate($value);

Set the value of the date field

=cut

sub setDate{
    my ($self, $value) = @_;
    $self->setFieldValue('date', $value);
}


#######################################################

=item B<getNote>

my $string = $obj->getNote();

Get the value of the note field

=cut

sub getNote{
    my ($self) = @_;
    return $self->getFieldValue('note');
}

#######################################################

=item B<setNote>

$obj->setNote($value);

Set the value of the note field

=cut

sub setNote{
    my ($self, $value) = @_;
    $self->setFieldValue('note', $value);
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

