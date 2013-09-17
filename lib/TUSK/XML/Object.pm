# Copyright 2013 Tufts University
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

package TUSK::XML::Object;

use 5.008;
use strict;
use warnings;
use version;
use utf8;
use Carp;
use Readonly;

use MooseX::Types::Moose qw(ArrayRef HashRef Str);
use TUSK::Types qw(XML_Object);

use Moose::Role;
use Moose::Util qw{does_role};

our $VERSION = qv('0.0.1');

############
# Requires #
############

# TUSK classes that implement this role must have the following
# attributes and methods.

requires '_build_tagName';

###################
# Role attributes #
###################

has attributes => (
    is => 'ro',
    isa => HashRef[Str],
    lazy => 1,
    builder => '_build_attributes',
);

has attributes_list => (
    is => 'ro',
    isa => ArrayRef[Str],
    lazy => 1,
    builder => '_build_attributes_list',
);

has content => (
    is => 'ro',
    isa => ArrayRef[Str | XML_Object | HashRef],
    lazy => 1,
    builder => '_build_content',
);

has content_list => (
    is => 'ro',
    isa => ArrayRef[Str],
    lazy => 1,
    builder => '_build_content_list',
);

has namespace => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_namespace',
);

has tagName => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_tagName',
);

################
# Role methods #
################

sub write_xml {
    my ($self, $writer) = @_;
    $self->_open_tag({ writer => $writer, ns => $self->namespace,
                       tag => $self->tagName, attrs => $self->attributes });
    $self->write_content($writer);
    $writer->endTag;
    return;
}

sub write_content {
    my ($self, $writer) = @_;
    foreach my $content ( @{ $self->content } ) {
        if (does_role($content, 'TUSK::XML::Object')) {
            $self->_write_obj($writer, $content);
        }
        elsif (ref($content) eq 'HASH') {
            $self->_write_element($writer, $content);
        }
        else {
            $writer->characters($content);
        }
    }
    return;
}

###################
# Private methods #
###################

sub _build_namespace {
    return q{};
}

sub _build_attributes {
    my $self = shift;
    my %attrs;
    foreach my $attr_name ( @{ $self->attributes_list } ) {
        next if (! defined $self->$attr_name);
        $attrs{$attr_name} = $self->$attr_name;
    }
    return \%attrs;
};

sub _build_attributes_list {
    return [];
}

# Convenience function to automatically build contents from an
# implementing object's content_list. Implementing objects can
# override this for custom behavior.
sub _build_content {
    my $self = shift;
    my @contents;
    foreach my $content ( @{ $self->content_list } ) {
        next if (! defined $self->$content);
        if (does_role($self->$content, 'TUSK::XML::Object')) {
            # Pass xml objects through to content as is
            push @contents, $self->$content ;
        }
        elsif (ref($self->$content) eq 'ARRAY') {
            # Add an array of subelements with the same tag name
            foreach my $elt ( @{ $self->$content } ) {
                push @contents, { $content => $elt };
            }
        }
        else {
            # Add a single subelement with its tag name
            push @contents, { $content => $self->$content };
        }
    }
    return \@contents;
};

# If the implementing object wants to use the _build_content
# convenience function, it can override _build_content_list with a
# list of attributes.
# Example:
#   package TUSK::Example;
#   use Moose;
#   with 'TUSK::XML::Object';
#   has CountryName => ( isa => 'Str' );
#   has CountryCode => ( isa => 'Str' );
#   sub _build_content_list { [ qw(CountryName CountryCode ) ] }
sub _build_content_list {
    return [];
};

sub _write_obj {
    my ($self, $writer, $content) = @_;
    $content->write_xml($writer);
    return;
}

sub _write_element {
    my ($self, $writer, $content) = @_;
    $self->_open_tag({
        writer => $writer,
        ns => $self->namespace,
        tag => keys %{ $content },
        attrs => {}
    });
    $writer->characters(values %{ $content });
    $writer->endTag;
    return;
}

sub _open_tag {
    my ($self, $arg_ref) = @_;
    my $writer = $arg_ref->{writer};
    my $ns = $arg_ref->{ns};
    my $tag = $arg_ref->{tag};
    my $attr_ref = $arg_ref->{attrs};
    if ($ns) {
        $writer->startTag( [ $ns, $tag ], %$attr_ref );
    }
    else {
        $writer->startTag( $tag, %$attr_ref );
    }
    return;
}

no Moose::Role;
1;

__END__

=head1 NAME

TUSK::XML::Object - A role for TUSK objects that represent XML nodes

=head1 VERSION

This documentation refers to L<TUSK::XML::Object> v0.0.1.

=head1 SYNOPSIS

  package TUSK::Example;
  use Moose;
  with 'TUSK::XML::Object';
  has namespace => (
      is => 'ro',
      isa => 'Str',
      default => 'http://
  );

=head1 DESCRIPTION

=head1 ATTRIBUTES

=head1 METHODS

=head1 DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

TUSK modules depend on properly set constants in the configuration
file loaded by L<TUSK::Constants>. See the documentation for
L<TUSK::Constants> for more detail.

=head1 INCOMPATIBILITIES

This module has no known incompatibilities.

=head1 BUGS AND LIMITATIONS

There are no known bugs in this module. Please report problems to the
TUSK development team (tusk@tufts.edu) Patches are welcome.

=head1 LICENSE AND COPYRIGHT

Copyright 2013 Tufts University

Licensed under the Educational Community License, Version 1.0 (the
"License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at

http://www.opensource.org/licenses/ecl1.php

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
