use tusk;

alter table assignment add  `email_flag` tinyint(1) unsigned NOT NULL DEFAULT '0' after resubmit_flag;

CREATE TABLE `user_link` (
  `user_link_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` varchar(24) NOT NULL,
  `label` varchar(255) NOT NULL,
  `url` text NOT NULL,
  `sort_order` int(10) NOT NULL,
  `created_by` varchar(24) NOT NULL,
  `created_on` datetime NOT NULL,
  `modified_by` varchar(24) NOT NULL,
  `modified_on` datetime NOT NULL,
  PRIMARY KEY (`user_link_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `user_link_history` (
  `user_link_history_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_link_id` int(10) unsigned NOT NULL,
  `user_id` varchar(24) NOT NULL,
  `label` varchar(255) NOT NULL,
  `url` text NOT NULL,
  `sort_order` int(10) NOT NULL,
  `created_by` varchar(24) NOT NULL,
  `created_on` datetime NOT NULL,
  `modified_by` varchar(24) NOT NULL,
  `modified_on` datetime NOT NULL,
  `history_action` enum('Insert','Update','Delete') DEFAULT NULL,
  PRIMARY KEY (`user_link_history_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `user_announcement_hide` (
  `user_announcement_hide_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` varchar(24) NOT NULL,
  `announcement_id` int(10) unsigned NOT NULL,
  `school_id` int(10) unsigned NOT NULL,
  `hide_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_announcement_hide_id`),
  KEY `user_id` (`user_id`,`announcement_id`,`school_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `user_announcement_hide_history` (
  `user_announcement_hide_history_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_announcement_hide_id` int(10) unsigned NOT NULL,
  `user_id` varchar(24) NOT NULL,
  `announcement_id` int(10) unsigned NOT NULL,
  `school_id` int(10) unsigned NOT NULL,
  `hide_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `history_action` enum('Insert','Update','Delete') DEFAULT NULL,
  PRIMARY KEY (`user_announcement_hide_history_id`),
  KEY `user_id` (`user_id`,`announcement_id`,`school_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
