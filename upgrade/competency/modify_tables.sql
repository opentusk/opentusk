ALTER TABLE competency ENGINE = InnoDB;

ALTER TABLE competency CONVERT TO CHARACTER SET utf8;


ALTER TABLE competency
ADD COLUMN uri varchar(256) DEFAULT NULL AFTER description, 
ADD COLUMN competency_level_enum_id int(10) UNSIGNED AFTER uri,
ADD COLUMN competency_user_type_id int(10) UNSIGNED AFTER competency_level_enum_id
ADD COLUMN version_id tinyint AFTER school_id,
ADD CONSTRAINT fk_competencytype FOREIGN KEY(competency_user_type_id) REFERENCES competency_user_type( competency_user_type_id),
ADD CONSTRAINT fk_competencyversion FOREIGN KEY (version_id) REFERENCES competency_version (competency_version_id);


ALTER TABLE competency_history
ADD COLUMN uri varchar(256) NOT NULL AFTER description,
ADD COLUMN competency_level_enum_id int(10) UNSIGNED AFTER uri;

ALTER TABLE competency ENGINE = InnoDB;

ALTER TABLE competency_history CONVERT TO CHARACTER SET utf8;

RENAME TABLE competency_relationship TO competency_hierarchy;
ALTER TABLE competency_hierarchy 
CHANGE competency_relationship_id competency_hierarchy_id int(10) UNSIGNED PRIMARY KEY AUTO_INCREMENT,
DROP column school_id;

RENAME TABLE competency_relationship_history TO competency_hierarchy_history;

ALTER TABLE competency_hierarchy_history 
CHANGE competency_relationship_history_id competency_hierarchy_history_id int(10) UNSIGNED PRIMARY KEY AUTO_INCREMENT,
CHANGE competency_relationship_id competency_hierarchy_id int(10) UNSIGNED,
DROP column school_id;


