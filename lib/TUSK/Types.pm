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

package TUSK::Types;

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

use TUSK::Core::School;

#########
# * Setup
#########

use MooseX::Types -declare => [
    qw(
          ClassMeeting
          Medbiq_AcademicLevels
          Medbiq_Address
          Medbiq_Address_Category
          Medbiq_Address_Restriction
          Medbiq_AssessmentMethod
          Medbiq_CompetencyFramework
          Medbiq_CompetencyObject
          Medbiq_CompetencyObjectReference
          Medbiq_ContextValues
          Medbiq_Country
          Medbiq_CurriculumInventory
          Medbiq_Domain
          Medbiq_Event
          Medbiq_Events
          Medbiq_Expectations
          Medbiq_Identifier
          Medbiq_Institution
          Medbiq_InstructionalMethod
          Medbiq_Integration
          Medbiq_Keyword
          Medbiq_LOM
          Medbiq_Program
          Medbiq_Relation
          Medbiq_Sequence
          Medbiq_SupportingInformation
          Medbiq_UniqueID
          Medbiq_VocabularyTerm
          NonNullString
          School
          StrArrayRef
          StrHashRef
          Sys_DateTime
          TUSK_DateTime
          TUSK_Objective
          URI
          UnsignedInt
          UnsignedNum
          XML_Object
          xs_boolean
          xs_date
          xs_duration
  )
];

use MooseX::Types::Moose ':all';

#################
# * General Types
#################

subtype UnsignedInt, as Int, where { $_ >= 0 };
subtype UnsignedNum, as Num, where { $_ >= 0.0 };
subtype URI, as Str;

subtype StrHashRef, as HashRef[Str];

subtype StrArrayRef, as ArrayRef[Str];

class_type Sys_DateTime, { class => 'DateTime' };

##############
# * TUSK Types
##############

class_type TUSK_DateTime, { class => 'HSDB4::DateTime' };
class_type TUSK_Objective, { class => 'HSDB4::SQLRow::Objective' };
class_type School, { class => 'TUSK::Core::School' };
class_type ClassMeeting, { class => 'HSDB45::ClassMeeting' };

role_type XML_Object, { role => 'TUSK::XML::Object' };

#############
# * XSD Types
#############

subtype xs_date, as Str,
    where { $_ =~ m{ \A -?
                     \d{4,} - \d{2} - \d{2}   # date
                     (([-+]) \d{2}:\d{2} | Z) # timezone
                     \z }xms };

subtype xs_duration, as Str,
    where { $_ =~ m{ \A -?
                     P
                     (?:[0-9]+Y)?
                     (?:[0-9]+M)?
                     (?:[0-9]+D)?
                     (?:T
                         (?:[0-9]+H)?
                         (?:[0-9]+M)?
                         (?:[0-9]+(?:\.[0-9]+)?S)?
                     )?
                     \z }xms };

enum xs_boolean, qw( 0 1 true false );

######################
# * Medbiquitous Types
######################

subtype NonNullString,
    as Str,
    where { length($_) > 0 };

subtype Medbiq_CompetencyObjectReference,
    as Str,
    where { $_ =~ m{ \A \s*
                     /CurriculumInventory/Expectations/CompetencyObject
                     \[ lom:lom/lom:general/lom:identifier/lom:entry
                     \s? = \s?
                     ' [^']+ '
                     \]
                     \s* \z }xms };

subtype Medbiq_Domain,
    as Str,
    where { m/ \A idd: .+ : .+ \z /xms };

class_type Medbiq_UniqueID, { class => 'TUSK::Medbiq::UniqueID' };
class_type Medbiq_Address, { class => 'TUSK::Medbiq::Address' };
class_type Medbiq_Country, { class => 'TUSK::Medbiq::Address::Country' };
class_type Medbiq_Institution, { class => 'TUSK::Medbiq::Institution' };
class_type Medbiq_CurriculumInventory, {
    class => 'TUSK::Medbiq::CurriculumInventory'
};
class_type Medbiq_VocabularyTerm, { class => 'TUSK::Medbiq::VocabularyTerm' };
class_type Medbiq_Program, { class => 'TUSK::Medbiq::Program' };
class_type Medbiq_Events, { class => 'TUSK::Medbiq::Events' };
class_type Medbiq_Expectations, { class => 'TUSK::Medbiq::Expectations' };
class_type Medbiq_AcademicLevels, { class => 'TUSK::Medbiq::AcademicLevels' };
class_type Medbiq_Sequence, { class => 'TUSK::Medbiq::Sequence' };
class_type Medbiq_Integration, { class => 'TUSK::Medbiq::Integration' };
class_type Medbiq_Event, { class => 'TUSK::Medbiq::Event' };
class_type Medbiq_Keyword, { class => 'TUSK::Medbiq::Keyword' };
class_type Medbiq_InstructionalMethod,
    { class => 'TUSK::Medbiq::InstructionalMethod' };
class_type Medbiq_AssessmentMethod,
    { class => 'TUSK::Medbiq::AssessmentMethod' };
class_type Medbiq_CompetencyObject,
    { class => 'TUSK::Medbiq::CompetencyObject' };
class_type Medbiq_CompetencyFramework,
    { class => 'TUSK::Medbiq::CompetencyFramework' };
class_type Medbiq_SupportingInformation,
    { class => 'TUSK::Medbiq::SupportingInformation' };
class_type Medbiq_Identifier,
    { class => 'TUSK::Medbiq::Identifier' };
class_type Medbiq_Relation,
    { class => 'TUSK::Medbiq::Relation' };
class_type Medbiq_LOM,
    { class => 'TUSK::Medbiq::LOM' };

enum Medbiq_Address_Category,
    qw( Residential Business Undeliverable );

enum Medbiq_Address_Restriction,
    qw( Unrestricted Restricted Confidential );

enum Medbiq_ContextValues,
    ('school', 'higher education', 'training', 'other');


#############
# * Coercions
#############

coerce StrArrayRef, from Str, via { [ $_ ] };

coerce TUSK_DateTime,
    from Sys_DateTime,
    via { HSDB4::DateTime->new->in_unix_time( $_->epoch ) },
    from xs_date,
    via {
        my $xsd = $_;
        $xsd =~ m{ \A -?
                   (\d{4,}) - (\d{2}) - (\d{2})
                   (([-+]) \d{2}:\d{2} | Z)
                   \z }xms;
        my $year = $1;
        my $month = $2;
        my $day = $3;
        HSDB4::DateTime->new->in_mysql_date(
            sprintf('%s-%s-%s', $year, $month, $day)
        )
    }
    ;

coerce Sys_DateTime,
    from TUSK_DateTime,
    via { DateTime->from_epoch( epoch => $_->out_unix_time ) },
    from xs_date,
    via {
        my $xsd = $_;
        $xsd =~ m{ \A -?
                   (\d{4,}) - (\d{2}) - (\d{2})
                   (([-+]) \d{2}:\d{2} | Z)
                   \z }xms;
        my $year = $1;
        my $month = $2;
        my $day = $3;
        DateTime->new(year => $year, month => $month, day => $day)
    }
    ;

coerce School,
    from Str,
    via {
        TUSK::Core::School->lookupReturnOne(
            qq{ school_name = '$_' }
        )
    };

coerce xs_date,
    from TUSK_DateTime,
    via { $_->out_mysql_date . "Z" },
    from Sys_DateTime,
    via { $_->ymd . "Z" };


1;

###########
# * Perldoc
###########

__END__

=head1 NAME

TUSK::Types - Common types and coercions for TUSK objects

=head1 VERSION

This documentation refers to L<TUSK::Types> v0.0.1.

=head1 SYNOPSIS

  use TUSK::Types;

=head1 DESCRIPTION

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
