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


package TUSK::Quiz::Quiz;

=head1 NAME

B<TUSK::Quiz::Quiz> - Class for manipulating entries in table quiz in tusk database

=head1 DESCRIPTION

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
use TUSK::Quiz::LinkQuizQuizItem;
use TUSK::Quiz::LinkCourseQuiz;
use TUSK::Quiz::Result;
use TUSK::Core::School;
use HSDB45::Course;
use HSDB4::DateTime;
use TUSK::Case::RuleOperand;
use TUSK::Case::RuleElementType;

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
					tablename => "quiz",
					usertoken => "ContentManager",
				    },
				    _field_names => {
					'quiz_id' => 'pk',
					'duration'=>'',
					'title' => '',
					'instructions' => '',
					'quiz_type' => '',
					'questions_per_page' => '',
					'random_question_level' => '',
					'show_all_feedback' => '',
					'hide_correct_answer' => '',
					'ending_message' => '',
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

sub getTitle{
    my $self = shift;
    return $self->getFieldValue('title');
}

sub setTitle{
    my $self = shift;
    my $value = shift;
    $self->setFieldValue('title', $value);
}

sub getInstructions{
    my $self = shift;
    return $self->getFieldValue('instructions');
}

sub setInstructions{
    my $self = shift;
    my $value = shift;
    $self->setFieldValue('instructions', $value);
}

sub getDuration{
    my $self = shift;
    return $self->getFieldValue('duration');
}

sub setDuration{
    my $self = shift;
    my $value = shift;
    $self->setFieldValue('duration', $value);
}

sub getQuizType{
    my $self = shift;
    return $self->getFieldValue('quiz_type');
}

sub setQuizType{
    my $self = shift;
    my $value = shift;
    $self->setFieldValue('quiz_type', $value);
}

sub getQuestionsPerPage{
    my $self = shift;
    return $self->getFieldValue('questions_per_page');
}

sub setQuestionsPerPage{
    my $self = shift;
    my $value = shift;
    $self->setFieldValue('questions_per_page', $value);
}

sub getEndingMessage{
    my $self = shift;
    return $self->getFieldValue('ending_message');
}

sub setEndingMessage{
    my $self = shift;
    my $value = shift;
    $self->setFieldValue('ending_message', $value);
}

sub getFormattedQuizType{
    my ($self) = @_;

    if ($self->getQuizType eq "SelfAssessment"){
	return "Self Assessment";
    }elsif ($self->getQuizType eq "FeedbackQuiz"){
	return "Feedback Quiz";
    }else{
	return $self->getQuizType;
    }
}

sub getFormattedDuration{
    my ($self) = @_;
    my $duration = $self->getDuration;
    if ($duration eq "00:00:00"){
	return "Untimed";
    }else{
	$duration =~ s/:\d\d$//;
	$duration =~ s/^0//;
	return $duration;
    }

}

sub setRandomQuestionLevel {
    my ($self,$value) = @_;
    $self->setFieldValue('random_question_level',$value);
}

sub getRandomQuestionLevel {
    my ($self) = @_;
    return $self->getFieldValue('random_question_level');
}

sub setShowAllFeedback {
    my ($self,$value) = @_;
    $self->setFieldValue('show_all_feedback',$value);
}

sub getShowAllFeedback {
    my ($self) = @_;
    return $self->getFieldValue('show_all_feedback');
}

sub setHideCorrectAnswer {
    my ($self,$value) = @_;
    $self->setFieldValue('hide_correct_answer',$value);
}

sub getHideCorrectAnswer {
    my ($self) = @_;
    return $self->getFieldValue('hide_correct_answer');
}

### link stuff

sub getQuizItem{
    #
    # get a particular Quiz Item
    #

    my ($self, $index) = @_;
    return @{$self->getQuizItems}[$index];
}

sub getQuizItems{
    my ($self, $cond, $orderby) = @_;
    unless (exists $self->{_quiz_items}){
	$cond .= " and " if ($cond);
	$cond .= "quiz_id = '" . $self->getPrimaryKeyID . "'";
	$orderby = ["sort_order"] unless ($orderby);

	$self->{_quiz_items} = TUSK::Quiz::LinkQuizQuizItem->new->passValues($self)->getQuestions($cond, $orderby);
    }
    return $self->{_quiz_items};
}

sub getRandomQuizItems{
    my ($self) = @_;
    unless (exists $self->{_quiz_items}){
	my $cond .= "quiz_id = " . $self->getPrimaryKeyID . " AND user_id = '$self->{_userid}'";
	my $orderby = ["sort_order"];

	$self->{_quiz_items} = TUSK::Quiz::LinkQuizQuizItem->new()->passValues($self)->getRandomQuestions($self->getPrimaryKeyID(),$self->{_userid});
    }
    return $self->{_quiz_items};
}

sub getQuizItemsWithAnswers{
    #
    # Grab the QuizItems and put into an array ref
    #

    my ($self, $cond, $orderby) = @_;

    if ($self->getRandomQuestionLevel()) {
	$self->getRandomQuizItems();
    } else {
	$self->getQuizItems($cond, $orderby);
    }

    if (defined ($self->{_quiz_items}) && scalar(@{$self->{_quiz_items}})){
	$self->{_quiz_items} = TUSK::Quiz::Question->new->passValues($self)->lookupAnswers($self->{_quiz_items});
    }

    return $self->{_quiz_items};
}

sub getQuizItemsWithAnswersHash{
    #
    # Grab the QuizItems and put into a hash ref
    #

    my ($self, $cond, $orderby) = @_;

    my $quizItemsArray = $self->getQuizItemsWithAnswers($cond, $orderby);
    my $quizItemsHash;


    foreach my $quiz_item (@$quizItemsArray){
	$quizItemsHash->{$quiz_item->getPrimaryKeyID} =  $quiz_item;
    }

    return $quizItemsHash;
}

sub getUserID {
    my ($self) = @_;
    return $self->{_userid};
}

sub setUserID {
    my ($self, $user_id) = @_;
    $self->{_userid} = $user_id;
}


#######################################################

=item B<exportToGradeBook>

    $msg = $quiz->exportToGradeBook($grade_event, $commit);

The grade_event is a required parameter of the type TUSK::GradeBook::GradeEvent.  $commit 
is a flag that indicates whether the update should occur or not.  

The function takes the quiz's results and inserts and updates the grades for
the given grade_event object.  

The return value is a string for a user to see what the export did and did not do.

=cut


sub exportToGradeBook{
	my $self = shift;
	my $grade_event = shift;
	my $commit = shift;
	my $results = $self->getExportableResults($grade_event); 
	my $grade_event_quiz_id = $grade_event->getQuizID();
	if (!defined($grade_event_quiz_id) || ($grade_event_quiz_id eq $self->getPrimaryKeyID())){
		$grade_event->setQuizID($self->getPrimaryKeyID());
		$grade_event->save({'user'=>$self->getUser()});
	} else {
		confess "The Quiz is being exported to an invalid grade event. The grade event is associated to quiz $grade_event_quiz_id";
	}
	my ($link,$links,$grade_event_id,$user_object,$user_id,$updatingLink,$score,$user_name,$old_score);
	my @msgs = ();
	my $record_count = 0;
	$grade_event_id = $grade_event->getPrimaryKeyID();
	foreach my $result (@{$results}){
		$updatingLink = 0;
		$user_id = $result->getUserID;
                $links = TUSK::GradeBook::LinkUserGradeEvent->lookupByRelation($user_id,$grade_event_id);
                if (scalar(@{$links})){
                        $link = pop @{$links};
			$updatingLink = 1;
			$old_score = $link->getGrade;
                } else {
                        $link = TUSK::GradeBook::LinkUserGradeEvent->new();
                        $link->setParentUserID($user_id);
                        $link->setChildGradeEventID($grade_event_id);
                }
		$score = $result->getScore();
		$user_object = HSDB4::SQLRow::User->new->lookup_key($user_id);
		if (defined($user_object->primary_key())){
			$user_name = $user_object->out_full_name();
		} else {
			confess "User object not found for key $user_id";
		}
                $link->setGrade($score);
		$record_count++;
		if ($commit){
			if ($updatingLink && ($old_score ne $score)){
				push @msgs, "Changing Grade for $user_name from $old_score to $score.";
			}
			$link->save({'user'=>$self->getUser()});
		} else {
			if ($updatingLink && ($old_score ne $score)){
			    push @msgs, "The grade for $user_name would change from $old_score to $score.";
			}
		}
	}
	if ($commit){
		push @msgs, "Export complete -- $record_count records exported";
	} else {
		push @msgs, "Test complete -- $record_count records would be exported.";
	}
	if (!scalar(@{$results})){
		push @msgs, 'There are no eligible results to export for this quiz.';
	}
	return \@msgs;
}


sub getExportableResults {
	my $self = shift;
	my $grade_event = shift || confess "A grade event is a required parameter";
	my $course = $grade_event->getCourseObject();
	my @students = $course->get_students($grade_event->getTimePeriodID());
	my $studentCond;
	if (@students){
		$studentCond = 'user_id in ('.join(",",map { "'".$_->primary_key."'" } @students).') ';
	} else {
		# no students, so no results
		return [];	
	}
	my $quiz_id = $self->getPrimaryKeyID();
	my $results = TUSK::Quiz::Result->lookup(" quiz_id = $quiz_id and end_date is not null and $studentCond ");
	my @exportable_results = grep { !$_->needsGrading } @{$results};
	return \@exportable_results;
}

sub hasQuestion {
	my $self = shift;
	my $question = shift;
 	my $quiz_items = $self->getQuizItems();	
	my $pk;
	if ((ref $question eq '') && ($question =~ m/^\d+$/)){
		$pk = $question
	} elsif ($question->isa('TUSK::Quiz::Question') ) {
		$pk = $question->getPrimaryKeyID; 
	} else {
		confess "Invalid input sent to hasQuestion : $question";
	}

	foreach my $qi (@{$quiz_items}){
		return 1 if ($qi->getPrimaryKeyID() == $pk);
	}
	return 0;
}

sub deleteAllQuestions{
    my $self = shift;
    my $link_items = TUSK::Quiz::LinkQuizQuizItem->lookup("quiz_id = ".$self->getPrimaryKeyID);
    return 1 unless (scalar(@{$link_items})); # return 1 if no links found

    my ($item,$retval) ;
    foreach my $link (@{$link_items}){
	$retval =  $link->delete();
	return undef unless ($retval);
    }
    return($retval);
}

sub getDurationText{
#
#  takes the duration text and forms a human readable string
#
	my $self = shift;
	my $duration = $self->getDuration();
	my ($hour,$minute,$second) = ($duration =~ m/(\d\d):(\d\d):(\d\d)/);
	my $out_text = '';
	# need to force into numeric context
	$out_text .= "$hour Hours " if ($hour+0); 
	$out_text .= "$minute Minutes " if ($minute+0); 
	$out_text .= "$second Seconds " if ($second+0); 
	return $out_text;

}

sub hasUserCompleted{
#
#  function returns whether a specific user has completed the quiz
#
        my $self = shift;
	my $user_id = shift or croak "user_id is required by hasUserCompleted";
	my $preview = shift || 0;
	if (!$self->isa('TUSK::Quiz::Quiz')){
		croak "Need to pass a valid object to hasUserCompleted";
	}
	my $id = $self->getPrimaryKeyID();
	my $results = TUSK::Quiz::Result->lookup("user_id = '$user_id' and quiz_id = $id and end_date is not null and preview_flag = $preview");
	if (scalar(@{$results})){
		return 1;
	}
	return 0;

}

sub isSelfAssessment{

#  returns whether the quiz is a self assessment type
#
	my $self = shift or croak "Need an object passed";
        if (!$self->isa('TUSK::Quiz::Quiz')){
                croak "Need to pass a valid object to isSelfAssessment";
        }
	if ($self->getQuizType eq 'SelfAssessment'){
		return 1;
	}
	return 0;
}

sub isFeedbackQuiz{

#  returns whether the quiz is a graded quiz with feedback
#
	my $self = shift or croak "Need an object passed";
        if (!$self->isa('TUSK::Quiz::Quiz')){
                croak "Need to pass a valid object to isFeedbackQuiz";
        }
	if ($self->getQuizType eq 'FeedbackQuiz'){
		return 1;
	}
	return 0;
}

sub isGradedQuiz{

#  returns whether the quiz is a graded type
#
	my $self = shift or croak "Need an object passed";
        if (!$self->isa('TUSK::Quiz::Quiz')){
                croak "Need to pass a valid object to isGradedQuiz";
        }
	if ($self->getQuizType eq 'Quiz'){
		return 1;
	}
	return 0;
}


sub delete {
        my ($self, $cond) = @_;
	my $retval;
	if ($cond){
	    # need some crazy logic here
	}else{
	    $retval = $self->deleteAllQuestions();
	    return unless ($retval);
	}

        $retval = $self->SUPER::delete($cond);
        return $retval;
}

sub getLinkCourseQuizObject{
    my ($self) = @_;
    return $self->getJoinObject("TUSK::Quiz::LinkCourseQuiz");
}

sub getPublishFlagSpelledOut{
    my ($self) = @_;
    my $link_course_quiz = $self->getLinkCourseQuizObject();
    return unless ($link_course_quiz);
    return $link_course_quiz->getPublishFlagSpelledOut();
}

sub getAvailableDate {
    my ($self) = @_;
    my $link_course_quiz = $self->getLinkCourseQuizObject();
    return unless ($link_course_quiz);
    return $link_course_quiz->getFormattedAvailableDate();
}

sub getDueDate {
    my ($self) = @_;
    my $link_course_quiz = $self->getLinkCourseQuizObject();
    return unless ($link_course_quiz);
    return $link_course_quiz->getFormattedDueDate();
}

sub getTimePeriodID {
	my $self = shift;
    my $linkobject = $self->getLinkCourseQuizObject();
	return ($linkobject) ? $linkobject->getTimePeriodID() : undef;
}

sub isOverDue {
    my ($self) = @_;    
    my $linkobject = $self->getLinkCourseQuizObject();
    my $duedate = $linkobject->getDueDate();
    return 0 unless ($duedate);

    my $now = HSDB4::DateTime->new();
    my $due = HSDB4::DateTime->new()->in_mysql_date($duedate);

    return (HSDB4::DateTime::compare($now, $due) > 0) ? 1 : 0;
}


sub getDurationInSeconds {
    my $self = shift;
    my $secs = 0;
    if (my $duration = $self->getFieldValue('duration')) {
		my @duration = split(':', $duration);
		$secs = 60 * 60 * $duration[0] + 60 * $duration[1] + $duration[2];
    }
    return $secs;
}


sub isOverTimeLimit {
    my ($self, $user_id) = @_;    
    my $duration = $self->getDurationInSeconds();
    my $now = HSDB4::DateTime->new();

    my $result = TUSK::Quiz::Result->lookupReturnOne("user_id = '$user_id' and quiz_id = " . $self->getPrimaryKeyID() . " and preview_flag = 0");

    if ($result && $result->getStartDate() && $duration) {
		my $start = HSDB4::DateTime->new()->in_mysql_date($result->getStartDate());
		if (($now->out_unix_time() - $start->out_unix_time()) > $duration) {
			return 1;
		}
    }

    return 0;
}


#######################################################

=item B<usedInScoreRule>

   $int = $quiz->usedInScoreRule();

Return whether the quiz is a part of a minimum score 
rule in the case simulator.

=cut

sub usedInScoreRule {
	my $self = shift;
	
	my $type = TUSK::Case::RuleElementType->new->lookupReturnOne('label="quiz_score"');
	my $oper = TUSK::Case::RuleOperand->new()->lookup('element_id=' . $self->getPrimaryKeyID() . ' and rule_element_type_id=' . $type->getPrimaryKeyID());

	return scalar @$oper;
}


#######################################################

=item B<canHaveScoreRule>

   $int = $quiz->canHaveScoreRule();

Return whether the quiz can have its score determined by the system;
i.e., quiz only has questions that can have their correctness 
determined by system. Free text answers cannot currently be evaluated
by system, so a quiz with one of those fails.

=cut

sub canHaveScoreRule {
	my $self = shift;
	my $questions = shift;

	my $can_grade = my $can_grade_recurse = 1;

	foreach my $question (@$questions) {
		# only list questions that have answers, but also list section questions
		# sect. questions don't have answers, but they do have children questions that might
		if ($question->hasAnswers() || $question->getType() eq 'Section') {
			if ($question->getType() eq 'Section' || $question->getType() eq 'Matching') {
				$can_grade_recurse = $self->canHaveScoreRule($question->getSubQuestions());
			}
		}
		else {
			$can_grade = 0;
		}
		$can_grade = ($can_grade && $can_grade_recurse)? 1 : 0;
	}
	return $can_grade;
}

=head1 AUTHOR

TUSK <tuskdev@tufts.edu>

=head1 BUGS

None Reported.

=head1 SEE ALSO

B<TUSK::Core::SQLRow> - parent class

=head1 COPYRIGHT



=cut

1;
