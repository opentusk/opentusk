#!/usr/bin/perl -w

use strict;
use FindBin;
use lib "$FindBin::Bin/../../lib";
use MySQL::Password;
use TUSK::Core::School;
use TUSK::Course::CourseMetadataDisplay;
use TUSK::Constants;
use File::Find qw(find);
use DBI;
use Getopt::Std;

### $script_user (set below as unix login) is value for created and modified in db (when needed)
my $script_user = getpwuid($<) || "new_school_script";
my ($dbh, $sth, $sql, $retval, $error_string, $tusk_admin, $confirmation);

main();


sub main {
    get_user_options();

    validateUser();

    getTuskAdmin();

    my $school_dbs = getExistingSchoolDatabases();

    ## read config file and try to setup each school. skips if school database is already there
    foreach my $school (keys %TUSK::Constants::Schools) {
	warn "considering school: $school";
	unless (exists $school_dbs->{'hsdb45_' . $TUSK::Constants::Schools{$school}{ShortName} . '_admin'}) {
		warn "creating school: $school";
	    if (my $new_school = insertSchool($school, $TUSK::Constants::Schools{$school})) {
		insertForumCategory($new_school);
		insertSchoolEnum($new_school);
		insert_course_metadata_display($new_school);
		createSchoolDatabase($new_school);
	    }
	}
    }
}


sub getExistingSchoolDatabases {
    my $sth = $dbh->prepare('show databases');
    $sth->execute();
    my %dbs = ();
    while (my @data = $sth->fetchrow_array()) {
	$dbs{$data[0]} = 1;
    }
    $sth->finish();
    return \%dbs;
}


sub get_user_options {
    our ($opt_h, $opt_i);
    getopts ("hi");

    print_help() if $opt_h;
    print_instructions() if $opt_i;
    exit if $opt_h or $opt_i;
}

sub validateUser {
    # $user_name & $password used to connect to db; 
    my ($user_name, $password);

    print "\nPlease enter username of account with global mysql 'GRANT' permissions (this is necessary in order to create new school database). Hint: the default is often 'root'. For $script_user, press <return>. \n\nUser name:  ";
    $user_name = <>;
    chomp $user_name;
    $user_name = $script_user unless defined $user_name;

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
	$sth->execute();
    };
    die "Failure: $@ - sql: $sql" if ($@);

    my $privileges = $sth->fetchrow_array();
    $sth->finish();

    die "User $user_name does not have global GRANT permissions\n" if $privileges ne 'Y';

    $script_user = $user_name;
}


sub getTuskAdmin {
    do {
	print "\nUsername of administrator for new school (for $script_user, press <return>, otherwise, type new id and press <return>): ";

	$tusk_admin = <>;
	chomp $tusk_admin;
	
	$tusk_admin = $tusk_admin || $script_user;
 
	$sql = "select status from hsdb4.user where user_id = '$tusk_admin'";

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
	            print "\nYou selected $tusk_admin. Are you sure? (y/n): ";
	            $confirmation = lc(<>);
	            chomp $confirmation;
	        }
	    } while $confirmation ne 'y' && $confirmation ne 'n';
	}
    } while $@ || $confirmation ne 'y';
}

sub insertSchool {
    my ($school_name, $school_data) = @_;
    my $new_school = TUSK::Core::School->new();
    $new_school->setDatabaseUserToken('ContentManager');
    $new_school->setFieldValues({school_display => $school_data->{DisplayName}, school_name => $school_name, school_db => 'hsdb45_' . $school_data->{ShortName} . '_admin'});
    $new_school->save({user => $script_user});
    print "Created school ($school_data->{DisplayName}) with id of " . $new_school->getPrimaryKeyID() . "\n";
    return $new_school;
}


sub insertForumCategory {
    my $new_school = shift;
    my $pkey = $new_school->getPrimaryKeyID();
    my $school_name = $new_school->getSchoolName();
    my $sql = "insert into mwforum.categories (title, pos, categorykey) values ('$school_name', 0, '0-$pkey-0')";

    eval {
	$retval = $dbh->do($sql);
    };

    if ($@) {
	$error_string .= "Failure: $@ - query failed: $sql\n";
    } else {
	print "Success: Created forum category with id of " . $dbh->{'mysql_insertid'} . "\n";
    }
}


sub insertSchoolEnum {
    my $new_school = shift;
    my @modify_type_fields = ({table => 'hsdb4.content', field => 'school'},
			      {table => 'hsdb4.content_history', field => 'school'}, 
			      {table => 'hsdb4.ppt_upload_status', field => 'school'}, 
			      {table => 'hsdb4.user', field => 'affiliation'}, 
			      {table => 'hsdb4.xml_cache', field => 'school'}, 
			      {table => 'tusk.full_text_search_content', field => 'school'}, 
			      );
    my $sth;
    foreach (@modify_type_fields) {
	$sth = $dbh->prepare("describe $_->{table} $_->{field}");

	eval {
	    $sth->execute();
	};
	die "Failure: $@ - failed to retrieve type of $_->{field}" if ($@);

	my $field_description = $sth->fetchrow_hashref();
	my $field_type = $field_description->{Type};
	# add new school name to end of list of names
	my $school_name = $new_school->getSchoolName();

	unless ($field_type =~ /$school_name/) {
	    $field_type =~ s/((set|enum)\('.*')\)/$1,'$school_name'\)/;
	    $sql = "alter table $_->{table} modify $_->{field} $field_type";

	    eval {
	    	$retval = $dbh->do($sql);
	    };

	    if ($@) {
	    	$error_string .= "Failure: $@ - query failed: $sql\n";
	    } else {
	    	print "Success: Updated " . $_->{table} . " table's " . $_->{field} . " field's type.\n";
	    }
        }
	else {
	    print "Warning: School Name ($school_name) already found in $_->{table} $_->{field}\n";
	}
    }

    $sth->finish();
}

## Avoid hardcoded paths if possible search install tree for sql template
sub findSchoolTempl {
        my $templ_file = 'create_school_tables.sql';
        my $server_root = $TUSK::Constants::ServerRoot || '/usr/local/tusk/current';
        my $search_root = "$server_root/install";
        my $done = 0;
        find({
                wanted => sub {
                        return if($done);
                        if( $_ eq $templ_file ) {
                                $File::Find::prune = 1; # prevent subdirs
                                $templ_file = $File::Find::name;
                                $done = 1;
                                return;
                        }

                }
        }, $search_root);
        return($templ_file);
}

sub createSchoolDatabase {
    my $new_school = shift;
    my $school_db = $new_school->getSchoolDb();
    my $sql = undef;
    my $file = findSchoolTempl();
    open( my $fh, '<', $file ) or die "Missing $file\n";
    while (<$fh>) {
        ### skip comment and and blank lines
	next if (/(^--|^$)/);
	chomp;
        ### concatenate sql until we reach a semi-colon, at that point, sql is complete
	unless (/\;/) {
	   $sql .= $_;
	   next;
        }
		     
        $sql =~ s/##DB_NAME##/$school_db/g; 
	$sql =~ s/##CHILD_USER_ID##/$tusk_admin/g; 
        $sql =~ s/##DEFAULT_USER##/$TUSK::Constants::DatabaseUsers{ContentManager}->{readusername}/g; 
        $sql =~ s/##CONTENT_USER##/$TUSK::Constants::DatabaseUsers{ContentManager}->{writeusername}/g; 
        $sql =~ s/##EVAL_ADMIN##/$TUSK::Constants::DatabaseUsers{ContentManager}->{writeusername}/g; 

	eval {
	    $retval = $dbh->do($sql);
	};

	if ($@) {
	    if ($sql =~ /(^create database|^use)/) {
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
    close $fh;

    print "SUCCESS:: Created database: $school_db\n";

    print "Total Errors:\n\n$error_string\n" if $error_string; 
}

sub insert_course_metadata_display {
    my $new_school = shift;
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

EOM
}

sub print_instructions {

    print <<EOM;

    This script will add a new school to TUSK.
    
    It will prompt user for following info:
	
	Username and password of account with global mysql
	'GRANT' permissions. Without this, script cannot
	add permissions for school's new database tables.

	School Admin -- initial course administrator. additional administrators can be added later, if desired.

    This script creates a new school, or schools, based upon data in tusk.conf. 
    For instructions on how to appropriately configure tusk.conf for a new school, please refer to the 
    installation documentation.


EOM
}

