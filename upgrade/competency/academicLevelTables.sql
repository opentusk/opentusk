DROP TABLE IF EXISTS competency_program_hierarchy;

DROP TABLE IF EXISTS program_hierarchy;

DROP TABLE IF EXISTS program;

DROP TABLE IF EXISTS academic_level_course; 

CREATE TABLE program
(
program_id INT(10) UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
title VARCHAR(100),
description VARCHAR(250),
school_id INT(10) UNSIGNED,
modified_by VARCHAR(24) NOT NULL DEFAULT ' ',
modified_on DATETIME DEFAULT NULL,
/*CONSTRAINT FOREIGN KEY ( school_id ) REFERENCES school( school_id )*/
) ENGINE=InnoDB CHARSET utf8;

DROP TABLE IF EXISTS academic_level;

CREATE TABLE academic_level
(
academic_level_id INT(10) UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
title VARCHAR(100),
description VARCHAR(250),
school_id INT(10) UNSIGNED,
modified_by VARCHAR(24) NOT NULL DEFAULT ' ',
modified_on DATETIME DEFAULT NULL
/*CONSTRAINT FOREIGN KEY (school_id) REFERENCES school(school_id)*/
) ENGINE=InnoDB CHARSET utf8;

CREATE TABLE academic_level_course
(
academic_level_course_id INT(10) UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
academic_level_id INT(10) UNSIGNED,
course_id INT(10) UNSIGNED,
CONSTRAINT FOREIGN KEY (academic_level_id) REFERENCES academic_level(academic_level_id),
modified_by VARCHAR(24) NOT NULL DEFAULT ' ',
modified_on DATETIME DEFAULT NULL
/*CONSTRAINT FOREIGN KEY (course_id) REFERENCES course(course_id)*/
) ENGINE=InnoDB CHARSET utf8;

DROP TABLE IF EXISTS track;

CREATE TABLE track
(
track_id INT(10) UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
title VARCHAR(100),
description VARCHAR(250),
school_id INT(10) UNSIGNED,
modified_by VARCHAR(24) NOT NULL DEFAULT ' ',
modified_on DATETIME DEFAULT NULL,
/*CONSTRAINT FOREIGN KEY ( school_id ) REFERENCES school( school_id )*/
) ENGINE=InnoDB CHARSET utf8;

CREATE TABLE program_hierarchy
(
program_hierarchy_id INT(10) UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
program_id INT(10) UNSIGNED,
academic_level_id INT(10) UNSIGNED,
track_id INT(10) UNSIGNED,
CONSTRAINT FOREIGN KEY ( program_id ) REFERENCES program( program_id ),
CONSTRAINT FOREIGN KEY ( academic_level_id ) REFERENCES academic_level( academic_level_id),
CONSTRAINT FOREIGN KEY ( track_id ) REFERENCES track( track_id ),
modified_by VARCHAR(24) NOT NULL DEFAULT ' ',
modified_on DATETIME DEFAULT NULL,
) ENGINE=InnoDB CHARSET utf8;

CREATE TABLE competency_program_hierarchy
(
competency_program_hierarchy_id INT(10) UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
competency_id INT(10) UNSIGNED,
program_hierarchy_id INT(10) UNSIGNED,
CONSTRAINT FOREIGN KEY ( competency_id ) REFERENCES competency( competency_id ),
CONSTRAINT FOREIGN KEY ( program_hierarchy_id ) REFERENCES program_hierarchy_id( program_hierarchy_id ),
modified_by VARCHAR(24) NOT NULL DEFAULT ' ',
modified_on DATETIME DEFAULT NULL,
) ENGINE=InnoDB CHARSET utf8;