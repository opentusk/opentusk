# Copyright 2013 Tufts University
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


package TUSK::Core::AuditTrail::LinkUserGradeEventHistory;

=head1 NAME

B<TUSK::Core::AuditTrail::LinkUserGradeEventHistory> - Class for manipulating entries in table link_user_grade_event_history in tusk database

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
					'tablename' => 'link_user_grade_event_history',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'link_user_grade_event_history_id' => 'pk',
					'link_user_grade_event_id' => '',
					'parent_user_id' => '',
					'child_grade_event_id' => '',
					'grade' => '',
					'comments' => '',
					'user_group_id' => '',
					'teaching_site_id' => '',
					'coding_code_id' => '',
					'history_action' => '',
				    },
				    _attributes => {
					save_history => 0,
					tracking_fields => 1,	
				    },
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

=item B<getLinkUserGradeEventID>

my $string = $obj->getLinkUserGradeEventID();

Get the value of the link_user_grade_event_id field

=cut

sub getLinkUserGradeEventID{
    my ($self) = @_;
    return $self->getFieldValue('link_user_grade_event_id');
}

#######################################################

=item B<setLinkUserGradeEventID>

$obj->setLinkUserGradeEventID($value);

Set the value of the link_user_grade_event_id field

=cut

sub setLinkUserGradeEventID{
    my ($self, $value) = @_;
    $self->setFieldValue('link_user_grade_event_id', $value);
}


#######################################################

=item B<getParentUserID>

my $string = $obj->getParentUserID();

Get the value of the parent_user_id field

=cut

sub getParentUserID{
    my ($self) = @_;
    return $self->getFieldValue('parent_user_id');
}

#######################################################

=item B<setParentUserID>

$obj->setParentUserID($value);

Set the value of the parent_user_id field

=cut

sub setParentUserID{
    my ($self, $value) = @_;
    $self->setFieldValue('parent_user_id', $value);
}


#######################################################

=item B<getChildGradeEventID>

my $string = $obj->getChildGradeEventID();

Get the value of the child_grade_event_id field

=cut

sub getChildGradeEventID{
    my ($self) = @_;
    return $self->getFieldValue('child_grade_event_id');
}

#######################################################

=item B<setChildGradeEventID>

$obj->setChildGradeEventID($value);

Set the value of the child_grade_event_id field

=cut

sub setChildGradeEventID{
    my ($self, $value) = @_;
    $self->setFieldValue('child_grade_event_id', $value);
}


#######################################################

=item B<getGrade>

my $string = $obj->getGrade();

Get the value of the grade field

=cut

sub getGrade{
    my ($self) = @_;
    return $self->getFieldValue('grade');
}

#######################################################

=item B<setGrade>

$obj->setGrade($value);

Set the value of the grade field

=cut

sub setGrade{
    my ($self, $value) = @_;
    $self->setFieldValue('grade', $value);
}


#######################################################

=item B<getComments>

my $string = $obj->getComments();

Get the value of the comments field

=cut

sub getComments{
    my ($self) = @_;
    return $self->getFieldValue('comments');
}

#######################################################

=item B<setComments>

$obj->setComments($value);

Set the value of the comments field

=cut

sub setComments{
    my ($self, $value) = @_;
    $self->setFieldValue('comments', $value);
}


#######################################################

=item B<getUserGroupID>

my $string = $obj->getUserGroupID();

Get the value of the user_group_id field

=cut

sub getUserGroupID{
    my ($self) = @_;
    return $self->getFieldValue('user_group_id');
}

#######################################################

=item B<setUserGroupID>

$obj->setUserGroupID($value);

Set the value of the user_group_id field

=cut

sub setUserGroupID{
    my ($self, $value) = @_;
    $self->setFieldValue('user_group_id', $value);
}


#######################################################

=item B<getTeachingSiteID>

my $string = $obj->getTeachingSiteID();

Get the value of the teaching_site_id field

=cut

sub getTeachingSiteID{
    my ($self) = @_;
    return $self->getFieldValue('teaching_site_id');
}

#######################################################

=item B<setTeachingSiteID>

$obj->setTeachingSiteID($value);

Set the value of the teaching_site_id field

=cut

sub setTeachingSiteID{
    my ($self, $value) = @_;
    $self->setFieldValue('teaching_site_id', $value);
}


#######################################################

=item B<getCodingCodeID>

my $string = $obj->getCodingCodeID();

Get the value of the coding_code_id field

=cut

sub getCodingCodeID{
    my ($self) = @_;
    return $self->getFieldValue('coding_code_id');
}

#######################################################

=item B<setCodingCodeID>

$obj->setCodingCodeID($value);

Set the value of the coding_code_id field

=cut

sub setCodingCodeID{
    my ($self, $value) = @_;
    $self->setFieldValue('coding_code_id', $value);
}


#######################################################

=item B<getHistoryAction>

my $string = $obj->getHistoryAction();

Get the value of the history_action field

=cut

sub getHistoryAction{
    my ($self) = @_;
    return $self->getFieldValue('history_action');
}

#######################################################

=item B<setHistoryAction>

$obj->setHistoryAction($value);

Set the value of the history_action field

=cut

sub setHistoryAction{
    my ($self, $value) = @_;
    $self->setFieldValue('history_action', $value);
}



=back

=cut

### Other Methods

=head1 BUGS

None Reported.

=head1 SEE ALSO

B<TUSK::Core::SQLRow> - parent class

=head1 AUTHOR

TUSK Development Team <tuskdev@tufts.edu>

=head1 COPYRIGHT

Copyright (c) Tufts University Sciences Knowledgebase, 2013.

=cut

1;

