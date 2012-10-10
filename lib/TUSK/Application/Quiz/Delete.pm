package TUSK::Application::Quiz::Delete;

use strict;
use warnings;
use TUSK::Quiz::Quiz;
use TUSK::Quiz::LinkQuizQuizItem;
use TUSK::Quiz::LinkQuestionQuestion;
use TUSK::Quiz::Answer;

sub new {
    my ($class, $args) = @_;

    my $self = {
	_quiz_id       => $args->{quiz_id},
	_user          => $args->{user} || 'tusk',
    };

    bless($self, $class);
    return $self;
}


sub deleteSomeQuestions {
   my ($self, $question_keys) = @_;

   foreach (@$question_keys) {
       my ($type, $id, $question_id) = split('_', $_);
       my $question = TUSK::Quiz::Question->new()->lookupKey($question_id);
       print "$type, $id, $question_id<br/>";
       next unless defined $question;
       my $qlink;

       if ($type eq 'linkquiz'){
		$qlink = shift @{TUSK::Quiz::LinkQuizQuizItem->new()->lookupByRelation($id, $question_id)};
	} elsif ($type eq 'linkquestion'){
		$qlink = shift @{TUSK::Quiz::LinkQuestionQuestion->new()->lookupByRelation($id, $question_id)};
	}

	$qlink->delete();

	# only delete question if it is not used anywhere else
	my $item_links = TUSK::Quiz::LinkQuizQuizItem->new()->lookup("quiz_item_id = $question_id");
	unless (scalar(@$item_links)){
	    my $qq_links = TUSK::Quiz::LinkQuestionQuestion->new()->lookup("child_question_id = $question_id");
	    unless (scalar(@$qq_links)) {
		$question->delete();
	    }
	}
   }
}


1;
