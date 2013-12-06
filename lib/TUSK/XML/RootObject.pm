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

package TUSK::XML::RootObject;

use 5.008;
use strict;
use warnings;
use version; our $VERSION = qv('0.0.1');
use utf8;
use Carp;
use Readonly;

use Types::Standard qw( Str );

use Moose::Role;

with 'TUSK::XML::Object';

requires '_build_tagName';

####################
# Class attributes #
####################

has tagName => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_tagName',
);

#################
# Class methods #
#################

###################
# Private methods #
###################

###########
# Cleanup #
###########

no Moose::Role;
1;

__END__

=head1 NAME

TUSK::XML::RootObject - A role to represent the root document element in XML

=head1 SYNOPSIS

  package TUSK::XML::Doc;
  use Moose;
  with 'TUSK::XML::RootObject';

  has Elt => ( is => 'ro', isa => 'TUSK::XML::Elt', required => 1 );

  sub _build_xml_content { return [ 'Elt' ]; }
  sub _build_tagName { return 'Doc'; }

=head1 DESCRIPTION

Implementing this role is just like implementing L<TUSK::XML::Object>,
with the additional requirement of a L<_build_tagName> method.
L<tagName> is used as the root document element tag.

Classes that implement L<TUSK::XML::RootObject> are intended to be at
the root of a document hierarchy. For an example, see
L<TUSK::Medbiq::CurriculumInventory>, which acts as the root document
element of a curriculum inventory XML document.

=head1 ATTRIBUTES

=over 4

=item * tagName

The tag name of the root document element. For example,
``CurriculumInventory'' is the tag name of a curriculum inventory root
document element.

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
