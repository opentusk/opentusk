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


package HSDB45::EvalTest;

use strict;
use base qw/Test::Unit::TestCase/;
use Test::Unit;

use HSDB45::Eval;
use HSDB45::Eval::Question;
use HSDB45::Eval::Authoring;
use MySQL::Password;
use Carp;

my $SCHOOL = 'regress';
my @TYPES = ('NumericRating', 'FillIn', 'MultipleChoice', 'YesNo', 'DiscreteNumeric');
my @ORDERINGS = (1, 2, 3, 5, 8);
my @LABELS = (1, 2, 3, 4, 5);
my @REQUIREDS = ("no", "no", "no", "no", "no");

sub sql_files {
    return qw(base_course.sql base_time_period.sql base_user_group.sql);
}

sub new {
    my $self = shift()->SUPER::new(@_);
    return $self;
}

# a convenience wrapper for Eval::Authoring::create_question
sub create_question {
    my ($eval, $type, $qid_after) = @_;
    my $qid = HSDB45::Eval::Authoring::create_question($SCHOOL, get_user_pw(),
						       $eval, $type, $qid_after);
    return $qid;
}

# a convenience wrapper for Eval::Authoring::do_questions_edits
sub edit_question {
    my ($eval, $qid, $sort_order, $label, $required) = @_;
    my $question = $eval->question($qid);
    my $fdat = HSDB45::Eval::Authoring::build_fdat($qid, $sort_order,
						   $label, $required);
    return HSDB45::Eval::Authoring::do_question_edits(get_user_pw(), $eval,
						      $question, $fdat);
}

# get the ID of a question created in set_up
sub get_qid {
    my $self = shift();
    my $offset = shift();
    return $self->{-qids}->[$offset];
}

# get the IDs of all questions created in set_up
sub get_qids {
    my $self = shift();
    return @{$self->{-qids}};
}

# record the ID of a question created in set_up
sub record_qid {
    my $self = shift();
    my $qid = shift();

    $self->{-qids} = [] unless $self->{-qids};
    push(@{$self->{-qids}}, $qid);
}

sub set_up {
    my $self = shift();
    my $eval = HSDB45::Eval->new(_school => $SCHOOL);

    # create the eval, and squirrel away its id
    $eval->field_value("title", "Unit Testing Eval");
    $eval->save(get_user_pw());
    $self->set_eval_id($eval->primary_key());

    # give the eval some questions


    my $qid = 0;
    for my $i (0..$#TYPES) {
	$qid = create_question($eval, $TYPES[$i], $qid);
	edit_question($eval, $qid, $ORDERINGS[$i], $LABELS[$i], $REQUIREDS[$i]);
	$self->record_qid($qid);
    }
}

sub tear_down {
}

# get the id of the eval created in the set_up method
sub get_eval_id {
    my $self = shift();
    return $self->{-eval_id};
}

# record the id of the eval created in set_up
sub set_eval_id {
    my $self = shift();
    my $eval_id = shift();
    assert($eval_id =~ /\d+/, "bogus  eval id: $eval_id");
    $self->{-eval_id} = $eval_id;
}

sub load_eval {
    my ($self) = @_;
    return HSDB45::Eval->new(_school => $SCHOOL, _id => $self->get_eval_id());
}

# verify the reapportion_orderings method from HSDB45::Eval
sub test_reapportion_orderings {
    my ($self) = @_;
    my $eval = $self->load_eval();

    # verify things before actually reapportioning
    my $offset = 0;
    foreach my $question ($eval->questions()) {
	my $recorded_qid = $self->get_qid($offset++);
	my $retrieved_qid = $question->primary_key();
	assert($recorded_qid == $retrieved_qid, "qid mismatch: ($recorded_qid, $retrieved_qid)");
    }

    $eval->reapportion_orderings();

    # verify things after the reapportioning
    my $expected_so = 10;
    foreach my $question ($eval->questions()) {
	my $retrieved_so = $question->aux_info('sort_order');
	assert($expected_so == $retrieved_so,
	       "sort_order mismatch: ($expected_so, $retrieved_so)");
	$expected_so += 10;
    }
}

sub test_label_generation {
    my ($self) = @_;
    my $eval = $self->load_eval();

    my $offset = 0;
    foreach my $question ($eval->questions()) {
	assert($question->label() eq $LABELS[$offset],
	       "label mismatch: (" . $question->label() . ", " . $LABELS[$offset]);
	++$offset;
    }

    $offset = 0;
    my @new_labels = ("auto", "auto", "foo");
    foreach my $question (($eval->questions())[2..4]) {
	my $sort_order = $question->aux_info('sort_order');
	my $required = $question->aux_info('required');
	edit_question($eval, $question->primary_key(),
		      $sort_order, $new_labels[$offset], $required);
	++$offset;
    }

    $offset = 0;
    my @auto_labels = (1, 2, 3, 4, "foo");
    my @real_labels = (1, 2, "auto", "auto", "foo");

    foreach my $question ($eval->questions()) {
	assert($question->label() eq $auto_labels[$offset],
	       "auto label mismatch: (" . $question->label() . ", "
	       . $auto_labels[$offset]);

	assert($question->get_real_label() eq $real_labels[$offset],
	       "real label mismatch: (" . $question->get_real_label() . ", "
	       . $real_labels[$offset]);

	++$offset;
    }
}

sub test_prep_for_insertion {
    my ($self) = @_;
    my $eval = $self->load_eval();

    my @qid_afters = (0, $self->get_qid(4), $self->get_qid(2), $self->get_qid(1));
    my @expected = (0, 18, 4, 25);

    # first, make sure that prep_for_insertion is returning stuff correctly
    for my $i (0..$#expected) {
	my $actual =
	    HSDB45::Eval::Authoring::prep_for_insertion(get_user_pw(),
							$eval, $qid_afters[$i]);
	assert($actual == $expected[$i],
	       "prep_for_insertion: actual=$actual expected=$expected[$i]");
    }
}

sub test_edit_question {
    my ($self) = @_;
    my $eval = $self->load_eval();

    my $question = $eval->question($self->get_qid(1));
    my $qid = $question->primary_key();

    my $fdat =
	HSDB45::Eval::Authoring::build_fdat($qid,
					    $question->aux_info('sort_order'),
					    $question->get_real_label(),
					    $question->aux_info('required'));
    $fdat->{"q_${qid}_preceding_qid"} = 0;
    HSDB45::Eval::Authoring::edit_question(get_user_pw(), $eval, $question, $fdat);

    assert(($eval->questions())[0]->primary_key() == $qid,
	   "unexpected qid: " . ($eval->questions())[0]->primary_key() . " $qid");

    $question = $eval->question($self->get_qid(2));
    $qid = $question->primary_key();

    $fdat =
	HSDB45::Eval::Authoring::build_fdat($qid,
					    $question->aux_info('sort_order'),
					    $question->get_real_label(),
					    $question->aux_info('required'));
    $fdat->{"q_${qid}_preceding_qid"} = $self->get_qid(3);
    HSDB45::Eval::Authoring::edit_question(get_user_pw(), $eval, $question, $fdat);

    assert(($eval->questions())[3]->primary_key() == $qid,
	   "unexpected qid: " . ($eval->questions())[3]->primary_key() . " $qid");

    $question = $eval->question($self->get_qid(4));
    $qid = $question->primary_key();

    $fdat =
	HSDB45::Eval::Authoring::build_fdat($qid,
					    $question->aux_info('sort_order'),
					    $question->get_real_label(),
					    $question->aux_info('required'));
    $fdat->{"q_${qid}_preceding_qid"} = $self->get_qid(3);
    HSDB45::Eval::Authoring::edit_question(get_user_pw(), $eval, $question, $fdat);

    assert(($eval->questions())[3]->primary_key() == $qid,
	   "unexpected qid: " . ($eval->questions())[3]->primary_key() . " $qid");
}

sub test_get_preceding_qid {
    my ($self) = @_;
    my $eval = $self->load_eval();

    my $pqid = $eval->get_preceding_qid($self->get_qid(0));
    assert($pqid == 0, "expecting 0, but got $pqid");

    for my $i (1..(scalar($eval->questions()) - 1)) {
	my $actual = $eval->get_preceding_qid($self->get_qid($i));
	my $expected = $self->get_qid($i - 1);
	assert($actual == $expected, "expecting $expected, but got $actual");
    }
}

sub test_automate_all_labels {
    my ($self) = @_;
    my $eval = $self->load_eval();

    $eval->automate_all_labels();

    foreach my $q ($eval->questions()) {
	assert($q->get_real_label() eq "auto",
	       "label should have been 'auto', but was "
	       . $q->get_real_label());
    }
}

1;
