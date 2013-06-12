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


truncate course_user;
truncate course_user_history;
truncate course_user_site;
truncate course_user_site_history;

# note delete does not reset auto_increment counter 

delete from permission_user_role where
	role_id in (
		select role_id from permission_role where feature_type_id in (
			select feature_type_id from permission_feature_type where feature_type_token = 'course'
		)
	)
	/*
	there are records with role_id = 0. it's very likely that we have created
	them. but, we want to be safe. so they will remain. if you really have to
	insist, then uncomment the next line
	*/
	# or role_id = 0 
	;

delete from permission_role where feature_type_id in (
	select feature_type_id from permission_feature_type where feature_type_token = 'course'
);

delete from permission_feature_type where feature_type_token = 'course';

