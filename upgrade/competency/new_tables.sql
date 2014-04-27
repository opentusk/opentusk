CREATE TABLE competency_relation
(
	competency_relation_id int(10) UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
	competency_id_1 int(10) UNSIGNED,
	competency_id_2 int(10) UNSIGNED,
	created_by varchar(24) NOT NULL DEFAULT ' ',
	created_on datetime DEFAULT NULL,
	modified_by varchar(24) NOT NULL DEFAULT ' ',
	modified_on datetime DEFAULT NULL,
	CONSTRAINT FOREIGN KEY (competency_id_1) REFERENCES competency(competency_id),
	CONSTRAINT FOREIGN KEY (competency_id_2) REFERENCES competency(competency_id)
) CHARSET utf8;

CREATE TABLE competency_relation_history
(
	competency_relation_history_id int(10) UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
	competency_relation_id int(10) UNSIGNED NOT NULL,
	competency_id_1 int(10) UNSIGNED NOT NULL,
	competency_id_2 int(10) UNSIGNED NOT NULL,
	created_by varchar(24) NOT NULL DEFAULT ' ',
	created_on datetime DEFAULT NULL,
	modified_by varchar(24) NOT NULL DEFAULT ' ',
	modified_on datetime DEFAULT NULL,
	history_action enum('Insert', 'Update', 'Delete'),
	CONSTRAINT FOREIGN KEY (competency_id_1) REFERENCES competency(competency_id),
	CONSTRAINT FOREIGN KEY (competency_id_2) REFERENCES competency(competency_id)
) CHARSET utf8;

DROP TABLE IF EXISTS competency_version;

CREATE TABLE competency_version
(
	competency_version_id tinyint UNSIGNED NOT NULL PRIMARY KEY,
	school_id int(10) UNSIGNED,
	title varchar(100),
	description varchar(250),
	start_date datetime,
	created_by varchar(24) DEFAULT NULL,
	created_on datetime DEFAULT NULL,
	modified_by varchar(24) DEFAULT NULL,
	modified_on datetime DEFAULT NULL;
) ENGINE=InnoDB CHARSET utf8;

DROP TABLE IF EXISTS competency_course_content;

CREATE TABLE competency_course_content
(
	competency_course_content_id int(10) UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
	competency_course_id int(10) UNSIGNED,
	competency_content_id int(10) UNSIGNED,
	created_by varchar(24) NOT NULL DEFAULT ' ',
	created_on datetime DEFAULT NULL,
	modified_by varchar(24) NOT NULL DEFAULT ' ',
	modified_on datetime DEFAULT NULL,
	CONSTRAINT FOREIGN KEY (competency_course_id) REFERENCES course_competency(course_competency_id),
	CONSTRAINT FOREIGN KEY (competency_content_id) REFERENCES content_competency(content_competency_id)
 ) ENGINE=InnoDB CHARSET utf8;

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
	course_competency_history_id int(10) unsigned NOT NULL PRIMARY KEY AUTO_INCREMENT,
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


DROP TABLE IF EXISTS competency_content;

CREATE TABLE competency_content (
	content_competency_id int(10) unsigned NOT NULL PRIMARY KEY AUTO_INCREMENT,
	competency_id int(10) unsigned NOT NULL DEFAULT '0',
	content_id int(10) unsigned NOT NULL DEFAULT '0',
	sort_order smallint(6) unsigned NOT NULL DEFAULT '65535',
	created_by varchar(24) NOT NULL DEFAULT ' ',
	created_on datetime DEFAULT NULL,
	modified_by varchar(24) NOT NULL DEFAULT ' ',
	modified_on datetime DEFAULT NULL,
	CONSTRAINT FOREIGN KEY (competency_id) REFERENCES competency(competency_id)
) ENGINE=INNODB DEFAULT CHARSET=utf8; 

DROP TABLE IF EXISTS competency_content_history;

CREATE TABLE competency_content_history (
	competency_content_history_id int(10) unsigned NOT NULL PRIMARY KEY AUTO_INCREMENT,
	competency_id int(10) unsigned NOT NULL DEFAULT '0',
	content_id int(10) unsigned NOT NULL DEFAULT '0',
	sort_order smallint(6) unsigned NOT NULL DEFAULT '65535',
	created_by varchar(24) NOT NULL DEFAULT ' ',
	created_on datetime DEFAULT NULL,
	modified_by varchar(24) NOT NULL DEFAULT ' ',
	modified_on datetime DEFAULT NULL,
	history_action enum('Insert', 'Update', 'Delete'),
	CONSTRAINT FOREIGN KEY (competency_id) REFERENCES competency(competency_id)
) ENGINE=INNODB DEFAULT CHARSET=utf8; 

DROP TABLE IF EXISTS competency_class_meeting;

CREATE TABLE competency_class_meeting (
	competency_class_meeting_id int(10) unsigned NOT NULL PRIMARY KEY AUTO_INCREMENT,
	competency_id int(10) unsigned NOT NULL DEFAULT '0',
	class_meeting_id int(10) unsigned NOT NULL DEFAULT '0',
	sort_order smallint(6) unsigned NOT NULL DEFAULT '65535',
	assessment_method_id int(10) UNSIGNED 
	created_by varchar(24) NOT NULL DEFAULT ' ',
	created_on datetime DEFAULT NULL,
	modified_by varchar(24) NOT NULL DEFAULT ' ',
	modified_on datetime DEFAULT NULL,
	CONSTRAINT FOREIGN KEY (competency_id) REFERENCES competency(competency_id),
	CONSTRAINT UNIQUE (assessment_method_id)
) ENGINE=INNODB DEFAULT CHARSET=utf8; 

DROP TABLE IF EXISTS competency_class_meeting_history;

CREATE TABLE competency_class_meeting_history (
	competency_competency_history_id int(10) unsigned NOT NULL PRIMARY KEY AUTO_INCREMENT,
	competency_id int(10) unsigned NOT NULL DEFAULT '0',
	class_meeting_id int(10) unsigned NOT NULL DEFAULT '0',
	sort_order smallint(6) unsigned NOT NULL DEFAULT '65535',
	created_by varchar(24) NOT NULL DEFAULT ' ',
	created_on datetime DEFAULT NULL,
	modified_by varchar(24) NOT NULL DEFAULT ' ',
	modified_on datetime DEFAULT NULL,
	history_action enum('Insert', 'Update', 'Delete'),
	CONSTRAINT FOREIGN KEY (competency_id) REFERENCES competency(competency_id)
) ENGINE=INNODB DEFAULT CHARSET=utf8; 

DROP TABLE IF EXISTS competency_user_type;

CREATE TABLE competency_user_type( 
	competency_user_type_id int(10) unsigned PRIMARY KEY AUTO_INCREMENT, 
	name varchar(24), 
	school_id int(10) unsigned, 
	competency_type_enum_id smallint(6),
	created_by varchar(24) NOT NULL DEFAULT '' , 
	created_on datetime DEFAULT NULL, 
	modified_by varchar(24) NOT NULL DEFAULT '', 
	modified on datetime DEFAULT NULL 
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
