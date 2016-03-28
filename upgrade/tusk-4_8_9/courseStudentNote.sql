CREATE TABLE IF NOT EXISTS tusk.`course_student_note`(
	`course_student_note_id` INT NOT NULL AUTO_INCREMENT,
	`course_id` INT(10) UNSIGNED NOT NULL,
	`student_id` VARCHAR(24) NOT NULL,
	`date` DATETIME DEFAULT NULL,
	`note` TEXT,
	`modified_by` VARCHAR(40) NOT NULL DEFAULT ' ',
  	`modified_on` DATETIME DEFAULT NULL,
	PRIMARY KEY(`course_student_note_id`)
) ENGINE = InnoDB DEFAULT CHARSET=utf8 ;