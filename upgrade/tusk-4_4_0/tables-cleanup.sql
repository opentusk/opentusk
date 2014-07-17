/* use this if you want to clean up data */

use tusk;

/* cleanup user permissions */
delete ur 
from permission_user_role ur 
inner join permission_role r 
on (ur.role_id = r.role_id and r.feature_type_id)
inner join permission_feature_type ft
on (r.feature_type_id = ft.feature_type_id AND feature_type_token = 'course');

truncate table course_user_site;
truncate table course_user_site_history;
truncate table course_user;
truncate table course_user_history;

