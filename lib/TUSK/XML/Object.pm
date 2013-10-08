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
use version; our $VERSION = qv('0.0.1');
use utf8;
use Carp;
use Readonly;

use Types::Standard qw( ArrayRef HashRef Str );
use TUSK::Types qw( XML_Object );
use TUSK::Meta::Attribute::Trait::Namespaced;
use TUSK::Meta::Attribute::Trait::Tagged;

use Moose::Role;
use Moose::Util qw(does_role);

requires '_build_namespace';

###################
# Role attributes #
###################

has xml_attributes => (
    is => 'ro',
    isa => ArrayRef[ Str ],
    lazy => 1,
    builder => '_build_xml_attributes',
);

has xml_content => (
    is => 'ro',
    isa => (Str | ArrayRef[ Str ]),
    lazy => 1,
    builder => '_build_xml_content',
);

has namespace => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_namespace',
);

################
# Role methods #
################

sub write_xml {
    my ($self, $writer) = @_;
    my $is_root = does_role($self, 'TUSK::XML::RootObject');
    if ($is_root) {
        my @xml_attrs = $self->_attribute_map_of($self);
        $writer->startTag( [ $self->namespace, $self->tagName ], @xml_attrs );
    }
    if ( _is_array($self->xml_content) ) {
        foreach my $attr_name ( @{ $self->xml_content } ) {
            next unless (defined $self->$attr_name);
            $self->write_xml_content($attr_name, $writer);
        }
    }
    else {
        $writer->characters($self->xml_content);
    }
    if ($is_root) {
        $writer->endTag;
    }
    return;
}

sub write_xml_content {
    my ($self, $attr_name, $writer) = @_;
    my $ns = $self->_namespace_of($attr_name);
    my $tag = $self->_tag_of($attr_name);
    # An XML content can be one of Str, XML object, or ArrayRef of those
    my $contents_ref = _is_array($self->$attr_name) ? $self->$attr_name
        :                                             [ $self->$attr_name ];
    foreach my $xml_content ( @{ $contents_ref } ) {
        my $is_xml_object = does_role($xml_content, 'TUSK::XML::Object');
        if ($is_xml_object) {
            my @xml_attrs = $self->_attribute_map_of($xml_content);
            $writer->startTag( [$ns, $tag], @xml_attrs );
            $xml_content->write_xml($writer);
            $writer->endTag;
        }
        else {
            $writer->dataElement( [$ns, $tag], $xml_content );
        }
    }
    return;
}

###################
# Private methods #
###################

sub _build_xml_attributes { return []; }
sub _build_xml_content { return []; }

sub _is_array {
    my $obj = shift;
    return (ref($obj) eq 'ARRAY');
}

sub _attribute_map_of {
    my ($self, $xmlobj) = @_;
    my @attr_map;
    foreach my $attr_name ( @{ $xmlobj->xml_attributes } ) {
        next unless (defined $xmlobj->$attr_name);
        my $xml_attr_key = $xmlobj->_attribute_for($attr_name);
        my $xml_attr_value = $xmlobj->$attr_name;
        push @attr_map, $xml_attr_key, $xml_attr_value;
    }
    return @attr_map;
}

sub _attribute_for {
    my ($self, $attr_name) = @_;
    my $key = $self->_tag_of($attr_name);
    # get XML attribute namespace, if any (different from XML tag's namespace)
    my $ns;
    my $attr = $self->meta->get_attribute($attr_name);
    if ( $attr->does('Namespaced') && $attr->has_namespace ) {
        $ns = $attr->namespace;
    }
    return $key unless (defined $ns);
    return [$ns, $key];
}

sub _namespace_of {
    my ($self, $attr_name) = @_;
    my $attr = $self->meta->get_attribute($attr_name);
    if ( $attr->does('Namespaced') && $attr->has_namespace ) {
        return $attr->namespace;
    }
    return $self->namespace;
}

sub _tag_of {
    my ($self, $attr_name) = @_;
    my $attr = $self->meta->get_attribute($attr_name);
    if ( $attr->does('Tagged') && $attr->has_tag ) {
        return $attr->tag;
    }
    return $attr_name;
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
