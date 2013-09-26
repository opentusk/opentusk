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
    qw( UnsignedInt
        UnsignedNum
        URI
        StrHashRef
        StrArrayRef
        School
        XML_Object
        xs_date
        Sys_DateTime
        TUSK_DateTime
        NonNullString
        Medbiq_Domain
        Medbiq_Address
        Medbiq_Country
        Medbiq_Address_Category
        Medbiq_Address_Restriction
        Medbiq_ContextValues
        Medbiq_UniqueID
        Medbiq_Institution
        Medbiq_Program
        Medbiq_Events
        Medbiq_Event
        Medbiq_Expectations
        Medbiq_AcademicLevels
        Medbiq_Sequence
        Medbiq_Integration
        Medbiq_VocabularyTerm
        Medbiq_CurriculumInventory )
];

use MooseX::Types::Moose ':all';

#################
# * General Types
#################

subtype UnsignedInt, as Int, where { $_ >= 0 };
subtype UnsignedNum, as Num, where { $_ >= 0.0 };

subtype StrHashRef, as HashRef[Str];

subtype StrArrayRef, as ArrayRef[Str];
coerce StrArrayRef, from Str, via { [ $_ ] };

class_type TUSK_DateTime, { class => 'HSDB4::DateTime' };
class_type Sys_DateTime, { class => 'DateTime' };
coerce TUSK_DateTime,
    from Sys_DateTime,
    via { HSDB4::DateTime->new->in_unix_time( $_->epoch ) };
coerce Sys_DateTime,
    from TUSK_DateTime,
    via { DateTime->from_epoch( epoch => $_->out_unix_time ) };

##############
# * TUSK Types
##############

class_type School, { class => 'TUSK::Core::School' };
coerce School,
    from Str,
    via {
        TUSK::Core::School->lookupReturnOne(
            qq{ school_name = '$_' }
        )
    };

role_type XML_Object, { role => 'TUSK::XML::Object' };

#############
# * XSD Types
#############

subtype xs_date, as Str,
    where { $_ =~ m{ \A -?
                     \d{4,} - \d{2} - \d{2}   # date
                     (([-+]) \d{2}:\d{2} | Z) # timezone
                     \z }xms };

coerce xs_date,
    from TUSK_DateTime,
    via { $_->out_mysql_date . "Z" },
    from Sys_DateTime,
    via { $_->ymd . "Z" };


######################
# * Medbiquitous Types
######################

subtype NonNullString,
    as Str,
    where { length($_) > 0 };

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

enum Medbiq_Address_Category,
    qw( Residential Business Undeliverable );

enum Medbiq_Address_Restriction,
    qw( Unrestricted Restricted Confidential );

enum Medbiq_ContextValues,
    ('school', 'higher education', 'training', 'other');

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
