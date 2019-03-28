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

package TUSK::IMS::QTI::Presentation;

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

use Types::Standard qw( Str Maybe ArrayRef );
use TUSK::IMS::Types qw( Material ResponseLid ResponseString );
use TUSK::Types qw( QuizQuestion );
use TUSK::IMS::Namespaces ':all';
use TUSK::IMS::QTI::Material;
use TUSK::IMS::QTI::Response::Lid;
use TUSK::IMS::QTI::Response::String;
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

has target_dir => (
    is => 'ro',
    isa => Str,
    required => 1,
);

has material => (
    is => 'ro',
   isa => Material,
    lazy => 1,
    builder => '_build_material'
);

has response_lid => (
    is => 'ro',
    isa => Maybe[ArrayRef[ResponseLid]],
    lazy => 1,
    builder => '_build_response_lid'
);

has response_str => (
    is => 'ro',
    isa => Maybe[ResponseString],
    lazy => 1,
    builder => '_build_response_str'
);

############
# * Builders
############

sub _build_namespace { qti_quiz_questions_ns }
sub _build_tagName { 'presentation' }
sub _build_xml_content {
    return [ qw( material response_lid response_str) ];
}

sub _build_material {
    my $self = shift;
    return TUSK::IMS::QTI::Material->new(text => $self->question()->getBody());
}

sub _build_response_lid {
    my $self = shift;
    my $question_type = $self->question()->getType();
    my $answers = $self->question()->getAnswers();
    $self->_modify_answers($answers);

    if ($question_type eq 'TrueFalse' || $question_type eq 'MultipleChoice') {
        return [ TUSK::IMS::QTI::Response::Lid->new(answers => $answers, question_id => $self->question()->getPrimaryKeyID()) ];
    }

    if ($question_type eq 'Matching') {
        my @lids = ();
        foreach my $link  (@{ $self->question()->getSubQuestionLinks() }) {
            push @lids, TUSK::IMS::QTI::Response::Lid->new(answers => $answers, question_id => $link->getChildQuestionID(), item_text => $link->getQuestionObject()->getBody());
        }
        return \@lids;
    }
    return undef;
}

sub _build_response_str {
    my $self = shift;
    my $question_type = $self->question()->getType();
    if ($question_type eq 'Essay'
        || $question_type eq 'FillIn'
        || $question_type eq 'MultipleFillIn') {
        my $answers = $self->question()->getAnswers();
        $self->_modify_answers($answers);
        return TUSK::IMS::QTI::Response::String->new(answers => $answers);
    }
    return undef;
}


sub _modify_answers {
    my ($self, $answers) = @_;
    ## handle image source in answers
    my $imgsrc = TUSK::IMS::QTI::Utils::ImageSource->new(target_dir => $self->target_dir());
    foreach my $answer (@$answers) {
       if (my $new_answer_text = $imgsrc->process($answer->getValue())) {
           $answer->setValue($new_answer_text);
       }
    }
}

###########
# * Cleanup
###########

__PACKAGE__->meta->make_immutable;
no Moose;

1;
