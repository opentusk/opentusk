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


package Apache::AuthzHSDB;

use strict;
use Apache2::Const qw(:common REDIRECT);
use Apache2::Cookie;
use Apache2::Connection;
use Apache::TicketTool;
use TUSK::Constants;

# Lookup the content page, and see if we're authorized to look at it.

sub handler {
    my $r = shift;

    ## automatically approve if the request came from the server itself
    my $remote_ip = $r->connection()->remote_ip();
    if ($TUSK::Constants::PermissableIPs->{$remote_ip}) {
	$r->user("TUSKserver");
	return OK;
    }

    my $cls = $r->dir_config('RowClass');

    my $debug = $r->dir_config("HSDBDebug") || 0;

    $r->log_error("Authz: RowClass is ".sprintf($cls ? $cls : "undef")) if ($debug >= 2);

    unless ($cls) {
	return OK if $r->user ne $ENV{'HSDB_GUEST_USERNAME'};

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
    $r->headers_out->set('X-Log-Info', $doc->out_log_item) if $doc;

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

    my $user_id = $r->user || $ENV{'HSDB_GUEST_USERNAME'};

    ## look on the URL for a token, if the user doesn't exist
    if (!$user_id || $user_id eq $ENV{'HSDB_GUEST_USERNAME'}) {
	my %args = $r->args;
	my $ttool = Apache::TicketTool->new;
        my $cookieJar = Apache2::Cookie::Jar->new($r);
	if ($args{token}) {
	    my ($status,$message) = $ttool->verify_string_ticket($args{token});
	    if ($status) {
		my ($time,$user,$hash,$timeout) = split("!!",$args{token});
		$user_id = $user;
		$r->user($user_id);
	    }
	} elsif (scalar($cookieJar->cookies())) {
		my($returnValue, $message) = $ttool->verify_ticket($r);
		if($returnValue && $cookieJar->cookies('Ticket')) {
			my %ticket = $cookieJar->cookies('Ticket')->value;
			$user_id = Apache::TicketTool::get_user_from_ticket(\%ticket);

		}
	}
    }

    return $user_id;
}


1;
__END__

