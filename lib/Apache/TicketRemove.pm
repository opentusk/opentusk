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


package Apache::TicketRemove;

use strict;
use Apache2::Const qw(:common REDIRECT);
use Apache2::Cookie;
use Apache::Session::MySQL::NoLock;
use Apache2::Request;
use Apache::TicketMaster::CAS;
use Apache::TicketMaster::Shib;
use HSDB4::SQLRow::User;
use TUSK::Constants;
use URI::Escape;

#TUSK added plugin
use Forum::MwfPlgAuthen;

sub handler {
    my $r = shift;

    my $apr = Apache2::Request->new($r);

    my $cookieJar = Apache2::Cookie::Jar->new($r);
    my $location = $apr->param('request_uri') || "/";
    if($location =~ /\?/) { $location .= '&'; } else { $location .= '?'; }


    # Shib login adds more cookies with stange names to lets kill those.
    # Also, shib adds a second ticket so lets be sure to kill both of those.
#    if($cookieJar->cookies('Ticket')) {
    foreach my $cookieName ($cookieJar->cookies()) {
	if($cookieName eq 'Ticket') {
		my %ticket = $cookieJar->cookies('Ticket')->value;
		my $user_id = Apache::TicketTool::get_user_from_ticket(\%ticket);
		my $user = HSDB4::SQLRow::User->new->lookup_key($user_id);

		# Let the login page know if the user last logged in with CAS
		if(Apache::TicketMaster::CAS::isCASEnabled() && $user->cas_login()) {
			if($TUSK::Constants::CAS{'removeCASSessionOnLogout'}) {
				$location = Apache::TicketMaster::CAS::getLogoutURL();
			} else {
				$location.= "logout=true";
			}
			$user->field_value('cas_login', 0);
		}
		if(Apache::TicketMaster::Shib::isShibEnabled() && $user->shib_session()) {
			if($TUSK::Constants::Shibboleth{'removeShibSessionOnLogout'}) {
				$location = Apache::TicketMaster::Shib::getSPLogoutURL();
			} else {
				$location.= "logout=shib";
			}
			$user->field_value('shib_session', 0);
		}


		# TUSK added logout
		MwfPlgAuthen::logout($user_id, $r);

		# Destroy Apache Session
		unless($TUSK::Constants::CookieUsesUserID) {
			my %session;
			Apache::TicketTool::create_apache_session($ticket{user}, \%session);
			if(tied(%session))      {tied(%session)->delete;}
			else                    {warn("Apache::TicketRemove session not tied... unable to delete");}
			Apache::TicketTool::destroy_apache_session(\%session);
		}

		$user->update_loggedout_flag(1) if ($user);
		if($TUSK::Authentication::useShibboleth) {
			my $shibUserPrefix = $TUSK::Constants::shibbolethUserID;
                	if($user_id =~ /^$shibUserPrefix/) {
                        	my $shibUserID = TUSK::Shibboleth::User->isShibUser($user_id);
                        	if($shibUserID) {
					my $shibIdPObject = TUSK::Shibboleth::User->new()->lookupKey($shibUserID);
					if($shibIdPObject && $shibIdPObject->getLogoutPage() && ($shibIdPObject->needsRegen() ne 'Y')) {
						my $sslServer = $TUSK::Constants::Domain . ':' . $TUSK::Constants::securePort;
						my $server = $TUSK::Constants::Domain;
						$location = "https://$sslServer/Shibboleth.sso/Logout?";
						if($shibIdPObject->getLogoutPage()) {
							$location.= "return=". uri_escape($shibIdPObject->getLogoutPage(). "?target=http://". $server . "/home");
						}
					}
				}
                        }
                }
	}
    	my $cookie =  Apache2::Cookie->new($r,
	      -name => $cookieName,
	      -path => '/',
	      -expires => '-7d',
	      -value => '',
	);
	$cookie->bake($r);
    }
    # This needs to happen after the call to MwfPlgAuthen::logout($user_id);
    $r->user($ENV{'HSDB_GUEST_USERNAME'});

    $r->headers_out->{Location} = $location;
    return REDIRECT;
}

1;
