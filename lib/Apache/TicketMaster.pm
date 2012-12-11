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


package Apache::TicketMaster;

use strict;
use Apache2::Const qw(:common REDIRECT);
use Apache::TicketTool ();
use Apache2::Cookie;
use Apache2::Request();
use HSDB4::SQLRow::LogItem;
use HSDB4::DateTime;

# This is the log-in screen that provides authentication cookies.
# There should already be a cookie named "request_uri" that tells
# the login screen where the original request came from.
sub handler {
    my $r = shift;
    my $debug = $r->dir_config("HSDBDebug") || 0;
    $r->log_error("TicketMaster being handled") if ($debug >= 2);
    my $apr = Apache2::Request->new($r);
    my($user, $pass) = ($apr->param('user'),$apr->param('password'));
	my $failedLoginUserCookie = Apache2::Cookie->new ($r,
		-name => 'failed_login_user',
		-value => '' ,
		-expires=> '+3m', 
		-path => '/'
	);

    my $cookieJar = Apache2::Cookie::Jar->new($r);
    my $request_uri = $apr->param('request_uri') || 
	    ($cookieJar->cookies('request_uri') && $cookieJar->cookies('request_uri')->value) ||
	    ($r->prev && $r->prev->uri) 
	    || '/home';

    $r->log_error("TM redirecting to $request_uri") if ($debug >= 2);

    my $ticketTool = Apache::TicketTool->new($r);
    my($result, $msg, $dest,$userObject);
    if ($user || $pass) {
	$user = lc($user);
	$user =~ s/\s+//g; 
	($result, $msg) = $ticketTool->authenticate($user, $pass);
	if ($result) {
		$userObject = HSDB4::SQLRow::User->new->lookup_key($user);
		my $ticket = $ticketTool->make_ticket($r, $user);
		unless ($ticket) {
			$r->log_error("Couldn't make ticket -- missing secret?");
			$failedLoginUserCookie->bake($r);
			return SERVER_ERROR;
		}
		logLogin($userObject);
		$dest = $ticketTool->check_status($r, $userObject);
		if ($dest) {
			$r->log_error("TM redirecting $user to $dest") if ($debug >= 2);
			$failedLoginUserCookie->bake($r);
			return go_to_uri($r, $dest, $ticket);
		} else {
			$request_uri = setLoginMessage($userObject,$request_uri);
			$r->log_error("TM redirecting $user to requested $request_uri") if ($debug >= 2);
			$failedLoginUserCookie->bake($r);
			return go_to_uri($r, $request_uri, $ticket);
		}
	}
	$r->log_error("Bad login for $user: $msg") if ($debug >= 2);
    }
    if (!$user){
	$msg = "Enter a username"
    } else {
	$msg = "Unable to login";
    }
    $r->log_error("TM going to login screen...") if ($debug >= 2);

    $failedLoginUserCookie->value($user);
    $failedLoginUserCookie->bake($r);
    return go_to_uri($r,$request_uri,undef,$msg);
}

sub go_to_uri {
	my($r, $requested_uri, $ticket, $errmsg) = @_;
	my ($reqCookie,$errorCookie);

	if ($errmsg){ # indicates an error state, set cookies and go home
		## 15 seconds is minimum for some browsers, although blackberry mobiles seem to need 3m
		my $expires = ($requested_uri =~ /mobi/)? '+3m' : '+15s';
		$errorCookie = Apache2::Cookie->new ($r,
			-name => 'login_error',
			-value => $errmsg ,
			-expires=>$expires, 
			-path => '/');
		$requested_uri = "/";
	} else {
		$errorCookie = Apache2::Cookie->new ($r,
			-name => 'login_error',
			-value => '' ,
			-expires=>'now',
			-path => '/');
	}


	if ($ticket){ 
		$ticket->bake($r);
	}
	$errorCookie->bake($r);
	$r->headers_out->set("Location",$requested_uri);
	return REDIRECT;
}


sub logLogin {
	my $user_obj = shift;
	my $li = HSDB4::SQLRow::LogItem->new();
	$li->save_loglist( [ $user_obj->user_id,
                         HSDB4::DateTime->new()->out_mysql_timestamp(),
                         'Log-in', undef, undef, undef ] );
	$user_obj->update_previous_login();
}

sub setLoginMessage {
	my $user_obj = shift;
	my $request_uri = shift;
	unless ($user_obj->get_loggedout_flag()){
	    if ($request_uri =~ /^(\/mobi)?\/home/){
		$request_uri .= '?hintmsg=Remember%2C+click+on+LOGOUT+prior+to+closing+the+web+browser%2E';
		}
	}
	$user_obj->update_loggedout_flag(0);
	return $request_uri;
}

1;
__END__

