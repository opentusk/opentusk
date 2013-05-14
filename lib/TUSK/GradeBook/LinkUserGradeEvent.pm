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


package TUSK::GradeBook::LinkUserGradeEvent;

=head1 NAME

B<TUSK::GradeBook::LinkUserGradeEvent> - Class for manipulating entries in table link_user_grade_event in tusk database

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
use TUSK::GradeBook::GradeMultiple;
use HSDB4::DateTime;
use TUSK::Functions;
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
					'tablename' => 'link_user_grade_event',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'link_user_grade_event_id' => 'pk',
					'parent_user_id' => '',
					'child_grade_event_id' => '',
					'grade' => '',
					'comments' => '',
					'user_group_id' => '',
					'teaching_site_id' => '',
					'coding_code_id' => '',
				    },
				    _attributes => {
					save_history => 1,
					tracking_fields => 1,	
				    },
				    _levels => {
					reporting => 'warn',
					error => 0,
				    },
				    @_
				  );
    # Finish initialization...
    return $self;
}

### Get/Set methods

#######################################################

=item B<getParentUserID>

    $string = $obj->getParentUserID();

    Get the value of the parent_user_id field

=cut

sub getParentUserID{
    my ($self) = @_;
    return $self->getFieldValue('parent_user_id');
}

#######################################################

=item B<setParentUserID>

    $string = $obj->setParentUserID($value);

    Set the value of the parent_user_id field

=cut

sub setParentUserID{
    my ($self, $value) = @_;
    $self->setFieldValue('parent_user_id', $value);
}


#######################################################

=item B<getChildGradeEventID>

    $string = $obj->getChildGradeEventID();

    Get the value of the child_grade_event_id field

=cut

sub getChildGradeEventID{
    my ($self) = @_;
    return $self->getFieldValue('child_grade_event_id');
}

#######################################################

=item B<setChildGradeEventID>

    $string = $obj->setChildGradeEventID($value);

    Set the value of the child_grade_event_id field

=cut

sub setChildGradeEventID{
    my ($self, $value) = @_;
    $self->setFieldValue('child_grade_event_id', $value);
}


#######################################################

=item B<getGrade>

    $string = $obj->getGrade();

    Get the value of the grade field

=cut

sub getGrade{
    my ($self) = @_;
    return $self->getFieldValue('grade');
}

#######################################################

=item B<setGrade>

    $string = $obj->setGrade($value);

    Set the value of the grade field

=cut

sub setGrade{
    my ($self, $value) = @_;
    $self->setFieldValue('grade', $value);
}


#######################################################

=item B<getComments>

    $string = $obj->getComments();

    Get the value of the comments field

=cut

sub getComments{
    my ($self) = @_;
    return $self->getFieldValue('comments');
}

#######################################################

=item B<setComments>

    $string = $obj->setComments($value);

    Set the value of the comments field

=cut

sub setComments{
    my ($self, $value) = @_;
    $self->setFieldValue('comments', $value);
}



#######################################################

=item B<getUserGroupID>

    $string = $obj->getUserGroupID();

    Get the value of the user_group_id field

=cut

sub getUserGroupID{
    my ($self) = @_;
    return $self->getFieldValue('user_group_id');
}

#######################################################

=item B<setUserGroupID>

    $string = $obj->setUserGroupID($value);

    Set the value of the user_group_id field

=cut

sub setUserGroupID{
    my ($self, $value) = @_;
    $self->setFieldValue('user_group_id', $value);
}


#######################################################

=item B<getTeachingSiteID>

    $string = $obj->getTeachingSiteID();

    Get the value of the teaching_site_id field

=cut

sub getTeachingSiteID{
    my ($self) = @_;
    return $self->getFieldValue('teaching_site_id');
}

#######################################################

=item B<setTeachingSiteID>

    $string = $obj->setTeachingSiteID($value);

    Set the value of the teaching_site_id field

=cut

sub setTeachingSiteID{
    my ($self, $value) = @_;
    $self->setFieldValue('teaching_site_id', $value);
}


#######################################################

=item B<getCodingCodeID>

    $string = $obj->getCodingCodeID();

    Get the value of the coding_code_id field

=cut

sub getCodingCodeID{
    my ($self) = @_;
    return $self->getFieldValue('coding_code_id');
}

#######################################################

=item B<setCodingCodeID>

    $string = $obj->setCodingCodeID($value);

    Set the value of the coding_code_id field

=cut

sub setCodingCodeID{
    my ($self, $value) = @_;
    $self->setFieldValue('coding_code_id', $value);
}


=back

=cut

### Other Methods

#######################################################

=item B<lookupByRelation>

    $arrayref = $obj->lookupByRelation($parent_id,$child_id);

   This function returns an arrayref of TUSK::GradeBook::LinkUserGradeEvent objects
that have the parent id and child id specified.  There should be only one entry. 

=cut

sub lookupByRelation{
        my ($self,$user_id,$grade_event_id) = @_; 
        return $self->lookup(" parent_user_id = '$user_id' and child_grade_event_id = '$grade_event_id' ");

}


#######################################################

=item B<getGradeEventObject>

=cut

sub getGradeEventObject {
    my ($self) = @_;
	return $self->getJoinObject("TUSK::GradeBook::GradeEvent");
}



#######################################################

=item B<setFailedGrade>
  somewhat kludgy but set the failed grade
=cut


sub setFailedGrade {
	my ($self, $user_id) = @_;
	my $grade = $self->getGrade();
	return unless $self->getChildGradeEventID();
	return unless $grade;

	if (my $event = TUSK::GradeBook::GradeEvent->lookupKey($self->getChildGradeEventID())) {
		if (my $pass_grade = $event->getPassGrade()) {
			if ((TUSK::Functions::isValidNumber($pass_grade)) && (TUSK::Functions::isValidNumber($grade)) && ($pass_grade > $grade)) {
				if ($self->getPrimaryKeyID()) {
					my $failed_grades = TUSK::GradeBook::GradeMultiple->lookup("link_user_grade_event_id = " . $self->getPrimaryKeyID() . " And grade_type = $TUSK::GradeBook::GradeMultiple::FAILED_GRADETYPE");
					my ($sort_order, $prev_grade);
					if (my $num = scalar @$failed_grades) {
						$sort_order = $num + 1; 
						$prev_grade = $failed_grades->[$num-1]->getGrade();
					} else {
						$sort_order = 1;
					} 

					next if ($prev_grade && $prev_grade eq $grade);
					my $multiple = TUSK::GradeBook::GradeMultiple->new();
					$multiple->setGrade($grade);
					$multiple->setGradeType($TUSK::GradeBook::GradeMultiple::FAILED_GRADETYPE);
					$multiple->setGradeDate(HSDB4::DateTime->new()->out_mysql_timestamp());
					$multiple->setSortOrder($sort_order);
					$multiple->setLinkUserGradeEventID($self->getPrimaryKeyID());
					$multiple->save({ user => $user_id });
				}
			}
		}
	}
}


=item B<delete>
	Override parent method as we possibly need to delete failed grade records prior to delete itself
=cut

sub delete {
    my ($self, $user_hash) = @_;

	my $failed_grades = TUSK::GradeBook::GradeMultiple->lookup("link_user_grade_event_id = " . $self->getPrimaryKeyID() . " And grade_type = $TUSK::GradeBook::GradeMultiple::FAILED_GRADETYPE");

	foreach my $failed_grade (@$failed_grades) {
		$failed_grade->delete($user_hash);
	}

	$self->SUPER::delete($user_hash);
}

sub getGradeMultipleObjects {
    my ($self) = @_;
	return $self->getJoinObjects("TUSK::GradeBook::GradeMultiple");
}


#######################################################

=item B<getGradeEventUserData>

=cut

sub getGradeEventUsers {
    my ($self, $school_id, $grade_type_id, $time_period_ids, $course_ids) = @_;

	my $sth = $self->databaseSelect(qq(
		SELECT
			user_id,
			firstname,
			lastname
		FROM
			hsdb4.user,
			tusk.link_user_grade_event,
			tusk.grade_event
		WHERE
			school_id = ? AND
			grade_event_type_id = ? AND
			parent_user_id = user_id AND
			grade_event_id = child_grade_event_id AND
			time_period_id IN(?) AND
			course_id IN (?)
		GROUP BY
			user_id
		ORDER BY
			lastname;
	), $school_id, $grade_type_id, $time_period_ids, $course_ids);

	my $data;

	while (my($user_id, $firstname, $lastname) = $sth->fetchrow_array()) {
		push @$data, {$user_id => $firstname . ' ' . $lastname};
	}
	return $data;
}


# user_id => {
#				name => 'First Last',
#				time_period_id => {
#					course_id => grade,
#					course_id => grade
#				},
#				time_period_id => {
#					course_id => grade,
#					course_id => grade
#				}
#			 },
#			.....
#

	sub getGradeEventData {
    my ($self, $school_id, $grade_type_id, $time_period_ids, $course_ids, $student_ids) = @_;

	my $sth = $self->databaseSelect("
		SELECT
			user_id,
			firstname,
			lastname,
			time_period_id,
			course_id,
			grade
		FROM
			hsdb4.user,
			tusk.link_user_grade_event,
			tusk.grade_event
		WHERE
			school_id = $school_id AND
			grade_event_type_id = $grade_type_id AND
			parent_user_id = user_id AND
			grade_event_id = child_grade_event_id AND
			time_period_id IN($time_period_ids) AND
			course_id IN ( $course_ids) AND
			user_id IN ($student_ids)
		ORDER BY
			lastname;
	");													## TODO: get to work with parameters
	
	my %tmpHash;

	while (my($user_id, $firstname, $lastname, $time_period_id, $course_id, $grade) = $sth->fetchrow_array()) {	
		if (exists $tmpHash{$user_id}) {
			push (@{$tmpHash{$user_id}{$time_period_id}}, {$course_id => $grade});
		}
		else {
			$tmpHash{$user_id}{firstname} = $firstname;
			$tmpHash{$user_id}{lastname} = $lastname;
			push (@{$tmpHash{$user_id}{$time_period_id}}, {$course_id => $grade});
		}
	}

	my @data = sort { $a->{lastname} cmp $b->{lastname} } values %tmpHash;


	return \@data;
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

