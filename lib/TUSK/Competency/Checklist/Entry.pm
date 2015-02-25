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


package TUSK::Competency::Checklist::Entry;

=head1 NAME

B<TUSK::Competency::Checklist::Entry> - Class for manipulating entries in table competency_checklist_entry in tusk database

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

use HSDB4::DateTime;

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
					'tablename' => 'competency_checklist_entry',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'competency_checklist_entry_id' => 'pk',
					'competency_checklist_id' => '',
					'competency_checklist_assignment_id' => '',
					'request_date' => '',
					'notify_date' => '',
					'complete_date' => '',
					'assessor_comment' => '',
					'student_comment' => '',
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

=item B<getCompetencyChecklistID>

my $string = $obj->getCompetencyChecklistID();

Get the value of the competency_checklist_id field

=cut

sub getCompetencyChecklistID{
    my ($self) = @_;
    return $self->getFieldValue('competency_checklist_id');
}

#######################################################

=item B<setCompetencyChecklistID>

$obj->setCompetencyChecklistID($value);

Set the value of the competency_checklist_id field

=cut

sub setCompetencyChecklistID{
    my ($self, $value) = @_;
    $self->setFieldValue('competency_checklist_id', $value);
}


#######################################################

=item B<getCompetencyChecklistAssignmentID>

my $string = $obj->getCompetencyChecklistAssignmentID();

Get the value of the competency_checklist_assignment_id field

=cut

sub getCompetencyChecklistAssignmentID{
    my ($self) = @_;
    return $self->getFieldValue('competency_checklist_assignment_id');
}

#######################################################

=item B<setCompetencyChecklistAssignmentID>

$obj->setCompetencyChecklistAssignmentID($value);

Set the value of the competency_checklist_assignment_id field

=cut

sub setCompetencyChecklistAssignmentID{
    my ($self, $value) = @_;
    $self->setFieldValue('competency_checklist_assignment_id', $value);
}


#######################################################

=item B<getRequestDate>

my $string = $obj->getRequestDate();

Get the value of the request_date field

=cut

sub getRequestDate{
    my ($self) = @_;
    return $self->getFieldValue('request_date');
}

#######################################################

=item B<setRequestDate>

$obj->setRequestDate($value);

Set the value of the request_date field

=cut

sub setRequestDate{
    my ($self, $value) = @_;
    $self->setFieldValue('request_date', $value);
}


#######################################################

=item B<getNotifyDate>

my $string = $obj->getNotifyDate();

Get the value of the notify_date field

=cut

sub getNotifyDate{
    my ($self) = @_;
    return $self->getFieldValue('notify_date');
}

#######################################################

=item B<setNotifyDate>

$obj->setNotifyDate($value);

Set the value of the notify_date field

=cut

sub setNotifyDate{
    my ($self, $value) = @_;
    $self->setFieldValue('notify_date', $value);
}


#######################################################

=item B<getCompleteDate>

my $string = $obj->getCompleteDate();

Get the value of the complete_date field

=cut

sub getCompleteDate{
    my ($self) = @_;
    return $self->getFieldValue('complete_date');
}

#######################################################

=item B<setCompleteDate>

$obj->setCompleteDate($value);

Set the value of the complete_date field

=cut

sub setCompleteDate{
    my ($self, $value) = @_;
    $self->setFieldValue('complete_date', $value);
}


#######################################################

=item B<getAssessorComment>

my $string = $obj->getAssessorComment();

Get the value of the assessor_comment field

=cut

sub getAssessorComment{
    my ($self) = @_;
    return $self->getFieldValue('assessor_comment');
}

#######################################################

=item B<setAssessorComment>

$obj->setAssessorComment($value);

Set the value of the assessor_comment field

=cut

sub setAssessorComment{
    my ($self, $value) = @_;
    $self->setFieldValue('assessor_comment', $value);
}


#######################################################

=item B<getStudentComment>

my $string = $obj->getStudentComment();

Get the value of the student_comment field

=cut

sub getStudentComment{
    my ($self) = @_;
    return $self->getFieldValue('student_comment');
}

#######################################################

=item B<setStudentComment>

$obj->setStudentComment($value);

Set the value of the student_comment field

=cut

sub setStudentComment{
    my ($self, $value) = @_;
    $self->setFieldValue('student_comment', $value);
}



=back

=cut

### Other Methods

sub getFormattedRequestDate {
    my $self = shift;
    return HSDB4::DateTime->new()->in_mysql_date($self->getFieldValue('request_date'))->out_string_date_short_year();
}

sub getFormattedNotifyDate {
    my $self = shift;
    return HSDB4::DateTime->new()->in_mysql_date($self->getFieldValue('notify_date'))->out_string_date_short_year();
}

sub getFormattedCompleteDate {
    my $self = shift;
    return HSDB4::DateTime->new()->in_mysql_date($self->getFieldValue('complete_date'))->out_string_date_short_year();
}

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

