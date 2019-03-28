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

package TUSK::IMS::QTI::Questestinterop;

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

use TUSK::IMS::Namespaces ':all';
use Types::Standard qw( ArrayRef Int Str);
use TUSK::Types qw( Quiz );
use TUSK::IMS::Types qw( QTIAssessment );
use TUSK::IMS::QTI::Assessment;

use Moose;
with 'TUSK::XML::RootObject';

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

has assessment => (
    is => 'ro',
    isa => QTIAssessment,
    lazy => 1,
    builder => '_build_assessment'
);

has schemaLocation => (
    traits => [qw/Namespaced/],
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_schemaLocation',
    namespace => xml_schema_instance_ns,
);


############
# * Builders
############

sub _build_namespace { qti_quiz_questions_ns }
sub _build_tagName { 'questestinterop' }

sub _build_xml_content {
    return [ qw( assessment )];
}

sub _build_xml_attributes {
    return [ qw( schemaLocation )];
}

sub _build_assessment {
    my $self = shift;
    return TUSK::IMS::QTI::Assessment->new(quiz => $self->quiz(), target_dir => $self->target_dir());
}

sub _build_schemaLocation {
    my $self = shift;
    return "http://www.imsglobal.org/xsd/ims_qtiasiv1p2 http://www.imsglobal.org/xsd/ims_qtiasiv1p2p1.xsd";
}

###########
# * Cleanup
###########

__PACKAGE__->meta->make_immutable;
no Moose;

1;
