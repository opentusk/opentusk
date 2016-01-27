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


package HSDB45::Eval::Question::MergedResults;

use strict;

use HSDB45::Eval::Question;
use HSDB45::Eval::MergedResults;
use HSDB45::Eval::Question::ResponseGroup;

use vars qw/%TypeClass $VERSION/;

$VERSION = do { my @r = (q$Revision: 1.4 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
sub version { return $VERSION; }

my @mod_deps  = ('HSDB45::Eval::Question',
     'HSDB45::Eval::MergedResults',
     'HSDB45::Eval::Question::ResponseGroup');
my @file_deps = ();

sub get_mod_deps  { return @mod_deps }
sub get_file_deps { return @file_deps }




BEGIN {
    %TypeClass = ( 'Title'                 => 'HSDB45::Eval::Question::MergedResults::None',
       'Instruction'           => 'HSDB45::Eval::Question::MergedResults::None',
       'MultipleResponse'      => 'HSDB45::Eval::Question::MergedResults::MultipleDiscrete',
       'MultipleChoice'        => 'HSDB45::Eval::Question::MergedResults::Discrete',
       'Count'                 => 'HSDB45::Eval::Question::MergedResults::Discrete',
       'DiscreteNumeric'       => 'HSDB45::Eval::Question::MergedResults::DiscreteNumeric',
       'NumericRating'         => 'HSDB45::Eval::Question::MergedResults::DiscreteNumeric',
       'PlusMinusRating'       => 'HSDB45::Eval::Question::MergedResults::DiscreteNumeric',
       'YesNo'                 => 'HSDB45::Eval::Question::MergedResults::Discrete',
       'Ranking'               => 'HSDB45::Eval::Question::MergedResults::Textual',
       'TeachingSite'          => 'HSDB45::Eval::Question::MergedResults::Discrete',
       'SmallGroupsInstructor' => 'HSDB45::Eval::Question::MergedResults::Discrete',
       'IdentifySelf'          => 'HSDB45::Eval::Question::MergedResults::Textual',
       'FillIn'                => 'HSDB45::Eval::Question::MergedResults::Textual',
       'LongFillIn'            => 'HSDB45::Eval::Question::MergedResults::Textual',
       'NumericFillIn'         => 'HSDB45::Eval::Question::MergedResults::Numeric',
       );

    require HSDB45::Eval::Question::MergedResults::None;
    require HSDB45::Eval::Question::MergedResults::MultipleDiscrete;
    require HSDB45::Eval::Question::MergedResults::Discrete;
    require HSDB45::Eval::Question::MergedResults::DiscreteNumeric;
    require HSDB45::Eval::Question::MergedResults::Numeric;
    require HSDB45::Eval::Question::MergedResults::Textual;
}

# Description: Constructor
# Input: HSDB45::Eval::Question object and HSDB45::Eval::MergedResults
# Output: HSDB45::Eval::Question::Results object
sub new {
    my $class = shift;
    $class = ref $class || $class;
    my $self = {};
    bless $self, $class;
    return $self->init (@_);
}

sub init ($$) {
    my $self = shift;

    $self->{-eval_question} = shift;
    unless($self->question()->isa("HSDB45::Eval::Question")) {
        die "Was expecting an HSDB45::Eval::Question object, but got " . ref($self->question());
    }
    $self->{-eval_results} = shift;
    unless($self->eval_results()->isa("HSDB45::Eval::MergedResults")) {
        die "Was expecting an HSDB45::Eval::MergedResults object, but got " . ref($self->eval_results());
    }

    $self->{-all_resps} = HSDB45::Eval::Question::ResponseGroup->new($self, "__ALL__");
    # First, rebless to the right results type
    my $type = $self->question()->body()->question_type ();
    if ($type && $TypeClass{$type}) { bless $self, $TypeClass{$type} }
    else { die "Cannot figure out the question type." }
    $self->lookup_responses;
    return $self;
}

sub question {
    my $self = shift();
    return $self->{-eval_question};
}

sub eval_results {
    my $self = shift();
    return $self->{-eval_results};
}

# Description: Looks up the responses from the database
# Input:
# Output:
sub lookup_responses {
    my $self = shift;
    my $question = $self->question();
    my $results = $self->eval_results();
    my $eval = $results->parent_eval();
    my $eval_ids = join(',', $results->primary_eval_id(), $results->secondary_eval_ids());
    my @conds = ("eval_id IN ($eval_ids)", 'eval_question_id = ' . $question->primary_key());
    if ($eval->is_teaching_eval()) {
        my $evaluatee_id = $results->evaluatee_id();
        return if ($self->isa('HSDB45::Eval::Question::MergedResults::Textual') && !$evaluatee_id);
        my $user_codes = join("','", $self->eval_results()->user_codes());
        push @conds, "user_code IN ('$user_codes')";
    }
    my $blankresp = HSDB45::Eval::Question::Response->new (_school => $self->question->school);
    for my $resp ($blankresp->lookup_conditions (@conds)) {
        $resp->set_aux_info ('parent_results' => $self);
        $self->{-all_resps}->add_response ($resp);
    }
    return;
}

1;
__END__
