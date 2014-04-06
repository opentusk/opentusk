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


package TUSK::Course;

=head1 NAME

B<TUSK::Course> - Class for manipulating entries in table course in tusk database

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
#use TUSK::CourseMetadata;

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
					'tablename' => 'course',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'course_id' => 'pk',
					'school_id' => '',
					'school_course_code' => '',
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

=item B<getSchoolCourseCode>

my $string = $obj->getSchoolCourseCode();

Get the value of the school_course_code field

=cut

sub getSchoolCourseCode{
    my ($self) = @_;
    return $self->getFieldValue('school_course_code');
}

#######################################################

=item B<setSchoolCourseCode>

$obj->setSchoolCourseCode($value);

Set the value of the school_course_code field

=cut

sub setSchoolCourseCode{
    my ($self, $value) = @_;
    $self->setFieldValue('school_course_code', $value);
}

#######################################################

=item B<getHSDB45CourseFromTuskID>

HSDB45::Course = $obj->getHSDB45CourseFromTuskID();

Get the HSDB45::Course from a TUSK::Course

=cut

sub getHSDB45CourseFromTuskID{
    my ($self) = @_;
    my $school = TUSK::Core::School->lookupKey( $self->getSchoolID() );
    my $hsdb45Course = HSDB45::Course->new( _school => $school->getSchoolName() )->lookup_key( $self->getSchoolCourseCode() );
    return $hsdb45Course;
}



#######################################################

=item B<getTuskCourseIDFromSchoolID>

my $string = $obj->getTuskCourseIDFromSchoolID();

Get the unique ID (tusk course ID) if you have the id for the school and the course.
In HSDB45 we used two keys for a course: school and course. In TUSK we use a unique key for all courses.
This method is used to convert the old school/course to the new tusk id.

=cut

sub getTuskCourseIDFromSchoolID {
    my ($self, $school_id, $course_id) = @_;
    my $searchResultsRef = $self->lookup("school_id=$school_id AND school_course_code=$course_id", undef, undef, undef, undef);
    return ${$searchResultsRef}[0]->getPrimaryKeyID();
}



=back

=cut

sub getCompetenciesByCourse{    
    #returns all competencies associated with a course, given the course's tusk_course_id

    my ( $lib, $course_id ) = @_;

    my $course_competencies = TUSK::Competency::Competency->lookup( 'competency_course.course_id ='. $course_id, 
								    [ 'competency_id', 'description'] , undef, undef,
								    [ TUSK::Core::JoinObject->new( 'TUSK::Competency::Course', 
												   { origkey=> 'competency_id', joinkey => 'competency_id', jointype => 'inner'})]);	

    return $course_competencies;

}


sub getTopLevelCompetenciesByCourse{    
    #returns all competencies associated with a course, given the course's tusk_course_id

    my ( $lib, $course_id ) = @_;

    my $course_competencies = TUSK::Competency::Competency->lookup('competency_course.course_id ='. $course_id, 
								    ['competency_id', 'description'] , undef, undef,
								    [TUSK::Core::JoinObject->new('TUSK::Competency::Course', 
												   { origkey => 'competency_id', joinkey => 'competency_id', jointype => 'inner'}),
								    TUSK::Core::JoinObject->new('TUSK::Competency::Hierarchy',
												{ origkey => 'competency_id', joinkey => 'child_competency_id', jointype => 'inner', joincond => 'parent_competency_id=0'})
								    ]);	

    return $course_competencies;

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

