# Copyright 2019 Tufts University
#
# Licensed under the Educational Community License, Version 1.0 (the
# "License"); you may not use this file except in compliance with the
# License. You may obtain a copy of the License at
#
# http://www.opensource.org/licenses/ecl1.php
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

package TUSK::IMS::QTI::Response::Processing;

###########
# * Imports
###########

use 5.008;
use strict;
use warnings;
use version; our $VERSION = qv('0.0.1');
use utf8;
use Carp;
use Readonly;

use Types::Standard qw( Int Str ArrayRef Maybe );
use TUSK::Types qw( QuizQuestion QuizAnswer  );
use TUSK::IMS::Types qw( ResponseOutcomes ResponseCondition );
use TUSK::Quiz::Answer;
use TUSK::IMS::Namespaces ':all';
use TUSK::IMS::QTI::Response::Outcomes;
use TUSK::IMS::QTI::Response::Condition;

#########
# * Setup
#########

use Moose;
with 'TUSK::XML::Object';

####################
# * Class attributes
####################

has question => (
    is => 'ro',
    isa => QuizQuestion,
    required => 1
);

has answers => (
    is => 'ro',
    isa => ArrayRef[QuizAnswer],
    required => 1
);

has num_child_questions => (
    is => 'ro',
    isa => Maybe[Int],
    default => sub { 0 }
);

has outcomes => (
    is => 'ro',
    isa => ResponseOutcomes,
    lazy => 1,
    builder => '_build_outcomes'
);

has respcondition => (
    is => 'ro',
    isa => ArrayRef[ResponseCondition],
    lazy => 1,
    builder => '_build_respcondition'
);

############
# * Builders
############

sub _build_namespace { qti_quiz_questions_ns }
sub _build_tagName { 'resprocessing' }

sub _build_xml_content {
    return [ qw( outcomes respcondition )];
}

sub _build_outcomes {
    my $self = shift;
    return TUSK::IMS::QTI::Response::Outcomes->new(maxvalue => 100, minvalue => 0);
}

sub _build_respcondition {
    my $self = shift;
    my @response_conditions = ();

    my $question_feedback = $self->question()->getFeedback();
    if (defined $question_feedback && $question_feedback =~ /.*\S.*/) {     ## need general_feedback
       my $general_answer = TUSK::Quiz::Answer->new(_id => 0);
       $general_answer->setFieldValues({
           feedback => $question_feedback,
           quiz_question_id => $self->question()->getPrimaryKeyID()
                                        });
       push @response_conditions, TUSK::IMS::QTI::Response::Condition->new(answer => $general_answer, question => $self->question());
    }

    foreach my $answer (@{$self->answers()}) {
        push @response_conditions, TUSK::IMS::QTI::Response::Condition->new(answer => $answer, question => $self->question(), num_child_questions => $self->num_child_questions());
    }
    return \@response_conditions;
}


###########
# * Cleanup
###########

__PACKAGE__->meta->make_immutable;
no Moose;

1;
