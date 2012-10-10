package TUSK::Application::Quiz::Copy;

use strict;
use warnings;
use TUSK::Quiz::Quiz;
use TUSK::Quiz::LinkQuizQuizItem;
use TUSK::Quiz::LinkQuestionQuestion;
use TUSK::Quiz::Answer;
use TUSK::Quiz::QuestionCopy;
use TUSK::Core::IntegratedCourseQuizQuestion;
use HSDB45::Course;

sub new {
    my ($class, $args) = @_;

    my $self = { 
	_source_quiz    => TUSK::Quiz::Quiz->lookupKey($args->{source_quiz_id},
									[TUSK::Core::JoinObject->new('TUSK::Quiz::LinkCourseQuiz', {joinkey =>'child_quiz_id', origkey=>'quiz_id'})]),
	_source_quiz_id  => $args->{source_quiz_id},
	_time_period_id => $args->{time_period_id},
	_target_quiz       => TUSK::Quiz::Quiz->lookupKey($args->{target_quiz_id},
									[TUSK::Core::JoinObject->new('TUSK::Quiz::LinkCourseQuiz', {joinkey =>'child_quiz_id', origkey=>'quiz_id'})]),
	_target_quiz_id    => $args->{target_quiz_id},
	_include_answers => $args->{include_answers},
	_user          => $args->{user} || 'tusk',
    };


    bless($self, $class);
    return $self;
}

sub getSortOrderForTargetQuiz {
    my $self = shift;
    my $links = TUSK::Quiz::LinkQuizQuizItem->lookup("quiz_id = " . $self->{_target_quiz_id});
    return (defined $links && scalar @$links) ? scalar @$links : 0;
}

sub copy {
    my $self = shift;

	$self->{_copy_related_courses} = $self->coursesHaveSameChildren();

    $self->{_target_quiz_sort_order} = $self->getSortOrderForTargetQuiz();
    my $links = TUSK::Quiz::LinkQuizQuizItem->lookup("quiz_id = " . $self->{_source_quiz_id}, ['sort_order']);

    $self->copyQuestionsAnswers($links,0);
}


sub coursesHaveSameChildren {
	my $self 			 	 = shift;
	my $source_course_link 	 = $self->{_source_quiz}->getJoinObject('TUSK::Quiz::LinkCourseQuiz');
	my $source_course		 = HSDB45::Course->new(_school => $source_course_link->getSchoolID)->lookup_key($source_course_link->getParentCourseID()); 
	my $target_course_link	 = $self->{_target_quiz}->getJoinObject('TUSK::Quiz::LinkCourseQuiz');
	my $target_course		 = HSDB45::Course->new(_school => $target_course_link->getSchoolID)->lookup_key($target_course_link->getParentCourseID()); 
	
	return unless (($source_course && $target_course) && 
				   ($source_course->type eq 'integrated course' && $target_course->type eq 'integrated course'));
	my $source_subcourses	 = $source_course->get_subcourses();
	my $dest_subcourses		 = $target_course->get_subcourses();
	my $source_subcourse_ids = ();
	
	##For each subcourse from the source course, ensure the target course has the same subcourse.
	map { $source_subcourse_ids->{$_->getPrimaryKeyID()} = 1 } @$source_subcourses;
	foreach my $dest_subcourse (@$dest_subcourses) {
		return unless $source_subcourse_ids->{$dest_subcourse->getPrimaryKeyID()};
	}

	$self->{_source_course}	= $source_course;
	$self->{_source_course_school} = $source_course_link->getSchoolID(); 
	$self->{_target_course}	= $target_course;
	return 1;
}


sub copyRelatedCourses {
	use Data::Dumper;
    my ($self, $source_question, $target_question) = @_;
   
    ###Clone related course entries from the source question into the target question.
	my $subcourses = TUSK::Quiz::Question->get_related_courses($source_question->getPrimaryKeyID(),
															   $self->{_source_course}->getPrimaryKeyID(),
															   $self->{_source_course}->get_school()->getPrimaryKeyID());
	foreach my $subcourse (@$subcourses) {
		my $ICQ = TUSK::Core::IntegratedCourseQuizQuestion->new();
		$ICQ->setParentIntegratedCourseID($subcourse->getTuskCourseID());
		$ICQ->setOriginatingCourseID($self->{_target_course}->getTuskCourseID());
		$ICQ->setChildQuizQuestionID($target_question->getPrimaryKeyID());
		$ICQ->save({user => $self->{_user}}); 
	}
}


sub copySomeQuestions {
    my ($self,$question_ids) = @_;

	$self->{_copy_related_courses} = $self->coursesHaveSameChildren();
    $self->{_target_quiz_sort_order} = $self->getSortOrderForTargetQuiz();
    my $links = TUSK::Quiz::LinkQuizQuizItem->lookup('quiz_id = ' . $self->{_source_quiz_id} . ' AND quiz_item_id in (' . join(",", @$question_ids) . ')', ['sort_order']);
    $self->copyQuestionsAnswers($links,0);
}


sub copyQuestionsAnswers {
    my ($self, $links, $parent_question_id) = @_;

    foreach my $link (@$links) {
    	my $from_question_id = (ref $link eq 'TUSK::Quiz::LinkQuizQuizItem') ? $link->getQuizItemID() : $link->getChildQuestionID();
    
    	if (my $from_question = TUSK::Quiz::Question->lookupKey($from_question_id)) {
    	    my $to_question = $from_question->clone();
    	    $to_question->setFeedback(undef) unless $self->{_include_answers};
    	    $to_question->save({ user => $self->{_user} });
    	    my $to_question_id = $to_question->getPrimaryKeyID();
    
    	    ## we want to keep only single parent copy 
    	    ## so we search for the parent of from_question and used it if found
    	    ## skip the children of MultipleFillIn and Matching Child
    	    if ($from_question->getBody()) {
        		my $copy = TUSK::Quiz::QuestionCopy->new();
        		my $parent_copy = $copy->lookupReturnOne("child_copy_question_id = $from_question_id");
        		$copy->setFieldValues({ 
        		    parent_copy_question_id => (defined $parent_copy) ? $parent_copy->getParentCopyQuestionID() : $from_question_id,
        		    child_copy_question_id => $to_question_id
        		    });
        		$copy->save({ user => $self->{_user}});
    	    }
    
    	    if (ref $link eq 'TUSK::Quiz::LinkQuizQuizItem') {
    			my $new_link = $link->clone({quiz_id => $self->{_target_quiz_id}, quiz_item_id => $to_question_id});
    			$new_link->setSortOrder($self->{_target_quiz_sort_order});
    			$self->{_target_quiz_sort_order}++;
    			$new_link->save({ user => $self->{_user} });
    	    } elsif (ref $link eq 'TUSK::Quiz::LinkQuestionQuestion') {
    			my $new_link = $link->clone({parent_question_id => $parent_question_id, child_question_id => $to_question_id});
    			$new_link->save({ user => $self->{_user} });
    	    }
    
    	    my $type = $from_question->getType();
    	    if ($type =~ /^(Section|MultipleFillIn|Matching)$/) {
    			my $link_questions = TUSK::Quiz::LinkQuestionQuestion->lookup("parent_question_id = $from_question_id");
    			$self->copyQuestionsAnswers($link_questions,$to_question_id);
    	    } 
    
        	### MatchingChild copies only one quiz answer at the time
    	    if ($type eq 'MatchingChild') {
    			if (ref $link eq 'TUSK::Quiz::LinkQuestionQuestion') {
    				if ($self->{_include_answers}) {
    					$self->copyMatchingChildAnswer($from_question_id, $to_question_id, $link->getParentQuestionID(), $parent_question_id);
    			    }
    			} 
    	    } else {
    			if ($type ne 'Matching' && $self->{_include_answers}) {
    		    	$self->copyAnswers($from_question_id, $to_question_id);
    			}
    	    }

            #If this question is being copied from one Integrated Course to another, and the target course has the same subcourses as this one,
            #create the corresponding records in IntegratedCourseQuizQuestion.
            if ($self->{_copy_related_courses} && $type ne 'MatchingChild'  && ref $link eq 'TUSK::Quiz::LinkQuizQuizItem') {
               $self->copyRelatedCourses($from_question, $to_question); 
            }
    
    	} else {
    	    print "invalid question: $from_question_id\n";
	    }
        
    }
}


sub copyAnswers {
    my ($self, $from_question_id, $to_question_id) = @_;
    my $answers = TUSK::Quiz::Answer->lookup("quiz_question_id = $from_question_id ");

    foreach my $answer (@$answers) {
	my $new_answer = $answer->clone({quiz_question_id => $to_question_id});
	$new_answer->save({ user => $self->{_user} });
    }

}


sub copyMatchingChildAnswer {
    my ($self, $from_child_question_id, $to_child_question_id, $from_parent_question_id, $to_parent_question_id) = @_;
    my $answer = TUSK::Quiz::Answer->lookupReturnOne("quiz_question_id = $from_parent_question_id AND child_question_id = $from_child_question_id");

    if ($answer) {
	my $new_answer = $answer->clone({quiz_question_id => $to_parent_question_id, child_question_id => $to_child_question_id});
	$new_answer->save({ user => $self->{_user} });
    }
}



1;
