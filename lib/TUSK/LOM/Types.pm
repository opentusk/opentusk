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

package TUSK::LOM::Types;

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
                      CharacterString
                      LanguageCode
                      DateTime
                      DateTimeString
                      Duration
                      DurationString
                      LangString
                      Vocabulary
                      LOM
                      General
                      LifeCycle
                      MetaMetadata
                      Technical
                      Educational
                      Rights
                      Relation
                      Annotation
                      Classification
                      Identifier
              );
use Type::Utils -all;
use Types::Standard -types;

#############
# * LOM Types
#############

class_type LOM, { class => 'TUSK::LOM' };
class_type LangString, { class => 'TUSK::LOM::LangString' };
class_type Vocabulary, { class => 'TUSK::LOM::Vocabulary' };
class_type DateTime, { class => 'TUSK::LOM::DateTime' };
class_type Duration, { class => 'TUSK::LOM::Duration' };

# ** Simple types

declare CharacterString, as Str;
declare LanguageCode,
    as Str,
    where {
        $_ =~ m{ \A \s*
                 (
                     none                # special code in LOM
                 |   ( [ix] (- .+)? )    # reserved prefix
                 |   ( \w{2,3} (- .+)? ) # 2 or 3 letter language codes
                 )
                 \s* \z }xms
    };

# DateTimeString and DurationString are not the same as the datetime
# and duration XML Schema primitive types. See LOM specification for
# more details.
#
# TODO: Implement additional constraints from specification:
#       - DateTimeString:
#         - year >= 0001
#         - 01 <= month <= 12
#         - validate day based on year, month
#         - 00 <= hour <= 23
#         - 00 <= minute <= 59
#         - 00 <= second <= 59
#         - same for timezone +/- hh:mm
#       - DurationString
#         - at least one positive integer
declare DateTimeString,
    as Str,
    where {
        $_ =~ m{ \A \s*
                 \d{4}                           # year
                 ( - \d{2}                       # month
                     ( - \d{2}                   # day
                         ( T \d{2}               # hour
                             ( : \d{2}           # minute
                                 ( : \d{2}       # second
                                     ( \. \d+ )? # fractional second
                                     ( Z         # timezone
                                     | ( [+-] \d{2}
                                             ( : \d{2} )?
                                         )
                                     )?          # end timezone
                                 )?              # end second
                             )?                  # end minute
                         )?                      # end hour
                     )?                          # end day
                 )?                              # end month
                 \s* \z }xms
    };
declare DurationString,
    as Str,
    where {
        $_ =~ m{ \A \s*
                 P                  # duration marker
                 (\d+ Y)?           # years
                 (\d+ M)?           # months
                 (\d+ D)?           # days
                 (T                 # time marker
                     (\d+ H)?       # hours
                     (\d+ M)?       # minutes
                     (\d+           # seconds
                         (\. \d+)?  # fractional seconds
                         S )?       # end seconds
                 )?                 # end time
                 \s* \z }xms
    };

# ** General
class_type General, { class => 'TUSK::LOM::General' };
class_type Identifier, { class => 'TUSK::LOM::Identifier' };

# ** LifeCycle
class_type LifeCycle, { class => 'TUSK::LOM::LifeCycle' };

# ** MetaMetadata
class_type MetaMetadata, { class => 'TUSK::LOM::MetaMetadata' };

# ** Technical
class_type Technical, { class => 'TUSK::LOM::Technical' };

# ** Educational
class_type Educational, { class => 'TUSK::LOM::Educational' };

# ** Rights
class_type Rights, { class => 'TUSK::LOM::Rights' };

# ** Relation
class_type Relation, { class => 'TUSK::LOM::Relation' };

# ** Annotation
class_type Annotation, { class => 'TUSK::LOM::Annotation' };

# ** Classification
class_type Classification, { class => 'TUSK::LOM::Classification' };

###########
# * Cleanup
###########

1;

###########
# * Perldoc
###########

__END__

=head1 NAME

TUSK::LOM::Types - A short description of the module's purpose

=head1 VERSION

This documentation refers to L<TUSK::LOM::Types> v0.0.1.

=head1 SYNOPSIS

  use TUSK::LOM::Types;

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
