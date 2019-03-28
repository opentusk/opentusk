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

package TUSK::IMS::QTI::Variable::Condition;

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

use Types::Standard qw( Int Str Maybe )
;use TUSK::Types qw( QuizAnswer );
use TUSK::IMS::Types qw( VariableEqual );
use TUSK::IMS::Namespaces ':all';
use TUSK::IMS::QTI::Variable::Equal;


#########
# * Setup
#########

use Moose;
with 'TUSK::XML::Object';

####################
# * Class attributes
####################


has answer => (   ## id from user's response
    is => 'ro',
    isa => QuizAnswer,
    required => 1
);

## need answer  id from response label (one of the choices)

has varequal => (
    is => 'ro',
    isa => Maybe[VariableEqual],
    lazy => 1,
    builder => '_build_var_equal'
);

has other => (
    is => 'ro',
    isa => Maybe[Str],
    lazy => 1,
    builder => '_build_other'
);

############
# * Builders
############

sub _build_namespace { qti_quiz_questions_ns }
sub _build_tagName { 'conditionvar' }
sub _build_xml_content { [ 'varequal', 'other' ] }
sub _build_empty_tags { [ 'other' ] }

sub _build_var_equal {
    my $self = shift;
    ## varequal from response_label id
    my $respident =  ($self->answer()->getChildQuestionID()) ? $self->answer()->getChildQuestionID() : $self->answer()->getQuestionID();
    my $answer_id = $self->answer()->getPrimaryKeyID();
    return ($answer_id == 0)
        ? undef
        : TUSK::IMS::QTI::Variable::Equal->new(respident => 'resp_' . $respident, varequal => $answer_id);
}

sub _build_other {
    my $self = shift;
    return ($self->answer()->getPrimaryKeyID() == 0) ? '' : undef;
}


###########
# * Cleanup
###########

__PACKAGE__->meta->make_immutable;
no Moose;

1;
