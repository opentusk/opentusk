# Base class for TUSK database objects using Moose.
#
# Useful for Baseline and Upgrade, which call out to mysql command.

package TUSK::DB::Object;

# use Modern::Perl;
use strict;
use warnings;
use utf8;

use HSDB4::Constants;
use TUSK::DB::Util qw(mysql_with_file);

use Moose;
# use namespace::autoclean;

has dbh => (
    is => 'ro',
    isa => 'Object',
    default => sub { HSDB4::Constants::def_db_handle() },
);
has verbose => (
    is => 'rw',
    isa => 'Bool',
    default => undef,
);
has db_user => (
    is => 'ro',
    isa => 'Maybe[Str]',
    required => 0,
    default => undef,
);
has db_pw => (
    is => 'ro',
    isa => 'Maybe[Str]',
    required => 0,
    default => undef,
);

sub _call_mysql_with_file {
    my $self = shift;
    my ($file, $db) = @_;
    mysql_with_file({
        file => $file,
        db => $db,
        user => $self->db_user(),
        password => $self->db_pw(),
    });
}

__PACKAGE__->meta->make_immutable;

no Moose;

1;
