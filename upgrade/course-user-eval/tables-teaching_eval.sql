SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `eval_type` (
  `eval_type_id` smallint(2) unsigned NOT NULL auto_increment,
  `token` varchar(12) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `label` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci default NULL,
  `created_by` varchar(24) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL default '',
  `created_on` datetime NOT NULL default '0000-00-00 00:00:00',
  `modified_by` varchar(24) CHARACTER SET utf8 COLLATE utf8_general_ci default NULL,
  `modified_on` datetime default NULL,
  PRIMARY KEY  (`eval_type_id`),
  KEY (`token`)
) ENGINE=InnoDB DEFAULT CHARSET=UTF8;
SET character_set_client = @saved_cs_client; 


INSERT ignore INTO `eval_type` VALUES 
(1, 'course', 'Course Evaluation', 'script', now(), 'script', now()),
(2, 'teaching', 'Teaching Evaluation', 'script', now(), 'script', now());


/* 
  - for now these tables are for teaching evaluations but hopefully the table structure and name are generic enough to include/extend to other types of evals 
  - we should be able to derive course_id and time_period_id from eval_id
  - we need teaching site here since user_code is anonymous and evaluatee can be linked to more than one teaching_site in a course.
*/


drop table if exists enum_data;

SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `enum_data` (
  `enum_data_id` int(10) unsigned NOT NULL auto_increment,
  `namespace` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL default '',
  `short_name` varchar(12) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL default '',
  `display_name` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL default '',
  `description` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL default '',
  `created_by` varchar(24) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL default '',
  `created_on` datetime NOT NULL default '0000-00-00 00:00:00',
  `modified_by` varchar(24) CHARACTER SET utf8 COLLATE utf8_general_ci default NULL,
  `modified_on` datetime default NULL,
  PRIMARY KEY  (`enum_data_id`),
  KEY `namespace` (`namespace`),
  KEY `short_name` (`short_name`)
) ENGINE=InnoDB DEFAULT CHARSET=UTF8;
SET character_set_client = @saved_cs_client; 


INSERT ignore INTO `enum_data` VALUES 
(1, 'eval_association.status', 'saved', 'Saved', NULL, 'script', now(), 'script', now()),
(2, 'eval_association.status', 'completed', 'Completed', NULL, 'script', now(), 'script', now());


drop table if exists eval_entry;
drop table if exists eval_entry_history;
drop table if exists eval_association;
drop table if exists eval_association_history;

SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `eval_entry` (
  `eval_entry_id` int(10) unsigned NOT NULL auto_increment,
  `school_id` int(10) unsigned NOT NULL,
  `eval_id` int(10) unsigned NOT NULL,
  `evaluator_code` varchar(32) character set utf8 COLLATE utf8_general_ci NOT NULL,
  `evaluatee_id` varchar(24) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL default '',
  `teaching_site_id` int(10) unsigned NOT NULL,
  `created_by` varchar(24) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL default '',
  `created_on` datetime NOT NULL default '0000-00-00 00:00:00',
  `modified_by` varchar(24) CHARACTER SET utf8 COLLATE utf8_general_ci default NULL,
  `modified_on` datetime default NULL,
  PRIMARY KEY  (`eval_entry_id`),
  KEY `school_id` (`school_id`),
  KEY `eval_id` (`eval_id`),
  KEY `evaluator_code` (`evaluator_code`)
) ENGINE=InnoDB DEFAULT CHARSET=UTF8;
SET character_set_client = @saved_cs_client; 



SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `eval_entry_history` (
  `eval_entry_history_id` int(10) unsigned NOT NULL auto_increment,
  `eval_entry_id` int(10) unsigned NOT NULL,
  `school_id` int(10) unsigned NOT NULL,
  `eval_id` int(10) unsigned NOT NULL,
  `evaluator_code` varchar(32) character set utf8 COLLATE utf8_general_ci NOT NULL,
  `evaluatee_id` varchar(24) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL default '',
  `teaching_site_id` int(10) unsigned NOT NULL,
  `created_by` varchar(24) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL default '',
  `created_on` datetime NOT NULL default '0000-00-00 00:00:00',
  `modified_by` varchar(24) CHARACTER SET utf8 COLLATE utf8_general_ci default NULL,
  `modified_on` datetime default NULL,
  `history_action` enum('Insert','Update','Delete') default NULL,
  PRIMARY KEY  (`eval_entry_history_id`)
) ENGINE=InnoDB DEFAULT CHARSET=UTF8;
SET character_set_client = @saved_cs_client; 



SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `eval_association` (
  `eval_association_id` int(10) unsigned NOT NULL auto_increment,
  `school_id` int(10) unsigned NOT NULL,
  `eval_id` int(10) unsigned NOT NULL,
  `evaluator_id` varchar(24) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL default '',
  `evaluatee_id` varchar(24) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL default '',
  `status_enum_id` smallint default NULL,
  `status_date` datetime default NULL,
  `created_by` varchar(24) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL default '',
  `created_on` datetime NOT NULL default '0000-00-00 00:00:00',
  `modified_by` varchar(24) CHARACTER SET utf8 COLLATE utf8_general_ci default NULL,
  `modified_on` datetime default NULL,
  PRIMARY KEY  (`eval_association_id`),
  KEY `school_id` (`school_id`),
  KEY `eval_id` (`eval_id`),
  KEY `evaluator_id` (`evaluator_id`),
  KEY `evaluatee_id` (`evaluatee_id`)
/*  CONSTRAINT FOREIGN KEY (`status_enum_id`) REFERENCES `enum_data` (`enum_data_id`) ON DELETE SET NULL ON UPDATE CASCADE */
) ENGINE=InnoDB DEFAULT CHARSET=UTF8;
SET character_set_client = @saved_cs_client; 



SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `eval_association_history` (
  `eval_association_history_id` int(10) unsigned NOT NULL auto_increment,
  `eval_association_id` int(10) unsigned NOT NULL,
  `school_id` int(10) unsigned NOT NULL,
  `eval_id` int(10) unsigned NOT NULL,
  `evaluator_id` varchar(24) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL default '',
  `evaluatee_id` varchar(24) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL default '',
  `status_enum_id` smallint default NULL,
  `status_date` datetime default NULL,
  `created_by` varchar(24) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL default '',
  `created_on` datetime NOT NULL default '0000-00-00 00:00:00',
  `modified_by` varchar(24) CHARACTER SET utf8 COLLATE utf8_general_ci default NULL,
  `modified_on` datetime default NULL,
  `history_action` enum('Insert','Update','Delete') default NULL,
  PRIMARY KEY  (`eval_association_history_id`)
) ENGINE=InnoDB DEFAULT CHARSET=UTF8;
SET character_set_client = @saved_cs_client; 



SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `eval_role` (
  `eval_role_id` int(10) unsigned NOT NULL auto_increment,
  `school_id` int(10) unsigned NOT NULL,
  `eval_id` int(10) unsigned NOT NULL,
  `role_id` int(10) unsigned NOT NULL,  
  `sort_order` tinyint(3) unsigned NOT NULL,
  `required_evals`  tinyint(3) unsigned NOT NULL,
  `created_by` varchar(24) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL default '',
  `created_on` datetime NOT NULL default '0000-00-00 00:00:00',
  `modified_by` varchar(24) CHARACTER SET utf8 COLLATE utf8_general_ci default NULL,
  `modified_on` datetime default NULL,
  PRIMARY KEY  (`eval_role_id`),
  KEY `school_id` (`school_id`),
  KEY `eval_id` (`eval_id`),
  KEY `role_id` (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=UTF8;
SET character_set_client = @saved_cs_client; 


SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `eval_role_history` (
  `eval_role_history_id` int(10) unsigned NOT NULL auto_increment,
  `eval_role_id` int(10) unsigned NOT NULL,
  `school_id` int(10) unsigned NOT NULL,
  `eval_id` int(10) unsigned NOT NULL,
  `role_id` int(10) unsigned NOT NULL,  
  `sort_order` tinyint(3) unsigned NOT NULL,
  `required_evals`  tinyint(3) unsigned NOT NULL,
  `created_by` varchar(24) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL default '',
  `created_on` datetime NOT NULL default '0000-00-00 00:00:00',
  `modified_by` varchar(24) CHARACTER SET utf8 COLLATE utf8_general_ci default NULL,
  `modified_on` datetime default NULL,
  `history_action` enum('Insert','Update','Delete') default NULL,
  PRIMARY KEY  (`eval_role_history_id`)
) ENGINE=InnoDB DEFAULT CHARSET=UTF8;
SET character_set_client = @saved_cs_client; 
