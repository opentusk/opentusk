USE hsdb4;

DROP TABLE sessions;

CREATE TABLE sessions (
  id binary(32) NOT NULL DEFAULT '0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0',
  a_session blob,
  modified_on timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY sessions_modified (modified_on)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
