# Copyright 2012 Tufts University 

# Licensed under the Educational Community License, Version 1.0 (the "License"); 
# you may not use this file except in compliance with the License. 
# You may obtain a copy of the License at 

# http://www.opensource.org/licenses/ecl1.php 

# Unless required by applicable law or agreed to in writing, software 
# distributed under the License is distributed on an "AS IS" BASIS, 
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
# See the License for the specific language governing permissions and 
# limitations under the License.


package TUSK::Application::Competency::Checklist;

use strict;

use TUSK::Competency::Competency;
use TUSK::Competency::Hierarchy;
use TUSK::Competency::Checklist::Group;
use TUSK::Competency::Checklist::Entry;
use TUSK::Competency::Checklist::Checklist;
use TUSK::Core::HSDB4Tables::User;
use TUSK::Enum::Data;
use Digest::MD5;
use TUSK::Constants;
use HSDB4::DateTime;
use Carp qw(croak);

sub new {
    my ($class, $args) = @_;

    my $checklist_group = TUSK::Competency::Checklist::Group->lookupKey($args->{checklist_group_id});
    croak "Invalid checklist_group_id: $args->{checklist_group_id}\n" unless defined $checklist_group;

    my $self = { 
	checklist_group_id  => $args->{checklist_group_id},
    };

    bless($self, $class);
    return $self;
}

sub getChecklistGroup {
    my $self = shift;
    return $self->getChecklistGroup();
}

=item
    Return competency object for the checklist
=cut
sub getCompetencyChecklist {
    my ($self, $checklist_id) = @_;
    return TUSK::Competency::Competency->lookupReturnOne(undef, undef, undef, undef, [
		TUSK::Core::JoinObject->new("TUSK::Competency::Checklist::Checklist", { 
		    joinkey => 'competency_id', 
		    jointype => 'inner', 
		    joincond => "competency_checklist_id = $checklist_id AND competency_checklist_group_id = $self->{checklist_group_id}"
		    }) 
	   ]);
}

=item
    Return a tree of competencies in the checklist group as an array ref. Cmpetency Title is a key
=cut
sub getSkillsModulesWithCategories {
    my $self = shift;

    my $sth = TUSK::Competency::Competency->new()->databaseSelect(qq(
	  SELECT a.competency_checklist_id, c1.description, required, c2.description, self_assessed, partner_assessed, faculty_assessed
	  FROM tusk.competency_checklist a
	  INNER JOIN tusk.competency as c1 on (a.competency_id = c1.competency_id)
	  INNER JOIN tusk.competency_hierarchy as h on (child_competency_id = a.competency_id)
	  INNER JOIN tusk.competency as c2 on (parent_competency_id = c2.competency_id)
	  WHERE competency_checklist_group_id = $self->{checklist_group_id}
    ));

    my $data = {};
    while (my ($checklist_id, $competency_title, $req, $cat_title, $self_assessed, $partner_assessed, $faculty_assessed) = $sth->fetchrow_array()) {
	push @{$data->{$cat_title}}, {
	    checklist_id => $checklist_id, 
	    competency_title => $competency_title, 
	    required => $req, 
	    self => $self_assessed, 
	    partner => $partner_assessed, 
	    faculty => $faculty_assessed,
	    total => $self_assessed + $partner_assessed + $faculty_assessed,
	};
    }
    $sth->finish();
    return $data;
}

=item
    Return a list of (self/partner/faculty) entries with completions for a given student enrolled in a time period
=cut
sub getStudentEntries {
    my ($self, $student_id, $tp_id) = @_;
    croak "missing parameters: student id and time period id" unless ($student_id && $tp_id);

    my $entries = TUSK::Competency::Checklist::Entry->lookup('', undef, undef, undef, [ 
	TUSK::Core::JoinObject->new("TUSK::Competency::Checklist::Assignment", { 
	    jointype => 'inner',
	    joinkey => 'competency_checklist_assignment_id', 
	    joincond => "competency_checklist_group_id = $self->{checklist_group_id} AND time_period_id = $tp_id AND student_id = '$student_id'",
	}), 
	TUSK::Core::JoinObject->new("TUSK::Enum::Data", { 
	    jointype => 'inner', 
	    joinkey => 'enum_data_id', 
	    origkey => 'competency_checklist_assignment.assessor_type_enum_id',
	}), 
	TUSK::Core::JoinObject->new("TUSK::Competency::Checklist::Completion", { 
	    joinkey => 'competency_checklist_entry_id', 
	}), 
	TUSK::Core::JoinObject->new("TUSK::Competency::Checklist::Checklist", { 
	    joinkey => 'competency_checklist_id', 
	    jointype => 'inner', 
	    joincond => "competency_checklist.competency_checklist_group_id = $self->{checklist_group_id}"
	}) 
    ]);

    my %checklist_entries = ();
    my %checklist_completions = ();

    foreach my $entry (@$entries) {
	my $enum = $entry->getJoinObject('TUSK::Enum::Data');
	$checklist_entries{$entry->getCompetencyChecklistID()}{$enum->getShortName()} = $entry;

	if ($entry->getCompleteDate()) {
	    $checklist_completions{$entry->getCompetencyChecklistID()}++;
	}
    }
    return (\%checklist_entries, \%checklist_completions);
}

=item
    Return a list of pending, current entries for a given assignment id
=cut
sub getPendingEntries {
    my ($self, $checklist_assignment_id, $school) = @_;
    croak "missing parameters: checklist assignment id" unless ($checklist_assignment_id);

    my $entries = TUSK::Competency::Checklist::Entry->lookup("request_date is not NULL and complete_date is NULL", ['request_date'], ['competency_checklist_entry_id'], undef, [
	TUSK::Core::JoinObject->new("TUSK::Competency::Checklist::Assignment", { 
		joinkey => 'competency_checklist_assignment_id', 
		jointype => 'inner', 
		joincond => "competency_checklist_assignment.competency_checklist_assignment_id = $checklist_assignment_id" 
	}),	
	TUSK::Core::JoinObject->new("TUSK::Core::HSDB45Tables::TimePeriod", { 
		database => $school->getSchoolDb(), 
		joinkey => 'time_period_id', 
		origkey => 'competency_checklist_assignment.time_period_id', 
		jointype => 'inner', 
		joincond => 'start_date < now() AND end_date > (curdate() + interval 1 day)'
	}), 
	TUSK::Core::JoinObject->new("TUSK::Competency::Checklist::Checklist", { 
		joinkey => 'competency_checklist_id', 
		jointype => 'inner', 
	}),	
	TUSK::Core::JoinObject->new("TUSK::Competency::Competency", { 
		joinkey => 'competency_id', 
		origkey => 'competency_checklist.competency_id',
		jointype => 'inner', 
	}),	
    ]);
    return $entries;
}													    

sub getAssignments {
    my ($self, $student_id, $tp_id) = @_;
    croak "missing parameters: student id and time period id" unless ($student_id && $tp_id);

    my $assignments = TUSK::Competency::Checklist::Assignment->lookup("competency_checklist_group_id = $self->{checklist_group_id} AND time_period_id = $tp_id AND student_id = '$student_id'", undef, undef, undef, [ 
	TUSK::Core::JoinObject->new("TUSK::Enum::Data", { joinkey => 'enum_data_id', origkey => 'competency_checklist_assignment.assessor_type_enum_id', jointype => 'inner', }), 
    ]);

    return { map { $_->getJoinObject('TUSK::Enum::Data')->getShortName() => $_ } @$assignments };
}


sub assignSelf {
    my ($self, $student_id, $time_period_id) = @_;

    my $enum = TUSK::Enum::Data->lookupReturnOne("namespace = 'competency_checklist_assignment.assessor_type' and short_name = 'self'");
    croak "Failed to get enum_data object for self assignment" unless $enum;
    my $assignment = TUSK::Competency::Checklist::Assignment->new();
    $assignment->setFieldValues({
	competency_checklist_group_id => $self->{checklist_group_id},
	time_period_id 		=> $time_period_id,
	student_id 		=> $student_id,
	assessor_id 		=> $student_id,
	assessor_type_enum_id 	=> $enum->getPrimaryKeyID(),
    });
    $assignment->save({user => $student_id});
}

sub getUrlToken {
    my ($self, $assignment) = @_;
    return $self->getToken($assignment->getCompetencyChecklistGroupID(), $assignment->getPrimaryKeyID());
}

sub getToken {
    my ($self, $checklist_group_id, $assignment_id) = @_;
    my $ctx = Digest::MD5->new();
    $ctx->add($checklist_group_id, $assignment_id, $TUSK::Constants::ChecklistSecret);
    my $token = $ctx->add($ctx->b64digest())->b64digest();
    $token =~ s/\///;
    return $token;
}

sub validateUrlToken {
    my ($self, $checklist_group_id, $assignment_id, $url_token) = @_;
    return ($self->getToken($checklist_group_id, $assignment_id) eq $url_token) ? 1 : 0;
}

=item
    Update assesor request data as current time in the Entry object
=cut
sub setAssessorRequest {
    my ($self, $assignment_id, $checklist_id, $user_id, $entry) = @_;
    my $now = HSDB4::DateTime->new()->out_mysql_timestamp();

    if ($entry->getPrimaryKeyID()) {
	$entry->setRequestDate($now);
	$entry->setNotifyDate(undef) if ($entry->getNotifyDate());
    } else {
	$entry->setFieldValues({
	    competency_checklist_assignment_id => $assignment_id,
	    competency_checklist_id => $checklist_id,
	    request_date => $now,
	});
    }
    $entry->save({user => $user_id});
    return $entry;
}

=item
    Return User object with assignment and entry objects for a given assignment_id and type of assessor
=cut
sub getAssessor {
    my ($self, $assignment_id, $checklist_id, $assessor_type) = @_;

    return TUSK::Core::HSDB4Tables::User->lookupReturnOne(undef, undef, undef, undef, [
	TUSK::Core::JoinObject->new('TUSK::Competency::Checklist::Assignment', { 
	    joinkey => 'assessor_id', 
	    origkey => 'user_id', 
	    jointype => 'inner',
	    joincond => "competency_checklist_assignment_id = $assignment_id AND competency_checklist_group_id = $self->{checklist_group_id}",
	}),
	TUSK::Core::JoinObject->new('TUSK::Enum::Data', { 
	    joinkey => 'enum_data_id', 
	    origkey => 'competency_checklist_assignment.assessor_type_enum_id', 
	    jointype => 'inner', 
	    joincond => "namespace = 'competency_checklist_assignment.assessor_type' AND short_name = '$assessor_type'"
	}),
	TUSK::Core::JoinObject->new('TUSK::Competency::Checklist::Entry', { 
	    joinkey => 'competency_checklist_assignment_id', 
	    origkey => 'competency_checklist_assignment.competency_checklist_assignment_id', 
	    joincond => "competency_checklist_id = $checklist_id",
	}),
   ]);
}

=item
    Return a student user object for the checklist assignment
=cut
sub getStudent {
    my ($self, $checklist_assignment_id) = @_;
    return TUSK::Core::HSDB4Tables::User->lookupReturnOne(undef, undef, undef, undef, [
		TUSK::Core::JoinObject->new("TUSK::Competency::Checklist::Assignment", { joinkey => 'student_id', origkey => 'user_id', jointype => 'inner', joincond => "competency_checklist_assignment_id = $checklist_assignment_id and competency_checklist_group_id = $self->{checklist_group_id}" })
	]);
}


sub getPendingPartnerChecklists {
    my ($self, $school, $assessor_id) = @_;
    return TUSK::Competency::Checklist::Checklist->lookup("competency_checklist.competency_checklist_group_id = $self->{checklist_group_id}" , undef, undef, undef, [
        TUSK::Core::JoinObject->new("TUSK::Competency::Checklist::Assignment", { 
	    jointype => 'inner', 
	    joinkey => 'competency_checklist_group_id', 
	    joincond => "assessor_id = '$assessor_id'"}),
	TUSK::Core::JoinObject->new("TUSK::Enum::Data", { 
	    jointype => 'inner', 
	    joinkey => 'enum_data_id', 
	    origkey => 'competency_checklist_assignment.assessor_type_enum_id',
	    joincond => "short_name = 'partner'",
	}), 
        TUSK::Core::JoinObject->new("TUSK::Core::HSDB45Tables::TimePeriod", { 
	    database => $school->getSchoolDb(), 
	    jointype => 'inner', 
	    joinkey => 'time_period_id', 
	    origkey=> "competency_checklist_assignment.time_period_id",  
	    cond => "start_date < now()  AND end_date > now()", jointype => 'inner' }),
	TUSK::Core::JoinObject->new('TUSK::Competency::Checklist::Entry', { 
	    jointype => 'inner', 
	    joinkey => 'competency_checklist_id', 
	    joincond => 'competency_checklist_entry.competency_checklist_assignment_id = competency_checklist_assignment.competency_checklist_assignment_id AND request_date is not NULL AND complete_date is NULL', 
	}),
    ]);
}

1;
