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

package TUSK::Medbiq::CurriculumInventory;

###########
# * Imports
###########

use 5.008;
use strict;
use warnings;
use version;
use utf8;
use Carp;
use Readonly;
use POSIX qw(strftime);
use DateTime;

use Types::Standard qw( Str ArrayRef HashRef Int InstanceOf);
use TUSK::Medbiq::Types qw( UniqueID NonNullString );
use TUSK::Types qw( School AcademicLevel URI TUSK_XSD_Date TUSK_DateTime Competency);
use TUSK::Academic::Level;
use TUSK::Namespaces ':all';
use TUSK::Medbiq::UniqueID;
use TUSK::Medbiq::Institution;
use TUSK::Medbiq::Program;
use TUSK::Medbiq::Events;
use TUSK::Medbiq::Expectations;
use TUSK::Medbiq::AcademicLevels;
use TUSK::Medbiq::Sequence;
use TUSK::Competency::Competency;
use TUSK::Course::AcademicLevel;

use Moose;
with 'TUSK::XML::RootObject';

our $VERSION = qv('0.0.1');

####################
# * Class attributes
####################

has school => (
    is => 'ro',
    isa => School,
    coerce => 1,
    required => 1,
);

has schemaLocation => (
    traits => [qw/Namespaced/],
    is => 'ro',
    isa => Str,
    lazy => 1,
    builder => '_build_schemaLocation',
    namespace => xml_schema_instance_ns,
);

has ReportID => (
    is => 'ro',
    isa => UniqueID,
    lazy => 1,
    builder => '_build_ReportID',
);

has Institution => (
    is => 'ro',
    isa => TUSK::Medbiq::Types::Institution,
    lazy => 1,
    builder => '_build_Institution',
);

has program_name => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    default => sub {
	my $self = shift;
	return $TUSK::Constants::Schools{$self->school()->getSchoolName()}{Degree};
    }
);

has Program => (
    is => 'ro',
    isa => TUSK::Medbiq::Types::Program,
    lazy => 1,
    builder => '_build_Program',
);

has Title => (
    is => 'ro',
    isa => NonNullString,
    lazy => 1,
    default => '',
);

has ReportDate => (
    is => 'ro',
    isa => TUSK_XSD_Date,
    coerce => 1,
    lazy => 1,
    builder => '_build_ReportDate',
);

has ReportingStartDate => (
    is => 'ro',
    isa => TUSK_XSD_Date,
    coerce => 1,
    required => 1,
);

has ReportingEndDate => (
    is => 'ro',
    isa => TUSK_XSD_Date,,
    coerce => 1,
    required => 1,
);

has Language => (
    is => 'ro',
    isa => NonNullString,
    lazy => 1,
    builder => '_build_Language',
);

has Description => (
    is => 'ro',
    isa => NonNullString,
    lazy => 1,
    default => ' ',		    
);

has SupportingLink => (
    is => 'ro',
    isa => URI,
    required => 0,
);

has Events => (
    is => 'ro',
    isa => TUSK::Medbiq::Types::Events,
    lazy => 1,
    builder => '_build_Events',
);

has Expectations => (
    is => 'ro',
    isa => TUSK::Medbiq::Types::Expectations,
    lazy => 1,
    builder => '_build_Expectations',
);

has AcademicLevels => (
    is => 'ro',
    isa => TUSK::Medbiq::Types::AcademicLevels,
    lazy => 1,
    builder => '_build_AcademicLevels',
);

has Sequence => (
    is => 'ro',
    isa => TUSK::Medbiq::Types::Sequence,
    lazy => 1,
    builder => '_build_Sequence',
);

has Integration => (
    is => 'ro',
    isa => TUSK::Medbiq::Types::Integration,
    required => 0,
);

has event_competencies => (
    is => 'ro',
    isa => ArrayRef[Competency],
    lazy => 1,
    builder => '_build_event_competencies',
);

has course_competencies => (
    is => 'ro',
    isa => ArrayRef[Competency],
    lazy => 1,
    builder => '_build_course_competencies',
);

has school_competencies => (
    is => 'ro',
    isa => ArrayRef[Competency],
    lazy => 1,
    builder => '_build_school_competencies',
);

has national_competencies => (
    is => 'ro',
    isa => ArrayRef[Competency],
    lazy => 1,
    builder => '_build_national_competencies',
);

has academic_levels_with_courses => (
    is => 'ro',
    isa => ArrayRef[InstanceOf['TUSK::Course::AcademicLevel']],
    lazy => 1,
    builder => '_build_academic_levels_with_courses',
);

has sorted_academic_levels => (
    is => 'ro',
    isa => ArrayRef[AcademicLevel],
    lazy => 1,
    builder => '_build_sorted_academic_levels',
);


######################
# * Private attributes
######################

has _now => (
    is => 'ro',
    isa => 'DateTime',
    lazy => 1,
    builder => '_build__now',
);


############
# * Builders
############

sub _build_namespace { curriculum_inventory_ns }
sub _build_tagName { 'CurriculumInventory' }

sub _build_xml_content {
    return [ qw( ReportID
                 Institution
                 Program
                 Title
                 ReportDate
                 ReportingStartDate
                 ReportingEndDate
                 Language
                 Description
                 SupportingLink
                 Events
                 Expectations
                 AcademicLevels
                 Sequence
                 Integration ) ];
}

sub _build_xml_attributes { [ qw( schemaLocation ) ] }

sub _build__now {
    return DateTime->now;
}


sub _build_schemaLocation {
    return 'http://ns.medbiq.org/curriculuminventory/v1/curriculuminventory.xsd';
}

sub _build_ReportID {
    return TUSK::Medbiq::UniqueID->new;
}

sub _build_Institution {
    return TUSK::Medbiq::Institution->new;
}

sub _build_Program {
    my $self = shift;
    return TUSK::Medbiq::Program->new(ProgramName => $self->program_name());
}

sub _build_Title {
    my $self = shift;
    return '! PLACEHOLDER TITLE !';
}

sub _build_Description {
    return '! PLACEHOLDER DESCRIPTION !';
}

sub _build_ReportDate {
    return shift->_now;
}

sub _build_Language {
    return 'en-US';
}

sub _build_Events {
    my $self = shift;

    return TUSK::Medbiq::Events->new(
        school => $self->school(),
        start_date => $self->ReportingStartDate(),
        end_date => $self->ReportingEndDate(),
        competencies => $self->event_competencies(),
    );
}

sub _build_course_competencies {
    my $self = shift;

    my @course_competencies = ();
    my $relation_obj_class = 'TUSK::Competency::Relation';

    foreach my $alwc (@{$self->academic_levels_with_courses}) {
	foreach my $comp (@{$alwc->getJoinObjects('TUSK::Competency::Competency')}) {
	    $comp->setJoinObjects($relation_obj_class, $alwc->getJoinObject($relation_obj_class));
	    $comp->setJoinObjects('competency_level', $alwc->getJoinObject('competency_level'));
	    push @course_competencies, $comp;
	}
    }
    return \@course_competencies;
}

sub _build_Expectations {
    my $self = shift;

    return TUSK::Medbiq::Expectations->new(
        school => $self->school,
        event_competencies => $self->event_competencies,
        school_competencies => $self->school_competencies,
        national_competencies => $self->national_competencies,
	course_competencies => $self->course_competencies,
        framework_id => $self->ReportID()->id(),
    );
}

sub _build_sorted_academic_levels {
    my $self = shift;

    my %levels = ();
    foreach my $link (@{$self->academic_levels_with_courses()}) {
	if (my $level = $link->getJoinObject('TUSK::Academic::Level')) {
	    $levels{$level->getPrimaryKeyID()} = $level;
	}
    }

    ## medbiq requires levels in sequence starting with 1 so we reset the sort order on the fly
    my $num = 1;
    my @sorted_levels = ();
    foreach my $level (sort { $a->getSortOrder() <=> $b->getSortOrder() } values %levels) {
	$level->setSortOrder($num++);
	push @sorted_levels, $level;
    }
    return \@sorted_levels;
}

sub _build_AcademicLevels {
    my $self = shift;

    return TUSK::Medbiq::AcademicLevels->new(levels => $self->sorted_academic_levels );
}

sub _build_Sequence {
    my $self = shift;

    return TUSK::Medbiq::Sequence->new(
        school => $self->school(),
        levels => { map { $_->getPrimaryKeyID() => $_->getSortOrder() } @{$self->sorted_academic_levels()} },
        levels_with_courses => $self->academic_levels_with_courses(),
    );
}

sub _build_event_competencies {
    my $self = shift;
    my $school_db = $self->school()->getSchoolDb();

    my $class_meeting_competencies = TUSK::Competency::Competency->lookup(undef, undef, undef, undef, [
	  TUSK::Core::JoinObject->new('TUSK::Enum::Data', {
	      jointype => 'inner',
	      origkey => 'competency_level_enum_id',
	      joinkey => 'enum_data_id',
	      joincond => "namespace = 'competency.level_id' and short_name = 'class_meet'",
	      alias => 'competency_level',
	  }),
	  TUSK::Core::JoinObject->new('TUSK::Competency::ClassMeeting', {
	      jointype => 'inner',
	      joinkey => 'competency_id',
	  }),
	  TUSK::Core::JoinObject->new('TUSK::Core::HSDB45Tables::ClassMeeting', {
	      database => $school_db,
	      jointype => 'inner',
	      origkey => 'competency_class_meeting.class_meeting_id',
	      joinkey => 'class_meeting_id',
	      joincond => "meeting_date between '" . $self->ReportingStartDate() . "' AND '" . $self->_reportingEndDateTime() . "'",
	 }),
         TUSK::Core::JoinObject->new('TUSK::ClassMeeting::Type', {
	      jointype => 'inner',
	      origkey => 'class_meeting.type_id',
	      joinkey => 'class_meeting_type_id',
	 }),
	 TUSK::Core::JoinObject->new('TUSK::Enum::Data', {
	      jointype => 'inner',
	      origkey => 'class_meeting_type.curriculum_method_enum_id',
	      joinkey => 'enum_data_id',
	      joincond => "curriculum_method.namespace = 'class_meeting_type.curriculum_method_id' and curriculum_method.short_name in ('assessment', 'instruction')",
	      alias => 'curriculum_method',
	  }),
	 TUSK::Core::JoinObject->new('TUSK::Competency::Relation', {
	      origkey => 'competency_id',
	      joinkey => 'competency_id_1',
	})
    ]);

    my $content_competencies = TUSK::Competency::Competency->lookup(undef, undef, undef, undef, [
	  TUSK::Core::JoinObject->new('TUSK::Enum::Data', {
	      jointype => 'inner',
	      origkey => 'competency_level_enum_id',
	      joinkey => 'enum_data_id',
	      joincond => "namespace = 'competency.level_id' and short_name = 'content'",
	      alias => 'competency_level',
	  }),
	  TUSK::Core::JoinObject->new('TUSK::Competency::Content', {
	      jointype => 'inner',
	      joinkey => 'competency_id',
	  }),
	  TUSK::Core::JoinObject->new('TUSK::Core::HSDB45Tables::LinkClassMeetingContent', {
	      database => $school_db,
	      jointype => 'inner',
	      origkey => 'competency_content.content_id',
	      joinkey => 'child_content_id',
	 }),
	  TUSK::Core::JoinObject->new('TUSK::Core::HSDB45Tables::ClassMeeting', {
	      database => $school_db,
	      jointype => 'inner',
	      origkey => 'link_class_meeting_content.parent_class_meeting_id',
	      joinkey => 'class_meeting_id',
	      joincond => "meeting_date between '" . $self->ReportingStartDate() . "' AND '" . $self->_reportingEndDateTime() . "'",
	 }),
         TUSK::Core::JoinObject->new('TUSK::ClassMeeting::Type', {
	      jointype => 'inner',
	      origkey => 'class_meeting.type_id',
	      joinkey => 'class_meeting_type_id',
	 }),
	 TUSK::Core::JoinObject->new('TUSK::Enum::Data', {
	      jointype => 'inner',
	      origkey => 'class_meeting_type.curriculum_method_enum_id',
	      joinkey => 'enum_data_id',
	      joincond => "curriculum_method.namespace = 'class_meeting_type.curriculum_method_id' and curriculum_method.short_name in ('assessment', 'instruction')",
	      alias => 'curriculum_method',
	  }),
	 TUSK::Core::JoinObject->new('TUSK::Competency::Relation', {
	      origkey => 'competency_id',
	      joinkey => 'competency_id_1',
	})
    ]);

    return [ @$class_meeting_competencies, @$content_competencies ];
}


sub _build_academic_levels_with_courses {
    my $self = shift;
    my $school_db = $self->school()->getSchoolDb();

    return TUSK::Course::AcademicLevel->lookup(undef, undef, undef, undef, [
	  TUSK::Core::JoinObject->new('TUSK::Academic::Level', {
	      jointype => 'inner',
	      joinkey => 'academic_level_id',
	      joincond => 'academic_level.school_id = ' . $self->school()->getPrimaryKeyID(),
	  }),
          TUSK::Core::JoinObject->new('TUSK::Course', {
	      jointype => 'inner',
	      joinkey => 'course_id',
	      alias    => 'tusk_course',
	  }),
          TUSK::Core::JoinObject->new('TUSK::Core::HSDB45Tables::Course', {
	      database => $school_db,
	      jointype => 'inner',
	      origkey => 'tusk_course.school_course_code',
	      joinkey => 'course_id',
	      alias    => 'hsdb45_course',
	  }),
	  TUSK::Core::JoinObject->new('TUSK::Core::HSDB45Tables::ClassMeeting', {
	      database => $school_db,
	      jointype => 'inner',
	      origkey => 'hsdb45_course.course_id',
	      joinkey => 'course_id',
	      joincond => "meeting_date between '" . $self->ReportingStartDate() . "' AND '" . $self->_reportingEndDateTime() . "'",
	 }),
         TUSK::Core::JoinObject->new('TUSK::ClassMeeting::Type', {
	      jointype => 'inner',
	      origkey => 'class_meeting.type_id',
	      joinkey => 'class_meeting_type_id',
	 }),
	 TUSK::Core::JoinObject->new('TUSK::Enum::Data', {
	      jointype => 'inner',
	      origkey => 'class_meeting_type.curriculum_method_enum_id',
	      joinkey => 'enum_data_id',
	      joincond => "curriculum_method.namespace = 'class_meeting_type.curriculum_method_id' and curriculum_method.short_name in ('assessment', 'instruction')",
	      alias => 'curriculum_method',
	  }),
	 TUSK::Core::JoinObject->new('TUSK::Competency::Course', {
	      joinkey => 'course_id',
	 }),
         TUSK::Core::JoinObject->new('TUSK::Competency::Competency', {
	      origkey => 'competency_course.competency_id',
	      joinkey => 'competency_id',
	      joincond => 'competency.school_id = ' . $self->school()->getPrimaryKeyID(), 
	 }),
	 TUSK::Core::JoinObject->new('TUSK::Enum::Data', {
	      origkey => 'competency.competency_level_enum_id',
	      joinkey => 'enum_data_id',
	      joincond => "competency_level.namespace = 'competency.level_id' and competency_level.short_name = 'course'",
	      alias => 'competency_level',
	 }),
	 TUSK::Core::JoinObject->new('TUSK::Competency::Relation', {  ## course-school competencies
	      origkey => 'competency_course.competency_id',
	      joinkey => 'competency_id_1',
	})
    ]);
}

### Given course competencies, we build school competencies
sub _build_school_competencies {
    my $self = shift;
    return $self->_competencies_relation('school', [ map { $_->getPrimaryKeyID() } @{$self->course_competencies()} ]);
}

### Given school competencies, we build national competencies
sub _build_national_competencies {
    my $self = shift;
    return $self->_competencies_relation('national', [ map { $_->getPrimaryKeyID() } @{$self->school_competencies()} ]);
}


sub _reportingEndDateTime {
    my $self = shift;
    return $self->ReportingEndDate() . ' 23:59:59';
}

#################
# * Class methods
#################

###################
# * Private methods
###################

sub _competencies_relation {
    my ($self, $token, $linked_competencies) = @_;
    return [] unless scalar @$linked_competencies;

    return TUSK::Competency::Competency->lookup('', undef, undef, undef, [
	  TUSK::Core::JoinObject->new('TUSK::Enum::Data', {
	      jointype => 'inner',
	      origkey => 'competency_level_enum_id',
	      joinkey => 'enum_data_id',
	      joincond => "competency_level.short_name = '$token'",
	      alias => 'competency_level',
	  }),
	  TUSK::Core::JoinObject->new('TUSK::Competency::Relation', {
	      jointype => 'inner',
	      origkey => 'competency_id',
	      joinkey => 'competency_id_2',
	      joincond => 'competency_id_1 in (' . join(',', @$linked_competencies) . ')',
	  }),
	  TUSK::Core::JoinObject->new('TUSK::Feature::Link', {
	      origkey => 'competency_id',
	      joinkey => 'feature_id',
	  }),
	  TUSK::Core::JoinObject->new('TUSK::Enum::Data', {
	      origkey => 'feature_link.feature_type_enum_id',
	      joinkey => 'enum_data_id',
	      alias => 'feature_type',
	  }),
    ]);
}


__PACKAGE__->meta->make_immutable;
no Moose;
1;

###########
# * Perldoc
###########

__END__

=head1 NAME

TUSK::Medbiq::CurriculumInventory - Container object for a curriculum
inventory report

=head1 VERSION

This documentation refers to L<TUSK::Medbiq::CurriculumInventory> v0.0.1.

=head1 SYNOPSIS

  use XML::Writer;
  use TUSK::Medbiq::CurriculumInventory;
  my $ci = TUSK::Medbiq::CurriculumInventory->new( school => 'Default' );
  my $writer = XML::Writer->new;
  $ci->write_xml($writer);

=head1 DESCRIPTION

Given a L<TUSK::Core::School> object, L<TUSK::Medbiq::CurriculumInventory>
will contain the necessary information for a curriculum inventory
report.

This object is meant to be constructed by L<TUSK::Medbiq::Report>.

See the Medbiquitous curriculum inventory specification at
L<http://ns.medbiq.org/curriculuminventory/v1/> for more information.

=head1 ATTRIBUTES

=over 4

=item school

A required attribute of type L<TUSK::Medbiq::Types>::School.

=back

=head1 METHODS

=over 4

=item write_xml

Output a curriculum inventory document to the L<XML::Writer> input
parameter.

=back

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
