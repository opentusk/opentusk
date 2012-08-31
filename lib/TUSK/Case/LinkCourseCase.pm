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


package TUSK::Case::LinkCourseCase;

=head1 NAME

B<TUSK::Case::LinkCourseCase> - Class for manipulating entries in table link_course_case in tusk database

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
					'tablename' => 'link_course_case',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'link_course_case_id' => 'pk',
					'parent_course_id' => '',
					'child_case_id' => '',
					'school_id' => '',
					'available_date' => '',
					'due_date' => '',
					'sort_order' => '',
				    },
				    _attributes => {
					save_history => 1,
					tracking_fields => 1,	
				    },
				    _levels => {
					reporting => 'cluck',
					error => 0,
				    },
				    _default_order_bys => ['sort_order'],
				    _default_join_objects => [ TUSK::Core::JoinObject->new("TUSK::Case::Case", { joinkey => 'case_header_id', origkey => 'child_case_id' } )],
				    @_
				  );
    # Finish initialization...
    return $self;
}

### Get/Set methods

#######################################################

=item B<getParentCourseID>

    $string = $obj->getParentCourseID();

    Get the value of the parent_course_id field

=cut

sub getParentCourseID{
    my ($self) = @_;
    return $self->getFieldValue('parent_course_id');
}

#######################################################

=item B<setParentCourseID>

    $obj->setParentCourseID($value);

    Set the value of the parent_course_id field

=cut

sub setParentCourseID{
    my ($self, $value) = @_;
    $self->setFieldValue('parent_course_id', $value);
}


#######################################################

=item B<getChildCaseID>

    $string = $obj->getChildCaseID();

    Get the value of the child_case_id field

=cut

sub getChildCaseID{
    my ($self) = @_;
    return $self->getFieldValue('child_case_id');
}

#######################################################

=item B<setChildCaseID>

    $obj->setChildCaseID($value);

    Set the value of the child_case_id field

=cut

sub setChildCaseID{
    my ($self, $value) = @_;
    $self->setFieldValue('child_case_id', $value);
}


#######################################################

=item B<getSchoolID>

    $string = $obj->getSchoolID();

    Get the value of the school_id field

=cut

sub getSchoolID{
    my ($self) = @_;
    return $self->getFieldValue('school_id');
}

#######################################################

=item B<setSchoolID>

    $obj->setSchoolID($value);

    Set the value of the school_id field

=cut

sub setSchoolID{
    my ($self, $value) = @_;
    $self->setFieldValue('school_id', $value);
}


#######################################################

=item B<getAvailableDate>

    $string = $obj->getAvailableDate();

    Get the value of the available_date field

=cut

sub getAvailableDate{
    my ($self) = @_;
    return $self->getFieldValue('available_date');
}

sub getFormattedAvailableDate {
    my ($self) = @_;
	my $date = $self->getFieldValue('available_date');
	$date =~ s/:\d{2}$//;
	return $date;
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

    $string = $obj->getDueDate();

    Get the value of the due_date field

=cut

sub getDueDate{
    my ($self) = @_;
    return $self->getFieldValue('due_date');
}

sub getFormattedDueDate {
    my ($self) = @_;
	my $date = $self->getFieldValue('due_date');
	$date =~ s/:\d{2}$//;
	return $date;
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

=item B<getSortOrder>

    $string = $obj->getSortOrder();

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

### Other Methods

#######################################################

=item B<lookupByRelation>

    TUSK::Case::LinkCourseUser->lookupByRelation($course_id,$school_id,$case_id);

	Takes the unique combination of course id, school id and case id and
returns the row corresponding if it exists.

=cut

sub lookupByRelation {
	my ($self,$course_id,$school_id,$case_id) = @_;
	my $links = TUSK::Case::LinkCourseCase->lookup(" parent_course_id = $course_id AND school_id = $school_id ".
		" AND child_case_id = $case_id ");
	return pop @{$links};
}

sub getCaseObject{
    my ($self) = @_;
    return $self->getJoinObject('TUSK::Case::Case');
}

sub getCaseTitle{
    my ($self) = @_;
    my $case = $self->getCaseObject();
    return $case->getCaseTitle();
}

sub getCaseType{
    my ($self) = @_;
    my $case = $self->getCaseObject();
    return $case->getCaseType();
}

sub getCaseAuthors{
    my ($self) = @_;
    my $case = $self->getCaseObject();
    return $case->getCaseAuthors();
}

sub getCasePrimaryKeyID{
    my ($self) = @_;
    my $case = $self->getCaseObject();
    return $case->getPrimaryKeyID();
}

sub getCaseStatus{
    my ($self) = @_;
    my $case = $self->getCaseObject();

    return 'Not Posted' unless ($case->getPublishFlag());
    return 'Active &amp; Posted' if ($self->is_active());
    return 'Not Active &amp; Posted';
}

sub is_active{
    # check to see if this content is active
    my $self = shift;

    return 0 if ($self->is_expired() or $self->is_hidden());

    return 1;
}

sub is_hidden{
    # check to see if this content is hidden (not yet active)
    my $self = shift;

    my $now = time();

    if ($self->getAvailableDate()){
        my $available_date = HSDB4::DateTime->new()->in_mysql_date($self->getAvailableDate());
        return 1 if ($now <= $available_date->out_unix_time());
    }
    
    return 0;
}

sub is_expired{
    # check to see if this content has expired (was active at one point)
    my $self = shift;

    my $now = time();

    if ($self->getDueDate()){
        my $end_date = HSDB4::DateTime->new()->in_mysql_date($self->getDueDate());
        return 1 if ($now >= ($end_date->out_unix_time()));
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

