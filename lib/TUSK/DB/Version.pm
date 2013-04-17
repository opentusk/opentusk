package TUSK::DB::Version;

# use Modern::Perl;
use strict;
use warnings;
use utf8;

use Carp;
use Readonly;
use HSDB4::Constants qw(get_school_db);
use TUSK::Constants;

use Moose;
# use namespace::autoclean;

extends qw(TUSK::DB::Object);

sub tusk_version {
    my $self = shift;
    return $self->_db_version({ db => $TUSK::Constants::Databases{tusk} });
}

sub hsdb4_version {
    my $self = shift;
    return $self->_db_version({ db => $TUSK::Constants::Databases{hsdb4} });
}

sub fts_version {
    my $self = shift;
    return $self->_db_version({ db => $TUSK::Constants::Databases{fts} });
}

sub mwforum_version {
    my $self = shift;
    return $self->_db_version({ db => $TUSK::Constants::Databases{mwforum} });
}

sub hsdb45_admin_version {
    my $self = shift;
    my $dbname = shift;
    return $self->_db_version({ db => $dbname });
}

sub version_hashref {
    my $self = shift;
    return {
        tusk => $self->tusk_version(),
        hsdb4 => $self->hsdb4_version(),
        fts => $self->fts_version(),
        mwforum => $self->mwforum_version(),
        map {
            get_school_db($_) => $self->hsdb45_admin_version(get_school_db($_))
        } keys %TUSK::Constants::Schools,
    };
}

sub version_string_hashref {
    my $self = shift;
    my $version_ref = $self->version_hashref();
    my %version_string = ();
    foreach my $db (keys %{$version_ref}) {
        if (! exists $version_ref->{$db}->{id}) {
            $version_string{$db} = 'unversioned';
        }
        else {
            $version_string{$db} = join(
                '.',
                $version_ref->{$db}->{major_release_number},
                $version_ref->{$db}->{minor_release_number},
                $version_ref->{$db}->{point_release_number},
            );
        }
    }
    return \%version_string;
}

sub _db_version {
    my $self = shift;
    my $options_ref = shift;
    my $dbh = $self->dbh();
    my $dbname = $options_ref->{db};
    my $version_ref = {};
    my $sth;

    Readonly my $sql => <<"END_SQL";
select id, major_release_number, minor_release_number,
       point_release_number, script_name, date_applied
from schema_change_log
order by date_applied desc
limit 1;
END_SQL

    # check for database
    $sth = $dbh->prepare("show databases like ?");
    $sth->execute($dbname) or confess $sth->errstr;
    return if (! defined ($sth->fetchrow_arrayref()));
    $dbh->do("use `$dbname` ;") or confess $dbh->errstr;

    # check for schema_change_log
    $sth = $dbh->prepare(q{show tables like 'schema_change_log'});
    $sth->execute() or confess $sth->errstr;

    if (defined($sth->fetchrow_arrayref())) {
        $sth = $dbh->prepare($sql);
        $sth->execute() or confess $sth->errstr;
        $version_ref = $sth->fetchrow_hashref();
    }
    return $version_ref;
}

__PACKAGE__->meta->make_immutable;

no Moose;

1;
