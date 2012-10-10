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


package TUSK::Case::RuleOperand;

=head1 NAME

B<TUSK::Case::RuleOperand> - Class for manipulating entries in table case_rule_operand in tusk database

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

    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
    
    @ISA = qw(TUSK::Core::SQLRow Exporter);
    @EXPORT = qw( );
    @EXPORT_OK = qw( );
}

use vars @EXPORT_OK;

# Non-exported package globals go here
use vars ();

use Carp;
use TUSK::Case::RuleElementType;
use TUSK::Case::RuleOperandRelation;
use TUSK::Case::LinkPhaseQuiz;
use TUSK::Case::Phase;
use TUSK::Case::PhaseVisit;
use TUSK::Case::PhaseOptionSelection;
use TUSK::Quiz::LinkQuizQuizItem;
use TUSK::Quiz::LinkQuestionQuestion;
use TUSK::Quiz::Response;
use TUSK::Quiz::Question;

sub new {
    # Find out what class we are
    my $class = shift;
    $class = ref $class || $class;
    # Call the super-class's constructor and give it all the values
    my $self = $class->SUPER::new ( 
				    _datainfo => {
					'database' => 'tusk',
					'tablename' => 'case_rule_operand',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'rule_operand_id' => 'pk',
					'rule_id' => '',
					'phase_id' => '',
					'element_id' => '',
					'rule_element_type_id' => '',
				    },
				    _attributes => {
					save_history => 1,
					tracking_fields => 1,	
				    },
				    _levels => {
					reporting => 'cluck',
					error => 0,
				    },
				    _default_join_objects => [
				    TUSK::Core::JoinObject->new('TUSK::Case::RuleOperandRelation', { joinkey => 'rule_operand_id', origkey => 'rule_operand_id' } )
				    ],
				    @_
				  );
    # Finish initialization...
    return $self;
}

### Get/Set methods

#######################################################

=item B<getRuleID>

my $string = $obj->getRuleID();

Get the value of the rule_id field

=cut

sub getRuleID{
    my ($self) = @_;
    return $self->getFieldValue('rule_id');
}

#######################################################

=item B<setRuleID>

$obj->setRuleID($value);

Set the value of the rule_id field

=cut

sub setRuleID{
    my ($self, $value) = @_;
    $self->setFieldValue('rule_id', $value);
}


#######################################################

=item B<getPhaseID>

my $string = $obj->getPhaseID();

Get the value of the phase_id field

=cut

sub getPhaseID{
    my ($self) = @_;
    return $self->getFieldValue('phase_id');
}

#######################################################

=item B<setPhaseID>

$obj->setPhaseID($value);

Set the value of the phase_id field

=cut

sub setPhaseID{
    my ($self, $value) = @_;
    $self->setFieldValue('phase_id', $value);
}


#######################################################

=item B<getElementID>

my $string = $obj->getElementID();

Get the value of the element_id field

=cut

sub getElementID{
    my ($self) = @_;
    return $self->getFieldValue('element_id');
}

#######################################################

=item B<setElementID>

$obj->setElementID($value);

Set the value of the element_id field

=cut

sub setElementID{
    my ($self, $value) = @_;
    $self->setFieldValue('element_id', $value);
}


#######################################################

=item B<getRuleElementTypeID>

my $string = $obj->getRuleElementTypeID();

Get the value of the rule_element_type_id field

=cut

sub getRuleElementTypeID{
    my ($self) = @_;
    return $self->getFieldValue('rule_element_type_id');
}

#######################################################

=item B<setRuleElementTypeID>

$obj->setRuleElementTypeID($value);

Set the value of the rule_element_type_id field

=cut

sub setRuleElementTypeID{
    my ($self, $value) = @_;
    $self->setFieldValue('rule_element_type_id', $value);
}



=back

=cut

### Other Methods


=item B<getElementType>

my $obj = $obj->getElementType();

Get the RuleElmentType obj associated with this operand

=cut

sub getElementType{
    my ($self) = @_;
	my $elt_type = TUSK::Case::RuleElementType->new()->lookupKey($self->getRuleElementTypeID());

	return $elt_type;
}


#######################################################


=item B<getRelationTypeID>

$id = $obj->getRelationTypeID();

Get the rule_relation_type field from RuleOperandRelation 
obj associated with this operand, or undef if no such 
associated object.

=cut
       
sub getRelationTypeID{
    my ($self) = @_;

	if ($self->checkJoinObject('TUSK::Case::RuleOperandRelation')) {
		my $relation = $self->getJoinObject('TUSK::Case::RuleOperandRelation');
		return $relation->getRuleRelationTypeID();
	}
	else {
		return undef;
	}
}


#######################################################


=item B<setRelationTypeID>

$obj->setRelationTypeID($id);

Set the relation_type field from RuleOperandRelation 
obj associated with this operand.

=cut
       
sub setRelationTypeID{
    my ($self, $type_id) = @_;

	if (defined $type_id && $type_id) {
		my $relation;
		unless ($self->checkJoinObject('TUSK::Case::RuleOperandRelation')) {
			$relation = TUSK::Case::RuleOperandRelation->new();
			$self->pushJoinObject('TUSK::Case::RuleOperandRelation', $relation);
		}
		else {
			$relation = $self->getJoinObject('TUSK::Case::RuleOperandRelation');
		}

		$relation->setRuleRelationTypeID($type_id);
	}
}


#######################################################


=item B<getRelationValue>

$obj->getRelationValue($value);

Get the value field in RuleOperandRelation obj 
associated with this operand, or undef if no such 
associated object.

=cut

sub getRelationValue{
    my ($self) = @_;

	if ($self->checkJoinObject('TUSK::Case::RuleOperandRelation')) {
		my $relation = $self->getJoinObject('TUSK::Case::RuleOperandRelation');
		return $relation->getValue();
	}
	return undef;
}


#######################################################


=item B<setRelationValue>

$obj->setRelationValue($value);

Set the value field in RuleOperandRelation obj associated with this operand.

=cut

sub setRelationValue{
    my ($self, $value) = @_;

	# s.o. box calls this for every operand, regardless of whether a relation should be established
	# for a given operand. therefore, make sure that we have a value, and
	# that the value is an integer before creating join obj.
	if (defined $value && $value =~ /^-?\d+\z/) {
		my $relation;
		unless ($self->checkJoinObject('TUSK::Case::RuleOperandRelation')) {
			$relation = TUSK::Case::RuleOperandRelation->new();
			$self->pushJoinObject('TUSK::Case::RuleOperandRelation', $relation);
		}
		else {
			$relation = $self->getJoinObject('TUSK::Case::RuleOperandRelation');
		}
		
		$relation->setValue($value);
	}
}


#######################################################


=item B<save>

$obj->save($params);

When saving a RuleOperand, make sure we save any joined RuleOperandRelation objects.

=cut

sub save{
    my ($self, $params) = @_;

	$self->SUPER::save($params);

	if ($self->checkJoinObject('TUSK::Case::RuleOperandRelation')) {
		my $relation = $self->getJoinObject('TUSK::Case::RuleOperandRelation');
		$relation->setRuleOperandID($self->getPrimaryKeyID());
		$relation->save($params);
	}
}


#######################################################


=item B<delete>

$obj->delete($params);

When deleting a RuleOperand, make sure we delete any joined RuleOperandRelation objects.

=cut

sub delete{
    my ($self, $params) = @_;

	if ($self->checkJoinObject('TUSK::Case::RuleOperandRelation')) {
		my $relation = $self->getJoinObject('TUSK::Case::RuleOperandRelation');
		$relation->delete($params);
	}

	$self->SUPER::delete($params);
}


#######################################################


=item B<getElementTypeLabel>

my $str = $obj->getElementTypeLabel();

Return the label for the element type that is referenced in this 
rule, or undef if there is no element type.

=cut

sub getElementTypeLabel{
    my $self = shift;

	my $lbl;
	if ($self->getRuleElementTypeID()) {
		my $type_obj = $self->getElementType();
		$lbl = $type_obj->getLabel();
	}
	
	return $lbl;
}


#######################################################


=item B<evaluatePhaseVisit>

my $int = $obj->evaluatePhaseVisit($report);

Given the context of a case report, return true if the 
phase id specified in the operand has been visited.

=cut

sub evaluatePhaseVisit{
    my ($self, $report) = @_;

	my $v = TUSK::Case::PhaseVisit->new()->lookup('case_report_id=' . $report->getPrimaryKeyID() . ' AND case_phase_visit.phase_id=' . $self->getPhaseID());
	return scalar @$v;	
}


#######################################################


=item B<evaluateOption>

my $int = $obj->evaluateOption($report);

Given the context of a case report, return true if the 
option specified in the operand has been selected in the
most recent phase visit to the treatment type phase.

=cut

sub evaluateOption{
    my ($self, $report) = @_;

	my $opt_phase = TUSK::Case::Phase->lookupKey($self->getPhaseID());
	my $visit = $opt_phase->getLastVisitWithSelections($report);
		
	if (defined $visit) {
		my $selection = TUSK::Case::PhaseOptionSelection->lookupReturnOne
			( 'case_report_id='       . $report->getPrimaryKeyID() 
			. ' AND phase_id='        . $self->getPhaseID() 
			. ' AND phase_visit_id='  . $visit->getPrimaryKeyID() 
			. ' AND phase_option_id=' . $self->getElementID()
			);
		if (defined $selection) {
			return 1;
		}
	}
	return 0;
}


#######################################################


=item B<evaluateTest>

my $int = $obj->evaluateTest($report);

Given the context of a case report, return true if the 
test specified in the operand has been selected in the 
relevant phase.

=cut

sub evaluateTest{
    my ($self, $report) = @_;

	my $test_phase = TUSK::Case::Phase->lookupKey($self->getPhaseID());
	my $selections = $test_phase->getPhaseTestSelections($report);

	if (scalar @$selections) {
		my $elt_id = $self->getElementID();
		foreach my $s (@$selections) {
			if ($s->getTestID() == $elt_id) {
				return 1;
			}
		}
	}
	return 0;
}


#######################################################


=item B<evaluateQuiz>

my $int = $obj->evaluateQuiz($report);

Given the context of a case report, return true if the 
quiz specified in the operand has been completed.

=cut

sub evaluateQuiz{
    my ($self, $report) = @_;

	return $report->hasCompletedQuiz($self->getElementID());
}


#######################################################


=item B<evaluateQuizQuestion>

my $int = $obj->evaluateQuizQuestion($report);

Given the context of a case report, return true if the 
quiz question specified in the operand has been answered
correctly in the most recently started quiz report, as long as
this report has been completed.
This means that if a user starts a quiz, but doesn't submit, the
question will not be deemed to have been answered correctly. To
emphasize the point, in order to evaluate a question's correctness,
the most recently started quiz report must have been completed.

=cut

sub evaluateQuizQuestion{
	my ($self, $report) = @_;

	my $quizlink = TUSK::Case::LinkPhaseQuiz->new()->lookupReturnOne('parent_phase_id=' . $self->getPhaseID());
	my $quiz_result = $report->getCompletedQuiz($quizlink->getChildQuizID());

	if (defined $quiz_result) {
		# questions are unique and are either linked from a quiz, or from another question.
		# therefore, see if linked from quiz first, if not, get question link.
		my $link = TUSK::Quiz::LinkQuizQuizItem->lookupReturnOne('quiz_item_id=' . $self->getElementID());
		unless (defined $link) {
			$link = TUSK::Quiz::LinkQuestionQuestion->lookupReturnOne('child_question_id=' . $self->getElementID());
		}

		my $response = TUSK::Quiz::Response->lookupReturnOne('quiz_result_id=' . $quiz_result->getPrimaryKeyID() . " AND link_type='" . $link->getTablename() . "' AND link_id=" . $link->getPrimaryKeyID());

		if (defined $response) {
			my $question = TUSK::Quiz::Question->new()->lookupKey($self->getElementID());
			my $correct_a = $question->getCorrectAnswer();
			if ($response->getAnswerID() ==  $correct_a->getPrimaryKeyID()) {
				return 1;
			}
		}
	}
	return 0;
}


#######################################################


=item B<evaluateQuizScore>

my $int = $obj->evaluateQuizScore($report);

Given the context of a case report, return true if the 
quiz score specified is less than or equal to the score
received by the student in the most recently started
quiz report (this means that if a user starts a quiz, 
but doesn't submit, they will not evaluate to true since
they won't be considered to have a score - even if they
had previously submitted the quiz earlier in this same
case report).

=cut

sub evaluateQuizScore{
    my ($self, $report) = @_;

	my $quizlink = TUSK::Case::LinkPhaseQuiz->new()->lookupReturnOne('parent_phase_id=' . $self->getPhaseID());
	my $quiz_result = $report->getCompletedQuiz($quizlink->getChildQuizID());
	
	if (defined $quiz_result) {
		my $rel_val = $self->getRelationValue();
		my $score = $quiz_result->getScoreAsPercentage();
		if ($score >= $rel_val) {
			return 1;
		}
	}
	return 0;
}


#######################################################


=item B<evaluatesTrue>

my $int = $obj->evaluatesTrue($report);

Given the context of a case report, return true if the 
operand has been satisfied.

=cut

sub evaluatesTrue{
    my ($self, $report) = @_;

	my $type = $self->getElementTypeLabel();

	if (!defined $type) {
		return $self->evaluatePhaseVisit($report);
	}
	elsif ($type eq 'option') {
		return $self->evaluateOption($report);
	}
	elsif ($type eq 'test') {
		return $self->evaluateTest($report);
	}
	elsif ($type eq 'quiz') {
		return $self->evaluateQuiz($report);
	}
	elsif ($type eq 'quiz_question') {
		return $self->evaluateQuizQuestion($report);
	}
	elsif ($type eq 'quiz_score') {
		return $self->evaluateQuizScore($report);
	}

	# we should not get here. however, if there is a problem, we should probably alert 
	# developers with an error.
	confess "we were not able to appropriately evaluate this operand";
}


#######################################################


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

