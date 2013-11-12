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

package Medbiq::IntegrationBlock;

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

use TUSK::Namespaces ':all';
use Types::Standard qw( Maybe ArrayRef );
use Medbiq::Types qw( NonNullString EventReferenceXpath
                            SequenceBlockReferenceXpath );

#########
# * Setup
#########

use Moose;
with 'TUSK::XML::Object';

####################
# * Class attributes
####################

has id => (
    is => 'ro',
    isa => NonNullString,
    required => 1,
);

has Title => (
    is => 'ro',
    isa => NonNullString,
    required => 1,
);

has Description => (
    is => 'ro',
    isa => Maybe[NonNullString],
    lazy => 1,
    builder => '_build_Description',
);

has CompetencyObjectReference => (
    is => 'ro',
    isa => ArrayRef[Medbiq::Types::CompetencyObjectReference],
    lazy => 1,
    builder => '_build_CompetencyObjectReference',
);

has EventReference => (
    is => 'ro',
    isa => ArrayRef[EventReferenceXpath],
    lazy => 1,
    builder => '_build_EventReference',
);

has SequenceBlockReference => (
    is => 'ro',
    isa => ArrayRef[SequenceBlockReferenceXpath],
    lazy => 1,
    builder => '_build_SequenceBlockReference',
);


############
# * Builders
############

sub _build_namespace { curriculum_inventory_ns }
sub _build_xml_attributes { [ qw( id ) ] }
sub _build_xml_content { [ qw( Title Description CompetencyObjectReference
                               EventReference SequenceBlockReference ) ] }

#################
# * Class methods
#################

###################
# * Private methods
###################

###########
# * Cleanup
###########

__PACKAGE__->meta->make_immutable;
no Moose;
1;

###########
# * Perldoc
###########

__END__

=head1 NAME

Medbiq::IntegrationBlock - A short description of the module's purpose

=head1 VERSION

This documentation refers to L<Medbiq::IntegrationBlock> v0.0.1.

=head1 SYNOPSIS

  use Medbiq::IntegrationBlock;

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
