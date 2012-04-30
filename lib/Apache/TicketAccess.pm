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


package Apache::TicketAccess;

use strict;
use Apache2::Const qw(:common);
use Apache::TicketTool ();

sub handler {
    my $r = shift;

    my $debug = $r->dir_config("HSDBDebug") || 0;

    my $ticketTool = Apache::TicketTool->new($r);
    my ($result, $msg);
    ($result, $msg) = $ticketTool->verify_ticket($r);

    $r->log_error("Ticket returned $msg") if ($debug >= 3);

    if ($result) {
	# The ticket has been accepted.  If there are access problems
	# later, we should tell the user what went wrong.

	$r->custom_response(FORBIDDEN, "/tusk/server/http/error/forbidden");
    } else {
	# Ticket not accepted -- perhaps it's expired, or perhaps
	# there are no cookies.  If the authorization handler returns
	# FORBIDDEN, we're going to need to handle it later.

	$r->warn("Using guest access -- $msg") if ($debug >= 1);
	$r->custom_response(FORBIDDEN, "/tusk/guestlogin");

	# Set up a guest user.
	$r->user($ENV{'HSDB_GUEST_USERNAME'});
    }
    return OK;
}

1;
__END__
