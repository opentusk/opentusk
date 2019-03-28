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

package TUSK::IMS::QTI::Item;

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

use Types::Standard qw( Int StrictNum Str ArrayRef Maybe );
use TUSK::IMS::Types qw( ItemMetadata Presentation ResponseProcessing ItemFeedback);
use TUSK::Types qw( QuizQuestion QuizAnswer );
use TUSK::IMS::Namespaces ':all';
use TUSK::IMS::QTI::Presentation;
use TUSK::IMS::QTI::Response::Processing;
use TUSK::IMS::QTI::Metadata::Item;
use TUSK::IMS::QTI::Feedback::Item;
use TUSK::IMS::QTI::Utils::ImageSource;

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

has points => (
    is => 'ro',
    isa => StrictNum,
    required => 1
);

has target_dir => (
    is => 'ro',
    isa => Str,
    required => 1,
);

has ident => (
    is => 'ro',
    isa => Int,
    lazy => 1,
    builder => '_build_ident'
);

has title => (
    is => 'ro',
    isa => Str,
    default => sub { 'Question' }
);

has answers => (
    is => 'ro',
    isa => ArrayRef[QuizAnswer],
    lazy => 1,
    builder => '_build_answers'
);

has itemmetadata => (
    is => 'ro',
    isa => ItemMetadata,
    lazy => 1,
    builder => '_build_item_metadata'
);

has presentation => (
    is => 'ro',
    isa => Presentation,
    lazy => 1,
    builder => '_build_presentation'
);

has resprocessing => (
    is => 'ro',
    isa => Maybe[ResponseProcessing],
    lazy => 1,
    builder => '_build_response_processing'
);

has itemfeedback => (
    is => 'ro',
    isa => ArrayRef[ItemFeedback],
    lazy => 1,
    builder => '_build_item_feedback'
);

############
# * Builders
############

sub _build_namespace { qti_quiz_questions_ns }
sub _build_tagName { 'item' }

sub _build_xml_content {
    return [ qw( itemmetadata presentation resprocessing itemfeedback )];
}

sub _build_xml_attributes {
    return [ qw( ident title ) ];
}

sub _build_ident {
    my $self = shift;
    return $self->question()->getPrimaryKeyID();
}

sub _build_title {
    my $self = shift;
    return $self->question()->getTitle();
}

sub _build_answers {
    my $self = shift;
    return $self->question()->getAnswers();
}

sub _build_item_metadata {
    my $self = shift;
    return TUSK::IMS::QTI::Metadata::Item->new(question => $self->question(), points => $self->points());
}

sub _build_presentation {
    my $self = shift;
    return TUSK::IMS::QTI::Presentation->new(question => $self->question(), target_dir => $self->target_dir());
}

sub _build_response_processing {
    my $self = shift;
    if ($self->question()->getType() eq 'Section') {
        return undef;
    } elsif ($self->question()->getType() eq 'Matching') {
        return TUSK::IMS::QTI::Response::Processing->new(question => $self->question(), answers => $self->answers(), num_child_questions => scalar(@{$self->question()->getSubQuestionLinks()}));
    } else {
        return TUSK::IMS::QTI::Response::Processing->new(question => $self->question(), answers => $self->answers());
    }
}

sub _build_item_feedback {
    my $self = shift;
    my @feedback = ();

    ## handle image source in feedback
    my $imgsrc = TUSK::IMS::QTI::Utils::ImageSource->new(target_dir => $self->target_dir());

    my $question_feedback = $self->question()->getFeedback();
    if (defined $question_feedback && $question_feedback =~ /.*\S.*/) {
       if (my $new_question_feedback = $imgsrc->process($question_feedback)) {
           $question_feedback = $new_question_feedback;
       }

        push @feedback, TUSK::IMS::QTI::Feedback::Item->new(ident => 'general_fb', text => $question_feedback);
    }

    foreach my $answer (@{$self->answers}) {
        my $answer_feedback = $answer->getFeedback();
        if (defined $answer_feedback && $answer_feedback =~ /.*\S.*/) {
            if (my $new_answer_feedback = $imgsrc->process($answer_feedback)) {
                $answer_feedback = $new_answer_feedback;
            }

            push @feedback, TUSK::IMS::QTI::Feedback::Item->new(ident => $answer->getPrimaryKeyID() . '_fb', text => $answer_feedback);
        }
    }

    return \@feedback;
}

###########
# * Cleanup
###########

__PACKAGE__->meta->make_immutable;
no Moose;

1;
