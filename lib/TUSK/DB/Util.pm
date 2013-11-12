package TUSK::DB::Util;

use strict;
use warnings;
use utf8;

use Carp;
use File::Spec;
use IPC::Run3;
use Sys::Hostname;

use TUSK::Constants;

use base qw(Exporter);

our @EXPORT_OK = qw( sql_dir
                     sql_file_path
                     mysql_with_file
                     get_db_host
                     get_dsn
                     get_my_cnf
                     sql_prep_list
                     tusk_tables );

sub sql_prep_list {
    my $count = scalar(@_);
    return join( q{,}, ('?') x $count );
}

sub sql_dir {
    return File::Spec->catdir(
        $TUSK::Constants::ServerRoot,
        'db',
    );
}

sub sql_file_path {
    my $basefile = shift;
    return File::Spec->catfile(
        sql_dir(),
        $basefile,
    );
}

sub mysql_with_file {
    my $opt_ref = shift;
    my $file = $opt_ref->{file};
    my $db = $opt_ref->{db};
    my $user = $opt_ref->{user};
    my $pw = $opt_ref->{password};
    my $host = $TUSK::Constants::Servers{hostname()}->{WriteHost};
    confess "mysql_with_file called without file\n" if (! $file);
    my @sysargs = ('mysql',);
    push @sysargs, '--user=' . $user if defined $user;
    push @sysargs, '--password=' . $pw if defined $pw;
    push @sysargs, '--host=' . $host if ($host ne 'localhost');
    push @sysargs, $db if defined $db;
    run3 \@sysargs, $file;
    if ($? != 0) {
        confess "mysql command failed: $?, $!\n";
    }
}

sub get_db_host {
    my $opt_ref = shift || {};
    my $default = $opt_ref->{default};
    my $hostname = hostname();
    my $dbhost;
    if (exists $TUSK::Constants::Servers{$hostname}) {
        my $dbserver = $TUSK::Constants::Servers{$hostname};
        $dbhost = $dbserver->{'WriteHost'};
    }
    elsif (defined $default) {
        print STDERR (
            "Warning: Database for server $hostname "
                . "not set in tusk.conf. Using $default.\n"
            );
        $dbhost = $default;
    }
    else {
        confess "Database for server $hostname not set in tusk.conf.\n";
    }
    return $dbhost;
}

sub get_my_cnf {
    return "$ENV{HOME}/.my.cnf";
}

sub get_dsn {
    my $opt_ref = shift || {};
    my $verbose = $opt_ref->{verbose};
    my $dbhost = $opt_ref->{host} || get_db_host($opt_ref);
    my $use_my_cnf = $opt_ref->{use_my_cnf};
    my $my_cnf = $opt_ref->{my_cnf} || get_my_cnf();
    my $dsn = "DBI:mysql:mysql:$dbhost";
    if ( $use_my_cnf && ( -r $my_cnf ) ) {
        $dsn .= ";mysql_read_default_file=$my_cnf";
        print "Using MySQL settings in $my_cnf\n" if $verbose;
    }
    return $dsn;
}

sub tusk_tables {
    my ($sql,) = @_;

    my $frag_ref = create_table_sql_fragments($sql);

    my $table_sql = create_table_sql($frag_ref);
    my $history_sql = create_history_sql($frag_ref);

    return ($table_sql, $history_sql);
}

sub create_history_sql {
    my ($args,) = @_;
    my $create_table = $args->{create_table};
    my $table_name = $args->{table_name};
    my $col_spec = $args->{col_spec};
    my $suffix = $args->{suffix};

    my $mod_columns = mod_columns_sql();
    my $history_column =
        q{history_action ENUM('Insert', 'Update', 'Delete') DEFAULT NULL,};

    my $history_col_spec = $col_spec;
    $history_col_spec =~ s{\s+ primary \s+ key}{}xmsi;
    $history_col_spec =~ s{\s+ auto_increment}{}xmsi;

    my $history_sql
        = _history_sql_helper($create_table, $table_name, $history_col_spec,
                              $mod_columns, $history_column, $suffix);
    $history_sql = strip_blank_lines($history_sql);

    return $history_sql;
}

sub _history_sql_helper {
    my ($create_table, $table_name, $history_col_spec, $mod_columns,
        $history_column, $suffix) = @_;
    return <<"END_SQL";
$create_table $table_name\_history (
$table_name\_history_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
$history_col_spec
$mod_columns
$history_column
PRIMARY KEY ($table_name\_history_id),
INDEX $table_name\_id_history_idx ($table_name\_id)
) $suffix;
END_SQL
}

sub create_table_sql {
    my ($args,) = @_;
    my $create_table = $args->{create_table};
    my $table_name = $args->{table_name};
    my $col_spec = $args->{col_spec};
    my $key_spec = $args->{key_spec};
    my $suffix = $args->{suffix};

    my $mod_columns = mod_columns_sql();

    my $table_sql = <<"END_SQL";
$create_table $table_name (
$col_spec
$mod_columns
$key_spec
) $suffix;
END_SQL

    return strip_blank_lines($table_sql);
}

sub mod_columns_sql {
    return <<'END_SQL';
created_by VARCHAR(24) NOT NULL DEFAULT '',
created_on DATETIME DEFAULT NULL,
modified_by VARCHAR(24) NOT NULL DEFAULT '',
modified_on DATETIME DEFAULT NULL,
END_SQL
}

sub create_table_sql_fragments {
    my ($sql,) = @_;

    my ($if_not_exists, $table_name, $col_spec, $key_spec, $suffix)
        = $sql =~ m{
                       \A \s*
                       create \s+ table \s+            # 'create table'
                       (if \s+ not \s+ exists \s+)?    # optional
                       (\w+)                           # table name
                       \s* \( \s*
                       (.*)                            # col spec
                       \s (primary \s+ key .+)         # key spec
                       \) \s*
                       ([^)]*)                         # table suffix
                       ; \s* \z
               }xmsi;

    confess "Cannot parse create table statement:\n$sql\n" if (! $table_name);

    my $create_table = $if_not_exists ? 'CREATE TABLE IF NOT EXISTS'
        :                               'CREATE TABLE';

    return {
        create_table => $create_table,
        table_name => $table_name,
        col_spec => $col_spec,
        key_spec => $key_spec,
        suffix => $suffix,
    };
}

sub strip_blank_lines {
    my ($s,) = @_;
    my @lines = split /\n/, $s;
    @lines = grep { $_ !~ /^\s*$/ } @lines;
    return join("\n", @lines);
}

1;

__END__

=head1 NAME

TUSK::DB::Util - TUSK-specific database utility functions.

=head1 SYNOPSIS

  use TUSK::DB::Util qw(sql_prep_list);

=head1 SUBROUTINES

=over 4

=item * sql_dir

Return the directory containing database scripts. For internal use by
baseline and upgrade scripts. Returns TUSK_PROJECT_ROOT/db, where
TUSK_PROJECT_ROOT is the path specified in
$L<TUSK::Constants>::ServerRoot.

=item * sql_file_path

Take a filename and return that filename appended to L<sql_dir>.

=item * mysql_with_file

Call the mysql command with the specified file. Accepts a hashref of
arguments. The 'file' argument is required. Optional arguments are
'db', 'user', 'password' and passed to the mysql command.

=item * get_db_host

=item * get_dsn

Return database connection string. Arguments are optional and passed
in a hashref. Valid options are:

=over 4

=item *

verbose: defaults to false

=item *

host: defaults to whatever is specified by $L<TUSK::Constants>

=item *

use_my_cnf: defaults to false

=item *

my_cnf: defaults to path returned by L<get_my_cnf>

=item *

default: default database host, if any

=back

Example usage:

  use DBI;
  use TUSK::DB::Util qw(get_dsn);

  my $dsn = get_dsn( { use_my_cnf => 1 } );
  my $dbh = DBI->connect($dsn, ...);

=item * get_my_cnf

Return path of user's .my.cnf file.

=item * sql_prep_list

Takes in a list and returns a prepared statement placeholder of the
appropriate length. For example:

  my @ids = (1, 3, 5, 7, 11);
  my $placeholders = sql_prep_list(@ids);

Use this in a prepared statement:

  $sth = $dbh->prepare(
    "SELECT col FROM tbl WHERE id IN ($placeholders)"
  );
  $sth->execute(@ids);

=item * tusk_tables

Aid table creation by adding columns and a history table.

Takes in a SQL create table statement and outputs two SQL create table
statements: the original table with created and modified columns, and
a TUSK history table for auditing.

Poor man's SQL using regex. A more robust solution is to extend
SQL::Statement with MySQL syntax. Create statement must have a
line that starts with "PRIMARY KEY (...)".

Example expected input:

  CREATE TABLE IF NOT EXISTS competency_source (
    competency_source_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    ... more colspec ...
    PRIMARY KEY (competency_source_id),
    ... more indexes ...
  ) engine=InnoDB default charset=utf8;

=back

=head1 CONFIGURATION AND ENVIRONMENT

TUSK modules depend on properly set constants in the configuration
file loaded by L<TUSK::Constants>. See the documentation for
L<TUSK::Constants> for more detail.

=head1 INCOMPATIBILITIES

This module has no known incompatibilities.

=head1 BUGS AND LIMITATIONS

There are no known bugs in this module. Please report problems to the
TUSK development team (tusk@tufts.edu) Patches are welcome.

=head1 LICENSE AND COPYRIGHT

Copyright 2013 Tufts University

Licensed under the Educational Community License, Version 1.0 (the
"License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at

http://www.opensource.org/licenses/ecl1.php

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
