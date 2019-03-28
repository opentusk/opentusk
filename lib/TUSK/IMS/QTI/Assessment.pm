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

package TUSK::IMS::QTI::Assessment;

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

use Types::Standard qw( Int Str HashRef );
use TUSK::Types qw( Quiz );
use TUSK::IMS::Types qw( QTISection QTIMetadata);
use TUSK::IMS::Namespaces ':all';
use TUSK::IMS::QTI::Metadata;
use TUSK::IMS::QTI::Section;

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

has ident => (
    is => 'ro',
    isa => Int,
    lazy => 1,
    builder => '_build_ident'
);

has title => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_title'
);


has qtimetadata => (
    is => 'ro',
    isa => QTIMetadata,
    lazy => 1,
    builder => '_build_qtimetadata'
);

has section => (
    is => 'ro',
    isa => QTISection,
    lazy => 1,
    builder => '_build_section'
);


############
# * Builders
############

sub _build_namespace { qti_quiz_questions_ns }

sub _build_xml_content {
    return [ qw( qtimetadata section  )];
}

sub _build_xml_attributes {
    return [ qw( ident title )];
}

sub _build_ident {
    my $self = shift;
    return $self->quiz()->getPrimaryKeyID();
}

sub _build_title {
    my $self = shift;
    return $self->quiz()->getTitle();
}

sub _build_qtimetadata {
    my $self = shift;
    return TUSK::IMS::QTI::Metadata->new( fields => [ { 'key' => 'cc_maxattempts', 'value'  => '1' }] );
}

sub _build_section {
    my $self = shift;
    return TUSK::IMS::QTI::Section->new(quiz => $self->quiz(), target_dir => $self->target_dir());
}

###########
# * Cleanup
###########

__PACKAGE__->meta->make_immutable;
no Moose;


1;
