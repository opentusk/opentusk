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


package TUSK::Quiz::Response;

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
					tablename => "quiz_response",
					usertoken => "ContentManager",
				    },
				    _field_names => {
					'quiz_response_id' => 'pk',
					'quiz_result_id' => '',
					'link_type' => '',
					'link_id' => '',
					'quiz_answer_id' => '',
					'response_text' => '',
					'graded_flag' => '',
					'graded_points' => '',
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

sub getResultID{
    #
    # get user_id field
    #

    my $self = shift;
    return $self->getFieldValue('quiz_result_id');
}

sub setResultID{
    #
    # set user_id field
    #

    my ($self, $value) = @_;
    $self->setFieldValue('quiz_result_id', $value);
}

sub getLinkType{
    #
    # get link_type field
    #

    my $self = shift;
    return $self->getFieldValue('link_type');
}

sub setLinkType{
    #
    # set link_type field
    #

    my ($self, $value) = @_;
    $self->setFieldValue('link_type', $value);
}


sub getLinkID{
    #
    # get link_id field
    #

    my $self = shift;
    return $self->getFieldValue('link_id');
}

sub setLinkID{
    #
    # set link_id field
    #

    my ($self, $value) = @_;
    $self->setFieldValue('link_id', $value);
}


sub getAnswerID{
    #
    # get start_date field
    #

    my $self = shift;
    return $self->getFieldValue('quiz_answer_id');
}

sub setAnswerID{
    #
    # set start_date field
    #

    my ($self, $value) = @_;
    $self->setFieldValue('quiz_answer_id', $value);
}


sub getResponseText{
    #
    # get end_date field
    #

    my $self = shift;
    return $self->getFieldValue('response_text');
}

sub setResponseText{
    #
    # set end_date field
    #

    my ($self, $value) = @_;
    $self->setFieldValue('response_text', $value);
}

sub getGradedFlag {
    #
    # get end_date field
    #

    my $self = shift;
    return $self->getFieldValue('graded_flag');
}

sub setGradedFlag {
    #
    # set end_date field
    #

    my ($self, $value) = @_;
    $self->setFieldValue('graded_flag', $value);
}

sub getGradedPoints{
    #
    # get graded_points field
    #

    my $self = shift;
    return $self->getFieldValue('graded_points');
}

sub setGradedPoints{
    #
    # set graded_points field
    #

    my ($self, $value) = @_;
    $self->setFieldValue('graded_points', $value);
}

sub getQuizItem {
	my $self = shift or confess "Object required for getQuizItem";
	unless ($self->{_quiz_item}){
	    if ($self->getLinkType() eq 'link_quiz_quiz_item'){
		my $quiz_item_link = TUSK::Quiz::LinkQuizQuizItem->lookupKey($self->getLinkID());
		$self->{_quiz_item} =  $quiz_item_link->getQuizItem();
	    }else{
		my $quiz_item_link = TUSK::Quiz::LinkQuestionQuestion->lookupKey($self->getLinkID());
		$self->{_quiz_item} =  $quiz_item_link->getQuizItem();
	    }
	}
	return $self->{_quiz_item};
 }

sub getAnswer{
	my $self = shift or croak "Need an object to proceed";
	unless ($self->{-answer}){
		if ($self->getAnswerID){
			$self->{-answer} = TUSK::Quiz::Answer->lookupKey($self->getAnswerID());
		}
	}
	return $self->{-answer};


}
### Other Methods

sub isCorrect {
    my $self = shift;
    return ($self->getPoints()) ? 1 : 0;
}

1;
