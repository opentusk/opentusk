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

our @EXPORT_OK = qw(sql_dir
                    sql_file_path
                    mysql_with_file
                    get_db_host
                    get_dsn
                    get_my_cnf
                    sql_prep_list
               );

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

1;
