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


package TUSK::Quiz::Answer;

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

use TUSK::Constants;

# Creation methods

sub new {
    # Find out what class we are
    my $class = shift;
    $class = ref $class || $class;
    # Call the super-class's constructor and give it all the values
    my $self = $class->SUPER::new ( 
				    _datainfo => {
					database => "tusk",
					tablename => "quiz_answer",
					usertoken => "ContentManager",
				    },
				    _field_names => {
					'quiz_answer_id' => 'pk',
					'quiz_question_id' => '',
					'child_question_id' => '',
					'label' => '',
					'sort_order' => '',
					'correct' => '',
					'value' => '',
					'feedback' => 'skip',
					'hint' => 'skip'
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

sub getQuestionID{
    my $self = shift;
    return $self->getFieldValue('quiz_question_id');
}

sub setQuestionID{
    my $self = shift;
    my $value = shift;
    $self->setFieldValue('quiz_question_id', $value);
}

sub getChildQuestionID{
    my $self = shift;
    return $self->getFieldValue('child_question_id');
}

sub setChildQuestionID{
    my $self = shift;
    my $value = shift;
    $self->setFieldValue('child_question_id', $value);
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

sub getSortOrder{
    my $self = shift;
    return $self->getFieldValue('sort_order');
}

sub setSortOrder{
    my $self = shift;
    my $value = shift;
    $self->setFieldValue('sort_order', $value);
}

sub getValue{
    my $self = shift;
    return $self->getFieldValue('value');
}

sub setValue{
    my $self = shift;
    my $value = shift;
    $self->setFieldValue('value', $value);
}

sub getCorrect{
    my $self = shift;
    return $self->getFieldValue('correct');
}

sub setCorrect{
    my $self = shift;
    my $value = shift;
    $self->setFieldValue('correct', $value);
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

sub getHint{
    my $self = shift;
    return $self->getFieldValue('hint');
}

sub setHint{
    my $self = shift;
    my $value = shift;
    $self->setFieldValue('hint', $value);
}

sub isCorrect {
        my $self = shift;
        if ($self->getCorrect()){
                return 1;
        }
        return 0;

}

sub getChildQuestionBody{
    my ($self, $child_question_id) = @_;
    
    my $child_question = TUSK::Quiz::Question->new()->lookupKey($child_question_id);
    return '' if (ref($child_question) ne 'TUSK::Quiz::Question' || !$child_question->getPrimaryKeyID());
    return $child_question->getBody();
}

1;


