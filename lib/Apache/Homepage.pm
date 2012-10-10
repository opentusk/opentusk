package Apache::Homepage;

use strict;
use HSDB4::SQLRow::User;
use Apache::TicketTool;
use Apache::Cookie;
use TUSK::ShibbolethUser;
use Apache::Constants qw(OK REDIRECT);
use Apache::Request;
use TUSK::Mobile::Device;

sub handler{
	my $r = shift;

	my $user = HSDB4::SQLRow::User->new ();

	my $ttool = Apache::TicketTool->new($r);
	my ($res, $msg) = $ttool->verify_ticket($r);

	my $shibUser = -1;
	my $apr = Apache::Request->new($r);

	if ($res) {
		$shibUser = TUSK::ShibbolethUser->isShibUser($r->connection->user);
		if($shibUser > -1) {
			$user->makeGhost($shibUser);
		} 
		else {
			$user->lookup_key($r->connection->user);
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
				$cookie->bake;
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
			if(($r->uri() =~ /^\/mobi/ || $r->uri() =~ /^\/smallscreen/) || (($ua && checkUA($ua)) || TUSK::Mobile::Device::isMobileDevice($ua))){
				$r->internal_redirect("/tusk/mobi/home?$params");
				return OK;
			}
		}
		
		$r->internal_redirect("/tusk/home?$params");
		return OK;
	}
	else{
		unless($r->uri() =~ /^\/bigscreen/){ 
			if(($r->uri() =~ /^\/mobi/ || $r->uri() =~ /^\/smallscreen/) || (($ua && checkUA($ua)) || TUSK::Mobile::Device::isMobileDevice($ua))){
				$r->internal_redirect("/mobi/login?$params");
				return OK;
			}
		}

		$r->internal_redirect("/tusk/login?$params");
		return OK;
	}

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
