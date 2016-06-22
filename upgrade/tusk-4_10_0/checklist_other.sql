USE hsdb4;

ALTER table hsdb4.user 
CHANGE uid uid int(10) NOT NULL after user_id,
CHANGE firstname firstname varchar(20) CHARACTER SET utf8 NOT NULL DEFAULT '' after uid,
CHANGE midname midname varchar(20) CHARACTER SET utf8 DEFAULT NULL after firstname,
CHANGE lastname lastname varchar(40) CHARACTER SET utf8 NOT NULL DEFAULT '' after midname,
CHANGE suffix suffix varchar(10) CHARACTER SET utf8 DEFAULT NULL after lastname,
CHANGE loggedout_flag loggedout_flag int(1) unsigned DEFAULT '1' after previous_login,
CHANGE password_reset password_reset datetime DEFAULT NULL after password;


USE tusk;

ALTER table enum_data 
CHANGE description description varchar(200) NOT NULL DEFAULT '' after short_name;

INSERT INTO enum_data VALUES
(0, 'user_creation.source_id', 'checklist', 'Competency Checklist App', 'Generated by competency checklist application', 'script', now()),
(0, 'user_creation.source_id', 'evaluation', 'Evaluation App', 'Generated by evaluation application', 'script', now());

SET @FEATURE_TYPE_ID = (SELECT feature_type_id FROM permission_feature_type WHERE feature_type_token = 'course');
INSERT INTO permission_role VALUES (0, 'healthprof', 'Healthcare Professional', @FEATURE_TYPE_ID, 1, 'script', now(), 'script', now());

CREATE TABLE IF NOT EXISTS `user_creation` (
  `user_creation_id` int(10) unsigned NOT NULL auto_increment,
  `user_id` varchar(24) DEFAULT NULL,
  `source_enum_id` int(10) unsigned NOT NULL,
  `object_id` int(10) unsigned NOT NULL,
  `modified_by` varchar(24) DEFAULT NULL,
  `modified_on` datetime DEFAULT NULL,
  PRIMARY KEY (`user_creation_id`),
  KEY `source_enum_id` (`source_enum_id`),
  KEY `object_id` (`object_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
