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

package TUSK::IMS::Manifest::LOM;

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
use TUSK::Types qw( Course );
use TUSK::IMS::Types qw( ManifestGeneral ManifestLifeCycle ManifestRights );
use TUSK::IMS::Namespaces ':all';
use TUSK::Meta::Attribute::Trait::Namespaced;
use TUSK::IMS::Manifest::General;
use TUSK::IMS::Manifest::LifeCycle;
use TUSK::IMS::Manifest::Rights;

#########
# * Setup
#########

use Moose;
with 'TUSK::XML::Object';

####################
# * Class attributes
####################

has course_title => (
    is => 'ro',
    isa => Str,
    required => 1
);

has general => (
    traits => [qw(Namespaced)],
    is => 'ro',
    isa => ManifestGeneral,
    lazy => 1,
    builder => '_build_general',
    namespace => lom_ns
);


has lifeCycle => (
    traits => [qw(Namespaced)],
    is => 'ro',
    isa => ManifestLifeCycle,
    lazy => 1,
    builder => '_build_lifeCycle',
    namespace => lom_ns
);

has rights => (
    traits => [qw(Namespaced)],
    is => 'ro',
    isa => ManifestRights,
    lazy => 1,
    builder => '_build_rights',
    namespace => lom_ns
);


############
# * Builders
############

sub _build_namespace { manifest_ns }
sub _build_tagName { 'lom' }
sub _build_xml_content { [ qw( general lifeCycle rights) ] }


sub _build_general {
    my $self = shift;
    return TUSK::IMS::Manifest::General->new(course_title => $self->course_title());
}


sub _build_lifeCycle {
    my $self = shift;
    return TUSK::IMS::Manifest::LifeCycle->new();
}

sub _build_rights {
    my $self = shift;
    return TUSK::IMS::Manifest::Rights->new();
    return qq(
        <imsmd:copyrightAndOtherRestrictions>
          <imsmd:value>yes</imsmd:value>
        </imsmd:copyrightAndOtherRestrictions>
        <imsmd:description>
          <imsmd:string>Private (Copyrighted) - http://en.wikipedia.org/wiki/Copyright</imsmd:string>
        </imsmd:description>
    );
}


###########
# * Cleanup
###########

__PACKAGE__->meta->make_immutable;
no Moose;
1;
