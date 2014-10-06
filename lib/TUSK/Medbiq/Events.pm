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

use TUSK::Medbiq::Types;
use TUSK::Types qw(School TUSK_XSD_Date Competency Umls_Keyword);
use Types::Standard qw(ArrayRef HashRef Str);
use TUSK::Namespaces ':all';
use HSDB4::Constants;
use HSDB45::ClassMeeting;
use TUSK::Medbiq::Event;
use TUSK::Medbiq::Method::Instructional;
use TUSK::Medbiq::Method::Assessment;
use TUSK::Core::LinkContentKeyword;
use TUSK::Core::HSDB45Tables::ClassMeeting;
use namespace::clean;


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

has school_db => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    default => sub {
	my $self = shift;
	return $self->school()->getSchoolDb();
    },
);

has start_date => (
    is => 'ro',
    isa => TUSK_XSD_Date,
    required => 1,
);

has end_date => (
    is => 'ro',
    isa => TUSK_XSD_Date,
    required => 1,
);

has Event => (
    is => 'ro',
    isa => ArrayRef[TUSK::Medbiq::Types::Event],
    lazy => 1,
    builder => '_build_Events',
);

has competencies => (
    is => 'ro',
    isa => ArrayRef[Competency],		     
    required => 1,		     
);

has competencies_by_class_meeting => (
    is => 'ro',
    isa => HashRef[HashRef[Competency]],
    lazy => 1,
    builder => '_build_competencies_by_class_meeting',				      
);
    				      
has keywords => (
    is => 'ro',
    isa => HashRef[HashRef[Umls_Keyword]],
    lazy => 1,
    builder => '_build_keywords',		 
);		 


############
# * Builders
############

sub _build_namespace { curriculum_inventory_ns }
sub _build_xml_content { [ qw( Event ) ] }

sub _build_competencies_by_class_meeting {
    my $self = shift;

    ## double check if same competencies are in both classmeeting and content
    my %competencies = (); 
    foreach my $comp (@{$self->competencies()}) {
	next unless ref $comp eq 'TUSK::Competency::Competency';
	if (my $cm = $comp->getJoinObject('TUSK::Core::HSDB45Tables::ClassMeeting')) {
	    $competencies{$cm->getPrimaryKeyID()}{$comp->getPrimaryKeyID()} = $comp;
	}
    }

    return \%competencies;
}

sub _build_Events {
    my $self = shift;

    my $competencies = $self->competencies_by_class_meeting();
    my $kwords = $self->keywords();
    my $school = $self->school();

    my $cm = TUSK::Core::HSDB45Tables::ClassMeeting->new();
    $cm->setDatabase($self->school()->getSchoolDb());
    my $class_meetings = $cm->lookup($self->_meeting_dates_condition(), undef, undef, undef, [
       	  TUSK::Core::JoinObject->new('TUSK::ClassMeeting::Type', {
	      jointype => 'inner',
	      origkey => 'type_id',
	      joinkey => 'class_meeting_type_id',
	  }),
	  TUSK::Core::JoinObject->new('TUSK::Enum::Data', {
	      jointype => 'inner',
	      origkey => 'class_meeting_type.curriculum_method_enum_id',
	      joinkey => 'enum_data_id',
	      joincond => "namespace = 'class_meeting_type.curriculum_method_id' and short_name in ('assessment', 'instruction')"
	  }),
    ]);

    my @events = ();
    foreach my $event (@$class_meetings) {
	push @events, TUSK::Medbiq::Event->new(dao => $event, 
					       competencies => $competencies->{$event->getPrimaryKeyID()},
					       keywords => $kwords->{$event->getPrimaryKeyID()},
        );
    }

    return \@events;
}

sub _build_keywords {
    my $self = shift;

    my $links = TUSK::Core::LinkContentKeyword->lookup(undef, undef, undef, undef, [
	  TUSK::Core::JoinObject->new('TUSK::Core::HSDB45Tables::LinkClassMeetingContent', {
	      database => $self->school_db(),
	      jointype => 'inner',
	      origkey => 'parent_content_id',
	      joinkey => 'child_content_id',
	 }),
	  TUSK::Core::JoinObject->new('TUSK::Core::HSDB45Tables::ClassMeeting', {
	      database => $self->school_db(),
	      jointype => 'inner',
	      origkey => 'link_class_meeting_content.parent_class_meeting_id',
	      joinkey => 'class_meeting_id',
	      joincond => $self->_meeting_dates_condition(),
	 }),
    ]);

    my $event_keywords = {};
    foreach (@$links) {
	if (my $cm = $_->getJoinObject('TUSK::Core::HSDB45Tables::ClassMeeting')) {
	    my $kword = $_->getJoinObject('TUSK::Core::Keyword');
	    $event_keywords->{$cm->getPrimaryKeyID()}{$kword->getPrimaryKeyID()} = $kword;
	}
    }

    return $event_keywords;
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
    return ( TUSK::Medbiq::Method::Instructional->has_medbiq_translation($type)
          || TUSK::Medbiq::Method::Assessment->has_medbiq_translation($type) );
}

sub _meeting_dates_condition {
    my $self = shift;
    return "meeting_date between '" . $self->start_date . "' and '" . $self->end_date . " 23:59:59'";
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
