package Apache::AuthzHSDB;

use strict;
use Apache::Constants qw(:common REDIRECT);
use Apache::Cookie;
use Apache::TicketTool;
use TUSK::Constants;

# Lookup the content page, and see if we're authorized to look at it.

sub handler {
    my $r = shift;

    ## automatically approve if the request came from the server itself
    my $remote_ip = $r->connection->remote_ip();
    if ($TUSK::Constants::PermissableIPs->{$remote_ip}) {
	$r->connection->user("TUSKserver");
	return OK;
    }

    my $cls = $r->dir_config('RowClass');

    my $debug = $r->dir_config("HSDBDebug") || 0;

    $r->log_error("Authz: RowClass is ".sprintf($cls ? $cls : "undef")) if ($debug >= 2);

    unless ($cls) {
	return OK if $r->connection->user ne $ENV{'HSDB_GUEST_USERNAME'};

	# If we have no special RowClass, then we check to see what kind of 
	# access to provide to guests.
	my $access = $r->dir_config('AuthzDefault') || 'Restrictive';
	return OK if $access eq 'Permissive';

	# Restrictive access, so decline guests.
	return FORBIDDEN;
    }

    # Lookup document content.
    eval "require $cls";

    my $doc;

    my $uri = ($r->path_info()) ? $r->path_info() : $r->uri();

    if ($cls =~ /HSDB45/){
	eval {$doc = $cls->lookup_path($uri);};
	if($@) {return NOT_FOUND;}
    }else{
	eval {$doc = $cls->new->lookup_path($uri);};
	if($@) {return NOT_FOUND;}
    }
    
    # Save a header with logging information
    $r->header_out('X-Log-Info', $doc->out_log_item) if $doc;

    my $user_id = get_user_id($r);

    # Check user from connection
    unless ($doc and $doc->is_user_authorized($user_id)) {
	# save URI, and note that access was forbidden.

	$r->log_reason($user_id." auth denied", $r->path_info);

	return FORBIDDEN;
    }

    return OK;
}

sub get_user_id{
    my ($r) = @_;

    my $user_id = $r->connection->user || $ENV{'HSDB_GUEST_USERNAME'};

    ## look on the URL for a token, if the user doesn't exist
    if (!$user_id || $user_id eq $ENV{'HSDB_GUEST_USERNAME'}) {
	my %args = $r->args;
	my $ttool = Apache::TicketTool->new;
	if ($args{token}) {
	    my ($status,$message) = $ttool->verify_string_ticket($args{token});
	    if ($status) {
		my ($time,$user,$hash,$timeout) = split("!!",$args{token});
		$user_id = $user;
		$r->connection->user($user_id);
	    }
	} elsif (my %cookies = Apache::Cookie->new($r)->parse) {
		my($returnValue, $message) = $ttool->verify_ticket($r);
		if($returnValue && $cookies{'Ticket'}) {
			my %ticket = $cookies{'Ticket'}->value;
			$user_id = $ticket{'user'};
		}
	}
    }

    return $user_id;
}


1;
__END__

