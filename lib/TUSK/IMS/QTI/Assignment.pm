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

package TUSK::IMS::QTI::Assignment;
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

use Types::Standard qw( Str Int Undef);
use TUSK::Types qw( Quiz Course );
use TUSK::IMS::Namespaces ':all';

use Moose;
with 'TUSK::XML::Object';

####################
# * Class attributes
####################

has quiz => (
    is => 'ro',
    isa => Quiz,
    required => 1,
);

has total_points => (
    is => 'ro',
    isa => Int,
    required => 1,
);

has course => (
    is => 'ro',
    isa => Course,
    required => 1,
);

has identifier => (
    is => 'ro',
    isa => Int,
    lazy => 1,
    builder => '_build_identifier'
);

has title => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_title'
);

has due_at => (
    is => 'ro',
    isa => Str,
    default => sub { '' }
);

has lock_at => (
    is => 'ro',
    isa => Undef,
);

has unlock_at => (
    is => 'ro',
    isa => Undef,
#    default => sub { undef },
);

has module_locked => (
    is => 'ro',
    isa => Str,
    default => sub { 'false' },
);

has workflow_state => (
    is => 'ro',
    isa => Str,
    default => sub { 'unpublished' },
);

has assignment_overrides => (
    is => 'ro',
    isa => Undef,
);

has quiz_identifierref => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_quiz_identifierref',
);

has has_group_category => (
    is => 'ro',
    isa => Str,
    default => sub { 'false' },
);

has points_possible => (
    is => 'ro',
    isa => Int,
    lazy => 1,
    builder => '_build_points_possible'
);

has grading_type => (
    is => 'ro',
    isa => Str,
    default => sub { 'points' },
);


has all_day => (
    is => 'ro',
    isa => Str,
    default => sub { 'false' },
);

has submission_types => (
    is => 'ro',
    isa => Str,
    default => sub { 'online_quiz' },
);

has position => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_position'
);

has turnitin_enabled => (
    is => 'ro',
    isa => Str,
    default => sub { 'false' },
);

has vericite_enabled => (
    is => 'ro',
    isa => Str,
    default => sub { 'false' },
);

has peer_review_count => (
    is => 'ro',
    isa => Int,
    default => sub { 0 },
);

has peer_reviews => (
    is => 'ro',
    isa => Str,
    default => sub { 'false' },
);

has automatic_peer_reviews => (
    is => 'ro',
    isa => Str,
    default => sub { 'false' },
);

has aunonymous_peer_reviews => (
    is => 'ro',
    isa => Str,
    default => sub { 'false' },
);

has grade_group_students_individually => (
    is => 'ro',
    isa => Str,
    default => sub { 'false' },
);

has turnitin_enabled   => (
    is => 'ro',
    isa => Str,
    default => sub { 'false' },
);

has vericite_enabled  => (
    is => 'ro',
    isa => Str,
    default => sub { 'false' },
);

has peer_review_count  => (
    is => 'ro',
    isa => Str,
    default => sub { '0' },
);

has automatic_peer_reviews  => (
    is => 'ro',
    isa => Str,
    default => sub { 'false' },
);

has anonymous_peer_reviews  => (
    is => 'ro',
    isa => Str,
    default => sub { 'false' },
);

has grade_group_students_individually  => (
    is => 'ro',
    isa => Str,
    default => sub { 'false' },
);

has freeze_on_copy  => (
    is => 'ro',
    isa => Str,
    default => sub { 'false' },
);

has omit_from_final_grade  => (
    is => 'ro',
    isa => Str,
    default => sub { 'false' },
);

has intra_group_peer_reviews  => (
    is => 'ro',
    isa => Str,
    default => sub { 'false' },
);

has only_visible_to_overrides => (
    is => 'ro',
    isa => Str,
    default => sub { 'false' },
);

has post_to_sis => (
    is => 'ro',
    isa => Str,
    default => sub { 'false' },
);

has moderated_grading  => (
    is => 'ro',
    isa => Str,
    default => sub { 'false' },
);

has grader_count => (
    is => 'ro',
    isa => Str,
    default => sub { '0' },
);

has grader_comments_visible_to_graders  => (
    is => 'ro',
    isa => Str,
    default => sub { 'true' },
);

has anonymous_grading  => (
    is => 'ro',
    isa => Str,
    default => sub { 'false' },
);

has graders_anonymous_to_graders  => (
    is => 'ro',
    isa => Str,
    default => sub { 'false' },
);

has grader_names_visible_to_final_grader => (
    is => 'ro',
    isa => Str,
    default => sub { 'true' },
);

has anonymous_instructor_annotations  => (
    is => 'ro',
    isa => Str,
    default => sub { 'false' },
);

############
# * Builders
############

sub _build_namespace { qti_quiz_ns }
sub _build_nameTag { 'assignment' }
sub _build_xml_content {
    return [ qw(
       title
       due_at
       lock_at
       unlock_at
       module_locked
       workflow_state
       assignment_overrides
       quiz_identifierref
       has_group_category
       points_possible
       grading_type
       all_day
       submission_types
       position
       turnitin_enabled
       vericite_enabled
       peer_review_count
       peer_reviews
       automatic_peer_reviews
       anonymous_peer_reviews
       grade_group_students_individually
       freeze_on_copy
       omit_from_final_grade
       intra_group_peer_reviews
       only_visible_to_overrides
       post_to_sis
       moderated_grading
       grader_count
       grader_comments_visible_to_graders
       anonymous_grading
       graders_anonymous_to_graders
       grader_names_visible_to_final_grader
       anonymous_instructor_annotations
    )];
}

sub _build_xml_attributes { [ 'identifier' ] }
sub _build_enpty_tags { [ 'assignment_override' ] }

sub _build_identifier {
    my $self = shift;
    return $self->quiz()->getPrimaryKeyID();
}

sub _build_title {
    my $self = shift;
    return $self->quiz()->getTitle();
}

sub _build_quiz_identifierref {
    my $self = shift;
    return $self->quiz()->getPrimaryKeyID();
}

sub _build_points_possible {
    my $self = shift;
    return $self->total_points();
}

sub _build_position {
    my $self = shift;
    # $self->quiz()->
    return 1;
}

###########
# * Cleanup
###########

__PACKAGE__->meta->make_immutable;
no Moose;

1;
