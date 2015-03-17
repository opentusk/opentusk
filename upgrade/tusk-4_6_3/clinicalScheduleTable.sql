CREATE TABLE tusk.`academic_level_clinical_schedule`(
  `academic_level_clinical_schedule_id` INT NOT NULL AUTO_INCREMENT,
  `academic_level_id` INT(10) UNSIGNED NOT NULL,
  `school_id` INT(10) UNSIGNED DEFAULT NULL,
  `modified_by` VARCHAR(40) NOT NULL DEFAULT ' ',
  `modified_on` DATETIME DEFAULT NULL,
  PRIMARY KEY(`academic_level_clinical_schedule_id`)
) ENGINE = InnoDB DEFAULT CHARSET=utf8 ;
