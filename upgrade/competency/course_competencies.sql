/*
Upgrade script for competency upgrade related to course_competencies, competency_types and the competency checklist project.
*/

/*Modifications to old tables*/

/*upgrade competency and competency_history tables to InnoDB and character set utf8*/

ALTER TABLE competency ENGINE = InnoDB;

ALTER TABLE competency_history ENGINE = InnoDB;

ALTER TABLE competency CONVERT TO CHARACTER SET utf8;

ALTER TABLE competency_history CONVERT TO CHARACTER SET utf8;


/*Insert user_type data and level_id data to enum_data table*/

INSERT INTO enum_data 
VALUES ( 
	0,
	'competency.user_type.id', 
	'competency', 
	'Competency', 
	'Competency type for Competencies', 
	'script', 
	now(), 
	'script', 
	now() 
); 

INSERT INTO enum_data
VALUES ( 
	0,
	'competency.user_type.id', 
	'category', 
	'Competency Category', 
	'Category type for Competencies', 
	'script', 
	now(), 
	'script', 
	now() 
); 

INSERT INTO enum_data 
VALUES ( 
	0, 
	'competency.user_type_id',
	 'info',
	 'Supporting Information',
	 'Supporting Information',
	 'script', 
	now(),
	 'script',
	now() 
); 

INSERT INTO enum_data 
VALUES ( 
	0,
	'competency.level_id', 
	'national', 
	'National', 
	'National Competencies', 
	'script', 
	now(), 
	'script', 
	now() 
);\

INSERT INTO enum_data 
VALUES ( 
	0,
	'competency.level_id', 
	'school', 
	'School', 
	'School Competencies', 
	'script', 
	now(), 
	'script', 
	now() 
); 

INSERT INTO enum_data
VALUES ( 
	0,
	'competency.level_id', 
	'course', 
	'Course', 
	'Course Competencies', 
	'script', 
	now(), 
	'script', 
	now() 
); 


INSERT INTO enum_data 
VALUES ( 
	0,
	'competency.level_id', 
	'class_meet', 
	'Class Meeting', 
	'Class Meeting Competencies', 
	'script', 
	now(), 
	'script', 
	now() 
); 

INSERT INTO enum_data 
VALUES ( 
	0,
	'competency.level_id', 
	'content', 
	'Content', 
	'Content Competencies', 
	'script', 
	now(), 
	'script', 
	now() 
); 

/*user_type and related history table for linking custom user types to types in enum_data */

DROP TABLE IF EXISTS competency_user_type;

CREATE TABLE competency_user_type( 
	competency_user_type_id int(10) unsigned PRIMARY KEY AUTO_INCREMENT, 
	name varchar(24), 
	school_id int(10) unsigned, 
	competency_type_enum_id smallint(6),
	created_by varchar(24) NOT NULL DEFAULT '', 
	created_on datetime DEFAULT NULL, 
	modified_by varchar(24) NOT NULL DEFAULT '', 
	modified_on datetime DEFAULT NULL 
) ENGINE=InnoDB CHARSET=UTF8; 

DROP TABLE IF EXISTS competency_user_type_history;

CREATE TABLE competency_user_type_history(
	competency_user_type_history_id int(10) unsigned NOT NULL PRIMARY KEY AUTO_INCREMENT, 
	competency_user_type_id int(10) unsigned, 
	name varchar(24), 
	school_id int(10) unsigned, 
	competency_type_enum_id smallint(6),
	created_by varchar(24) NOT NULL DEFAULT '' , 
	created_on datetime DEFAULT NULL, 
	modified_by varchar(24) NOT NULL DEFAULT '', 
	modified_on datetime DEFAULT NULL,
	history_action enum('Insert', 'Update', 'Delete')
) ENGINE=InnoDB CHARSET=UTF8; 

/*Add new columns to competency and comptency_history tables*/

ALTER TABLE competency
ADD COLUMN uri varchar(256) DEFAULT NULL AFTER description, 
ADD COLUMN competency_level_enum_id int(10) unsigned DEFAULT NULL, 
ADD COLUMN competency_user_type_id int(10) unsigned DEFAULT NULL,
ADD COLUMN version_id tinyint unsigned DEFAULT NULL AFTER school_id;

ALTER TABLE competency_history
ADD COLUMN uri varchar(256) NOT NULL AFTER description,
ADD COLUMN competency_level_enum_id int(10) unsigned DEFAULT NULL AFTER uri,
ADD COLUMN competency_user_type_id int(10) unsigned DEFAULT NULL AFTER competency_level_enum_id,
ADD COLUMN version_id tinyint unsigned DEFAULT NULL AFTER school_id;

/* rename the competency_relationship table and the related history table to competency_hierarchy */

RENAME TABLE competency_relationship TO competency_hierarchy;

ALTER TABLE competency_hierarchy 
CHANGE competency_relationship_id competency_hierarchy_id int(10) UNSIGNED,
DROP column school_id;

RENAME TABLE competency_relationship_history TO competency_hierarchy_history;

ALTER TABLE competency_hierarchy_history 
CHANGE competency_relationship_history_id competency_hierarchy_history_id int(10) UNSIGNED,
CHANGE competency_relationship_id competency_hierarchy_id int(10) UNSIGNED,
DROP column school_id;


/*Creation of New tables*/

/* competency_course table and related history table to specify which competencies are related to which courses */

DROP TABLE IF EXISTS competency_course;

CREATE TABLE competency_course (
	competency_course_id int(10) unsigned NOT NULL PRIMARY KEY AUTO_INCREMENT,
	competency_id int(10) unsigned NOT NULL DEFAULT '0',
	course_id int(10) unsigned NOT NULL DEFAULT '0',
	sort_order smallint(6) unsigned NOT NULL DEFAULT '65535',
	created_by varchar(24) NOT NULL DEFAULT ' ',
	created_on datetime DEFAULT NULL,
	modified_by varchar(24) NOT NULL DEFAULT ' ',
	modified_on datetime DEFAULT NULL,
	CONSTRAINT FOREIGN KEY (competency_id) REFERENCES competency(competency_id)
) ENGINE=INNODB DEFAULT CHARSET=utf8; 

DROP TABLE IF EXISTS competency_course_history;

CREATE TABLE competency_course_history (
	competency_course_history_id int(10) unsigned NOT NULL PRIMARY KEY AUTO_INCREMENT,
	competency_id int(10) unsigned NOT NULL DEFAULT '0',
	course_id int(10) unsigned NOT NULL DEFAULT '0',
	sort_order smallint(6) unsigned NOT NULL DEFAULT '65535',
	created_by varchar(24) NOT NULL DEFAULT ' ',
	created_on datetime DEFAULT NULL,
	modified_by varchar(24) NOT NULL DEFAULT ' ',
	modified_on datetime DEFAULT NULL,
	history_action enum('Insert', 'Update', 'Delete'),
	CONSTRAINT FOREIGN KEY (competency_id) REFERENCES competency(competency_id)
) ENGINE=INNODB DEFAULT CHARSET=utf8; 

