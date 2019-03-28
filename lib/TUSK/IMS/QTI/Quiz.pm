# Copyright 2019 Tufts University
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

package TUSK::IMS::QTI::Quiz;

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

use Types::Standard qw( Int Str StrictNum );
use TUSK::Types qw( Course Quiz );
use TUSK::IMS::Types qw( QTIAssignment );
use TUSK::IMS::Namespaces ':all';
use TUSK::IMS::QTI::Assignment;

use Moose;
with 'TUSK::XML::RootObject';

####################
# * Class attributes
####################

has course => (
    is => 'ro',
    isa => Course,
    required => 1,
);

has quiz => (
    is => 'ro',
    isa => Quiz,
    required => 1,
);

has total_points => (
    is => 'ro',
    isa => StrictNum,
    required => 1,
);

has identifier => (
    is => 'ro',
    isa => Int,
    lazy => 1,
    builder => '_build_identifier'
);

has schemaLocation => (
    traits => [qw/Namespaced/],
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_schemaLocation',
    namespace => xml_schema_instance_ns,
);

has title => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_title'
);

has description => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_description'
);

has shuffle_answers => (
    is => 'ro',
    isa => Str,
    default => sub { 'false' },
);


has scoring_policy => (
    is => 'ro',
    isa => Str,
    default => sub { 'keep_highest' },
);

has hide_results => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_hide_results'
);


has quiz_type => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_quiz_type'
);

has points_possible => (
    is => 'ro',
    isa => Int,
    lazy => 1,
    builder => '_build_points_possible'
);

has require_lockdown_browser => (
    is => 'ro',
    isa => Str,
    default => sub { 'false' },
);

has require_lockdown_browser_for_results => (
    is => 'ro',
    isa => Str,
    default => sub { 'false' },
);


has require_lockdown_browser_monitor => (
    is => 'ro',
    isa => Str,
    default => sub { 'false' },
);

has lockdown_browser_monitor_data => (
    is => 'ro',
    isa => Str,
    default => sub { '' },
);

has show_correct_answers => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_show_correct_answers'
);

has anonymous_submissions => (
    is => 'ro',
    isa => Str,
    default => sub { 'false' }
);

has could_be_locked => (
    is => 'ro',
    isa => Str,
    default => sub { 'false' }
);

has allowed_attempts => (
    is => 'ro',
    isa => Str,
    default => sub { '1' }
);

has one_question_at_a_time => (
    is => 'ro',
    isa => Str,
    default => sub { 'false' }
);

has cant_go_back => (
    is => 'ro',
    isa => Str,
    default => sub { 'false' }
);

has available => (
    is => 'ro',
    isa => Str,
    default => sub { 'false' }
);

has one_time_results => (
    is => 'ro',
    isa => Str,
    default => sub { 'false' }
);

has only_visible_to_overrides => (
    is => 'ro',
    isa => Str,
    default => sub { 'false' }
);

has show_correct_answers_last_attempt => (
    is => 'ro',
    isa => Str,
    default => sub { 'false' }
);

has show_correct_answers_last_attempt => (
    is => 'ro',
    isa => Str,
    default => sub { 'false' }
);

has module_locked => (
    is => 'ro',
    isa => Str,
    default => sub { 'false' }
);

has assignment => (
    is => 'ro',
    isa => QTIAssignment,
    lazy => 1,
    builder => '_build_assignment'
);

has assignment_group_identifierref  => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_assignment_group_identifierref'
);

has assignment_overrides  => (
    is => 'ro',
    isa => Str,
    default => sub { '' },
);

############
# * Builders
############

sub _build_namespace { qti_quiz_ns }
sub _build_tagName { 'quiz' }

sub _build_xml_content {
    return [ qw(
       title
       description
       shuffle_answers
       scoring_policy
       hide_results
       quiz_type
       points_possible
       require_lockdown_browser
       require_lockdown_browser_for_results
       require_lockdown_browser_monitor
       lockdown_browser_monitor_data
       show_correct_answers
       anonymous_submissions
       could_be_locked
       allowed_attempts
       one_question_at_a_time
       cant_go_back
       available
       one_time_results
       show_correct_answers_last_attempt
       only_visible_to_overrides
       module_locked
       assignment
       assignment_group_identifierref
       assignment_overrides
    )];
}

sub _build_xml_attributes {
    return [ qw( identifier schemaLocation )];
}

sub _build_identifier {
    my $self = shift;
    return $self->quiz()->getPrimaryKeyID();
}

sub _build_schemaLocation {
    my $self = shift;
    return "http://canvas.instructure.com/xsd/cccv1p0 https://canvas.instructure.com/xsd/cccv1p0.xsd"
}

sub _build_title {
    my $self = shift;
    return $self->course()->title();
}

sub _build_description {
    my $self = shift;
    return $self->quiz()->getInstructions();
}

sub _build_hide_results {
    my $self = shift;
    return ($self->quiz->getQuizType() eq 'FeedbackQuiz') ? '' : 'always';
}

sub _build_quiz_type {
    my $self = shift;
    return ($self->quiz()->getQuizType() eq 'SelfAssesment') ? 'pratice_quiz' :'assignment';
}

sub _build_points_possible {
    my $self = shift;
    return $self->total_points();
}

sub _build_assignment {
    my $self = shift;
    return TUSK::IMS::QTI::Assignment->new(quiz => $self->quiz(), total_points => $self->total_points(), course => $self->course());
}

sub _build_show_correct_answers {
    my $self = shift;
    return ($self->quiz()->getQuizType() eq 'FeedbackQuiz') ? 'true' : 'false';
}

sub _build_assignment_group_identifierref {
    my $self = shift;
    return 'groupidref:' . $self->course()->primary_key();
}

###########
# * Cleanup
###########

__PACKAGE__->meta->make_immutable;
no Moose;

1;
