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

package TUSK::Medbiq::ReportID;

use 5.008;
use strict;
use warnings;
use version;
use utf8;
use Carp;
use Readonly;

use Data::UUID;

use TUSK::Constants;
use TUSK::Medbiq::Types;

use Moose;

with ( 'TUSK::XML::Object',
       'TUSK::Medbiq::UniqueID' );

our $VERSION = qv('0.0.1');

####################
# Class attributes #
####################

#################
# Class methods #
#################

###################
# Private methods #
###################

sub _build_namespace { 'http://ns.medbiq.org/curriculuminventory/v1/' }
sub _build_tagName { 'ReportID' }

sub _build_attribute_list { [ qw(domain) ] }

sub _build_content { my $self = shift; return [ $self->id ]; }

__PACKAGE__->meta->make_immutable;
no Moose;
1;

__END__

=head1 NAME

TUSK::Medbiq::ReportID - Represents the ReportID element of a
L<TUSK::Medbiq::CurriculumInventory> document

=head1 VERSION

This documentation refers to L<TUSK::Medbiq::ReportID> v0.0.1.

=head1 SYNOPSIS

  use TUSK::Medbiq::ReportID;
  my $rid = TUSK::Medbiq::ReportID->new;
  print "Domain: " . $rid->domain . "\n";
  print "ID: " . $rid->id . "\n";

=head1 DESCRIPTION

L<TUSK::Medbiq::ReportID> is a container object for a domain and report ID
for a curriculum inventory report. Unless otherwise specified via an
attribute it will generate a UUID.

=head1 ATTRIBUTES

=over 4

=item * domain

A Medbiquitous domain of the form 'idd:domain.edu:uuid'. See the
specification for more information on valid domains. The default is
automatically constructed from $L<TUSK::Constants>::Domain.

=item * id

Any string that uniquely identifies the report. The default is to
automatically generate a UUID.

=back

=head1 METHODS

=over 4

=item write_xml

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
