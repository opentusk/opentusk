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

package Medbiq::Address;

use 5.008;
use strict;
use warnings;
use version; our $VERSION = qv('0.0.1');
use utf8;
use Carp;
use Readonly;

use Types::Standard qw( ArrayRef );
use Medbiq::Types qw( NonNullString Address_Category
                            Address_Restriction );

use Moose;
with 'TUSK::XML::Object';

Readonly my $_default_namespace => 'http://ns.medbiq.org/address/v1/';

####################
# Class attributes #
####################

has ID => (
    is => 'ro',
    isa => NonNullString,
    required => 0,
);

has Organization => (
    is => 'ro',
    isa => ArrayRef[NonNullString],
    lazy => 1,
    builder => '_build_Organization',
);

has StreetAddressLine => (
    is => 'ro',
    isa => ArrayRef[NonNullString],
    lazy => 1,
    builder => '_build_StreetAddressLine',
);

has City => (
    is => 'ro',
    isa => NonNullString,
    required => 0,
);

has StateOrProvince => (
    is => 'ro',
    isa => NonNullString,
    required => 0,
);

has PostalCode => (
    is => 'ro',
    isa => NonNullString,
    required => 0,
);

has Region => (
    is => 'ro',
    isa => NonNullString,
    required => 0,
);

has District => (
    is => 'ro',
    isa => NonNullString,
    required => 0,
);

has Country => (
    is => 'ro',
    isa => Medbiq::Types::Country,
    required => 0,
);

has addressCategory => (
    is => 'ro',
    isa => Address_Category,
    required => 0,
);

has restrictions => (
    is => 'ro',
    isa => Address_Restriction,
    required => 0,
);

#################
# Class methods #
#################

###################
# Private methods #
###################

sub _build_namespace { return $_default_namespace; }

sub _build_xml_attributes {
    return [ qw( addressCategory restrictions ) ];
}

sub _build_xml_content {
    return [ qw( ID Organization StreetAddressLine City StateOrProvince
                 PostalCode Region District Country ) ];
}

sub _build_Organization {
    return [ $TUSK::Constants::SiteName ];
}

sub _build_StreetAddressLine {
    return $TUSK::Constants::Institution{Address};
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

__END__

=head1 NAME

Medbiq::Address - Container for Medbiquitous address information

=head1 VERSION

This documentation refers to L<Medbiq::Address> v0.0.1.

=head1 SYNOPSIS

  use Medbiq::Address;

=head1 DESCRIPTION

L<Medbiq::Address> is a container for the Medbiquitous address
type. See the address specification at
L<http://ns.medbiq.org/address/v1/>.

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
