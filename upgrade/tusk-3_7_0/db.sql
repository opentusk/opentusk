 CREATE TABLE `competency_type` (
  `competency_type_id` int(10) unsigned NOT NULL auto_increment,
  `school_id` int(10) unsigned NOT NULL,
  `description` varchar(255) NOT NULL,
  `created_by` varchar(24) NOT NULL default '',
  `created_on` datetime default NULL,
  `modified_by` varchar(24) default NULL,
  `modified_on` datetime default NULL,
  PRIMARY KEY  (`competency_type_id`),
  KEY `school_id` (`school_id`),
  CONSTRAINT `competency_type_ibfk_1` FOREIGN KEY (`school_id`) REFERENCES `school` (`school_id`)
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=latin1;

CREATE TABLE `competency_type_history` (
  `competency_type_history_id` int(10) unsigned NOT NULL auto_increment,
  `competency_type_id` int(10) unsigned NOT NULL,
  `school_id` int(10) unsigned NOT NULL,
  `description` varchar(255) NOT NULL,
  `created_by` varchar(24) NOT NULL default '',
  `created_on` datetime default NULL,
  `modified_by` varchar(24) default NULL,
  `modified_on` datetime default NULL,
  `history_action` enum('Insert','Update','Delete') default NULL,
  PRIMARY KEY  (`competency_type_history_id`),
  KEY `school_id` (`school_id`),
  KEY `competency_type_id` (`competency_type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=75 DEFAULT CHARSET=latin1;

CREATE TABLE `competency` (
  `competency_id` int(10) unsigned NOT NULL auto_increment,
  `school_id` int(10) unsigned NOT NULL,
  `title` varchar(120) NOT NULL default '',
  `description` text,
  `created_by` varchar(24) NOT NULL default '',
  `created_on` datetime default NULL,
  `modified_by` varchar(24) default NULL,
  `modified_on` datetime default NULL,
  PRIMARY KEY  (`competency_id`),
  KEY `school_id` (`school_id`),
  CONSTRAINT `competency_ibfk_2` FOREIGN KEY (`school_id`) REFERENCES `school` (`school_id`)
) ENGINE=InnoDB AUTO_INCREMENT=98 DEFAULT CHARSET=latin1;

CREATE TABLE `competency_history` (
  `competency_history_id` int(10) unsigned NOT NULL auto_increment,
  `competency_id` int(10) unsigned NOT NULL,
  `school_id` int(10) unsigned NOT NULL,
  `title` varchar(120) NOT NULL default '',
  `description` text,
  `created_by` varchar(24) NOT NULL default '',
  `created_on` datetime default NULL,
  `modified_by` varchar(24) default NULL,
  `modified_on` datetime default NULL,
  `history_action` enum('Insert','Update','Delete') default NULL,
  PRIMARY KEY  (`competency_history_id`),
  KEY `competency_id` (`competency_id`),
  KEY `school_id` (`school_id`)
) ENGINE=InnoDB AUTO_INCREMENT=237 DEFAULT CHARSET=latin1;

CREATE TABLE `competency_competency` (
  `competency_competency_id` int(10) unsigned NOT NULL auto_increment,
  `parent_competency_id` int(10) unsigned default NULL,
  `child_competency_id` int(10) unsigned default NULL,
  `sort_order` tinyint(3) unsigned default NULL,
  `created_by` varchar(24) NOT NULL default '',
  `created_on` datetime default NULL,
  `modified_by` varchar(24) default NULL,
  `modified_on` datetime default NULL,
  PRIMARY KEY  (`competency_competency_id`),
  KEY `parent_competency_id` (`parent_competency_id`),
  KEY `child_competency_id` (`child_competency_id`),
  CONSTRAINT `competency_competency_ibfk_1` FOREIGN KEY (`child_competency_id`) REFERENCES `competency` (`competency_id`)
) ENGINE=InnoDB AUTO_INCREMENT=96 DEFAULT CHARSET=latin1;

CREATE TABLE `competency_competency_history` (
  `competency_competency_history_id` int(10) unsigned NOT NULL auto_increment,
  `competency_competency_id` int(10) unsigned NOT NULL,
  `parent_competency_id` int(10) unsigned default NULL,
  `child_competency_id` int(10) unsigned default NULL,
  `sort_order` tinyint(3) unsigned default NULL,
  `history_action` enum('Insert','Update','Delete') default NULL,
  `created_by` varchar(24) NOT NULL default '',
  `created_on` datetime default NULL,
  `modified_by` varchar(24) default NULL,
  `modified_on` datetime default NULL,
  PRIMARY KEY  (`competency_competency_history_id`),
  KEY `competency_competency_id` (`competency_competency_id`),
  KEY `parent_competency_id` (`parent_competency_id`),
  KEY `child_competency_id` (`child_competency_id`)
) ENGINE=InnoDB AUTO_INCREMENT=879 DEFAULT CHARSET=latin1;

CREATE TABLE `competency_competency_type` (
  `competency_competency_type_id` int(10) unsigned NOT NULL auto_increment,
  `competency_id` int(10) unsigned default NULL,
  `competency_type_id` int(10) unsigned default NULL,
  `created_by` varchar(24) NOT NULL default '',
  `created_on` datetime default NULL,
  `modified_by` varchar(24) default NULL,
  `modified_on` datetime default NULL,
  PRIMARY KEY  (`competency_competency_type_id`),
  KEY `competency_id` (`competency_id`),
  KEY `competency_type_id` (`competency_type_id`),
  CONSTRAINT `competency_competency_type_ibfk_1` FOREIGN KEY (`competency_id`) REFERENCES `competency` (`competency_id`),
  CONSTRAINT `competency_competency_type_ibfk_2` FOREIGN KEY (`competency_type_id`) REFERENCES `competency_type` (`competency_type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=201 DEFAULT CHARSET=latin1;

CREATE TABLE `competency_competency_type_history` (
  `competency_competency_type_history_id` int(10) unsigned NOT NULL auto_increment,
  `competency_competency_type_id` int(10) unsigned NOT NULL,
  `competency_id` int(10) unsigned default NULL,
  `competency_type_id` int(10) unsigned default NULL,
  `created_by` varchar(24) NOT NULL default '',
  `created_on` datetime default NULL,
  `modified_by` varchar(24) default NULL,
  `modified_on` datetime default NULL,
  `history_action` enum('Insert','Update','Delete') default NULL,
  PRIMARY KEY  (`competency_competency_type_history_id`),
  KEY `competency_competency_type_id` (`competency_competency_type_id`),
  KEY `competency_id` (`competency_id`),
  KEY `competency_type_id` (`competency_type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=298 DEFAULT CHARSET=latin1;
