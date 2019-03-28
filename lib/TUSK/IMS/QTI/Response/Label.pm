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

package TUSK::IMS::QTI::Response::Label;

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

use Type::Utils -all;
use Types::Standard qw( Str Maybe );
use TUSK::IMS::Types qw( Material  );
use TUSK::IMS::Namespaces ':all';
use TUSK::IMS::QTI::Material;


#########
# * Setup
#########

use Moose;
with 'TUSK::XML::Object';

####################
# * Class attributes
####################

has ident => (
    is => 'ro',
    isa => Str,
    required => 1
);

has rshuffle => (
    is => 'ro',
    isa => enum([ qw( Yes No ) ]),
    required => 0
);

has answer_text => (
    is => 'ro',
    isa => Str,
    required => 0
);

has material => (
    is => 'ro',
    isa => Maybe[Material],
    lazy => 1,
    builder => '_build_material'
);

############
# * Builders
############

sub _build_namespace { qti_quiz_questions_ns }
sub _build_tagName { 'response_label' }
sub _build_xml_content { [ 'material' ] }
sub _build_xml_attributes { [ 'ident', 'rshuffle' ] }

sub _build_material {
    my $self = shift;
    return (defined $self->answer_text) ? TUSK::IMS::QTI::Material->new(text => $self->answer_text()) : undef;
}

###########
# * Cleanup
###########

__PACKAGE__->meta->make_immutable;
no Moose;

1;
