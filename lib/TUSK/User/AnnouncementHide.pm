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


##### NOTE ######
# At some point in the future, when User.pm is no longer using HSDB4::SQLRow,
# User::AnnouncementHide should become a data access object for the User model
#################


package TUSK::User::AnnouncementHide;

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
use HSDB4::SQLRow::User;
use TUSK::Core::School;


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
					'tablename' => 'user_announcement_hide',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'user_announcement_hide_id' => 'pk',
					'user_id' => '',
					'announcement_id' => '',
					'school_id' => '',
					'hide_on' => '',
				    },
				    _attributes => {
					save_history => 1,
					tracking_fields => 0,	
				    },
				    _levels => {
					reporting => '-c',
					error => 0,
				    },
				    @_
				  );
    # Finish initialization...
    return $self;
}

## Get/Set methods ##

sub setUserID {
    my ($self, $value) = @_;
    return $self->setFieldValue('user_id', $value);
}

sub setSchoolID {
    my ($self, $value) = @_;
    return $self->setFieldValue('school_id', $value);
}

sub setAnnouncementID {
    my ($self, $value) = @_;
    return $self->setFieldValue('announcement_id', $value);
}

sub setHideOn {
    my ($self, $value) = @_;
    return $self->setFieldValue('hide_on', $value);
}

sub getSchoolID {
    my ($self) = @_;
    return $self->getFieldValue('user_id');
}

sub getSchoolID {
    my ($self) = @_;
    return $self->getFieldValue('school_id');
}

sub getAnnouncementID {
    my ($self) = @_;
    return $self->getFieldValue('announcement_id');
}

sub getHideOn {
    my ($self) = @_;
    return $self->getFieldValue('hide_on');
}

## Other methods ###

# Return a DateTime object of the hide_on timestamp
sub out_timestamp {
    my $self = shift;
    return HSDB4::DateTime->new->in_mysql_date($self->getHideOn());
}

# Return 1 or 0, depending on if user has unhidden announcements to display
sub user_has_unhidden_announcements {
    my ($user_id) = @_;
	if (scalar keys %{get_nonhidden_announcements_by_school($user_id)}) {
		return 1;
	}
	return 0;
}

# given a user_id, return hash ref of announcements the user has not chosen to hide
# if announcement has been modified since they chose to hide it, it will be included;
# organized by school
sub get_nonhidden_announcements_by_school {
    my ($user_id) = @_;
	my $hidden = get_hidden_announcements_by_school($user_id);
	my $announcements = HSDB4::SQLRow::User->new->lookup_key($user_id)->get_school_announcements();
	my $schoolObj = TUSK::Core::School->new();

	foreach my $school (keys %$announcements) {
		my $school_id = $schoolObj->getSchoolID($school);
		foreach my $ann_id (keys %{$announcements->{$school}}) {
			# is there an entry for this user, school and announcement?
			my $hide_on_timestamp = $hidden->{$school_id}->{$ann_id};
			if (defined $hide_on_timestamp) {
				my $announcement_timestamp = $announcements->{$school}->{$ann_id}->out_timestamp;
				if ($hide_on_timestamp->is_after($announcement_timestamp)) {
					delete($announcements->{$school}->{$ann_id});
				}
			}
 		}
		unless (scalar keys %{$announcements->{$school}}) {
			delete($announcements->{$school});
		}
	}
	
	return $announcements;
}

# given a user_id, return hash ref of announcements they have chosen to hide and, when they
# chose to hide them, in a DateTime object; organized by school
sub get_hidden_announcements_by_school {
    my ($user_id) = @_;
	my $announcements = TUSK::User::AnnouncementHide->new()->lookup("user_id = '$user_id'");
	my %hidden;

	foreach my $annHide (@$announcements) {
		$hidden{$annHide->getSchoolID()}{$annHide->getAnnouncementID()} = $annHide->out_timestamp();
	}

	return \%hidden;
}


1;
