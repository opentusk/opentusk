package TUSK::DB::Baseline;

use strict;
use warnings;
use utf8;

use File::Spec;
use Carp;
use Readonly;
use HSDB4::Constants qw(get_school_db);
use TUSK::Constants;
use TUSK::Core::School;
use TUSK::Course::CourseMetadataDisplay;
use TUSK::DB::Util qw(sql_file_path);

use Moose::Util::TypeConstraints;

use Moose;

extends qw(TUSK::DB::Object);

# Restrict database name for now. Makes things easier.
Readonly my $valid_dbname_regex => qr{\A [A-Za-z0-9_]+ \z}xms;
subtype 'DBName',
    as 'Str',
    where { $_ =~ $valid_dbname_regex },
    message { "`$_` is not a valid database name\n" };

has mwforum => (
    is => 'ro',
    isa => 'DBName',
    default => $TUSK::Constants::Databases{mwforum},
);
has fts => (
    is => 'ro',
    isa => 'DBName',
    default => $TUSK::Constants::Databases{fts},
);
has hsdb4 => (
    is => 'ro',
    isa => 'DBName',
    default => $TUSK::Constants::Databases{hsdb4},
);
has tusk => (
    is => 'ro',
    isa => 'DBName',
    default => $TUSK::Constants::Databases{tusk},
);
has create_school => (
    is => 'rw',
    isa => 'Bool',
    default => undef,
);
has school_admin => (
    is => 'rw',
    isa => 'Str',
    default => 'admin',
);
has create_admin => (
    is => 'rw',
    isa => 'Bool',
    default => undef,
);

# Optional params:
#   create_school, school_admin
sub create_baseline {
    my $self = shift;
    my $options_ref = shift;

    my $verbose = $self->verbose();
    my $dbh = $self->dbh();

    my %sql_file_for = (
        $self->mwforum() => 'baseline_mwforum.mysql',
        $self->fts() => 'baseline_fts.mysql',
        $self->hsdb4() => 'baseline_hsdb4.mysql',
        $self->tusk() => 'baseline_tusk.mysql',
    );

    foreach my $db_name (keys %sql_file_for) {
        print "Creating database $db_name ... " if $verbose;
        my $create_db_sql = "create database if not exists $db_name ;";
        $dbh->do($create_db_sql) or confess $dbh->errstr;
        print "done.\n" if $verbose;

        my $sql_file = sql_file_path($sql_file_for{$db_name});
        print "Populating database from `$sql_file` ...\n" if $verbose;
        $self->_call_mysql_with_file($sql_file, $db_name);

        print "Setting baseline version ...\n" if $verbose;
        $dbh->do("use `$db_name` ;") or confess $dbh->errstr;
        my $sth = $dbh->prepare(_init_schema_sql());
        $sth->execute() or confess $sth->errstr;
        print "Done.\n" if $verbose;
    }

    if ($self->create_admin()) {
        my $school_admin = $self->school_admin();
        print "Creating default admin user $school_admin ...\n" if $verbose;
        $self->_create_admin_user();
    }

    if ($self->create_school()) {
        print "Creating hsdb45 admin schools ...\n" if $verbose;
        $self->create_school_baseline();
        print "Done creating hsdb45 admin schools.\n" if $verbose;
    }
}

sub _create_admin_user {
    my $self = shift;
    my $dbh = $self->dbh();
    my $hsdb4_db = $self->hsdb4();
    my $admin_user = $self->school_admin();
    my $verbose = $self->verbose();
    my $sql = <<"END_SQL";
insert ignore into `$hsdb4_db`.user (
  user_id, source, status, password, lastname, firstname, affiliation, uid
)
values (
  ?,
  'internal',
  'Active',
  password('admin'),
  'Trator',
  'Adminis',
  'default',
  0
);
END_SQL
    my $sth = $dbh->prepare($sql);
    my $is_inserted = $sth->execute($admin_user) or confess $sth->errstr;
    if ($is_inserted == 0) {
        print "User $admin_user already exists.\n" if $verbose;
    }
    else {
        print "\n";
        print "==========\n";
        print "IMPORTANT:\n";
        print "User $admin_user created with default password.\n";
        print "Please change $admin_user\'s password immediately.\n";
        print "==========\n\n";
    }
}

sub _init_schema_sql {
    return <<END_SQL;
insert ignore into
schema_change_log (
  id,
  major_release_number,
  minor_release_number,
  point_release_number,
  script_name,
  date_applied
)
values (
  1,
  '01',
  '00',
  '0000',
  'initial install',
  now()
);
END_SQL
}

sub _create_school_database {
    my $self = shift;
    my $options_ref = shift;

    my $school_db = _verify_db_name($options_ref->{school_db});
    my $tusk_admin = $options_ref->{school_admin};
    my $dbh = $self->dbh();
    my $sth;
    my $file = sql_file_path('baseline_hsdb45_admin.mysql');

    $dbh->do("create database if not exists `$school_db` ;") or
        confess $dbh->errstr;
    $dbh->do("use `$school_db` ;") or confess $dbh->errstr;

    $self->_call_mysql_with_file($file, $school_db);

    # set school admin user as default admin
    $sth = $dbh->prepare(
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
            my $perm_sql = "grant $perm on `$school_db`.$tbl "
                . "to '$content_mgr'\@'%';";
            $sth = $dbh->prepare($perm_sql);
            $sth->execute() or confess $sth->errstr;
        }
    }
}

sub _insert_school {
    my $self = shift;
    my $options_ref = shift;

    my $tusk_db = $self->tusk();
    my $school_db = _verify_db_name($options_ref->{school_db});
    my $school_name = $options_ref->{school_name};
    my $verbose = $self->verbose();
    my $dbh = $self->dbh();
    my $sth;

    my $school_id;

    Readonly my $sql => <<"END_SQL";
insert into `$tusk_db`.school (
  school_display, school_name, school_db,
  created_by, created_on, modified_by, modified_on
)
values (?, ?, ?, ?, ?, ?, ?)
END_SQL

    # Check to see if the school already exists in the tusk school
    # table. If so, check the name in the database against the name in
    # tusk.conf and bail if they don't match.
    $sth = $dbh->prepare(
        'select school_id, school_name '
            . "from `$tusk_db`.school where school_db = ?"
    );
    $sth->execute($school_db) or confess $sth->errstr;
    my $db_school_name_ref = $sth->fetchrow_arrayref();
    if (! defined $db_school_name_ref) {
        $sth = $dbh->prepare($sql);
        $sth->execute(
            $TUSK::Constants::Schools{$school_name}->{DisplayName},
            $school_name,
            $school_db,
            $self->school_admin(),
            'now()',
            $self->school_admin(),
            'now()',
        );
        $school_id = $dbh->last_insert_id(undef, undef, undef, undef);
    }
    else {
        $school_id = $db_school_name_ref->[0];
        my $db_school_name = $db_school_name_ref->[1];
        if ($db_school_name ne $school_name) {
            confess "Database school name $db_school_name "
                . "doesn't match tusk.conf school name $school_name";
        }
        if ($verbose) {
            print "School $school_name already exists in $tusk_db.school\n";
        }
    }
    return $school_id;
}

sub _verify_db_name {
    my $db_name = shift;
    if ($db_name !~ $valid_dbname_regex) {
        confess "`$db_name` is not a valid database name\n";
    }
    return $db_name;
}

sub _insert_forum_category {
    my $self = shift;
    my $options_ref = shift;

    my $mwforum_db = $self->mwforum();
    my $tusk_db = $self->tusk();
    my $school_name = $options_ref->{school_name};
    my $school_id = $options_ref->{school_id};
    my $verbose = $self->verbose();
    my $dbh = $self->dbh();
    my $sth;

    # Check to see if the school already exists in the mwforum table.
    # If so, check the school's id and bail if they don't match.
    $sth = $dbh->prepare(
        "select categorykey from `$mwforum_db`.categories "
        . "where title = ? and categorykey like '0-%-0'"
    );
    $sth->execute($school_name) or confess $sth->errstr;
    my $existing_category_ref = $sth->fetchrow_arrayref();
    if (! defined $existing_category_ref) {
        $sth = $dbh->prepare(
            "insert into `$mwforum_db`.categories (title, pos, categorykey) "
            . 'values (?, 0, ?)'
        );
        $sth->execute($school_name, "0-$school_id-0") or confess $sth->errstr;
    }
    else {
        my $mwforum_school_id = $existing_category_ref->[0];
        if ($mwforum_school_id ne "0-$school_id-0") {
            confess "`$mwforum_db`.categories.categorykey $mwforum_school_id "
                . "doesn't match `$tusk_db`.school.school_id $school_id\n";
        }
        if ($verbose) {
            print "School $school_name already exists "
                . "in $mwforum_db.categories\n";
        }
    }
}

sub create_school_baseline {
    my $self = shift;

    my $school_admin_user = $self->school_admin();
    my $tusk_db = $self->tusk();
    my $verbose = $self->verbose();
    my $dbh = $self->dbh();
    my $sth;

    $self->validate_user();

    foreach my $school (keys %TUSK::Constants::Schools) {
        my $db_name = _verify_db_name(get_school_db($school));

        print "Creating database $db_name ... \n" if $verbose;
        $self->_create_school_database({
            school_db => $db_name,
            school_admin => $school_admin_user,
        });

        print "Setting baseline version ...\n" if $verbose;
        $dbh->do("use `$db_name` ;") or confess $dbh->errstr;
        my $sth = $dbh->prepare(_init_schema_sql());
        $sth->execute() or confess $sth->errstr;

        print "Inserting school into $tusk_db ...\n" if $verbose;
        my $school_id = $self->_insert_school({
            school_name => $school,
            school_db => $db_name,
        });
        print "Creating forum category ...\n" if $verbose;
        $self->_insert_forum_category({
            school_id => $school_id,
            school_name => $school,
        });
        print "Adding school enum ...\n" if $verbose;
        $self->_insert_school_enum({
            school_name => $school,
        });
        print "Adding course metadata for school ...\n" if $verbose;
        $self->_insert_course_metadata({
            school_id => $school_id,
        });
        print "Done.\n" if $verbose;
    }
}

sub _insert_school_enum {
    my $self = shift;
    my $options_ref = shift;

    my $tusk_db = $self->tusk();
    my $hsdb4_db = $self->hsdb4();
    my $school_name = $options_ref->{school_name};
    my $verbose = $self->verbose();
    my $dbh = $self->dbh();
    my $sql_safe_school_name = $dbh->quote($school_name);
    my $sth;

    my @modify_type_fields = (
        {table => "$hsdb4_db.content", field => 'school'},
        {table => "$hsdb4_db.content_history", field => 'school'},
        {table => "$hsdb4_db.ppt_upload_status", field => 'school'},
        {table => "$hsdb4_db.user", field => 'affiliation'},
        {table => "$hsdb4_db.xml_cache", field => 'school'},
        {table => "$tusk_db.full_text_search_content", field => 'school'},
    );

    foreach my $field_info_ref (@modify_type_fields) {
        $sth = $dbh->prepare(
            "describe $field_info_ref->{table} $field_info_ref->{field}"
        );

        eval {
            $sth->execute();
        };
        if ($@) {
            die "Failure: $@ - failed to retrieve type of "
                . "$field_info_ref->{field}";
        }

        my $field_description = $sth->fetchrow_hashref();
        my $field_type = $field_description->{Type};

        # add new school name to end of list of names

        if (index($field_type, $sql_safe_school_name) == -1) {
            $field_type =~ s/((set|enum)\('.*')\)/$1,$sql_safe_school_name\)/;
            my $sql = "alter table $field_info_ref->{table} modify "
                . "$field_info_ref->{field} $field_type";

            eval {
                $dbh->do($sql);
            };
            confess "Failure: $@ - query failed: $sql\n" if $@;

            if ($verbose) {
                print "Success: Updated " . $field_info_ref->{table}
                    . " table's " . $field_info_ref->{field}
                    . " field's type.\n";
            }
        }
        elsif ($verbose) {
            print "School Name ($school_name) already found in "
                . "$field_info_ref->{table} $field_info_ref->{field}\n";
        }
    }

    $sth->finish();
}

sub _insert_course_metadata {
    my $self = shift;
    my $options_ref = shift;

    my $mwforum_db = $self->mwforum();
    my $tusk_db = $self->tusk();
    my $school_id = $options_ref->{school_id};
    my $verbose = $self->verbose();
    my $dbh = $self->dbh();
    my $sth;

    # if school_id already exists in course_metadata_display, no need
    # to re-insert
    $sth = $dbh->prepare(
        "select count(*) from `$tusk_db`.course_metadata_display "
        . 'where school_id = ?'
    );
    $sth->execute($school_id) or confess $sth->errstr;
    my $num_display_rows = $sth->fetchrow_arrayref()->[0];
    if ($num_display_rows > 0) {
        print "Course metadata display already already exists.\n" if $verbose;
        return;
    }

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
        $md->save({user => $self->school_admin()});
        $md_objects->{$dat->[0]} = $md;
    }
}

sub validate_user {
    my $self = shift;
    my $dbh = $self->dbh();
    my $sth;

    $sth = $dbh->prepare(q{select substring_index(user(), '@', 1);});
    $sth->execute() or confess $sth->errstr;
    my $user_name = $sth->fetchrow_arrayref()->[0];

    # make sure account from user has GRANT privileges
    my $sql = "select Grant_priv from mysql.user where User = ?";
    $sth = $dbh->prepare($sql);
    $sth->execute($user_name) or confess $sth->errstr;

    my $privileges = $sth->fetchrow_array();

    if ($privileges ne 'Y') {
        confess "User $user_name does not have global GRANT permissions\n";
    }
}

__PACKAGE__->meta->make_immutable;

no Moose;

1;
