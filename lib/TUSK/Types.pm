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

use Type::Library
    -base,
    -declare => qw(
		      AcademicLevel
                      ClassMeeting
                      Competency
                      NonNullString
                      School
                      StrArrayRef
                      StrHashRef
                      Sys_DateTime
		      Time
                      TUSK_DateTime
                      TUSK_XSD_Date
                      UnsignedInt
                      UnsignedNum
		      Umls_Keyword
                      URI
                      XHTML_Object
                      XML_Object
              );
use Type::Utils -all;
use Types::Standard qw( Int Num Str HashRef ArrayRef );
use Types::XSD;
use TUSK::Medbiq::Types qw();

#################
# * General Types
#################

declare UnsignedInt, as Int, where { $_ >= 0 };
declare UnsignedNum, as Num, where { $_ >= 0.0 };
declare URI, as Str;
declare StrHashRef, as HashRef[Str];
declare StrArrayRef, as ArrayRef[Str];
declare Time, as Str, where { $_ =~ /^(?:(?:([01]?\d|2[0-3]):)?([0-5]?\d):)?([0-5]?\d)$/ };

class_type Sys_DateTime, { class => 'DateTime' };

##############
# * TUSK Types
##############

role_type XML_Object, { role => 'TUSK::XML::Object' };

declare TUSK_XSD_Date, as Types::XSD::Date;
declare XHTML_Object, as XML_Object;

class_type AcademicLevel, { class => 'TUSK::Academic::Level' };
class_type ClassMeeting, { class => 'HSDB45::ClassMeeting' };
class_type Competency, { class => 'TUSK::Competency::Competency' };
class_type School, { class => 'TUSK::Core::School' };
class_type TUSK_DateTime, { class => 'HSDB4::DateTime' };
class_type Umls_Keyword, { class => 'TUSK::Core::Keyword' };

#############
# * Coercions
#############

coerce StrArrayRef, from Str, via { [ $_ ] };

coerce TUSK_DateTime,
    from Sys_DateTime,
    via { HSDB4::DateTime->new->in_unix_time( $_->epoch ) },
    from Types::XSD::Date,
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
    from Types::XSD::Date,
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

coerce TUSK_XSD_Date,
    from TUSK_DateTime,
    via { $_->out_mysql_date },
    from Sys_DateTime,
    via { $_->ymd };

###########
# * Cleanup
###########

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
