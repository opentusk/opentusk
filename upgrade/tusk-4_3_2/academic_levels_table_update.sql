/*Add sort_order column to academic_level and academic_level_history tables*/

ALTER TABLE academic_level_course_history
DROP FOREIGN KEY academic_level_course_history_ibfk_1;

ALTER TABLE academic_level
ADD COLUMN sort_order tinyint(3) unsigned NOT NULL DEFAULT '0' AFTER school_id;

ALTER TABLE academic_level_history
ADD COLUMN sort_order tinyint(3) unsigned NOT NULL DEFAULT '0' AFTER school_id;

