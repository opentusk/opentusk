/*
Upgrade script for competency upgrade related to course_competencies, 
competency_types and the competency checklist project.
*/

/*Modifications to old tables*/

/*upgrade competency and competency_history tables to InnoDB and character set utf8*/

ALTER TABLE competency ENGINE = InnoDB;

ALTER TABLE competency_history ENGINE = InnoDB;

ALTER TABLE competency CONVERT TO CHARACTER SET utf8;

ALTER TABLE competency_history CONVERT TO CHARACTER SET utf8;

/* Insert user_type data and level_id data to enum_data table */
CREATE TABLE IF NOT EXISTS `enum_data` (
  `enum_data_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `namespace` varchar(50) NOT NULL DEFAULT '',
  `short_name` varchar(12) NOT NULL DEFAULT '',
  `display_name` varchar(100) DEFAULT NULL,
  `description` varchar(200) NOT NULL DEFAULT '',
  `created_by` varchar(24) NOT NULL DEFAULT '',
  `created_on` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `modified_by` varchar(24) DEFAULT NULL,
  `modified_on` datetime DEFAULT NULL,
  PRIMARY KEY (`enum_data_id`),
  KEY `namespace` (`namespace`),
  KEY `short_name` (`short_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO enum_data VALUES
(0, 'competency.user_type.id', 'competency', 'Competency', 'Competency type for Competencies', 'script', now(), 'script', now()),
(0, 'competency.user_type.id', 'category', 'Competency Category', 'Category type for Competencies', 'script', now(), 'script', now()),
(0, 'competency.user_type.id', 'info', 'Supporting Information', 'Supporting Information', 'script', now(), 'script', now()),
(0, 'competency.level_id', 'national', 'National', 'National Competencies', 'script', now(), 'script', now()),
(0, 'competency.level_id', 'school', 'School', 'School Competencies', 'script', now(), 'script', now()),
(0, 'competency.level_id', 'course', 'Course', 'Course Competencies', 'script', now(), 'script', now()), 
(0, 'competency.level_id', 'class_meet', 'Class Meeting', 'Class Meeting Competencies', 'script', now(), 'script', now()),
(0, 'competency.level_id', 'content', 'Content', 'Content Competencies', 'script', now(), 'script', now());

/*drop tables if tables of same name as new tables exist*/
DROP TABLE IF EXISTS competency_course;
DROP TABLE IF EXISTS competency_course_history;
DROP TABLE IF EXISTS competency_user_type;
DROP TABLE IF EXISTS competency_user_type_history;

/*user_type and related history table for linking custom user types to types in enum_data */


CREATE TABLE competency_user_type( 
	competency_user_type_id int(10) unsigned PRIMARY KEY AUTO_INCREMENT, 
	name varchar(24), 
	school_id int(10) unsigned, 
	competency_type_enum_id smallint(6),
	modified_by varchar(24) NOT NULL DEFAULT '', 
	modified_on datetime DEFAULT NULL 
) ENGINE=InnoDB CHARSET=UTF8; 


CREATE TABLE competency_user_type_history(
	competency_user_type_history_id int(10) unsigned NOT NULL PRIMARY KEY AUTO_INCREMENT, 
	competency_user_type_id int(10) unsigned, 
	name varchar(24), 
	school_id int(10) unsigned, 
	competency_type_enum_id smallint(6),
	modified_by varchar(24) NOT NULL DEFAULT '', 
	modified_on datetime DEFAULT NULL,
	history_action enum('Insert', 'Update', 'Delete')
) ENGINE=InnoDB CHARSET=UTF8; 

/*Drop created_by and created_on columns from and add new columns to competency and comptency_history tables*/

ALTER TABLE competency
DROP COLUMN created_by,
DROP COLUMN created_on,
ADD COLUMN uri varchar(256) DEFAULT NULL AFTER description, 
ADD COLUMN competency_level_enum_id int(10) unsigned NOT NULL AFTER uri, 
ADD COLUMN competency_user_type_id int(10) unsigned AFTER competency_level_enum_id,
ADD COLUMN version_id tinyint unsigned DEFAULT NULL AFTER school_id,
CHANGE title title varchar(350) DEFAULT NULL,
ADD CONSTRAINT FOREIGN KEY (competency_user_type_id) REFERENCES competency_user_type(competency_user_type_id);

ALTER TABLE competency_history
DROP COLUMN created_by,
DROP COLUMN created_on,
ADD COLUMN uri varchar(256) NOT NULL AFTER description,
ADD COLUMN competency_level_enum_id int(10) unsigned NOT NULL AFTER uri,
ADD COLUMN competency_user_type_id int(10) unsigned NOT NULL AFTER competency_level_enum_id,
ADD COLUMN version_id tinyint unsigned DEFAULT NULL AFTER school_id,
CHANGE title title varchar(350) DEFAULT NULL;

/* Drop created_by and created_on columns from and rename the competency_relationship table and the related history table to competency_hierarchy */

RENAME TABLE competency_relationship TO competency_hierarchy;

ALTER TABLE competency_hierarchy 
DROP COLUMN created_by,
DROP COLUMN created_on,
CHANGE competency_relationship_id competency_hierarchy_id int(10) unsigned NOT NULL AUTO_INCREMENT;

RENAME TABLE competency_relationship_history TO competency_hierarchy_history;

ALTER TABLE competency_hierarchy_history 
DROP COLUMN created_by,
DROP COLUMN created_on,
CHANGE competency_relationship_history_id competency_hierarchy_history_id int(10) unsigned NOT NULL AUTO_INCREMENT,
CHANGE competency_relationship_id competency_hierarchy_id int(10) unsigned NOT NULL;

/*Creation of New tables*/

/* competency_course table and related history table to specify which competencies are related to which courses */

CREATE TABLE competency_course (
	competency_course_id int(10) unsigned NOT NULL PRIMARY KEY AUTO_INCREMENT,
	competency_id int(10) unsigned NOT NULL DEFAULT '0',
	course_id int(10) unsigned NOT NULL DEFAULT '0',
	sort_order smallint(6) unsigned NOT NULL DEFAULT '65535',
	modified_by varchar(24) NOT NULL DEFAULT ' ',
	modified_on datetime DEFAULT NULL,
	CONSTRAINT FOREIGN KEY (competency_id) REFERENCES competency(competency_id)
) ENGINE=INNODB DEFAULT CHARSET=utf8; 

CREATE TABLE competency_course_history (
	competency_course_history_id int(10) unsigned NOT NULL PRIMARY KEY AUTO_INCREMENT,
	competency_course_id int(10) unsigned NOT NULL DEFAULT '0',
	competency_id int(10) unsigned NOT NULL DEFAULT '0',
	course_id int(10) unsigned NOT NULL DEFAULT '0',
	sort_order smallint(6) unsigned NOT NULL DEFAULT '65535',
	modified_by varchar(24) NOT NULL DEFAULT ' ',
	modified_on datetime DEFAULT NULL,
	history_action enum('Insert', 'Update', 'Delete')
) ENGINE=INNODB DEFAULT CHARSET=utf8; 

/*Drop old foreign keys, required in external installs*/

ALTER TABLE competency_hierarchy DROP FOREIGN KEY competency_hierarchy_ibfk_1;

ALTER TABLE competency_competency_type DROP FOREIGN KEY competency_competency_type_ibfk_1;

