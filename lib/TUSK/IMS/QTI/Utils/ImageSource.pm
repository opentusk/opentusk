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

package TUSK::IMS::QTI::Utils::ImageSource;

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
use HTML::Parser;
use File::Copy;

use Types::Standard qw( Str ArrayRef);

use Moose;

has target_dir => (
    is => 'ro',
    isa => Str,
    required => 1,
);

has htmlparser => (
    is => 'ro',
    isa => 'HTML::Parser',
    builder => '_build_html_parser'
);

has urls => (
    is => 'rw',
    isa => ArrayRef[Str],
    default => sub { [] }
);

has new_filenames => (
    is => 'rw',
    isa => ArrayRef[Str],
    default => sub { [] }
);

############
# * Builders
############

sub _build_html_parser {
    my $self = shift;
    my $p = HTML::Parser->new( api_version => 3 );
    $p->{-ImageSource} = $self;
	$p->handler( start => \&_start, "self,tagname,attr");
    return $p;
}


########################
# * Object methods
########################

sub process {
    my ($self, $text)  = @_;
    my $p = $self->htmlparser();
    $p->parse($text);

    ## we already got img tags if any from parse method
    my $urls = $self->urls();
    return undef unless (scalar @$urls);

    my $new_filenames = $self->new_filenames();
    foreach my $i (0 .. scalar @$urls) {
        if (defined $urls->[$i]) {
            $text =~ s/$urls->[$i]/\$IMS-CC-FILEBASE\$\/$new_filenames->[$i]/;
        }
    }

    ## reset for next use.
    $p->{-ImageSource}->{urls} = [];
    $p->{-ImageSource}->{new_filenames} = [];

    return $text;
}

########################
# * private methods
########################

sub _start {
    my ($self, $tag, $attr) = @_;
    return unless $tag eq "img";
    return unless exists $attr->{src};

    ## do nothing for absolute  url or data uri; only copy tusk's img url
    if ($attr->{src} !~ /^\/[a-zA-Z]+\/[0-9]+/) {
        return;
    }

    _copyFile($attr->{src}, $self);  ## passing $parser for some storage
    push @{$self->{-ImageSource}->urls()}, $attr->{src};
}

sub _copyFile {
    my ($src, $p) = @_;
    my (undef, $size, $content_id) = split(/\//, $src);

    ### validate content
    my $content = HSDB4::SQLRow::Content->new()->lookup_key($content_id);
    unless (defined $content) {
        warn "invalid content id: $content_id in " . $p->{-ImageSource}->target_dir();
        return;
    }

    ## special case for content reuse
    if ($content->reuse_content_id()) {
        $content_id = $content->reuse_content_id();
    }

    my $dir = $TUSK::Constants::BaseStaticPath . "/slide/$size/"
        . substr($content_id, 0, 1) . '/'
        . substr($content_id, 1, 1) . '/'
        . substr($content_id, 2, 1);

    opendir(DIR, $dir);
    my @files = grep(/^$content_id\.(jpg|png|gif)/,readdir(DIR));
    closedir(DIR);

    if (scalar @files == 1) {
        my $new_filename = $size . '_' . $files[0];
        copy("$dir/$files[0]", $p->{-ImageSource}->target_dir() . "/$new_filename");
        push @{$p->{-ImageSource}->new_filenames()}, $new_filename;
    } else {
        warn "there are more than one file of the same image: $dir/$content_id";
        warn $_ foreach (@files);
    }

}

###########
# * Cleanup
###########

__PACKAGE__->meta->make_immutable;
no Moose;

1;
