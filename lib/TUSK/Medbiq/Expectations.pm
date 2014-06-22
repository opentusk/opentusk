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

package TUSK::Medbiq::Expectations;

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

use HSDB4::Constants;
use TUSK::Medbiq::CompetencyObject;
use Types::Standard qw( ArrayRef );
use TUSK::Medbiq::Types;
use TUSK::Namespaces ':all';

#########
# * Setup
#########

use Moose;
with 'TUSK::XML::Object';

####################
# * Class attributes
####################

has CompetencyObject => (
    is => 'ro',
    isa => ArrayRef[TUSK::Medbiq::Types::CompetencyObject],
    lazy => 1,
    builder => '_build_CompetencyObject',
);

has CompetencyFramework => (
    is => 'ro',
    isa => ArrayRef[TUSK::Medbiq::Types::CompetencyFramework],
    lazy => 1,
    builder => '_build_CompetencyFramework',
);

has events => (
    is => 'ro',
    isa => TUSK::Medbiq::Types::Events,
    required => 1,
);


############
# * Builders
############

sub _build_CompetencyObject {
    my $self = shift;
    my %objective_from_id;
    foreach my $e ( @{ $self->events->Event } ) {
        foreach my $obj ( values %{ $e->competencies } ) {
            my $id = $obj->getPrimaryKeyID();
            if ( ! exists $objective_from_id{$id} ) {
                $objective_from_id{$id}
                    = TUSK::Medbiq::CompetencyObject->new(dao => $obj);
            }
        }
    }
    my @competencies = values %objective_from_id;
    return \@competencies;
}

sub _build_CompetencyFramework {
    my $self = shift;
    return [];
}

sub _build_namespace { curriculum_inventory_ns }
sub _build_xml_content { [ qw(CompetencyObject CompetencyFramework) ] }

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

TUSK::Medbiq::Expectations - A short description of the module's purpose

=head1 VERSION

This documentation refers to L<TUSK::Medbiq::Expectations> v0.0.1.

=head1 SYNOPSIS

  use TUSK::Medbiq::Expectations;

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
