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


package TUSK::Quiz::LinkCourseQuiz;

=head1 NAME

B<TUSK::Quiz::LinkCourseQuiz> - Class for manipulating entries in table link_course_quiz in tusk database

=head1 DESCRIPTION

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
use Carp;
use TUSK::Core::School;
use TUSK::Quiz::Quiz;
use HSDB45::Course;

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
					'tablename' => 'link_course_quiz',
					'usertoken' => 'ContentManager',
					},
				    _field_names => {
					'link_course_quiz_id' => 'pk',
					'parent_course_id' => '',
					'child_quiz_id' => '',
					'school_id' => '',
					'time_period_id' => '',
					'available_date' => '',
					'due_date' => '',
					'sort_order' => '',
				    },
				    _attributes => {
					save_history => 1,
					tracking_fields => 1,	
				    },
				    _levels => {
					reporting => 'warn',
					error => 0,
				    },
				    _default_order_bys => ['sort_order'],
				    @_
				  );
    # Finish initialization...
    return $self;
}

### Get/Set methods

#######################################################

=item B<getParentCourseID>

   $string = $obj->getParentCourseID();

Get the value of the parent_course_id field

=cut

sub getParentCourseID{
    my ($self) = @_;
    return $self->getFieldValue('parent_course_id');
}

#######################################################

=item B<setParentCourseID>

    $obj->setParentCourseID($value);

Set the value of the parent_course_id field

=cut

sub setParentCourseID{
    my ($self, $value) = @_;
    $self->setFieldValue('parent_course_id', $value);
}


#######################################################

=item B<getChildQuizID>

   $string = $obj->getChildQuizID();

Get the value of the child_quiz_id field

=cut

sub getChildQuizID{
    my ($self) = @_;
    return $self->getFieldValue('child_quiz_id');
}

#######################################################

=item B<setChildQuizID>

    $obj->setChildQuizID($value);

Set the value of the child_quiz_id field

=cut

sub setChildQuizID{
    my ($self, $value) = @_;
    $self->setFieldValue('child_quiz_id', $value);
}


#######################################################

=item B<getSchoolID>

   $string = $obj->getSchoolID();

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

=item B<getTimePeriodID>

   $string = $obj->getTimePeriodID();

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

=item B<getAvailableDate>

   $string = $obj->getAvailableDate();

Get the value of the available_date field

=cut

sub getAvailableDate{
    my ($self) = @_;
    return $self->getFieldValue('available_date');
}

#######################################################

=item B<getFormattedAvailableDate>

   $string = $obj->getFormattedAvailableDate();

Get the value of the available_date field without secs

=cut

sub getFormattedAvailableDate{
    my ($self) = @_;
    my $avail_date = $self->getAvailableDate();
    $avail_date =~ s/:\d\d$//;
    return $avail_date;
}

#######################################################

=item B<setAvailableDate>

    $obj->setAvailableDate($value);

Set the value of the available_date field

=cut

sub setAvailableDate{
    my ($self, $value) = @_;
    $self->setFieldValue('available_date', $value);
}


#######################################################

=item B<getDueDate>

   $string = $obj->getDueDate();

Get the value of the due_date field

=cut

sub getDueDate{
    my ($self) = @_;
    return $self->getFieldValue('due_date');
}

#######################################################

=item B<getFormattedDueDate>

   $string = $obj->getFormattedDueDate();

Get the value of the due_date field with no secs

=cut

sub getFormattedDueDate{
    my ($self) = @_;
    my $due_date = $self->getDueDate();
    $due_date =~ s/:\d\d$//;
    return $due_date;
}

#######################################################

=item B<setDueDate>

    $obj->setDueDate($value);

Set the value of the due_date field

=cut

sub setDueDate{
    my ($self, $value) = @_;
    $self->setFieldValue('due_date', $value);
}


#######################################################

=item B<getSortOrder>

   $string = $obj->getSortOrder();

Get the value of the sort_order field

=cut

sub getSortOrder{
    my ($self) = @_;
    return $self->getFieldValue('sort_order');
}

#######################################################

=item B<setSortOrder>

    $obj->setSortOrder($value);

Set the value of the sort_order field

=cut

sub setSortOrder{
    my ($self, $value) = @_;
    $self->setFieldValue('sort_order', $value);
}


#######################################################

=item B<getQuizzes>

    $string = $obj->getQuizzes($cond, $orderby, $cond, $orderby);

=cut

sub getQuizzes{
    my ($self, $school_name, $course_id, $cond, $orderby, $fields, $limit, $joinobjs) = @_;

    my $school_id = TUSK::Core::School->new->getSchoolID($school_name);
    my $course =  HSDB45::Course->new(_school => $school_name, _id=>$course_id);

    $orderby = ["sort_order"] unless ($orderby);
    push (@$joinobjs, TUSK::Core::JoinObject->new("TUSK::Quiz::LinkCourseQuiz", {joinkey=>'child_quiz_id', origkey=>'quiz_id', cond => "link_course_quiz.parent_course_id = $course_id and link_course_quiz.school_id = $school_id"}));

    return TUSK::Quiz::Quiz->new->passValues($self)->lookup($cond, $orderby, $fields, $limit, $joinobjs);
}

#######################################################

=item B<lookupByRelation>

    $links = $obj->lookupByRelation($course_obj, $quiz_obj, $time_period_obj );

This returns an arrayref of LinkCourseQuiz objects that are defined by the attributes passed in.
If the tp_id (timeperiod_id) is not passed it, then it assumes the current timeperiod for the course.

=cut

sub lookupByRelation{
	validate_pos( @_, { isa=> 'HSDB45::Course'}, 
		{isa=>'TUSK::Quiz::Quiz'},
		{default=>undef, 'isa'=>'HSDB45::TimePeriod'});
	my $course = shift;	
	my $quiz = shift;
	my $time_period = shift;
	my ($course_id,$quiz_id,$school_id) = ($course->getPrimaryKeyID(),$quiz->getPrimaryKeyID(),
		$course->getSchool->getPrimaryKeyID());
	my $time_period_id; 
	if (defined($time_period)){
		$time_period_id = $time_period->primary_key();
	} else {
		$time_period_id = $course->get_current_timeperiod();
	}
	return TUSK::LinkCourse::Quiz->new->lookup(<<EOM);
		parent_course_id = $course_id and child_quiz_id = $quiz_id and		
		school_id = $school_id and time_period_id = $time_period_id
EOM

}

#######################################################

=item B<setSelf>

    $obj->setSelf($course, $tp);

=cut

sub setSelf{
    my ($self, $course, $tp) = @_;
    $self->setSchoolID(TUSK::Core::School->new->getSchoolID($course->school));
    $self->setParentCourseID($course->primary_key);

    $tp = $course->get_current_timeperiod unless ($tp);
    $self->setTimePeriodID($tp);

    return $self;
}

=back

=cut

### Other Methods

=head1 AUTHOR

TUSK <tuskdev@tufts.edu>

=head1 BUGS

None Reported.

=head1 SEE ALSO

B<TUSK::Core::SQLRow> - parent class

=head1 COPYRIGHT



=cut

1;

