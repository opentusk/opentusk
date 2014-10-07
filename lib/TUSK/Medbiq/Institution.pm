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

package TUSK::Medbiq::Institution;

use 5.008;
use strict;
use warnings;
use version; our $VERSION = qv('0.0.1');
use utf8;
use Carp;
use Readonly;

use TUSK::Constants;
use TUSK::Medbiq::Institution::Address;
use TUSK::Medbiq::UniqueID;

use TUSK::Medbiq::Types qw( NonNullString UniqueID );

use Moose;

with 'TUSK::XML::Object';

####################
# Class attributes #
####################

has InstitutionName => (
    is => 'ro',
    isa => NonNullString,
    lazy => 1,
    builder => '_build_InstitutionName',
);

has InstitutionID => (
    is => 'ro',
    isa => UniqueID,
    builder => '_build_InstitutionID',
);

has Address => (
    is => 'ro',
    isa => TUSK::Medbiq::Types::Address,
    lazy => 1,
    builder => '_build_Address',
);

#################
# Class methods #
#################

###################
# Private methods #
###################

sub _build_namespace { 'http://ns.medbiq.org/member/v1/' }
sub _build_xml_content { [ qw( InstitutionName InstitutionID Address ) ] }

sub _build_InstitutionName {
    return $TUSK::Constants::Institution{LongName};
};

sub _build_InstitutionID {
    return TUSK::Medbiq::UniqueID->new(domain => 'idd:aamc.org:institution', id => $TUSK::Constants::Institution{AAMC_ID});
}

sub _build_Address {
    return TUSK::Medbiq::Institution::Address->new();
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

__END__

=head1 NAME

TUSK::Medbiq::Institution - Container for institution info

=head1 VERSION

This documentation refers to L<TUSK::Medbiq::Institution> v0.0.1.

=head1 SYNOPSIS

  use TUSK::Medbiq::Institution;

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
