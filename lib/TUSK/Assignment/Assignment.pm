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


package TUSK::Assignment::Assignment;

=head1 NAME

B<TUSK::Assignment::Assignment> - Class for manipulating entries in table assignment in tusk database

=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 INTERFACE


=head2 GET/SET METHODS

=over 4

=cut

use strict;

BEGIN {
    require Exporter;
    require TUSK::Core::SQLRow;

    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
    
    @ISA = qw(TUSK::Core::SQLRow Exporter);
    @EXPORT = qw( );
    @EXPORT_OK = qw( );
}

use vars @EXPORT_OK;
use TUSK::GradeBook::GradeEvent;
use TUSK::Assignment::LinkAssignmentContent;
use TUSK::Assignment::LinkAssignmentStudent;
use TUSK::Assignment::LinkAssignmentUserGroup;
use HSDB4::Constants;
use HSDB4::DateTime;

# Non-exported package globals go here
use vars ();

sub new {
    # Find out what class we are
    my $class = shift;
    $class = ref $class || $class;
    # Call the super-class's constructor and give it all the values
    my $self = $class->SUPER::new ( 
				    _datainfo => {
					'database' => 'tusk',
					'tablename' => 'assignment',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'assignment_id' => 'pk',
					'grade_event_id' => '',
					'available_date' => '',
					'due_date' => '',
					'group_file_flag' => '',
					'resubmit_flag' => '',
					'email_flag' => '',
					'sort_order'	=> '',
				    },
				    _attributes => {
					save_history => 1,
					tracking_fields => 1,	
				    },
				     _default_join_objects => [
          TUSK::Core::JoinObject->new("TUSK::GradeBook::GradeEvent"), 
				     ],
				    _levels => {
					reporting => 'cluck',
					error => 0,
				    },
				    @_
				  );
    # Finish initialization...
    return $self;
}

### Get/Set methods

#######################################################

=item B<getGradeEventID>

my $string = $obj->getGradeEventID();

Get the value of the grade_event_id field

=cut

sub getGradeEventID{
    my ($self) = @_;
    return $self->getFieldValue('grade_event_id');
}

#######################################################

=item B<setGradeEventID>

$obj->setGradeEventID($value);

Set the value of the grade_event_id field

=cut

sub setGradeEventID{
    my ($self, $value) = @_;
    $self->setFieldValue('grade_event_id', $value);
}


#######################################################

=item B<getAvailableDate>

my $string = $obj->getAvailableDate();

Get the value of the available_date field

=cut

sub getAvailableDate{
    my ($self) = @_;
    return $self->getFieldValue('available_date');
}


#######################################################

=item B<getFormattedAvailableDate>

   $string = $obj->getFormattedAvailableDate();

Get the value of the available_date field without secs

=cut

sub getFormattedAvailableDate{
    my ($self) = @_;
    my $avail_date = $self->getAvailableDate();
    $avail_date =~ s/:\d\d$//;
    return $avail_date;
}


#######################################################

=item B<setAvailableDate>

$obj->setAvailableDate($value);

Set the value of the available_date field

=cut

sub setAvailableDate{
    my ($self, $value) = @_;
    $self->setFieldValue('available_date', $value);
}


#######################################################

=item B<getDueDate>

my $string = $obj->getDueDate();

Get the value of the due_date field

=cut

sub getDueDate{
    my ($self) = @_;
    return $self->getFieldValue('due_date');
}

#######################################################

=item B<getFormattedDueDate>

   $string = $obj->getFormattedDueDate();

Get the value of the due_date field with no secs

=cut

sub getFormattedDueDate{
    my ($self) = @_;
    my $due_date = $self->getDueDate();
    $due_date =~ s/:\d\d$//;
    return $due_date;
}

#######################################################

=item B<setDueDate>

$obj->setDueDate($value);

Set the value of the due_date field

=cut

sub setDueDate{
    my ($self, $value) = @_;
    $self->setFieldValue('due_date', $value);
}


#######################################################

=item B<getGroupFileFlag>

my $string = $obj->getGroupFileFlag();

Get the value of the group_file_flag field

=cut

sub getGroupFileFlag{
    my ($self) = @_;
    return $self->getFieldValue('group_file_flag');
}

#######################################################

=item B<setGroupFileFlag>

$obj->setGroupFileFlag($value);

Set the value of the group_file_flag field

=cut

sub setGroupFileFlag{
    my ($self, $value) = @_;
    $self->setFieldValue('group_file_flag', $value);
}


#######################################################

=item B<getResubmitFlag>

my $string = $obj->getResubmitFlag();

Get the value of the resubmit_flag field

=cut

sub getResubmitFlag{
    my ($self) = @_;
    return $self->getFieldValue('resubmit_flag');
}

#######################################################

=item B<setResubmitFlag>

$obj->setResubmitFlag($value);

Set the value of the resubmit_flag field

=cut

sub setResubmitFlag{
    my ($self, $value) = @_;
    $self->setFieldValue('resubmit_flag', $value);
}

#######################################################

=item B<getEmailFlag>

my $string = $obj->getEmailFlag();

Get the value of the email_flag field

=cut

sub getEmailFlag{
    my ($self) = @_;
    return $self->getFieldValue('email_flag');
}

#######################################################

=item B<setEmailFlag>

$obj->setEmailFlag($value);

Set the value of the email_flag field

=cut

sub setEmailFlag{
    my ($self, $value) = @_;
    $self->setFieldValue('email_flag', $value);
}

#######################################################

=item B<getSortOrder>

my $string = $obj->getSortOrder();

Get the value of the sort_order field

=cut

sub getSortOrder{
    my ($self) = @_;
    return $self->getFieldValue('sort_order');
}

#######################################################

=item B<setSortOrder>

$obj->setSortOrder($value);

Set the value of the sort_order field

=cut

sub setSortOrder{
    my ($self, $value) = @_;
    $self->setFieldValue('sort_order', $value);
}

=back


=cut

#######################################################

### Other Methods

sub updateSortOrders{
    my ($self, $change_order_string, $assignments) = @_;
	my ($index, $new_index) = split('-', $change_order_string);	
	my $cond = "1 = 1"; 
    return $self->SUPER::updateSortOrders($index, $new_index, $cond, $assignments);
}


sub getGradeEventObject {
    my ($self) = @_;
    return $self->getJoinObject("TUSK::GradeBook::GradeEvent");
}


sub getTitle {
    my ($self) = @_;
    if (ref $self->getGradeEventObject() eq "TUSK::GradeBook::GradeEvent"){
	return $self->getGradeEventObject()->getEventName();
    }
}

sub getInstruction {
    my ($self) = @_;
    if (ref $self->getGradeEventObject() eq "TUSK::GradeBook::GradeEvent"){
	return $self->getGradeEventObject()->getEventDescription();
    }
}

sub getFormattedInstruction {
    my ($self) = @_;
    if (ref $self->getGradeEventObject() eq "TUSK::GradeBook::GradeEvent"){
	my $desc = $self->getGradeEventObject()->getEventDescription();
	$desc =~ s/\n/<br\/>/g;
	return $desc;
    }
}

sub getWeight {
    my ($self) = @_;
    if (ref $self->getGradeEventObject() eq "TUSK::GradeBook::GradeEvent"){
	return $self->getGradeEventObject()->getWeight();
    }
}

sub getTimePeriodID {
    my ($self) = @_;
    if (ref $self->getGradeEventObject() eq "TUSK::GradeBook::GradeEvent"){
	return $self->getGradeEventObject()->getTimePeriodID();
    }
}

sub getPublishFlag {
    my ($self) = @_;
    if (ref $self->getGradeEventObject() eq "TUSK::GradeBook::GradeEvent"){
	return $self->getGradeEventObject()->getPublishFlag();
    }
}

sub getGroupFlag {
    my ($self) = @_;
    if (ref $self->getGradeEventObject() eq "TUSK::GradeBook::GradeEvent"){
	return $self->getGradeEventObject()->getGroupFlag();
    }
}


sub getLinkAssignmentContentObject {
    my ($self) = @_;
    return $self->getJoinObject("TUSK::Assignment::LinkAssignmentContent");
}

sub isPublished {
    my $self = shift;
    my $now = HSDB4::DateTime->new()->in_apache_timestamp(scalar localtime);
    my $available_date = HSDB4::DateTime->new()->in_mysql_timestamp($self->getAvailableDate());
    my $val = HSDB4::DateTime::compare($now,$available_date);
    return ($val <= 0) ? 0 : 1;
}    


sub isAlreadyWorkedOnByStudents {
    my $self = shift;
    return 0 unless $self->getPrimaryKeyID();
    my $cond = "link_assignment_content.parent_assignment_id = " . $self->getPrimaryKeyID();
    my $found;

    if ($self->getGroupFlag()) {
	my $dbh = $self->getDatabaseReadHandle();
	my $sth = $dbh->prepare("select distinct parent_content_id, child_user_id from hsdb4.link_content_user a, tusk.link_assignment_user_group b, tusk.link_assignment_content c where b.parent_assignment_id = " . $self->getPrimaryKeyID() . " and child_content_id = parent_content_id and b.parent_assignment_id = c.parent_assignment_id and roles rlike 'Student'");
	$sth->execute();
	$found = $sth->fetchrow_arrayref();
    } else { 
	$found = TUSK::Assignment::LinkAssignmentContent->new()->passValues($self)->lookup($cond, undef, undef, undef, [ TUSK::Core::JoinObject->new("TUSK::Assignment::LinkAssignmentStudent", {joinkey => 'parent_assignment_id', jointype => 'inner'})]);
    }

    return (defined $found && @{$found}) ? 1 : 0;
}

sub isAlreadySubmitted {
    my $self = shift;
 
    return 0 unless $self->getPrimaryKeyID();

    my $submit = TUSK::Assignment::Submission->new();

    my $links;
    if ($self->getGroupFlag()) {
	$links = $submit->passValues($self)->lookup("parent_assignment_id = " . $self->getPrimaryKeyID() . " AND submit_date is not null AND link_type = 'link_assignment_user_group'", undef, undef, undef, [TUSK::Core::JoinObject->new('TUSK::Assignment::LinkAssignmentUserGroup', {joinkey => 'link_assignment_user_group_id', origkey => 'link_id', jointype => 'inner'})]);
    } else {
	$links = $submit->passValues($self)->lookup("parent_assignment_id = " . $self->getPrimaryKeyID() . " AND submit_date is not null AND link_type = 'link_assignment_student'", undef, undef, undef, [TUSK::Core::JoinObject->new('TUSK::Assignment::LinkAssignmentStudent', {joinkey => 'link_assignment_student_id', origkey => 'link_id', jointype => 'inner'})]);
    }

    return (@{$links}) ? 1 : 0;
}


sub containsFacultyContent {
    my $self = shift;

    return 0 unless $self->getPrimaryKeyID();

    my $links = TUSK::Assignment::LinkAssignmentUser->new()->lookup("parent_assignment_id = " . $self->getPrimaryKeyID());

    return (@{$links}) ? 1 : 0;
}

sub isOverDue {
	my $self = shift;
	if (my $due_date = $self->getDueDate()) {
		my $now = HSDB4::DateTime->new();
		my $due = HSDB4::DateTime->new()->in_mysql_date($due_date);
		return (HSDB4::DateTime::compare($now, $due) > 0) ? 1 : 0;
	}
	return 0;
}

=head1 BUGS

None Reported.

=head1 SEE ALSO

B<TUSK::Core::SQLRow> - parent class

=head1 AUTHOR

TUSK Development Team <tuskdev@tufts.edu>

=head1 COPYRIGHT

Copyright (c) Tufts University Sciences Knowledgebase, 2004.

=cut

1;

