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

package TUSK::Medbiq::AssessmentMethod;

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
use TUSK::Medbiq::Types qw( NonNullString );
use TUSK::Namespaces ':all';

#########
# * Setup
#########

use Moose;
with 'TUSK::XML::Object';

####################
# * Class attributes
####################

has content => (
    is => 'ro',
    isa => NonNullString,
    required => 1,
);

has purpose => (
    is => 'ro',
    isa => enum([qw(Formative Summative)]),
    required => 1,
);

######################################
# * Medbiquitous instructional methods
######################################

Readonly my %METHOD_FROM_UID => (
    AM001 => 'Clinical Documentation Review',
    AM002 => 'Clinical Performance Rating/Checklist',
    AM003 => 'Exam - Institutionally Developed, Clinical Performance',
    AM004 => 'Exam - Institutionally Developed, Written/Computer-based',
    AM005 => 'Exam - Institutionally Developed, Oral',
    AM006 => 'Exam - Licensure, Clinical Performance',
    AM007 => 'Exam - Licensure, Written/Computer-based',
    AM008 => 'Exam - Nationally Normed/Standardized, Subject',
    AM009 => 'Multisource Assessment',
    AM010 => 'Narrative Assessment',
    AM011 => 'Oral Patient Presentation',
    AM012 => 'Participation',
    AM013 => 'Peer Assessment',
    AM014 => 'Portfolio-Based Assessment',
    AM015 => 'Practical (Lab)',
    AM016 => 'Research or Project Assessment',
    AM017 => 'Self-Assessment',
    AM018 => 'Stimulated Recall',
);

Readonly my %UID_FROM_TYPE => (
    'Examination' => 'AM004',
    'Laboratory Practical' => 'AM015',
    'Quiz' => 'AM017',
);

sub has_medbiq_translation {
    my $class = shift;
    my $type = shift;
    return exists $UID_FROM_TYPE{$type};
}

sub medbiq_method {
    my $class = shift;
    my $arg_ref = shift;
    my $type = $arg_ref->{class_meeting_type};

    if (! exists $UID_FROM_TYPE{$type}) {
        confess "No Medbiquitous Instructional Method found for class meeting type $type";
    }

    return $class->new(
        purpose => $arg_ref->{purpose},
        content => $UID_FROM_TYPE{$type}
    );
}

#################
# * Class methods
#################

###################
# * Private methods
###################

sub _build_namespace { curriculum_inventory_ns }
sub _build_xml_content { shift->content }
sub _build_xml_attributes { [ qw(purpose) ] }


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

TUSK::Medbiq::AssessmentMethod - A short description of the module's purpose

=head1 VERSION

This documentation refers to L<TUSK::Medbiq::AssessmentMethod> v0.0.1.

=head1 SYNOPSIS

  use TUSK::Medbiq::AssessmentMethod;

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
