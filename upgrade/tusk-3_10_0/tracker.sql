# drop tables in this order to avoid foreign key constraints.
DROP TABLE IF EXISTS tusk.process_tracker;
DROP TABLE IF EXISTS tusk.process_tracker_status_type;
DROP TABLE IF EXISTS tusk.process_tracker_type;



# now create tables
create table tusk.process_tracker_type (
	`process_tracker_type_id` int(10) unsigned NOT NULL auto_increment,
	`token` varchar(50) NOT NULL, 
	`label` varchar(255) NOT NULL, 
	`created_by` varchar(24) NOT NULL default '', 
	`created_on` datetime NOT NULL default '0000-00-00 00:00:00',
	`modified_by` varchar(24) NOT NULL default '',
	`modified_on` datetime NOT NULL default '0000-00-00 00:00:00',
	PRIMARY KEY (`process_tracker_type_id`),
	KEY `process_tracker_type_i01` (`token`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


create table tusk.process_tracker_status_type (
	`process_tracker_status_type_id` int(10) unsigned NOT NULL auto_increment,
	`token` varchar(50) NOT NULL, 
	`label` varchar(255) NOT NULL, 
	`description` varchar(750) NOT NULL default '', 
	`created_by` varchar(24) NOT NULL default '', 
	`created_on` datetime NOT NULL default '0000-00-00 00:00:00',
	`modified_by` varchar(24) NOT NULL default '',
	`modified_on` datetime NOT NULL default '0000-00-00 00:00:00',
	PRIMARY KEY (`process_tracker_status_type_id`),
	KEY `process_tracker_status_type_i01` (`token`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


create table tusk.process_tracker (
	`process_tracker_id` int(10) unsigned NOT NULL auto_increment,
	`school_id` int(10) unsigned,
	`object_id` int(10) unsigned NOT NULL,
	`process_tracker_type_id` int(10) unsigned NOT NULL,
	`process_tracker_status_type_id` int(10) unsigned NOT NULL,
	`created_by` varchar(24) NOT NULL default '', 
	`created_on` datetime NOT NULL default '0000-00-00 00:00:00',
	`modified_by` varchar(24) NOT NULL default '',
	`modified_on` datetime NOT NULL default '0000-00-00 00:00:00',
	PRIMARY KEY (`process_tracker_id`),
	KEY `process_tracker_i01` (`object_id`),
	KEY `process_tracker_i02` (`process_tracker_type_id`),
	KEY `process_tracker_i03` (`process_tracker_status_type_id`),
	KEY `process_tracker_i04` (`school_id`),
	FOREIGN KEY (`process_tracker_type_id`) REFERENCES tusk.process_tracker_type (`process_tracker_type_id`),
	FOREIGN KEY (`process_tracker_status_type_id`) REFERENCES tusk.process_tracker_status_type (`process_tracker_status_type_id`),
	FOREIGN KEY (`school_id`) REFERENCES tusk.school (`school_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;





##########
## HISTORY TABLE
##########

DROP TABLE IF EXISTS tusk.process_tracker_history;
create table tusk.process_tracker_history (
	`process_tracker_history_id` int(10) unsigned NOT NULL auto_increment,
	`process_tracker_id` int(10) unsigned NOT NULL,
	`school_id` int(10) unsigned,
	`object_id` int(10) unsigned NOT NULL,
	`process_tracker_type_id` int(10) unsigned NOT NULL,
	`process_tracker_status_type_id` int(10) unsigned NOT NULL,
	`created_by` varchar(24) NOT NULL default '', 
	`created_on` datetime NOT NULL default '0000-00-00 00:00:00',
	`modified_by` varchar(24) NOT NULL default '',
	`modified_on` datetime NOT NULL default '0000-00-00 00:00:00',
	`history_action` enum('Insert','Update','Delete') default NULL,
	PRIMARY KEY (`process_tracker_history_id`),
	KEY `process_tracker_history_i01` (`process_tracker_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;



##########
## Prime WITH DATA
##########

insert into tusk.process_tracker_type (token, label, created_by, created_on, modified_by, modified_on) values ('tuskdoc', 'TUSKdoc', 'dwalke01', now(), 'dwalke01', now());


insert into tusk.process_tracker_status_type (token, label, created_by, created_on, modified_by, modified_on) values ('tuskdoc_received', 'Received', 'dwalke01', now(), 'dwalke01', now());
insert into tusk.process_tracker_status_type (token, label, created_by, created_on, modified_by, modified_on) values ('tuskdoc_processing', 'Processing', 'dwalke01', now(), 'dwalke01', now());
insert into tusk.process_tracker_status_type (token, label, created_by, created_on, modified_by, modified_on) values ('tuskdoc_completed', 'Completed', 'dwalke01', now(), 'dwalke01', now());
insert into tusk.process_tracker_status_type (token, label, created_by, created_on, modified_by, modified_on) values ('tuskdoc_completed_warn', 'Completed (with warnings)', 'dwalke01', now(), 'dwalke01', now());
insert into tusk.process_tracker_status_type (token, label, created_by, created_on, modified_by, modified_on) values ('tuskdoc_error', 'Error', 'dwalke01', now(), 'dwalke01', now());

