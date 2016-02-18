delimiter //
SET @x_role_id = 0;
SET @x_function_id = 0;
INSERT INTO tusk.permission_function (function_token, function_desc, created_by, created_on, modified_by, modified_on) VALUES ('view_site_grades', 'View site grades', 'sqlscript', NOW(), 'sqlscript', NOW());
SELECT @x_role_id := role_id, @x_function_id := function_id 
	FROM tusk.permission_role AS t1 
		INNER JOIN tusk.permission_function AS t2 
	WHERE(t1.role_token = 'site_director' 
		AND t1.role_desc = 'Site Director' 
		AND t2.function_token = 'view_site_grades' 
		AND t2.function_desc = 'View site grades');
INSERT INTO tusk.permission_role_function(role_id, function_id, created_by, created_on, modified_by, modified_on) values(@x_role_id, @x_function_id, 'sqlscript', NOW(), 'sqlscript', NOW());
// 
delimiter ;