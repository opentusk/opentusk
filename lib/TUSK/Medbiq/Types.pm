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

package TUSK::Medbiq::Types;

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

#########
# * Setup
#########

use Type::Library
    -base,
    -declare => qw(
                      AcademicLevelReference
                      AcademicLevels
                      Address
                      Address_Category
                      Address_Restriction
                      AssessmentMethod
                      Category
                      CFIncludes
                      CFLOM
                      CFRelationship
                      CompetencyFramework
                      CompetencyObject
                      CompetencyObjectReference
                      ContextValues
                      Country
                      CurriculumInventory
                      Dates
                      Domain
                      Event
                      EventReferenceXpath
                      Events
                      Expectations
                      Identifier
                      Institution
                      InstructionalMethod
                      Integration
                      IntegrationBlock
                      IntegrationBlockList
                      Keyword
                      Level
                      NonNullString
                      Program
                      References
                      Relation
                      Sequence
                      SequenceBlock
                      SequenceBlockEvent
                      SequenceBlockReference
                      SequenceBlockReferenceXpath
                      Status
                      SupportingInformation
                      Timing
                      UniqueID
                      VocabularyTerm
              );
use Type::Utils -all;
use Types::Standard qw( Int Str ArrayRef );
use TUSK::LOM::Types qw( LOM );

###############################
# * Medbiquitous Standard Types
###############################

declare NonNullString, as Str, where { length($_) > 0 };

declare CFLOM,
    as LOM,
    where {
        my $lom = $_;
        ( $lom->general
              && $lom->general->identifier
              && $lom->general->identifier->catalog
              && $lom->general->identifier->entry
              && $lom->general->title )
    };

declare AcademicLevelReference,
    as Str,
    where { $_ =~ m{ \A \s*
                     /CurriculumInventory/AcademicLevels/Level
                     \[ \@number \s* = \s* ' \d+ ' \]
                     \s* \z }xms };

declare SequenceBlockReferenceXpath,
    as Str,
    where { $_ =~ m{ \A \s*
                     /CurriculumInventory/Sequence/SequenceBlock
                     \[ \@id \s* = \s* ' [^']+ ' \]
                     \s* \z }xms };

declare EventReferenceXpath,
    as Str,
    where { $_ =~ m{ \A \s*
                     /CurriculumInventory/Events/Event
                     \[ \@id \s* = \s* ' [^']+ ' \]
                     \s* \z }xms };

declare CompetencyObjectReference,
    as Str,
    where { $_ =~ m{ \A \s*
                     /CurriculumInventory/Expectations/CompetencyObject
                     \[ lom:lom/lom:general/lom:identifier/lom:entry
                     \s* = \s*
                     ' [^']+ '
                     \]
                     \s* \z }xms };

declare Domain,
    as Str,
    where { m/ \A idd: .+ : .+ \z /xms };

class_type UniqueID, { class => 'TUSK::Medbiq::UniqueID' };
class_type Address, { class => 'TUSK::Medbiq::Address' };
class_type Country, { class => 'TUSK::Medbiq::Country' };
class_type Institution, { class => 'TUSK::Medbiq::Institution' };
class_type CurriculumInventory, {
    class => 'TUSK::Medbiq::CurriculumInventory'
};
class_type VocabularyTerm, { class => 'TUSK::Medbiq::VocabularyTerm' };
class_type Program, { class => 'TUSK::Medbiq::Program' };
class_type Events, { class => 'TUSK::Medbiq::Events' };
class_type Expectations, { class => 'TUSK::Medbiq::Expectations' };
class_type AcademicLevels, { class => 'TUSK::Medbiq::AcademicLevels' };
class_type Sequence, { class => 'TUSK::Medbiq::Sequence' };
class_type SequenceBlock, { class => 'TUSK::Medbiq::SequenceBlock' };
class_type SequenceBlockReference,
    { class => 'TUSK::Medbiq::SequenceBlockReference' };
class_type Integration, { class => 'TUSK::Medbiq::Integration' };
class_type Event, { class => 'TUSK::Medbiq::Event' };
class_type Keyword, { class => 'TUSK::Medbiq::Keyword' };
class_type InstructionalMethod,
    { class => 'TUSK::Medbiq::InstructionalMethod' };
class_type AssessmentMethod,
    { class => 'TUSK::Medbiq::AssessmentMethod' };
class_type CompetencyObject,
    { class => 'TUSK::Medbiq::CompetencyObject' };
class_type CompetencyFramework,
    { class => 'TUSK::Medbiq::CompetencyFramework' };
class_type SupportingInformation,
    { class => 'TUSK::Medbiq::SupportingInformation' };
class_type Identifier,
    { class => 'TUSK::Medbiq::Identifier' };
class_type Relation,
    { class => 'TUSK::Medbiq::Relation' };
class_type Status,
    { class => 'TUSK::Medbiq::Status' };
class_type Category,
    { class => 'TUSK::Medbiq::Category' };
class_type References,
    { class => 'TUSK::Medbiq::References' };
class_type Level,
    { class => 'TUSK::Medbiq::Level' };
class_type Timing, { class => 'TUSK::Medbiq::Timing' };
class_type Dates, { class => 'TUSK::Medbiq::Dates' };
class_type SequenceBlockEvent,
    { class => 'TUSK::Medbiq::SequenceBlockEvent' };
class_type IntegrationBlock,
    { class => 'TUSK::Medbiq::IntegrationBlock' };

declare CFIncludes,
    as ArrayRef[Identifier],
    where { scalar(@{$_}) > 0 };

declare IntegrationBlockList,
    as ArrayRef[IntegrationBlock],
    where { scalar(@{$_}) > 0 };

enum Address_Category,
    [ qw( Residential Business Undeliverable ) ];

enum Address_Restriction,
    [ qw( Unrestricted Restricted Confidential ) ];

enum ContextValues,
    [ 'school', 'higher education', 'training', 'other' ];

enum CFRelationship,
    [ 'http://www.w3.org/2004/02/skos/core#broader',
      'http://www.w3.org/2004/02/skos/core#narrower',
      'http://www.w3.org/2004/02/skos/core#related', ];

###########
# * Cleanup
###########

1;

###########
# * Perldoc
###########

__END__

=head1 NAME

TUSK::Medbiq::Types - A short description of the module's purpose

=head1 VERSION

This documentation refers to L<TUSK::Medbiq::Types> v0.0.1.

=head1 SYNOPSIS

  use TUSK::Medbiq::Types;

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
