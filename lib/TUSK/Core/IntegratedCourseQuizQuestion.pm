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


package TUSK::Core::IntegratedCourseQuizQuestion;

=head1 NAME

B<TUSK::Core::IntegratedCourseQuizQuestion> - Class for manipulating entries in table integrated_course_quiz_question in tusk database

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
					'tablename' => 'integrated_course_quiz_question',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'integrated_course_quiz_question_id' => 'pk',
					'parent_integrated_course_id' => '',
					'child_quiz_question_id' => '',
					'originating_course_id' => '',
				    },
				    _attributes => {
					save_history => 0,
					tracking_fields => 1,	
				    },
				    _levels => {
					reporting => '-c',
					error => 0,
				    },
				    @_
				  );
    # Finish initialization...
    return $self;
}

### Get/Set methods

#######################################################

=item B<getParentIntegratedCourseID>

my $string = $obj->getParentIntegratedCourseID();

Get the value of the parent_integrated_course_id field

=cut

sub getParentIntegratedCourseID{
    my ($self) = @_;
    return $self->getFieldValue('parent_integrated_course_id');
}

#######################################################

=item B<setParentIntegratedCourseID>

$obj->setParentIntegratedCourseID($value);

Set the value of the parent_integrated_course_id field

=cut

sub setParentIntegratedCourseID{
    my ($self, $value) = @_;
    $self->setFieldValue('parent_integrated_course_id', $value);
}


#######################################################

=item B<getChildQuizQuestionID>

my $string = $obj->getChildQuizQuestionID();

Get the value of the child_quiz_question_id field

=cut

sub getChildQuizQuestionID{
    my ($self) = @_;
    return $self->getFieldValue('child_quiz_question_id');
}

#######################################################

=item B<setChildQuizQuestionID>

$obj->setChildQuizQuestionID($value);

Set the value of the child_quiz_question_id field

=cut

sub setChildQuizQuestionID{
    my ($self, $value) = @_;
    $self->setFieldValue('child_quiz_question_id', $value);
}


#######################################################

=item B<getOriginatingCourseID>

my $string = $obj->getOriginatingCourseID();

Get the value of the originating_course_id field

=cut

sub getOriginatingCourseID{
    my ($self) = @_;
    return $self->getFieldValue('originating_course_id');
}

#######################################################

=item B<setOriginatingCourseID>

$obj->setOriginatingCourseID($value);

Set the value of the originating_course_id field

=cut

sub setOriginatingCourseID{
    my ($self, $value) = @_;
    $self->setFieldValue('originating_course_id', $value);
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

