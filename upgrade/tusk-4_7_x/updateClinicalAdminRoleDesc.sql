delimiter //
SET @x_role_id = 0;
SET @x_function_id = 0;
SELECT @x_role_id := role_id, @x_function_id := function_id
    FROM tusk.permission_role AS t1
        INNER JOIN tusk.permission_function AS t2
    WHERE(t1.role_token = 'clinical_director'
        AND t1.role_desc = 'Ability to view schedules for clinical studies'
        AND t2.function_token = 'view_schedules'
        AND t2.function_desc = 'View schedules');

UPDATE tusk.permission_role
SET role_desc = 'Ability to view and edit schedules for clinical studies'
WHERE (role_token = 'clinical_director'
    AND feature_type_id = 2
    AND role_id = @x_role_id
    AND role_desc = 'Ability to view schedules for clinical studies');

UPDATE tusk.permission_function
SET function_token = 'view_edit_schedules', function_desc = 'View and edit schedules'
WHERE (function_token = 'view_schedules' AND function_desc = 'View schedules' AND function_id = @x_function_id);
//
delimiter ;
