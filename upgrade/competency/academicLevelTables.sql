
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