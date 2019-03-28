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

package TUSK::IMS::QTI::Metadata;

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

use Types::Standard qw( Str ArrayRef HashRef );
use TUSK::IMS::Namespaces ':all';
use TUSK::IMS::QTI::Metadata::Field;

#########
# * Setup
#########

use Moose;
with 'TUSK::XML::Object';

####################
# * Class attributes

has fields => (
    is => 'ro',
    isa => ArrayRef[HashRef[Str]],
    required => 1
);

has qtimetadatafield => (
    is => 'ro',
    isa => ArrayRef,
    lazy => 1,
    builder => '_build_qti_metadata_field'
);


############
# * Builders
############

sub _build_namespace { qti_quiz_questions_ns }
sub _build_tagName { [ 'qtimetadata' ] }
sub _build_xml_content { [ 'qtimetadatafield' ] }

sub _build_qti_metadata_field {
    my $self = shift;
    my @metadata_fields = ();

    foreach my $field (@{$self->fields()}) {
        push @metadata_fields, TUSK::IMS::QTI::Metadata::Field->new( fieldlabel => $field->{key}, fieldentry => $field->{value} );
    }
    return \@metadata_fields;
}

###########
# * Cleanup
###########

__PACKAGE__->meta->make_immutable;
no Moose;

1;
