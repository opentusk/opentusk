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

package TUSK::IMS::QTI::Metadata::Item;

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

use Types::Standard qw( StrictNum );
use TUSK::Types qw( QuizQuestion );
use TUSK::IMS::Types qw( QTIMetadata );
use TUSK::IMS::Namespaces ':all';
use TUSK::IMS::QTI::Metadata;


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

has qtimetadata => (
    is => 'ro',
    isa => QTIMetadata,
    lazy => 1,
    builder => '_build_qti_metadata'
);


############
# * Builders
############

sub _build_namespace { qti_quiz_questions_ns }
sub _build_tagName { 'itemmetadata' }
sub _build_xml_content { [ 'qtimetadata' ] }

sub _build_qti_metadata {
    my $self = shift;

    my %question_map = ( 'TrueFalse'=> 'true_false_question',
                         'MultipleChoice' => 'multiple_choice_question',
                         'FillIn' => 'essay_question',
                         'Essay' => 'essay_question',
                         'MultipleFillIn' => 'essay_question',
                         'Matching' => 'matching_question',
                         'Section' => 'text_only_question'
        );

    my @fields = ();
    my $question_type = $self->question()->getType();

    push @fields, { key => 'question_type', value => $question_map{$question_type} };

    push @fields, { key => 'points_possible',
                    value => (($question_type eq 'Section') ? '0.0' :
                              (($question_type eq 'Matching')
                               ? $self->points() * scalar(@{ $self->question()->getSubQuestionLinks() })
                               : $self->points())) };


    push @fields, { key => 'original_answer_ids',
                    value => ($question_type eq 'Matching')
                        ? join(',', map { $_->getChildQuestionID() } @{ $self->question()->getSubQuestionLinks() })
                        : join(',', map { $_->getPrimaryKeyID() }  @{$self->question()->getAnswers()}) };

    push @fields, { key => 'assessment_question_identifierref',
                    value => 'idref:' . $self->question()->getPrimaryKeyID() };

    return TUSK::IMS::QTI::Metadata->new(fields => \@fields);
}

###########
# * Cleanup
###########

__PACKAGE__->meta->make_immutable;
no Moose;

1;
