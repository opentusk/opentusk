package TUSK::Application::Assignment::Student;

use strict;
use base 'TUSK::Application::Assignment::User';
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
    $self->setAssignmentLinks() unless (defined $self->{link_assignment}) ;
    return $self;
}

sub setAssignment {
    my ($self, $assignment) = @_;
    $self->SUPER::setAssignment($assignment);
    $self->setAssignmentLinks() unless defined $self->{link_assignment};
}


sub setAssignmentLinks {
    my ($self, $link) = @_;

    die "missing link in TUSK::Application::Assignment::Student\n" unless defined $link;

    $self->{link_assignment} = $link;
    $self->{link_type} = $self->{link_assignment}->getTablename();
    $self->{link_id} = $self->{link_assignment}->getPrimaryKeyID();
    $self->{assignment_submissions} = $self->getAssignmentSubmission();
    $self->{current_submission} = $self->getCurrentSubmission();

}

sub getAssignmentLink {
    my $self = shift;
    return $self->{link_assignment};
}


sub getStudentComments {
    my ($self, $sequence, $sort_order) = @_;
    return $self->getComments('student-comment',$sequence,$sort_order);

}

sub setStudentComments {
    my ($self, $comments) = @_;
    $self->setComments('student-comment',$comments);
}


sub getFacultyComments {
    my ($self,$sequence, $sort_order) = @_;
    return $self->getComments('faculty-comment',$sequence,$sort_order );
}


sub getCurrentSubmission {
    my $self = shift;
    if ($self->{current_submission}) {
	return $self->{current_submission};
    }
    my $submissions = $self->getSubmissions();

    return ($self->{assignment}->getResubmitFlag() || $self->{link_assignment}->getResubmitFlag()) ? (($self->{faculty_view}) ? $submissions : $submissions + 1) : ($submissions ? $submissions : $submissions+1);
}

sub getSubmissions {
    my $self = shift;
    if ($self->{assignment_submissions}) {
	return scalar @{$self->{assignment_submissions}};
    }
    return 0;
}


sub shouldFeedbackBePosted {
    my ($self, $sequence) = @_;
    my $post_it = 0;

    $sequence = $self->{current_submission} unless defined $sequence;
    if (my $submit = $self->{assignment_submissions}->[$sequence-1]) {
	my $feedback_posted = $submit->getFeedbackPostFlag();

	if ($self->{assignment}->getResubmitFlag()) {
	    if (defined $feedback_posted) {
		$post_it = 1 if $feedback_posted eq 'Y';
	    } else {
		$post_it = 1;
	    }
	} else {
	    if (defined $feedback_posted && $feedback_posted eq 'Y') {
		$post_it = 1;
	    }
	}
    }
    return $post_it;
}


sub setFeedbackPostFlag {
    my ($self, $bywhom, $flag) = @_;

    my $current_submission = $self->{assignment_submissions}->[$self->{current_submission}-1];

    if ($current_submission) {
	### no update from the user, no value in the table, do nothing
	return if (!defined $self->{assignment}->getResubmitFlag() && !defined $flag);

	$flag = (defined $flag) ? 'Y' : 'N';
	$current_submission->setFeedbackPostFlag($flag);
	$current_submission->save({user => $bywhom->getUserID()});
    }
}


sub getIndividualResubmitFlag {
    my $self = shift;
    return ($self->{link_assignment}) ? $self->{link_assignment}->getResubmitFlag() : undef;
}

sub setIndividualResubmitFlag {
    my ($self, $bywhom, $flag) = @_;

    if ($self->{link_assignment}) {
	$self->{link_assignment}->setResubmitFlag($flag);
	$self->{link_assignment}->save({user => $bywhom->getUserID()});
    }
}

sub getSubmitDate {
    my ($self, $sequence) = @_;

    if (defined $self->{assignment_submissions} && scalar @{$self->{assignment_submissions}}) {
	$sequence = $self->{current_submission} unless (defined $sequence);
	return ($sequence && $self->{assignment_submissions}->[$sequence-1]) ? $self->{assignment_submissions}->[$sequence-1]->getSubmitDate() : undef;
    } 

    return undef;
}

sub setSubmitDate {
    my ($self, $submit_date) = @_;

    unless (defined $submit_date) {
	my $date = HSDB4::DateTime->new()->in_apache_timestamp(scalar localtime);
	$submit_date =  $date->out_mysql_timestamp();
    }

    if ($self->{link_assignment}) {
	my $submit = TUSK::Assignment::Submission->new();
	$submit->setFieldValues({
	    link_id => $self->{link_id},
	    link_type => $self->{link_type},
	    submit_date => $submit_date,
	    submit_sequence => $self->{current_submission},
	});
	$submit->save({user => $self->{user_id}});

	$self->{link_assignment}->save({user => $self->{user_id}});
    }
}


sub getNotes {
    my ($self, $type, $sort_order) = @_;
    die "missing note type in getNotes()" unless defined $type;

    my $note = $self->getAssignmentNote({note_type => $type, created_by => $self->{user_id} });
    return ($note->[0]) ? $note->[0]->getFormattedBody() : '';
}


sub getGrade {
    my ($self, $sequence) = @_;

    $sequence = $self->{current_submission} unless defined $sequence;
    if (my $submit = $self->{assignment_submissions}->[$sequence-1]) {
	return $submit->getGrade();
    } 

    return undef;
}


sub setGrade {
    my ($self, $bywhom, $grade) = @_;

    if (my $submit = $self->{assignment_submissions}->[$self->{current_submission}-1]) {
	$submit->setGrade($grade);
	$submit->save({user => $bywhom->getUserID()});
    }
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
    return ($self->{assignment}->getResubmitFlag() || $self->{link_assignment}->getResubmitFlag()) ? 1 : 0;
}


1;
