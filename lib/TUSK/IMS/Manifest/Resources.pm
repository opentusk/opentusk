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

package TUSK::IMS::Manifest::Resources;

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
use TUSK::IMS::Types qw( ManifestResource );
use TUSK::IMS::Manifest::Resource;

use Moose;
with 'TUSK::XML::Object';

####################
# * Class attributes
####################

has quiz_ids => (
    is => 'ro',
    isa => ArrayRef[Int],
    required => 1,
);

has img_directory => (
    is => 'ro',
    isa => Str,
    required => 1,
);

has images => (
    is => 'ro',
    isa => Maybe[ArrayRef[Str]],
    lazy => 1,
    builder => '_build_images'
);

has resource => (
    is => 'ro',
    isa => ArrayRef[ManifestResource],
    lazy => 1,
    builder => '_build_resource'
);

############
# * Builders
############

sub _build_namespace { manifest_ns }
sub _build_tagName { 'resources' }
sub _build_xml_content { [ 'resource' ] }

sub _build_resource {
    my $self = shift;
    my @resources = ();

    foreach my $quiz_id (@{$self->quiz_ids}) {
        push @resources, TUSK::IMS::Manifest::Resource->new(
            identifier => $quiz_id,
            type => 'imsqti_xmlv1p2',
            href => $quiz_id . '/' . $quiz_id . '.xml' );

        push @resources, TUSK::IMS::Manifest::Resource->new(
            identifier => $quiz_id . '-meta',
            type => 'associatedcontent/imscc_xmlv1p1/learning-application-resource',
            href => $quiz_id . '/assessment_meta.xml' );

        foreach my $img_file (@{$self->images()}) {
            my ($cid, undef) = split(/\./, $img_file);
            push @resources, TUSK::IMS::Manifest::Resource->new(
                identifier => $cid,
                type => 'webcontent',
                href => $img_file );
        }
    }

    return \@resources;
}

sub _build_images {
    my $self = shift;
    opendir(DIR, $self->img_directory());
    my @files = grep(/\.(jpg|png|gif)$/,readdir(DIR));
    closedir(DIR);
    return \@files;
}


###########
# * Cleanup
###########

__PACKAGE__->meta->make_immutable;
no Moose;
1;
