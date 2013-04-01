package TUSK::DB::Upgrade;

# use Modern::Perl;
use strict;
use warnings;
use utf8;

use Carp;
use Readonly;
use File::Spec;
use HSDB4::Constants qw(get_school_db);
use TUSK::Constants;
use TUSK::DB::Util qw(sql_file_path);

use Moose;
# use namespace::autoclean;

extends qw(TUSK::DB::Object);

Readonly my $upgrade_re => qr{
    \A                         # beginning of string
        sc \.                  # schema change prefix
        (                      # database name
            tusk
            | hsdb4
            | fts
            | mwforum
            | hsdb45
        ) \.
        (\d{2}) \.             # major version
        (\d{2}) \.             # minor version
        (\d{4}) \.             # point version
        (pl | mysql | sql)     # file extension
    \z                         # end of string
}xms;

sub apply_script {
    my $self = shift;
    my ($script,) = @_;
    my $verbose = $self->verbose();
    my $dbh = $self->dbh();
    my $sth;
    if ($script !~ $upgrade_re) {
        confess "$script is not a valid database upgrade script\n";
    }
    my $script_info = $self->script_info($script);
    my $db = $script_info->{db};
    my $ext = $script_info->{ext};
    my $script_file = sql_file_path($script);
    confess "Can't find file $script_file\n" if (! -e $script_file);
    print "Applying update $script to `$db` ... " if $verbose;
    if ($ext eq 'pl') {
        my @sysargs = ('perl', $script_file);
        system(@sysargs) == 0 or
            confess "Upgrade script $script failed: $?, $!\n";
    }
    else {
        eval {
            $self->_call_mysql_with_file($script_file, $db);
        };
        if ($@) {
            confess "Upgrade script $script failed: $@\n";
        }
    }
    print "done.\n" if $verbose;
    print "Updating `$db`.schema_change_log ... " if $verbose;

    $dbh->do("use `$db` ;") or confess $dbh->errstr;

    my $sql = <<END_SQL;
insert into
schema_change_log (
  major_release_number,
  minor_release_number,
  point_release_number,
  script_name,
  date_applied
)
values (?, ?, ?, ?, now());
END_SQL

    $sth = $dbh->prepare($sql);
    $sth->execute(
        $script_info->{major},
        $script_info->{minor},
        $script_info->{point},
        $script_info->{file},
    ) or confess $sth->errstr;

    print "done.\n" if $verbose;
}

sub script_info {
    my $self = shift;
    my ($script,) = @_;

    my ($db, $major_ver, $minor_ver, $point_ver, $ext)
        = $script =~ $upgrade_re;

    return {
        db => $db,
        major => $major_ver,
        minor => $minor_ver,
        point => $point_ver,
        ext => $ext,
        file => $script,
        path => sql_file_path($script),
    };
}

sub upgrade_scripts_to_run {
    my $self = shift;
    my $scripts_for = $self->upgrade_scripts_for_db();
    my $upgrades_in_ref = $self->upgrades_in_db();
    my %scripts_to_run_for;

    # check each script to see if it's already been run in the database
    foreach my $db_key (keys %{ $scripts_for }) {
        my @all_scripts = @{ $scripts_for->{$db_key} };
        my @list_of_dbs_to_process;

        # hsdb45 admin databases are special
        if ($db_key eq 'hsdb45') {
            # find all the hsdb45_?_admin databases
            @list_of_dbs_to_process = grep {
                $_ =~ m{\A hsdb45_}xms
            } keys %{ $upgrades_in_ref };
        }
        else {
            @list_of_dbs_to_process = ($TUSK::Constants::Databases{$db_key},);
        }

        foreach my $this_db (@list_of_dbs_to_process) {
            my @old_scripts = @{ $upgrades_in_ref->{$this_db} };
            my %set_of_old_scripts;
            @set_of_old_scripts{@old_scripts} = ();
            my @new_scripts = grep {
                ! exists $set_of_old_scripts{$_}
            } @all_scripts;
            $scripts_to_run_for{$this_db} = \@new_scripts;
        }
    }

    return \%scripts_to_run_for;
}

sub upgrades_in_db {
    my $self = shift;
    my $dbh = $self->dbh();
    my $sth;
    my @dbs = (
        $TUSK::Constants::Databases{mwforum},
        $TUSK::Constants::Databases{fts},
        $TUSK::Constants::Databases{hsdb4},
        $TUSK::Constants::Databases{tusk},
        map { get_school_db($_) } keys %TUSK::Constants::Schools,
    );
    my %upgrades_in;
    foreach my $db (@dbs) {
        $sth = $dbh->prepare(
            "select script_name from `$db`.schema_change_log"
            . q{ where script_name <> 'initial install' }
        );
        $sth->execute() or confess $sth->errstr;
        my $versions_ref = $sth->fetchall_arrayref();
        my @versions = map { $_->[0] } @{$versions_ref};
        $upgrades_in{$db} = \@versions;
    }
    return \%upgrades_in;
}

sub _upgrade_files {
    my $db_dir = File::Spec->catdir($TUSK::Constants::ServerRoot, 'db');
    opendir my $dir, $db_dir or confess "Cannot open directory: $!";
    my @files = readdir $dir;
    closedir $dir;
    @files = sort(@files);

    @files = grep { $_ =~ $upgrade_re } @files;
    return \@files;
}

sub _cmp_ext {
    my ($ext1, $ext2) = @_;
    my %precedence_of = (
        pl => 3,
        mysql => 2,
        sql => 1,
    );
    foreach my $ext ($ext1, $ext2) {
        if (! exists $precedence_of{$ext}) {
            confess 'Parameter error: '
                . "Invalid file extension passed to _cmp_ext($ext1, $ext2)\n";
        }
    }
    return ($precedence_of{$ext1} < $precedence_of{$ext2}) ? -1
         : ($precedence_of{$ext1} > $precedence_of{$ext2}) ?  1
         :                                                    0;
}

sub upgrade_scripts_for_db {
    my $self = shift;
    my %files_for = (
        mwforum => [],
        fts => [],
        hsdb4 => [],
        tusk => [],
        hsdb45 => [],
    );
    my %upgrades_for = map { $_ => {} } keys %files_for;
    my $files_ref = _upgrade_files();
    foreach my $f (@{$files_ref}) {
        my $script_info = $self->script_info($f);
        my $db = $script_info->{db};
        my $ext = $script_info->{ext};
        my $file_version = join(
            '.',
            $script_info->{major},
            $script_info->{minor},
            $script_info->{point},
        );

        # upgrade file precedence: *.pl > *.mysql > *.sql
        if (exists $upgrades_for{$db}->{$file_version}) {
            my $old_ext = $upgrades_for{$db}->{$file_version}->[0];
            if (_cmp_ext($ext, $old_ext) == 1) {
                $upgrades_for{$db}->{$file_version} = [$ext, $f];
            }
        }
        else {
            $upgrades_for{$db}->{$file_version} = [$ext, $f];
        }
    }

    foreach my $db (keys %files_for) {
        # get a list of upgrade files
        my @upg_files = map {
            $upgrades_for{$db}->{$_}->[1]
        } keys %{ $upgrades_for{$db} };

        # sort it and assign to db
        @upg_files = sort(@upg_files);
        $files_for{$db} = \@upg_files;
    }

    return \%files_for;
}

__PACKAGE__->meta->make_immutable;

no Moose;

1;
