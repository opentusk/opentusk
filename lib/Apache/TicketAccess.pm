package Apache::TicketAccess;

use strict;
use Apache::Constants qw(:common);
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

	$r->custom_response(FORBIDDEN, "/forbidden.html");
    } else {
	# Ticket not accepted -- perhaps it's expired, or perhaps
	# there are no cookies.  If the authorization handler returns
	# FORBIDDEN, we're going to need to handle it later.

	$r->warn("Using guest access -- $msg") if ($debug >= 1);
	$r->custom_response(FORBIDDEN, "/guestlogin.html");

	# Set up a guest user.
	$r->connection->user($ENV{'HSDB_GUEST_USERNAME'});
    }
    return OK;
}

1;
__END__
