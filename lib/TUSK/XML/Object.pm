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

=head1 SYNOPSIS

  package TUSK::XML::Address;
  use Moose;
  with 'TUSK::XML::Object';

  has Street => ( is => 'ro', isa => 'Str', required => 1 );
  has City   => ( is => 'ro', isa => 'Str', required => 1 );
  has State  => ( is => 'ro', isa => 'Str', required => 1 );
  has Zip    => ( is => 'ro', isa => 'Str', required => 1 );

  sub _build_namespace { return 'http://example.com/address.xsd'; }
  sub _build_xml_content { return [ qw( Street City State Zip ) ]; }
  sub _build_xml_attributes { return []; } # no attributes

  ...

  # some other package or script
  use TUSK::XML::Address;
  use XML::Writer;

  my $address = TUSK::XML::Address->new(
    Street => '124 Example Rd',
    City => 'Boston',
    State => 'MA',
    Zip => '12345'
  );
  $address->write_xml( XML::Writer->new );

  # Outputs (all on one line):
  # <Street>124 Example Rd</Street>
  # <City>Boston</City>
  # <State>MA</State>
  # <Zip>12345</Zip>

=head1 DESCRIPTION

Classes that implement L<TUSK::XML::Object> represent internal XML
nodes. For the root document element, implement
L<TUSK::XML::RootObject>. The difference is that a root object will
print its own tag name. For all others, the tag name is determined by
the name of the attribute.

Implementing classes are required to have a L<_build_namespace>
method. Add XML content with L<_build_xml_content> and
L<_build_xml_attributes> methods.

=head1 ATTRIBUTES

=over 4

=item * xml_attributes

A list of attribute names to be output as XML attributes of the
current tag. For example:

  has domain => ( is => 'ro', isa => 'Str' );
  sub _build_xml_attributes { return [ 'domain' ]; }

When L<write_xml> is called, domain="..." will be an attribute of the
current tag.

See L<TUSK::Medbiq::Address> for an example.

=item * xml_content

Either a string to be output, or a list of attribute names. The
attributes can be either a plain string, in which case the tag and
string will be printed, or another L<TUSK::XML::Object> on which
L<write_xml> will be called.

=item * namespace

The default namespace of the current XML object. All XML objects are
required to implement L<_build_namespace>.

=back

=head1 METHODS

=over 4

=item * write_xml

This is the method to call when serializing the object to an XML
document. The method takes as input an L<XML::Writer> object.

=item * write_xml_content

This method is a helper method for L<write_xml> and will not usually
be called directly. It takes as input an attribute name and an
L<XML::Writer> object.

=back

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
