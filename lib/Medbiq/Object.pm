# Copyright 2013 Tufts University
#
# Licensed under the Educational Community License, Version 1.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.opensource.org/licenses/ecl1.php
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

package TUSK::Medbiq::Object;

use 5.008;
use strict;
use warnings;
use utf8;
use Carp;
use Readonly;

use Moose;

our $VERSION = qv('0.0.1');

=head1 NAME

C<TUSK::Medbiq::Object> - Base class for Medbiquitous curriculum inventory objects

=head1 VERSION

This documentation refers to C<TUSK::Medbiq::Object> v0.0.1.

=head1 SYNOPSIS

Extend this class to use. Do not instantiate objects of this class
directory.

  package Example;
  use TUSK::Medbiq::Object;
  use Moose;
  extends 'TUSK::Medbiq::Object';
  ...

=head1 DESCRIPTION

C<TUSK::Medbiq::Object> serves as an abstract base class for the objects
in the TUSK implementation of the Medbiquitous curriculum inventory
standard. See the L<curriculum inventory working
group|http://www.medbiq.org/curriculum_inventory> at
L<MedBiquitous|http://www.medbiq.org> for more information.

=head1 ATTRIBUTES

=over 4

=item writer

An instance of L<XML::Writer>.

=cut


=back

=cut

=head1 METHODS

=cut



__PACKAGE__->meta->make_immutable;
no Moose;
1;

__END__

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

Licensed under the Educational Community License, Version 1.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.opensource.org/licenses/ecl1.php

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
