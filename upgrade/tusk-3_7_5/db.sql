CREATE TABLE `competency_relationship` (
  `competency_relationship_id` int(10) unsigned NOT NULL auto_increment,
  `school_id` int(10) unsigned default NULL,
  `lineage` varchar(255) default NULL,
  `parent_competency_id` int(10) unsigned default '0',
  `child_competency_id` int(10) unsigned default NULL,
  `sort_order` tinyint(3) unsigned default NULL,
  `depth` tinyint(3) unsigned default '0',
  `created_by` varchar(24) NOT NULL default '',
  `created_on` datetime default NULL,
  `modified_by` varchar(24) default NULL,
  `modified_on` datetime default NULL,
  PRIMARY KEY  (`competency_relationship_id`),
  KEY `parent_competency_id` (`parent_competency_id`),
  KEY `child_competency_id` (`child_competency_id`),
  KEY `lineage` (`lineage`),
  KEY `school_id` (`school_id`),
  CONSTRAINT `competency_relationship_ibfk_1` FOREIGN KEY (`child_competency_id`) REFERENCES `competency` (`competency_id`),
  CONSTRAINT `competency_relationship_ibfk_2` FOREIGN KEY (`school_id`) REFERENCES `school` (`school_id`)
) ENGINE=InnoDB;


CREATE TABLE `competency_relationship_history` (
  `competency_relationship_history_id` int(10) unsigned NOT NULL auto_increment,
  `competency_relationship_id` int(10) unsigned NOT NULL,
  `school_id` int(10) unsigned default NULL,
  `lineage` varchar(255) default NULL,
  `parent_competency_id` int(10) unsigned default '0',
  `child_competency_id` int(10) unsigned default NULL,
  `sort_order` tinyint(3) unsigned default NULL,
  `depth` tinyint(3) unsigned default '0',
  `created_by` varchar(24) NOT NULL default '',
  `created_on` datetime default NULL,
  `modified_by` varchar(24) default NULL,
  `modified_on` datetime default NULL,
  `history_action` enum('Insert','Update','Delete') default NULL,
  PRIMARY KEY  (`competency_relationship_history_id`),
  KEY `competency_relationship_id` (`competency_relationship_id`),
  KEY `parent_competency_id` (`parent_competency_id`),
  KEY `child_competency_id` (`child_competency_id`),
  KEY `lineage` (`lineage`),
  KEY `school_id` (`school_id`)
) ENGINE=InnoDB;

CREATE TABLE `grade_event_eval` (
  `grade_event_eval_id` int(10) unsigned NOT NULL auto_increment,
  `grade_event_id` int(10) unsigned NOT NULL,
  `eval_id` int(10) unsigned default NULL,
  `created_by` varchar(24) NOT NULL default '',
  `created_on` datetime default NULL,
  `modified_by` varchar(24) default NULL,
  `modified_on` datetime default NULL,
  PRIMARY KEY  (`grade_event_eval_id`),
  KEY `grade_event_id` (`grade_event_id`),
  KEY `eval_id` (`eval_id`)
) ENGINE=InnoDB;

CREATE TABLE `grade_event_eval_history` (
  `grade_event_eval_history_id` int(10) unsigned NOT NULL auto_increment,
  `grade_event_eval_id` int(10) unsigned NOT NULL,
  `grade_event_id` int(10) unsigned NOT NULL,
  `eval_id` int(10) unsigned default NULL,
  `created_by` varchar(24) NOT NULL default '',
  `created_on` datetime default NULL,
  `modified_by` varchar(24) default NULL,
  `modified_on` datetime default NULL,
  `history_action` enum('Insert','Update','Delete') default NULL,
  PRIMARY KEY  (`grade_event_eval_history_id`),
  KEY `grade_event_eval_id` (`grade_event_eval_id`),
  KEY `grade_event_id` (`grade_event_id`),
  KEY `eval_id` (`eval_id`)
) ENGINE=InnoDB;

