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


package TUSK::Application::Course::User;

use TUSK::Core::HSDB4Tables::User;
use TUSK::Core::HSDB45Tables::LinkUserGroupUser;
use TUSK::Course::User;
use TUSK::Course::User::Site;
use TUSK::Permission::UserRole;
use TUSK::Constants;


sub new {
    my ($class, $args) = @_;

    die "missing course object\n" unless ($args->{course} && ref $args->{course} eq 'HSDB45::Course');

    my $self = {
	course => $args->{course},
	school_db   => $args->{course}->school_db(),
    };

    bless($self, $class);
    return $self;
}
 
sub findUser {
    my ($self, $course_user_id) = @_;
    my $user = TUSK::Core::HSDB4Tables::User->new();

    return $user->lookupReturnOne(undef, undef, undef, undef, [
        TUSK::Core::JoinObject->new('TUSK::Course::User', { joinkey => 'user_id', jointype => 'inner', joincond => "course_user.course_user_id = $course_user_id" }),
        TUSK::Core::JoinObject->new('TUSK::Course::User::Site', { joinkey => 'course_user_id', origkey => 'course_user.course_user_id' }),
        TUSK::Core::JoinObject->new('TUSK::Core::HSDB45Tables::TeachingSite', { database => $self->{school_db}, joinkey => 'teaching_site_id', origkey => 'course_user_site.teaching_site_id'}),
        TUSK::Core::JoinObject->new('TUSK::Permission::UserRole', { joinkey => 'feature_id', origkey => 'course_user.course_user_id' }),		
        TUSK::Core::JoinObject->new('TUSK::Permission::Role', { joinkey => 'role_id', origkey => 'permission_user_role.role_id' }),
        TUSK::Core::JoinObject->new('TUSK::Permission::FeatureType', { joinkey => 'feature_type_id', origkey => 'permission_role.feature_type_id', joincond => "feature_type_token = 'course'" }),
    ]);
}

sub add {
    my ($self, $params) = @_;

    my $school_id = $self->{course}->school_id();
    my $course_id = $self->{course}->primary_key();
    my $user_id = $params->{user_id};
    my $time_period_id = $params->{time_period_id};

    my $course_users = TUSK::Course::User->lookup("school_id = $school_id AND course_id = $course_id AND user_id = '$user_id' AND time_period_id = $time_period_id");
    my $course_user = (scalar @$course_users) ? ${$course_users}[0] : TUSK::Course::User->new();

    unless (scalar @$course_users) {
        $course_user->setFieldValues({
            school_id => $school_id,
            course_id => $course_id,
            user_id => $user_id,
            time_period_id => $time_period_id,
        });
        $course_user->save({user => $params->{author} });
    }

    if (defined $params->{role_id} && $params->{role_id}) {
        _addUserRole($params->{user_id}, $params->{role_id}, $course_user->getPrimaryKeyID(), $params->{author});
    }

    my $virtual_role_ids = (ref $params->{virtual_role_id} eq 'ARRAY') ? $params->{virtual_role_id} : [$params->{virtual_role_id}];
    foreach my $vrole_id (@$virtual_role_ids) {
        _addUserRole($params->{user_id}, $vrole_id, $course_user->getPrimaryKeyID(), $params->{author}) if ($vrole_id);
    }

    my $site_ids = (ref $params->{site_id} eq 'ARRAY') ? $params->{site_id} : [$params->{site_id}];
    foreach my $site_id (@$site_ids) {
        _addUserSite($course_user->getPrimaryKeyID(), $site_id, $params->{author}) if ($site_id);
    }

    $self-> _updateCourseGroups($params, $course_user->getTimePeriodID());
}

sub _addUserRole {
    my ($user_id, $role_id, $course_user_id, $author) = @_;

    my $user_roles = TUSK::Permission::UserRole->lookup("user_id = '$user_id' AND role_id = $role_id AND feature_id = $course_user_id");
    return if (scalar @$user_roles);

    my $user_role = TUSK::Permission::UserRole->new();
    $user_role->setFieldValues({ 
        user_id => $user_id,
        role_id => $role_id,
        feature_id => $course_user_id,
    });
    $user_role->save({user => $author});
}

sub _addUserSite {
    my ($course_user_id, $site_id, $author) = @_;

    my $course_user_sites = TUSK::Course::User::Site->lookup("course_user_id = $course_user_id AND teaching_site_id = $site_id");
    return if (scalar @$course_user_sites);

    my $course_user_site = TUSK::Course::User::Site->new();
    $course_user_site->setFieldValues({
        course_user_id => $course_user_id,
        teaching_site_id => $site_id,
    });
    $course_user_site->save({user => $author});
}

sub _addCourseGroupUser {
    my ($user_id, $group_id) = @_;

    my $group_users = TUSK::Core::HSDB45Tables::LinkUserGroupUser->lookup("parent_user_group_id = $group_id AND child_user_id = $user_id");
    return if (scalar @$group_uses);

    my $group_user = TUSK::Core::HSDB45Tables::LinkUserGroupUser->new();
    $group_user->setDatabase($self->{school_db});
    $group_user->setFieldValues({
	parent_user_group_id => $group_id,
	child_user_id => $user_id,
    });
    $group_user->save();
}

sub edit {
    my ($self, $params) = @_;
    my $user = $self->findUser($params->{course_user_id});
    if (ref $user eq 'TUSK::Core::HSDB4Tables::User') {
	_updateRoles($params, $user);
	_updateUserSites($params, $user->getCourseUserSites());
	$self->_updateCourseGroups({ %$params, user_id => $user->getPrimaryKeyID() }, $user->getCourseUser()->getTimePeriodID());
    }
}

sub _updateRoles {
    my ($params, $user) = @_;
    my %user_roles = map { $_->getRoleID() => $_ } @{$user->getJoinObjects('TUSK::Permission::UserRole')};
    my %user_vroles = ();
    my $user_rrole = undef;

    foreach (@{$user->getJoinObjects('TUSK::Permission::Role')}) {
	if ($_->getVirtualRole()) {
	    $user_vroles{$_->getPrimaryKeyID()} = $user_roles{$_->getPrimaryKeyID()};   ### could be multiple virtual roles
	} else {
    	    $user_rrole = $user_roles{$_->getPrimaryKeyID()};   ### only one real role
	}
    }

    ### update role
    if ($user_rrole) {
	if (defined $params->{role_id}) {
	    if ($params->{role_id} == 0) {  ## DELETE
            $user_rrole->delete({ user => $params->{author} });
	    } else { ## UPDATE
            $user_rrole->setRoleID($params->{role_id});
            $user_rrole->save({ user => $params->{author} });
	    } 
	}
    } else {
        _addUserRole($user->getPrimaryKeyID(), $params->{role_id}, $params->{course_user_id}, $params->{author});
    }

    ### update virtual roles
    my %new_vroles = map { $_ => 1 } grep { defined $_ } ((ref $params->{virtual_role_id} eq 'ARRAY') ? @{$params->{virtual_role_id}} : $params->{virtual_role_id});

    unless (scalar keys %user_vroles) {  ## add
        foreach $new_vrole_id (keys %new_vroles) {
            _addUserRole($user->getPrimaryKeyID(), $new_vrole_id, $user->getCourseUserID(), $params->{author});
        }
    } else {  ## update/delete
        my %to_be_deleted = ();
        my $delete_all = (keys %new_vroles) ? 0 : 1;
        while (my ($key, $user_vrole) = each %user_vroles) {
            if ($delete_all || !exists $new_vroles{$key}) {
                $to_be_deleted{$key} = $user_vrole;
            } 
            delete $new_vroles{$key};
        } 
        ## reuse the rows if possible, or delete if fewer new labels
        foreach my $vrole (values %to_be_deleted) {
            if (my $new_vrole_id = (keys %new_vroles)[0]) {
                $vrole->setRoleID($new_vrole_id);
                $vrole->save({user => $params->{author}});
            } else {
                $vrole->delete({user => $params->{author}});
            }
        }

        ## some new leftover
        foreach $new_vrole_id (keys %new_vroles) {
            _addUserRole($user->getPrimaryKeyID(), $new_vrole_id, $user->getCourseUserID(), $params->{author});
        }
    }
}


sub _updateUserSites {
    my ($params, $course_user_sites) = @_;

    my %new_site_ids = map { $_ => 1 } grep { $_ }  ((ref $params->{site_id} eq 'ARRAY') ? @{$params->{site_id}} : ($params->{site_id}));
    return unless keys %new_site_ids;

    ## update
	foreach my $course_user_site (@$course_user_sites) {
	    my $existing_site_id = $course_user_site->getTeachingSiteID();

        if (exists $new_site_ids{$existing_site_id}) {
            delete $new_site_ids{$existing_site_id};
	    } else {
            $course_user_site->delete({user => $params->{author}});
	    }
    }

    ## add
    foreach $new_site_id (keys %new_site_ids) {
        _addUserSite($params->{course_user_id}, $new_site_id, $params->{author});
    }
}


sub _updateCourseGroups {
    my ($self, $params, $time_period_id) = @_;

    my $pw = $TUSK::Constants::DatabaseUsers{ContentManager}->{writepassword};
    my $un = $TUSK::Constants::DatabaseUsers{ContentManager}->{writeusername};

    my @usergroups = $self->{course}->sub_user_groups($time_period_id); 

    # delete and/or add the usergroups	
    foreach my $group (@usergroups) {
	my $pk = $group->primary_key;
	$params->{"newgroup-$pk"} = 0 unless $params->{"newgroup-$pk"};
	
	if ($params->{"newgroup-" . $pk} ne $params->{"oldgroup-" . $pk}){
		if ($params->{"newgroup-$pk"}){
                        # first delete just to make sure user is not already in the group 
			$group->delete_child_user($un, $pw, $params->{user_id}); 
			$group->add_child_user($un, $pw, $params->{user_id});
		} else {
			$group->delete_child_user($un, $pw, $params->{user_id});
		}
	}
    }
}

sub delete {
    my ($self, $user, $params, $author) = @_;
    my ($rval, $msg) = (0, 'Failed to delete');

    foreach my $course_user_site (@{$user->getCourseUserSites()}) {
	$course_user_site->delete({user => $author});
    }

    foreach my $user_role (@{$user->getUserRoles()}) {
	$user_role->delete({user => $author});
    }
    ## expect new/old group_id(s) in the $params
    $self->_updateCourseGroups($params, $user->getCourseUser()->getTimePeriodID());

    my $course_user = $user->getCourseUser();
    $course_user->delete({user => $author});
    
    ($rval, $msg) = (1, 'Successfully deleted');
    return ($rval, $msg);
}


sub discussions {
    my ($self, $time_period_id) = @_;

    my $board_key = Forum::ForumKey::createBoardKey($school_id, $self->{course}->primary_key, $time_period_id, '%');
    return Forum::Board->lookup("boardkey like '$boardKey' and private = 0", ["pos"] );
}

1;
