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


package TUSK::Academic::LevelClinicalSchedule;

=head1 NAME

B<TUSK::Academic::LevelClinicalSchedule> - Class for manipulating entries in table academic_level_clinical_schedule in tusk database

=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 INTERFACE


=head2 GET/SET METHODS

=over 4

=cut

use strict;

use TUSK::Academic::Level;
use TUSK::Course::AcademicLevel;
use TUSK::Core::HSDB45Tables::LinkCourseStudent;
use TUSK::Core::HSDB45Tables::Course;
use TUSK::Core::JoinObject;
use Time::Local;
use TUSK::Core::School;

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
					'tablename' => 'academic_level_clinical_schedule',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'academic_level_clinical_schedule_id' => 'pk',
					'academic_level_id' => '',
					'school_id' => '',
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

=item B<getAcademicLevelID>

my $string = $obj->getAcademicLevelID();

Get the value of the academic_level_id field

=cut

sub getAcademicLevelID{
    my ($self) = @_;
    return $self->getFieldValue('academic_level_id');
}

#######################################################

=item B<setAcademicLevelID>

$obj->setAcademicLevelID($value);

Set the value of the academic_level_id field

=cut

sub setAcademicLevelID{
    my ($self, $value) = @_;
    $self->setFieldValue('academic_level_id', $value);
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

### Get Rotations

#######################################################
sub getRotations{
	my ($self, $school_id, $school_db, $user_id) = @_;
	my $academicLevelClinicalScheduleCourses = TUSK::Academic::LevelClinicalSchedule->new();

    $academicLevelClinicalScheduleCourses->setDatabase(TUSK::Academic::LevelClinicalSchedule->new()->getDatabase());
    my $rotations = $academicLevelClinicalScheduleCourses->lookup( "", undef, undef, undef,
      [
        TUSK::Core::JoinObject->new('TUSK::Academic::Level',
          {
            joinkey => 'academic_level_id', origkey => 'academic_level_id', jointype => 'inner', database => TUSK::Academic::Level->new()->getDatabase(), alias => 't2',
            joincond => "t2.school_id = '$school_id'"
          }
        ),
        TUSK::Core::JoinObject->new('TUSK::Course::AcademicLevel',
          {
            joinkey => 'academic_level_id', origkey => 'academic_level_id', jointype => 'inner', database => TUSK::Course::AcademicLevel->new()->getDatabase(), alias => 't3',
            joincond => 't3.academic_level_id = t2.academic_level_id'
          }
        ),
        TUSK::Core::JoinObject->new('TUSK::Course',
          {
            joinkey => 'course_id', origkey => 't3.course_id', jointype => 'inner', database => TUSK::Course->new()->getDatabase(), alias => 't4'
          }
        ),
        TUSK::Core::JoinObject->new('TUSK::Core::HSDB45Tables::LinkCourseStudent',
          {
            joinkey => 'parent_course_id', origkey => 't4.school_course_code', jointype => 'inner', database => $school_db, alias => 't5',
            joincond => "t5.child_user_id = '$user_id'"
          }
        ),
        TUSK::Core::JoinObject->new('TUSK::Core::HSDB45Tables::Course',
          {
            joinkey => 'course_id', origkey => 't5.parent_course_id', jointype => 'inner', database => $school_db, alias => 't6',
            joincond => 't6.course_id = t4.school_course_code'
          }
        ),
        TUSK::Core::JoinObject->new('TUSK::Core::HSDB45Tables::TimePeriod',
          {
            joinkey => 'time_period_id', origkey => 't5.time_period_id', jointype => 'inner', database => $school_db, alias => 't7',
          }
        ),
        TUSK::Core::JoinObject->new('TUSK::Core::HSDB45Tables::TeachingSite',
          {
            joinkey => 'teaching_site_id', origkey => 't5.teaching_site_id', jointype => 'inner', database => $school_db, alias => 't8',
          }
        ),
      ]
   );

   return $rotations;
}

#######################################################

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

