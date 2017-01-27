USE tusk;

INSERT INTO enum_data VALUES (0, "course.landing_page", "original", "Original", "Original TUSK template", "script", now());

INSERT INTO enum_data VALUES (0, "course.landing_page", "template", "Course tempalte", "New Landing Page template", "script", now());

ALTER TABLE course ADD COLUMN landing_page INT(10) UNSIGNED NOT NULL AFTER school_course_code; 

ALTER TABLE course_history ADD COLUMN landing_page INT(10) UNSIGNED NOT NULL AFTER school_course_code; 

UPDATE course SET landing_page = (SELECT enum_data_id FROM enum_data WHERE namespace = "course.landing_page" AND short_name = "original"); 

UPDATE course_history SET landing_page = (SELECT enum_data_id FROM enum_data WHERE namespace = "course.landing_page" AND short_name = "original"); 

