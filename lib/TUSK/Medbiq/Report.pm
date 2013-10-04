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

###########
# * Imports
###########

use 5.008;
use strict;
use warnings;
use version;
use utf8;
use Carp;
use Readonly;

use XML::Writer;

use TUSK::Types ':all';
use TUSK::Namespaces ':all';
use TUSK::Medbiq::CurriculumInventory;

use Moose;

our $VERSION = qv('0.0.1');

####################
# * Class attributes
####################

has school => (
    is => 'ro',
    isa => School,
    coerce => 1,
    required => 1,
);

has start_date => (
    is => 'ro',
    isa => Sys_DateTime,
    coerce => 1,
    required => 1,
);

has end_date => (
    is => 'ro',
    isa => Sys_DateTime,
    coerce => 1,
    required => 1,
);

has CurriculumInventory => (
    is => 'ro',
    isa => Medbiq_CurriculumInventory,
    lazy => 1,
    builder => '_build_CurriculumInventory',
);

has writer => ( is => 'ro', isa => 'XML::Writer',
                lazy => 1, builder => '_build_writer' );

############
# * Builders
############

sub _build_writer {
    return XML::Writer->new(
        ENCODING => 'utf-8',
        DATA_MODE => 1,
        DATA_INDENT => 2,
        NAMESPACES => 1,
        FORCED_NS_DECLS => [
            curriculum_inventory_ns(),
            lom_ns(),
            address_ns(),
            competency_framework_ns(),
            competency_object_ns(),
            extend_ns(),
            member_ns(),
            xml_schema_instance_ns(),
        ],
        PREFIX_MAP => {
            curriculum_inventory_ns() => q(),
            lom_ns() => 'lom',
            address_ns() => 'a',
            competency_framework_ns() => 'cf',
            competency_object_ns() => 'co',
            extend_ns() => 'hx',
            member_ns() => 'm',
            xml_schema_instance_ns() => 'xsi',
        },
    );
}

sub _build_CurriculumInventory {
    my $self = shift;
    return TUSK::Medbiq::CurriculumInventory->new(
        school => $self->school,
        ReportingStartDate => $self->start_date,
        ReportingEndDate => $self->end_date,
    );
}


#################
# * Class methods
#################

sub write_report {
    my $self = shift;
    my $writer = $self->writer;

    # Set up curriculum inventory with proper namespaces
    $writer->xmlDecl();
    $self->CurriculumInventory->write_xml($writer);

    # Finish up
    $writer->end;
    return;
}

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
