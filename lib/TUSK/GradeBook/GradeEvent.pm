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


package TUSK::GradeBook::GradeEvent;

=head1 NAME

B<TUSK::GradeBook::GradeEvent> - Class for manipulating entries in table grade_event in tusk database

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
    require TUSK::Core::School;

    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
    
    @ISA = qw(TUSK::Core::SQLRow Exporter);
    @EXPORT = qw( );
    @EXPORT_OK = qw( );
}

use vars @EXPORT_OK;
use Carp;

use TUSK::GradeBook::GradeEventType;
use TUSK::GradeBook::GradeMultiple;
use TUSK::GradeBook::GradeCategory;


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
					'tablename' => 'grade_event',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'grade_event_id' => 'pk',
					'school_id' => '',
					'course_id' => '',
					'time_period_id' => '',
					'grade_event_type_id' => '',
					'event_name' => '',
					'event_description' => '',
					'weight' => '',
					'quiz_id'=>'',
					'publish_flag' => '',
					'grade_category_id' => '',
					'sort_order' => '',
					'group_flag' => '',
					'waive_grade' => '',
					'due_date' => '',
					'pass_grade' => '',
					'max_possible_points' => '',
				    },
				    _attributes => {
					save_history => 1,
					tracking_fields => 1,	
				    },
				     _default_join_objects => [
    					   TUSK::Core::JoinObject->new("TUSK::GradeBook::GradeEventType")
				     ],
				    _default_order_bys => ['sort_order asc', 'grade_event_id'],
				    _levels => {
					reporting => 'warn',
					error => 0,
				    },
				    @_
				  );
    # Finish initialization...
    return $self;
}

### Get/Set methods

#######################################################

=item B<getGradeEventID>

    $string = $obj->getGradeEventID();

    Get the value of the grade_event_id field

=cut

sub getGradeEventID{
    my ($self) = @_;
    return $self->getFieldValue('grade_event_id');
}

#######################################################


=item B<getWaiveGrade>

    $string = $obj->getWaiveGrade();

    Get the value of the waive_grade field

=cut

sub getWaiveGrade{
    my ($self) = @_;
    return $self->getFieldValue('waive_grade');
}

#######################################################

=item B<setWaiveGrade>

    $string = $obj->setWaiveGrade($value);

    Set the value of the waive_grade field

=cut

sub setWaiveGrade{
    my ($self, $value) = @_;
    $self->setFieldValue('waive_grade', $value);
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

    $string = $obj->setSchoolID($value);

    Set the value of the school_id field

=cut

sub setSchoolID{
    my ($self, $value) = @_;
    $self->setFieldValue('school_id', $value);
}


#######################################################

=item B<getCourseID>

    $string = $obj->getCourseID();

    Get the value of the course_id field

=cut

sub getCourseID{
    my ($self) = @_;
    return $self->getFieldValue('course_id');
}

#######################################################

=item B<setCourseID>

    $string = $obj->setCourseID($value);

    Set the value of the course_id field

=cut

sub setCourseID{
    my ($self, $value) = @_;
    $self->setFieldValue('course_id', $value);
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

    $string = $obj->setTimePeriodID($value);

    Set the value of the time_period_id field

=cut

sub setTimePeriodID{
    my ($self, $value) = @_;
    $self->setFieldValue('time_period_id', $value);
}


#######################################################

=item B<getGradeEventTypeID>

    $string = $obj->getGradeEventTypeID();

    Get the value of the grade_event_type_id field

=cut

sub getGradeEventTypeID{
    my ($self) = @_;
    return $self->getFieldValue('grade_event_type_id');
}

#######################################################

=item B<setGradeEventTypeID>

    $string = $obj->setGradeEventTypeID($value);

    Set the value of the grade_event_type_id field

=cut

sub setGradeEventTypeID{
    my ($self, $value) = @_;
    $self->setFieldValue('grade_event_type_id', $value);
}


#######################################################

=item B<getEventName>

    $string = $obj->getEventName();

    Get the value of the event_name field

=cut

sub getEventName{
    my ($self) = @_;
    return $self->getFieldValue('event_name');
}

#######################################################

=item B<setEventName>

    $string = $obj->setEventName($value);

    Set the value of the event_name field

=cut

sub setEventName{
    my ($self, $value) = @_;
    $self->setFieldValue('event_name', $value);
}


#######################################################

=item B<getWeight>

    $string = $obj->getWeight();

    Get the value of the weight field

=cut

sub getWeight{
    my ($self) = @_;
    return $self->getFieldValue('weight');
}

#######################################################

=item B<setWeight>

    $string = $obj->setWeight($value);

    Set the value of the weight field

=cut

sub setWeight{
    my ($self, $value) = @_;
    $self->setFieldValue('weight', $value);
}


#######################################################

#######################################################

=item B<getMaxPossiblePoints>

    $string = $obj->getMaxPossiblePoints();

    Get the value of the max_possible_points field

=cut

sub getMaxPossiblePoints{
    my ($self) = @_;
    return $self->getFieldValue('max_possible_points');
}

#######################################################

=item B<setMaxPossiblePoints>

    $string = $obj->setMaxPossiblePoints($value);

    Set the value of the max_possible_points field

=cut

sub setMaxPossiblePoints{
    my ($self, $value) = @_;
    $self->setFieldValue('max_possible_points', $value);
}


#######################################################

=item B<getPassGrade>

    $string = $obj->getPassGrade();

    Get the value of the pass_grade field

=cut

sub getPassGrade{
    my ($self) = @_;
    return $self->getFieldValue('pass_grade');
}

#######################################################

=item B<setPassGrade>

    $string = $obj->setPassGrade($value);

    Set the value of the pass_grade field

=cut

sub setPassGrade{
    my ($self, $value) = @_;
    $self->setFieldValue('pass_grade', $value);
}



#######################################################

=item B<getEventDescription>

    $string = $obj->getEventDescription();

    Get the value of the event_description field

=cut

sub getEventDescription{
    my ($self) = @_;
    return $self->getFieldValue('event_description');
}

#######################################################

=item B<setEventDescription>

    $string = $obj->setEventDescription($value);

    Set the value of the event_description field

=cut

sub setEventDescription{
    my ($self, $value) = @_;
    $self->setFieldValue('event_description', $value);
}

#######################################################

=item B<getQuizID>

    $string = $obj->getQuizID();

    Get the value of the quiz_id field

=cut

sub getQuizID{
    my ($self) = @_;
    return $self->getFieldValue('quiz_id');
}

#######################################################

=item B<setQuizID>

    $string = $obj->setQuizID($value);

    Set the value of the quiz_id field

=cut

sub setQuizID{
    my ($self, $value) = @_;
    $self->setFieldValue('quiz_id', $value);
}



#######################################################

=item B<getPublishFlag>

    $string = $obj->getPublishFlag();

    Get the value of the publish_flag field

=cut

sub getPublishFlag{
    my ($self) = @_;
    return $self->getFieldValue('publish_flag');
}

#######################################################

=item B<getPublishFlagSpelledOut>

    $string = $obj->getPublishFlagSpelledOut();

    Get the value of the publish_flag field as a yes/no value

=cut

sub getPublishFlagSpelledOut{
    my ($self) = @_;
    if ($self->getFieldValue('publish_flag')){
	return "Yes";
    }else{
	return "No";
    }
}

#######################################################

=item B<setPublishFlag>

    $string = $obj->setPublishFlag($value);

    Set the value of the publish_flag field

=cut

sub setPublishFlag{
    my ($self, $value) = @_;
    $self->setFieldValue('publish_flag', $value);
}

#######################################################

=item B<getGradeCategoryID>

    $string = $obj->getGradeCategoryID();

    Get the value of the grade_category_id field

=cut

sub getGradeCategoryID{
    my ($self) = @_;
    return $self->getFieldValue('grade_category_id');
}

#######################################################

=item B<setGradeCategoryID>

    $string = $obj->setGradeCategoryID($value);

    Set the value of the grade_category_id field

=cut

sub setGradeCategoryID{
    my ($self, $value) = @_;
    $self->setFieldValue('grade_category_id', $value);
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

    $string = $obj->setSortOrder($value);

    Set the value of the sort_order field

=cut

sub setSortOrder{
    my ($self, $value) = @_;
    $self->setFieldValue('sort_order', $value);
}

#######################################################

=item B<getGroupFlag>

    $string = $obj->getGroupFlag();

    Get the value of the group_flag field

=cut

sub getGroupFlag{
    my ($self) = @_;
    return $self->getFieldValue('group_flag');
}

#######################################################

=item B<getGroupFlagSpelledOut>

    $string = $obj->getgroupFlagSpelledOut();

    Get the value of the group_flag field as a yes/no value

=cut

sub getGroupFlagSpelledOut{
    my ($self) = @_;
    if ($self->getFieldValue('group_flag')){
	return "Yes";
    }else{
	return "No";
    }
}

#######################################################

=item B<setGroupFlag>

    $string = $obj->setGroupFlag($value);

    Set the value of the group_flag field

=cut

sub setGroupFlag{
    my ($self, $value) = @_;
    $self->setFieldValue('group_flag', $value);
}


#######################################################

=item B<getDueDate>

my $string = $obj->getDueDate();

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


=back

=cut

#######################################################

### Other Methods

sub getGradeEventTypeObject{
    my ($self) = @_;
    return $self->getJoinObject("TUSK::GradeBook::GradeEventType");
}

sub getGradeEventTypeName{
    my ($self) = @_;
    if (ref $self->getGradeEventTypeObject() eq "TUSK::GradeBook::GradeEventType"){
		return $self->getGradeEventTypeObject()->getGradeEventTypeName();
    }
}

sub getLinkUserGradeEventObject{
    my ($self) = @_;
    return $self->getJoinObject("TUSK::GradeBook::LinkUserGradeEvent");
}

sub getCourseObject{
    my $self = shift;
    my $school = TUSK::Core::School->lookupKey($self->getSchoolID());
    if (!defined($school)){
		confess "Grade event has invalid school";
    }
    return HSDB45::Course->new(_id=>$self->getCourseID(),_school=>$school->getSchoolName());
}

sub getGradeCategoryObject {
    my ($self) = @_;
	return $self->getJoinObject("TUSK::GradeBook::GradeCategory");
}


#######################################################

=item B<getCourseEvents>

    $objs_arrayref = $obj->getCourseEvents($school_name, $course_id, $timeperiod_id,$event_type);

    Return an arrayref of grade event objs for a particular school/course/timeperiod/event_type

=cut

sub getCourseEvents{
	my ($self, $school_name, $course_id, $time_period_id, $event_type) = @_;
	my $school_id = TUSK::Core::School->new->getSchoolID($school_name);
	my $addtl_join_obj;

	my $cond = "school_id = $school_id AND course_id = $course_id";
	if (defined($time_period_id)){
		$cond .= " AND time_period_id = $time_period_id";
	}
	if (defined($event_type)){
		$addtl_join_obj = [TUSK::Core::JoinObject->new("TUSK::GradeBook::GradeEventType", { 'cond' => " grade_event_type_name = '$event_type'"} )];
	}
        my $order_by = ['grade_category_id', 'sort_order'];
	return $self->lookup( $cond, $order_by, undef, undef, $addtl_join_obj );

}

#######################################################

=item B<updateSortOrders>

    $arrayref = $obj->updateSortOrders($school_name, $course_id, $timeperiod_id, $change_order_string, $arrayref);

updates the sort order given the index of the changed answer and the new spot where it will go.  $index is array index of the object that changed,
$newindex is the new place for the moved object, $cond is a string, and $arrayref is an arrayref.

=cut

sub updateSortOrders{
    my ($self, $school_name, $course_id, $time_period_id, $change_order_string, $arrayref) = @_;
    my $school_id = TUSK::Core::School->new->getSchoolID($school_name);
    return [] unless $school_id;

    my $cond = "school_id = " . $school_id . " and course_id = " . $course_id . " and time_period_id = " . $time_period_id;
    
    my ($index, $newindex) = split ("-", $change_order_string);
    return $self->SUPER::updateSortOrders($index, $newindex, $cond, $arrayref);
}


#######################################################

=item B<getCourseGradesByStudent>

    ($grades_data, $saved_grades) = $obj->getCourseGrades($course, $timeperiod_id);

given a course, timeperiod_id, and user_id return a arraryref used to display grades for given student.  $grades_data includes a record for each student in the class; $saved_grades only includes records for students with grades;

=cut

sub getCourseGradesByStudent{
    my ($self, $course, $timeperiod_id, $userID) = @_;

    my $grades_data = [];

    my $saved_grades = [];

    if ($self->getPrimaryKeyID()){
	my @students = $course->get_students($timeperiod_id);
        my $ourStudent;
	foreach my $student (@students) {
	    if ($student->primary_key eq $userID)
	    {
		$ourStudent=$student;
	    }
	}

	my $saved_grades_hashref;
	
	$saved_grades = TUSK::GradeBook::LinkUserGradeEvent->new->lookup("child_grade_event_id = " . $self->getPrimaryKeyID());
	
	foreach my $saved_grade (@$saved_grades){
	    if($saved_grade->getParentUserID() eq $userID)
	    {
		$saved_grades_hashref->{$saved_grade->getParentUserID()} = $saved_grade;
	    }
	}
	
	    my ($grade, $comments, $link_user_grade_event_id);
	    if (defined($saved_grades_hashref->{$ourStudent->primary_key})){
		$grade = $saved_grades_hashref->{$ourStudent->primary_key}->getGrade();
		$comments = $saved_grades_hashref->{$ourStudent->primary_key}->getComments();
		$link_user_grade_event_id = $saved_grades_hashref->{$ourStudent->primary_key}->getPrimaryKeyID();
	    }
	    push (@$grades_data, {user_id => $ourStudent->primary_key(), link_user_grade_event_id => $link_user_grade_event_id, name => $ourStudent->out_lastfirst_name(), grade => $grade, comments => $comments});
	
    }
    return ($grades_data, $saved_grades);
}


#######################################################

=item B<getGradeRecords>

    ($grades_data, $saved_grades) = $obj->getGradeRecords($course);

given a course return a arraryref used to display grades.  $grades_data includes a record for each student in the class; $saved_grades only includes records for students with grades;

=cut

sub getGradeRecords {
    my ($self, $course) = @_;

    my ($grades_data, $saved_grades) = ([], []);

    if ($self->getPrimaryKeyID()) {
		my @students = $course->get_students($self->getTimePeriodID());
		my $saved_grades_hashref;
	
		$saved_grades = TUSK::GradeBook::LinkUserGradeEvent->new->lookup("child_grade_event_id = " . $self->getPrimaryKeyID());
	
		foreach my $saved_grade (@$saved_grades){
			$saved_grades_hashref->{$saved_grade->getParentUserID()} = $saved_grade;		
		}
	
		foreach my $student (@students){
			my ($grade, $comments, $link_user_grade_event_id, $site_id);
			if (defined($saved_grades_hashref->{$student->primary_key})){
				$grade = $saved_grades_hashref->{$student->primary_key}->getGrade();
				$comments = $saved_grades_hashref->{$student->primary_key}->getComments();
				$link_user_grade_event_id = $saved_grades_hashref->{$student->primary_key()}->getPrimaryKeyID();
				$site_id = $saved_grades_hashref->{$student->primary_key()}->getTeachingSiteID();
			}
			push @$grades_data, {user_id => $student->primary_key(), link_user_grade_event_id => $link_user_grade_event_id, name => $student->out_lastfirst_name(), grade => $grade, comments => $comments, site => $site_id};
		}
    }

    return ($grades_data, $saved_grades);
}


#######################################################

=item B<getFinalGradeRecords>

    ($grades_data) = $obj->getFinalGradeRecords($course);

given a course return a arraryref used to display grades.  $grades_data includes a record for each student in the class; $saved_grades only includes records for students with grades;

=cut

sub getFinalGradeRecords {
    my ($self, $course) = @_;

    my ($final_grades, $saved_grades) = ([], []);

    if ($self->getPrimaryKeyID()) {
		my @students = $course->get_students($self->getTimePeriodID());
		my $saved_grades_hashref;
	
		$saved_grades = TUSK::GradeBook::LinkUserGradeEvent->new->lookup("child_grade_event_id = " . $self->getPrimaryKeyID(), undef, undef, undef, 
		 [ TUSK::Core::JoinObject->new("TUSK::GradeBook::GradeMultiple", {alias => 'calculated', joinkey => 'link_user_grade_event_id', origkey => 'link_user_grade_event_id', jointype => 'left', joincond => "calculated.grade_type = $TUSK::GradeBook::GradeMultiple::CALCULATED_FINAL_GRADETYPE"}), 
		   TUSK::Core::JoinObject->new("TUSK::GradeBook::GradeMultiple", {alias => 'adjusted', joinkey => 'link_user_grade_event_id', origkey => 'link_user_grade_event_id', jointype => 'left', joincond => "adjusted.grade_type = $TUSK::GradeBook::GradeMultiple::ADJUSTED_FINAL_GRADETYPE"})]);
	
		foreach my $saved_grade (@$saved_grades){
			$saved_grades_hashref->{$saved_grade->getParentUserID()} = $saved_grade;		
		}
	
		foreach my $student (@students){
			my ($final_grade, $comments, $link_user_grade_event_id, $calc_grade, $adj_grade);
			if (defined($saved_grades_hashref->{$student->primary_key})){
				$final_grade = $saved_grades_hashref->{$student->primary_key}->getGrade();
				my $c = $saved_grades_hashref->{$student->primary_key}->getJoinObject('calculated');
				if (ref $c eq 'TUSK::GradeBook::GradeMultiple') {
					$calc_grade = $c->getGrade();
				}
				my $a = $saved_grades_hashref->{$student->primary_key}->getJoinObject('adjusted');
				if (ref $a eq 'TUSK::GradeBook::GradeMultiple') {
					$adj_grade  = $a->getGrade();
				}

				$comments = $saved_grades_hashref->{$student->primary_key}->getComments();
				$link_user_grade_event_id = $saved_grades_hashref->{$student->primary_key()}->getPrimaryKeyID();
			}
			push @$final_grades, {user_id => $student->primary_key(), link_user_grade_event_id => $link_user_grade_event_id, name => $student->out_lastfirst_name(), final_grade => $final_grade, calc_grade => $calc_grade, adj_grade => $adj_grade, comments => $comments};
		}
    }

    return ($final_grades, $saved_grades);
}


#######################################################

=item B<checkTypePath>

    $bool = $obj->checkTypePath($course, $timeperiod_id);

    Return true if type path matches object

=cut

sub checkTypePath{
    my ($self, $course, $time_period_id) = @_;
    my $school_id = TUSK::Core::School->new->getSchoolID($course->school);

    return 0 if ($school_id != $self->getSchoolID());
    return 0 if ($course->course_id() != $self->getCourseID());
    return 0 if ($time_period_id != $self->getTimePeriodID());

    return 1;
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

