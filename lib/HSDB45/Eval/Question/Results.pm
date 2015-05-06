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


package HSDB45::Eval::Question::Results;

use strict;
use HSDB45::Eval::Question;
use HSDB45::Eval::Question::Response;
use HSDB45::Eval::Question::ResponseGroup;
use HSDB45::Eval::Question::ResponseStatistics;
use HSDB45::Eval::Question::Categorization;
use vars qw($VERSION);
use vars qw/%TypeClass/;
use overload '3way_comparison' => \&sort_order_compare;

BEGIN {
    %TypeClass = ( 'Title'                 => 'HSDB45::Eval::Question::Results::None',
		   'Instruction'           => 'HSDB45::Eval::Question::Results::None',
		   'MultipleResponse'      => 'HSDB45::Eval::Question::Results::MultipleDiscrete',
		   'MultipleChoice'        => 'HSDB45::Eval::Question::Results::Discrete',
		   'Count'                 => 'HSDB45::Eval::Question::Results::Discrete',
		   'DiscreteNumeric'       => 'HSDB45::Eval::Question::Results::DiscreteNumeric',
		   'NumericRating'         => 'HSDB45::Eval::Question::Results::DiscreteNumeric',
		   'PlusMinusRating'       => 'HSDB45::Eval::Question::Results::DiscreteNumeric',
		   'YesNo'                 => 'HSDB45::Eval::Question::Results::Discrete',
		   'Ranking'               => 'HSDB45::Eval::Question::Results::Textual',
		   'TeachingSite'          => 'HSDB45::Eval::Question::Results::Discrete',
		   'SmallGroupsInstructor' => 'HSDB45::Eval::Question::Results::Discrete',
		   'IdentifySelf'          => 'HSDB45::Eval::Question::Results::Textual',
		   'FillIn'                => 'HSDB45::Eval::Question::Results::Textual',
		   'LongFillIn'            => 'HSDB45::Eval::Question::Results::Textual',
		   'NumericFillIn'         => 'HSDB45::Eval::Question::Results::Numeric',
		   );

    require HSDB45::Eval::Question::Results::None;
    require HSDB45::Eval::Question::Results::MultipleDiscrete;
    require HSDB45::Eval::Question::Results::Discrete;
    require HSDB45::Eval::Question::Results::DiscreteNumeric;
    require HSDB45::Eval::Question::Results::Numeric;
    require HSDB45::Eval::Question::Results::Textual;
}

sub version {
    return $VERSION;
}

# dependencies for things that relate to caching
my @mod_deps  = ();
my @file_deps;

sub get_mod_deps {
    return @mod_deps;
}

sub get_file_deps {
    return @file_deps;
}


# Description: Constructor
# Input: HSDB45::Eval::Question object and HSDB45::Eval::Results
# Output: HSDB45::Eval::Question::Results object
sub new {
    my $class = shift;
    $class = ref $class || $class;
    my $self = {};
    bless $self, $class;
    return $self->init (@_);
}

sub is_type_binnable {
    my $type = shift or return;
    my $typeclass = $TypeClass{$type} or return;
    return $typeclass->is_binnable();
}

# Description: Return an indication of whether this question's responses are binnable. The default is "false".
# Input:
# Output: False
# OVERRIDE!
sub is_binnable { return; }

# Description: Return an indication of whether this question's responses are numeric. The default is "false".
# Input:
# Output: False
# OVERRIDE!
sub is_numeric { return; }

# Description: Return an indication of whether this question's responses are multi-binnable.
# Input:
# Output: False
# OVERRIDE!
sub is_multibinnable { return; }

# Description: Private initializer
# Input: HSDB45::Eval::Question object and HSDB45::Eval::Results
# Output: HSDB45::Eval::Question::Results object which has been initialized; reblesses object as required
sub init {
    my $self = shift;
    $self->{-eval_question} = shift;
    die "Was expecting an HSDB45::Eval::Question object..." unless($self->question()->isa("HSDB45::Eval::Question"));
    $self->{-eval_results} = shift;
    die "Was expecting an HSDB45::Eval::Results object..." unless($self->eval_results()->isa("HSDB45::Eval::Results"));
    $self->{-all_resps} = HSDB45::Eval::Question::ResponseGroup->new($self, "__ALL__");
    # First, rebless to the right results type
    my $type = $self->question()->body()->question_type();
    if ($type && $TypeClass{$type}) { bless $self, $TypeClass{$type} }
    else { die "Cannot figure out the question type." }
    $self->lookup_responses();
    return $self;
}

# Description: Looks up the responses from the database
# Input: 
# Output: 
sub lookup_responses {
    my $self = shift;
    my $question = $self->question();
    my $eval = $question->parent_eval();
    my $evaluatee_id = $self->eval_results()->evaluatee_id();
    return if ($self->isa('HSDB45::Eval::Question::Results::Textual') && $eval->is_teaching_eval() && !$evaluatee_id);
    my @conds = ('eval_id = ' . $eval->primary_key(),
		 'eval_question_id = ' . $question->primary_key());
    push @conds, "user_code LIKE '%-$evaluatee_id'" if ($evaluatee_id);
    my $blankresp = HSDB45::Eval::Question::Response->new (_school => $question->school());
    for my $resp ($blankresp->lookup_conditions (@conds)) {
	$resp->set_aux_info ('parent_results' => $self);
	$self->{-all_resps}->add_response ($resp);
    }
    return;
}

# Description: Look up a response by user_code
# Input: User code
# Output: Response object
sub response {
    my $self = shift;
    $self->{-all_resps}->response (@_);
}

# Description: Look up all of the responses
# Input: 
# Output: List of Response objects
sub responses {
    my $self = shift;
    $self->{-all_resps}->responses (@_);
}

# Description: Accessor for parent question
# Input:
# Output: The HSDB45::Eval::Question
sub question {
    my $self = shift;
    return $self->{-eval_question};
}

# Description: Accessor for parent Eval::Results object
# Input:
# Output: The HSDB45::Eval::Results
sub eval_results {
    my $self = shift;
    return $self->{-eval_results};
}

sub sort_order_compare {
    my ($left, $right) = shift;
    return $left->question <=> $right->question;
}

# Description: Returns the set of group-by question results objects
# Input:
# Output: The group-by question results objects
sub group_by_question_results {
    my $self = shift;
    return map { 
	$self->eval_results->question_results($_)
	} $self->question()->group_by_ids();
}

sub categorizations {
    my $self = shift();

    unless($self->{-categorizations}) {
	my @categorizations = ();
	foreach my $group_question ($self->group_by_question_results()) {
	    my $cat = 
	      HSDB45::Eval::Question::Categorization->new($self, $group_question);
	    push @categorizations, $cat ;
	}
	$self->{-categorizations} = \@categorizations;
    }

    return @{$self->{-categorizations}};
}

sub statistics {
    my $self = shift();
    return HSDB45::Eval::Question::ResponseStatistics->new($self->{-all_resps});
}

1;
__END__
