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


drop table if exists course_user;
drop table if exists course_user_history;
drop table if exists course_user_site;
drop table if exists course_user_site_history;

# The following is for test environment. It has no effect on the tusk database.

drop procedure if exists xxx_drop_permission_tables;
delimiter //

create procedure xxx_drop_permission_tables()
proc: begin

	if database() = 'tusk' then
		leave proc;
	end if;

	drop table if exists permission_feature_type;
	drop table if exists permission_feature_type_history;
	drop table if exists permission_role;
	drop table if exists permission_role_history;
	drop table if exists permission_user_role;
	drop table if exists permission_user_role_history;

end //

delimiter ;
call xxx_drop_permission_tables();
drop procedure if exists xxx_drop_permission_tables;

