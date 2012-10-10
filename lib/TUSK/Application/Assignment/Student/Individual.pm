package TUSK::Application::Assignment::Student::Individual;

use strict;
use base 'TUSK::Application::Assignment::Student';
use TUSK::Assignment::LinkAssignmentStudent;
use TUSK::Core::School;
use HSDB45::Course;

sub new {
    my ($class, $args) = @_;

    my $self = { user_id => $args->{user_id},
		 assignment => $args->{assignment},
		 course => $args->{course},
		 school => $args->{school},
		 faculty_view => $args->{faculty_view},  
		 link_assignment => $args->{link_assignment_student},
	       };
    bless($self,$class);

    $self->init();

    if (defined $self->{link_assignment}) {
	$self->SUPER::setAssignmentLinks($self->{link_assignment});
    } else {
	$self->setAssignmentLinks();
    }

    return $self;
}

sub setAssignment {
    my ($self, $assignment) = @_;
    $self->SUPER::setAssignment($assignment);
    $self->setAssignmentLinks() unless defined $self->{link_assignment};
}


sub setAssignmentLinks {
    my $self = shift;

    if (defined $self->{assignment}) {
	my $link = TUSK::Assignment::LinkAssignmentStudent->new()->lookupReturnOne("child_user_id = '$self->{user_id}' AND parent_assignment_id = $self->{assignment_id}");
	unless (defined $link) {
	    $link = TUSK::Assignment::LinkAssignmentStudent->new();
	    $link->setFieldValues({ 
		child_user_id        => $self->{user_id},
		parent_assignment_id => $self->{assignment_id},
	    });
	    $link->save({user => $self->{user_id}});
	}

	$self->SUPER::setAssignmentLinks($link);
    } 
}


sub getContent {
    my ($self, $sequence) = @_;

    $sequence = $self->{current_submission} unless (defined $sequence);

    my $condition = "parent_assignment_id = $self->{assignment_id} AND child_content_id in (SELECT parent_content_id FROM hsdb4.link_content_user WHERE child_user_id = '$self->{user_id}' AND roles rlike 'Student-') AND submit_sequence = $sequence";

    my $contentlinks = TUSK::Assignment::LinkAssignmentContent->new()->lookup("$condition order by modified_on");

    return $contentlinks;
}


sub getFacultyContent {
    my $self = shift;
    my $sequence = shift || 0;

    ### if sequence is 0, student is getting faculty's original content
    ### Otherwise, individual student gets faculty content based on sequence 
    ### and his/her userid

    my $condition = '';
    $condition = "AND user_id = '$self->{user_id}'" if $sequence > 0;

    my $contentlinks = TUSK::Assignment::LinkAssignmentContent->lookup("parent_assignment_id = " . $self->{assignment_id} . " AND child_content_id in (select parent_content_id from hsdb4.link_content_user a, tusk.link_assignment_user b where a.child_user_id = b.child_user_id and b.parent_assignment_id = " . $self->{assignment_id} . " and roles = 'Author') and submit_sequence = $sequence $condition");

    return $contentlinks;
}


sub getNotes {
    my ($self, $sort_order) = @_;
    return $self->SUPER::getNotes('self-note',$sort_order);
}


sub setNotes {
    my ($self, $notes) = @_;
    my $type = 'self-note';

    if ($self->{link_assignment}) {
	my $note = TUSK::Assignment::Note->lookupReturnOne("link_id = $self->{link_id} AND link_type = '$self->{link_type}' AND type = '$type' AND created_by = '$self->{user_id}'");

	unless (defined $note) { 
	    $note = $self->createNoteObject({type => $type, body => $notes});
	} else {
	    $note->setBody($notes);
	}
	$note->save({user => $self->{user_id}});
    }
}


sub getCurrentAssignments {
    my ($self) = @_;
    my @assignment_links = ();
    my $tp = $self->{course}->get_users_current_timeperiod($self->{user_id});

    if (ref $tp eq 'HSDB45::TimePeriod' && $self->{course}->is_user_registered($self->{user_id}, $tp->primary_key)) {
	my $assignments = TUSK::Assignment::Assignment->new()->lookup(
	      "course_id = " . $self->{course}->primary_key 
	      . " AND time_period_id = " . $tp->primary_key() 
	      . " AND school_id = " . TUSK::Core::School->new()->getSchoolID($self->{school}) 
	      . " AND available_date != '0000-00-00 00:00:00' AND available_date <= now()");

	my $sth;
	foreach my $assignment (@{$assignments}) {
	    if ($assignment->getGroupFlag()) {
		my $db = $self->{course}->get_school()->getSchoolDb();
		$sth = $assignment->databaseSelect("select max(submit_date) from tusk.assignment_submission where link_id in (select link_assignment_user_group_id from tusk.link_assignment_user_group where parent_assignment_id = " . $assignment->getPrimaryKeyID() . " and child_user_group_id in (select parent_user_group_id from $db\.link_user_group_user where child_user_id = '$self->{user_id}')) and link_type = 'link_assignment_user_group'");
	    } else { 
		$sth = $assignment->databaseSelect("select max(submit_date) from tusk.assignment_submission where link_id = (select link_assignment_student_id from tusk.link_assignment_student where parent_assignment_id = " . $assignment->getPrimaryKeyID() . " and child_user_id = '$self->{user_id}') and link_type = 'link_assignment_student'");
	    }

	    my ($submit_date) = $sth->fetchrow_array();
	    $sth->finish();
	    push @assignment_links, { assignment => $assignment, submit_date => $submit_date};

	}
    }

    return \@assignment_links;
}


sub setFacultyComments {
    my ($self, $bywhom, $comments) = @_;
    unless (defined $self->{grade_event_link}) {
	$self->setGradeEventLink();
    }

    if (defined $self->{grade_event_link}) {
	$self->{grade_event_link}->setComments($comments);
	$self->{grade_event_link}->save({user => $bywhom->getUserID()});
    } else {
	my $link = TUSK::GradeBook::LinkUserGradeEvent->new();
	$link->setFieldValues({
	      parent_user_id => $self->getUserID(),
	      child_grade_event_id => $self->{assogmemt}->getGradeEventID(),
	      comments => $comments });
	if ($link->save({user => $bywhom->getUserID()})) {
	    $self->{grade_event_link} = $link;
	} else {
	    die "Missing grade_event_id to update faculty comments.";
	}
    }

    $self->setComments('faculty-comment',$comments);
}


### update grade in both link_grade_event_user and assignment_submission tables
sub setGrade {
    my ($self, $bywhom, $grade) = @_;

    unless (defined $self->{grade_event_link}) {
	$self->setGradeEventLink();
    }

    if (defined $self->{grade_event_link}) {
	$self->{grade_event_link}->setGrade($grade);
	$self->{grade_event_link}->save({user => $bywhom->getUserID()});
    } else {
	my $link = TUSK::GradeBook::LinkUserGradeEvent->new();
	$link->setFieldValues({
	      parent_user_id => $self->getUserID(),
	      child_grade_event_id => $self->{assignment}->getGradeEventID(),
	      grade => $grade });

	if ($link->save({user => $bywhom->getUserID()})) {
	    $self->{grade_event_link} = $link;
	} else {
	    die "Missing grade_event_id to update grade.";
	}
    }

    $self->SUPER::setGrade($bywhom, $grade);
}


sub setGradeEventLink {
    my ($self) = @_;
    $self->{grade_event_link} = TUSK::GradeBook::LinkUserGradeEvent->new()->lookupReturnOne("parent_user_id = '" . $self->getUserID() . "' AND child_grade_event_id = " . $self->{assignment}->getGradeEventID());
}


sub resetSubmitDate {
    my ($self, $bywhom) = @_;
    my $link = $self->{link_assignment};
    if (defined $link) {
	$link->setSubmitDate(undef);
	$link->save({user => $bywhom->getUserID()});
    }
}


sub isResubmissionAllowed {
    my $self = shift;
    return 1 if ($self->{assignment}->getResubmitFlag());
}


1;
