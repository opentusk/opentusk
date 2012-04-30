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


package TUSK::Import::GradeBook;

use strict;
use base qw(TUSK::Import);
use HSDB4::SQLRow::User;
use TUSK::GradeBook::GradeEvent;
use TUSK::GradeBook::LinkUserGradeEvent;
use Carp;

sub new {
    my ($class) = @_;
    $class = ref $class || $class;
    my $self = $class->SUPER::new();
    $self->set_fields(qw(ID Score Comment));
    return $self;
}


sub processData {
	my ($self,$user_id,$grade_event,$course) = (@_);
	# $user_id is used to identify who is doing the update
	if (!defined($user_id)){
		confess "User ID for the Editor is a required field";
	}
	if (!$grade_event->isa('TUSK::GradeBook::GradeEvent')){
		confess "A grade event object must be passed";
	}
	my $record_count = 0;
	my $courseRoster = $self->getCourseRoster($course,$grade_event->getTimePeriodID());
	my ($link,$user,$score,$parent_user_id,$comment,$grade_event_id,$links);
	foreach my $record ($self->get_records()){
		# $self->add_log('info',$record->get_field_value('ID').':'.$record->get_field_value('Score'));
		$user = $self->findStudent($record->get_field_value('ID'));
		if (!defined($user)){
			next;
		}	
		if (!$self->validStudent($user,$courseRoster)){
			$self->add_log("error","Student ".$user->out_full_name()." (".$record->get_field_value('ID')
				.") is not in the course ".$course->title());
			next;
		}
		$parent_user_id = $user->primary_key();
		$grade_event_id = $grade_event->getPrimaryKeyID();
		$links = TUSK::GradeBook::LinkUserGradeEvent->lookupByRelation($parent_user_id,$grade_event_id);
		if (scalar(@{$links})){
			$link = pop @{$links};
		} else {
			$link = TUSK::GradeBook::LinkUserGradeEvent->new();
			$link->setParentUserID($parent_user_id);
			$link->setChildGradeEventID($grade_event_id);
		}
		if (!defined($record->get_field_value('Score')) ||
			($record->get_field_value('Score') eq "")){
			$score = 0;
		} else {
			$score = $record->get_field_value('Score');	
		}
		if (!defined($record->get_field_value('Comment')) ||
			($record->get_field_value('Comment') eq "")){
			$comment = '';
		} else {
			$comment = $record->get_field_value('Comment');	
		}                
		$link->setGrade($score);
		$link->setComments($comment);
		$link->save({'user'=>$user_id});
		$record_count++;
	}
	$self->add_log("info","There were $record_count records entered");
}

sub findStudent {
	my $self = shift;
	my $input_id = shift;
	my (@users,$user);
	if ($input_id =~ /^\d+$/){
		# it is a numeric id
		@users = HSDB4::SQLRow::User->new->lookup_conditions('sid = '.$input_id);
		if (scalar(@users) > 1){
			$self->add_log("error","There are two users with that ID : $input_id");
			return;
		} elsif (!scalar(@users)){
			$self->add_log("error","There is no user with that ID : $input_id");
			return;
		}
		$user = pop @users;
	} else {
		# it is a UTLN (user_id)
		$user = HSDB4::SQLRow::User->new->lookup_key($input_id);
		if (!defined($user->primary_key())){
                        $self->add_log("error","There is no user with that UTLN : $input_id");
                        return;
		}
	}
	return $user;

}

sub validStudent {
	my ($self,$student,$courseRoster) = @_;

	if(!defined($courseRoster->{$student->primary_key()})){
		return 0;
	}
	return 1;
}


sub getCourseRoster{
	my $self =shift;
	my $course = shift;
	my $time_period_id = shift || confess "Time Period ID is required for getCourseRoster";

	my @users = $course->get_students($time_period_id);
	my %tmpHash = map { ( $_->primary_key(), 1 ) } @users;
	return \%tmpHash;
}
1;
