-- Tufts' TUSK installs have a special HSDB45 school (HSDB) which is not also an eval
-- school, and is thus lacking some eval tables. Here's SQL to recreate the missing tables.
-- To use: 
--          mysql hsdb45_hsdb_admin < create_eval_tables.sql
--
-- P.S.: It looks like the following tables exist in the HSDB DBs at Tufts, likely due 
-- to some install scripts which didn't skip over HSDB:
-- * eval_merged_results_histogram
-- * eval_merged_results_supporting_graphs
-- * eval_results_histogram
-- * eval_results_supporting_graphs

CREATE TABLE `eval` (
		  `eval_id` int(10) unsigned NOT NULL auto_increment,
		  `course_id` int(10) unsigned NOT NULL default '0',
		  `time_period_id` int(10) unsigned NOT NULL default '0',
		  `teaching_site_id` int(10) unsigned default NULL,
		  `title` varchar(128) NOT NULL default '',
		  `available_date` date NOT NULL default '0000-00-00',
		  `modified` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
		  `due_date` date NOT NULL default '0000-00-00',
		  `prelim_due_date` date default NULL,
		  `submittable_date` date default NULL,
		  `question_stylesheet` int(10) default NULL,
		  `results_stylesheet` int(10) default NULL,
		  PRIMARY KEY  (`eval_id`),
		  KEY `course_id` (`course_id`),
		  KEY `available_date` (`available_date`)
) ENGINE=MyISAM AUTO_INCREMENT=21078 DEFAULT CHARSET=latin1;

CREATE TABLE `eval_completion` (
		  `user_id` varchar(32) NOT NULL default '',
		  `eval_id` int(10) unsigned NOT NULL default '0',
		  `created` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
		  `status` enum('Done','Not done') NOT NULL default 'Not done',
		  PRIMARY KEY  (`user_id`,`eval_id`),
		  KEY `eval_id` (`eval_id`,`status`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1; 

CREATE TABLE `eval_mergedresults_graphics` (
		  `eval_mergedresults_graphics_id` int(10) unsigned NOT NULL auto_increment,
		  `merged_eval_results_id` int(10) unsigned NOT NULL default '0',
		  `eval_question_id` int(10) unsigned NOT NULL default '0',
		  `mime_type` varchar(128) NOT NULL default 'image/png',
		  `width` int(10) unsigned NOT NULL default '0',
		  `height` int(10) unsigned NOT NULL default '0',
		  `graphic` mediumblob NOT NULL,
		  `graphic_text` text,
		  `modified` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
		  PRIMARY KEY  (`eval_mergedresults_graphics_id`),
		  KEY `eval_id` (`merged_eval_results_id`,`eval_question_id`)
) ENGINE=MyISAM AUTO_INCREMENT=42580 DEFAULT CHARSET=latin1;

CREATE TABLE `eval_question` (
		  `eval_question_id` int(10) unsigned NOT NULL auto_increment,
		  `body` text,
		  `modified` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
		  PRIMARY KEY  (`eval_question_id`)
) ENGINE=MyISAM AUTO_INCREMENT=31517 DEFAULT CHARSET=latin1;

CREATE TABLE `eval_question_convert` (
		  `eval_question_id` int(10) unsigned NOT NULL default '0',
		  `new_body` text,
		  PRIMARY KEY  (`eval_question_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `eval_response` (
		  `user_code` varchar(32) NOT NULL default '0',
		  `eval_id` int(10) unsigned NOT NULL default '0',
		  `eval_question_id` int(10) unsigned NOT NULL default '0',
		  `response` text,
		  `fixed` char(1) default NULL,
		  `modified` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
		  PRIMARY KEY  (`eval_id`,`eval_question_id`,`user_code`),
		  KEY `user_code` (`user_code`,`eval_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `eval_results_graphics` (
		  `eval_results_graphics_id` int(10) unsigned NOT NULL auto_increment,
		  `eval_id` int(10) unsigned NOT NULL default '0',
		  `eval_question_id` int(10) unsigned NOT NULL default '0',
		  `categorization_question_id` int(10) unsigned default NULL,
		  `categorization_value` varchar(255) default NULL,
		  `mime_type` varchar(128) NOT NULL default 'image/png',
		  `width` int(10) unsigned NOT NULL default '0',
		  `height` int(10) unsigned NOT NULL default '0',
		  `graphic` mediumblob NOT NULL,
		  `graphic_text` text,
		  `modified` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
		  PRIMARY KEY  (`eval_results_graphics_id`),
		  KEY `eval_id` (`eval_id`,`eval_question_id`)
) ENGINE=MyISAM AUTO_INCREMENT=160373 DEFAULT CHARSET=latin1;

CREATE TABLE `eval_save_data` (
		  `eval_save_data_id` int(10) unsigned NOT NULL auto_increment,
		  `user_eval_code` varchar(128) NOT NULL default '',
		  `data` text,
		  PRIMARY KEY  (`eval_save_data_id`),
		  KEY `user_eval_code` (`user_eval_code`)
) ENGINE=MyISAM AUTO_INCREMENT=19560 DEFAULT CHARSET=latin1;

CREATE TABLE `link_eval_eval_question` (
		  `parent_eval_id` int(10) unsigned NOT NULL default '0',
		  `child_eval_question_id` int(10) unsigned NOT NULL default '0',
		  `label` varchar(32) default NULL,
		  `sort_order` smallint(5) unsigned NOT NULL default '0',
		  `required` enum('Yes','No') default 'No',
		  `grouping` varchar(255) default NULL,
		  `graphic_stylesheet` varchar(255) default NULL,
		  `modified` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
		  PRIMARY KEY  (`parent_eval_id`,`child_eval_question_id`),
		  KEY `parent_eval_id` (`parent_eval_id`,`sort_order`),
		  KEY `child_eval_question_id` (`child_eval_question_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

 CREATE TABLE `merged_eval_results` (
		  `merged_eval_results_id` int(14) unsigned NOT NULL auto_increment,
		  `title` varchar(128) default NULL,
		  `primary_eval_id` int(14) unsigned NOT NULL default '0',
		  `secondary_eval_ids` text,
		  `modified` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
		  PRIMARY KEY  (`merged_eval_results_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1710 DEFAULT CHARSET=latin1;
