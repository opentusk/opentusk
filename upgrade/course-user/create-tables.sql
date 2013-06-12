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

/***

* default integer display size is 10
* default smallint display size is 6
* default utf8 collate is utf8-general-ci

* myisam fields can not be referenced in foreign key clause in innodb table definition
* use of foreign key cluause requires proper ordering of table definitions

***/

create table if not exists course_user (
	course_user_id int unsigned not null auto_increment,
	school_id int unsigned not null,
	course_id int unsigned not null, 
	user_id varchar(80) charset utf8 not null,
	time_period_id int unsigned not null,
	sort_order smallint unsigned not null default 65535,
	created_by varchar(24) charset utf8 default null,
	created_on datetime default null,
	modified_by varchar(24) charset utf8 default null,
	modified_on datetime default null,
	primary key (course_user_id),
	unique key (school_id, course_id, user_id, time_period_id)
	# foreign key (school_id) references tusk.school (school_id),
	# foreign key (course_id) references hsdb45_*_admin.course (course_id), # myisam
	# foreign key (user_id) references hsdb4.user (user_id), # myisam
	# foreign key (time_period_id) references hsdb45_*_admin.time_period (time_period_id) # myisam
	# foreign key (user_role_id) references user_role (user_role_id),
) engine=innodb charset=latin1;

create table if not exists course_user_history (
	course_user_history_id int unsigned not null auto_increment,
	course_user_id int unsigned not null,
	school_id int unsigned not null,
	course_id int unsigned not null, 
	user_id varchar(80) charset utf8 not null,
	time_period_id int unsigned not null,
	sort_order smallint unsigned not null default 65535,
	created_by varchar(24) charset utf8 default null,
	created_on datetime default null,
	modified_by varchar(24) charset utf8 default null,
	modified_on datetime default null,
	history_action enum('Insert', 'Update', 'Delete') default null,
	primary key (course_user_history_id)
) engine=innodb charset=latin1;

create table if not exists course_user_site (
	course_user_site_id int unsigned not null auto_increment,
	course_user_id int unsigned not null,
	teaching_site_id int unsigned not null,
	sort_order smallint unsigned not null default 65535,
	created_by varchar(24) charset utf8 default null,
	created_on datetime default null,
	modified_by varchar(24) charset utf8 default null,
	modified_on datetime default null,
	primary key (course_user_site_id),
	unique key (course_user_id, teaching_site_id)
	# foreign key (course_user_id) references course_user (course_user_id),
	# foreign key (teaching_site_id) references hsdb45_*_admin.teaching_site (teaching_site_id) # myisam
) engine=innodb charset=latin1;

create table if not exists course_user_site_history (
	course_user_site_history_id int unsigned not null auto_increment,
	course_user_site_id int unsigned not null,
	course_user_id int unsigned not null,
	teaching_site_id int unsigned not null,
	sort_order smallint(6) unsigned not null,
	created_by varchar(24) charset utf8 default null,
	created_on datetime default null,
	modified_by varchar(24) charset utf8 default null,
	modified_on datetime default null,
	history_action enum('Insert', 'Update', 'Delete') default null,
	primary key (course_user_site_history_id)
) engine=innodb charset=latin1;


# The following is for test environment. It has no effect on the tusk database.

drop procedure if exists xxx_create_permission_tables;
delimiter //

create procedure xxx_create_permission_tables()
proc: begin
 	if database() = 'tusk' then
 		leave proc;
 	end if;
	prepare ST from 'create table if not exists permission_feature_type like tusk.permission_feature_type';
	execute ST;
	prepare ST from 'create table if not exists permission_feature_type_history like tusk.permission_feature_type_history';
	execute ST;
	prepare ST from 'create table if not exists permission_role like tusk.permission_role';
	execute ST;
	prepare ST from 'create table if not exists permission_role_history like tusk.permission_role_history';
	execute ST;
	prepare ST from 'create table if not exists permission_user_role like tusk.permission_user_role';
	execute ST;
	prepare ST from 'create table if not exists permission_user_role_history like tusk.permission_user_role_history';
	execute ST;
	deallocate prepare ST;
end //

delimiter ;
call xxx_create_permission_tables();
drop procedure if exists xxx_create_permission_tables;

