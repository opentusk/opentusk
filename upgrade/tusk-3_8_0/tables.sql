insert into form_builder_form_type 
values (0, 'Assessment', 'Assessment', 'isathi01', now(), 'isathi01', now());

insert into form_builder_field_type values 
(0, 'Scaling', 'Scaling', 'isathi01', now(), 'isathi01', now());

alter table form_builder_entry_association add is_final tinyint(1) unsigned NOT NULL default 0 after user_id;
alter table form_builder_entry_association_history add is_final tinyint(1) unsigned NOT NULL default 0  after user_id;

alter table form_builder_response add score float unsigned NULL after active_flag;
alter table form_builder_response_history add score float unsigned NULL after active_flag;

alter table form_builder_field add show_comment tinyint(1) unsigned NOT NULL default '0' after fillin_size;
alter table form_builder_field_history add show_comment tinyint(1) unsigned NOT NULL default '0' after fillin_size;

alter table form_builder_field add weight float NOT NULL default 0 after trailing_text;
alter table form_builder_field_history add weight float NOT NULL default 0 after trailing_text;

DROP TABLE IF EXISTS form_builder_assessment;
DROP TABLE IF EXISTS form_builder_assessment_history;

CREATE TABLE form_builder_assessment (
	assessment_id int(10) unsigned NOT NULL auto_increment,
	form_id int(10) unsigned NOT NULL,
  	grade_event_id int(10) unsigned default NULL,
	score_display tinyint(1) unsigned NOT NULL default '0',
	score_range tinyint(1) unsigned NOT NULL default '0',
	show_images tinyint(1) unsigned NOT NULL default '0',	
	show_elective tinyint(1) unsigned NOT NULL default '0',	
	multi_assessors tinyint(1) unsigned NOT NULL default '0',	
	show_assigned tinyint(1) unsigned NOT NULL default '0',	
	student_selection tinyint(1) unsigned NOT NULL default '0',	
	frequency tinyint(2) unsigned NOT NULL default '1',
	unable_to_assess varchar(100) NULL,	
	show_final_comment tinyint(1) unsigned NOT NULL default '0',	
	final_comment varchar(255) default NULL,
	total_weight float NOT NULL default '0',
	created_by varchar(24) NOT NULL default '',
	created_on datetime default NULL,
	modified_by varchar(24) default NULL,
	modified_on datetime default NULL,
	PRIMARY KEY (assessment_id),
	INDEX (form_id),
	INDEX (grade_event_id)
) ENGINE = INNODB;

CREATE TABLE form_builder_assessment_history (
	assessment_history_id int(10) unsigned NOT NULL auto_increment,
	assessment_id int(10) unsigned NOT NULL,
	form_id int(10) unsigned NOT NULL,
  	grade_event_id int(10) unsigned default NULL,
	score_display tinyint(1) unsigned NOT NULL default '0',
	score_range tinyint(1) unsigned NOT NULL default '0',
	show_images tinyint(1) unsigned NOT NULL default '0',	
	show_elective tinyint(1) unsigned NOT NULL default '0',	
	multi_assessors tinyint(1) unsigned NOT NULL default '0',	
	show_assigned tinyint(1) unsigned NOT NULL default '0',	
	student_selection tinyint(1) unsigned NOT NULL default '0',	
	frequency tinyint(2) unsigned NOT NULL default '1',
	unable_to_assess varchar(100) NULL,	
	show_final_comment tinyint(1) unsigned NOT NULL default '0',	
	final_comment varchar(255) default NULL,
	total_weight float NOT NULL default '0',
	created_by varchar(24) NOT NULL default '',
	created_on datetime default NULL,
	modified_by varchar(24) default NULL,
	modified_on datetime default NULL,
	history_action enum('Insert','Update','Delete') default NULL,
	PRIMARY KEY (assessment_history_id),
	INDEX (form_id),
	INDEX (grade_event_id)
) ENGINE = INNODB;

DROP TABLE IF EXISTS form_builder_subject_assessor;
DROP TABLE IF EXISTS form_builder_subject_assessor_history;

CREATE TABLE form_builder_subject_assessor (
	subject_assessor_id int(10) unsigned NOT NULL auto_increment,
	form_id int(10) unsigned NOT NULL,
	time_period_id int(10) unsigned NOT NULL,
	subject_id varchar(24) default NULL,
	assessor_id varchar(24) default NULL,
	status tinyint(2) NOT NULL default '1',
	created_by varchar(24) NOT NULL default '',
	created_on datetime default NULL,
	modified_by varchar(24) default NULL,
	modified_on datetime default NULL,
	PRIMARY KEY (subject_assessor_id),
	UNIQUE KEY (form_id, time_period_id, subject_id, assessor_id),
	INDEX (status)
) ENGINE = INNODB;

CREATE TABLE form_builder_subject_assessor_history (
	subject_assessor_history_id int(10) unsigned NOT NULL auto_increment,
	subject_assessor_id int(10) unsigned NOT NULL,
	form_id int(10) unsigned NOT NULL,
	time_period_id int(10) unsigned NOT NULL,
	subject_id varchar(24) default NULL,
	assessor_id varchar(24) default NULL,
	status tinyint(3) NOT NULL default '1',
	created_by varchar(24) NOT NULL default '',
	created_on datetime default NULL,
	modified_by varchar(24) default NULL,
	modified_on datetime default NULL,
	history_action enum('Insert','Update','Delete') default NULL,
	PRIMARY KEY (subject_assessor_history_id)
) ENGINE = INNODB;

DROP TABLE IF EXISTS form_builder_form_attribute_field_item;
DROP TABLE IF EXISTS form_builder_form_attribute_field_item_history;
DROP TABLE IF EXISTS form_builder_form_attribute_item;
DROP TABLE IF EXISTS form_builder_form_attribute_item_history;
DROP TABLE IF EXISTS form_builder_form_attribute;
DROP TABLE IF EXISTS form_builder_form_attribute_history;

CREATE TABLE form_builder_form_attribute (
	attribute_id int(10) unsigned NOT NULL auto_increment,
	form_id int(10) unsigned NOT NULL,
	sort_order tinyint(3) NOT NULL default '1',
	created_by varchar(24) NOT NULL default '',
	created_on datetime default NULL,
	modified_by varchar(24) default NULL,
	modified_on datetime default NULL,
	PRIMARY KEY (attribute_id),
	INDEX (form_id)
) ENGINE = INNODB;

CREATE TABLE form_builder_form_attribute_history (
	attribute_history_id int(10) unsigned NOT NULL auto_increment,
	attribute_id int(10) unsigned NOT NULL,
	form_id int(10) unsigned NOT NULL,
	sort_order tinyint(3) NOT NULL default '1',
	created_by varchar(24) NOT NULL default '',
	created_on datetime default NULL,
	modified_by varchar(24) default NULL,
	modified_on datetime default NULL,
	history_action enum('Insert','Update','Delete') default NULL,
	PRIMARY KEY (attribute_history_id),
	INDEX (form_id)
) ENGINE = INNODB;

CREATE TABLE form_builder_form_attribute_item (
	attribute_item_id int(10) unsigned NOT NULL auto_increment,
	attribute_id int(10) unsigned NOT NULL,
	sort_order tinyint(3) NOT NULL default '1',
	title varchar(225) NULL,
	description text NULL,
	min_value tinyint(3) unsigned NULL,	
	max_value tinyint(3) unsigned NULL,	
	created_by varchar(24) NOT NULL default '',
	created_on datetime default NULL,
	modified_by varchar(24) default NULL,
	modified_on datetime default NULL,
	PRIMARY KEY (attribute_item_id),
    INDEX (attribute_id),
	FOREIGN KEY (attribute_id) REFERENCES form_builder_form_attribute (attribute_id)
) ENGINE = INNODB;

CREATE TABLE form_builder_form_attribute_item_history (
	attribute_item_history_id int(10) unsigned NOT NULL auto_increment,
	attribute_item_id int(10) unsigned NOT NULL,
	attribute_id int(10) unsigned NOT NULL,
	sort_order tinyint(3) NOT NULL default '1',
	title varchar(225) NULL,
	description text NULL,
	min_value tinyint(3) unsigned NULL,	
	max_value tinyint(3) unsigned NULL,	
	created_by varchar(24) NOT NULL default '',
	created_on datetime default NULL,
	modified_by varchar(24) default NULL,
	modified_on datetime default NULL,
	history_action enum('Insert','Update','Delete') default NULL,
	PRIMARY KEY (attribute_item_history_id),
    INDEX (attribute_id)
) ENGINE = INNODB;

CREATE TABLE form_builder_form_attribute_field_item (
	attribute_field_item_id  int(10) unsigned NOT NULL auto_increment,
	attribute_item_id int(10) unsigned NOT NULL,
	field_item_id int(10) unsigned NOT NULL,
	comment_required tinyint(1) unsigned NOT NULL default '0',
	created_by varchar(24) NOT NULL default '',
	created_on datetime default NULL,
	modified_by varchar(24) default NULL,
	modified_on datetime default NULL,
	PRIMARY KEY (attribute_field_item_id),
  	FOREIGN KEY (attribute_item_id) REFERENCES form_builder_form_attribute_item (attribute_item_id),
    INDEX (attribute_item_id),
	INDEX (field_item_id)
) ENGINE = INNODB;

CREATE TABLE form_builder_form_attribute_field_item_history (
	attribute_field_item_history_id int(10) unsigned NOT NULL auto_increment,
	attribute_field_item_id  int(10) unsigned NOT NULL,
	attribute_item_id int(10) unsigned NOT NULL,
	field_item_id int(10) unsigned NOT NULL,
	comment_required tinyint(1) unsigned NOT NULL default '0',
	created_by varchar(24) NOT NULL default '',
	created_on datetime default NULL,
	modified_by varchar(24) default NULL,
	modified_on datetime default NULL,
	history_action enum('Insert','Update','Delete') default NULL,
	PRIMARY KEY (attribute_field_item_history_id),
    INDEX (attribute_item_id),
	INDEX (field_item_id)
) ENGINE = INNODB;

ALTER TABLE form_builder_entry_association ENGINE=InnoDB;
ALTER TABLE form_builder_entry_association_history ENGINE=InnoDB;

DROP TABLE IF EXISTS form_builder_entry_grade;
DROP TABLE IF EXISTS form_builder_entry_grade_history;

CREATE TABLE form_builder_entry_grade (
	entry_grade_id int(10) unsigned NOT NULL auto_increment,
	entry_id int(10) unsigned NOT NULL,
	score float unsigned NULL,
	comments text NULL,
	created_by varchar(24) NOT NULL default '',
	created_on datetime default NULL,
	modified_by varchar(24) default NULL,
	modified_on datetime default NULL,
	PRIMARY KEY (entry_grade_id),
    INDEX (entry_id)
) ENGINE = INNODB;

CREATE TABLE form_builder_entry_grade_history (
	entry_grade_history_id int(10) unsigned NOT NULL auto_increment,
	entry_grade_id int(10) unsigned NOT NULL,
	entry_id int(10) unsigned NOT NULL,
	score float unsigned NULL,
	comments text NULL,
	created_by varchar(24) NOT NULL default '',
	created_on datetime default NULL,
	modified_by varchar(24) default NULL,
	modified_on datetime default NULL,
	history_action enum('Insert','Update','Delete') default NULL,
	PRIMARY KEY (entry_grade_history_id),
    INDEX (entry_id)
) ENGINE = INNODB;

DROP TABLE IF EXISTS form_builder_field_comment;
DROP TABLE IF EXISTS form_builder_field_comment_history;

CREATE TABLE form_builder_field_comment (
  	field_comment_id int(10) unsigned NOT NULL auto_increment,
  	field_id int(1) unsigned NOT NULL,
  	comment text NOT NULL,
  	sort_order tinyint(2) unsigned NOT NULL default '0',
  	created_by varchar(24) NOT NULL default '',
  	created_on datetime default NULL,
  	modified_by varchar(24) default NULL,
  	modified_on datetime default NULL,
	PRIMARY KEY (field_comment_id),
  	INDEX (field_id)
) ENGINE = INNODB;

CREATE TABLE form_builder_field_comment_history (
  	field_comment_history_id int(10) unsigned NOT NULL auto_increment,
  	field_comment_id int(10) unsigned NOT NULL,
  	field_id int(1) unsigned NOT NULL,
  	comment text NOT NULL,
  	sort_order tinyint(2) unsigned NOT NULL default '0',
  	created_by varchar(24) NOT NULL default '',
  	created_on datetime default NULL,
  	modified_by varchar(24) default NULL,
  	modified_on datetime default NULL,
  	history_action enum('Insert','Update','Delete') default NULL,
  	PRIMARY KEY (field_comment_history_id),
  	INDEX (field_id)
) ENGINE = INNODB;
