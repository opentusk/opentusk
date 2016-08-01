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
use TUSK::Competency::Checklist::Completion;
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
	  SELECT a.competency_checklist_id, c1.title, required, c2.title, self_assessed, partner_assessed, faculty_assessed, h2.sort_order, h.depth, h.sort_order
	  FROM tusk.competency_checklist a
	  INNER JOIN tusk.competency as c1 on (a.competency_id = c1.competency_id)
	  INNER JOIN tusk.competency_hierarchy as h on (h.child_competency_id = a.competency_id)
	  INNER JOIN tusk.competency as c2 on (parent_competency_id = c2.competency_id)
	  INNER JOIN tusk.competency_hierarchy as h2 on (h2.child_competency_id = c2.competency_id)						     
	  WHERE competency_checklist_group_id = $self->{checklist_group_id}
          ORDER BY h2.sort_order, h.depth, h.sort_order								     
    ));

    my $data = {};
    my @cat_order;
    my $last_cat_sort_order = -1;

    while (my ($checklist_id, $competency_title, $req, $cat_title, $self_assessed, $partner_assessed, $faculty_assessed, $cat_sort_order, $comp_depth, $comp_sort_order) = $sth->fetchrow_array()) {
	push @{$data->{$cat_title}}, {
	    checklist_id => $checklist_id, 
	    competency_title => $competency_title, 
	    required => $req, 
	    self => $self_assessed, 
	    partner => $partner_assessed, 
	    faculty => $faculty_assessed,
	    total => $self_assessed + $partner_assessed + $faculty_assessed,
	};
	if ($cat_sort_order > $last_cat_sort_order) {
	    push @cat_order, $cat_title;
	    $last_cat_sort_order = $cat_sort_order;
	}
    }

    $sth->finish();
    return $data, @cat_order;
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

    my $entries = TUSK::Competency::Checklist::Entry->lookup("(request_date is not NULL OR notify_date is not NULL) AND complete_date is NULL", ['request_date'], ['competency_checklist_entry_id'], undef, [
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
    return $ctx->hexdigest();
}

sub validateUrlToken {
    my ($self, $checklist_group_id, $assignment_id, $url_token) = @_;
    return ($self->getToken($checklist_group_id, $assignment_id) eq $url_token);
}

=item
    Update assesor request data as current time in the Entry object
=cut
sub setAssessorRequest {
    my ($self, $assignment_id, $checklist_id, $user_id, $entry, $comments) = @_;
    my $now = HSDB4::DateTime->new()->out_mysql_timestamp();

    if ($entry->getPrimaryKeyID()) {
        $entry->setCompetencyChecklistAssignmentID($assignment_id) unless ($entry->getCompetencyChecklistAssignmentID() == $assignment_id);
        $entry->setNotifyDate(undef) if ($entry->getNotifyDate());
    } else {
        $entry->setFieldValues({
            competency_checklist_assignment_id => $assignment_id,
            competency_checklist_id => $checklist_id,
        });
    }

    $entry->setRequestDate($now);
    $entry->setStudentComment($comments);
    $entry->save({user => $user_id});
}

=item
    Return User object with assignment and entry objects for a given assignment_id and type of assessor
=cut
sub getAssessor {
    my ($self, $args) = @_;

    ## caller must provide either the assignment_id OR both assessor/student ids
    my $assignment_cond;
    if (defined $args->{assignment_id}) {
        $assignment_cond = "competency_checklist_assignment.competency_checklist_assignment_id = $args->{assignment_id}";
    } elsif (defined $args->{assessor_id} && defined $args->{student_id}) {
        $assignment_cond = "student_id = '$args->{student_id}' AND assessor_id = '$args->{assessor_id}' AND time_period_id = $args->{time_period_id}";
    } else {
        die "Please provide either competency_checklist_assignment_id OR assessor_id/student_id\n";
    }
    my $user = TUSK::Core::HSDB4Tables::User->new();

    return $user->lookupReturnOne(undef, undef, undef, undef, [
        TUSK::Core::JoinObject->new('TUSK::Competency::Checklist::Assignment', { 
            joinkey => 'assessor_id', 
            origkey => 'user_id',
            jointype => 'inner',  
            joincond => "$assignment_cond AND competency_checklist_group_id = $self->{checklist_group_id}",
        }),
    	TUSK::Core::JoinObject->new('TUSK::Enum::Data', { 
            joinkey => 'enum_data_id', 
            origkey => 'competency_checklist_assignment.assessor_type_enum_id', 
            jointype => 'inner', 
            joincond => "namespace = 'competency_checklist_assignment.assessor_type' AND short_name = '$args->{assessor_type}'"
        }),
   ]);
}


sub getFacultyAssessors {
    my ($self, $student_id, $checklist_id, $time_period_id, $entry_id) = @_;

    return TUSK::Core::HSDB4Tables::User->lookup(undef, ['lastname', 'firstname'], undef, undef, [
        TUSK::Core::JoinObject->new('TUSK::Competency::Checklist::Assignment', { 
            joinkey => 'assessor_id', 
            origkey => 'user_id',
            jointype => 'inner',  
            joincond => "student_id = '$student_id' AND time_period_id = $time_period_id and competency_checklist_group_id = $self->{checklist_group_id}",
        }),
    	TUSK::Core::JoinObject->new('TUSK::Enum::Data', { 
            joinkey => 'enum_data_id', 
            origkey => 'competency_checklist_assignment.assessor_type_enum_id', 
            jointype => 'inner', 
            joincond => "namespace = 'competency_checklist_assignment.assessor_type' AND short_name = 'faculty'"
        }),
     	TUSK::Core::JoinObject->new('TUSK::Competency::Checklist::Entry', { 
            joinkey => 'competency_checklist_assignment_id', 
            origkey => 'competency_checklist_assignment.competency_checklist_assignment_id', 
            joincond => "competency_checklist_id = $checklist_id" . ((defined $entry_id) ? " AND competency_checklist_entry_id = $entry_id" : ''),
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

sub getChecklistWithParentChildren {
    my ($self, $checklist_id) = @_;

    my ($checklist, $parent, $children);

    if ($checklist_id) {
	$checklist = TUSK::Competency::Checklist::Checklist->lookupKey($checklist_id, [
	       TUSK::Core::JoinObject->new('TUSK::Competency::Checklist::Group', { joinkey => 'competency_checklist_group_id', jointype => 'inner' }),
	       TUSK::Core::JoinObject->new('TUSK::Competency::Competency', {joinkey => 'competency_id', jointype => 'inner' }),
        ]);

	$parent = TUSK::Competency::Competency->lookupReturnOne('', undef, undef, undef, [
		TUSK::Core::JoinObject->new('TUSK::Competency::Hierarchy', { joinkey => 'parent_competency_id', origkey => 'competency_id', jointype => 'inner', joincond => "child_competency_id = " .  $checklist->getCompetencyID()  }) ]);
			
	$children = TUSK::Competency::Competency->lookup('', undef, undef, undef, [
		TUSK::Core::JoinObject->new('TUSK::Competency::Hierarchy', { joinkey => 'child_competency_id', origkey => 'competency_id', jointype => 'inner', joincond => "parent_competency_id = " . $checklist->getCompetencyID() }) ]);
    }

    return (
	    $checklist || TUSK::Competency::Checklist::Checklist->new(), 
	    $parent || TUSK::Competency::Competency->new(), 
	    $children || [],
    );
}

sub getPendingFaculty {
    my $self = @_;

    #my $sth = qq(SELECT count(*) FROM competency_checklist_entry WHERE competency_checklist_assignment_id = $assignment_id AND complete_date IS NULL AND (request_date IS NOT NULL OR notify_date IS NOT NULL));


    
}

sub getSummaryReport {
    my ($self, $time_period_id, $course) = @_;

    my $checklist = TUSK::Competency::Checklist::Checklist->new();
	
    my $sth = $checklist->databaseSelect(qq(
SELECT competency_checklist_id, self_assessed + partner_assessed + faculty_assessed as total, required
FROM tusk.competency_checklist
WHERE competency_checklist_group_id = $self->{checklist_group_id}
    ));

    my $checklists = {};
    my $total_checklists = 0;
    my $total_required_checklists = 0;
    while (my ($checklist_id, $total, $required) = $sth->fetchrow_array()) {
	$checklists->{$checklist_id} = {
	    total => $total,
	    required => $required,
	};
	$total_checklists++;
	$total_required_checklists++ if ($required);
    }
    $sth->finish();

    $total_checklists = scalar keys %$checklists;
    my $school_db = $course->school_db();
    $sth = $checklist->databaseSelect(qq(
SELECT concat(lastname, ', ', firstname) as name, uid, competency_checklist_id, count(distinct competency_checklist_entry_id)
FROM $school_db.link_course_student as l
INNER JOIN tusk.competency_checklist_assignment as a on (l.child_user_id = student_id AND a.time_period_id = l.time_period_id and competency_checklist_group_id = $self->{checklist_group_id})
INNER JOIN tusk.competency_checklist_entry as e on (a.competency_checklist_assignment_id = e.competency_checklist_assignment_id AND complete_date is NOT NULL)
INNER JOIN hsdb4.user as u on (l.child_user_id = u.user_id)
WHERE l.time_period_id = $time_period_id
GROUP BY child_user_id, competency_checklist_id
ORDER BY name
					    ));

    my %data = ();
    while (my ($student_name, $student_id, $checklist_id, $cnt) = $sth->fetchrow_array()) {
	$data{$student_id}{name} = $student_name;
	if ($cnt == $checklists->{$checklist_id}{total}) {
	    $data{$student_id}{total_completed}++;
	    if ($checklists->{$checklist_id}{required}) {
		$data{$student_id}{total_required_completed}++;
	    }
	}
    }

    $sth = $checklist->databaseSelect(qq(
SELECT concat(lastname, ', ', firstname) as name, uid, d.short_name AS pending_type, count(distinct competency_checklist_entry_id)
FROM $school_db.link_course_student as l
INNER JOIN tusk.competency_checklist_assignment as a on (l.child_user_id = student_id AND a.time_period_id = l.time_period_id and competency_checklist_group_id = $self->{checklist_group_id})
INNER JOIN tusk.competency_checklist_entry as e on (a.competency_checklist_assignment_id = e.competency_checklist_assignment_id)
INNER JOIN hsdb4.user as u on (l.child_user_id = u.user_id)
INNER JOIN tusk.enum_data AS d ON (a.assessor_type_enum_id = d.enum_data_id)
WHERE l.time_period_id = $time_period_id
AND e.complete_date IS NULL 
AND (d.short_name = 'faculty' OR d.short_name = 'partner')
GROUP BY child_user_id
ORDER BY name
					    ));

    while (my ($current_student_name, $current_student_id, $pending_type, $cnt_pending) = $sth->fetchrow_array()) {
	if ($pending_type eq 'faculty') {
	    $data{$current_student_id}{faculty_pending} = $cnt_pending;
	} else {
	    $data{$current_student_id}{partner_pending} = $cnt_pending;
	}
    }

    return (\%data, $total_checklists, $total_required_checklists);
}


sub saveCompletions {
    my ($self, $args, $id_prefix, $entry_id, $assessor_id) = @_;

    my %completions = map { $_->getCompetencyID() => $_ } @{TUSK::Competency::Checklist::Completion->lookup("competency_checklist_entry_id = $entry_id")};
    foreach my $key (keys %$args) {
	if ($key =~ m/$id_prefix/) {
	    my (undef, $competency_id) = split(/__/, $key);
	    if (exists $completions{$competency_id}) {
		$completions{$competency_id}->setCompleted($args->{$key});
		$completions{$competency_id}->save({user => $assessor_id});
	    } else {
		my $completion = TUSK::Competency::Checklist::Completion->new();
		$completion->setFieldValues({
		    competency_checklist_entry_id 	=> $entry_id,
		    competency_id	                => $competency_id,
		    completed                           => $args->{$key},
		});
		$completion->save({user => $assessor_id});
	    }
	}
    }
}

1;
