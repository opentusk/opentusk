/*
SQL Upgrade script for tables related to competencies, competency relationships and academic levels.
*/

/*New tables for competency*/

DROP TABLE IF EXISTS competency_version;

CREATE TABLE competency_version
(
	competency_version_id tinyint UNSIGNED NOT NULL PRIMARY KEY,
	school_id int(10) UNSIGNED,
	title varchar(100),
	description varchar(250),
	start_date datetime,
	modified_by varchar(24) DEFAULT NULL,
	modified_on datetime DEFAULT NULL
) ENGINE=InnoDB CHARSET utf8;

DROP TABLE IF EXISTS competency_version_history;

CREATE TABLE competency_version_history
(
	competency_version_history_id tinyint UNSIGNED NOT NULL PRIMARY KEY,
	competency_version_id tinyint UNSIGNED NOT NULL,
	school_id int(10) UNSIGNED,
	title varchar(100),
	description varchar(250),
	start_date datetime,
	modified_by varchar(24) DEFAULT NULL,
	modified_on datetime DEFAULT NULL,
	history_action enum('Insert', 'Update', 'Delete')
) ENGINE=InnoDB CHARSET utf8;

DROP TABLE IF EXISTS competency_content;

CREATE TABLE competency_content (
	competency_content_id int(10) unsigned NOT NULL PRIMARY KEY AUTO_INCREMENT,
	competency_id int(10) unsigned NOT NULL DEFAULT '0',
	content_id int(10) unsigned NOT NULL DEFAULT '0',
	sort_order smallint(6) unsigned NOT NULL DEFAULT '0',
	modified_by varchar(24) NOT NULL DEFAULT ' ',
	modified_on datetime DEFAULT NULL,
	CONSTRAINT FOREIGN KEY (competency_id) REFERENCES competency(competency_id)
) ENGINE=INNODB DEFAULT CHARSET=utf8; 

DROP TABLE IF EXISTS competency_content_history;

CREATE TABLE competency_content_history (
	competency_content_history_id int(10) unsigned NOT NULL PRIMARY KEY AUTO_INCREMENT,
	competency_content_id int(10) unsigned NOT NULL,
	competency_id int(10) unsigned NOT NULL DEFAULT '0',
	content_id int(10) unsigned NOT NULL DEFAULT '0',
	sort_order smallint(6) unsigned NOT NULL DEFAULT '0',
	modified_by varchar(24) NOT NULL DEFAULT ' ',
	modified_on datetime DEFAULT NULL,
	history_action enum('Insert', 'Update', 'Delete')
) ENGINE=INNODB DEFAULT CHARSET=utf8; 

DROP TABLE IF EXISTS competency_class_meeting;

CREATE TABLE competency_class_meeting (
	competency_class_meeting_id int(10) unsigned NOT NULL PRIMARY KEY AUTO_INCREMENT,
	competency_id int(10) unsigned NOT NULL DEFAULT '0',
	class_meeting_id int(10) unsigned NOT NULL DEFAULT '0',
	sort_order smallint(6) unsigned NOT NULL DEFAULT '0',
	assessment_method_id int(10) UNSIGNED,
	modified_by varchar(24) NOT NULL DEFAULT ' ',
	modified_on datetime DEFAULT NULL,
	CONSTRAINT FOREIGN KEY (competency_id) REFERENCES competency(competency_id),
	CONSTRAINT UNIQUE (assessment_method_id)
) ENGINE=INNODB DEFAULT CHARSET=utf8; 

DROP TABLE IF EXISTS competency_class_meeting_history;

CREATE TABLE competency_class_meeting_history (
	competency_class_meeting_history_id int(10) unsigned NOT NULL PRIMARY KEY AUTO_INCREMENT,
	competency_class_meeting_id int(10) unsigned NOT NULL DEFAULT '0', 
	competency_id int(10) unsigned NOT NULL DEFAULT '0',
	class_meeting_id int(10) unsigned NOT NULL DEFAULT '0',
	sort_order smallint(6) unsigned NOT NULL DEFAULT '0',
	assessment_method_id int(10) UNSIGNED,
	modified_by varchar(24) NOT NULL DEFAULT ' ',
	modified_on datetime DEFAULT NULL,
	history_action enum('Insert', 'Update', 'Delete')
) ENGINE=INNODB DEFAULT CHARSET=utf8; 

/*Tables for competency linking*/

CREATE TABLE competency_relation
(
	competency_relation_id int(10) UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
	competency_id_1 int(10) UNSIGNED,
	competency_id_2 int(10) UNSIGNED,
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
	modified_by varchar(24) NOT NULL DEFAULT ' ',
	modified_on datetime DEFAULT NULL,
	history_action enum('Insert', 'Update', 'Delete')
) CHARSET utf8;

/*Table for academic level*/

DROP TABLE IF EXISTS academic_level_course; 

DROP TABLE IF EXISTS academic_level;

CREATE TABLE academic_level
(
	academic_level_id int(10) UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
	title varchar(100),
	description varchar(250),
	school_id int(10) UNSIGNED,
	modified_by varchar(24) NOT NULL DEFAULT ' ',
	modified_on datetime DEFAULT NULL
) ENGINE=InnoDB CHARSET utf8;

CREATE TABLE academic_level_history
(
	academic_level_history_id int(10) UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
	academic_level_id int(10) UNSIGNED NOT NULL,
	title varchar(100),
	description varchar(250),
	school_id int(10) UNSIGNED,
	modified_by varchar(24) NOT NULL DEFAULT ' ',
	modified_on datetime DEFAULT NULL,
	history_action enum('Insert', 'Update', 'Delete')
) ENGINE=InnoDB CHARSET utf8;

CREATE TABLE academic_level_course
(
	academic_level_course_id int(10) UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
	academic_level_id int(10) UNSIGNED,
	course_id int(10) UNSIGNED,
	CONSTRAINT FOREIGN KEY (academic_level_id) REFERENCES academic_level(academic_level_id),
	modified_by varchar(24) NOT NULL DEFAULT ' ',
	modified_on datetime DEFAULT NULL
) ENGINE=InnoDB CHARSET utf8;

CREATE TABLE academic_level_course_history
(
	academic_level_course_history_id int(10) UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
	academic_level_course_id int(10) UNSIGNED NOT NULL, 
	academic_level_id int(10) UNSIGNED,
	course_id int(10) UNSIGNED,
	CONSTRAINT FOREIGN KEY (academic_level_id) REFERENCES academic_level(academic_level_id),
	modified_by varchar(24) NOT NULL DEFAULT ' ',
	modified_on datetime DEFAULT NULL,
	history_action enum('Insert', 'Update', 'Delete')
) ENGINE=InnoDB CHARSET utf8;
