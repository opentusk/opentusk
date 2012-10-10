DROP TABLE IF EXISTS tusk.multi_content_manager;
CREATE TABLE tusk.multi_content_manager (
	multi_content_manager_id int(11) NOT NULL auto_increment,
	status varchar(25) default 'uploading',
	error TEXT default '',
	uploaded_file_name TEXT NOT NULL default '',
	directory TEXT default '',
	zip_file TEXT NOT NULL default '',
	zip_entities int(11) NOT NULL default '0',
	zip_entities_extracted int(11) default '0',
	previews_to_generate int(11) default '0',
	previews_generated int(11) default '0',
	size varchar(25) default '0 b',
	created_by varchar(24) NOT NULL default '',
	created_on datetime default NULL,
	modified_by varchar(24) default NULL,
	modified_on datetime default NULL,
	PRIMARY KEY (multi_content_manager_id)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
