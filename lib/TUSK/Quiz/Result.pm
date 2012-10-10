package TUSK::Quiz::Result;

use TUSK::Quiz::Response;
use TUSK::Quiz::LinkQuizQuizItem;
use TUSK::Quiz::RandomQuestion;
use HSDB4::DateTime;
use TUSK::Constants;
use Carp;
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
use HSDB4::SQLRow::User;


# Creation methods

sub new {
    # Find out what class we are
    my $class = shift;
    $class = ref $class || $class;
    # Call the super-class's constructor and give it all the values
    my $self = $class->SUPER::new ( 
				    _datainfo => {
					database => "tusk",
					tablename => "quiz_result",
					usertoken => "ContentManager",
				    },
				    _field_names => {
					'quiz_result_id' => 'pk',
					'user_id' => '',
					'quiz_id' => '',
					'current_question_index' => '',
					'start_date' => '',
					'end_date' => '',
					'preview_flag' => '',
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

### Get/Set methods

sub getUserID{
    #
    # get user_id field
    #

    my ($self) = @_;
    return $self->getFieldValue('user_id');
}

sub setUserID{
    #
    # set user_id field
    #

    my ($self, $value) = @_;
    $self->setFieldValue('user_id', $value);
}

sub getUserObject{
	my $self = shift;
	return HSDB4::SQLRow::User->new()->lookup_key($self->getUserID);
}


sub getQuizID{
    #
    # get quiz_id field
    #

    my ($self) = @_;
    return $self->getFieldValue('quiz_id');
}

sub setQuizID{
    #
    # set quiz_id field
    #

    my ($self, $value) = @_;
    $self->setFieldValue('quiz_id', $value);
}

sub getCurrentQuestionIndex{
    #
    # get current_question_index field
    #

    my ($self) = @_;
    return $self->getFieldValue('current_question_index');
}

sub setCurrentQuestionIndex{
    #
    # set current_question_index field
    #

    my ($self, $value) = @_;
    $self->setFieldValue('current_question_index', $value);
}


sub getStartDate{
    #
    # get start_date field
    #

    my ($self) = @_;
    return $self->getFieldValue('start_date');
}

sub setStartDate{
    #
    # set start_date field
    #

    my ($self, $value) = @_;
    if (!defined($value)){
	$value = HSDB4::DateTime->new()->out_mysql_timestamp()
    }

    $self->setFieldValue('start_date', $value);
}


sub getEndDate{
    #
    # get end_date field
    #

    my ($self) = @_;
    return $self->getFieldValue('end_date');
}

sub setEndDate{
    #
    # set end_date field
    #

    my ($self, $value) = @_;
    if (!defined($value)){
	$value = HSDB4::DateTime->new()->out_mysql_timestamp()
    }
    $self->setFieldValue('end_date', $value);
}


sub setPreviewFlag {
    my ($self,$value) = @_;
    $self->setFieldValue('preview_flag', $value);
}


sub getPreviewFlag {
    my ($self) = @_;
    return $self->getFieldValue('preview_flag');
}


sub getScore {
	my $self = shift;
	my $responses = $self->getResponses();
	my $score = 0;

	foreach my $response (@{$responses}) {
	    $score += $response->getGradedPoints();
	}
	return ((int (100 * ($score + 0.005 * ($score <=> 0)))) / 100); # round the score to two decimal places
}

sub needsGrading {
	my $self = shift;
	my $responses = $self->getResponses(); 
        foreach my $response (@{$responses}){
                unless ($response->getGradedFlag()) {
			return 1;
                }
        }
	return 0;
}

### Other Methods

sub addUpdateResponse{
    my ($self, $user, $response) = @_;

    my $retval = $response->save({ user => $user });

    if ($retval != 0){
	push (@{$self->getResponses}, $response);
    }
    
    return($retval);
}

sub pushResponse{
    # 
    # Used when doing lookups to push answer objects
    #

    my ($self, $response) = @_;
    push (@{$self->getResponses}, $response);
}

sub getResponse{
    my ($self, $index) = @_;  
    return @{$self->getResponses}[$index];
}

sub lookupResponses {
    my ($self,$question_arrayref) = @_;
    my (@questionids,$index,%ids);
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

    my $response_arrayref = TUSK::Quiz::Response->new->passValues($self)->lookup(
			"link_id IN (" . join(",", @questionids) . ")", ["link_id", "sort_order"]);
    
    foreach my $response (@{$response_arrayref}){
	my $questionid = $response->getQuestionID();
	my $index = $ids{$questionid};
	my $obj;

	if ($flag eq "question"){
	    $obj = @$question_arrayref[$index];
	}else{
	    $obj = @$question_arrayref[$index]->getQuestionObject();
	}
    }

    return $question_arrayref;
}

sub getResponses{
    my $self = shift;
    my $flag = shift || '';
    if ($flag eq 'check_db' or !exists $self->{_responses}){
	$self->{_responses} = TUSK::Quiz::Response->new->passValues($self)->lookup(
										   "quiz_result_id = " . $self->getPrimaryKeyID, 
										   ["quiz_response_id"]);

    }
    return $self->{_responses};
}

sub defineResponses{
    my ($self) = @_;
    unless (exists $self->{_responses}){
	$self->{_responses} = [];
    }
}

sub createResponses{
#
#  Responses is a hash ref, the key is a link_quiz_quiz_item_id and the value is the response_text
#  QuizItems is a hash ref, the key is a link_quiz_quiz_item and the value is the relevant quiz_item
#
    my ($self, $user, $quizItems, $responses, $link_type) = @_;
    $link_type = 'link_quiz_quiz_item' unless defined $link_type;
    $self->defineResponses;

    my $quiz_id = $self->getQuizID;
    my $result_id = $self->getPrimaryKeyID;

    foreach my $key (keys %$quizItems){
	my $quizItem = $quizItems->{$key};
	my $question = $quizItem->getQuestionObject();

	if ($question->getType() eq "Matching" or $question->getType() eq "Section" or $question->getType() eq "MultipleFillIn"){
	    $self->createResponses($user, $question->getSubQuestionLinks("hash"), $responses, "link_question_question");	    
	} else {
	    my $quiz = TUSK::Quiz::Quiz->lookupKey($quiz_id);
	    my $response = TUSK::Quiz::Response->lookupReturnOne("quiz_result_id = $result_id and link_id = " . $quizItem->getPrimaryKeyID() . " and link_type = '$link_type'");
	    $response = TUSK::Quiz::Response->new() unless (defined $response);
		
	    $response->setFieldValues({
		quiz_result_id => $result_id,
		graded_flag  => 0,
		link_id      => $quizItem->getPrimaryKeyID(),
		link_type    => $link_type,
		response_text  => $responses->{$question->getPrimaryKeyID()} });

	    my $answers = $question->getAnswers() || [];

	    if ($response->getResponseText() && $question->getType() !~ /^FillIn|Essay$/) {
		### leave the graded flag undef in case of no answers or matching child
		$response->setGradedFlag(1) if ($answers && scalar @$answers);

		foreach my $answer (@{$answers}){
		    ### response_text is still a primarky key id of the answer
		    ### then reset the response text based on the answer object
		    if ($response->getResponseText() == $answer->getPrimaryKeyID()){

			$response->setFieldValues({
			    graded_points  => $answer->getCorrect() * $quizItem->getPoints(),
			    quiz_answer_id => $answer->getPrimaryKeyID(),
			    response_text  => $answer->getValue() });
			last;
		    }
		}
	    }
	    $self->addUpdateResponse($user, $response);
	}
    }

}

    
sub trim{
    my ($string) = @_;
    $string =~ s/^\s*//;
    $string =~ s/\s*$//;
    return $string;
}

sub findOpenResult{
	my ($user_id,$quiz_id,$preview) = @_;
	my $cond = sprintf (" user_id = '%s' AND quiz_id = %d AND preview_flag = %d AND end_date IS NULL", $user_id, $quiz_id, $preview);
	my $results = TUSK::Quiz::Result->lookup($cond,undef,undef); 

	if (scalar(@{$results}) > 1){
		my $found_response = 0;
		my $is_first = 1;
		my $correct_result;
		foreach my $result ( @{$results} ) {
			my $response = $result->getResponses( 'check_db' );

			if ( scalar(@{$response}) ) {
				$found_response++;
				$correct_result = $result;
			} elsif ( !$is_first ) {
				$result->delete();
			}

			if ($is_first) {
				$correct_result = $result;
			}

			$is_first = 0;
		}
		if ( $found_response > 1 ) {
			croak "There are multiple open quizes for user $user_id in quiz $quiz_id that have responses entered";
		} else {
			return $correct_result;
		}
	} else {
		return pop @{$results};
	}
}


sub isOverdue{
	my $self = shift;
	my ($quiz_id,$result_id) = ($self->getQuizID(), $self->getPrimaryKeyID());
	my $sth = $self->databaseSelect(<<EOM);

SELECT 1
FROM tusk.quiz_result r, 
tusk.quiz q
WHERE r.quiz_result_id = $result_id  AND
q.quiz_id = r.quiz_id AND
q.quiz_id = $quiz_id AND
q.duration != '00:00:00' AND
((UNIX_TIMESTAMP(r.end_date) - UNIX_TIMESTAMP(r.start_date)) > TIME_TO_SEC(q.duration))

EOM
	my $results = $sth->fetchrow_array(); 
	$sth->finish();
        return ($results) ? 1 : 0;
}


sub cleanupResponses {
    my $self = shift;

    if ($self->getPrimaryKeyID()) {
	foreach my $resp (@{$self->getResponses()}) {
	    $resp->delete();
	}
    }
}


sub areRandomQuestionsModified {
    my $self = shift;

    return 0 unless $self->getPreviewFlag();

    my $randoms = TUSK::Quiz::RandomQuestion->lookup("quiz_id = " . $self->getQuizID() . " and user_id = '" . $self->getUserID() . "'");
    my $regulars = TUSK::Quiz::LinkQuizQuizItem->lookup("quiz_id = " . $self->getQuizID());
    return 0 unless (defined $randoms && scalar @$randoms);

    my %random_list = map { $_->getQuizQuestionID() => 1 } @$randoms;
    my %regular_list = map { $_->getQuizItemID() => 1 } @$regulars;
    
    foreach my $key (keys %random_list) {
	return 1 unless exists $regular_list{$key};
    }

    foreach my $key (keys %regular_list) {
	return 1 unless exists $random_list{$key};
    }

    return 0;
}


sub deleteRandomQuestions {
    my $self = shift;

    my $randoms = TUSK::Quiz::RandomQuestion->lookup("quiz_id = " . $self->getQuizID() . " and user_id = '" . $self->getUserID() . "'");

    foreach my $random_question (@$randoms) {
	my $retval = $random_question->delete();
	croak "Failed to delete records for quiz id " . $self->getQuizID() . " from random question table\n" unless $retval;
    }
}


1;
