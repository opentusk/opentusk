CREATE DATABASE IF NOT EXISTS shibboleth_sessions;
GRANT INSERT,UPDATE,DELETE,SELECT ON shibboleth_sessions.* TO 'shib_mgr'@'%' IDENTIFIED BY 'SHIBDBPSWD';
FLUSH PRIVILEGES;
CREATE TABLE IF NOT EXISTS shibboleth_sessions.version (major int NOT NULL, minor int NOT NULL);
CREATE TABLE IF NOT EXISTS shibboleth_sessions.strings (context varchar(255) not null, id varchar(255) not null, expires datetime not null, version smallint not null, value varchar(255) not null, PRIMARY KEY (context, id));
CREATE TABLE IF NOT EXISTS shibboleth_sessions.texts (context varchar(255) not null, id varchar(255) not null, expires datetime not null, version smallint not null, value text not null, PRIMARY KEY (context, id));
DELETE FROM shibboleth_sessions.version;
INSERT INTO shibboleth_sessions.version VALUES (1,0);
