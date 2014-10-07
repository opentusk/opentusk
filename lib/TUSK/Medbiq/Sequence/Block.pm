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

package TUSK::Medbiq::Sequence::Block;

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

use Type::Utils -all;
use Types::Standard qw( Maybe ArrayRef );
use Types::XSD qw( NonNegativeInteger PositiveInteger);
use TUSK::Namespaces ':all';
use TUSK::Medbiq::Types qw( NonNullString AcademicLevelReference );


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

has required => (
    is => 'ro',
    isa => enum(['Required', 'Optional', 'Required In Track']),
    required => 1,
);

has order => (
    is => 'ro',
    isa => Maybe[ enum( [ qw( Ordered Unordered Parallel ) ] ) ],
    lazy => 1,
    builder => '_build_order',
);

has minimum => (
    is => 'ro',
    isa => Maybe[NonNegativeInteger],
    lazy => 1,
    builder => '_build_minimum',
);

has maximum => (
    is => 'ro',
    isa => Maybe[PositiveInteger],
    lazy => 1,
    builder => '_build_maximum',
);

has track => (
    is => 'ro',
    isa => enum([qw(true false)]),
    lazy => 1,
    builder => '_build_track',
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

has Timing => (
    is => 'ro',
    isa => TUSK::Medbiq::Types::Timing,
    required => 1,
);

has Level => (
    is => 'ro',
    isa => AcademicLevelReference,
    required => 1,
);

has ClerkshipModel => (
    is => 'ro',
    isa => Maybe[ enum( [ qw(integrated rotation) ] ) ],
    lazy => 1,
    builder => '_build_ClerkshipModel',
);

has CompetencyObjectReference => (
    is => 'ro',
    isa => ArrayRef[TUSK::Medbiq::Types::CompetencyObjectReference],
    lazy => 1,
    builder => '_build_CompetencyObjectReference',
);

has Precondition => (
    is => 'ro',
    isa => Maybe[NonNullString],
    lazy => 1,
    builder => '_build_Precondition',
);

has Postcondition => (
    is => 'ro',
    isa => Maybe[NonNullString],
    lazy => 1,
    builder => '_build_Postcondition',
);

has SequenceBlockEvent => (
    is => 'ro',
    isa => ArrayRef[],
    lazy => 1,
    builder => '_build_SequenceBlockEvent',
);

has SequenceBlockReference => (
    is => 'ro',
    isa => ArrayRef[TUSK::Medbiq::Types::SequenceBlockReference],
    lazy => 1,
    builder => '_build_SequenceBlockReference',
);



############
# * Builders
############

sub _build_namespace { curriculum_inventory_ns }

sub _build_xml_attributes {
    return [ qw( id required order minimum maximum track ) ];
}

sub _build_xml_content {
    return [ qw( Title Description Timing Level ClerkshipModel
                 CompetencyObjectReference Precondition
                 Postcondition SequenceBlockEvent
                 SequenceBlockReference ) ];
}


sub _build_order { return; }
sub _build_minimum { return; }
sub _build_maximum { return; }
sub _build_track { return 'false'; }
sub _build_Description { return; }
sub _build_ClerkshipModel { return; }
sub _build_CompetencyObjectReference { return []; }
sub _build_Precondition { return; }
sub _build_Postcondition { return; }
sub _build_SequenceBlockReference { return []; }
sub _build_SequenceBlockEvent { return []; }

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

TUSK::Medbiq::Sequence::Block - A short description of the module's purpose

=head1 VERSION

This documentation refers to L<TUSK::Medbiq::Sequence::Block> v0.0.1.

=head1 SYNOPSIS

  use TUSK::Medbiq::Sequence::Block;

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
