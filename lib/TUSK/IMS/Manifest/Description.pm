# Copycopyright 2019 Tufts University
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

package TUSK::IMS::Manifest::Description;

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

use TUSK::IMS::Types qw( ManifestString );
use TUSK::IMS::Namespaces ':all';
use TUSK::Meta::Attribute::Trait::Namespaced;
use TUSK::IMS::Manifest::String;

#########
# * Setup
#########

use Moose;
with 'TUSK::XML::Object';

####################
# * Class attributes
####################

has string => (
    traits => [qw(Namespaced)],
    is => 'ro',
    isa => ManifestString,
    lazy => 1,
    builder => '_build_string',
    namespace => lom_ns
);

############
# * Builders
############

sub _build_namespace { manifest_ns }
sub _build_tagName { 'description' }
sub _build_xml_content { [ 'string' ] }

sub _build_string {
    my $self = shift;
    return TUSK::IMS::Manifest::String->new(string => "Private (Copyrighted) - http://en.wikipedia.org/wiki/Copyright");
}


###########
# * Cleanup
###########

__PACKAGE__->meta->make_immutable;
no Moose;
1;
