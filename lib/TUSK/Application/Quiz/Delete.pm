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
