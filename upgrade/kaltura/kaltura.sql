USE tusk;

CREATE TABLE IF NOT EXISTS `content_kaltura` (
  `content_kaltura_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `content_id` int(10) unsigned NOT NULL DEFAULT '0',
  `kaltura_id` varchar(24) DEFAULT NULL,
  `added_on` datetime DEFAULT NULL,
  `processed_on` datetime DEFAULT NULL,
  `error` text,
  `modified_by` varchar(24) DEFAULT NULL,
  `modified_on` datetime DEFAULT NULL,
  PRIMARY KEY (`content_kaltura_id`),
  UNIQUE KEY `content_id` (`content_id`),
  KEY `kaltura_id` (`kaltura_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `content_kaltura_history` (
  `content_kaltura_history_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `content_kaltura_id` int(10) unsigned NOT NULL,
  `content_id` int(10) unsigned NOT NULL DEFAULT '0',
  `kaltura_id` varchar(24) DEFAULT NULL,
  `added_on` datetime DEFAULT NULL,
  `processed_on` datetime DEFAULT NULL,
  `error` text,
  `modified_by` varchar(24) DEFAULT NULL,
  `modified_on` datetime DEFAULT NULL,
  `history_action` enum('Delete', 'Insert', 'Update'),
  PRIMARY KEY (`content_kaltura_history_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
