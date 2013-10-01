#!/usr/bin/perl
use strict;
use Data::Dumper;
use DBD::mysql;
use POSIX;
use IO::Handle;
use Getopt::Long;
autoflush STDOUT 1;

sub getUserInput();
sub createTables();
sub createTableAndIndexes($@);
sub checkEtcMycnf();
sub dumpAndDropTable($$$);
sub buildData();
sub execFromInFile($);
sub modificationsWhileSiteIsDown();

my $userIDToInsertAs = "system";


my $up;
my $down;
my $reload;
my $cpAndDrop = 0;
my $skip = 0;

GetOptions(
	"up!" => \$up,
	"down!" => \$down,
	"reload!" => \$reload,
	"cp=s" => \$cpAndDrop,
	"skip!" => \$skip,
);

if(!$up && !$down && !$reload) {
	print "$0 [-up] [-down -skip]\n";
	print "\t -up : perform functions that can be run while the site is up (on a previous version).\n";
	print "\t -down: perform functions that need the site to be shut off.\n";
	print "\t -reload: performs a reload of the umls_data by truncating the tables and re-importing them\n";
	print "\n";
	print "This script can be run in two phases for schools with a lot of content.\n";
	print "The first phase (-up) can be run wile an old version of tusk is still running.\n";
	print "This portion can take a long time to run (about 5h on Tufts installation).\n";
	print "\n";
	print "Phase two (-down) has to be run between upgrades (i.e. old versions of tusk will no longer run).\n";
	print "This phase takes some time but not as much as the first run.\n";
	print "If skip is also used it will not drop the tables, you can do that later.\n";
	print "\n";
	print "They can be run at the same time if you want to: $0 -up -down\n";
	print "This will do both functions back to back.\n";
	exit();
}

 #get database information:
my ($dbh, $fileName) = getUserInput();
if($down) {checkEtcMycnf();}

if($up || $reload) {
	unless($reload) {
		print "Create Tables In Database ...\n";
		createTables();
		print "Done altering database.\n\n\n";
	}

	print "Manipulating data... (take a nap... this will be a while)...\n";
	buildData();
	print "Done\n";
}

if($down) {
	print "Altering Database ...\n";
	modificationsWhileSiteIsDown();
}

print "Finishing\n";
$dbh->disconnect;
exit();






sub modificationsWhileSiteIsDown() {
	if($dbh->do("ALTER TABLE tusk.keyword DROP COLUMN definition;")) {print "OK.\n";}
	if($dbh->do("ALTER TABLE  tusk.umls_string ADD FULLTEXT KEY string_text (string_text);")) {print "OK.\n";}
        print "\n";

	unless($skip) {
		print "Dropping old tables...\n";
		dumpAndDropTable("hsdb4", "query",1);
		dumpAndDropTable("hsdb4", "link_query_content",1);
		dumpAndDropTable("hsdb4", "string",1);
		dumpAndDropTable("hsdb4", "concept",1);
		dumpAndDropTable("hsdb4", "link_concept_type",1);
		dumpAndDropTable("hsdb4", "type",1);
		print "Done\n\n";
	} else {
		print "You need to drop:\n";
		print "\thsdb4.query\n";
                print "\thsdb4.link_query_content\n";
                print "\thsdb4.string\n";
                print "\thsdb4.concept\n";
                print "\thsdb4.link_concept_type\n";
                print "\thsdb4.type\n";
	}
}


sub getUserInput() {
	my $mysqlDB = 'tusk';
	print "please enter the mysql database name ($mysqlDB): ";
	my $tempMysqlDB = <STDIN>;
	chomp $tempMysqlDB;
	if($tempMysqlDB) {$mysqlDB = $tempMysqlDB;}

	print "Please enter the mysql username: ";
	my $username = <STDIN>;
	chomp $username;

	print "Please enter the mysql password: ";
	system("stty -echo");
	my $password = <STDIN>;
	system("stty echo");
	chomp $password;
	print "\n";

	#connect to db
	my $dbh = DBI->connect("dbi:mysql:$mysqlDB", $username, $password) || die "unable to connect: $!";

	my $fileName = "tusk_umls_tables.sql";
	print "Please enter the name for the output file (tusk_umls_tables.sql): ";
	my $newFileName = <STDIN>;
	chomp $newFileName;
	if($newFileName) {$fileName = $newFileName;}
	unless(-e "$fileName") {die "Failed to find $fileName : $!\n";}
	return($dbh, $fileName);
}


sub createTables() {
	print "Altering existing keyword tables...\n";
	print "\ttusl.link_content_keyword...";
	if($dbh->do("ALTER TABLE tusk.link_content_keyword ADD author_weight TINYINT after sort_order, ADD computed_weight FLOAT after sort_order;")) {print "OK.\n";}
	print "\ttusk.link_content_keyword_history...";
	if($dbh->do("ALTER TABLE tusk.link_content_keyword_history ADD author_weight TINYINT after sort_order, ADD computed_weight FLOAT after sort_order;")) {print "OK.\n";}
	print "\ttusk.keyword...";
	if($dbh->do("ALTER TABLE tusk.keyword CHANGE concept_id concept_id varchar(8) character set utf8;")) {print "OK.\n";}
	print "\n";
	
	print "Creating new tables....\n";
	createTableAndIndexes( qq/CREATE TABLE tusk.link_keyword_umls_semantic_type (
			link_keyword_umls_semantic_type_id INTEGER(10) UNSIGNED NOT NULL AUTO_INCREMENT,
			parent_keyword_id INTEGER(10) NOT NULL,
			child_umls_semantic_type_id INTEGER(10) NOT NULL,
			PRIMARY KEY(link_keyword_umls_semantic_type_id)
		);/,
		"CREATE INDEX link_keyword_umls_semantic_type_i01 ON tusk.link_keyword_umls_semantic_type(parent_keyword_id);",
		"CREATE INDEX link_keyword_umls_semantic_type_i02 ON tusk.link_keyword_umls_semantic_type(child_umls_semantic_type_id);",
	);
	
	createTableAndIndexes( qq/CREATE TABLE tusk.link_keyword_umls_string (
			link_keyword_umls_string_id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
			parent_keyword_id INTEGER(10) NOT NULL,
			child_umls_string_id INTEGER(10) NOT NULL,
			term_status CHAR(1) NOT NULL,
			PRIMARY KEY(link_keyword_umls_string_id)
		);/, 
		"CREATE INDEX link_keyword_umls_string_i01 ON tusk.link_keyword_umls_string(parent_keyword_id);",
		"CREATE INDEX link_keyword_umls_string_i02 ON tusk.link_keyword_umls_string(child_umls_string_id);",
	);

  #	createTableAndIndexes(qq/CREATE TABLE tusk.link_umls_semantic_type_umls_semantic_type (
  #			link_umls_semantic_type_umls_semantic_type_id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  #			parent_umls_semantic_type_id INTEGER NOT NULL,
  #			child_umls_semantic_type_id INTEGER NOT NULL,
  #			type_relationship VARCHAR(20) NULL,
  #			PRIMARY KEY(link_umls_semantic_type_umls_semantic_type_id)
  #		);/,
  #		"CREATE INDEX link_umls_semantic_type_umls_semantic_type_i01 ON tusk.link_umls_semantic_type_umls_semantic_type(parent_umls_semantic_type_id);",
  #		"CREATE INDEX link_umls_semantic_type_umls_semantic_type_i02 ON tusk.link_umls_semantic_type_umls_semantic_type(child_umls_semantic_type_id);",
  #	);
	
	createTableAndIndexes(qq/CREATE TABLE tusk.umls_concept_mention (
			umls_concept_mention_id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
			keyword_id INTEGER(10) NOT NULL,
			content_id INTEGER(10) UNSIGNED NOT NULL,
			context_mentioned ENUM('Text', 'Header', 'Title', 'Keyword') NOT NULL DEFAULT 'Text',
			node_id INTEGER UNSIGNED NULL,
			map_weight INTEGER UNSIGNED NULL,
			mapped_text TEXT NULL,
			created_by VARCHAR(24) NOT NULL,
			created_on DATETIME NOT NULL,
			modified_by VARCHAR(24) ,
			modified_on DATETIME,
			PRIMARY KEY(umls_concept_mention_id)
		);/,
		"CREATE INDEX umls_concept_mention_i01 ON tusk.umls_concept_mention(keyword_id);",
		"CREATE INDEX umls_concept_mention_i02 ON tusk.umls_concept_mention(content_id);",
	);

	createTableAndIndexes(qq/CREATE TABLE tusk.umls_concept_mention_history ( 
			`umls_concept_mention_history_id` int(10) unsigned NOT NULL auto_increment, 
		        `umls_concept_mention_id` int(10) unsigned NOT NULL,
		        `keyword_id` int(10) NOT NULL,
		        `content_id` int(10) unsigned NOT NULL,
		        `context_mentioned` enum('Text','Header','Title','Keyword') NOT NULL,
		        `node_id` int(10) unsigned ,
		        `map_weight` int(10) unsigned ,
		        `mapped_text` text ,
		        `created_by` varchar(24) NOT NULL,
		        `created_on` datetime NOT NULL,
		        `modified_by` varchar(24) ,
		        `modified_on` datetime ,
		        `history_action` enum('Insert', 'Update', 'Delete'),
		        PRIMARY KEY (`umls_concept_mention_history_id`)
		);/,
		"CREATE INDEX umls_concept_mention_history_i01 ON tusk.umls_concept_mention_history(umls_concept_mention_id);",
	);
	
	createTableAndIndexes(qq/CREATE TABLE tusk.umls_definition (
			umls_definition_id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
			umls_definition_type_id INTEGER NOT NULL,
			keyword_id INTEGER(10) NOT NULL,
			definition MEDIUMTEXT NULL,
			PRIMARY KEY(umls_definition_id)
		) DEFAULT CHARSET=utf8;/,
		"CREATE INDEX umls_definition_i01 ON tusk.umls_definition(keyword_id);",
		"CREATE INDEX umls_definition_i02 ON tusk.umls_definition(umls_definition_type_id);",
	);

        createTableAndIndexes(qq/CREATE TABLE tusk.umls_definition_type (
			umls_definition_type_id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
			definition_type_name text NOT NULL,
			definition_type_code VARCHAR(20) NOT NULL,
			PRIMARY KEY(umls_definition_type_id)
		) DEFAULT CHARSET=utf8;/,
		"CREATE INDEX umls_definition_type_i01 ON tusk.umls_definition_type(definition_type_code);",
	);
	
        createTableAndIndexes(qq/CREATE TABLE tusk.umls_semantic_type (
		  	umls_semantic_type_id INTEGER NOT NULL AUTO_INCREMENT,
		  	semantic_type_id VARCHAR(8) NOT NULL,
		  	semantic_type TEXT NULL,
		  	PRIMARY KEY(umls_semantic_type_id)
		) DEFAULT CHARSET=utf8;/,
		"CREATE UNIQUE INDEX umls_semantic_type_u01 ON tusk.umls_semantic_type(semantic_type_id);",
	);

        createTableAndIndexes(qq/CREATE TABLE tusk.umls_string (
		  umls_string_id INTEGER NOT NULL AUTO_INCREMENT,
		  string_id VARCHAR(8) NOT NULL,
		  string_text TEXT NULL,
		  PRIMARY KEY(umls_string_id)
		) DEFAULT CHARSET=utf8;/,
		"CREATE UNIQUE INDEX tusk.umls_string_u01 ON tusk.umls_string(string_id);",
		"CREATE INDEX tusk.umls_string_i01 ON tusk.umls_string(string_text(20));",
	);

        createTableAndIndexes(qq/CREATE TABLE tusk.link_keyword_keyword (
			  link_keyword_keyword_id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
			parent_keyword_id INTEGER(10) NOT NULL,
			  child_keyword_id INTEGER(10) NOT NULL,
			  concept_relationship VARCHAR(20) NULL,
			PRIMARY KEY(link_keyword_keyword_id)
		);/,
		"CREATE INDEX link_keyword_keyword_i01 ON tusk.link_keyword_keyword (parent_keyword_id,concept_relationship);",
		"CREATE INDEX link_keyword_keyword_i02 ON tusk.link_keyword_keyword (child_keyword_id,concept_relationship);",
		"CREATE UNIQUE INDEX link_keyword_keyword_u01 ON tusk.link_keyword_keyword (parent_keyword_id,child_keyword_id,concept_relationship);",
	);

        createTableAndIndexes(qq/CREATE TABLE tusk.search_result (
			  `search_result_id` int(10) unsigned NOT NULL auto_increment,
			  `search_result_type_id` int (10) unsigned NOT NULL,
			  `search_result_category_id` int (10) unsigned NOT NULL,
			  `result_label` varchar(255) NOT NULL,
			  `result_url` text NOT NULL,
			  `entity_id` int (10) unsigned,
			  `created_by` varchar(24) NOT NULL,
			  `created_on` datetime NOT NULL,
			  `modified_by` varchar(24) ,
			  `modified_on` datetime ,
			  PRIMARY KEY  (`search_result_id`)
		);/,
		"CREATE INDEX search_result_i01 ON tusk.search_result(search_result_category_id);",
		"CREATE INDEX search_result_i02 ON tusk.search_result(entity_id);",
		"CREATE INDEX search_result_i03 ON tusk.search_result(search_result_type_id);",
	);
	
        createTableAndIndexes(qq/CREATE TABLE tusk.search_result_category (
			`search_result_category_id` int(10) unsigned NOT NULL auto_increment,
			`school_id` int (10) unsigned NOT NULL,
			`category_label` varchar(255) NOT NULL,
			`created_by` varchar(24) NOT NULL,
			`created_on` datetime NOT NULL,
			`modified_by` varchar(24),
			`modified_on` datetime ,
			PRIMARY KEY  (`search_result_category_id`)
		);/,
		"CREATE INDEX search_result_category_i01 ON tusk.search_result_category(school_id);",
	);

        createTableAndIndexes(qq/CREATE TABLE tusk.search_result_type (
			`search_result_type_id` int(10) unsigned NOT NULL auto_increment,
			`type_name` varchar(255) NOT NULL,
			`created_by` varchar(24) NOT NULL,
			`created_on` datetime NOT NULL,
			`modified_by` varchar(24) ,
			`modified_on` datetime ,
			PRIMARY KEY  (`search_result_type_id`)
		);/,
	);

        createTableAndIndexes(qq/CREATE TABLE tusk.search_term (
			`search_term_id` int(10) unsigned NOT NULL auto_increment,
			`search_result_id` int (10) unsigned NOT NULL,
			`search_term` varchar(255) NOT NULL,
			`created_by` varchar(24) NOT NULL,
			`created_on` datetime NOT NULL,
			`modified_by` varchar(24) ,
			`modified_on` datetime ,
			PRIMARY KEY  (`search_term_id`)
		);/,
		"CREATE INDEX search_term_i01 ON tusk.search_term(search_term_id);",
		"CREATE INDEX search_term_i02 ON tusk.search_term(search_term);",
	);

        createTableAndIndexes(qq/CREATE TABLE tusk.search_result_category_history ( 
			`search_result_category_history_id` int(10) unsigned NOT NULL auto_increment, 
			`search_result_category_id` int(10) unsigned NOT NULL,
			`school_id` int(10) unsigned NOT NULL,
			`category_label` varchar(255) NOT NULL,
			`created_by` varchar(24) NOT NULL,
			`created_on` datetime NOT NULL,
			`modified_by` varchar(24) ,
			`modified_on` datetime ,
			`history_action` enum('Insert', 'Update', 'Delete'),
			PRIMARY KEY (`search_result_category_history_id`)
		);/,
		"CREATE INDEX search_result_category_history_i01 ON tusk.search_result_category_history(search_result_category_id);",
	);

        createTableAndIndexes(qq/CREATE TABLE tusk.search_result_history ( 
			`search_result_history_id` int(10) unsigned NOT NULL auto_increment, 
			`search_result_id` int(10) unsigned NOT NULL,
			`search_result_type_id` int(10) unsigned NOT NULL,
			`search_result_category_id` int(10) unsigned NOT NULL,
			`result_label` varchar(255) NOT NULL,
			`result_url` text NOT NULL,
			`entity_id` int(10) unsigned ,
			`created_by` varchar(24) NOT NULL,
			`created_on` datetime NOT NULL,
			`modified_by` varchar(24) ,
			`modified_on` datetime ,
			`history_action` enum('Insert', 'Update', 'Delete'),
			PRIMARY KEY (`search_result_history_id`)
		);/,
		"CREATE INDEX search_result_history_i01 ON tusk.search_result_history(search_result_id);",
	);

        createTableAndIndexes(qq/CREATE TABLE tusk.search_result_type_history ( 
			`search_result_type_history_id` int(10) unsigned NOT NULL auto_increment, 
			`search_result_type_id` int(10) unsigned NOT NULL,
			`type_name` varchar(255) NOT NULL,
			`created_by` varchar(24) NOT NULL,
			`created_on` datetime NOT NULL,
			`modified_by` varchar(24) ,
			`modified_on` datetime ,
			`history_action` enum('Insert', 'Update', 'Delete'),
			PRIMARY KEY (`search_result_type_history_id`)
		);/,
		"CREATE INDEX search_result_type_history_i01 ON tusk.search_result_type_history(search_result_type_id);",
	);

        createTableAndIndexes(qq/CREATE TABLE tusk.search_term_history ( 
			`search_term_history_id` int(10) unsigned NOT NULL auto_increment, 
			`search_term_id` int(10) unsigned NOT NULL,
			`search_result_id` int(10) unsigned NOT NULL,
			`search_term` varchar(255) NOT NULL,
			`created_by` varchar(24) NOT NULL,
			`created_on` datetime NOT NULL,
			`modified_by` varchar(24) ,
			`modified_on` datetime ,
			`history_action` enum('Insert', 'Update', 'Delete'),
			PRIMARY KEY (`search_term_history_id`)
		);/,
		"CREATE INDEX search_term_history_i01 ON tusk.search_term_history(search_term_id);",
	);

        createTableAndIndexes(qq/CREATE TABLE tusk.search_query (
			  `search_query_id` int(10) unsigned NOT NULL auto_increment,
			  `search_query` varchar(255) NOT NULL,
			  `user_id` varchar(24) NOT NULL,
			  `created_by` varchar(24) NOT NULL,
			  `created_on` datetime NOT NULL,
			  `modified_by` varchar(24) ,
			  `modified_on` datetime ,
			  PRIMARY KEY  (`search_query_id`)
		);/,
		"CREATE INDEX search_query_i01 ON tusk.search_query(search_query_id);",
		"CREATE INDEX search_query_i02 ON tusk.search_query(search_query);",
	);

        createTableAndIndexes(qq/CREATE TABLE tusk.search_query_history ( 
		        `search_query_history_id` int(10) unsigned NOT NULL auto_increment, 
		        `search_query_id` int(10) unsigned NOT NULL,
		        `search_query` varchar(255) NOT NULL,
		        `user_id` varchar(24) NOT NULL,
		        `created_by` varchar(24) NOT NULL,
		        `created_on` datetime NOT NULL,
		        `modified_by` varchar(24) ,
		        `modified_on` datetime ,
		        `history_action` enum('Insert', 'Update', 'Delete'),
		        PRIMARY KEY (`search_query_history_id`)
		);/,
		"CREATE INDEX search_query_history_i01 ON tusk.search_query_history(search_query_id);",
	);

        createTableAndIndexes(qq/CREATE TABLE tusk.search_query_field (
			`search_query_field_id` int(10) unsigned NOT NULL auto_increment,
			`search_query_id` int(10) unsigned NOT NULL,
			`search_query_field_type_id` int(10) unsigned NOT NULL,
			`search_query_field` varchar(255) NOT NULL,
			`created_by` varchar(24) NOT NULL,
			`created_on` datetime NOT NULL,
			`modified_by` varchar(24) ,
			`modified_on` datetime ,
			PRIMARY KEY  (`search_query_field_id`)
		);/,
		"CREATE INDEX search_query_field_i01 ON tusk.search_query_field(search_query_field_id);",
		"CREATE INDEX search_query_field_i02 ON tusk.search_query_field(search_query_field);",
		"CREATE INDEX search_query_field_i03 ON tusk.search_query_field(search_query_id);",
		"CREATE INDEX search_query_field_i04 ON tusk.search_query_field(search_query_field_type_id);",
	);

        createTableAndIndexes(qq/CREATE TABLE tusk.search_query_field_history ( 
			`search_query_field_history_id` int(10) unsigned NOT NULL auto_increment, 
			`search_query_field_id` int(10) unsigned NOT NULL,
			`search_query_id` int(10) unsigned NOT NULL,
			`search_query_field_type_id` int(10) unsigned NOT NULL,
			`search_query_field` varchar(255) NOT NULL,
			`created_by` varchar(24) NOT NULL,
			`created_on` datetime NOT NULL,
			`modified_by` varchar(24) ,
			`modified_on` datetime ,
			`history_action` enum('Insert', 'Update', 'Delete'),
			PRIMARY KEY (`search_query_field_history_id`)
		);/,
		"CREATE INDEX search_query_field_history_i01 ON tusk.search_query_field_history(search_query_field_id);",
	);

        createTableAndIndexes(qq/CREATE TABLE tusk.search_query_field_type (
			`search_query_field_type_id` int(10) unsigned NOT NULL auto_increment,
			`search_query_field_name` varchar(255) NOT NULL,
			`display_text` varchar(255),
			`created_by` varchar(24) NOT NULL,
			`created_on` datetime NOT NULL,
			`modified_by` varchar(24) ,
			`modified_on` datetime ,
			PRIMARY KEY  (`search_query_field_type_id`)
		);/,
		"CREATE UNIQUE INDEX search_query_field_type_i01 ON tusk.search_query_field_type(search_query_field_name);",
	);

        createTableAndIndexes(qq/CREATE TABLE tusk.search_query_field_type_history ( 
			`search_query_field_type_history_id` int(10) unsigned NOT NULL auto_increment, 
			`search_query_field_type_id` int(10) unsigned NOT NULL,
			`search_query_field_name` varchar(255) NOT NULL,
			`created_by` varchar(24) NOT NULL,
			`created_on` datetime NOT NULL,
			`modified_by` varchar(24) ,
			`modified_on` datetime ,
			`history_action` enum('Insert', 'Update', 'Delete'),
			PRIMARY KEY (`search_query_field_type_history_id`)
		);/,
		"CREATE INDEX search_query_field_type_history_i01 ON tusk.search_query_field_type_history(search_query_field_type_id);",
	);

        createTableAndIndexes(qq/CREATE TABLE tusk.link_search_query_search_query (
			`link_search_query_search_query_id` int(10) unsigned NOT NULL auto_increment,
			`parent_search_query_id` int(10) unsigned NOT NULL,
			`child_search_query_id` int(10) unsigned NOT NULL,
			`created_by` varchar(24) NOT NULL,
			`created_on` datetime NOT NULL,
			`modified_by` varchar(24) ,
			`modified_on` datetime ,
			PRIMARY KEY  (`link_search_query_search_query_id`)
		);/,
		"CREATE INDEX link_search_query_search_query_i01 ON tusk.link_search_query_search_query(parent_search_query_id);",
		"CREATE INDEX link_search_query_search_query_i02 ON tusk.link_search_query_search_query(child_search_query_id);",
	);

        createTableAndIndexes(qq/CREATE TABLE tusk.link_search_query_search_query_history ( 
			`link_search_query_search_query_history_id` int(10) unsigned NOT NULL auto_increment, 
			`link_search_query_search_query_id` int(10) unsigned NOT NULL,
			`parent_search_query_id` int(10) unsigned NOT NULL,
			`child_search_query_id` int(10) unsigned NOT NULL,
			`created_by` varchar(24) NOT NULL,
			`created_on` datetime NOT NULL,
			`modified_by` varchar(24) ,
			`modified_on` datetime ,
			`history_action` enum('Insert', 'Update', 'Delete'),
			PRIMARY KEY (`link_search_query_search_query_history_id`)
		);/,
		"CREATE INDEX link_search_query_search_query_history_i01 ON tusk.link_search_query_search_query_history(link_search_query_search_query_id);",
	);

        createTableAndIndexes(qq/CREATE TABLE tusk.link_search_query_content (
			`link_search_query_content_id` int(10) unsigned NOT NULL auto_increment,
			`parent_search_query_id` int(10) unsigned NOT NULL,
			`child_content_id` int(10) unsigned  NOT NULL,
			`computed_score` float NOT NULL,
			PRIMARY KEY  (`link_search_query_content_id`)
		);/,
		"CREATE INDEX link_search_query_content_i01 ON tusk.link_search_query_content(parent_search_query_id);",
		"CREATE INDEX link_search_query_content_i02 ON tusk.link_search_query_content(child_content_id);",
		"CREATE INDEX link_search_query_content_i03 ON tusk.link_search_query_content(parent_search_query_id,child_content_id,computed_score);",
	);

        createTableAndIndexes(qq/CREATE TABLE tusk.full_text_search_content (
			`full_text_search_content_id` int(10) unsigned NOT NULL auto_increment,
			`content_id` int(10) unsigned NOT NULL default '0',
			`title` varchar(255) default NULL,
			`copyright` varchar(255) default NULL,
			`authors` text,
			`courses` text,
			`keywords` text,
			`school` enum('Medical','Veterinary','Dental','NEMC','Sackler','Nutrition','HSDB','Test','ArtsSciences','Downstate','PHPD','VeterinaryGP','Engineering','Archive','AEPD') default NULL,
			`type` enum('Document','Audio','Video','Flashpix','Collection','Figure','Slide','Shockwave','URL','PDF','Question','Multidocument','Quiz','DownloadableFile','Student Notes','Reuse','External','TUSKdoc') NOT NULL default 'Document',
			`body` text,
			PRIMARY KEY  (`full_text_search_content_id`),
			KEY `content_id` (`content_id`),
			KEY `school` (`school`),
			KEY `type` (`type`),
			FULLTEXT KEY `title` (`title`,`body`,`copyright`,`authors`,`keywords`),
			FULLTEXT KEY `title_2` (`title`),
			FULLTEXT KEY `body` (`body`),
			FULLTEXT KEY `copyright` (`copyright`),
			FULLTEXT KEY `authors` (`authors`),
			FULLTEXT KEY `keywords` (`keywords`),
			FULLTEXT KEY `courses` (`courses`)
			) ENGINE=MyISAM DEFAULT CHARSET=latin1
		;/,
	);
	print "Done\n";





	print "Performing grants to new tables...\n";
	$dbh->do("grant insert, update, delete, select on tusk.search_result to 'contentmanager';");
	$dbh->do("grant insert, update, delete, select on tusk.search_result_history to 'contentmanager';");
	$dbh->do("grant select on tusk.search_result to 'web_user';");
	$dbh->do("grant insert, update, delete, select on tusk.search_term to 'contentmanager';");
	$dbh->do("grant insert, update, delete, select on tusk.search_term_history to 'contentmanager';");
	$dbh->do("grant select on tusk.search_term to 'web_user';");
	$dbh->do("grant insert, update, delete, select on tusk.search_result_category to 'contentmanager';");
	$dbh->do("grant insert, update, delete, select on tusk.search_result_category_history to 'contentmanager';");
	$dbh->do("grant select on tusk.search_result_category to 'web_user';");
	$dbh->do("grant insert, update, delete, select on tusk.search_result_type to 'contentmanager';");
	$dbh->do("grant insert, update, delete, select on tusk.search_result_type_history to 'contentmanager';");
	$dbh->do("grant select on tusk.search_result_type  to 'web_user';");
	$dbh->do("grant insert, update, delete, select on tusk.umls_concept_mention to 'contentmanager';");
	$dbh->do("grant insert, update, delete, select on tusk.umls_concept_mention_history to 'contentmanager';");
	$dbh->do("grant select on tusk.umls_concept_mention to 'web_user';");
	$dbh->do("grant insert, update, delete, select on tusk.search_query to 'web_user';");
	$dbh->do("grant insert, update, delete, select on tusk.search_query_history to 'web_user';");
	$dbh->do("grant insert, update, delete, select on tusk.search_query_field to 'web_user';");
	$dbh->do("grant insert, update, delete, select on tusk.search_query_field_history to 'web_user';");
	$dbh->do("grant insert, update, delete, select on tusk.search_query_field_type to 'web_user';");
	$dbh->do("grant insert, update, delete, select on tusk.search_query_field_type_history to 'web_user';");
	$dbh->do("grant insert, update, delete, select on tusk.link_search_query_search_query to 'web_user';");
	$dbh->do("grant insert, update, delete, select on tusk.link_search_query_search_query_history to 'web_user';");
	$dbh->do("grant insert, update, delete, select on tusk.link_search_query_content to 'web_user';");
	$dbh->do("grant insert, update, delete, select on tusk.link_search_query_content to 'web_user';");
	$dbh->do("grant select on tusk.link_keyword_umls_string to 'web_user';");
	$dbh->do("grant select on tusk.umls_string to 'web_user';");
	$dbh->do("grant select on tusk.link_keyword_keyword to 'web_user';");
	$dbh->do("grant select on tusk.link_keyword_umls_semantic_type to 'web_user';");
	$dbh->do("grant select on tusk.umls_semantic_type to 'web_user';");
	$dbh->do("grant select on tusk.umls_definition to 'web_user';");
	$dbh->do("grant select on tusk.umls_definition_type to 'web_user';");
	$dbh->do("grant select on tusk.keyword to 'web_user';");
	$dbh->do("flush privileges;");
	print "Done\n\n";
}




sub createTableAndIndexes($@) {
	my $tableSQL = shift;
	my @indexSQL = @_;
	my $garbage = $tableSQL;
	$garbage =~ s/create table //i;
	my($tableName, $new_garbage) = split /\ /, $garbage, 2;
	$tableName =~ s/`//g;
	$tableName =~ s/'//g;
	print "\tCreating table $tableName...";
	if($dbh->do("DROP TABLE IF EXISTS $tableName")) {
		if($dbh->do($tableSQL)) {
			print "OK.\n";
			if(scalar(@indexSQL > 0)) {
				foreach (@indexSQL) {
					print "\tCreating index on $tableName...";
					if($_ && $dbh->do($_)) {print "OK.\n";}
				}
			}
			return 1;
		}
	}
	return 0;
}


sub checkEtcMycnf() {
	my $foundFTMinWordLen = 0;
	if(-e "/etc/my.cnf" && open(MY_CNF, "/etc/my.cnf")) { 
		while(<MY_CNF>) {   if(/^ft_min_word_len=(\d*).*/) {$foundFTMinWordLen = $1;}   }
	}

	my $answer;
	while(!$answer) {
		if($foundFTMinWordLen == 0) {
			print "\n\nHave you added the following line to /etc/my.cnf and restarted the server?\n\n";
			print "ft_min_word_len=3\n\n";
		} else {
			print "\n\nVery good, I found an ft_min_word_len setting in your /etc/my.cnf file.\n";
			if($foundFTMinWordLen != 3) {print "But... you were not set to the recommended value of 3 (you were $foundFTMinWordLen)\n";}
			print "The question is have you restarted your mysql database in order for the change to take effect?\n";
		}
		print "Oh, and have you searously backed up your database? I'm going to be dropping tables and they can only be recovered from backups!\n";
		print "(y/n/q) ?";
		$answer = <STDIN>;
		chomp $answer;
		if($answer =~ /^n/i) {die "You need to do that before starting this\n";}
		elsif($answer =~ /^y/i) {print "Good job\n";}
		elsif($answer =~ /^q/i) {print "Quitting\n"; exit();}
		else {$answer = '';}
	}
}


sub dumpAndDropTable($$$) {
	my $databaseName = shift;
	my $tableName = shift;
	my $dropTable = shift;

	if($cpAndDrop) {
		print "\tMoving $databaseName.$tableName...";
		unless(opendir(DATA_DIR, "/data/mysql/$databaseName")) {print "Error unable to open directory /data/mysql/$databaseName : $!\n";}
		else {
			my @files = grep /^$tableName\./, readdir(DATA_DIR);
			closedir(DATA_DIR);
			foreach my $file_name (@files) {
				unless(File::copy("/data/mysql/$databaseName/$file_name", "$cpAndDrop/$file_name")) {print "Error unable to move $file_name to $cpAndDrop/$file_name : $!\n";}
				else {
					if($dropTable) {
						unless($dbh->do("DROP TABLE $databaseName.$tableName")) {print "Error unable to drop the table : $!\n";}
						else {print "OK.\n";}
					} else {print "OK.\n";}
				}
			}
		}
        } else {
		print "\tDumping $databaseName.$tableName...";
		unless(open(DUMP_FILE, ">./$databaseName.$tableName.sql")) {print "Error unable to create dump file : $!\n";}
		else {
			my $sth = $dbh->prepare("SELECT * FROM $databaseName.$tableName");
			unless($sth) {print "Error unable to prepare mysql statement!\n";}
			elsif(!$sth->execute()) {print "Error unable to execute mysql statement!\n";}
			else {
				my $printedHeaderLine = 0;
				while(my $ref = $sth->fetchrow_hashref()) {
					my $line = '';
					my $headerLine = '';
					foreach my $key (sort keys %{$ref}) {
						my $value = $ref->{$key};
						$value ||= "\\0";
						$line.= $value . "\t";
						unless($printedHeaderLine) {$headerLine.= $key . "\t";}
					}
					unless($printedHeaderLine) {
						print DUMP_FILE "$headerLine\n";
						$printedHeaderLine++;
					}
					print DUMP_FILE "$line\n";
  				}
				unless("./$databaseName.$tableName.sql") {print "Error mysqldump did not seem to work\n";}
				elsif($dropTable) {
					unless($dbh->do("DROP TABLE $databaseName.$tableName")) {print "Error unable to drop the table : $!\n";}
					else {print "OK.\n";}
				} else {print "OK.\n";}
			}
			close(DUMP_FILE);
		}
	}
}
	

sub buildData() {
	#Dump keyword table
	dumpAndDropTable("tusk", "keyword", 0);

	#Importing concepts as temp table
	$dbh->do("DROP TABLE IF EXISTS tusk.umls_concept");
	if($dbh->do("CREATE TABLE IF NOT EXISTS tusk.umls_concept (umls_concept_id char(8), preferred_form varchar(255));")) {
		print "\tImporting umls concepts...";
		execFromInFile("umls_concept");
		
		# updating keywords that are umls concepts and add new concepts
		print "\tFixing keywords that are umls concepts that have the wrong label and adding new umls concepts...\n";
		my $sth = $dbh->prepare("select preferred_form, keyword, concept_id, umls_concept_id from tusk.umls_concept LEFT OUTER JOIN tusk.keyword on umls_concept_id=concept_id;");
		#$sth = $dbd->prepare("select preferred_form, keyword, concept_id from tusk.keyword, tusk.umls_concept where concept_id=umls_concept_id and preferred_form != keyword");
		print "\t\tPerforming SQL call to get concepts that need fixing...";
		unless($sth) {print "Error unable to get keywords and concepts!\n";}
		elsif($sth->execute()) {
			print "OK\n";
			my $numTried = 0;
			my $numTriedToFix = 0;
			my $numTriedToAdd = 0;
			my $numAdded = 0;
			my $numFixed = 0;
			print "\t\tWritting to log file ./keyword_merge_with_concept_ids.txt\n";
			open(LOG, ">./keyword_merge_with_concept_ids.txt") || warn "Could not write to file for log!\n";
			while(my $ref = $sth->fetchrow_hashref()) {
				$numTried++;
				print LOG "Looking at ceoncept number $numTried...";
				#If I have information from umls_concept but not from keyword then add me, I'm a new concept 
				$ref->{'keyword'} ||= '';
				if(defined($ref->{'preferred_form'}) && defined($ref->{'umls_concept_id'}) && !defined($ref->{'concept_id'})) {
					$numTriedToAdd++;
					print LOG "New ", $ref->{'preferred_form'};
					if($dbh->do("INSERT INTO tusk.keyword (keyword, concept_id, created_by, created_on) VALUES (" . $dbh->quote($ref->{'preferred_form'}) . "," . $dbh->quote($ref->{'umls_concept_id'}) . ", '$userIDToInsertAs', now());"))
						{$numAdded++;}
					print LOG "\n";
				} elsif($ref->{'preferred_form'} ne $ref->{'keyword'}) {
					$numTriedToFix++;
					print LOG "Needs fixing (",$ref->{'keyword'}," -> ",$ref->{'preferred_form'}, ")";
					if($dbh->do("UPDATE tusk.keyword SET keyword=" . $dbh->quote($ref->{'preferred_form'}) . ", modified_by='$userIDToInsertAs', modified_on=now() WHERE concept_id=" . $dbh->quote($ref->{'concept_id'}) .";")) {$numFixed++;}
					print LOG "\n";
				} else {print LOG "OK\n";}
			}
			print "\tWorked with $numTried entries\n";
			print "\tFixed $numFixed out of $numTriedToFix which needed fixing\n";
			print "\tAdded $numAdded out of $numTriedToAdd which needed to be added\n";
		}
		print "\n";

  #		#remove keywords that were concepts that were not in the umls data
  #		print "\tRemoving concept_id from keywords that are not in the umls data...\n";
  #		my $sth2 = $dbh->prepare("select concept_id from tusk.keyword where concept_id IS NOT NULL;");
  #		my $sth3 = $dbh->prepare("select umls_concept_id from tusk.umls_concept where umls_concept_id=?");
  #		#my $sth2 = $dbh->prepare("select concept_id from tusk.keyword LEFT OUTER JOIN tusk.umls_concept ON umls_concept_id=concept_id WHERE umls_concept_id IS NULL;");
  #		print "\t\tPerforming SQL call to get these keywords...\n";
  #		unless($sth2) {print "Error unable to get the keywords that need fixing...\n";}
  #		elsif($sth2->execute()) {
  #			my $numTried = 0;
  #			my $numFailed = 0;
  #			my $numUpdated = 0;
  #			while(my $ref = $sth2->fetchrow_hashref()) {
  #				$numTried++;
  #				print "\t\tLooking at keyword number $numTried of ", $sth2->rows(), "...";
  #				if($sth3->execute($ref->{'concept_id'})) {
  #					my $matches = $sth3->rows();
  #					if($matches == 0) {
  #						print "conceptID ", $ref->{'concept_id'}, " is not in umls fixing...";
  #						if($dbh->do("UPDATE tusk.keyword SET concept_id=NULL, modified_by='$userIDToInsertAs', modified_on=now() WHERE concept_id=" . $dbh->quote($ref->{'concept_id'}) . ";")) {
  #							$numUpdated++;
  #							print "OK\n";
  #						}
  #						else {
  #							$numFailed++;
  #							print "Failed\n";
  #						}
  #					} else {print "OK ($matches matches)\r";}
  #				} else {print "Failed to check the umls_concept table!\n";}
  #			}
  #			print "\tWorked with $numTried keywords\n";
  #			print "\tFixed $numUpdated of those\n";
  #			print "\tFailed to fix $numFailed of those\n";
  #		}

		#removing temp table
		unless($dbh->do("DROP TABLE tusk.umls_concept;")) {print "\tUnable to remove the temporary table : tusk.umls_concept\n";}

		#Importing tusk.umls_string
		execFromInFile("umls_string");

		#Importing tusk.umls_semantic_type
		execFromInFile("umls_semantic_type");

		#Importing tusk.umls_definition_type
		execFromInFile("umls_definition_type");
		
		#Importing tusk.link_keyword_umls_string
		execFromInFile("link_keyword_umls_string");

		#Importing tusk.link_keyword_umls_semantic_type
		execFromInFile("link_keyword_umls_semantic_type");

		#Importing tusk.link_keyword_keyword
		execFromInFile("link_keyword_keyword");

		#Importing tusk.umls_definition (Build with keywords).
		execFromInFile("umls_definition");

		unless($reload) {
			print "\tInserting data to tusk.search_result_type...";
			if($dbh->do("insert into tusk.search_result_type values (0,'Specific URL','$userIDToInsertAs', now(), null,null);")) {print "OK.\n";}
			print "\tInserting data into tusk.search_query_field_type...";
			$dbh->do("insert into tusk.search_query_field_type values (0,'author','Author','$userIDToInsertAs',now(),'$userIDToInsertAs',now());");
			$dbh->do("insert into tusk.search_query_field_type values (0,'title','Title','$userIDToInsertAs',now(),'$userIDToInsertAs',now());");
			$dbh->do("insert into tusk.search_query_field_type values (0,'media_type','Media Type','$userIDToInsertAs',now(),'$userIDToInsertAs',now());");
			$dbh->do("insert into tusk.search_query_field_type values (0,'copyright','Copyright','$userIDToInsertAs',now(),'$userIDToInsertAs',now());");
			$dbh->do("insert into tusk.search_query_field_type values (0,'school','School','$userIDToInsertAs',now(),'$userIDToInsertAs',now());");
			$dbh->do("insert into tusk.search_query_field_type values (0,'course','Course','$userIDToInsertAs',now(),'$userIDToInsertAs',now());");
			$dbh->do("insert into tusk.search_query_field_type values (0,'content_id','Content ID','$userIDToInsertAs',now(),'$userIDToInsertAs',now());");
			$dbh->do("insert into tusk.search_query_field_type values (0,'concepts','Concepts','$userIDToInsertAs',now(),'$userIDToInsertAs',now());");
			print "Done\n\n";
		}
	} else {print "\tFailed to create umls_concept temp table, unable to fix keywords.\nIm not doing anything else.";}
}

sub execFromInFile($) {
	my $tableName = shift;
	my $sth;
	my $inserting = 0;
	my $numFailed = 0;
	my $sqlStatement = '';

	unless(open(IN_FILE, $fileName)) {print "Could not open the input file : $fileName : $!\n";}
	else {
		my $lineNumber = 0;
		while(<IN_FILE>) {
			$lineNumber++;
			chomp;
			if(/^INSERT INTO ([^ ]*) /) {
				if($1 =~ /^(.*\.)?$tableName$/) {
					$sqlStatement = $_;
					print "Found INSERT commands for $tableName at $lineNumber...\n";
					print "\tTruncating $tableName...";
					unless($dbh->do("TRUNCATE TABLE tusk.$tableName")) {warn "Could not truncate tusk.$tableName\n";}
					else {print "OK\n";}
					$sth = $dbh->prepare($sqlStatement);
					$inserting = 1;
				} elsif($inserting) {
					$inserting = 0;
					print "Done at $lineNumber...\n";
					last;
				}
			} elsif($inserting && $sth) {
				my @insertValues = split /-\|-/, $_;
				foreach my $counter (0..$#insertValues) {$sth->bind_param(($counter + 1), $insertValues[$counter]);}
				unless($sth->execute()) {$numFailed++; last;}
			}
		}
		close(IN_FILE);
	}
	if($numFailed) {
		print "Failed $numFailed entries... do you want me to continue? (y/n) ";
		my $continue = <STDIN>;
		chomp $continue;
		if($continue =~ /^n$/i) {exit();}
	} else {print "OK.\n";}
}

