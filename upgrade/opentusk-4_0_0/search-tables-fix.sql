SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;

CREATE TABLE IF NOT EXISTS `search_result_category` (
  `search_result_category_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `school_id` int(10) unsigned NOT NULL DEFAULT '0',
  `category_label` varchar(255) NOT NULL DEFAULT '',
  `created_by` varchar(24) NOT NULL DEFAULT '',
  `created_on` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `modified_by` varchar(24) DEFAULT NULL,
  `modified_on` datetime DEFAULT NULL,
  PRIMARY KEY (`search_result_category_id`),
  KEY `search_result_category_i01` (`school_id`)
) ENGINE=MyISAM AUTO_INCREMENT=7 DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;


SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS`search_result_category_history` (
  `search_result_category_history_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `search_result_category_id` int(10) unsigned NOT NULL DEFAULT '0',
  `school_id` int(10) unsigned NOT NULL DEFAULT '0',
  `category_label` varchar(255) NOT NULL DEFAULT '',
  `created_by` varchar(24) NOT NULL DEFAULT '',
  `created_on` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `modified_by` varchar(24) DEFAULT NULL,
  `modified_on` datetime DEFAULT NULL,
  `history_action` enum('Insert','Update','Delete') DEFAULT NULL,
  PRIMARY KEY (`search_result_category_history_id`),
  KEY `search_result_category_history_i01` (`search_result_category_id`)
) ENGINE=MyISAM AUTO_INCREMENT=10 DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `search_result_type` (
  `search_result_type_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `type_name` varchar(255) NOT NULL DEFAULT '',
  `created_by` varchar(24) NOT NULL DEFAULT '',
  `created_on` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `modified_by` varchar(24) DEFAULT NULL,
  `modified_on` datetime DEFAULT NULL,
  PRIMARY KEY (`search_result_type_id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS  `search_result_type_history` (
  `search_result_type_history_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `search_result_type_id` int(10) unsigned NOT NULL DEFAULT '0',
  `type_name` varchar(255) NOT NULL DEFAULT '',
  `created_by` varchar(24) NOT NULL DEFAULT '',
  `created_on` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `modified_by` varchar(24) DEFAULT NULL,
  `modified_on` datetime DEFAULT NULL,
  `history_action` enum('Insert','Update','Delete') DEFAULT NULL,
  PRIMARY KEY (`search_result_type_history_id`),
  KEY `search_result_type_history_i01` (`search_result_type_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `search_term` (
  `search_term_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `search_result_id` int(10) unsigned NOT NULL DEFAULT '0',
  `search_term` varchar(255) NOT NULL DEFAULT '',
  `created_by` varchar(24) NOT NULL DEFAULT '',
  `created_on` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `modified_by` varchar(24) DEFAULT NULL,
  `modified_on` datetime DEFAULT NULL,
  PRIMARY KEY (`search_term_id`),
  KEY `search_term_i01` (`search_term_id`),
  KEY `search_term_i02` (`search_term`)
) ENGINE=MyISAM AUTO_INCREMENT=42 DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `search_term_history` (
  `search_term_history_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `search_term_id` int(10) unsigned NOT NULL DEFAULT '0',
  `search_result_id` int(10) unsigned NOT NULL DEFAULT '0',
  `search_term` varchar(255) NOT NULL DEFAULT '',
  `created_by` varchar(24) NOT NULL DEFAULT '',
  `created_on` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `modified_by` varchar(24) DEFAULT NULL,
  `modified_on` datetime DEFAULT NULL,
  `history_action` enum('Insert','Update','Delete') DEFAULT NULL,
  PRIMARY KEY (`search_term_history_id`),
  KEY `search_term_history_i01` (`search_term_id`)
) ENGINE=MyISAM AUTO_INCREMENT=66 DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `search_result_history` (
  `search_result_history_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `search_result_id` int(10) unsigned NOT NULL DEFAULT '0',
  `search_result_type_id` int(10) unsigned NOT NULL DEFAULT '0',
  `search_result_category_id` int(10) unsigned NOT NULL DEFAULT '0',
  `result_label` varchar(255) NOT NULL DEFAULT '',
  `result_url` text NOT NULL,
  `entity_id` int(10) unsigned DEFAULT NULL,
  `created_by` varchar(24) NOT NULL DEFAULT '',
  `created_on` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `modified_by` varchar(24) DEFAULT NULL,
  `modified_on` datetime DEFAULT NULL,
  `history_action` enum('Insert','Update','Delete') DEFAULT NULL,
  PRIMARY KEY (`search_result_history_id`),
  KEY `search_result_history_i01` (`search_result_id`)
) ENGINE=MyISAM AUTO_INCREMENT=38 DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

