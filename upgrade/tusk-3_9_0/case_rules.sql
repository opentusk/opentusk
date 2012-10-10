#####
# Dropping of tables that are created below. Primarily for development. That is why I have 
# commented it here. Could have been deleted, but figured it might be handy during
# installation (at least on test).
#DROP TABLE IF EXISTS tusk.case_rule_operand_relation;
#DROP TABLE IF EXISTS tusk.case_rule_operand;
#DROP TABLE IF EXISTS tusk.case_rule;

#DROP TABLE IF EXISTS tusk.case_rule_element_type;
#DROP TABLE IF EXISTS tusk.case_rule_operator_type;
#DROP TABLE IF EXISTS tusk.case_rule_relation_type;

#DROP TABLE IF EXISTS tusk.case_rule_history;
#DROP TABLE IF EXISTS tusk.case_rule_operand_history;
#DROP TABLE IF EXISTS tusk.case_rule_operand_relation_history;

#####
# Create our main tables
CREATE TABLE tusk.case_rule_element_type (
  `rule_element_type_id` tinyint(3) unsigned NOT NULL auto_increment,
  `label` varchar(64) NOT NULL default '',
  `created_by` varchar(24) NOT NULL default '',
  `created_on` datetime NOT NULL default '0000-00-00 00:00:00',
  `modified_by` varchar(24) NOT NULL default '',
  `modified_on` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`rule_element_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE tusk.case_rule_operator_type (
  `rule_operator_type_id` tinyint(3) unsigned NOT NULL auto_increment,
  `label` varchar(32) NOT NULL default '',
  `created_by` varchar(24) NOT NULL default '',
  `created_on` datetime NOT NULL default '0000-00-00 00:00:00',
  `modified_by` varchar(24) NOT NULL default '',
  `modified_on` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`rule_operator_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE tusk.case_rule_relation_type (
  `rule_relation_type_id` tinyint(3) unsigned NOT NULL auto_increment,
  `label` varchar(16) NOT NULL default '',
  `created_by` varchar(24) NOT NULL default '',
  `created_on` datetime NOT NULL default '0000-00-00 00:00:00',
  `modified_by` varchar(24) NOT NULL default '',
  `modified_on` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`rule_relation_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE tusk.case_rule (
  `rule_id` int(10) unsigned NOT NULL auto_increment,
  `phase_id` int(10) unsigned NOT NULL,
  `rule_operator_type_id` tinyint(3) unsigned NOT NULL,
  `message` text default NULL,
  `created_by` varchar(24) NOT NULL default '',
  `created_on` datetime NOT NULL default '0000-00-00 00:00:00',
  `modified_by` varchar(24) NOT NULL default '',
  `modified_on` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`rule_id`),
  KEY `phase_id` (`phase_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE tusk.case_rule_operand (
  `rule_operand_id` int(10) unsigned NOT NULL auto_increment,
  `rule_id` int(10) unsigned NOT NULL,
  `phase_id` int(10) unsigned NOT NULL,
  `element_id` int(10) unsigned default NULL,
  `rule_element_type_id` tinyint(3) unsigned default NULL,
  `created_by` varchar(24) NOT NULL default '',
  `created_on` datetime NOT NULL default '0000-00-00 00:00:00',
  `modified_by` varchar(24) NOT NULL default '',
  `modified_on` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`rule_operand_id`),
  FOREIGN KEY (`rule_id`) REFERENCES case_rule (`rule_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE tusk.case_rule_operand_relation (
  `rule_operand_relation_id` int(10) unsigned NOT NULL auto_increment,
  `rule_operand_id` int(10) unsigned NOT NULL,
  `rule_relation_type_id` tinyint(3) unsigned NOT NULL,
  `value` tinyint(3) unsigned NOT NULL default 0,
  `created_by` varchar(24) NOT NULL default '',
  `created_on` datetime NOT NULL default '0000-00-00 00:00:00',
  `modified_by` varchar(24) NOT NULL default '',
  `modified_on` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`rule_operand_relation_id`),
  FOREIGN KEY (`rule_operand_id`) REFERENCES case_rule_operand (`rule_operand_id`),
  FOREIGN KEY (`rule_relation_type_id`) REFERENCES case_rule_relation_type (`rule_relation_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


#####
# Create our history tables
CREATE TABLE tusk.case_rule_history (
  `rule_history_id` int(10) unsigned NOT NULL auto_increment,
  `rule_id` int(10) unsigned NOT NULL,
  `phase_id` int(10) unsigned NOT NULL,
  `rule_operator_type_id` tinyint(3) unsigned NOT NULL,
  `message` text default NULL,
  `created_by` varchar(24) NOT NULL default '',
  `created_on` datetime NOT NULL default '0000-00-00 00:00:00',
  `modified_by` varchar(24) NOT NULL default '',
  `modified_on` datetime NOT NULL default '0000-00-00 00:00:00',
  `history_action` enum('Insert','Update','Delete') default NULL,
  PRIMARY KEY  (`rule_history_id`),
  KEY `rule_id` (`rule_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE tusk.case_rule_operand_history (
  `rule_operand_history_id` int(10) unsigned NOT NULL auto_increment,
  `rule_operand_id` int(10) unsigned NOT NULL,
  `rule_id` int(10) unsigned NOT NULL,
  `phase_id` int(10) unsigned NOT NULL,
  `element_id` int(10) unsigned default NULL,
  `rule_element_type_id` tinyint(3) unsigned default NULL,
  `created_by` varchar(24) NOT NULL default '',
  `created_on` datetime NOT NULL default '0000-00-00 00:00:00',
  `modified_by` varchar(24) NOT NULL default '',
  `modified_on` datetime NOT NULL default '0000-00-00 00:00:00',
  `history_action` enum('Insert','Update','Delete') default NULL,
  PRIMARY KEY  (`rule_operand_history_id`),
  KEY (`rule_operand_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE tusk.case_rule_operand_relation_history (
  `rule_operand_relation_history_id` int(10) unsigned NOT NULL auto_increment,
  `rule_operand_relation_id` int(10) unsigned NOT NULL,
  `rule_operand_id` int(10) unsigned NOT NULL,
  `rule_relation_type_id` tinyint(3) unsigned NOT NULL,
  `value` tinyint(3) unsigned NOT NULL default 0,
  `created_by` varchar(24) NOT NULL default '',
  `created_on` datetime NOT NULL default '0000-00-00 00:00:00',
  `modified_by` varchar(24) NOT NULL default '',
  `modified_on` datetime NOT NULL default '0000-00-00 00:00:00',
  `history_action` enum('Insert','Update','Delete') default NULL,
  PRIMARY KEY  (`rule_operand_relation_history_id`),
  KEY  (`rule_operand_relation_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;



INSERT into tusk.case_rule_operator_type (label, created_by, created_on, modified_by, modified_on) values ('AND', 'dwalke01', now(), 'dwalke01', now()), ('OR', 'dwalke01', now(), 'dwalke01', now());

INSERT into tusk.case_rule_element_type (label, created_by, created_on, modified_by, modified_on) values 
('option', 'dwalke01', now(), 'dwalke01', now()), 
('test', 'dwalke01', now(), 'dwalke01', now()), 
('quiz', 'dwalke01', now(), 'dwalke01', now()), 
('quiz_question', 'dwalke01', now(), 'dwalke01', now()), 
('quiz_score', 'dwalke01', now(), 'dwalke01', now());

INSERT into tusk.case_rule_relation_type (label, created_by, created_on, modified_by, modified_on) values 
('==', 'dwalke01', now(), 'dwalke01', now()),
('!=', 'dwalke01', now(), 'dwalke01', now()),
('>', 'dwalke01', now(), 'dwalke01', now()), 
('<', 'dwalke01', now(), 'dwalke01', now()), 
('>=', 'dwalke01', now(), 'dwalke01', now()), 
('<=', 'dwalke01', now(), 'dwalke01', now()) 
;

alter table tusk.quiz add column hide_correct_answer tinyint(1) unsigned not null default 0 after show_all_feedback;

alter table tusk.quiz_history add column hide_correct_answer tinyint(1) unsigned not null default 0 after show_all_feedback;