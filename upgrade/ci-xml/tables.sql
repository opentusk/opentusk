CREATE TABLE IF NOT EXISTS `class_meeting_assessment_method_type` (
  `class_meeting_assessment_method_type_id` int(10) unsigned NOT NULL auto_increment,
  `class_meeting_id` int(10) unsigned NOT NULL,
  `school_id` int(10) unsigned NOT NULL,
  `assessment_method_type_enum_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`class_meeting_assessment_method_type_id`),
  UNIQUE KEY (`class_meeting_id`, `assessment_method_type_enum_id`)
) ENGINE=InnoDB DEFAULT CHARSET=UTF8;


CREATE TABLE IF NOT EXISTS `class_meeting_assessment_method_type_history` (
  `class_meeting_assessment_method_type_id` int(10) unsigned NOT NULL auto_increment,
  `class_meeting_id` int(10) unsigned NOT NULL,
  `school_id` int(10) unsigned NOT NULL,
  `assessment_method_type_enum__id` int(10) unsigned NOT NULL,
  `history_action` enum('Insert','Update','Delete') DEFAULT NULL,
  PRIMARY KEY (`class_meeting_assessment_method_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=UTF8;

alter table class_meeting_type
add curriculum_method_enum_id int(10) unsigned NULL after label,
add method_code varchar(12) NULL after curriculum_method_type_enum_id;

alter table class_meeting_type_history
add curriculum_method_enum_id int(10) unsigned NULL after label,
add method_code varchar(12) NULL after curriculum_method_type_enum_id;

INSERT INTO enum_data VALUES 
(0, 'class_meeting_type.curriculum_method_id', 'instruction', 'Instructional Method', '', 'script', now(), 'script', now()),
(0, 'class_meeting_type.curriculum_method_id', 'assessment', 'Assessment Method', '', 'script', now(), 'script', now()),
(0, 'class_meeting_assessment_method.type_id', 'formative', 'Formative', '', 'script', now(), 'script', now()),
(0, 'class_meeting_assessment_method.type_id', 'summative', 'Summative', '', 'script', now(), 'script', now());