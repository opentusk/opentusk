package Apache::TicketRemove;

use strict;
use Apache::Constants qw(:common REDIRECT);
use Apache::Cookie;
use Apache::Request ();
use HTML::Embperl;
use Apache::Session::MySQL;
use HSDB4::SQLRow::User;
use Data::Dumper;

#TUSK added plugin
use Forum::MwfPlgAuthen;

sub handler {
    my $r = shift;

    my $apr = Apache::Request->new($r);
    my $udat = HTML::Embperl::Req::SetupSession($apr);

    HTML::Embperl::Req::DeleteSession();  
    HTML::Embperl::Req::CleanupSession();  

    my %cookies = Apache::Cookie->new($r)->parse;
    my $location = $apr->param('request_uri') || "/";

    # Shib login adds more cookies with stange names to lets kill those.
    # Also, shib adds a second ticket so lets be sure to kill both of those.
    foreach my $cookieName (keys %cookies) {
	if($cookieName eq 'Ticket') {
		my %ticket = $cookies{'Ticket'}->value;
		my $user_id = $ticket{'user'};
		my $user = HSDB4::SQLRow::User->new->lookup_key($user_id);

		# TUSK added logout
		MwfPlgAuthen::logout($user_id);

		$user->update_loggedout_flag(1) if ($user);
		my $shibUserPrefix = $TUSK::Constants::shibbolethUserID;
                if($user_id =~ /^$shibUserPrefix/) {
                        my $shibUserID = TUSK::ShibbolethUser->isShibUser($user_id);
                        if($shibUserID) {
				my $shibIdPObject = TUSK::ShibbolethUser->new()->lookupKey($shibUserID);
				if($shibIdPObject && $shibIdPObject->getLogoutPage() && ($shibIdPObject->needsRegen() ne 'Y')) {
                                	$location = "https://". $TUSK::Constants::Domain ."/Shibboleth.sso/shibLogout" . $shibIdPObject->getShibbolethUserID();
				}
                        }
                }
	}
    	my $cookie =  Apache::Cookie->new($r,
	      -name => $cookieName,
	      -path => '/',
	      -expires => '-7d',
	      -value => '',
	);
	$cookie->bake;
    }
    # This needs to happen after the call to MwfPlgAuthen::logout($user_id);
    $r->connection->user($ENV{'HSDB_GUEST_USERNAME'});

    $r->headers_out->{Location} = $location;
    return REDIRECT;
}

1;
