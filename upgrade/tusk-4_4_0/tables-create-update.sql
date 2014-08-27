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


alter table `permission_role` add column `virtual_role` tinyint unsigned not null default 0 after `feature_type_id`;
alter table `permission_role_history` add column `virtual_role` tinyint unsigned not null default 0 after `feature_type_id`;


create table if not exists course_user (
	course_user_id int unsigned not null auto_increment,
	school_id int unsigned not null,
	time_period_id int unsigned not null,
	course_id int unsigned not null, 
	user_id varchar(80) not null,
	sort_order smallint unsigned not null default 65535,
	created_by varchar(24) default null,
	created_on datetime default null,
	modified_by varchar(24) default null,
	modified_on datetime default null,
	primary key (course_user_id),
	key (school_id),
	key (time_period_id),
	key (course_id),
	key (user_id)
) engine=InnoDB default charset=utf8;

create table if not exists course_user_history (
	course_user_history_id int unsigned not null auto_increment,
	course_user_id int unsigned not null,
	school_id int unsigned not null,
	time_period_id int unsigned not null,
	course_id int unsigned not null, 
	user_id varchar(80) not null,
	sort_order smallint unsigned not null default 65535,
	created_by varchar(24) default null,
	created_on datetime default null,
	modified_by varchar(24) default null,
	modified_on datetime default null,
	history_action enum('Insert', 'Update', 'Delete') default null,
	primary key (course_user_history_id)
) engine=InnoDB default charset=utf8;

create table if not exists course_user_site (
	course_user_site_id int unsigned not null auto_increment,
	course_user_id int unsigned not null,
	teaching_site_id int unsigned not null,
	sort_order smallint unsigned not null default 65535,
	created_by varchar(24) default null,
	created_on datetime default null,
	modified_by varchar(24) default null,
	modified_on datetime default null,
	primary key (course_user_site_id),
	key (course_user_id),
	key (teaching_site_id)
) engine=InnoDB default charset=utf8;

create table if not exists course_user_site_history (
	course_user_site_history_id int unsigned not null auto_increment,
	course_user_site_id int unsigned not null,
	course_user_id int unsigned not null,
	teaching_site_id int unsigned not null,
	sort_order smallint(6) unsigned not null,
	created_by varchar(24) default null,
	created_on datetime default null,
	modified_by varchar(24) default null,
	modified_on datetime default null,
	history_action enum('Insert', 'Update', 'Delete') default null,
	primary key (course_user_site_history_id)
) engine=InnoDB default charset=utf8;


INSERT INTO permission_feature_type VALUES (0, 'course', 'Course permission', 'script', now(), 'script', now());

INSERT INTO permission_role VALUES 
(0, 'director', 'Director', last_insert_id(), 0, 'script', now(), 'script', now()),
(0, 'site_director', 'Site Director', last_insert_id(), 0, 'script', now(), 'script', now()),
(0, 'manager', 'Manager', last_insert_id(), 0, 'script', now(), 'script', now()),
(0, 'student_manager', 'Student Manager', last_insert_id(), 0, 'script', now(), 'script', now()),
(0, 'editor', 'Editor', last_insert_id(), 0, 'script', now(), 'script', now()),
(0, 'author', 'Author', last_insert_id(), 0, 'script', now(), 'script', now()),
(0, 'student_editor', 'Student Editor', last_insert_id(), 0, 'script', now(), 'script', now()),
(0, 'lecturer', 'Lecturer', last_insert_id(), 1, 'script', now(), 'script', now()),
(0, 'instructor', 'Instructor', last_insert_id(), 1, 'script', now(), 'script', now()),
(0, 'lab_instructor', 'Lab Instructor', last_insert_id(), 1, 'script', now(), 'script', now()),
(0, 'librarian', 'Librarian', last_insert_id(), 1, 'script', now(), 'script', now()),
(0, 'merc_representative', 'MERC Representative', last_insert_id(), 1, 'script', now(), 'script', now()),
(0, 'teaching_assistant', 'Teaching Assistant', last_insert_id(), 1, 'script', now(), 'script', now()),
(0, 'attending', 'Attending', last_insert_id(), 1, 'script', now(), 'script', now()),
(0, 'resident', 'Resident', last_insert_id(), 1, 'script', now(), 'script', now())
;
