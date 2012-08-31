#! /usr/bin/perl

use strict;
use FindBin;
use lib "$FindBin::Bin/../lib";
use MySQL::Password;
use TUSK::Core::School;
use TUSK::Course::CourseMetadataDisplay;
use Data::Dumper;
use DBI;
use Getopt::Std;


# $user_name & $password used to connect to db; 
# $script_user (set below as unix login) is value for created and modified in db (when needed)
my ($user_name, $password, $script_user);
my ($dbh, $sth, $sql, $retval);
my $error_string;

$script_user = getpwuid($<) || "new_school_script";

# get any args passed in by user
our ($opt_h, $opt_i, $opt_p);
getopts ("hip");

&print_help if $opt_h;
&print_instructions if $opt_i;
&print_post_script if $opt_p;
exit if $opt_h or $opt_i or $opt_p;

###########################
# GET ALL SORTS OF INPUT FROM USER

print "\nPlease enter username of account with global mysql 'GRANT' permissions (this is necessary in order to create new school database). Hint: the default is often 'root'.\n\nUser name:  ";
$user_name = <>;
chomp $user_name;

print "Please enter password for $user_name: ";
system("stty -echo");
$password = <>;
print "\n";
system("stty echo");
chomp $password;

eval {
    $dbh = DBI->connect("DBI:mysql:tusk:localhost", $user_name, $password, {RaiseError => 1, PrintError => 0});
};
die "\nFailure: Could not connect to database: $@\n" if $@;

# make sure account from user has GRANT privileges
$sql = "select Grant_priv from mysql.user where User='$user_name'";
$sth = $dbh->prepare($sql);
eval {
    $sth->execute;
};
die "Failure: $@ - sql: $sql" if ($@);

my $privileges = $sth->fetchrow_array();
die "User $user_name does not have global GRANT permissions\n" if $privileges ne 'Y';
$sth->finish;

print "\nSchool display text (displayed on webpages): ";
my $school_display = <>;
chomp $school_display;

print "\nSchool name (used in db and code): ";
my $school_name = <>;
chomp $school_name;

print "\nSchool database name (will be inserted into hsdb45_XXX_admin): ";
my $school_db = <>;
chomp $school_db;
$school_db = "hsdb45_" . $school_db . "_admin";

$sth = $dbh->prepare('show databases');
$sth->execute();

my @data;
while (@data = $sth->fetchrow_array()) {
	if ($data[0] eq $school_db) {
		die "A database already exists by name $school_db. Please pick a unique name and try again.";
	}
}

my $confirmation;
my $administrator;
do {
    print "\nUsername of administrator for new school (for $script_user, press <return>, otherwise, type new id and press <return>): ";

    $administrator = <>;
    chomp $administrator;

    $administrator = $administrator || $script_user;
    
    $sql = "select status from hsdb4.user where user_id = '$administrator'";

    $sth = $dbh->prepare($sql);

    eval {
	$sth->execute;
    };
    if ($@){
	print "error checking database. please try again.\n";
    } else {
	my $status = $sth->fetchrow_array();
	do {
	    if (!$status){
		print "\nNo such user. Please try again.\n";
		$confirmation = 'n';
	    } elsif ($status ne 'Active'){
		print "\nUser is not active in TUSK, use as administrator anyway? (y/n): ";
		$confirmation = lc(<>);
		chomp $confirmation;
	    } else {
		print "\nYou selected $administrator. Are you sure? (y/n): ";
		$confirmation = lc(<>);
		chomp $confirmation;
	    }
	} while $confirmation ne 'y' && $confirmation ne 'n';
    }
} while $@ || $confirmation ne 'y';


print "\nYou submitted:\n";
print "School Display Text: $school_display\n";
print "School Name: $school_name\n";
print "School Database Name: $school_db\n";
print "School Admin: $administrator\n\n";


do {
    print "Is this correct? (y/n): ";
    $confirmation = lc(<>);
    chomp $confirmation;
} while $confirmation ne 'y' && $confirmation ne 'n';

exit if $confirmation eq 'n';

do {
    print "\nYou are ready to run script and generate a new school.\n";
    print "After script is run, call script again with '-p' option to see what you must do after running this script in order to fully implement your new school. Proceed? (y/n): ";
    $confirmation = lc(<>);
    chomp $confirmation;
} while $confirmation ne 'y' && $confirmation ne 'n';

exit if $confirmation eq 'n';

##########################
# INSERT SCHOOL INTO tusk.school

my $new_school = TUSK::Core::School->new();

$new_school->setDatabaseUserToken('ContentManager');

$new_school->setFieldValues({school_display => $school_display, school_name => $school_name, school_db => $school_db});

$new_school->save({user => $script_user});
print "Created school ($school_display) with id of " . $new_school->getPrimaryKeyID() . "\n";

##########################
# INSERT FORUM.CATEGORY FOR NEW SCHOOL

my $pkey = $new_school->getPrimaryKeyID();
$sql = "insert into mwforum.categories (title, pos, categorykey) values ('$school_name', 0, '0-$pkey-0')";

eval {
    $retval = $dbh->do($sql);
};
if ($@) {
    $error_string .= "Failure: $@ - query failed: $sql\n";
} else {
    print "Success: Created forum category with id of " . $dbh->{'mysql_insertid'} . "\n";
}

###############################
# ADD NEW SCHOOL TO THE ENUMS AND SETS OF SCHOOL NAMES

my @modify_type_fields = ({table => 'user', field => 'affiliation'},
			  {table => 'content', field => 'school'},
			  {table => 'xml_cache', field => 'school'},		   
			  {table => 'ppt_upload_status', field => 'school'} 
			  );

foreach (@modify_type_fields){
    
    $sth = $dbh->prepare("describe hsdb4.$_->{table} $_->{field}");

    eval {
	$sth->execute();
    };
    die "Failure: $@ - failed to retrieve type of $_->{field}" if ($@);

    my $field_description = $sth->fetchrow_hashref();
    my $field_type = $field_description->{Type};
    # add new school name to end of list of names
    $field_type =~ s/((set|enum)\('.*')\)/$1,'$school_name'\)/;
    $sql = "alter table hsdb4.$_->{table} modify $_->{field} $field_type";

    eval {
	$retval = $dbh->do($sql);
    };
    if ($@) {
	$error_string .= "Failure: $@ - query failed: $sql\n";
    } else {
	print "Success: Updated " . $_->{table} . " table's " . $_->{field} . " field's type.\n";
    }

}

$sth->finish;

##################################
# update course_metadata_display for the new school
insert_course_metadata_display();


##################################
# CREATE SCHOOL DATABASE

$sql = undef;
while(<DATA>){
    # skip comment and and blank lines
    next if /(^--|^$)/;
    chomp;
    # concatenate sql until we reach a semi-colon, at that point, sql is complete
    unless (/\;/){
	$sql .= $_;
	next;
    }		
		     
    $sql =~ s/##DB_NAME##/$school_db/g; 
    $sql =~ s/##CHILD_USER_ID##/$administrator/g; 
    $sql =~ s/##DEFAULT_USER##/$TUSK::Constants::DatabaseUsers->{ContentManager}->{readusername}/g; 
    $sql =~ s/##CONTENT_USER##/$TUSK::Constants::DatabaseUsers->{ContentManager}->{writeusername}/g; 
    $sql =~ s/##EVAL_ADMIN##/$TUSK::Constants::DatabaseUsers->{ContentManager}->{writeusername}/g; 

    eval {
	$retval = $dbh->do($sql);
    };
    if ($@){
	if ($sql =~ /(^create database|^use)/){
	    # if we fail on db creation or using, let's abort mission
	    die "FAILURE: $@ - sql: $sql" if $@;
	} else {
	    # otherwise, record error but continue
	    $error_string .= "Failure: $@ - query failed: $sql\n";
	}
    } else {
	print "SUCCESS: $sql\n";
    }
    $sql = undef;
}

print "SUCCESS:: Created database: $school_db\n";

print "Total Errors:\n\n$error_string\n" if $error_string; 

sub insert_course_metadata_display {
	my $school_id =  $new_school->getPrimaryKeyID();
	return unless $school_id;
	### first column is simply sequence for getting parent id
    ### display_title, sort_order, parent (ref to sequence), edit_type, locked(could be empty)
	my $data = [ 
				 ['ref_0','Attendance Policy', 1, undef, 'textarea'],
				 ['ref_1', 'Description', 2, undef, 'textarea'],
				 ['ref_2', 'Equipment List', 3, undef, 'list', 1],
				 ['ref_3', 'Equipment Item', 1, 'ref_2', 'text'],
				 ['ref_4', 'Grading And Evaluation', 4, undef, 'list', undef, 1],
				 ['ref_5', 'Grading Policy', 1, 'ref_4', 'table', undef, 1],
				 ['ref_6', 'Graded Item', undef, 'ref_5', 'table row'],
				 ['ref_7', 'Weight', 1, 'ref_6', 'text', '(use a % sign if you are giving percentages)'],
				 ['ref_8', 'Title', 2, 'ref_6', 'text'],
				 ['ref_9', 'Student Evaluation', 2, 'ref_4', 'textarea'],
				 ['ref_10', 'Other', 5, undef, 'textarea'],
				 ['ref_11', 'Reading List', 6, undef, 'table'],
				 ['ref_12', 'Reading List Item', undef, 'ref_11', 'table row'],
				 ['ref_13', 'Title', 1, 'ref_12', 'text'],
				 ['ref_14', 'Type', 2, 'ref_12', 'select'],
				 ['ref_15', 'Textbook', 1, 'ref_14', 'select-item'],
				 ['ref_16', 'Journal', 2, 'ref_14', 'select-item'],
				 ['ref_17', 'URL', 3, 'ref_14', 'select-item'],
				 ['ref_18', 'Medline Article', 4, 'ref_14', 'select-item'],
				 ['ref_19', 'Other', 4, 'ref_14', 'select-item'],
				 ['ref_20', 'Required', 3, 'ref_12', 'radio'],
				 ['ref_21', 'On Reserve', 4, 'ref_12', 'radio', '<b>On reserve</b> and <b>call number</b> are meant to be used with Textbook and Journal reading list items.'],
				 ['ref_22', 'Call Number', 5, 'ref_12', 'text', '<i>(if on reserve)</i>'],
				 ['ref_23', 'URL', 6, 'ref_12', 'text', 'The value of this field depends on the \'type\' chosen above.<br>For URLs (links to other Web pages), insert the Web address<br>here. For Medline articles, enter the article number. Otherwise, leave this field blank.'],
				 ['ref_24', 'Tutoring Services', 7, undef, 'textarea'],
				 ];
	my $md_objects = {};
	foreach my $dat (@$data) {
		my $md = TUSK::Course::CourseMetadataDisplay->new();
		$md->setDisplayTitle($dat->[1]);
		$md->setSortOrder($dat->[2]);
		if ($dat->[3] && exists $md_objects->{$dat->[3]}) {
			$md->setParent($md_objects->{$dat->[3]}->getPrimaryKeyID());
		}
		$md->setEditType($dat->[4]);
		$md->setEditComment($dat->[5]);
		$md->setLocked($dat->[6]) if $dat->[6];
		$md->setSchoolID($school_id);
		$md->save({user => $script_user});
		$md_objects->{$dat->[0]} = $md;
	}
}

sub print_help {
    print <<EOM;

    $0 [-h | -i]

    -h : gives you this help text
    -i : prints instructions for executing this script 
    -p : 'p'ost script instructions. that is, after the 
         script has been run, there are many files in TUSK
	 that must be manually edited to fully implement
	 the new school.

EOM
}

sub print_instructions {

    print <<EOM;

    This script will add a new school to TUSK.
    
    It will prompt user for following info:
	
	Username and password of account with global mysql
	'GRANT' permissions. Without this, script cannot
	add permissions for school's new database tables.

	School Display -- school name that will be shown on webpages

	School Name -- name of school that will be used in code and in certain fields of tusk db

	School Database -- this will determine name of school's new db; eg, hsdb45_med_admin.

	School Admin -- initial course administrator. additional administrators can be added later, if desired.

    After script has been run, there are many files in TUSK that need to be manually edited. Use the '-p' option to print those to screen.

EOM
}

sub print_post_script {

    print <<'EOM';

After create_school.pl has been run, there are many files in TUSK that need to be manually edited. The following instructions will take you through these edits.

#######
#Open /lib/TUSK/Constants.pm

search for declaration of $SchoolWideUserGroup
add key/value pair to anonymous hash where key is the school name (all lowercase) and value is '3'. this is the value that the new_school.pl script gives to the group 'Schoolwide Announcements'

search for declaration of @Affiliations
add school name (capitalized exactly as in db) to array

search for declaration of @SearchSchools
if you would like new school to be added to search drop down, add school name (capitalized exactly as in db) to array declaration.

######
#Open /lib/HSDB4/Constants.pm

there are a series of subs that return lists of schools. it is likely that your new school name will need to be added to many of them (in all cases, capitalized exactly as in db).

sub schools() - add name here if school will employ user groups or forums, or if you want it to show up in list of schools on 'browse all courses' page

sub schedule_schools() - add name if school will employ a schedule

sub course_schools() - add name if school will have courses

sub eval_schools() - add name if school will have evaluations

sub survey_schools() - ??

sub user_group_schools() - add name if school will have user groups

sub forum_schools() - add name if school will have forums

sub homepage_course_schools() - add name if school should show up in list of schools on 'browse all courses' page

search for %code_schools
add a unique capital letter as key, and school name (capitalized exactly as it appears in db) as value

search for %school_codes
add school name as key (all lowercase) and single capital letter as value (same letter added above)

search for %school_dbs
add school name as key (all lowercase) and school database as value

search for %school_eags
add school name as key (all lowercase) and 2 as value (script has set the id for the user group as 2 when it added eval user group for you)

search for %School_Admin_Group
add school name as key (capitalized exactly as it appears in db) and 1 as value (script has set the id for the user group as 1 when it added eval user group for you)

search for %School_Edit_Group
add school name as key (capitalized exactly as it appears in db) and 1 as value (script has set the id for the user group as 1 when it added eval user group for you)


EOM
}


__DATA__


create database ##DB_NAME##
;
use ##DB_NAME##
;
-- MySQL dump 10.9
-- Host: localhost    Database: hsdb45_med_admin
-- ------------------------------------------------------
-- Table structure for table `announcement`

CREATE TABLE `announcement` (
  `announcement_id` int(10) unsigned NOT NULL auto_increment,
  `created` timestamp NOT NULL,`start_date` date NOT NULL default '0000-00-00',
  `expire_date` date NOT NULL default '0000-00-00',
  `username` varchar(24) NOT NULL default '',
  `user_group_id` int(10) unsigned NOT NULL default '0',
  `body` text,
  PRIMARY KEY  (`announcement_id`),
  KEY `user_group_id` (`user_group_id`),
  KEY `expire_date` (`expire_date`),
  KEY `start_date` (`start_date`))
;

--
-- Table structure for table `class_meeting`
--

CREATE TABLE `class_meeting` (
  `class_meeting_id` int(10) unsigned NOT NULL auto_increment,
  `title` varchar(120) NOT NULL default '',
  `oea_code` varchar(24) NOT NULL default '',
  `course_id` int(10) unsigned NOT NULL default '0',
  `type_id` int(10) unsigned default NULL,
  `meeting_date` date NOT NULL default '0000-00-00',
  `starttime` time NOT NULL default '00:00:00',
  `endtime` time default NULL,
  `location` varchar(255) default NULL,
  `is_duplicate` tinyint(1) unsigned default '0',
  `is_mandatory` tinyint(1) unsigned default '0',
  `modified` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `flagtime` datetime default NULL,
  `body` text,
  PRIMARY KEY  (`class_meeting_id`),
  KEY `course_id` (`course_id`),
  KEY `unit_date` (`meeting_date`,`starttime`),
  KEY `oea_code` (`oea_code`),
  KEY `type_id` (`type_id`),
  KEY `is_duplicate` (`is_duplicate`)
) ENGINE=MyISAM AUTO_INCREMENT=26457 DEFAULT CHARSET=latin1
;

--
-- Table structure for table `course`
--

CREATE TABLE `course` (
  `course_id` int(10) unsigned NOT NULL auto_increment,
  `title` varchar(120) NOT NULL default '',
  `oea_code` varchar(32) default NULL,
  `color` varchar(20) default NULL,
  `abbreviation` varchar(24) default NULL,
  `associate_users` set('User Group','Enrollment') default NULL,
  `type` enum('course','integrated course','committee','community service','group','thesis committee') default NULL,
  `course_source` enum('Catalog','Independent') default NULL,
  `modified` timestamp NOT NULL,
  `body` text,
  `rss` tinyint(1) default '1',
  PRIMARY KEY  (`course_id`),
  KEY `title` (`title`))
;

--
-- Table structure for table `default_stylesheet`
--

CREATE TABLE `default_stylesheet` (
  `stylesheet_type_id` int(10) unsigned NOT NULL auto_increment,
  `default_stylesheet_id` int(10) unsigned default NULL,
  `modified` timestamp NOT NULL,
  PRIMARY KEY  (`stylesheet_type_id`))
;

--
-- Table structure for table `eval`
--

CREATE TABLE `eval` (
  `eval_id` int(10) unsigned NOT NULL auto_increment,
  `course_id` int(10) unsigned NOT NULL default '0',
  `time_period_id` int(10) unsigned NOT NULL default '0',
  `teaching_site_id` int(10) unsigned default NULL,
  `title` varchar(128) NOT NULL default '',
  `available_date` date NOT NULL default '0000-00-00',
  `modified` timestamp NOT NULL,
  `due_date` date NOT NULL default '0000-00-00',
  `prelim_due_date` date default NULL,
  `submittable_date` date default NULL,
  `question_stylesheet` int(10) default NULL,
  `results_stylesheet` int(10) default NULL,
  PRIMARY KEY  (`eval_id`),
  KEY `course_id` (`course_id`),
  KEY `available_date` (`available_date`))
;

--
-- Table structure for table `eval_completion`
--

CREATE TABLE `eval_completion` (
  `user_id` varchar(32) NOT NULL default '',
  `eval_id` int(10) unsigned NOT NULL default '0',
  `created` timestamp NOT NULL,
  `status` enum('Done','Not done') NOT NULL default 'Not done',
  PRIMARY KEY  (`user_id`,`eval_id`),
  KEY `eval_id` (`eval_id`,`status`))
;

--
-- Table structure for table `eval_mergedresults_graphics`
--

CREATE TABLE `eval_mergedresults_graphics` (
  `eval_mergedresults_graphics_id` int(10) unsigned NOT NULL auto_increment,
  `merged_eval_results_id` int(10) unsigned NOT NULL default '0',
  `eval_question_id` int(10) unsigned NOT NULL default '0',
  `mime_type` varchar(128) NOT NULL default 'image/png',
  `width` int(10) unsigned NOT NULL default '0',
  `height` int(10) unsigned NOT NULL default '0',
  `graphic` mediumblob NOT NULL,
  `graphic_text` text,
  `modified` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`eval_mergedresults_graphics_id`),
  KEY `eval_id` (`merged_eval_results_id`,`eval_question_id`)
) ENGINE=MyISAM AUTO_INCREMENT=13617 DEFAULT CHARSET=latin1
;

--
-- Table structure for table `eval_question`
--

CREATE TABLE `eval_question` (
  `eval_question_id` int(10) unsigned NOT NULL auto_increment,
  `body` text,
  `modified` timestamp NOT NULL,
  PRIMARY KEY  (`eval_question_id`))
;

--
-- Table structure for table `eval_question_convert`
--

CREATE TABLE `eval_question_convert` (
  `eval_question_id` int(10) unsigned NOT NULL default '0',
  `new_body` text,
  PRIMARY KEY  (`eval_question_id`))
;

--
-- Table structure for table `eval_response`
--

CREATE TABLE `eval_response` (
  `user_code` varchar(32) NOT NULL default '0',
  `eval_id` int(10) unsigned NOT NULL default '0',
  `eval_question_id` int(10) unsigned NOT NULL default '0',
  `response` text,
  `fixed` char(1) default NULL,
  `modified` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`eval_id`,`eval_question_id`,`user_code`),
  KEY `user_code` (`user_code`,`eval_id`))
;

--
-- Table structure for table `eval_results_graphics`
--

CREATE TABLE `eval_results_graphics` (
  `eval_results_graphics_id` int(10) unsigned NOT NULL auto_increment,
  `eval_id` int(10) unsigned NOT NULL default '0',
  `eval_question_id` int(10) unsigned NOT NULL default '0',
  `categorization_question_id` int(10) unsigned default NULL,
  `categorization_value` varchar(255) default NULL,
  `mime_type` varchar(128) NOT NULL default 'image/png',
  `width` int(10) unsigned NOT NULL default '0',
  `height` int(10) unsigned NOT NULL default '0',
  `graphic` mediumblob NOT NULL,
  `modified` timestamp NOT NULL,
  PRIMARY KEY  (`eval_results_graphics_id`),
  KEY `eval_id` (`eval_id`,`eval_question_id`))
  ENGINE=MyISAM DEFAULT CHARSET=latin1
;

--
-- Table structure for table `eval_results_histogram`
--

CREATE TABLE `eval_results_histogram` (
  `eval_results_histogram_id` int(10) unsigned NOT NULL auto_increment,
  `eval_id` int(10) unsigned NOT NULL default '0',
  `eval_question_id` int(10) default NULL,
  `categorization_question_id` int(10) unsigned default NULL,
  `categorization_value` varchar(255) default NULL,
  `mime_type` varchar(128) NOT NULL default 'text/html',
  `width` int(10) unsigned NOT NULL default '0',
  `height` int(10) unsigned NOT NULL default '0',
  `graphic` mediumblob NOT NULL,
  `modified` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`eval_results_histogram_id`),
  KEY `eval_id` (`eval_id`,`eval_question_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1
;

--
-- Table structure for table `eval_merged_results_histogram`
--


CREATE TABLE `eval_merged_results_histogram` (
  `eval_merged_results_histogram_id` int(10) unsigned NOT NULL auto_increment,
  `merged_eval_results_id` int(10) unsigned NOT NULL default '0',
  `eval_question_id` int(10) default NULL,
  `categorization_question_id` int(10) unsigned default NULL,
  `categorization_value` varchar(255) default NULL,
  `mime_type` varchar(128) NOT NULL default 'text/html',
  `width` int(10) unsigned NOT NULL default '0',
  `height` int(10) unsigned NOT NULL default '0',
  `graphic` mediumblob NOT NULL,
  `graphic_text` text NOT NULL,
  `modified` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`eval_merged_results_histogram_id`),
  KEY `merged_eval_results_id` (`merged_eval_results_id`,`eval_question_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1
;

--
-- Table structure for table `eval_results_supporting_graphs`
--

CREATE TABLE `eval_results_supporting_graphs` (
  `eval_results_support_graph_id` int(10) unsigned NOT NULL auto_increment,
  `eval_id` int(10) unsigned NOT NULL default '0',
  `eval_question_id` int(10) default NULL,
  `graph_type` varchar(255) default NULL,
  `categorization_question_id` int(10) unsigned default NULL,
  `categorization_value` varchar(255) default NULL,
  `mime_type` varchar(128) NOT NULL default 'text/html',
  `width` int(10) unsigned NOT NULL default '0',
  `height` int(10) unsigned NOT NULL default '0',
  `graphic` mediumblob NOT NULL,
  `modified` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`eval_results_support_graph_id`),
  KEY `eval_id` (`eval_id`,`eval_question_id`,`graph_type`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1
;

--
-- Table structure for table `eval_merged_results_supporting_graphs`

CREATE TABLE `eval_merged_results_supporting_graphs` (
  `eval_merged_results_support_graph_id` int(10) unsigned NOT NULL auto_increment,
  `merged_eval_results_id` int(10) unsigned NOT NULL default '0',
  `eval_question_id` int(10) default NULL,
  `graph_type` varchar(255) default NULL,
  `categorization_question_id` int(10) unsigned default NULL,
  `categorization_value` varchar(255) default NULL,
  `mime_type` varchar(128) NOT NULL default 'text/html',
  `width` int(10) unsigned NOT NULL default '0',
  `height` int(10) unsigned NOT NULL default '0',
  `graphic` mediumblob NOT NULL,
  `graphic_text` text NOT NULL,
  `modified` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`eval_merged_results_support_graph_id`),
  KEY `merged_eval_results_id` (`merged_eval_results_id`,`eval_question_id`,`graph_type`)
) ENGINE=MyISAM AUTO_INCREMENT=1721 DEFAULT CHARSET=latin1
;

--
-- Table structure for table `eval_save_data`
--

CREATE TABLE `eval_save_data` (
  `eval_save_data_id` int(10) unsigned NOT NULL auto_increment,
  `user_eval_code` varchar(128) NOT NULL default '',
  `data` text,
  PRIMARY KEY  (`eval_save_data_id`),
  KEY `user_eval_code` (`user_eval_code`))
;

--
-- Table structure for table `homepage_category`
--

CREATE TABLE `homepage_category` (
  `id` int(10) NOT NULL auto_increment,
  `primary_user_group_id` int(10) default NULL,
  `secondary_user_group_id` int(10) default NULL,
  `label` varchar(100) default NULL,
  `sort_order` int(10) default NULL,
  `schedule` int(1) default NULL,
  `modified` timestamp NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `user_group` (`primary_user_group_id`))
;

--
-- Table structure for table `homepage_course`
--

CREATE TABLE `homepage_course` (
  `id` int(10) NOT NULL auto_increment,
  `course_id` int(10) default NULL,
  `category_id` int(10) default NULL,
  `sort_order` int(10) default NULL,
  `label` varchar(100) default NULL,
  `url` varchar(255) default NULL,
  `indent` int(1) default NULL,
  `modified` timestamp NOT NULL,
  `last_changed` datetime default NULL,
  `show_date` date default NULL,
  `hide_date` date default NULL,
  PRIMARY KEY  (`id`),
  KEY `course` (`course_id`),
  KEY `category` (`category_id`))
;

--
-- Table structure for table `hot_content_cache`
--

CREATE TABLE `hot_content_cache` (
  `user_group_id` int(10) unsigned NOT NULL default '0',
  `modified` timestamp NOT NULL,
  `content_ids` varchar(255) NOT NULL default '',
  PRIMARY KEY  (`user_group_id`),
  KEY `modified` (`modified`))
;

--
-- Table structure for table `link_class_meeting_content`
--

CREATE TABLE `link_class_meeting_content` (
  `link_class_meeting_content_id` int(11) NOT NULL auto_increment,
  `parent_class_meeting_id` int(10) unsigned NOT NULL default '0',
  `child_content_id` int(10) unsigned NOT NULL default '0',
  `class_meeting_content_type_id` int(11) NOT NULL default '0',
  `anchor_label` varchar(255) default NULL,
  `sort_order` smallint(6) unsigned NOT NULL default '65535',
  `label` varchar(255) default NULL,
  `modified` timestamp NOT NULL,
  PRIMARY KEY  (`link_class_meeting_content_id`),
  UNIQUE KEY `link_class_meeting_content_u01` (`parent_class_meeting_id`,`child_content_id`,`class_meeting_content_type_id`),
  KEY `child_content_id` (`child_content_id`),
  KEY `parent_class_meeting_id` (`parent_class_meeting_id`,`sort_order`))
;

--
-- Table structure for table `link_class_meeting_topic`
--

CREATE TABLE `link_class_meeting_topic` (
  `parent_class_meeting_id` int(10) unsigned NOT NULL default '0',
  `child_topic_id` int(10) unsigned NOT NULL default '0',
  `sort_order` smallint(6) unsigned NOT NULL default '65535',
  `relationship` enum('Prerequisite','Topic','Evaluation','Subtopic') default NULL,
  `modified` timestamp NOT NULL,
  PRIMARY KEY  (`parent_class_meeting_id`,`child_topic_id`),
  KEY `child_topic_id` (`child_topic_id`),
  KEY `parent_class_meeting_id` (`parent_class_meeting_id`,`sort_order`))
;

--
-- Table structure for table `link_class_meeting_user`
--

CREATE TABLE `link_class_meeting_user` (
  `parent_class_meeting_id` int(10) unsigned NOT NULL default '0',
  `child_user_id` char(24) NOT NULL default '',
  `sort_order` smallint(6) unsigned NOT NULL default '65535',
  `roles` set('Director','Author','Lecturer','Instructor') default NULL,
  `modified` timestamp NOT NULL,
  PRIMARY KEY  (`parent_class_meeting_id`,`child_user_id`),
  KEY `child_user_id` (`child_user_id`),
  KEY `parent_class_meeting_id` (`parent_class_meeting_id`,`sort_order`))
;

--
-- Table structure for table `link_course_announcement`
--

CREATE TABLE `link_course_announcement` (
  `parent_course_id` char(24) NOT NULL default '',
  `child_announcement_id` int(10) unsigned NOT NULL default '0',
  `modified` timestamp NOT NULL,
  PRIMARY KEY  (`parent_course_id`,`child_announcement_id`))
;

--
-- Table structure for table `link_course_content`
--

CREATE TABLE `link_course_content` (
  `parent_course_id` int(10) unsigned NOT NULL default '0',
  `child_content_id` int(10) unsigned NOT NULL default '0',
  `sort_order` smallint(6) unsigned NOT NULL default '65535',
  `label` varchar(255) default NULL,
  `modified` timestamp NOT NULL,
  PRIMARY KEY  (`parent_course_id`,`child_content_id`),
  KEY `child_content_id` (`child_content_id`),
  KEY `parent_course_id` (`parent_course_id`,`sort_order`))
;

--
-- Table structure for table `link_course_course`
--

CREATE TABLE `link_course_course` (
  `parent_course_id` int(10) unsigned NOT NULL default '0',
  `child_course_id` int(10) unsigned NOT NULL default '0',
  `sort_order` smallint(6) unsigned NOT NULL default '65535',
  `modified` timestamp NOT NULL,
  PRIMARY KEY  (`parent_course_id`,`child_course_id`),
  KEY `child_course_id` (`child_course_id`),
  KEY `parent_course_id` (`parent_course_id`,`sort_order`))
;

--
-- Table structure for table `link_course_forum`
--

CREATE TABLE `link_course_forum` (
  `parent_course_id` int(11) NOT NULL default '0',
  `child_forum_id` int(11) NOT NULL default '0',
  `time_period_id` int(10) unsigned NOT NULL default '0',
  PRIMARY KEY  (`parent_course_id`,`child_forum_id`))
;

--
-- Table structure for table `link_course_objective`
--

CREATE TABLE `link_course_objective` (
  `parent_course_id` int(10) unsigned NOT NULL default '0',
  `child_objective_id` int(10) unsigned NOT NULL default '0',
  `sort_order` smallint(6) unsigned NOT NULL default '65535',
  `relationship` enum('Prerequisite','Objective','Evaluation','Subobjective') default NULL,
  `modified` timestamp NOT NULL,
  PRIMARY KEY  (`parent_course_id`,`child_objective_id`))
;

--
-- Table structure for table `link_course_student`
--

CREATE TABLE `link_course_student` (
  `parent_course_id` int(10) unsigned NOT NULL default '0',
  `child_user_id` char(24) NOT NULL default '',
  `time_period_id` int(10) unsigned NOT NULL default '0',
  `modified` timestamp NOT NULL,
  `teaching_site_id` int(10) NOT NULL default '0',
  `elective` tinyint(1) NOT NULL default '0',
  PRIMARY KEY  (`parent_course_id`,`child_user_id`,`time_period_id`,`teaching_site_id`),
  KEY `child_user_id` (`child_user_id`))
;

--
-- Table structure for table `link_course_teaching_site`
--

CREATE TABLE `link_course_teaching_site` (
  `parent_course_id` int(10) unsigned NOT NULL default '0',
  `child_teaching_site_id` int(10) unsigned NOT NULL default '0',
  `max_students` int(10) unsigned default NULL,
  `modified` timestamp NOT NULL,
  PRIMARY KEY  (`parent_course_id`,`child_teaching_site_id`))
;

--
-- Table structure for table `link_course_topic`
--

CREATE TABLE `link_course_topic` (
  `parent_course_id` int(10) unsigned NOT NULL default '0',
  `child_topic_id` int(10) unsigned NOT NULL default '0',
  `sort_order` smallint(6) unsigned NOT NULL default '65535',
  `relationship` enum('Prerequisite','Topic','Evaluation','Subtopic') default NULL,
  `modified` timestamp NOT NULL,
  PRIMARY KEY  (`parent_course_id`,`child_topic_id`),
  KEY `child_topic_id` (`child_topic_id`),
  KEY `parent_course_id` (`parent_course_id`,`sort_order`))
;

--
-- Table structure for table `link_course_user`
--

CREATE TABLE `link_course_user` (
  `parent_course_id` int(10) unsigned NOT NULL default '0',
  `child_user_id` varchar(24) NOT NULL default '',
  `sort_order` smallint(6) unsigned NOT NULL default '65535',
  `roles` set('Director','Manager','Student Manager','Site Director','Editor','Author','Student Editor','Lecturer','Instructor','Lab Instructor','Librarian','MERC Representative','Teaching Assistant') default NULL,
  `teaching_site_id` int(10) unsigned NOT NULL default '0',
  `modified` timestamp NOT NULL,
  PRIMARY KEY  (`parent_course_id`,`child_user_id`),
  KEY `child_user_id` (`child_user_id`),
  KEY `parent_course_id` (`parent_course_id`,`sort_order`))
;

--
-- Table structure for table `link_course_user_group`
--

CREATE TABLE `link_course_user_group` (
  `parent_course_id` int(10) unsigned NOT NULL default '0',
  `child_user_group_id` int(10) unsigned NOT NULL default '0',
  `time_period_id` int(10) unsigned NOT NULL default '0',
  PRIMARY KEY  (`parent_course_id`,`child_user_group_id`,`time_period_id`),
  KEY `child_user_group_id` (`child_user_group_id`,`time_period_id`))
;

--
-- Table structure for table `link_eval_eval_question`
--

CREATE TABLE `link_eval_eval_question` (
  `parent_eval_id` int(10) unsigned NOT NULL default '0',
  `child_eval_question_id` int(10) unsigned NOT NULL default '0',
  `label` varchar(32) default NULL,
  `sort_order` smallint(5) unsigned NOT NULL default '0',
  `required` enum('Yes','No') default 'No',
  `grouping` varchar(255) default NULL,
  `graphic_stylesheet` varchar(255) default NULL,
  `modified` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`parent_eval_id`,`child_eval_question_id`),
  KEY `parent_eval_id` (`parent_eval_id`,`sort_order`),
  KEY `child_eval_question_id` (`child_eval_question_id`))
;

--
-- Table structure for table `link_small_group_user`
--

CREATE TABLE `link_small_group_user` (
  `parent_small_group_id` int(10) unsigned NOT NULL default '0',
  `child_user_id` char(24) NOT NULL default '',
  `roles` set('Director','Author','Lecturer','Instructor','Student','Teaching Assistant') default NULL,
  `modified` timestamp NOT NULL,
  PRIMARY KEY  (`parent_small_group_id`,`child_user_id`),
  KEY `child_user_id` (`child_user_id`))
;

--
-- Table structure for table `link_teaching_site_user`
--

CREATE TABLE `link_teaching_site_user` (
  `parent_teaching_site_id` int(10) unsigned NOT NULL default '0',
  `child_user_id` varchar(24) NOT NULL default '',
  `modified` timestamp NOT NULL,
  PRIMARY KEY  (`parent_teaching_site_id`,`child_user_id`))
;

--
-- Table structure for table `link_user_group_announcement`
--

CREATE TABLE `link_user_group_announcement` (
  `parent_user_group_id` char(24) NOT NULL default '',
  `child_announcement_id` int(10) unsigned NOT NULL default '0',
  `modified` timestamp NOT NULL,
  PRIMARY KEY  (`parent_user_group_id`,`child_announcement_id`))
;

--
-- Table structure for table `link_user_group_forum`
--

CREATE TABLE `link_user_group_forum` (
  `parent_user_group_id` int(10) NOT NULL default '0',
  `child_forum_id` int(10) NOT NULL default '0',
  PRIMARY KEY  (`parent_user_group_id`,`child_forum_id`))
;

--
-- Table structure for table `link_user_group_user`
--

CREATE TABLE `link_user_group_user` (
  `parent_user_group_id` int(10) unsigned NOT NULL default '0',
  `child_user_id` char(24) NOT NULL default '',
  `modified` timestamp NOT NULL,
  PRIMARY KEY  (`parent_user_group_id`,`child_user_id`),
  KEY `child_user_id` (`child_user_id`))
;

--
-- Table structure for table `location_exception`
--

CREATE TABLE `location_exception` (
  `small_group_id` int(10) unsigned NOT NULL default '0',
  `meeting_date` date NOT NULL default '0000-00-00',
  `new_location` varchar(64) default NULL,
  `new_instructor` varchar(64) default NULL,
  `modified` timestamp NOT NULL,
  PRIMARY KEY  (`small_group_id`,`meeting_date`))
;

--
-- Table structure for table `merged_eval_results`
--

CREATE TABLE `merged_eval_results` (
  `merged_eval_results_id` int(14) unsigned NOT NULL auto_increment,
  `title` varchar(128) default NULL,
  `primary_eval_id` int(14) unsigned NOT NULL default '0',
  `secondary_eval_ids` text,
  `modified` timestamp NOT NULL,
  PRIMARY KEY  (`merged_eval_results_id`))
;

--
-- Table structure for table `old_link_course_user`
--

CREATE TABLE `old_link_course_user` (
  `old_link_course_user_id` int(10) NOT NULL auto_increment,
  `parent_course_id` int(10) unsigned NOT NULL default '0',
  `child_user_id` char(24) NOT NULL default '',
  `sort_order` smallint(6) unsigned NOT NULL default '65535',
  `roles` set('Director','Editor','Author','Lecturer','Instructor','Cooperating Instructor','Teaching Assistant','Lab Instructor','Librarian','MERC Representative') default NULL,
  `modified` timestamp NOT NULL,
  `created` timestamp NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`old_link_course_user_id`),
  KEY `child_user_id` (`child_user_id`),
  KEY `parent_course_id` (`parent_course_id`,`sort_order`))
;

--
-- Table structure for table `small_group`
--

CREATE TABLE `small_group` (
  `small_group_id` int(10) unsigned NOT NULL auto_increment,
  `course_id` int(10) unsigned NOT NULL default '0',
  `time_period_id` int(10) unsigned NOT NULL default '0',
  `label` varchar(64) default NULL,
  `meeting_type` enum('Lecture','Small Group','Conference','Laboratory','Examination','Reception','Luncheon','Unknown') NOT NULL default 'Unknown',
  `instructor` varchar(64) default NULL,
  `location` varchar(64) default NULL,
  `max_students` smallint(6) default NULL,
  `modified` timestamp NOT NULL,
  PRIMARY KEY  (`small_group_id`),
  KEY `course_id` (`course_id`,`meeting_type`))
;

--
-- Table structure for table `stylesheet`
--

CREATE TABLE `stylesheet` (
  `stylesheet_id` int(10) unsigned NOT NULL auto_increment,
  `stylesheet_type_id` int(10) unsigned NOT NULL default '0',
  `label` varchar(50) default NULL,
  `body` longtext NOT NULL,
  `description` text,
  `modified` timestamp NOT NULL,
  PRIMARY KEY  (`stylesheet_id`),
  UNIQUE KEY `label` (`label`),
  KEY `stylesheet_type_id` (`stylesheet_type_id`))
;

--
-- Table structure for table `teaching_site`
--

CREATE TABLE `teaching_site` (
  `teaching_site_id` int(10) unsigned NOT NULL auto_increment,
  `site_name` varchar(64) NOT NULL default '',
  `site_city_state` varchar(64) default NULL,
  `modified` timestamp NOT NULL,
  `body` text,
  PRIMARY KEY  (`teaching_site_id`),
  KEY `site_name` (`site_name`))
;

--
-- Table structure for table `time_period`
--

CREATE TABLE `time_period` (
  `time_period_id` int(10) unsigned NOT NULL auto_increment,
  `academic_year` varchar(9) NOT NULL default '2000-2001',
  `period` varchar(128) NOT NULL default '',
  `start_date` date default NULL,
  `end_date` date default NULL,
  PRIMARY KEY  (`time_period_id`))
;


--
-- Insert 'eternity' time period into table (used by 'My Groups')
--

insert into time_period (academic_year, period, start_date, end_date) values ('', 'eternity', now(), '2036-10-31')
;


--
-- Table structure for table `tracking`
--

CREATE TABLE `tracking` (
  `tracking_id` int(10) unsigned NOT NULL auto_increment,
  `course_id` int(10) unsigned NOT NULL default '0',
  `user_group_id` int(10) unsigned default '0',
  `content_id` int(10) unsigned NOT NULL default '0',
  `start_date` date default NULL,
  `end_date` date default NULL,
  `page_views` int(10) unsigned default '0',
  `unique_visitors` int(10) unsigned default '0',
  `sort_order` int(10) unsigned default '999999999',
  `time_period_id` int(10) default '0',
  PRIMARY KEY  (`tracking_id`),
  KEY `course_id` (`course_id`))
;

--
-- Table structure for table `user_group`
--

CREATE TABLE `user_group` (
  `user_group_id` int(10) unsigned NOT NULL auto_increment,
  `label` varchar(64) default NULL,
  `homepage_info` set('Hot Content','Announcements','Evals','Discussion') default NULL,
  `schedule_flag_time` datetime default NULL,
  `modified` timestamp NOT NULL,
  `sub_group` enum('Yes','No') default 'No',
  `description` mediumtext,
  `sort_order` tinyint(3) unsigned default NULL,
  PRIMARY KEY  (`user_group_id`))
;

insert into user_group values (1,'School Administrators','Announcements',NULL,now(),'No',NULL,0)
;
insert into user_group values (2,'Evaluations Administrators','Announcements',NULL,now(),'No',NULL,1)
;
insert into user_group values (3,'Schoolwide Announcements','Announcements',NULL,now(),'No',NULL,2)
;
insert into link_user_group_user values (1,'##CHILD_USER_ID##',now())
;

--
-- now grant permissions
--

GRANT SELECT ON `##DB_NAME##`.* TO '##DEFAULT_USER##'@'%'
;    
GRANT SELECT, INSERT, UPDATE ON `##DB_NAME##`.`eval_results_graphics` TO '##DEFAULT_USER##'@'%'
;
GRANT INSERT ON `##DB_NAME##`.`eval_response` TO '##DEFAULT_USER##'@'%'
;
GRANT SELECT, INSERT, UPDATE ON `##DB_NAME##`.`stylesheet` TO '##DEFAULT_USER##'@'%'
;
GRANT SELECT, INSERT, UPDATE ON `##DB_NAME##`.`default_stylesheet` TO '##DEFAULT_USER##'@'%'
;
GRANT INSERT ON `##DB_NAME##`.`eval_completion` TO '##DEFAULT_USER##'@'%'
;
GRANT SELECT, INSERT, UPDATE, DELETE ON `##DB_NAME##`.`hot_content_cache` TO '##DEFAULT_USER##'@'%'
;
GRANT SELECT, INSERT, UPDATE, DELETE ON `##DB_NAME##`.`eval_save_data` TO '##DEFAULT_USER##'@'%'
;
GRANT SELECT, INSERT, UPDATE ON `##DB_NAME##`.`eval_mergedresults_graphics` TO '##DEFAULT_USER##'@'%'
;
GRANT SELECT, INSERT, UPDATE, DELETE ON `##DB_NAME##`.`link_course_student` TO '##CONTENT_USER##'@'%'
;
GRANT SELECT, INSERT, UPDATE, DELETE ON `##DB_NAME##`.`user_group` TO '##CONTENT_USER##'@'%'
;
GRANT SELECT, INSERT, UPDATE, DELETE ON `##DB_NAME##`.`teaching_site` TO '##CONTENT_USER##'@'%'
;
GRANT SELECT, INSERT, UPDATE, DELETE ON `##DB_NAME##`.`announcement` TO '##CONTENT_USER##'@'%'
;
GRANT SELECT, INSERT, UPDATE, DELETE ON `##DB_NAME##`.`course` TO '##CONTENT_USER##'@'%'
;
GRANT SELECT, INSERT, UPDATE, DELETE ON `##DB_NAME##`.`link_user_group_user` TO '##CONTENT_USER##'@'%'
;
GRANT SELECT, INSERT, UPDATE, DELETE ON `##DB_NAME##`.`link_course_forum` TO '##CONTENT_USER##'@'%'
;
GRANT SELECT, INSERT, UPDATE, DELETE ON `##DB_NAME##`.`link_user_group_forum` TO '##CONTENT_USER##'@'%'
;
GRANT SELECT, INSERT, UPDATE, DELETE ON `##DB_NAME##`.`link_course_user` TO '##CONTENT_USER##'@'%'
;
GRANT SELECT, INSERT, UPDATE, DELETE ON `##DB_NAME##`.`eval` TO '##EVAL_USER##'@'%'
;
GRANT SELECT, INSERT, UPDATE, DELETE ON `##DB_NAME##`.`eval_question` TO '##EVAL_USER##'@'%'
;
GRANT SELECT, INSERT, UPDATE, DELETE ON `##DB_NAME##`.`link_eval_eval_question` TO '##EVAL_USER##'@'%'
;
GRANT SELECT, INSERT, UPDATE, DELETE ON `##DB_NAME##`.`merged_eval_results` TO '##EVAL_USER##'@'%'
;
GRANT SELECT, INSERT, UPDATE, DELETE ON `##DB_NAME##`.`link_course_teaching_site` TO '##CONTENT_USER##'@'%'
;
GRANT SELECT, INSERT, UPDATE, DELETE ON `##DB_NAME##`.`link_course_user_group` TO '##CONTENT_USER##'@'%'
;
GRANT SELECT, INSERT, UPDATE, DELETE ON `##DB_NAME##`.`link_course_content` TO '##CONTENT_USER##'@'%'
;
GRANT SELECT, INSERT, UPDATE, DELETE ON `##DB_NAME##`.`link_teaching_site_user` TO '##CONTENT_USER##'@'%'
;
GRANT SELECT, INSERT, UPDATE, DELETE ON `##DB_NAME##`.`tracking` TO '##CONTENT_USER##'@'%'
;
GRANT SELECT, INSERT, UPDATE, DELETE ON `##DB_NAME##`.`homepage_category` TO '##CONTENT_USER##'@'%'
;
GRANT SELECT, INSERT, UPDATE, DELETE ON `##DB_NAME##`.`link_course_objective` TO '##CONTENT_USER##'@'%'
;
GRANT SELECT, INSERT, UPDATE, DELETE ON `##DB_NAME##`.`class_meeting` TO '##CONTENT_USER##'@'%'
;
GRANT SELECT, INSERT, UPDATE, DELETE ON `##DB_NAME##`.`homepage_course` TO '##CONTENT_USER##'@'%'
;
GRANT SELECT, INSERT, UPDATE, DELETE ON `##DB_NAME##`.`time_period` TO '##CONTENT_USER##'@'%'
;
GRANT SELECT, INSERT, UPDATE, DELETE ON `##DB_NAME##`.`link_user_group_announcement` TO '##CONTENT_USER##'@'%'
;
GRANT SELECT, INSERT, UPDATE, DELETE ON `##DB_NAME##`.`link_course_announcement` TO '##CONTENT_USER##'@'%'
;
GRANT SELECT, INSERT, UPDATE, DELETE ON `##DB_NAME##`.`link_class_meeting_content` TO '##CONTENT_USER##'@'%'
;