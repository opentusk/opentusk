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

package TUSK::IMS::QTI::Response::Lid;

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
use TUSK::Types qw( QuizAnswer );
use TUSK::IMS::Types qw( Material RenderChoice );
use TUSK::IMS::Namespaces ':all';
use TUSK::IMS::QTI::Render::Choice;
use TUSK::IMS::QTI::Material;

#########
# * Setup
#########

use Moose;
with 'TUSK::XML::Object';

####################
# * Class attributes
####################

has answers => (
    is => 'ro',
    isa => ArrayRef[QuizAnswer],
    required => 1
);

has question_id => (
    is => 'ro',
    isa => Int,
    required => 1
);

has item_text => (
    is => 'ro',
    isa => Maybe[Str],
    default => sub { undef }
);

has ident => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_ident'
#    default => sub { 'response1' }
);

has rcardinality => (
    is => 'ro',
    isa => Str,
    default => sub { 'Single' }
);

has material => (
    is => 'ro',
    isa => Maybe[Material],
    lazy => 1,
    builder => '_build_material'
);

has render_choice => (
    is => 'ro',
    isa => RenderChoice,
    lazy => 1,
    builder => '_build_render_choice'
);


############
# * Builders
############

sub _build_namespace { qti_quiz_questions_ns }
sub _build_tagName { 'response_lid' }
sub _build_xml_content { [ 'material', 'render_choice' ] }

sub _build_xml_attributes {
    return [ qw( ident rcardinality ) ];
}

sub _build_ident {
    my $self = shift;
    ## all the answers have the same question id, so we take it from first one.
    return 'resp_' . $self->question_id();
}

sub _build_material {
    my $self = shift;
    return (defined $self->item_text()) ? TUSK::IMS::QTI::Material->new(text => $self->item_text()) : undef;
}

sub _build_render_choice {
    my $self = shift;
    return TUSK::IMS::QTI::Render::Choice->new(answers => $self->answers());
}


###########
# * Cleanup
###########

__PACKAGE__->meta->make_immutable;
no Moose;

1;
