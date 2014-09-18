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


package TUSK::Competency::Checklist::Assignment;

=head1 NAME

B<TUSK::Competency::Checklist::Assignment> - Class for manipulating entries in table competency_checklist_assignment in tusk database

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
					'tablename' => 'competency_checklist_assignment',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'competency_checklist_assignment_id' => 'pk',
					'competency_checklist_group_id' => '',
					'time_period_id' => '',
					'student_id' => '',
					'assessor_id' => '',
					'assessor_type_enum_id' => '',
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

=item B<getCompetencyChecklistGroupID>

my $string = $obj->getCompetencyChecklistGroupID();

Get the value of the competency_checklist_group_id field

=cut

sub getCompetencyChecklistGroupID{
    my ($self) = @_;
    return $self->getFieldValue('competency_checklist_group_id');
}

#######################################################

=item B<setCompetencyChecklistGroupID>

$obj->setCompetencyChecklistGroupID($value);

Set the value of the competency_checklist_group_id field

=cut

sub setCompetencyChecklistGroupID{
    my ($self, $value) = @_;
    $self->setFieldValue('competency_checklist_group_id', $value);
}


#######################################################

=item B<getTimePeriodID>

my $string = $obj->getTimePeriodID();

Get the value of the timeperiod_id field

=cut

sub getTimePeriodID{
    my ($self) = @_;
    return $self->getFieldValue('time_period_id');
}

#######################################################

=item B<setTimePeriodID>

$obj->setTimePeriodID($value);

Set the value of the timeperiod_id field

=cut

sub setTimePeriodID{
    my ($self, $value) = @_;
    $self->setFieldValue('time_period_id', $value);
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

=item B<getAssessorID>

my $string = $obj->getAssessorID();

Get the value of the assessor_id field

=cut

sub getAssessorID{
    my ($self) = @_;
    return $self->getFieldValue('assessor_id');
}

#######################################################

=item B<setAssessorID>

$obj->setAssessorID($value);

Set the value of the assessor_id field

=cut

sub setAssessorID{
    my ($self, $value) = @_;
    $self->setFieldValue('assessor_id', $value);
}


#######################################################

=item B<getAssessorTypeEnumID>

my $string = $obj->getAssessorTypeEnumID();

Get the value of the assessor_type_enum_id field

=cut

sub getAssessorTypeEnumID{
    my ($self) = @_;
    return $self->getFieldValue('assessor_type_enum_id');
}

#######################################################

=item B<setAssessorTypeEnumID>

$obj->setAssessorTypeEnumID($value);

Set the value of the assessor_type_enum_id field

=cut

sub setAssessorTypeEnumID{
    my ($self, $value) = @_;
    $self->setFieldValue('assessor_type_enum_id', $value);
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



=back

=cut

### Other Methods

=item
    Check if a checklist assignment type is of a given token
=cut
sub isAssignmentType {
    my ($self, $token) = @_;
    if (my $enum =  $self->getJoinObject('TUSK::Enum::Data')) {
	return  ($enum->getShortName() eq $token) ? 1 : 0;
    }
    return 0
}

=item
    Check if it is a self assignment
=cut
sub isSelfAssignment {
    my ($self, $user_id) = @_;
    return ($self->getStudentID() eq $user_id && $self->getAssessorID() eq $user_id) ? 1 : 0;
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

