ALTER TABLE enum_data 
DROP COLUMN created_by, DROP COLUMN created_on;

CREATE TABLE IF NOT EXISTS `feature_link` (
  `feature_link_id` int(10) unsigned NOT NULL auto_increment,
  `feature_type_enum_id` int(10) unsigned NOT NULL, 
  `feature_id` int(10) unsigned NOT NULL,  
  `url` varchar(255) NOT NULL,
  `modified_by` varchar(24) NOT NULL DEFAULT '',
  `modified_on` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`feature_link_id`),
  KEY (`feature_type_enum_id`),
  KEY (`feature_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `feature_link_history` (
  `feature_link_history_id` int(10) unsigned NOT NULL auto_increment,
  `feature_link_id` int(10) unsigned NOT NULL,
  `feature_type_enum_id` int(10) unsigned NOT NULL,
  `feature_id` int(10) unsigned NOT NULL,
  `url` varchar(255) NOT NULL,
  `modified_by` varchar(24) NOT NULL DEFAULT '',
  `modified_on` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `history_action` enum('Insert','Update','Delete') DEFAULT NULL,
  PRIMARY KEY (`feature_link_history_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO enum_data VALUES
(0, 'feature_link.feature_type', 'competency', 'Competency', 'URIs for national Competencies', 'script', now());
