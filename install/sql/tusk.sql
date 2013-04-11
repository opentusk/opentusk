create database if not exists mwforum;
use mwforum;
source ../../db/baseline_mwforum.mysql

create database if not exists fts;
use fts;
source ../../db/baseline_fts.mysql

create database if not exists hsdb4;
use hsdb4;
source ../../db/baseline_hsdb4.mysql

create database if not exists tusk;
use tusk;
source ../../db/baseline_tusk.mysql
