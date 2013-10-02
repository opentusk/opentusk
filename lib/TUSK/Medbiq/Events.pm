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

package TUSK::Medbiq::Events;

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

use MooseX::Types::Moose ':all';
use TUSK::Types ':all';
use TUSK::Medbiq::Namespaces ':all';
use HSDB4::Constants;
use HSDB45::ClassMeeting;
use TUSK::Medbiq::Event;
use TUSK::Medbiq::InstructionalMethod;
use TUSK::Medbiq::AssessmentMethod;

#########
# * Setup
#########

use Moose;
with 'TUSK::XML::Object';

####################
# * Class attributes
####################

has school => (
    is => 'ro',
    isa => School,
    required => 1,
    coerce => 1,
);

has start_date => (
    is => 'ro',
    isa => TUSK_DateTime,
    required => 1,
    coerce => 1,
);

has end_date => (
    is => 'ro',
    isa => TUSK_DateTime,
    required => 1,
    coerce => 1,
);

has Event => (
    is => 'ro',
    isa => ArrayRef[Medbiq_Event],
    lazy => 1,
    builder => '_build_Event',
);



############
# * Builders
############

sub _build_namespace { curriculum_inventory_ns }
sub _build_xml_content { [ qw( Event ) ] }

sub _build_Event {
    my $self = shift;
    my @class_meetings = $self->_class_meetings;
    @class_meetings = grep { $self->_keep_meeting($_) } @class_meetings;
    my @event_list;
    my $i = 0;
    # my $limit = 10;
    foreach my $cm ( @class_meetings ) {
        push @event_list, TUSK::Medbiq::Event->new(
            dao => $cm,
        );
        $i++;
        # last unless $i < $limit;
    }
    return \@event_list;
}

#################
# * Class methods
#################

###################
# * Private methods
###################

sub _keep_meeting {
    my $self = shift;
    my $cm = shift;
    my $type = $cm->type;
    return ( TUSK::Medbiq::InstructionalMethod->has_medbiq_translation($type)
          || TUSK::Medbiq::AssessmentMethod->has_medbiq_translation($type) );
}

sub _class_meetings {
    my $self = shift;
    my $cm = HSDB45::ClassMeeting->new(
        _school => $self->school->getSchoolName
    );
    my $dbh = HSDB4::Constants::def_db_handle();
    return $cm->lookup_conditions(
        join(
            ' AND ',
            sprintf(
                'meeting_date BETWEEN %s AND %s',
                $dbh->quote( $self->start_date->out_mysql_date ),
                $dbh->quote( $self->end_date->out_mysql_date ),
            ),
         ),
    );
}

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

TUSK::Medbiq::Events - A short description of the module's purpose

=head1 VERSION

This documentation refers to L<TUSK::Medbiq::Events> v0.0.1.

=head1 SYNOPSIS

  use TUSK::Medbiq::Events;

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
