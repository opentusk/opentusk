#!/usr/bin/perl

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

#
# Polulates course_user, course_user_site, permission_feature_type,
# permission_role, permission_user_role tables in tusk database based on
# link_course_user and link_course_student tables in hsdb45_*_admin
# databases.
#
# course_user table has a non-null field for time period, but link_course_user
# tables do not have such data. So, link_course_student tables are consulted to
# deduce the information. But, the result is not perfect.
#
# Permission related tables are used to build role info. course_user table
# simply references permission_user_role table.
#
# This script should be idempotent. Otherwise, it's a bug.
#

use strict;
use warnings;
use lib qw(lib);
use Zoo::DB;

our $DB_NAME = $ENV{DB_NAME}; # database name

main();

sub main {

	defined $DB_NAME or die "DB_NAME not defined\n";

	my $db_name = $DB_NAME;
	my ($db, $stash);

	$db = Zoo::DB->new
	(
		host => $ENV{DB_HOST},
		uid  => $ENV{DB_UID},
		pwd  => $ENV{DB_PWD},
		attr => {
			PrintWarn  => 0,
			PrintError => 0,
			RaiseError => 0,
		},
	);
	$db->error and die $db->error;

	$stash = $db->stash;
	$stash->now = $db->now_str;

	# get schools
	$db->select(qq# SELECT school_id, school_db FROM tusk.school ORDER BY school_id #);
	$db->error and die $db->error;
	$stash->school = $db->result_array_of_hashes;

	# collect role names
	$stash->role_name = # prescribed roles
	[
		'Director', 'Manager', 'Student Manager', 'Site Director', 'Editor', 'Author', 'Student Editor',
		'Lecturer', 'Instructor', 'Lab Instructor', 'Librarian', 'MERC Representative', 'Teaching Assistant',
		'Attending', 'Resident' # new
	];
	for my $x (@{$stash->school}) # custom roles
	{
		$db->column_info($x->{school_db}, 'link_course_user', 'roles');
		$db->error and die $db->error;
		push @{$stash->role_name}, @{$db->result_hashref('COLUMN_NAME')->{roles}{mysql_values}};
	}
	{
		# deduplicate role names
		my $c = {};
		@{$stash->role_name} = map { $c->{$_}++ ? () : $_ } @{$stash->role_name};
	}

	# make role tokens
	$stash->role_token = {}; # name => token
	($stash->role_token->{$_} = lc()) =~ tr/ /_/ for @{$stash->role_name};
	
	# real roles - the rest is just lables
	$stash->real_role = { map { ($_, 1) } qw(director manager student_manager site_director editor author student_editor) };
	
	#
	# permission_feature_type table:
	# retrive feature_type_id for feature_type_token = 'course'.
	# create if missing.
	#
	{
		# retrieve 
		$db->select(qq# select feature_type_id from $db_name.permission_feature_type where feature_type_token = 'course'#);
		$db->error and die $db->error;
		my $r = $db->result_arrayref;
		@$r == 1 and $stash->feature_type_id = $r->[0][0], last;
		@$r >  1 and die "There are @{[scalar(@$r)]} records with feature_type_token='course'"; # something went very wrong
		# insert
		$db->insert_hash("$db_name.permission_feature_type", {
			feature_type_token => 'course',
			feature_type_desc  => 'Course Permission',
			created_by  => 'script',
			created_on  => $stash->now,
			modified_by => 'script',
			modified_on => $stash->now,
		});
		$db->error and die $db->error;
		redo;
	}

	#
	# permission_role table:
	# retrieve role tokens for role names.
	# create if missing.
	#
	{
		$stash->role_id = {}; # token => id 
		# retrieve
		$db->select(qq# select role_token, role_id from $db_name.permission_role where feature_type_id=@{[$stash->feature_type_id]} #);
		$db->error and die $db->error;
		$stash->role_id->{$_->[0]} = $_->[1] for @{$db->result_arrayref};
		last if keys(%{$stash->role_id}) == @{$stash->role_name};
		# insert missing
		for my $x (@{$stash->role_name}) {
			my $y = $stash->role_token->{$x};
			next if exists $stash->role_id->{$y};
			$db->insert_hash("$db_name.permission_role", {
				role_token      => $y,
				role_desc       => $x,
				feature_type_id => $stash->feature_type_id,
				virtual_role    => 0 + ! (exists $stash->real_role->{$y}),
				created_by      => 'script',
				created_on      => $stash->now,
				modified_by     => 'script',
				modified_on     => $stash->now,
			});
			$db->error and die $db->error;
		}
		redo;
	}

	#
	# populate tusk.course_user, tusk.course_user_site, and tusk.permission_user_role.
	# left join link_course_user and link_course_student to deduce time period info.
	# this deduction may generate a lot of spurious rows with NULL time_period_id.
	# 

	$stash->data = [];
	for my $x (@{$stash->school})
	{
		$db->select(qq#
			select distinct
				$x->{school_id} as school_id,
				A.parent_course_id as course_id,
				A.child_user_id as user_id,
				B.time_period_id as time_period_id,
				A.teaching_site_id teaching_site_id,
				A.sort_order as sort_order,
			    A.roles as roles
			from
				$x->{school_db}.link_course_user as A
				left join
				$x->{school_db}.link_course_student as B
				on A.parent_course_id = B.parent_course_id and A.teaching_site_id = B.teaching_site_id
			order by
				A.parent_course_id, A.child_user_id, B.time_period_id, A.teaching_site_id
		#);
		$db->error and die $db->error;
		push @{$stash->data}, @{$db->result_array_of_hashes};
	}

	for my $x (@{$stash->data})
	{
		$x->{time_period_id} = 0 unless defined $x->{time_period_id};
		$x->{created_by} = $x->{modified_by} = 'script';
		$x->{created_on} = $x->{modified_on} = $stash->now;
		$x->{role_ids}   = [ map { $stash->role_id->{$_} } map { $stash->role_token->{$_} } split ',', $x->{roles} ];
	}

	# tusk.course_user table
	$stash->dup = {};
	for my $x (@{$stash->data})
	{
		my $key = join ':', map { $x->{$_} } qw(school_id course_id user_id time_period_id);
		if (exists $stash->dup->{$key}) {
			# duplicate with different teaching site
			$x->{course_user_id} = $stash->dup->{$key};			
			next;
		}
		$db->insert_hash("$db_name.course_user", {
			map { ($_, $x->{$_}) } qw(
				school_id course_id user_id time_period_id sort_order
				created_by created_on modified_by modified_on
			)
		} );
		$db->error and die $db->error;
		$x->{course_user_id} = $stash->dup->{$key} = $db->_last_insert_id;
	}

	# tusk.course_user_site table
	for my $x (@{$stash->data})
	{
		$db->insert_hash("$db_name.course_user_site", {
			map { ($_, $x->{$_}) } qw(
				course_user_id teaching_site_id
				created_by created_on modified_by modified_on
			)
		} );
		$db->error and die $db->error;
	}

	# tusk.permission_user_role
	$stash->dup = {};
	for my $x (@{$stash->data})
	{
		my $key = $x->{course_user_id};
		if (exists $stash->dup->{$key}) {
			# duplicates should have the same role
			next;
		}
		for (@{$x->{role_ids}})
		{
			$db->insert_hash("$db_name.permission_user_role", {
				feature_id => $x->{course_user_id},
				role_id => $_,
				map { ($_, $x->{$_}) } qw(
					user_id
					created_by created_on modified_by modified_on
				)
			} );
			$db->error and die $db->error;
		}
		$stash->dup->{$key}++;
	};

}

#
