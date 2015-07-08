UPDATE tusk.permission_role 
SET role_desc = 'Ability to view and edit schedules for clinical studies' 
WHERE role_token = 'clinical_director' AND feature_type_id = 2;
