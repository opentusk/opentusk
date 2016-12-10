package Apache::TicketMaster::CAS;

use strict;
use Apache2::Const qw(:common REDIRECT);
use Apache2::Cookie;
use Apache2::Request();
use Apache::TicketTool;
use Apache::TicketMaster;
use TUSK::Application::Email;
use TUSK::Constants;
use TUSK::Core::Logger;
use URI::Escape;


my $casClient;
if($TUSK::Constants::CAS{'Enabled'}) {
	require AuthCAS;
	$casClient = new AuthCAS( casUrl => $TUSK::Constants::CAS{'baseURL'}, drift => $TUSK::Constants::CAS{'drift'} );
}
my $landingPageURL = 'https://'. $TUSK::Constants::Domain;
my $loginURL = $landingPageURL .'/loginCAS';

sub isCASEnabled {
	if($TUSK::Constants::CAS{'Enabled'})	{ return 1; }
	else					{ return 0; }
}

sub getLoginUrl {
	return $casClient->getServerLoginURL($loginURL);
}

sub getLogoutURL {
	return $casClient->getServerLogoutURL($landingPageURL);
}

# There should already be a cookie named "request_uri" that tells us where to head to if the user login is successful

sub handler {
	my $r = shift;
	my $TUSK_Logger = TUSK::Core::Logger->new();

	$TUSK_Logger->logInfo("TicketMasterCAS (TMCAS) being handled", "login");
	my $apr = Apache2::Request->new($r);
 
	# Pull the tiket out of the http post 
	my $passedTicket = $apr->param('ticket');

	# Lets figure out where we want to send the user when we are done
	my $cookieJar = Apache2::Cookie::Jar->new($r);
	my $request_uri = $apr->param('request_uri') || 
		($cookieJar->cookies('request_uri') && $cookieJar->cookies('request_uri')->value) ||
		($r->prev && $r->prev->uri) 
		|| '/home';
	$TUSK_Logger->logInfo("TMCAS user will be redirected to $request_uri", "login");


	unless($TUSK::Constants::CAS{'Enabled'}) {
		$TUSK_Logger->logInfo("TMCAS bombing out (CAS not enabled)", "login");
		return Apache::TicketMaster::go_to_uri($r,$request_uri,undef,"Login Error");
	}


	# If we didn't get a ticet, just go back to the login page with an "Unabe to login message"
	unless($passedTicket) {
		$TUSK_Logger->logInfo("TMCAS there was no ticket parameter in the request.", "login");
		return Apache::TicketMaster::go_to_uri($r,$request_uri,undef,"Unable to login");
	}
	
	$TUSK_Logger->logInfo("TMCAS got ticket of $passedTicket", "login");

	# Validate SAML ticket
	my ($user, %userAttributes) = $casClient->validateSAML({'service' => $loginURL, 'ticket' => $passedTicket});

	unless($user) {
		$TUSK_Logger->logWarn("TMCAS CAS did not return that user was loged in ". &AuthCAS::get_errors(), "login");
		return Apache::TicketMaster::go_to_uri($r,$request_uri,undef,"Unable to validate user from ". $TUSK::Constants::CAS{'displayName'});
	}

	foreach (sort keys %userAttributes) { $TUSK_Logger->logDebug("TMCAS $_: $userAttributes{$_}", "login"); }

	my $ticketTool = Apache::TicketTool->new($r);
	$user = lc($user);
	$user =~ s/\s+//g; 
	my $userObject = HSDB4::SQLRow::User->new->lookup_key($user);
	unless($userObject) {
		unless($TUSK::Constants::CAS{'createUsers'}) {
			# if there was no user object than tell the user they are not allowed to login
			$TUSK_Logger->logError("TMCAS there is no user $user in the database and we are not allowed to create one", "login");
			return Apache::TicketMaster::go_to_uri($r,$request_uri,undef,"You are unable to use $TUSK::Constants::SiteAbbr");
		}

		$TUSK_Logger->logWarn("TMCAS there is no user $user in the database but we are going to create one", "login");
		# We have permission to create a new user
		$userObject = HSDB4::SQLRow::User->new();

		# Set the user ID and source
		$userObject->primary_key( $user );
       		$userObject->field_value('source', 'external');

		my $message = '';
		for my $hsdb4UserAttribute (keys %{ $TUSK::Constants::CAS{'attributes'} }) {
			my $attribType = $TUSK::Constants::CAS{'attributes'}{$hsdb4UserAttribute}{'type'};
			my $attribValue = $TUSK::Constants::CAS{'attributes'}{$hsdb4UserAttribute}{'value'};

			my $startString = "Processing $hsdb4UserAttribute of type $attribType with value $attribValue";
			if($attribType eq 'attribute') {
				$TUSK_Logger->logDebug("$startString expanded value is '". $userAttributes{$attribValue} ."'", "login"); 
				$userObject->field_value($hsdb4UserAttribute => $userAttributes{$attribValue});
				$message.= "\t". $hsdb4UserAttribute .' => '. $userAttributes{$attribValue} ."\n";
			} elsif($attribType eq 'hardcoded') {
				$TUSK_Logger->logDebug("$startString hardcoded value is ". $attribValue, "login");
				$userObject->field_value($hsdb4UserAttribute => $attribValue);
				$message.= "\t". $hsdb4UserAttribute .' => '. $attribValue ."\n";
			} else {
				$TUSK_Logger->logWarn("$startString - $attribType is not a valid attribute type, ignoring", "login");
				$message.= "\tUnused attrivute: ". $attribType ." => ". $attribValue ."\n";
			}
		}

		my $returnValue = $userObject->save();
		if($returnValue && $TUSK::Constants::CAS{'sendEmailOnUserCreation'}) {
			my $mail = TUSK::Application::Email->new({
				to_addr => $TUSK::Constants::CAS{'sendEmailOnUserCreation'},
				from_addr => $TUSK::Constants::AdminEmail,
				subject => "New CAS User Signon: ".$userObject->primary_key,
				body => "A new user was created via the CAS signon process.\nPlease add them to the approprate groups.\n". $message,
			});
			my $response = $mail->send();
			unless($response) {
				$TUSK_Logger->logError("Failed to send email: ". $mail->getError(), "login");
			}
		}
	}

	my $ticket = $ticketTool->make_ticket($r, $user);
	unless ($ticket) {
		$TUSK_Logger->logError("TMCAS Couldn't make ticket -- missing secret?", "login");
		return SERVER_ERROR;
	}

	# Indicate that the user logged in with CAS
	$userObject->field_value('cas_login', 1);
	$userObject->save();

	Apache::TicketMaster::logLogin($userObject);
	my $dest = $ticketTool->check_status($r, $userObject);
	if ($dest) {
		$TUSK_Logger->logInfo("TMCAS redirecting $user to $dest", "login");
		return Apache::TicketMaster::go_to_uri($r, $dest, $ticket);
	} else {
		$request_uri = Apache::TicketMaster::setLoginMessage($userObject,$request_uri);
		$TUSK_Logger->logInfo("TMCAS redirecting $user to requested $request_uri", "login");
		return Apache::TicketMaster::go_to_uri($r, $request_uri, $ticket);
	}
}

1;
__END__


