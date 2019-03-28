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

package TUSK::IMS::QTI::Response::Condition;

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

use Types::Standard qw( Int Str Maybe );
use TUSK::Types qw( QuizQuestion QuizAnswer );
use TUSK::IMS::Types qw( ConditionVariable SetVariable DisplayFeedback );
use TUSK::IMS::Namespaces ':all';
use TUSK::IMS::QTI::Variable::Condition;
use TUSK::IMS::QTI::Variable::Set;
use TUSK::IMS::QTI::Feedback::Display;

#########
# * Setup
#########

use Moose;
with 'TUSK::XML::Object';

####################
# * Class attributes
####################

has answer => (
    is => 'ro',
    isa => QuizAnswer,
    required => 1
);

has question => (
    is => 'ro',
    isa => QuizQuestion,
    required => 1
);

has num_child_questions => (
    is => 'ro',
    isa => Maybe[Int],
    default => sub { undef }
);

has continue => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_continue'
);

has conditionvar => (
    is => 'ro',
    isa => ConditionVariable,
    lazy => 1,
    builder => '_build_condition_var'
);

has setvar => (
    is => 'ro',
    isa => Maybe[SetVariable],
    lazy => 1,
    builder => '_build_set_var'
);

has displayfeedback => (
    is => 'ro',
    isa => Maybe[DisplayFeedback],
    lazy => 1,
    builder => '_build_display_feedback'
);



############
# * Builders
############

sub _build_namespace { qti_quiz_questions_ns }
sub _build_tagName { 'respconditionvar' }
sub _build_xml_content { [ 'conditionvar', 'setvar', 'displayfeedback' ] }
sub _build_xml_attributes { [ 'continue' ] }
sub _build_empty_tags { [ 'displayfeedback' ] }


sub _build_continue {
    my $self = shift;

    return ($self->_has_feedback()) ? 'Yes' : 'No';
}

sub _build_condition_var {
    my $self = shift;
    return TUSK::IMS::QTI::Variable::Condition->new(answer => $self->answer() );
}

sub _build_set_var {
    my $self = shift;
    return undef if ($self->answer()->getPrimaryKeyID() == 0);

    if ($self->answer()->getCorrect()) {
        return TUSK::IMS::QTI::Variable::Set->new(action => 'Set', varname => 'Score', score => 100);
    }

    if (defined $self->num_child_questions() && $self->num_child_questions() > 0) {
        my $score = sprintf("%.1F", 100 / $self->num_child_questions());
        return TUSK::IMS::QTI::Variable::Set->new(action => 'Add', varname => 'Score', score => $score);
    }

    return undef;
}

sub _build_display_feedback {
    my $self = shift;
    my $linkrefid = ($self->answer()->getPrimaryKeyID() == 0) ? 'general_fb' : $self->answer()->getPrimaryKeyID() . '_fb';
    return ($self->_has_feedback()) ? TUSK::IMS::QTI::Feedback::Display->new(linkrefid => $linkrefid ) : undef;
}

#####################
# Helper Methods
#####################
sub _has_feedback {
    my $self = shift;
    my $feedback = $self->answer()->getFeedback();
    return (defined $feedback && $feedback =~ /.*\S.*/) ? 1 : 0;
}


###########
# * Cleanup
###########

__PACKAGE__->meta->make_immutable;
no Moose;

1;
