package TUSK::Application::Assignment::Author;

use base qw(TUSK::Application::Assignment::User);
use TUSK::Assignment::LinkAssignmentUser;
use TUSK::Assignment::LinkAssignmentUserGroup;
use TUSK::Application::Assignment::Student::Individual;
use TUSK::Application::Assignment::Student::Group;

sub new {

    my ($class, $args) = @_;

    my $self = { assignment  => $args->{assignment},
		 user_id     => $args->{user_id},
	         course      => $args->{course} };

    bless($self, $class);
    $self->init();
    return $self;
}

sub getStudents {
    my ($self) = @_;
    my @students = ();
 
   foreach my $student ($self->{course}->get_students($self->{assignment}->getTimePeriodID())) {
	push @students, TUSK::Application::Assignment::Student::Individual->new({user_id => $student->primary_key(), assignment => $self->{assignment}, faculty_view => 1});
    }

    return \@students;
}


sub getStudentGroups {
    my $self = shift;
    my @groups = ();

    my $links = TUSK::Assignment::LinkAssignmentUserGroup->new()->lookup("parent_assignment_id = $self->{assignment_id}");

    foreach my $link (@{$links}) {
	push @groups, TUSK::Application::Assignment::Student::Group->new({
	    group_id => $link->getChildUserGroupID(), 
	    assignment => $self->{assignment}, 
	    course => $self->{course},
##	    link_assignment => $link
	    faculty_view => 1,
	});
    }

    return \@groups;
}

sub getStudentGroupsWithContent {
    my $self = shift;

    my $dbh = $self->{assignment}->getDatabaseReadHandle();
    my $sth = $dbh->prepare("select distinct link_assignment_content_id from hsdb4.link_content_user, tusk.link_assignment_content where parent_assignment_id = $self->{assignment_id} and parent_content_id = child_content_id and user_group_id != 0 and roles = 'Author'");
    $sth->execute();

    my $ids = join(",", $sth->fetchrow_array());

    return (defined $ids && $ids =~ /\d/) ? TUSK::Assignment::LinkAssignmentContent->new()->lookup("link_assignment_content_id in ($ids)") : undef;
}

### group_flag is a passed argument because we want the caller to decide which table data should be deleted from
sub cleanupStudentsLinks {
    my ($self,$group_flag) = @_;
    my $links;

    if ($group_flag) {
	$links = TUSK::Assignment::LinkAssignmentUserGroup->new()->lookup("parent_assignment_id = $self->{assignment_id}");
    } else {
	$links = TUSK::Assignment::LinkAssignmentStudent->new()->lookup("parent_assignment_id = $self->{assignment_id}");
    }

    foreach my $link (@$links) {
	$link->delete({user => $self->{user_id}});
    }
}

sub cleanupFacultyLinks {
    my $self = shift;
    $links = TUSK::Assignment::LinkAssignmentUser->new()->lookup("parent_assignment_id = $self->{assignment_id}");

    foreach my $link (@$links) {
	$link->delete({user => $self->{user_id}});
    }

}


sub getFacultyContent {
    my $self = shift;
    my $sequence = shift || 0;

    ### in case if there are many faculty members who write assignments
    ### all faculty contents will be displayed to students

    my $contentlinks = TUSK::Assignment::LinkAssignmentContent->lookup("parent_assignment_id = " . $self->{assignment_id} . " AND child_content_id in (select parent_content_id from hsdb4.link_content_user a, tusk.link_assignment_user b where a.child_user_id = b.child_user_id and b.parent_assignment_id = " . $self->{assignment_id} . " and roles = 'Author') and submit_sequence = $sequence");

    return $contentlinks;
}


1;
