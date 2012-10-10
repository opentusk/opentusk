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


package TUSK::Quiz::Question;

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

use TUSK::Quiz::Answer;
use TUSK::Quiz::LinkQuestionQuestion;
use TUSK::Constants;
use TUSK::Quiz::Response;
use TUSK::Quiz::QuestionCopy;

# Non-exported package globals go here
use vars ();

# Creation methods

sub new {
    # Find out what class we are
    my $class = shift;
    $class = ref $class || $class;
    # Call the super-class's constructor and give it all the values
    my $self = $class->SUPER::new ( 
				    _datainfo => {
					database => "tusk",
					tablename => "quiz_question",
					usertoken => "ContentManager",
				    },
				    _field_names => {
					'quiz_question_id' => 'pk',
					'type' => '',
					'title' => '',
					'body' => '',
					'feedback' => '',
				    },
				    _attributes => {
					save_history => 1,
					tracking_fields => 1,
				    },
				    _levels =>  {
					reporting => 'warn',
					error => 0,  
				    },
				    @_);
    # Finish initialization...
    return $self;
}

sub getType{
    my $self = shift;
    return $self->getFieldValue('type');
}

sub setType{
    my $self = shift;
    my $value = shift;
    $self->setFieldValue('type', $value);
}

sub getTitle{
    my $self = shift;
    return $self->getFieldValue('title');
}

sub setTitle{
    my $self = shift;
    my $value = shift;
    $self->setFieldValue('title', $value);
}

sub getBody{
    my $self = shift;
    return $self->getFieldValue('body');
}

sub setBody{
    my $self = shift;
    my $value = shift;
    $self->setFieldValue('body', $value);
}

sub getFeedback{
    my $self = shift;
    return $self->getFieldValue('feedback');
}

sub setFeedback{
    my $self = shift;
    my $value = shift;
    $self->setFieldValue('feedback', $value);
}

sub getFormattedType{
    my ($self) = @_;
    my $type = $self->getType;
    if ($type eq "TrueFalse"){
	return "True / False";
    }elsif($type eq "MultipleChoice"){
	return "Multiple Choice";
    }elsif($type eq "FillIn"){
	return "Fill In";
    }elsif($type eq "MultipleFillIn"){
	return "Multiple Fill In";
    }else{
	return $type;
    }
}

### Stuff to do with answers array

sub insertAnswer{
    my ($self, $values_hashref) = @_;

    my $answer = TUSK::Quiz::Answer->new->setFieldValues($values_hashref);
    my $retval = $answer->save();
    if ($retval != 0){
	push (@{$self->getAnswers}, $answer);
    }
    
    return($retval);
}

sub updateAnswer{
    my ($self, $index, $values_hashref) = @_;
    
    my $answer = $self->getAnswer($index);
    $answer->fieldValues($values_hashref);
    my $retval = $answer->save();
    
    return($retval);
}

sub updateAnswerSortOrders{
    my ($self, $index, $newindex) = @_;
    
    $self->{_answers} = $self->updateSortOrders($index, $newindex, "question_id = " . $self->getPrimaryKeyID, $self->getAnswers);

}

sub deleteAnswer{
    my ($self, $index) = @_;

    my $answer = $self->getAnswer($index);
    my $retval = $answer->delete;

    return($retval);
}

sub deleteAllAnswers{
    my $self = shift;

    my $retval = TUSK::Quiz::Answer->new->delete("quiz_question_id = " . $self->getPrimaryKeyID);
    return($retval);
}

sub pushAnswer{
    # 
    # Used when doing lookups to push answer objects
    #

    my ($self, $answer) = @_;
    push (@{$self->getAnswers}, $answer);
}

sub getAnswer{
    my ($self, $index) = @_;  
    return @{$self->getAnswers}[$index];
}

sub getAnswers{
    my $self = shift;
    my $override = shift;

    if ($override or ! exists $self->{_answers}){

	if ($self->getPrimaryKeyID){

	    if ($self->getType() eq "MatchingChild"){
		my $answers = TUSK::Quiz::Answer->new()->lookup(
	"link_question_question.child_question_id = " . $self->getPrimaryKeyID(), 
	["sort_order"], 
	undef, 
	undef,
	[
	 TUSK::Core::JoinObject->new("TUSK::Quiz::LinkQuestionQuestion", 
	     { 
		 joinkey => 'parent_question_id',
		 origkey => 'quiz_question_id',
	     }),
	 ]);

		my $correct_answer_text = '';

		foreach my $answer (@$answers){
		    if ($answer->getChildQuestionID() == $self->getPrimaryKeyID()){
			$correct_answer_text = $answer->getValue();
			last;
		    }
		}

		my $matching_answers = [];
		my $answer_seen = {};

		foreach my $answer (@$answers){
		    unless ($answer_seen->{ $answer->getValue() }){
			if ($correct_answer_text && $answer->getValue() eq $correct_answer_text){
			    $answer->setCorrect(1);
			}
			push @$matching_answers, $answer;
			$answer_seen->{ $answer->getValue() } = 1;
		    }
		}

		$self->{_answers} = $matching_answers;
	    } else {
		$self->{_answers} = TUSK::Quiz::Answer->new->passValues($self)->lookup(
				"quiz_question_id = " . $self->getPrimaryKeyID,["sort_order"]);
	    }
	} 
    }
    return $self->{_answers};
}

sub defineAnswers{
    my $self = shift;
    unless (exists $self->{_answers}){
	$self->{_answers} = [];
    }
}

sub getCorrectAnswer{
	my ($self) = @_;

	unless ($self->{_correct_answer}){
	    my $answers = $self->getAnswers();
	    foreach my $answer (@$answers){
		if ($answer->getCorrect()){
		    $self->{_correct_answer} = $answer;
		    last;
		}
	    }
	}

	return $self->{_correct_answer};
}

sub getCorrectAnswers {
	my ($self) = @_;

	unless ($self->{_correct_answer}){
	    my $answers = $self->getAnswers();
	    foreach my $answer (@$answers){
		if ($answer->getCorrect()){
		    push @{$self->{_correct_answer}}, $answer;
		}
	    }
	}

	return $self->{_correct_answer};
}


sub setCorrectAnswer{
	my $self = shift;
	my $answer = shift;
	$self->{_correct_answer} = $answer;
}


####  Advanced lookups

sub lookupWithAnswers{
    my ($self, $cond, $orderby, $fields) = @_;
    return lookupAnswers($self->lookup($cond, $orderby, $fields));
}

sub lookupAnswers{
    my ($self, $question_arrayref) = @_;
    my (@questionids, %ids, $index);
    my $flag = "question";

    foreach my $question (@$question_arrayref){
	my $id;
	if (ref($question) eq "TUSK::Quiz::Question"){
	    $id = $question->getPrimaryKeyID;
	}else{
	    $id = $question->getQuestionObject()->getPrimaryKeyID;
	    $flag = "linkquizquizitem";
	}
	push (@questionids, $id);
	$ids{$id} = $index++;
    }

    return [] if (!scalar(@questionids));

    my $answer_arrayref = TUSK::Quiz::Answer->new->passValues($self)->lookup(
			"quiz_question_id IN (" . join(",", @questionids) . ")", ["quiz_question_id", "sort_order"]);
    
    foreach my $answer (@{$answer_arrayref}){
	my $questionid = $answer->getQuestionID();
	my $index = $ids{$questionid};
	my $obj;

	if ($flag eq "question"){
	    $obj = @$question_arrayref[$index];
	}else{
	    $obj = @$question_arrayref[$index]->getQuestionObject();
	}
	$obj->defineAnswers;
	$obj->pushAnswer($answer);

	if ($answer->isCorrect()){
		$obj->setCorrectAnswer($answer);	
	}
    }

    return $question_arrayref;
}


sub hasAnswers{
	my $self = shift;
	my $answers = $self->getAnswers;
	if (scalar (@{$answers})){
		return 1;
	} 
	return 0;
}

sub getSubQuestions{
    my ($self) = @_;

    return TUSK::Quiz::Question->new()->lookup(
						"parent_question_id = " . $self->getPrimaryKeyID(),
						["sort_order"], 
						undef, 
						undef,
						[
						 TUSK::Core::JoinObject->new("TUSK::Quiz::LinkQuestionQuestion", 
									     {
										 origkey => 'quiz_question_id', 
										 joinkey => 'child_question_id',
									     }
									     ),
						 ],
						);
}

sub getSubQuestionLinks{
    my ($self, $type) = @_;

    my $array =  TUSK::Quiz::LinkQuestionQuestion->new()->lookup(
						"parent_question_id = " . $self->getPrimaryKeyID(),
						["sort_order"], 
						undef, 
						undef,
						[
						 TUSK::Core::JoinObject->new("TUSK::Quiz::Question", 
									     {
										 joinkey => 'quiz_question_id', 
										 origkey => 'child_question_id',
									     }
									     ),
						 ],
						);
    return $array if (!defined($type) or $type ne "hash");

    my $hash = {};

    foreach my $item (@$array){
	$hash->{ $item->getPrimaryKeyID() } = $item;
    }

    return $hash;
}

sub delete{
    my ($self, $params) = @_;
    
    my $retval = $self->deleteAllAnswers();

    my $links = $self->getSubQuestionLinks();

    foreach my $link (@$links){
	my $question = $link->getQuestionObject();
	my $qid = $question->getPrimaryKeyID();
	$question->delete($params);

	### for now, we still keep records if user wants to delete parent copy
	if (my $copy = TUSK::Quiz::QuestionCopy->new()->lookupReturnOne("child_copy_question_id = $qid")) {
	    $copy->delete();
	}

	$link->delete($params);
    }

    if (my $copy = TUSK::Quiz::QuestionCopy->new()->lookupReturnOne("child_copy_question_id = " . $self->getPrimaryKeyID())) {
	$copy->delete();
    }
    
    return $self->SUPER::delete($params);
}


sub needsGrading {
    my ($self,$quiz,$link_id,$link_type,$question_id,$question_type) = @_;
    my $responses = [];

    if ($question_type =~ /^MultipleFillIn|Matching$/) {
	my $resp = TUSK::Quiz::Response->new();
	$responses = $resp->lookup("preview_flag = 0 and quiz_id = " . $quiz->getPrimaryKeyID() . " and link_id in (select link_question_question_id from tusk.link_question_question where parent_question_id = $question_id) and link_type = 'link_question_question'", undef,undef,undef, [TUSK::Core::JoinObject->new("TUSK::Quiz::Result", { joinkey => 'quiz_result_id'}) ]);
    } else {
	$responses = TUSK::Quiz::Response->new()->lookup("preview_flag = 0 and quiz_id = " . $quiz->getPrimaryKeyID() . " and link_id = $link_id and link_type = '$link_type'", undef,undef,undef, [TUSK::Core::JoinObject->new("TUSK::Quiz::Result", { joinkey => 'quiz_result_id'}) ]);
    }

    foreach my $response (@{$responses}){
	unless ($response->getGradedFlag()) {
	    return 1;
	}
    }
    return 0;
}


sub get_related_courses{
        my ($self,$question_id, $orig_course_id, $school_name) = @_;
		my $school_id = TUSK::Core::School->new->getSchoolID($school_name);
		my $course =  HSDB45::Course->new(_school => $school_name, _id=>$orig_course_id);
		my $tusk_course = TUSK::Course->new()->lookupKey($course->getTuskCourseID());
		my $ret = [];
		
		foreach (@{ TUSK::Core::IntegratedCourseQuizQuestion->new()->passValues($tusk_course)->lookup("child_quiz_question_id=".$question_id." and originating_course_id =".$tusk_course->getFieldValue('course_id') ) } ) {
			my $i_tusk_course = TUSK::Course->new()->lookupKey( $_->getParentIntegratedCourseID() );
			push @{$ret}, $i_tusk_course->getHSDB45CourseFromTuskID();
		}

=head
    foreach (@{ TUSK::Core::LinkCourseCourse->new()->passValues($tusk_course)->lookup("link_course_course.parent_course_id=".$tusk_course->getFieldValue('course_id'
)) }) {
                my $i_tusk_course = TUSK::Course->new()->lookupKey( $_->getChildCourseID() );
                push @{$ret}, $i_tusk_course->getHSDB45CourseFromTuskID();
        }
=cut

        return $ret;
}


1;
