# Copyright 2012 Tufts University 
#
# Licensed under the Educational Community License, Version 1.0 (the "License"); 
# you may not use this file except in compliance with the License. 
# You may obtain a copy of the License at 
#
# http://www.opensource.org/licenses/ecl1.php 
#
# Unless required by applicable law or agreed to in writing, software 
# distributed under the License is distributed on an "AS IS" BASIS, 
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
# See the License for the specific language governing permissions and 
# limitations under the License.


package TUSK::Application::Assignment::User;


use HSDB4::Constants;
use TUSK::Constants;
use HSDB4::SQLRow::User;
use HSDB4::SQLRow::Content;
use TUSK::Assignment::Assignment;
use TUSK::Assignment::LinkAssignmentContent;
use TUSK::Assignment::Note;
use TUSK::Assignment::Submission;
use TUSK::GradeBook::LinkUserGradeEvent;


sub new {

    my ($incoming, $args)  = @_;
    my $class = ref($incoming) || $incoming;

    my $self = { assignment_id  => _$args->{assignment_id},
		 user_id     => $args->{user_id}, };

    return bless($self, $class);
}


sub init {
    my $self = shift;
    
    $self->{user} = HSDB4::SQLRow::User->new()->lookup_key($self->{user_id});

    if (defined $self->{assignment}) {
	$self->{assignment_id} =  $self->{assignment}->getPrimaryKeyID();
	$self->{grade_event_id} = $self->{assignment}->getGradeEventID();
    }
}


sub getAssignment {
    my $self = shift;
    return $self->{assignment};
}


sub setAssignment {
    my ($self, $assignment) = @_;
    $self->{assignment} = $assignment;
    die "Error: invalid assignment" unless defined $assignment->getPrimaryKeyID();
    $self->{assignment_id} = $assignment->getPrimaryKeyID();
    if (defined $self->{assignment}) {
	$self->{assignment_id} =  $self->{assignment}->getPrimaryKeyID();
	$self->{grade_event_id} = $self->{assignment}->getGradeEventID();
    }

}

sub getUserID {
    my $self = shift;
    return $self->{user_id};
}

sub getID {
    my $self = shift;
    return $self->{user_id};
}

sub getName {
    my $self = shift;
    return $self->{user}->out_lastfirst_name();
}


sub deleteContent {
    my ($self, $content_ids) = @_;

    my $un = $TUSK::Constants::DatabaseUsers->{ContentManager}->{writeusername};
    my $pw = $TUSK::Constants::DatabaseUsers->{ContentManager}->{writepassword};

    eval {
	foreach my $content_id (@{$content_ids}) {
	    my $link = TUSK::Assignment::LinkAssignmentContent->new()->lookupReturnOne("parent_assignment_id = $self->{assignment_id} AND child_content_id = $content_id");
	    if (defined $link) {
		$link->delete({user => $self->{user_id}});
	    }

	    my $content = HSDB4::SQLRow::Content->new()->lookup_key($content_id);
	    if (defined $content && $content->primary_key()) {
		my ($rval, $msg) = $content->delete_child_users($un, $pw);
		my $rows = $content->delete($un, $pw);
	    }
	}
    };
	
    return ($@) ? $@ : undef;
}


sub getGradeEvent {
    my $self = shift;
    my $grade_event_id;
    my $grade_event = TUSK::GradeBook::GradeEvent->new();

    if (defined $self->{assignment}) {
	return $grade_event->lookupKey($self->{assignment}->getGradeEventID());
    } else {
	return $grade_event;
    }
}


sub getAssignmentSubmission {
    my ($self, $sequence) = @_;

    my $cond = "link_id = $self->{link_id} AND link_type = '$self->{link_type}'";
    if ($submission_sequence) {
	$cond .= " AND submit_sequence = $sequence";
    }
    return TUSK::Assignment::Submission->lookup($cond);
}


### could get multiple notes for each type
sub getAssignmentNote {
    my ($self, $args) = @_;

    die "Need Note Type\n" unless defined $args->{note_type};

    my $condition = "link_id = $self->{link_id} AND link_type = '$self->{link_type}' AND type = '$args->{note_type}'";

    $condition .= " AND sort_order = $args->{sort_order}" if ($args->{sort_order});
    $condition .= " AND created_by = '$args->{created_by}'" if ($args->{created_by});

    ### it is possible that some faculty/student comments are not in sequence  
    ### ie not all comments are made for each submission
    if ($args->{note_type} eq 'faculty-comment' || $args->{note_type} eq 'student-comment') {
	my $notes = TUSK::Assignment::Note->lookup($condition);
	my @sequenced_notes;
	foreach (@$notes) {
	    my $seq = ($_->getSubmitSequence() > 0) ? $_->getSubmitSequence()-1 : 0;
	    $sequenced_notes[$seq] = $_;
	}
	return \@sequenced_notes;
    } 

    ### self or group notes
    return TUSK::Assignment::Note->lookup($condition);
}



sub createNoteObject {
    my ($self, $args) = @_;
    my $note = TUSK::Assignment::Note->new();

    if ($self->{link_id} && $self->{link_type}) {
	$note->setFieldValues({
	    link_id => $self->{link_id},
	    link_type => $self->{link_type},
	    type => $args->{type},
	    sort_order => $args->{sort_order} || 1,
	    submit_sequence => $args->{sequence} || 0,
	    body => $args->{body},
	});
    }
    return $note;
}


sub getComments {
    my ($self, $type, $sequence, $sort_order) = @_;
    my $comments = $self->getAssignmentNote({note_type => $type});

    $sequence = $self->{current_submission} unless (defined $sequence);
    return ($sequence > 0 && $comments->[$sequence-1]) ? $comments->[$sequence-1]->getFormattedBody() : undef;
}

sub setComments {
    my ($self, $type, $comments) = @_;

    if ($self->{link_assignment}) {
	my $note = TUSK::Assignment::Note->lookupReturnOne("link_id = $self->{link_id} AND link_type = '$self->{link_type}' AND type = '$type' AND submit_sequence = $self->{current_submission}");

	unless (defined $note) { 
	    $note = $self->createNoteObject({type => $type, body => $comments, sequence => $self->{current_submission}});
	} else {
	    $note->setBody($comments);
	}
	$note->save({user => $self->{user_id}});
    }
}


1;
