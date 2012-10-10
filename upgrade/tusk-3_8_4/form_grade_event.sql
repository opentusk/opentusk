insert into form_builder_form_type 
values (0, 'Assess', 'Assessment', 'isathi01', now(), 'isathi01', now());


CREATE TABLE form_builder_form_grade_event (
	form_grade_event_id int(10) unsigned NOT NULL auto_increment,
	form_id int(10) unsigned NOT NULL,
  	grade_event_id int(10) unsigned NOT NULL,
  	created_by varchar(24) NOT NULL default '',
  	created_on datetime default NULL,
  	modified_by varchar(24) default NULL,
  	modified_on datetime default NULL,
  	PRIMARY KEY  (form_grade_event_id),
  	UNIQUE KEY (form_id, grade_event_id)
) ENGINE=INNODB;


CREATE TABLE form_builder_form_grade_event_history (
  	form_grade_event_history_id int(10) unsigned NOT NULL auto_increment,
  	form_grade_event_id int(10) unsigned NOT NULL,
  	form_id int(10) unsigned NOT NULL,
  	grade_event_id int(10) unsigned NOT NULL,
  	created_by varchar(24) NOT NULL default '',
  	created_on datetime default NULL,
  	modified_by varchar(24) default NULL,
  	modified_on datetime default NULL,
  	history_action enum('Insert','Update','Delete') default NULL,
  	PRIMARY KEY (form_grade_event_history_id)
) ENGINE=INNODB;


insert into form_builder_form_grade_event (form_id, grade_event_id, created_by, created_on, modified_by, modified_on) 
select form_id, grade_event_id, created_by, created_on, modified_by, modified_on from form_builder_assessment where grade_event_id != 0;

alter table form_builder_assessment drop grade_event_id;
alter table form_builder_assessment_history drop grade_event_id;
