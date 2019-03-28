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

package TUSK::IMS::Manifest::Rights;

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

use TUSK::IMS::Types qw( ManifestCopyright ManifestDescription );
use TUSK::IMS::Namespaces ':all';
use TUSK::Meta::Attribute::Trait::Namespaced;
use TUSK::IMS::Manifest::Copyright;
use TUSK::IMS::Manifest::Description;

#########
# * Setup
#########

use Moose;
with 'TUSK::XML::Object';

####################
# * Class attributes
####################

has copyright => (
    traits => [qw(Namespaced)],
    is => 'ro',
    isa => ManifestCopyright,
    lazy => 1,
    builder => '_build_copyright',
    namespace => lom_ns
);

has description => (
    traits => [qw(Namespaced)],
    is => 'ro',
    isa => ManifestDescription,
    lazy => 1,
    builder => '_build_description',
    namespace => lom_ns
);

############
# * Builders
############

sub _build_namespace { manifest_ns }
sub _build_tagName { 'rights' }
sub _build_xml_content { [ 'copyright', 'description' ] }

sub _build_copyright {
    my $self = shift;
    return TUSK::IMS::Manifest::Copyright->new();
}

sub _build_description {
    my $self = shift;
    return TUSK::IMS::Manifest::Description->new();
}


###########
# * Cleanup
###########

__PACKAGE__->meta->make_immutable;
no Moose;
1;
