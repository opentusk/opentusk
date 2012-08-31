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


package TUSK::ProcessTracker::ProcessTracker;

=head1 NAME

B<TUSK::ProcessTracker::ProcessTracker> - Class for manipulating entries in table process_tracker in tusk database

=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 INTERFACE


=head2 GET/SET METHODS

=over 4

=cut

use strict;
use Carp;

BEGIN {
    require Exporter;
    require TUSK::Core::SQLRow;

    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
    
    @ISA = qw(TUSK::Core::SQLRow Exporter);
    @EXPORT = qw( );
    @EXPORT_OK = qw( );
}

use vars @EXPORT_OK;

use TUSK::ProcessTracker::Type;
use TUSK::ProcessTracker::StatusType;
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
					'tablename' => 'process_tracker',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'process_tracker_id' => 'pk',
					'school_id' => '',
					'object_id' => '',
					'process_tracker_type_id' => '',
					'process_tracker_status_type_id' => '',
				    },
				    _attributes => {
					save_history => 1,
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

=item B<getSchoolID>

my $string = $obj->getSchoolID();

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

=item B<getObjectID>

my $string = $obj->getObjectID();

Get the value of the object_id field

=cut

sub getObjectID{
    my ($self) = @_;
    return $self->getFieldValue('object_id');
}

#######################################################

=item B<setObjectID>

$obj->setObjectID($value);

Set the value of the object_id field

=cut

sub setObjectID{
    my ($self, $value) = @_;
    $self->setFieldValue('object_id', $value);
}


#######################################################

=item B<getProcessTrackerTypeID>

my $string = $obj->getProcessTrackerTypeID();

Get the value of the process_tracker_type_id field

=cut

sub getProcessTrackerTypeID{
    my ($self) = @_;
    return $self->getFieldValue('process_tracker_type_id');
}

#######################################################

=item B<setProcessTrackerTypeID>

$obj->setProcessTrackerTypeID($value);

Set the value of the process_tracker_type_id field

=cut

sub setProcessTrackerTypeID{
    my ($self, $value) = @_;
    $self->setFieldValue('process_tracker_type_id', $value);
}


#######################################################

=item B<getProcessTrackerStatusTypeID>

my $string = $obj->getProcessTrackerStatusTypeID();

Get the value of the process_tracker_status_type_id field

=cut

sub getProcessTrackerStatusTypeID{
    my ($self) = @_;
    return $self->getFieldValue('process_tracker_status_type_id');
}

#######################################################

=item B<setProcessTrackerStatusTypeID>

$obj->setProcessTrackerStatusTypeID($value);

Set the value of the process_tracker_status_type_id field

=cut

sub setProcessTrackerStatusTypeID{
    my ($self, $value) = @_;
    $self->setFieldValue('process_tracker_status_type_id', $value);
}



=back

=cut

### Other Methods



#######################################################

=item B<getTrackerType>

$obj->getTrackerType();

Get the token value for the process_tracker_type_id field

=cut

sub getTrackerType{
	my ($self) = @_;

	my $type = TUSK::ProcessTracker::Type->lookupKey($self->getProcessTrackerTypeID());

	return $type->getToken() if defined $type;
}


#######################################################

=item B<setTrackerType>

$obj->setTrackerType($token);

Set the value of the process_tracker_type_id field by looking 
up id of type in tusk.process_tracker_type using supplied token.

=cut

sub setTrackerType{
	my ($self, $token) = @_;

	my $type = TUSK::ProcessTracker::Type->new()->lookupReturnOne("token='$token'");

	confess "No process tracker type found with token: '$token'" unless defined $type;

	$self->setProcessTrackerTypeID($type->getPrimaryKeyID());
}


#######################################################

=item B<getStatusLabel>

my $str = $obj->getStatusLabel();

Get the string representation of the value stored in process_tracker_status_type_id field

=cut

sub getStatusLabel{
	my ($self) = @_;

	my $status_type_id = $self->getProcessTrackerStatusTypeID();
	my $status_type = TUSK::ProcessTracker::StatusType->new()->lookupKey($status_type_id);

	return $status_type->getLabel();
}


#######################################################

=item B<getStatus>

my $str = $obj->getStatus();

Get the token of the value stored in process_tracker_status_type_id field

=cut

sub getStatus{
	my ($self) = @_;

	my $status_type_id = $self->getProcessTrackerStatusTypeID();
	my $status_type = TUSK::ProcessTracker::StatusType->new()->lookupKey($status_type_id);

	return $status_type->getToken();
}


#######################################################

=item B<setStatus>

$obj->setStatus($token);

Set the value of the process_tracker_status_type_id field by looking 
up id of status_type in tusk.process_tracker_status_type using 
supplied token.

=cut

sub setStatus{
    my ($self, $token) = @_;

	my $type = TUSK::ProcessTracker::StatusType->new()->lookupReturnOne("token='$token'");

	confess "No process tracker status type found with token: '$token'" unless defined $type;

    $self->setProcessTrackerStatusTypeID($type->getPrimaryKeyID());
}


#######################################################

=item B<getMostRecentTracker>

my $obj = $obj->getMostRecentTracker($school_id, $obj_id, $token);

Given the object's school_id, primary key, and tracker_type token return that 
object's most recent process tracker.

=cut

sub getMostRecentTracker{
	my ($self, $school_id, $obj_id, $token) = @_;

	my $type = TUSK::ProcessTracker::Type->new()->lookupReturnOne("token='$token'");

	confess "No process tracker type found with token: '$token'" unless defined $type;

	my $cond = "object_id=$obj_id and process_tracker_type_id=" . $type->getPrimaryKeyID();
	$cond .= " and school_id=$school_id" if $school_id;
	my $tracker = TUSK::ProcessTracker::ProcessTracker->lookupReturnOne($cond, ['process_tracker_id desc']);

	return $tracker;
}


#######################################################

=item B<isCompleted>

my $int = $obj->isCompleted();

Object can determine if its status is one that would
deem the process_tracker receipt closed/completed.

=cut

sub isCompleted{
	my ($self) = @_;

	my %complete_status_regex = ( tuskdoc     => 'completed|error', 
	                            );

	my $type = $self->getTrackerType();
	if ($self->getStatus() =~ /$complete_status_regex{$type}/i) {
		return 1;
	}
	else {
		return 0;
	}
}


#######################################################

=item B<isCompletedSuccessfully>

my $int = $obj->isCompletedSuccessfully();

Object can determine if its status is one that would
deem the process_tracker receipt closed/completed in
a manner that indicates a successful conversion.

=cut

sub isCompletedSuccessfully{
	my ($self) = @_;
	my %complete_status_regex = ( tuskdoc     => 'completed$', 
	                            );

	my $type = $self->getTrackerType();
	if ($self->getStatus() =~ /$complete_status_regex{$type}/i) {
		return 1;
	}
	else {
		return 0;
	}
}


#######################################################

=item B<getRecentByUser>

my $array_ref = $obj->getRecentByUser($proc_type, $user_id, $school_id, $num_days);

Return all processes that match the supplied process type and user id 
(optionally for the specified school) and have occurred in the supplied
number of days. If no arg supplied for number of days, just return
relevant processes from all time.


=cut

sub getRecentByUser {
	my ($self, $proc_type, $user_id, $school_id, $num_days) = @_;

	my $type_obj = TUSK::ProcessTracker::Type->new()->lookupReturnOne("token='$proc_type'");

	my $cond= "created_by='$user_id' and process_tracker_type_id='" . $type_obj->getPrimaryKeyID() . "'";

	my $time_cond = '';
	if (defined $num_days) {
		my $compare_date = HSDB4::DateTime->new();
		$compare_date->subtract_days($num_days);

		$time_cond = " and modified_on > '" . $compare_date->out_mysql_timestamp() . "'";
	}
	
	$cond .= $time_cond;

	$cond .= " and school_id=$school_id" if $school_id;

	return TUSK::ProcessTracker::ProcessTracker->lookup($cond, ['process_tracker_id desc']);
}


#######################################################

=item B<getDistinctRecentByUser>

my $array_ref = $obj->getDistinctRecentByUser($proc_type, $user_id, $school_id, $num_days);

Return processes that match the supplied process type and user id 
and have occurred in the supplied number of days. If no arg supplied
for number of days, just return relevant processes from all time.
The processes returned will be distinct by object_id - only the
latest record for the distinct object_ids returned.


=cut

sub getDistinctRecentByUser {
	my ($self, $proc_type, $user_id, $school_id, $num_days) = @_;

	my $processes = $self->getRecentByUser($proc_type, $user_id, $school_id, $num_days);

	my %seen;
	my @ret = grep { ++$seen{$_->getObjectID()} == 1 } @$processes;

	return \@ret;
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

