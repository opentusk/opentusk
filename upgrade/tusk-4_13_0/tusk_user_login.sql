CREATE TABLE IF NOT EXISTS tusk.user_login (
  user_login_id int(10) unsigned NOT NULL auto_increment,
  uid int(11) NOT NULL,
  login datetime default '2000-01-01 00:00:00',
  previous_login datetime default '2000-01-01 00:00:00',
  loggedout_flag int(1) unsigned default '1',
  cas_login int(11) default '0',
  shib_session varchar(80) character set utf8 NOT NULL default '0',
  modified_by varchar(24) NOT NULL,
  modified_on datetime NOT NULL,
  PRIMARY KEY  (user_login_id),
  UNIQUE KEY (uid),
  CONSTRAINT `fk_uid_hsdb4_user` FOREIGN KEY (`uid`) REFERENCES `hsdb4`.`user` (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS tusk.user_login_history (
  user_login_history_id int(10) unsigned NOT NULL auto_increment,
  user_login_id int(10) unsigned NOT NULL,
  uid int(11) NOT NULL,
  login datetime default '2000-01-01 00:00:00',
  previous_login datetime default '2000-01-01 00:00:00',
  loggedout_flag int(1) unsigned default '1',
  cas_login int(11) default '0',
  shib_session varchar(80) character set utf8 NOT NULL default '0',
  modified_by varchar(24) NOT NULL,
  modified_on datetime NOT NULL,
  history_action enum('Insert','Update','Delete') default NULL,
  PRIMARY KEY  (user_login_history_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO tusk.user_login (uid, login, previous_login, loggedout_flag)
   SELECT uid, login, previous_login, loggedout_flag 
     FROM hsdb4.user;
