package TUSK::Quiz::LinkQuizQuizItem;

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

use TUSK::Quiz::Question;
use TUSK::Quiz::RandomQuestion;
use Carp;


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
					 tablename => "link_quiz_quiz_item",
					 usertoken => "ContentManager",
				     },
				     _field_names => {
					 'link_quiz_quiz_item_id' => 'pk',
					 'quiz_id' => '',
					 'quiz_item_id' => '',
					 'label' => '',
					 'sort_order' => '',
					 'points' => ''
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

sub getQuizID{
    my $self = shift;
    return $self->getFieldValue('quiz_id');
}

sub setQuizID{
    my $self = shift;
    my $value = shift;
    $self->setFieldValue('quiz_id', $value);
}

sub getQuizItemID{
    my $self = shift;
    return $self->getFieldValue('quiz_item_id');
}

sub setQuizItemID{
    my $self = shift;
    my $value = shift;
    $self->setFieldValue('quiz_item_id', $value);
}

sub getSortOrder{
    my $self = shift;
    return $self->getFieldValue('sort_order');
}

sub setSortOrder{
    my $self = shift;
    my $value = shift;
    $self->setFieldValue('sort_order', $value);
}

sub getLabel{
    my $self = shift;
    return $self->getFieldValue('label');
}

sub setLabel{
    my $self = shift;
    my $value = shift;
    $self->setFieldValue('label', $value);
}

sub getPoints{
    my $self = shift;
    return $self->getFieldValue('points');
}

sub setPoints{
    my $self = shift;
    my $value = shift;
    $self->setFieldValue('points', $value);
}

sub getQuestionObject{
    my ($self) = @_;
    return $self->getJoinObject("TUSK::Quiz::Question");
}

## link methods
sub getQuestions{
    #
    # method to grab questions based on some conditions
    #    

    my ($self, $cond, $orderby, $fields, $limit) = @_;
    $cond .= " and " if ($cond);
    $cond .= "quiz_question.quiz_question_id = link_quiz_quiz_item.quiz_item_id";

    $orderby = ["quiz_id","sort_order"] unless ($orderby);

    return ($self->lookup($cond, $orderby, $fields, $limit, [ TUSK::Core::JoinObject->new("TUSK::Quiz::Question", { origkey => 'quiz_item_id', joinkey => 'quiz_question_id'})]));
}

sub getRandomQuestions {
    # method to grab questions based on pre-defined random sort order

    my ($self, $quiz_id, $user_id) = @_;
    my $questions = TUSK::Quiz::RandomQuestion->new()->lookup("quiz_id = $quiz_id and user_id = '$user_id'");
    
    unless (defined $questions && scalar @{$questions}) {
	$self->createRandomQuestions($quiz_id, $user_id);
    }

    my $cond = "link_quiz_quiz_item.quiz_id = $quiz_id AND quiz_question.quiz_question_id = link_quiz_quiz_item.quiz_item_id AND quiz_random_question.quiz_question_id = link_quiz_quiz_item.quiz_item_id AND quiz_random_question.user_id = '$user_id'";
    my $orderbys = ['quiz_random_question.sort_order'];

    return ($self->lookup($cond, $orderbys, undef, undef, [ TUSK::Core::JoinObject->new("TUSK::Quiz::Question", { origkey => 'quiz_item_id', joinkey => 'quiz_question_id'}),  TUSK::Core::JoinObject->new("TUSK::Quiz::RandomQuestion", { origkey => 'quiz_item_id', joinkey => 'quiz_question_id'})]));
}

sub createRandomQuestions {
    my ($self, $quiz_id,$user_id) = @_;
    my $links = $self->lookup("quiz_id = $quiz_id order by rand()");
    my $i = 1;
    foreach my $link (@{$links}) {
	my $random = TUSK::Quiz::RandomQuestion->new();
	$random->setFieldValues({ quiz_id => $quiz_id, user_id => $user_id, quiz_question_id => $link->getQuizItemID(), sort_order=> $i });
	$random->save({'user' => $user_id});
	$i++;
    }
}

sub getQuizItem{
	my $self = shift;
	return TUSK::Quiz::Question->lookupKey($self->getQuizItemID());
}

sub lookupByRelation {
	my ($self,$quiz_id,$quiz_item_id) = @_; 
	return $self->lookup("quiz_id = $quiz_id and quiz_item_id = $quiz_item_id");
}


1;
