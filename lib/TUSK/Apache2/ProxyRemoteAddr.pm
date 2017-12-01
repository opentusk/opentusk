# Copyright 2012 Tufts University
#
# Licensed under the Educational Community License, Version 1.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.opensource.org/licenses/ecl1.php
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
        $r->connection->can('remote_ip')->( $r->headers_in->{'X-Forwarded-For'} );
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
