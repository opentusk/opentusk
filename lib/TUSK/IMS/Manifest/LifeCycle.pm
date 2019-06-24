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

package TUSK::IMS::Manifest::LifeCycle;

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
use TUSK::IMS::Types qw( ManifestContribute );
use TUSK::IMS::Namespaces ':all';
use TUSK::Meta::Attribute::Trait::Namespaced;
use TUSK::IMS::Manifest::Contribute;

#########
# * Setup
#########

use Moose;
with 'TUSK::XML::Object';

####################
# * Class attributes
####################

has contribute => (
    traits => [qw(Namespaced)],
    is => 'ro',
    isa => ManifestContribute,
    lazy => 1,
    builder => '_build_contribute',
    namespace => lom_ns
);

############
# * Builders
############

sub _build_namespace { manifest_ns }
sub _build_tagName { 'lifeCycle' }
sub _build_xml_content { [ 'contribute' ] }

sub _build_contribute {
    my $self = shift;
    return TUSK::IMS::Manifest::Contribute->new();
}


###########
# * Cleanup
###########

__PACKAGE__->meta->make_immutable;
no Moose;
1;