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

package TUSK::IMS::QTI::Metadata::Field;

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

use Types::Standard qw( Str );
use TUSK::IMS::Namespaces ':all';

#########
# * Setup
#########

use Moose;
with 'TUSK::XML::Object';

####################
# * Class attributes
####################

has fieldlabel => (
    is => 'ro',
    isa => Str,
    required => 1
);

has fieldentry => (
    is => 'ro',
    isa => Str,
    required => 1
);

############
# * Builders
############

sub _build_namespace { qti_quiz_questions_ns }
sub _build_tagName { 'qtimetadatafield' }

sub _build_xml_content {
    return [ qw( fieldlabel fieldentry ) ];
}

###########
# * Cleanup
###########

__PACKAGE__->meta->make_immutable;
no Moose;

1;
