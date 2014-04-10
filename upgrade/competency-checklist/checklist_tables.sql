use tusk;

CREATE TABLE IF NOT EXISTS `competency_checklist_group` (
  `competency_checklist_group_id` int(10) unsigned NOT NULL auto_increment,
  `school_id` int(10) unsigned NOT NULL,
  `course_id` int(10) unsigned NOT NULL,
  `title` varchar(100) NOT NULL default '',
  `description` varchar(200) NOT NULL default '',
  `publish_flag` tinyint(1) unsigned default 0,
  `modified_by` varchar(24) default NULL,
  `modified_on` datetime default NULL,
  PRIMARY KEY  (`competency_checklist_group_id`),
  KEY (`school_id`),
  KEY (`course_id`),
) ENGINE=InnoDB DEFAULT CHARSET=UTF8;


CREATE TABLE IF NOT EXISTS `competency_checklist_group_history` (
  `competency_checklist_group_history_id` int(10) unsigned NOT NULL auto_increment,
  `competency_checklist_group_id` int(10) unsigned NOT NULL,
  `school_id` int(10) unsigned NOT NULL,
  `course_id` int(10) unsigned NOT NULL,
  `title` varchar(100) NOT NULL default '',
  `description` varchar(200) NOT NULL default '',
  `publish_flag` tinyint(1) unsigned default 0,
  `modified_by` varchar(24) default NULL,
  `modified_on` datetime default NULL,
  `history_action` enum('Insert','Update','Delete') DEFAULT NULL,
  PRIMARY KEY  (`competency_checklist_group_history_id`)
) ENGINE=InnoDB DEFAULT CHARSET=UTF8;


CREATE TABLE IF NOT EXISTS `competency_checklist` (
  `competency_checklist_id` int(10) unsigned NOT NULL auto_increment,
  `competency_checklist_group_id` int(10) unsigned NOT NULL,
  `competency_id` int(10) unsigned NOT NULL,
  `description` varchar(200) default NULL,
  `required` tinyint(1) unsigned default 0,
  `self_assessed` tinyint(1) NOT NULL default 1,
  `partner_assessed` tinyint(1) NOT NULL default 1,
  `faculty_assessed` tinyint(1) NOT NULL default 1,
  `modified_by` varchar(24) default NULL,
  `modified_on` datetime default NULL,
  PRIMARY KEY  (`competency_checklist_id`),
  KEY (`competency_checklist_group_id`),
  KEY (`competency_id`)
) ENGINE=InnoDB DEFAULT CHARSET=UTF8;


CREATE TABLE IF NOT EXISTS `competency_checklist_history` (
  `competency_checklist_history_id` int(10) unsigned NOT NULL auto_increment,
  `competency_checklist_id` int(10) unsigned NOT NULL,
  `competency_checklist_group_id` int(10) unsigned NOT NULL,
  `competency_id` int(10) unsigned NOT NULL,
  `description` varchar(200) default NULL,
  `required` tinyint(1) unsigned default 0,
  `self_assessed` tinyint(1) NOT NULL default 1,
  `partner_assessed` tinyint(1) NOT NULL default 1,
  `faculty_assessed` tinyint(1) NOT NULL default 1,
  `modified_by` varchar(24) default NULL,
  `modified_on` datetime default NULL,
  `history_action` enum('Insert','Update','Delete') DEFAULT NULL,
  PRIMARY KEY  (`competency_checklist_history_id`)
) ENGINE=InnoDB DEFAULT CHARSET=UTF8;

CREATE TABLE IF NOT EXISTS `enum_data` (
  `enum_data_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `namespace` varchar(50) NOT NULL DEFAULT '',
  `short_name` varchar(12) NOT NULL DEFAULT '',
  `display_name` varchar(100) DEFAULT NULL,
  `description` varchar(200) NOT NULL DEFAULT '',
  `created_by` varchar(24) NOT NULL DEFAULT '',
  `created_on` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `modified_by` varchar(24) DEFAULT NULL,
  `modified_on` datetime DEFAULT NULL,
  PRIMARY KEY (`enum_data_id`),
  KEY `namespace` (`namespace`),
  KEY `short_name` (`short_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

insert into enum_data values 
	(0, 'competency_checklist_assignment.assessor_type', 'self', 'Self', '', 'script', now(), 'script', now()),
	(0, 'competency_checklist_assignment.assessor_type', 'partner', 'Partner', '', 'script', now(), 'script', now()),
	(0, 'competency_checklist_assignment.assessor_type', 'faculty', 'Faculty', '', 'script', now(), 'script', now());


CREATE TABLE IF NOT EXISTS `competency_checklist_assignment` (
  `competency_checklist_assignment_id` int(10) unsigned NOT NULL auto_increment,
  `competency_checklist_group_id` int(10) unsigned NOT NULL,
  `time_period_id` int(10) unsigned NOT NULL,
  `student_id` varchar(24) NOT NULL,
  `assessor_id` varchar(24) NULL,
  `assessor_type_enum_id` tinyint(1) default 1,
  `modified_by` varchar(24) default NULL,
  `modified_on` datetime default NULL,
  PRIMARY KEY  (`competency_checklist_assignment_id`),
  KEY (`competency_checklist_group_id`),
  KEY (`student_id`)
) ENGINE=InnoDB DEFAULT CHARSET=UTF8;


CREATE TABLE IF NOT EXISTS `competency_checklist_assignment_history` (
  `competency_checklist_assignment_history_id` int(10) unsigned NOT NULL auto_increment,
  `competency_checklist_assignment_id` int(10) unsigned NOT NULL,
  `competency_checklist_group_id` int(10) unsigned NOT NULL,
  `time_period_id` int(10) unsigned NOT NULL,
  `student_id` varchar(24) NOT NULL,
  `assessor_id` varchar(24) NULL,
  `assessor_type_enum_id` tinyint(1) default 1,
  `modified_by` varchar(24) default NULL,
  `modified_on` datetime default NULL,
  `history_action` enum('Insert','Update','Delete') DEFAULT NULL,
  PRIMARY KEY  (`competency_checklist_assignment_history_id`)
) ENGINE=InnoDB DEFAULT CHARSET=UTF8;


CREATE TABLE IF NOT EXISTS `competency_checklist_entry` (
  `competency_checklist_entry_id` int(10) unsigned NOT NULL auto_increment,
  `competency_checklist_id` int(10) unsigned NOT NULL,
  `competency_checklist_assignment_id` int(10) unsigned NOT NULL,
  `request_date` datetime default NULL,
  `notify_date` datetime default NULL,
  `complete_date` datetime default NULL,
  `assessor_comment` text default NULL,
  `student_comment` text default NULL,
  `modified_by` varchar(24) default NULL,
  `modified_on` datetime default NULL,
  PRIMARY KEY  (`competency_checklist_entry_id`),
  KEY (`competency_checklist_id`)
  KEY (`competency_assignment_id`)
) ENGINE=InnoDB DEFAULT CHARSET=UTF8;


CREATE TABLE IF NOT EXISTS `competency_checklist_entry_history` (
  `competency_checklist_entry_history_id` int(10) unsigned NOT NULL auto_increment,
  `competency_checklist_entry_id` int(10) unsigned NOT NULL,
  `competency_checklist_id` int(10) unsigned NOT NULL,
  `competency_checklist_assignment_id` int(10) unsigned NOT NULL,
  `request_date` datetime default NULL,
  `notify_date` datetime default NULL,
  `complete_date` datetime default NULL,
  `assessor_comment` text default NULL,
  `student_comment` text default NULL,
  `modified_by` varchar(24) default NULL,
  `modified_on` datetime default NULL,
  `history_action` enum('Insert','Update','Delete') DEFAULT NULL,
  PRIMARY KEY  (`competency_checklist_entry_history_id`)
) ENGINE=InnoDB DEFAULT CHARSET=UTF8;


CREATE TABLE IF NOT EXISTS `competency_checklist_completion` (
  `competency_checklist_completion_id` int(10) unsigned NOT NULL auto_increment,
  `competency_checklist_entry_id` int(10) unsigned NOT NULL,
  `competency_id` int(10) unsigned NOT NULL,
  `completed` tinyint(1) unsigned NOT NULL,
  `modified_by` varchar(24) default NULL,
  `modified_on` datetime default NULL,
  PRIMARY KEY  (`competency_checklist_completion_id`),
  KEY (`competency_checklist_entry_id`)
) ENGINE=InnoDB DEFAULT CHARSET=UTF8;

CREATE TABLE IF NOT EXISTS `competency_checklist_completion_history` (
  `competency_checklist_completion_history_id` int(10) unsigned NOT NULL auto_increment,
  `competency_checklist_completion_id` int(10) unsigned NOT NULL,
  `competency_checklist_entry_id` int(10) unsigned NOT NULL,
  `competency_id` int(10) unsigned NOT NULL,
  `completed` tinyint(1) unsigned NOT NULL,
  `modified_by` varchar(24) default NULL,
  `modified_on` datetime default NULL,
  `history_action` enum('Insert','Update','Delete') DEFAULT NULL,
  PRIMARY KEY  (`competency_checklist_completion_history_id`)
) ENGINE=InnoDB DEFAULT CHARSET=UTF8;

