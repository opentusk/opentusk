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

package TUSK::IMS::Manifest::Resource;

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
use Types::Standard qw( ArrayRef Int Str Maybe );
use TUSK::IMS::Types qw( ResourceFile ResourceDependency );
use TUSK::IMS::Manifest::Resource::File;
use TUSK::IMS::Manifest::Resource::Dependency;

use Moose;
with 'TUSK::XML::Object';

####################
# * Class attributes
####################

has identifier => (
    is => 'ro',
    isa => Str,
    required => 1,
);

has type => (
    is => 'ro',
    isa => Str,
    required => 1,
);

has href => (
    is => 'ro',
    isa => Str,
    required => 1,
);

has file => (
    is => 'ro',
    isa => ResourceFile,
    lazy => 1,
    builder => '_build_file'
);

has dependency => (
    is => 'ro',
    isa => ResourceDependency,
    lazy => 1,
    builder => '_build_dependency'
);

############
# * Builders
############

sub _build_namespace { manifest_ns }
sub _build_tagName { 'resource' }
sub _build_xml_content { [ 'file' ] }
sub _build_xml_attributes { [ 'identifier', 'type' ] }
sub _build_empty_tags { [ 'file', 'depedency' ] }

sub _build_file {
    my $self = shift;
    return TUSK::IMS::Manifest::Resource::File->new(href => $self->href());
}
sub _build_dependency {
    my $self = shift;
    return ($self->type() eq 'imsqti_xmlv1p2')
        ? TUSK::IMS::Manifest::Dependency->new(identifierref => 'ref:' . $self->content_id())
        : undef;
}

###########
# * Cleanup
###########

__PACKAGE__->meta->make_immutable;
no Moose;
1;
