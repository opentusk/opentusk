package Apache::HSDBHostsOnly;

use strict;
use Apache::Constants qw(:common);
use Apache::File();
use Apache::Log();
use TUSK::Constants;
use Safe();

my $Safe = Safe->new();
my $filetime = 0;

sub handler {
    my $r = shift;
    my $hostfile;
    my $remote_ip = $r->connection->remote_ip();
    return OK if $TUSK::Constants::PermissableIPs->{$remote_ip};
    $r->log_reason("Access forbidden to client IP: $remote_ip.");
    return FORBIDDEN;
}

1;
