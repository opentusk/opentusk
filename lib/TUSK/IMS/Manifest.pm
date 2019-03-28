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

package TUSK::IMS::Manifest;

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
use TUSK::IMS::Types qw( ManifestMetadata Organization Resources );
use TUSK::Types qw( Quiz Course );
use TUSK::IMS::Manifest::Metadata;
use TUSK::IMS::Manifest::Resources;

use Moose;
with 'TUSK::XML::RootObject';

####################
# * Class attributes
####################

has quiz_ids => (
    is => 'ro',
    isa => ArrayRef[Int],
    required => 1,
);

has course => (
    is => 'ro',
    isa => Course,
    required => 1
);

has img_directory => (
    is => 'ro',
    isa => Str,
    required => 1,
);

has metadata => (
    is => 'ro',
    isa => ManifestMetadata,
    lazy => 1,
    builder => '_build_metadata'
);

has organization => (
    is => 'ro',
    isa => Str,
    default => sub { '' }
);

has resources => (
    is => 'ro',
    isa => Resources,
    lazy => 1,
    builder => '_build_resources'
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

sub _build_namespace { manifest_ns }
sub _build_tagName { 'manifest' }

sub _build_xml_content {
    return [ qw(
                 metadata
                 resources
    )];
}

sub _build_schemaLocation {
    return 'http://www.imsglobal.org/xsd/imsccv1p1/imscp_v1p1 http://www.imsglobal.org/xsd/imscp_v1p1.xsd http://ltsc.ieee.org/xsd/imsccv1p1/LOM/resource http://www.imsglobal.org/profile/cc/ccv1p1/LOM/ccv1p1_lomresource_v1p0.xsd http://www.imsglobal.org/xsd/imsmd_v1p2 http://www.imsglobal.org/xsd/imsmd_v1p2p2.xsd';
}

sub _build_metadata {
    my $self = shift;
    return TUSK::IMS::Manifest::Metadata->new(course_title => $self->course()->title());
}

sub _build_resources {
    my $self = shift;
    return TUSK::IMS::Manifest::Resources->new(
        quiz_ids => $self->quiz_ids(),
        img_directory => $self->img_directory());
}

###########
# * Cleanup
###########

__PACKAGE__->meta->make_immutable;
no Moose;
1;
