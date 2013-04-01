#! /usr/bin/env perl

use Modern::Perl;
use FindBin;
use Sys::Hostname;
use TUSK::Constants;
use TUSK::Core::School;
use TUSK::Course::CourseMetadataDisplay;
use File::Find qw(find);
use DBI;
use Getopt::Std;
use Readonly;
use Carp;

### $script_user (set below as unix login) is value for created and
### modified in db (when needed)
my $script_user = getpwuid($<) || "new_school_script";
my ($dbh, $sth, $sql, $retval, $error_string, $tusk_admin, $confirmation);

main();

sub main {
    my $my_cnf = "$ENV{HOME}/.my.cnf";
    my $hostname = hostname;
    my $dbserver = $TUSK::Constants::Servers{$hostname} || 'localhost';
    my $dbhost = $dbserver->{'WriteHost'};
    my $dsn = "DBI:mysql:mysql:$dbhost;mysql_read_default_file=$my_cnf";
    $dbh = DBI->connect($dsn, undef, undef, { RaiseError => 1 });
    confess $DBI::errstr if (! $dbh);

    get_user_options();
    validateUser();
    getTuskAdmin();

    my $school_dbs = getExistingSchoolDatabases();

    ## read config file and try to setup each school. skips if school
    ## database is already there
    foreach my $school (keys %TUSK::Constants::Schools) {
	unless (exists $school_dbs->{
            'hsdb45_'
                . $TUSK::Constants::Schools{$school}{ShortName}
                . '_admin'
            }) {
	    if (my $new_school = insertSchool(
                $school,
                $TUSK::Constants::Schools{$school}
            )) {
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
    $sth = $dbh->prepare(q{select substring_index(user(), '@', 1);});
    $sth->execute() or confess $sth->errstr;
    my $user_name = $sth->fetchrow_array();

    # make sure account from user has GRANT privileges
    $sql = "select Grant_priv from mysql.user where User = ?";
    $sth = $dbh->prepare($sql);
    $sth->execute($user_name) or confess $sth->errstr;

    my $privileges = $sth->fetchrow_array();
    $sth->finish();

    if ($privileges ne 'Y') {
        die "User $user_name does not have global GRANT permissions\n";
    }

    $script_user = $user_name;
}

sub getTuskAdmin {
    do {
	print <<"EOM";
Username of administrator for new school (for $script_user, press <return>,
otherwise, type new id and press <return>):  
EOM

	$tusk_admin = <>;
	chomp $tusk_admin;
	
	$tusk_admin = $tusk_admin || $script_user;
 
	$sql = "select status from hsdb4.user where user_id = '$tusk_admin'";

	$sth = $dbh->prepare($sql);

	eval {
	    $sth->execute;
	};

	if ($@) {
	    print "error checking database. please try again.\n";
	} else {
	    my $status = $sth->fetchrow_array();
	    do {
	        if (!$status) {
	            print "\nNo such user. Please try again.\n";
	            $confirmation = 'n';
	        } elsif ($status ne 'Active') {
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
    $new_school->setFieldValues({
        school_display => $school_data->{DisplayName},
        school_name => $school_name,
        school_db => 'hsdb45_' . $school_data->{ShortName} . '_admin',
    });
    $new_school->save({user => $script_user});
    print "Created school ($school_data->{DisplayName}) with id of "
        . $new_school->getPrimaryKeyID() . "\n";
    return $new_school;
}


sub insertForumCategory {
    my $new_school = shift;
    my $pkey = $new_school->getPrimaryKeyID();
    my $school_name = $new_school->getSchoolName();
    my $sql = "insert into mwforum.categories (title, pos, categorykey) "
        . "values ('$school_name', 0, '0-$pkey-0')";

    eval {
	$retval = $dbh->do($sql);
    };

    if ($@) {
	$error_string .= "Failure: $@ - query failed: $sql\n";
    } else {
	print "Success: Created forum category with id of "
            . $dbh->{'mysql_insertid'} . "\n";
    }
}


sub insertSchoolEnum {
    my $new_school = shift;
    my @modify_type_fields = (
        {table => 'hsdb4.content', field => 'school'},
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

	if ($field_type !~ /$school_name/) {
	    $field_type =~ s/((set|enum)\('.*')\)/$1,'$school_name'\)/;
	    $sql = "alter table $_->{table} modify $_->{field} $field_type";

	    eval {
	    	$retval = $dbh->do($sql);
	    };

	    if ($@) {
	    	$error_string .= "Failure: $@ - query failed: $sql\n";
	    } else {
	    	print "Success: Updated " . $_->{table} . " table's "
                    . $_->{field} . " field's type.\n";
	    }
        }
        else {
	    print "Warning: School Name ($school_name) already "
                . "found in $_->{table} $_->{field}\n";
	}
    }

    $sth->finish();
}

## Avoid hardcoded paths if possible search install tree for sql template
sub findSchoolTempl {
    my $templ_file = 'baseline_hsdb45_admin.mysql';
    my $server_root = $TUSK::Constants::ServerRoot || '/usr/local/tusk/current';
    my $search_root = "$server_root/db";
    my $done = 0;
    find({
        wanted => sub {
            return if($done);
            if ( $_ eq $templ_file ) {
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

    my $sth = $dbh->prepare("create database if not exists `$school_db` ;");
    $sth->execute() or confess $sth->errstr;
    $sth = $dbh->prepare("use `$school_db` ;");
    $sth->execute() or confess $sth->errstr;

    system("mysql $school_db < $file");
    if ( $? == -1 ) {
        confess "mysql command failed: $!";
    }

    # set current user as default admin
    $dbh->prepare(
        'insert ignore into link_user_group_user values (1, ?, now())'
    );
    $sth->execute($tusk_admin) or confess $sth->errstr;

    # grant permissions
    my $content_mgr = $TUSK::Constants::DatabaseUsers{ContentManager}->{writeusername};
    Readonly my $perms_ref => {
        'select' => [
            '*',
        ],
        'insert' => [
            'eval_response',
            'eval_completion',
        ],
        'select, insert, update' => [
            'eval_results_graphics',
            'stylesheet',
            'default_stylesheet',
            'eval_mergedresults_graphics',
        ],
        'select, insert, update, delete' => [
            'hot_content_cache',
            'eval_save_data',
            'link_course_student',
            'user_group',
            'teaching_site',
            'announcement',
            'course',
            'link_user_group_user',
            'link_course_forum',
            'link_user_group_forum',
            'link_course_user',
            'eval',
            'eval_question',
            'link_eval_eval_question',
            'merged_eval_results',
            'link_course_teaching_site',
            'link_course_user_group',
            'link_course_content',
            'link_teaching_site_user',
            'tracking',
            'homepage_category',
            'link_course_objective',
            'class_meeting',
            'homepage_course',
            'time_period',
            'link_user_group_announcement',
            'link_course_announcement',
            'link_class_meeting_content',
        ],
    };

    foreach my $perm (keys %{$perms_ref}) {
        foreach my $tbl (@{$perms_ref->{$perm}}) {
            my $perm_sql = "grant $perm on `$school_db`.`$tbl` "
                . "to '$content_mgr'@%;";
            $dbh->prepare($perm_sql);
            $sth->execute() or confess $sth->errstr;
        }
    }
}

sub insert_course_metadata_display {
    my $new_school = shift;
    my $school_id =  $new_school->getPrimaryKeyID();
    return unless $school_id;
    ### first column is simply sequence for getting parent id
    ### display_title, sort_order, parent (ref to sequence), edit_type,
    ### locked(could be empty)
    my $data = [ 
        ['ref_0','Attendance Policy', 1, undef, 'textarea'],
        ['ref_1', 'Description', 2, undef, 'textarea'],
        ['ref_2', 'Equipment List', 3, undef, 'list', 1],
        ['ref_3', 'Equipment Item', 1, 'ref_2', 'text'],
        ['ref_4', 'Grading And Evaluation', 4, undef, 'list', undef, 1],
        ['ref_5', 'Grading Policy', 1, 'ref_4', 'table', undef, 1],
        ['ref_6', 'Graded Item', undef, 'ref_5', 'table row'],
        [
            'ref_7',
            'Weight',
            1,
            'ref_6',
            'text',
            '(use a % sign if you are giving percentages)',
        ],
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
        [
            'ref_21',
            'On Reserve',
            4,
            'ref_12',
            'radio',
            (
                '<b>On reserve</b> and <b>call number</b> are meant to be '
                . 'used with Textbook and Journal reading list items.'
            ),
        ],
        ['ref_22', 'Call Number', 5, 'ref_12', 'text', '<i>(if on reserve)</i>'],
        [
            'ref_23',
            'URL',
            6,
            'ref_12',
            'text',
            (
                'The value of this field depends on the \'type\' chosen above.'
                . '<br>For URLs (links to other Web pages), insert the Web '
                . 'address<br>here. For Medline articles, enter the article '
                . 'number. Otherwise, leave this field blank.'
            ),
        ],
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

Options:
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

    School Admin -- initial course administrator. 
    Additional administrators can be added later, if desired.

This script creates a new school, or schools, based upon data in
tusk.conf. For instructions on how to appropriately configure
tusk.conf for a new school, please refer to the installation
documentation.
EOM
}

