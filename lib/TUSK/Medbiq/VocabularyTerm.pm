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

package TUSK::Medbiq::VocabularyTerm;

use 5.008;
use strict;
use warnings;
use version; our $VERSION = qv('0.0.1');
use utf8;
use Carp;
use Readonly;

use MooseX::Types::Moose ':all';
use TUSK::Types ':all';
use TUSK::Medbiq::Namespaces ':all';

use Moose;

with 'TUSK::XML::Object';

####################
# Class attributes #
####################

has content => (
    is => 'ro',
    isa => NonNullString,
    required => 1,
);

has source => (
    is => 'ro',
    isa => NonNullString,
    lazy => 1,
    builder => '_build_source',
);

has sourceID => (
    is => 'ro',
    isa => NonNullString,
    required => 1,
);

#################
# Class methods #
#################

###################
# Private methods #
###################

sub _build_namespace { curriculum_inventory_ns }
sub _build_xml_content { $self->content }
sub _build_xml_attributes { [ qw(source sourceID) ] }

sub _build_source { 'HEALTHCARE_LOMv1' }

###########
# Cleanup #
###########

__PACKAGE__->meta->make_immutable;
no Moose;
1;

__END__

=head1 NAME

TUSK::Medbiq::VocabularyTerm - A short description of the module's purpose

=head1 VERSION

This documentation refers to L<TUSK::Medbiq::VocabularyTerm> v0.0.1.

=head1 SYNOPSIS

  use TUSK::Medbiq::VocabularyTerm;

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
