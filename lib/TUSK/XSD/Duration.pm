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

package TUSK::XSD::Duration;

use 5.008;
use strict;
use warnings;
use version;
use utf8;
use Carp;
use Readonly;

use List::MoreUtils qw(all);

use MooseX::Types::Moose qw( Bool );
use TUSK::Types qw( UnsignedInt UnsignedNum );

use Moose;
use overload '""' => 'to_string';

our $VERSION = qv('0.0.1');

####################
# Class attributes #
####################

has is_negative => (
    is => 'ro',
    isa => Bool,
    lazy => 1,
    builder => '_build_is_negative',
);

has years => (
    is => 'ro',
    isa => UnsignedInt,
    lazy => 1,
    builder => '_build_years',
);

has months => (
    is => 'ro',
    isa => UnsignedInt,
    lazy => 1,
    builder => '_build_months',
);

has days => (
    is => 'ro',
    isa => UnsignedInt,
    lazy => 1,
    builder => '_build_days',
);

has hours => (
    is => 'ro',
    isa => UnsignedInt,
    lazy => 1,
    builder => '_build_hours',
);

has minutes => (
    is => 'ro',
    isa => UnsignedInt,
    lazy => 1,
    builder => '_build_minutes',
);

has seconds => (
    is => 'ro',
    isa => UnsignedNum,
    lazy => 1,
    builder => '_build_seconds',
);

#################
# Class methods #
#################

sub parse_string {
    my ($class, $str) = @_;
    my $is_match = $str =~ m{
        \A                    # begin string
        ( -? )                # optional preceding negative
        P                     # required
        (?: ( \d+ ) Y )?      # years
        (?: ( \d+ ) M )?      # months
        (?: ( \d+ ) D )?      # days
        (?:                   # group time components
            T                 # required if any time components
            (?: ( \d+ ) H )?  # hours
            (?: ( \d+ ) M )?  # minutes
            (?: ( \d+         # seconds
                    (?: \.    # fractional seconds
                        \d+
                    )? ) S )?
        )?                    # time component is optional
        \z                    # end string
                        }xms;
    if (! $is_match) {
        confess "Failed to parse: $str as: $class. Reason: "
            . "string does not match regex";
    }
    my %attrs;
    $attrs{is_negative} = 1 if $1;
    $attrs{years}       = $2 if $2;
    $attrs{months}      = $3 if $3;
    $attrs{days}        = $4 if $4;
    $attrs{hours}       = $5 if $5;
    $attrs{minutes}     = $6 if $6;
    $attrs{seconds}     = $7 if $7;
    return $class->new(%attrs);
}

sub to_string {
    my $self = shift;
    my $years = $self->years;
    my $months = $self->months;
    my $days = $self->days;
    my $hours = $self->hours;
    my $minutes = $self->minutes;
    my $seconds = $self->seconds;

    # zero-length duration
    if ( all { $_ == 0 } ($years, $months, $days,
                          $hours, $minutes, $seconds) ) {
        return 'P0Y';
    }

    my @comps;
    push @comps, '-' if $self->is_negative;
    push @comps, 'P';

    # date component
    push @comps, $years, 'Y' if $years;
    push @comps, $months, 'M' if $months;
    push @comps, $days, 'D' if $days;

    # time component
    my $has_time = ! ( all { $_ == 0 } ($hours, $minutes, $seconds) );
    push @comps, 'T' if $has_time;
    push @comps, $hours, 'H' if $hours;
    push @comps, $minutes, 'M' if $minutes;
    push @comps, $seconds, 'S' if $seconds;

    return join(q(), @comps);
}

###################
# Private methods #
###################

sub _build_is_negative {
    return 0;
}

sub _build_years {
    return 0;
};

sub _build_months {
    return 0;
};

sub _build_days {
    return 0;
};

sub _build_hours {
    return 0;
};

sub _build_minutes {
    return 0;
};

sub _build_seconds {
    return 0;
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

__END__

=head1 NAME

TUSK::XSD::Duration - Representation of an XSD duration, ISO-8601 standard

=head1 VERSION

This documentation refers to L<TUSK::XSD::Duration> v0.0.1.

=head1 SYNOPSIS

  use TUSK::XSD::Duration;

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
