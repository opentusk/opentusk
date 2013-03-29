package TUSK::Apache2::ProxyRemoteAddr;

use strict;
use warnings;

use Apache2::Connection ();
use Apache2::RequestRec ();
use Apache2::Const -compile => qw( DECLINED );
use APR::Table ();

sub handler {
    my $r = shift;
    # unset the X-Forwarded header and set the connection remote_ip
    if ( defined $r->headers_in->{'X-Forwarded-For'} ) {
        $r->connection->remote_ip( $r->headers_in->{'X-Forwarded-For'} );
        $r->headers_in->unset('X-Forwarded-For');
    }

    return Apache2::Const::DECLINED;
}

1;

=head1 NAME

Apache2::Connection::XForwardedFor - Sets the connection remote_ip to X-Forwarded-For header

=head1 SYNOPSIS

 # in tusk_base.conf
 PerlPostReadRequestHandler TUSK::Apache2::ProxyRemoteAddr;


=head1 DESCRIPTION


=head1 SEE ALSO

L<Apache2::Connection>
L<Apache2::Connection::XForwardedFor>

=head1 CREDITS

This module is mostly taken from Fred Moyer, E<lt>fred@redhotpenguin.comE<gt> excellent L<Apache2::Connection::XForwardedFor> module.

=cut
