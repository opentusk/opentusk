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

package TUSK::Medbiq::Event;

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

use TUSK::Core::Objective;
use TUSK::Medbiq::Types qw( NonNullString VocabularyTerm );
use TUSK::Types qw( TUSK_Objective ClassMeeting );
use Types::Standard qw( HashRef Str Maybe ArrayRef );
use Types::XSD qw( Duration Boolean );
use TUSK::Namespaces ':all';
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

has dao => (
    is => 'ro',
    isa => ClassMeeting,
    required => 1,
);

has objectives => (
    is => 'ro',
    isa => HashRef[TUSK_Objective],
    lazy => 1,
    builder => '_build_objectives',
);

has id => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_id',
);

has Title => (
    is => 'ro',
    isa => NonNullString,
    lazy => 1,
    builder => '_build_Title',
);

has EventDuration => (
    is => 'ro',
    isa => Duration,
    lazy => 1,
    builder => '_build_EventDuration',
);

has Description => (
    is => 'ro',
    isa => Maybe[Str],
    lazy => 1,
    builder => '_build_Description',
);

has Keyword => (
    is => 'ro',
    isa => ArrayRef[TUSK::Medbiq::Types::Keyword],
    lazy => 1,
    builder => '_build_Keyword',
);

has Interprofessional => (
    is => 'ro',
    isa => Maybe[Boolean],
    lazy => 1,
    builder => '_build_Interprofessional',
);

has CompetencyObjectReference => (
    is => 'ro',
    isa => ArrayRef[TUSK::Medbiq::Types::CompetencyObjectReference],
    lazy => 1,
    builder => '_build_CompetencyObjectReference',
);

has ResourceType => (
    is => 'ro',
    isa => ArrayRef[VocabularyTerm],
    lazy => 1,
    builder => '_build_ResourceType',
);

has InstructionalMethod => (
    is => 'ro',
    isa => ArrayRef[TUSK::Medbiq::Types::InstructionalMethod],
    lazy => 1,
    builder => '_build_InstructionalMethod',
);

has AssessmentMethod => (
    is => 'ro',
    isa => ArrayRef[TUSK::Medbiq::Types::AssessmentMethod],
    lazy => 1,
    builder => '_build_AssessmentMethod',
);


############
# * Builders
############

sub _build_namespace { return curriculum_inventory_ns(); }
sub _build_xml_attributes { [ qw(id) ] }
sub _build_xml_content {
    return [ qw( Title EventDuration Description Keyword Interprofessional
                 CompetencyObjectReference ResourceType InstructionalMethod
                 AssessmentMethod ) ];
}

sub _build_id {
    my $self = shift;
    return 'event-' . $self->dao->primary_key;
}

sub _build_Title {
    my $self = shift;
    my $title = $self->dao->title || 'Untitled Event';
    return $title;
}

sub _build_EventDuration {
    my $self = shift;
    my $start = $self->dao->start_time;
    my $end = $self->dao->end_time;
    return $self->_duration_string_from_mysql_times({
        start => $start, end => $end
    });
}

sub _build_Description {
    my $self = shift;
    return undef;
}

sub _build_Keyword {
    my $self = shift;
    return [];
}

sub _build_Interprofessional {
    my $self = shift;
    return undef;
}

sub _build_objectives {
    my $self = shift;
    my %objective_from_id;
    foreach my $cm_link ( @{ $self->dao->child_objectives } ) {
        my $id = $cm_link->getObjectiveID();
        if ( ! exists $objective_from_id{$id} ) {
            $objective_from_id{$id} = $cm_link->getObjective();
        }
    }
    foreach my $content ( $self->dao->child_content() ) {
        foreach my $c_link ( $content->child_objectives() ) {
            my $id = $c_link->primary_key();
            if ( ! exists $objective_from_id{$id} ) {
                $objective_from_id{ $id }
                    = TUSK::Core::Objective->new->lookupKey($id);
            }
        }
    }
    return \%objective_from_id;
}

sub _build_CompetencyObjectReference {
    my $self = shift;
    my $co_ref_fmt = q{/CurriculumInventory/Expectations/CompetencyObject}
        . q{[lom:lom/lom:general/lom:identifier/lom:entry='objective-%d']};
    my @competency_links
        = map { sprintf($co_ref_fmt, $_) } keys %{ $self->objectives };
    return \@competency_links;
}

sub _build_ResourceType {
    my $self = shift;
    return [];
}

sub _build_InstructionalMethod {
    my $self = shift;
    my $type = $self->dao->type;
    my @methods;
    if (TUSK::Medbiq::InstructionalMethod->has_medbiq_translation($type)) {
        push @methods, TUSK::Medbiq::InstructionalMethod->medbiq_method({
            class_meeting_type => $type,
            primary => 1,
        });
    }
    return \@methods;
}

sub _build_AssessmentMethod {
    my $self = shift;
    my $type = $self->dao->type;
    my @methods;
    if (TUSK::Medbiq::AssessmentMethod->has_medbiq_translation($type)) {
        push @methods, TUSK::Medbiq::AssessmentMethod->medbiq_method({
            class_meeting_type => $type,
            purpose => 'Formative',
        });
    }
    return \@methods;
}


#################
# * Class methods
#################

###################
# * Private methods
###################

sub _duration_string_from_mysql_times {
    my ($self, $arg_ref) = @_;
    my $start = $arg_ref->{start};
    my $end = $arg_ref->{end};
    my ($hh1, $mm1) = $start =~ m{ \A (\d{2}) : (\d{2}) : \d{2}
                                   (?: \. \d+)? \z }xms;
    my ($hh2, $mm2) = $end   =~ m{ \A (\d{2}) : (\d{2}) : \d{2}
                                   (?: \. \d+)? \z }xms;
    my $minute_diff = 0 + $mm2 - $mm1;
    my $hour_diff   = 0 + $hh2 - $hh1;
    if ($minute_diff < 0) {
        $hour_diff -= 1;
        $minute_diff += 60;
    }
    my $duration_string = 'PT';
    $duration_string .= $hour_diff . 'H' if $hour_diff;
    $duration_string .= $minute_diff . 'M' if $minute_diff;
    return $duration_string;
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

TUSK::Medbiq::Event - A short description of the module's purpose

=head1 VERSION

This documentation refers to L<TUSK::Medbiq::Event> v0.0.1.

=head1 SYNOPSIS

  use TUSK::Medbiq::Event;

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
