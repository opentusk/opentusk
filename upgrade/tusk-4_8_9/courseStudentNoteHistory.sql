CREATE TABLE IF NOT EXISTS tusk.`course_student_note_history` (
  `course_student_note_history_id` INT(11) NOT NULL AUTO_INCREMENT,
  `course_student_note_id` INT(11) NOT NULL,
  `course_id` INT(10) UNSIGNED NOT NULL,
  `student_id` VARCHAR(24) NOT NULL,
  `date` DATETIME DEFAULT NULL,
  `note` TEXT,
  `modified_by` VARCHAR(40) NOT NULL DEFAULT ' ',
  `modified_on` DATETIME DEFAULT NULL,
  `history_action` enum('Delete', 'Insert', 'Update'),
  PRIMARY KEY (`course_student_note_history_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;