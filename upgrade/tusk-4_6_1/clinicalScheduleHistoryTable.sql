CREATE TABLE tusk.`academic_level_clinical_schedule_history`(
  `academic_level_clinical_schedule_history_id` INT NOT NULL AUTO_INCREMENT,
  `academic_level_clinical_schedule_id` INT NOT NULL,
  `academic_level_id` INT(10) UNSIGNED NOT NULL,
  `school_id` INT(10) UNSIGNED DEFAULT NULL,
  `modified_by` VARCHAR(40) NOT NULL DEFAULT ' ',
  `modified_on` DATETIME DEFAULT NULL,
  `history_action` enum('Delete', 'Insert', 'Update'),
  PRIMARY KEY (`academic_level_clinical_schedule_history_id`)
) ENGINE = InnoDB DEFAULT CHARSET=utf8 ;
