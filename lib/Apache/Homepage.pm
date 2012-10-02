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


package Apache::Homepage;

use strict;
use HSDB4::SQLRow::User;
use Apache::TicketTool;
use TUSK::Shibboleth::User;
use Apache2::Const qw(OK REDIRECT);
use Apache2::Request;
use Apache2::RequestRec;
use Apache2::SubRequest;
use TUSK::Mobile::Device;

sub handler{
	my $r = shift;

	my $user = HSDB4::SQLRow::User->new ();

	my $ttool = Apache::TicketTool->new($r);
	my ($res, $msg) = $ttool->verify_ticket($r);

	my $shibUser = -1;
	my $apr = Apache2::Request->new($r);

	if ($res) {
		$shibUser = TUSK::Shibboleth::User->isShibUser($r->user);
		if($shibUser > -1) {
			$user->makeGhost($shibUser);
		} 
		else {
			$user->lookup_key($r->user);
		}
	}
	else {
		## if we have a token on the URL, try to verify with that
		my $token = $apr->param('token');
		if ($token) {
			($res,$msg) = $ttool->verify_string_ticket($token);
			if ($res) {
				my ($time,$user_name,$hash,$expires) = split('!!',$token);
				my $cookie = $ttool->make_ticket($r, $user_name);
				$cookie->bake($r);
				$user->lookup_key($user_name);
			}
		}
	}

	my $params = $r->args() || '';
	if ($params =~ /(.*)/) {   # $params is tainted
		$params = $1;          # $params now untainted
	}

	my $ua = $r->headers_in->get('User-Agent');

	if($user->primary_key){
		unless($r->uri() =~ /^\/bigscreen/){ 
			if(($r->uri() =~ /^\/mobi/ || $r->uri() =~ /^\/smallscreen/) || (!mobileExceptions($ua) && (checkUA($ua) || TUSK::Mobile::Device::isMobileDevice($ua)))){
				$r->internal_redirect("/tusk/mobi/home?$params");
				return OK;
			}
		}
		
		$r->internal_redirect("/tusk/home?$params");
		return OK;
	}
	else{
		unless($r->uri() =~ /^\/bigscreen/){ 
			if(($r->uri() =~ /^\/mobi/ || $r->uri() =~ /^\/smallscreen/) || (!mobileExceptions($ua) && (checkUA($ua) || TUSK::Mobile::Device::isMobileDevice($ua)))){
				$r->internal_redirect("/mobi/login?$params");
				return OK;
			}
		}

		$r->internal_redirect("/tusk/login?$params");
		return OK;
	}

}

sub mobileExceptions {
	my $ua = lc shift;

	# This was put in place to redirect browsers that would normally be mobile
	# to the main site.  The current impetus is the iPad, but there is clearly
	# the potential for a variety of tablets if the market takes off.

	if ( $ua =~ /ipad/ ) { return 1; }
}

sub checkUA{
	my $ua = lc shift;

	# the regex here is primed by a detect i found on the following website:
	# http://www.brainhandles.com/2007/10/15/detecting-mobile-browsers/
	# it is possible that additions/subtractions can be made over time.

	if(   $ua =~ /phone/
	   || $ua =~ /blackberry/
	   || $ua =~ /windows ce/
	   || $ua =~ /opera mini/
	   || $ua =~ /mobi/
	   || $ua =~ /mot-/
	   || $ua =~ /sony/
	   || $ua =~ /palmsource/
	   || $ua =~ /palmos/
	   || $ua =~ /240x320/
	   || $ua =~ /nokia/
	   || $ua =~ /wireless/
	   || $ua =~ /opwv/
	   || $ua =~ /symbian/
	   ){
		return 1;
	}
	return 0;
}


1;

__END__
