CREATE TABLE IF NOT EXISTS `class_meeting_assessment_purpose` (
  `class_meeting_assessment_purpose_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `class_meeting_id` int(10) unsigned NOT NULL,
  `school_id` int(10) unsigned NOT NULL,
  `assessment_purpose_enum_id` int(10) unsigned NOT NULL,
  `modified_by` varchar(24) NOT NULL DEFAULT '',
  `modified_on` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`class_meeting_assessment_purpose_id`),
  UNIQUE KEY `class_meeting_id` (`class_meeting_id`,`assessment_purpose_enum_id`, `school_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `class_meeting_assessment_purpose_history` (
  `class_meeting_assessment_purpose_history_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `class_meeting_assessment_purpose_id` int(10) unsigned NOT NULL,
  `class_meeting_id` int(10) unsigned NOT NULL,
  `school_id` int(10) unsigned NOT NULL,
  `assessment_purpose_enum_id` int(10) unsigned NOT NULL,
  `modified_by` varchar(24) NOT NULL DEFAULT '',
  `modified_on` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `history_action` enum('Insert','Update','Delete') DEFAULT NULL,
  PRIMARY KEY (`class_meeting_assessment_purpose_history_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE IF NOT EXISTS `class_meeting_group` (
  `class_meeting_group_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `class_meeting_id1` int(10) unsigned NOT NULL,
  `class_meeting_id2` int(10) unsigned NOT NULL,
  `school_id` int(10) unsigned NOT NULL,
  `modified_by` varchar(24) NOT NULL DEFAULT '',
  `modified_on` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`class_meeting_group_id`),
  UNIQUE KEY `class_meeting_id` (`class_meeting_id1`, `class_meeting_id2`, `school_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `class_meeting_group_history` (
  `class_meeting_group_history_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `class_meeting_group_id` int(10) unsigned NOT NULL,
  `class_meeting_id1` int(10) unsigned NOT NULL,
  `class_meeting_id2` int(10) unsigned NOT NULL,
  `school_id` int(10) unsigned NOT NULL,
  `modified_by` varchar(24) NOT NULL DEFAULT '',
  `modified_on` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `history_action` enum('Insert','Update','Delete') DEFAULT NULL,
  PRIMARY KEY (`class_meeting_group_history_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


alter table class_meeting_type
add curriculum_method_enum_id int(10) unsigned NULL after label,
add method_code varchar(12) NULL after curriculum_method_enum_id;

alter table class_meeting_type_history
add curriculum_method_enum_id int(10) unsigned NULL after label,
add method_code varchar(12) NULL after curriculum_method_enum_id;

INSERT INTO enum_data VALUES 
(0, 'class_meeting_type.curriculum_method_id', 'instruction', 'Instructional Method', '', 'script', now()),
(0, 'class_meeting_type.curriculum_method_id', 'assessment', 'Assessment Method', '', 'script', now()),
(0, 'class_meeting_assessment_method.type_id', 'formative', 'Formative', '', 'script', now()),
(0, 'class_meeting_assessment_method.type_id', 'summative', 'Summative', '', 'script', now());
