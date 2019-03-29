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

package TUSK::IMS::QTI::Section;

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

use Types::Standard qw( Str ArrayRef);
use TUSK::Types qw( Quiz );
use TUSK::IMS::Types qw( QTIItem );
use TUSK::IMS::Namespaces ':all';
use TUSK::IMS::QTI::Item;
use TUSK::Constants;
use TUSK::Quiz::LinkQuestionQuestion;
use HTML::Parser;
use File::Copy;
use TUSK::IMS::QTI::Utils::ImageSource;

#########
# * Setup
#########

use Moose;
with 'TUSK::XML::Object';

####################
# * Class attributes
####################

has quiz => (
    is => 'ro',
    isa => Quiz,
    required => 1
);

has target_dir => (
    is => 'ro',
    isa => Str,
    required => 1,
);

has item => (
    is => 'ro',
    isa => ArrayRef[QTIItem],
    lazy => 1,
    builder => '_build_items'
);

has ident => (
    is => 'ro',
    isa => Str,
    default => sub { 'root_section' }
);

has urls => (
    is => 'rw',
    isa => ArrayRef[Str],
    default => sub { [] }
);

has new_filenames => (
    is => 'rw',
    isa => ArrayRef[Str],
    default => sub { [] }
);

############
# * Builders
############

sub _build_namespace { qti_quiz_questions_ns }
sub _build_tagName { 'section' }
sub _build_xml_content { [ 'item' ] }
sub _build_xml_attributes { [ 'ident' ] }


sub _build_items {
    my $self = shift;
    my $random_quiz_questions = 0;

    if ($random_quiz_questions = $self->quiz()->getRandomQuestionLevel()) {
        $self->quiz()->setRandomQuestionLevel(0);
    }
	my $itemsWithAnswers = $self->quiz()->getQuizItemsWithAnswers();
    $self->quiz()->setRandomQuestionLevel(1) if ($random_quiz_questions);

    my $imgsrc = TUSK::IMS::QTI::Utils::ImageSource->new(target_dir => $self->target_dir());
    my @items = ();

    foreach my $item (@$itemsWithAnswers) {
        my $question = $item->getQuestionObject();
        if ($question->getType() eq 'Section') {
            if (my $new_question_body = $imgsrc->process($question->getBody())) {
                $question->setBody($new_question_body);
            }

            push @items, TUSK::IMS::QTI::Item->new(question => $question, points => $item->getPoints(), target_dir => $self->target_dir());

            foreach my $subitem (@{$question->getSubQuestionLinks()}) {
                my $subquestion = $subitem->getQuestionObject();
                push @items, TUSK::IMS::QTI::Item->new(question => $subquestion, points => $subitem->getPoints(), target_dir => $self->target_dir());
                if (my $new_question_body = $imgsrc->process($subquestion->getBody())) {
                    $subquestion->setBody($new_question_body);
                }
            }
        } else {
            push @items, TUSK::IMS::QTI::Item->new(question => $item->getQuestionObject, points => $item->getPoints(), target_dir => $self->target_dir());
                if (my $new_question_body = $imgsrc->process($question->getBody())) {
                    $question->setBody($new_question_body);
                }

        }
    }
    return \@items;
}

###########
# * Cleanup
###########

__PACKAGE__->meta->make_immutable;
no Moose;

1;








1;
