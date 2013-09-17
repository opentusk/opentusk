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

package TUSK::Medbiq::Report;

use 5.008;
use strict;
use warnings;
use version;
use utf8;
use Carp;
use Readonly;

use XML::Writer;

use TUSK::Types;
use TUSK::Medbiq::Types;
use TUSK::Medbiq::CurriculumInventory;

use Moose;

our $VERSION = qv('0.0.1');

####################
# Class attributes #
####################

has school => (
    is => 'ro',
    isa => 'TUSK::Types::School',
    coerce => 1,
    required => 1,
);

has CurriculumInventory => (
    is => 'ro',
    isa => 'TUSK::Medbiq::CurriculumInventory',
    lazy => 1,
    builder => '_build_CurriculumInventory',
);

has writer => ( is => 'ro', isa => 'XML::Writer',
                lazy => 1, builder => '_build_writer' );

#################
# Class methods #
#################

sub write_report {
    my $self = shift;
    my $writer = $self->writer;

    # Set up curriculum inventory with proper namespaces
    $self->CurriculumInventory->write_xml($writer);

    # Finish up
    $writer->end;
    return;
}

###################
# Private methods #
###################

sub _build_writer {
    return XML::Writer->new(
        NEWLINES => 1,
        DATA_MODE => 1,
        NAMESPACES => 1,
        PREFIX_MAP => {
            'http://ns.medbiq.org/curriculuminventory/v1/' => q{},
            'http://ltsc.ieee.org/xsd/LOM' => 'lom',
            'http://ns.medbiq.org/address/v1/' => 'a',
            'http://ns.medbiq.org/competencyframework/v1/' => 'cf',
            'http://ns.medbiq.org/lom/extend/v1/' => 'hx',
            'http://ns.medbiq.org/member/v1/' => 'm',
        },
    );
}

sub _build_CurriculumInventory {
    my $self = shift;
    return TUSK::Medbiq::CurriculumInventory->new( school => $self->school );
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

__END__

=head1 NAME

TUSK::Medbiq::Report - Generates a curriculum inventory report

=head1 VERSION

This documentation refers to L<TUSK::Medbiq::Report> v0.0.1.

=head1 SYNOPSIS

  use TUSK::Medbiq::Report;
  my $report = TUSK::Medbiq::Report( school => 'Default' );
  $report->write_report;

=head1 DESCRIPTION

This module generates a report for the curriculum inventory. By
default it will write to C<STDOUT>.

=head1 ATTRIBUTES

=over 4

=item * school

=item * CurriculumInventory

=item * writer

=back

=head1 METHODS

=over 4

=item write_report

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
