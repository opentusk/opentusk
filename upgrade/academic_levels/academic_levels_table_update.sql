/*Add sort_order column to academic_level and academic_level_history tables*/

ALTER TABLE academic_level
ADD COLUMN sort_order tinyint(3) unsigned NOT NULL DEFAULT '0' AFTER school_id;

ALTER TABLE academic_level_history
ADD COLUMN sort_order tinyint(3) unsigned NOT NULL DEFAULT '0' AFTER school_id;

DROP TABLE IF EXISTS time_period_year;

DROP TABLE IF EXISTS time_period_year_history;

DROP TABLE IF EXISTS year;

DROP TABLE IF EXISTS year_history;

CREATE TABLE year (
	year_id tinyint(3) unsigned NOT NULL PRIMARY KEY AUTO_INCREMENT,
	title varchar(50) DEFAULT NULL,
	description varchar(250) DEFAULT NULL,
	modified_by varchar(24) NOT NULL DEFAULT ' ',
	modified_on datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE year_history (
	year_history_id int(10) unsigned NOT NULL PRIMARY KEY AUTO_INCREMENT,
	year_id tinyint(3) unsigned NOT NULL,
	title varchar(50) DEFAULT NULL,
	description varchar(250) DEFAULT NULL,
	modified_by varchar(24) NOT NULL DEFAULT ' ',
	modified_on datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE time_period_year (
	time_period_year_id int(10) unsigned NOT NULL PRIMARY KEY AUTO_INCREMENT,
	school_id int(10) unsigned NOT NULL,
	time_period_id int(10) unsigned NOT NULL,
	year_id tinyint(3) unsigned NOT NULL,	
	modified_by varchar(24) NOT NULL DEFAULT ' ',
	modified_on datetime DEFAULT NULL,
	CONSTRAINT FOREIGN KEY (year_id) REFERENCES year(year_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE time_period_year_history (
	time_period_year_history_id int(10) unsigned NOT NULL PRIMARY KEY AUTO_INCREMENT,
	time_period_year_id int(10) unsigned NOT NULL,
	school_id int(10) unsigned NOT NULL,
	time_period_id int(10) unsigned NOT NULL,
	year_id tinyint(3) unsigned NOT NULL,	
	modified_by varchar(24) NOT NULL DEFAULT ' ',
	modified_on datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*Insert default values to year table*/

INSERT INTO year VALUES
(0, '1', 'Year 1', 'script', now()),
(0, '2', 'Year 2', 'script', now()),
(0, '3', 'Year 3', 'script', now()),
(0, '4', 'Year 4', 'script', now());