alter table form_builder_form add require_approval int(1) unsigned default 0 after form_description;
alter table form_builder_form_history add require_approval int(1) unsigned default 0 after form_description;


CREATE TABLE `patient_log_approval` (
  `patient_log_approval_id` int(10) unsigned NOT NULL auto_increment,
  `form_id` int(10) unsigned default NULL,
  `user_id` varchar(50) default NULL,
  `approval_time` datetime,
  `approved_by` varchar(50),
  PRIMARY KEY  (`patient_log_approval_id`),
  KEY `form_id` (`form_id`),
  KEY `user_id` (`user_id`),
  KEY `approved_by` (`approved_by`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
