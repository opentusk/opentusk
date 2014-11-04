START TRANSACTION;
USE tusk;

SET @FEATURE_TYPE_ID = (SELECT feature_type_id FROM permission_feature_type WHERE feature_type_token = 'school');
SET @ROLE_ID = (SELECT role_id FROM permission_role WHERE role_token = 'admin' and feature_type_id = @FEATURE_TYPE_ID);

DELETE FROM permission_role WHERE role_id = @ROLE_ID;
DELETE FROM permission_user_role WHERE role_id = @ROLE_ID;
DELETE FROM permission_role_function WHERE role_id = @ROLE_ID;

COMMIT;


START TRANSACTION;
USE tusk;

INSERT INTO permission_role VALUES (0, 'registrar', 'Ability to view grades for a particular school', @FEATURE_TYPE_ID, 0, 'script', now(), 'script', now());
SET @ROLE_ID = (SELECT last_insert_id());

INSERT INTO permission_function VALUES (0, 'view_school_grades', 'View grades for a particular school', 'script',  now(), 'script',  now());
SET @function_id = (SELECT last_insert_id());

INSERT INTO permission_role_function VALUES (0, @ROLE_ID, @FUNCTION_ID,  'script',  now(), 'script',  now());

COMMIT;
