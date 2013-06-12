# Copyright 2013 Albert Einstein College of Medicine of Yeshiva University 
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

package TUSK::Manage::Course::Users2;

# This replaces TUSK::Manage::Course::User

use strict;
use warnings;
use Carp ();

use HSDB45::Course;
use TUSK::Constants;
use TUSK::Core::HSDB4Tables::User;
use TUSK::Core::HSDB45Tables::Course;
use TUSK::Core::HSDB45Tables::LinkCourseTeachingSite;
use TUSK::Core::HSDB45Tables::TeachingSite;
use TUSK::Core::HSDB45Tables::TimePeriod;
use TUSK::Core::JoinObject;
use TUSK::Core::School;
use TUSK::Course::User;
use TUSK::Permission::UserRole;
use TUSK::Permission::Role;
use TUSK::Permission::FeatureType;

sub new
{
	my $this = shift;
	$this = bless { @_ }, ref $this || $this;
	return $this;
}

####################################################################################################

sub get_school # ({school_id|school_name|school_db|school_display})
{
	# returns the first matching TUSK::Core::School object, or undef
	my ($this, $search) = @_;
	if ($search =~ /^\d+$/) {
		for my $school (@{TUSK::Core::School->new->lookup}) {
			$school->getFieldValue($_) == $search and return $school for qw(school_id);
		}
	} else {
		$search = lc $search;
		for my $school (@{TUSK::Core::School->new->lookup}) {
			lc($school->getFieldValue($_)) eq $search and return $school for qw(school_name school_db school_display);
		}
	}
	return;
}

sub get_school_db   { return $_ && $_->getFieldValue('school_db')   for get_school(@_) }
sub get_school_id   { return $_ && $_->getFieldValue('school_id')   for get_school(@_) }
sub get_school_name { return $_ && $_->getFieldValue('school_name') for get_school(@_) }

####################################################################################################

sub get_all_roles_and_labels
{
	# returns a reference to an array of objects of TUSK::Permission::Role
	my ($this) = @_;
	my $role = TUSK::Permission::Role->new;
	$role->lookup(
		"permission_feature_type.feature_type_token = 'course'",
		undef, undef, undef,
		[
			# tusk.permission_feature_type: feature type detail (one)
			TUSK::Core::JoinObject->new(
				'TUSK::Permission::FeatureType',
				{
					joinkey => 'feature_type_id',
					origkey => 'permission_role.feature_type_id',
				}
			),
		]
	);
}

####################################################################################################

sub get_all_courses # (school)
{
	# returns a reference to an array of objects of TUSK::Core::HSDB45Tables::Course
	my ($this, $school) = @_;
	my ($school_db, $course);
	$school_db = $this->get_school_db($school) or Carp::croak "invalid school '$school'";
	$course = TUSK::Core::HSDB45Tables::Course->new(database => $school_db);
	$course->lookup();
}

sub get_course # (school, course_id)
{
	# returns an object of TUSK::Core::HSDB45Tables::Course
	my ($this, $school, $id) = @_;
	my ($school_db, $course);
	$school_db = $this->get_school_db($school) or Carp::croak "invalid school '$school'";
	$course = TUSK::Core::HSDB45Tables::Course->new(database => $school_db);
	$course->lookupKey($id);
}

sub get_course_teaching_sites # (school, course_id)
{
	# returns a reference to an array of objects of TUSK::Core::HSDB45Tables::LinkCourseTeachingSite
	my ($this, $school, $course_id) = @_;
	my $school_db = $this->get_school_db($school) or Carp::croak "invalid school '$school'";
	my $course = TUSK::Core::HSDB45Tables::LinkCourseTeachingSite->new(database => $school_db);
	$course->lookup(
		"parent_course_id=$course_id", undef, undef, undef,
		[
			# hsdb45_*_admin.teaching_site: teaching site detail (one)
			TUSK::Core::JoinObject->new(
				'TUSK::Core::HSDB45Tables::TeachingSite',
				{
					database => $school_db,
					joinkey  => 'teaching_site_id',
					origkey  => 'link_course_teaching_site.child_teaching_site_id',
				}
			),

		],
	);
}

sub get_course_and_all_related # (school, course_id, [time_period_id], [teaching_site_id])
{
	# returns an object of TUSK::Core::HSDB45Tables::Course, or undef. This
	# object is complete with all related objects. So, no further join shoule
	# be necessary. For the exact structure, see TUSK::Core::SQLRow.
	#
	my ($this, $school, $course_id, $time_period_id, $teaching_site_id) = @_;
	my ($school_db, $school_id, $course, $result);
	my $xtra_condition = '';
	for ($this->get_school($school))
	{
		defined() or Carp::croak "invalid school '$school'";
		$school_db = $_->getFieldValue('school_db');
		$school_id = $_->getFieldValue('school_id');
	}
	$course = TUSK::Core::HSDB45Tables::Course->new(database => $school_db);
	$xtra_condition .= " and course_user.time_period_id = '$time_period_id'" if defined $time_period_id;
	$xtra_condition .= " and course_user_site.teaching_site_id = '$teaching_site_id'" if defined $teaching_site_id;
	$result = $course->lookup(
		# $cond, \@order_by, \@field, $limit, \@(TUSK::Core::JoinObject)
		join(' and ',
			"course.course_id=$course_id",
			"course_user.school_id=$school_id",
			"(permission_feature_type.feature_type_token = 'course' or permission_feature_type.feature_type_token is null)",
		) . $xtra_condition,
		undef, undef, undef,
		[
			# tusk.course_user: course users (many)
			TUSK::Core::JoinObject->new(
				'TUSK::Course::User',
				{
					joinkey => 'course_id',
					origkey => 'course_id',
				}
			),
			# hsdb4.user: user detail (one)
			TUSK::Core::JoinObject->new(
				'TUSK::Core::HSDB4Tables::User',
				{
					joinkey => 'user_id',
					origkey => 'course_user.user_id',
					objtree => ['TUSK::Course::User'],
				}
			),
			# hsdb45_*_admin.time_period: time period detail (one)
			TUSK::Core::JoinObject->new(
				'TUSK::Core::HSDB45Tables::TimePeriod',
				{
					database => $school_db,
					joinkey  => 'time_period_id',
					origkey  => 'course_user.time_period_id',
					objtree  => ['TUSK::Course::User'],
				}
			),
			# tusk.course_user_site: user's teaching sites (many)
			TUSK::Core::JoinObject->new(
				'TUSK::Course::User::Site',
				{
					joinkey => 'course_user_id',
					origkey => 'course_user.course_user_id',
					objtree => ['TUSK::Course::User'],
				}
			),
			# hsdb45_*_admin.teaching_site: teaching site detail (one)
			TUSK::Core::JoinObject->new(
				'TUSK::Core::HSDB45Tables::TeachingSite',
				{
					database => $school_db,
					joinkey  => 'teaching_site_id',
					origkey  => 'course_user_site.teaching_site_id',
					objtree  => ['TUSK::Course::User', 'TUSK::Course::User::Site'],
				}
			),
			# tusk.permission_user_role: user's roles (many)
			# feature_id references couese_user.course_user_id
			TUSK::Core::JoinObject->new(
				'TUSK::Permission::UserRole',
				{
					joinkey => 'feature_id',
					origkey => 'course_user.course_user_id',
					objtree => ['TUSK::Course::User'],
				}
			),
			# tusk.permission_role: role detail (one)
			# we need roles whose feature_type_id corresponds to feature_type_token = 'course'
			TUSK::Core::JoinObject->new(
				'TUSK::Permission::Role',
				{
					joinkey => 'role_id',
					origkey => 'permission_user_role.role_id',
					objtree => ['TUSK::Course::User', 'TUSK::Permission::UserRole'],
				}
			),
			# tusk.permission_feature_type: feature type detail (one)
			# this is necessary to pick only feature_type_token = 'course'
			TUSK::Core::JoinObject->new(
				'TUSK::Permission::FeatureType',
				{
					joinkey => 'feature_type_id',
					origkey => 'permission_role.feature_type_id',
					objtree => ['TUSK::Course::User', 'TUSK::Permission::UserRole', 'TUSK::Permission::Role'],
				}
			),
		],
	);
	return $result->[0]; # there should be at most one
}

####################################################################################################

sub get_course_user # (course_user_id)
{
	my ($this, $course_user_id) = @_;
	my $course_user = TUSK::Course::User->new;
	$course_user->lookupKey($course_user_id);
	return $course_user;
}

sub get_course_user_and_all_related # (course_user_id)
{
	my ($this, $course_user_id) = @_;
	my ($course_user, $school_db, $result);
	$course_user = TUSK::Course::User->new;
	return undef unless $course_user->lookupKey($course_user_id);
	$school_db = $this->get_school_db($course_user->getFieldValue('school_id'));
	$course_user = TUSK::Course::User->new;
	$result = $course_user->lookup(
		# $cond, \@order_by, \@field, $limit, \@(TUSK::Core::JoinObject)
		"course_user.course_user_id='$course_user_id'",
		undef, undef, undef,
		[
			# RELATED
			# tusk.course_user_site: user's teaching sites
			TUSK::Core::JoinObject->new(
				'TUSK::Course::User::Site',
				{
					joinkey => 'course_user_id',
					origkey => 'course_user.course_user_id',
				}
			),
			# tusk.permission_user_role: user's roles
			TUSK::Core::JoinObject->new(
				'TUSK::Permission::UserRole',
				{
					joinkey => 'feature_id',
					origkey => 'course_user.course_user_id',
				}
			),
			# DETAILS
			# hsdb4.user: user detail
			TUSK::Core::JoinObject->new(
				'TUSK::Core::HSDB4Tables::User',
				{
					joinkey => 'user_id',
					origkey => 'course_user.user_id',
				}
			),
			# hsdb45_*_admin.time_period: time period detail
			TUSK::Core::JoinObject->new(
				'TUSK::Core::HSDB45Tables::TimePeriod',
				{
					database => $school_db,
					joinkey  => 'time_period_id',
					origkey  => 'course_user.time_period_id',
				}
			),
			# hsdb45_*_admin.teaching_site: teaching site detail
			TUSK::Core::JoinObject->new(
				'TUSK::Core::HSDB45Tables::TeachingSite',
				{
					database => $school_db,
					joinkey  => 'teaching_site_id',
					origkey  => 'course_user_site.teaching_site_id',
					objtree  => ['TUSK::Course::User::Site'],
				}
			),
			# tusk.permission_role: role detail
			TUSK::Core::JoinObject->new(
				'TUSK::Permission::Role',
				{
					joinkey => 'role_id',
					origkey => 'permission_user_role.role_id',
					objtree => ['TUSK::Permission::UserRole'],
				}
			),
		],
	);
	return $result->[0]; # there should be at most one
}

####################################################################################################
# Helper Methods Like Thosse in TUSK::Manage::Course::User
####################################################################################################

sub show_pre_process # (school, course_id, [time_period_id], [teaching_site_id])
{
	my ($this, $school, $course_id, $time_period_id, $teaching_site_id) = @_;
	my $data = { users => [], usercount => 0, subusercount => 0 };
	my $course = $this->get_course_and_all_related($school, $course_id, $time_period_id, $teaching_site_id); # can be null

	return $data unless $course;

	$data->{users} = $course->getJoinObjects('TUSK::Course::User');
	$data->{usercount} = @{$data->{users}};

	# default ordering from HSDB4::SQLLinkDefinition for hsdb45_*_admin.link_course_user: sort_order, lastname, firstname
	@{$data->{users}} = sort {
		return $_ for grep { $_ } $a->getFieldValue('sort_order') <=> $b->getFieldValue('sort_order');
		my ($x, $y) = map { $_->get_first_join_object('TUSK::Core::HSDB4Tables::User') } ($a, $b);
		return  1 unless defined $x;
		return -1 unless defined $y;
		lc($x->getFieldValue('firstname')) cmp lc($y->getFieldValue('firstname'))
		or lc($x->getFieldValue('lastname')) cmp lc($y->getFieldValue('lastname'));
	} @{$data->{users}}; 

	return $data unless $course->getType eq 'integrated course';

	for ($this->get_subcourse_ids($school, $course_id))
	{
		my $subcourse = $this->get_course_and_all_related($school, $_, $time_period_id, $teaching_site_id) or next; # can be null 
		my $title = $this->course_out_title($subcourse); 
		$data->{subusers}{$title} = $subcourse->getJoinObjects('TUSK::Course::User');
		$data->{subusercount} += @{$data->{subusers}{$title}};
	} 

	return $data;
}

sub addedit_pre_process
{
	my ($this, $course_user_id, $school_name, $course_id, $time_period_id) = @_;
	my $data = {};

	$data->{all_roles} = {};
	for my $x (@{$this->get_all_roles_and_labels}) {
		$data->{all_roles}{$x->getFieldValue('role_token')} = {
			map { ($_ => $x->getFieldValue($_)) } qw(role_id role_token role_desc virtual_role feature_type_id)
		};
	}

	if (defined $course_user_id) { # edit

		my $course_user_obj = $this->get_course_user_and_all_related($course_user_id);
		my $user_obj = $course_user_obj->get_first_join_object('TUSK::Core::HSDB4Tables::User'); # undef if db is messed up
		my $user_roles = $course_user_obj->getJoinObjects('TUSK::Permission::UserRole');

		$school_name = $this->get_school_name($course_user_obj->getFieldValue('school_id'));
		$course_id = $course_user_obj->getFieldValue('course_id');
		$time_period_id = $course_user_obj->getFieldValue('time_period_id');

		$data->{course_user_obj} = $course_user_obj;

		# row 1: user
		$data->{actionref} = {
			usage => 'No'
		};
		$data->{userarray} = [ {
			userid => $course_user_obj->getFieldValue('user_id'),
			name   => $user_obj && join(', ', map { $user_obj->getFieldValue($_) } qw(lastname firstname)),
		} ];

		# row 2: role
		# row 4: labels
		$data->{roles} = {};
		for my $x (@{$user_roles}) {
			my $r = $x->get_first_join_object('TUSK::Permission::Role');
			my $k = $r->getFieldValue('role_token');
			my $v = {};
			$v->{$_} = $x->getFieldValue($_) for qw(user_role_id);
			$v->{$_} = $r->getFieldValue($_) for qw(role_id role_token role_desc virtual_role feature_type_id);
			$data->{roles}{$k} = $v;
		}
		$data->{shownone} = ! grep {
			/^(manager|director|editor|author|student_editor|student_manager|site_director)$/
		} keys %{$data->{roles}};

		# row 3: teaching sites
		$data->{teaching_sites} = $course_user_obj->getJoinObjects('TUSK::Course::User::Site');

		# row 6: submit
		$data->{action} = 'edit';

	} else { # add

		# row 1: user
		$data->{actionref} = {
			usage => 'Yes',
			length => 100,
			functions => [{ func => 'remove', label => 'Delete' }],
		};
		$data->{userarray} = [];

		# row 2: role
		# row 4: labels
		$data->{roles} = {};
		$data->{shownone} = 1;

		# row 3: teaching sites
		$data->{teaching_sites} = [];

		# row 6: submit
		$data->{action} = 'add';

	}

	# row 3: teaching sites
	$data->{all_teaching_sites} = $this->get_course_teaching_sites($school_name, $course_id); # arrayref

	# row 5: group
	$data->{usergroups} = [ $this->get_sub_user_groups($school_name, $course_id, $time_period_id) ];
	$data->{usergroupcount} = @{$data->{usergroups}};

	return $data;
}

sub change_order # (order_spec, \@users)
{
	my ($this, $order, $users) = @_;
	# $order = <current position>-<new position>; position is 1-based
	# $users = $this->show_pre_process->{users}
	return (1, "Order Remains the Same") unless $order;
	my ($current, $new) = map { --$_  } split '-', $order; 
	splice @$users, $new, 0, $_ for splice @$users, $current, 1;
	my $sort_order = 0 ;
	for (@$users)
	{
		$sort_order += 10;
		$_->update(
			"sort_order = $sort_order",
			"course_user_id = @{[$_->getFieldValue('course_user_id')]}",
		) or return (0, 'Unable to Update Order');
	}
	return (1, "Order Successfully Changed");
}

# delete, addedit_users, edit_user, add_user have a lot of repetition due to
# lack of time.  They should be refactored.

sub delete # (course_user_id)
{
	my ($this, $course_user_id) = @_;
	return (1, "No ID Specified") unless defined $course_user_id; # could be 0?
	my $course_user = $this->get_course_user_and_all_related($course_user_id);
	return (1, "No Such User") unless $course_user;
	# SQLRow::delete() returns number of rows affected on success, or croaks
	# on error. So, it's pointless to check the return value.
	for my $related (map { @{$course_user->getJoinObjects($_)} } qw(TUSK::Course::User::Site TUSK::Permission::UserRole))
	{
		$related->delete; 
	}
	$course_user->delete;
	return (1, "User Deleted");
}

sub addedit_users # (course_user_id, school_name, course_id, time_period_id, \%ARGS, \%param)
{
	my ($this, $course_user_id, $school_name, $course_id, $time_period_id, $args, $param) = @_;
	my $school_id = $this->get_school_id($school_name);
	my $users = [ TUSK::Functions::get_users($args) ];
	my ($rval, $msg);
	if ($args->{action} eq 'edit') {
		($rval, $msg) = $this->edit_user($course_user_id, $users->[0], $args, $param);
	} else {
		($rval, $msg) = $this->add_users($school_id, $course_id, $time_period_id, $users, $args, $param);
	}

	return ($rval && 1, $msg);
}

sub edit_user
{
	my ($this, $course_user_id, $user, $args, $param) = @_;
	my $course_user_obj = $this->get_course_user_and_all_related($course_user_id) or return (0, "No course_user entry: $course_user_id");
	my $session_user = $param->{session_user};
	my @param = qw(roles labels teaching_sites);
	my $new = { map { ($_ => {}) } @param };
	my $old = { map { ($_ => {}) } @param };

	# user input
	for my $x (@param) {
		my $y = $args->{$x};
		$y eq '' and next;
		$new->{$x}{$_} = undef for ref($y) eq 'ARRAY' ? @$y : $y; 
	}

	# current data
	for my $x (@{$course_user_obj->getJoinObjects('TUSK::Permission::UserRole')}) {
		my $y = $x->get_first_join_object('TUSK::Permission::Role')->getFieldValue('virtual_role') ? 'labels' : 'roles';
		$old->{$y}{$x->getFieldValue('role_id')} = $x;
	}
	for my $x (@{$course_user_obj->getJoinObjects('TUSK::Course::User::Site')}) {
		$old->{teaching_sites}{$x->getFieldValue('teaching_site_id')} = $x;
	}

	# remove uchanged
	for (@param) {
		my $n = $new->{$_};
		my $o = $old->{$_};
		my $x = {};
		$x->{$_}++ for keys %$n;
		$x->{$_}-- for keys %$o;
		$x = [ grep { !$x->{$_} } keys %$x ];
		delete @{$n}{@$x};
		delete @{$o}{@$x};
	}

	my ($key);

	# There is no point in checking the return value from database operation. SQLRow
	# dies on database error.

	# update roles
	$key = 'roles';
	for my $x (keys %{$old->{$key}}) {
		$old->{$key}{$x}->delete;
	}
	for my $x (keys %{$new->{$key}}) {
		my $o = TUSK::Permission::UserRole->new;
		$o->setFieldValues({
			feature_id => $course_user_obj->getFieldValue('course_user_id'),
			user_id => $course_user_obj->getFieldValue('user_id'),
			role_id => $x,
		});
		$new->{$key}{$x} = $o->save({ user => $session_user });
	}

	# update labels 
	$key = 'labels';
	for my $x (keys %{$old->{$key}}) {
		$old->{$key}{$x}->delete;
	}
	for my $x (keys %{$new->{$key}}) {
		my $o = TUSK::Permission::UserRole->new;
		$o->setFieldValues({
			feature_id => $course_user_obj->getFieldValue('course_user_id'),
			user_id => $course_user_obj->getFieldValue('user_id'),
			role_id => $x,
		});
		$new->{$key}{$x} = $o->save({ user => $session_user });
	}

	# update teaching sites
	$key = 'teaching_sites';
	for my $x (keys %{$old->{$key}}) {
		$old->{$key}{$x}->delete;
	}
	for my $x (keys %{$new->{$key}}) {
		my $o = TUSK::Course::User::Site->new;
		$o->setFieldValues({
			course_user_id => $course_user_obj->getFieldValue('course_user_id'),
			teaching_site_id => $x,
		});
		$new->{$key}{$x} = $o->save({ user => $session_user });
	}

	# user group
	$this->update_user_groups((map { $course_user_obj->getFieldValue($_) } qw(school_id course_id time_period_id)), $args, $user);
	
	return (1, "User Updated");
}

sub add_users
{
	my ($this, $school_id, $course_id, $time_period_id, $users, $args, $param) = @_;;
	my $session_user = $param->{session_user};
	my @param = qw(roles labels teaching_sites);
	my $new = { map { ($_ => {}) } @param };
	my ($rval, $msg);
	my $xtra = {};

	# user input
	for my $x (@param) {
		my $y = $args->{$x};
		$y eq '' and next;
		$new->{$x}{$_} = undef for ref($y) eq 'ARRAY' ? @$y : $y; 
	}

	for (@$users)
	{
		my $user_id = $_->{userid};
		my $course_user_id;
		my ($key, $o, $r, $x);

		# There is no point in checking the return value from database
		# operation. SQLRow dies on database error.

		# remove, if any, esixting course_user(school_id, course_id, user_id, time_period_id)
		# why remove? this is the behavior of the old system.
		$o = TUSK::Course::User->new; 
		$r = $o->lookup("user_id='$user_id' and school_id=$school_id and course_id=$course_id and time_period_id=$time_period_id");
		$this->delete($_->getPrimaryKeyID) for @$r;

		# insert into course_user (school_id, course_id, user_id, time_period_id, created_by)
		$o = TUSK::Course::User->new; 
		$o->setFieldValues({
			user_id => $user_id,
			school_id => $school_id,
			course_id => $course_id,
			time_period_id => $time_period_id,
		});
		$course_user_id = $o->save({ user => $session_user });

		# for each role, insert into permission_user_role (user_id, role_id, feature_id(=course_user_id))
		$key = 'roles';
		for my $x (keys %{$new->{$key}}) {
			my $o = TUSK::Permission::UserRole->new;
			$o->setFieldValues({
				feature_id => $course_user_id,
				user_id => $user_id,
				role_id => $x,
			});
			$o->save({ user => $session_user });
		}

		# for each label, insert into permission_user_role (user_id, role_id, feature_id(=course_user_id))
		$key = 'labels';
		for my $x (keys %{$new->{$key}}) {
			my $o = TUSK::Permission::UserRole->new;
			$o->setFieldValues({
				feature_id => $course_user_id,
				user_id => $user_id,
				role_id => $x,
			});
			$o->save({ user => $session_user });
		}

		# for each teaching site, insert into course_user_site (course_user_id, teaching_site_id)
		$key = 'teaching_sites';
		for my $x (keys %{$new->{$key}}) {
			my $o = TUSK::Course::User::Site->new;
			$o->setFieldValues({
				course_user_id => $course_user_id,
				teaching_site_id => $x,
			});
			$o->save({ user => $session_user });
		}

		# update user_group stuff
		$this->update_user_groups($school_id, $course_id, $time_period_id, $args, $_);
	
	}

	return (1, "User@{[ @$users > 1 ? 's' : '' ]} Added");
}

####################################################################################################
# Ancillaries
####################################################################################################

sub get_subcourse_ids # (school_name, main_course_id)
{
	# I want to use TUSK::Core::HSDB45Tables::Course, but it does not have
	# get_subcourses(), yet.  So, I factored out this piece that relys on the
	# old HSDB45::Course::get_subcourses(). The method is quite involved, and
	# will need some effort to port into TUSK::Core::HSDB45Tables::Course.
	map { $_->course_id } @{HSDB45::Course->new(_school => $_[1])->lookup_key($_[2])->get_subcourses};
}

sub get_sub_user_groups # (school_name, course_id, time_period_id)
{
	# This exists for similar reason for get_subcourse_ids().
	my ($this, $school, $course_id, $time_period_id) = @_;
	HSDB45::Course->new(_school => $_[1])->lookup_key($_[2])->sub_user_groups($_[3]); # list
}

sub update_user_groups
{
	# This exists for similar reason for get_subcourse_ids().
	my ($this, $school_id, $course_id, $time_period_id, $args, $user) = @_;
	my ($un, $pw) = @{$TUSK::Constants::DatabaseUsers{ContentManager}}{qw(writeusername writepassword)};
	my $course = HSDB45::Course->new(_school => $this->get_school_name($school_id))->lookup_key($course_id);
	for ($course->sub_user_groups($time_period_id)) {
		my $pk = $_->primary_key;
		my $ng = $args->{"newgroup-$pk"} || 0;
		my $og = $args->{"oldgroup-$pk"};
		next if $ng eq $og;
		$_->delete_child_user($un, $pw, $user->{pk});
		$ng and $_->add_child_user($un, $pw, $user->{pk});
	}
	return 1;
}

sub course_out_title # (course_obj)
{
	# this is a replication of HSDB45::Course::out_title().
	# course should be an object of TUSK::Core::HSDB45Tables::Course.
	require HTML::Strip;
	my ($this, $course) = @_;
	my ($title, $oea_code) = ($course->getTitle, $course->getOeaCode); 
	return '' unless length $title;
	$title = ucfirst($title);
	$title = substr($title, 0, 50) . '...' if length ($title) > 50;
	if ($oea_code)
	{
		# what's the nature of oea_code? why would you need all this?
		my $stripper = HTML::Strip->new;
		$stripper->set_decode_entities(0);
		$oea_code = $stripper->parse($oea_code);
		utf8::decode($oea_code); # necessary?
		$title .= " ($oea_code)" unless $title =~ /^$oea_code/i;
	}
	return $title;
}

1;
