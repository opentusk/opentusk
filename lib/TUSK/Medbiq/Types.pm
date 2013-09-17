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

package TUSK::Medbiq::Types;

use 5.008;
use strict;
use warnings;
use version;
use utf8;
use Carp;
use Readonly;

use List::MoreUtils qw(any);

use TUSK::Types;

use Moose::Util::TypeConstraints;

our $VERSION = qv('0.0.1');

##############################
# Types, Subtypes, and Enums #
##############################

subtype 'NonNullString',
    as 'Str',
    where { length($_) > 0 };

subtype 'URI', as 'Str';

subtype 'TUSK::Medbiq::Types::Domain',
    as 'Str',
    where { m/ \A idd: .+ : .+ \z /xms };

enum 'TUSK::Medbiq::Types::Address::Category',
    qw( Residential Business Undeliverable );

enum 'TUSK::Medbiq::Types::Address::Restriction',
    qw( Unrestricted Restricted Confidential );

#############
# Coercions #
#############

1;

__END__

=head1 NAME

TUSK::Medbiq::Types - Types used by TUSK objects supporting the
Medbiquitous standards

=head1 VERSION

This documentation refers to L<TUSK::Medbiq::Types> v0.0.1.

=head1 SYNOPSIS

  package TUSK::Example;
  use Moose;
  use TUSK::Medbiq::Types;
  has school => (
      is => 'ro',
      isa => 'TUSK::Medbiq::Types::School',
      coerce => 1,
      required => 1,
  );

=head1 DESCRIPTION

This module holds types and coercion methods for TUSK Medbiquitous objects.

=head1 TYPES AND COERCIONS

=over 4

=item * TUSK::Medbiq::Types::School

L<TUSK::Medbiq::Types::School> is the Moose type constraint for
L<TUSK::Core::School>.

Objects that use attributes with type L<TUSK::Medbiq::Types::School> can set
coerce to true to automatically convert from the school name to a
school object. See L<SYNOPSIS> for details.

=back

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
