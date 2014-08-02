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

package TUSK::Medbiq::AcademicLevels;

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

use Types::Standard qw(Int ArrayRef InstanceOf);
use TUSK::Types qw(AcademicLevel);
use TUSK::Medbiq::AcademicLevel;
use TUSK::Namespaces ':all';

#########
# * Setup
#########

use Moose;
with 'TUSK::XML::Object';

####################
# * Class attributes
####################

has levels => (
    is => 'ro',
    isa => ArrayRef[AcademicLevel],
    required => 1,
);

has LevelsInProgram => (
    is => 'ro',
    isa => Int,
    lazy => 1,
    builder => '_build_LevelsInProgram',
);

has Level => (
    is => 'ro',
    isa => ArrayRef[InstanceOf['TUSK::Medbiq::AcademicLevel']],
    lazy => 1,
    builder => '_build_Level',	      
);

############
# * Builders
############

sub _build_namespace { curriculum_inventory_ns; }
sub _build_xml_content { [ qw( LevelsInProgram Level )] }

sub _build_LevelsInProgram {
    my $self = shift;
    return scalar @{$self->levels};
}

sub _build_Level {
    my $self = shift;
    return [ map { TUSK::Medbiq::AcademicLevel->new(dao => $_) } @{$self->levels} ];
}

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

TUSK::Medbiq::AcademicLevels - A short description of the module's purpose

=head1 VERSION

This documentation refers to L<TUSK::Medbiq::AcademicLevels> v0.0.1.

=head1 SYNOPSIS

  use TUSK::Medbiq::AcademicLevels;

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
