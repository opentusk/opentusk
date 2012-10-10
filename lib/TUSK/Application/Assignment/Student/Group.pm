package TUSK::Application::Assignment::Student::Group;

use strict;
use base 'TUSK::Application::Assignment::Student';
use HSDB45::UserGroup;
use TUSK::Core::School;
use TUSK::Assignment::LinkAssignmentUserGroup;



sub new {
    my ($class, $args) = @_;

    my $self = { group_id => $args->{group_id},
	         user_id => $args->{user_id},
		 assignment => $args->{assignment},
		 course => $args->{course},
		 school => $args->{course}->get_school(),
		 faculty_view => $args->{faculty_view},  
		 link_assignment => $args->{link_assignment},
	       };
    bless($self,$class);

    $self->init();

    if (defined $self->{link_assignment}) {
	$self->SUPER::setAssignmentLinks($self->{link_assignment});
    } else {
	$self->setAssignmentLinks();
    }

    if ($args->{course}) {
	if ($self->{group_id}) {
	    $self->{group} = HSDB45::UserGroup->new(_school => $args->{course}->get_school()->getSchoolName())->lookup_key($args->{group_id});
	}
    } else {
	die "missing key parameters: course\n";
    }

    return $self;
}


sub setAssignmentLinks {
    my $self = shift;

    if (defined $self->{assignment} && defined $self->{group_id}) {
	my $link =  TUSK::Assignment::LinkAssignmentUserGroup->new()->lookupReturnOne("child_user_group_id = $self->{group_id} AND parent_assignment_id = $self->{assignment_id}");
	unless (defined $link) {
	    $link = TUSK::Assignment::LinkAssignmentUserGroup->new();
	    $link->setFieldValues({ 
		child_user_group_id  => $self->{group_id},
		parent_assignment_id => $self->{assignment_id} });
	    $link->save({user => $self->{user_id}});
	}
	$self->SUPER::setAssignmentLinks($link);
    }
}


sub getFacultyContent {
    my $self = shift;
    my $sequence = shift || 0;
    my $condition = '';

    if ($self->{group_id}) {
	## somewhat kludgy  
	## a group memeber gets original faculty content without a group id 
	## when sequence is zero; otherwise, the member will get faculty content 
	## based on passed sequence and a group id
	if ($self->{assignment}->getGroupFileFlag() || $sequence) {
	    $condition = "AND user_group_id = $self->{group_id}";
	}
    } else {
	my $db = HSDB4::Constants::get_school_db($self->{school}->getSchoolName());
	$condition = "AND user_group_id in (select parent_user_group_id from $db.link_user_group_user where child_user_id = '$self->{user_id}')";
    }

    my $contentlinks = TUSK::Assignment::LinkAssignmentContent->lookup("parent_assignment_id = " . $self->{assignment_id} . " AND child_content_id in (SELECT parent_content_id FROM hsdb4.link_content_user a, tusk.link_assignment_user b where a.child_user_id = b.child_user_id and b.parent_assignment_id = " . $self->{assignment_id} . " and roles = 'Author') AND submit_sequence = $sequence $condition");

    return $contentlinks;
}


sub getContent {
    my ($self, $sequence) = @_;
 
    $sequence = $self->{current_submission} unless (defined $sequence);
    my $db = HSDB4::Constants::get_school_db($self->{course}->get_school()->getSchoolName());

    my $contentlinks = TUSK::Assignment::LinkAssignmentContent->new()->lookup("parent_assignment_id = $self->{assignment_id} AND user_group_id = $self->{group_id} AND child_content_id in (SELECT parent_content_id FROM hsdb4.link_content_user a, $db.link_user_group_user b WHERE roles rlike 'Student-' and a.child_user_id = b.child_user_id and b.parent_user_group_id = $self->{group_id}) AND submit_sequence = $sequence order by modified_on");

    return $contentlinks;
}


sub getNotes {
    my ($self, $sort_order) = @_;
    return $self->SUPER::getNotes('group-note',$sort_order);
}


sub setNotes {
    my ($self, $notes) = @_;
    my $type = 'group-note';

    if ($self->{link_assignment}) {
	my $note_objs = TUSK::Assignment::Note->lookup("link_id = $self->{link_id} AND link_type = '$self->{link_type}' AND type = '$type' AND created_by = '$self->{user_id}'");

	my $sort_order = (defined $note_objs) ? scalar @$note_objs + 1 : 1;
	my $note = $self->createNoteObject({type => $type, body => $notes, sort_order => $sort_order });
	$note->save({user => $self->{user_id}});
    }
}


sub getMemberNotes {
    my $self = shift;
    return TUSK::Assignment::Note->lookup("link_id = $self->{link_id} AND link_type = '$self->{link_type}' AND type = 'group-note'", ['modified_on DESC']);
}


sub getCurrentAssignmentLinks {
    my ($self) = @_;
    my @assignment_links = ();
    my $tp = $self->{course}->get_current_timeperiod();

    if (ref $tp eq 'HSDB45::TimePeriod' && $self->{course}->is_user_registered($self->{user_id}, $tp->primary_key)) {
	my $assignments = TUSK::Assignment::Assignment->new()->lookup(
	      "course_id = " . $self->{course}->primary_key 
	      . " AND time_period_id = " . $tp->primary_key() 
	      . " AND school_id = " . TUSK::Core::School->new()->getSchoolID($self->{school}) 
	      . " AND available_date != '0000-00-00 00:00:00' AND available_date <= now()");

	foreach my $assignment (@{$assignments}) {
	    my $link = TUSK::Assignment::LinkAssignmentUserGroup->new()->lookupReturnOne("child_user_group_id = '$self->{user_id}' AND parent_assignment_id = " . $assignment->getPrimaryKeyID());
		push @assignment_links, { assignment => $assignment, assignment_link_user_group => $link };
	}
    }

    return \@assignment_links;
}


sub getName {
    my $self = shift;
    return $self->{group}->out_label();
}

sub getID {
    my $self = shift;
    return $self->{group_id};
}

sub getGroupID {
    my $self = shift;
    return $self->{group_id};
}

sub setGroupID {
    my ($self, $group_id) = @_;
    $self->{group_id} = $group_id;
    $self->setAssignmentLinks();
}

sub setGradeEventLink {
    my ($self) = @_;

    my $links = TUSK::GradeBook::LinkUserGradeEvent->new()->lookup("user_group_id = $self->{group_id} AND child_grade_event_id = " . $self->{assignment}->getGradeEventID());

    if (defined $links && scalar @{$links} > 0) {
	$self->{grade_event_link} = $links;
    }
}

sub setFacultyComments {
    my ($self, $bywhom, $comments) = @_;
    unless (defined $self->{grade_event_link}) {
	$self->setGradeEventLink();
    }

    if (defined $self->{grade_event_link}) {
	foreach my $link (@{$self->{grade_event_link}}) {
	    $link->setComments($comments);
	    $link->save({user => $bywhom->getUserID()});
	}
    } else {
	my $grade_event_id = $self->{assignment}->getGradeEventID();
	my $i = 0;
	foreach my $student ($self->{group}->child_users()) {
	    my $link = TUSK::GradeBook::LinkUserGradeEvent->new();
	    $link->setFieldValues({
		parent_user_id => $self->getUserID(),
		user_group_id => $self->{group_id},
		child_grade_event_id => $grade_event_id,
		comments => $comments });

	    $link->save({user => $bywhom->getUserID()});
	    $self->{grade_event_link}[$i] = $link;
	    $i++;
	}
    }

    $self->setComments('faculty-comment',$comments);
}


sub setGrade {
    my ($self, $bywhom, $grade) = @_;

    unless (defined $self->{grade_event_link}) {
	$self->setGradeEventLink();
    }

    if (defined $self->{grade_event_link}) {
	foreach my $link (@{$self->{grade_event_link}}) {
	    $link->setGrade($grade);
	    $link->save({user => $bywhom->getUserID()});
	}
    } else {
	my $grade_event_id = $self->{assignment}->getGradeEventID();
	my $i = 0;
	foreach my $student ($self->{group}->child_users()) {
	    my $link = TUSK::GradeBook::LinkUserGradeEvent->new();
	    $link->setFieldValues({
		      parent_user_id => $student->primary_key(),
		      child_grade_event_id => $grade_event_id,
		      user_group_id => $self->{group_id},
		      grade => $grade });

	    $link->save({user => $bywhom->getUserID()});
	    $self->{grade_event_link}[$i] = $link;
	    $i++;
	}

    }

    $self->SUPER::setGrade($bywhom, $grade);
}


sub getAssignedGroups {
    my $self = shift;
    my $db = $self->{school}->getSchoolDb();

    my $links = TUSK::Assignment::LinkAssignmentUserGroup->new()->lookup("parent_assignment_id = $self->{assignment_id} and child_user_group_id in (select child_user_group_id from $db.link_user_group_user, $db.link_course_user_group where child_user_id = '$self->{user_id}' and parent_user_group_id = child_user_group_id and parent_course_id = " . $self->{course}->primary_key() . ")");

    my @groups = ();
    if (@{$links}) {
	@groups = HSDB45::UserGroup->new(_school => $self->{school}->getSchoolName())->lookup_conditions("user_group_id in (" . join(", ", map {$_->getChildUserGroupID()} @$links) . ")");
    }
    return \@groups;
}


1;
