delimiter //
SET @x_role_id = 0;
SET @x_function_id = 0;
INSERT INTO tusk.permission_role (role_token, role_desc, feature_type_id) VALUES ('clinical_director', 'Ability to view schedules for clinical studies', 2);
INSERT INTO tusk.permission_function (function_token, function_desc) VALUES ('view_schedules', 'View schedules');
SELECT @x_role_id := role_id, @x_function_id := function_id 
	FROM tusk.permission_role AS t1 
		INNER JOIN tusk.permission_function AS t2 
	WHERE(t1.role_token = 'clinical_director' 
		AND t1.role_desc = 'Ability to view schedules for clinical studies' 
		AND t2.function_token = 'view_schedules' 
		AND t2.function_desc = 'View schedules');
INSERT INTO tusk.permission_role_function(role_id, function_id) values(@x_role_id, @x_function_id);
// 
delimiter ;