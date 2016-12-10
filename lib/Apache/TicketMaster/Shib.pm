package Apache::TicketMaster::Shib;

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

# alter table user add column shib_session varchar(80) CHARACTER SET utf8 NOT NULL DEFAULT '0';


sub handler {
	my $r = shift;

	# This module pretty much does squat (so far) because it appears to run BEFORE the shib handler
	# So the environment variables shib provides are not yet set
	# shib/login calls the method below which processes the environment
	return Apache2::Const::OK;
}


sub isShibEnabled {
	if($TUSK::Constants::Shibboleth{'Enabled'})	{ return 1; }
	else						{ return 0; }
}	       

sub getLoginUrl {
	return 'https://'. $TUSK::Constants::Domain .'/shib/login';
}

sub getSPLogoutURL {
	my $logoutURL = 'https://'. $TUSK::Constants::Domain ."/Shibboleth.sso/Logout?return_url=". uri_escape("http://". $TUSK::Constants::Domain ."?logout=shib");
	my $TUSK_Logger = TUSK::Core::Logger->new();
	$TUSK_Logger->logTrace("TMShib returning logout URL: $logoutURL", "login");
	return $logoutURL;
}

sub getIdPLogoutURL {
#	my $parameters = uri_escape($TUSK::Constants::Shibboleth{'IdPLogoutURL'} ."?target=http://". $TUSK::Constants::Domain);
#	return 'https://'. $TUSK::Constants::Domain ."/Shibboleth.sso/Logout?return_url=$parameters";
#	return $TUSK::Constants::Shibboleth{'logoutURL'} .'?return_url=https://'. $TUSK::Constants::Domain .'/Shibboleth.sso/Logout?return=/dologout';
	return $TUSK::Constants::Shibboleth{'IdPLogoutURL'};
}

sub authenticate {
	my $envRef = shift;
	my $r = shift;

	my $TUSK_Logger = TUSK::Core::Logger->new();
		
	$TUSK_Logger->logInfo("TicketMasterShib (TMShib) being handled", "login");
	unless($r) {
		$TUSK_Logger->logInfo("TMShib this is going to be bad: apache request object not passed in", "login");
	}

	my $apr = Apache2::Request->new($r);
		
	# Lets figure out where we want to send the user when we are done
	my $cookieJar = Apache2::Cookie::Jar->new($r);
	my $request_uri = $apr->param('request_uri') ||
		($cookieJar->cookies('request_uri') && $cookieJar->cookies('request_uri')->value) ||
		($r->prev && $r->prev->uri) 
		|| '/home';
	my $target = $apr->param('target');
	if($target) { $request_uri = $target; }
	$TUSK_Logger->logInfo("TMShib user will be redirected to $request_uri", "login");

			
	unless($TUSK::Constants::Shibboleth{'Enabled'}) {
		$TUSK_Logger->logInfo("TMShib bombing out (Shib not enabled)", "login");
		return Apache::TicketMaster::go_to_uri($r,$request_uri,undef,"Login Error");
	}		       
			
	unless(exists($TUSK::Constants::Shibboleth{'attributes'}{'user_id'})) {
		$TUSK_Logger->logInfo("TMShib no user_id field defined in the Shib attribute map", "login");
		return Apache::TicketMaster::go_to_uri($r,$request_uri,undef,"Login Error");
	}

	$TUSK_Logger->logTrace("-------> HERE <--------", "login");
	$TUSK_Logger->logTrace("Going to get user with ". $TUSK::Constants::Shibboleth{'attributes'}{'user_id'}{'type'}, "login");
	my $user;
	if($TUSK::Constants::Shibboleth{'attributes'}{'user_id'}{'type'} eq 'hardcoded') {
		$user = $ENV{ $TUSK::Constants::Shibboleth{'attributes'}{'user_id'}{'value'} };
		$TUSK_Logger->logTrace("In hardcoded with $user", "login");
	} elsif($TUSK::Constants::Shibboleth{'attributes'}{'user_id'}{'type'} eq 'attribute') {
		foreach (sort keys %ENV) {
			$TUSK_Logger->logTrace("$_: $ENV{$_}", "login");
		}
		$user = $ENV{ $TUSK::Constants::Shibboleth{'attributes'}{'user_id'}{'value'} };
		$TUSK_Logger->logTrace("In attribute with $user", "login");
	} else {
		$TUSK_Logger->logWarn("TMShib attribute type on user_id field is not supported", "login");
	}
	
	$TUSK_Logger->logTrace("Here", "login");
	unless($user) {	 
		$TUSK_Logger->logWarn("TMShib Shib did not return that user was logged in", "login");
		return Apache::TicketMaster::go_to_uri($r,$request_uri,undef,"Unable to validate user from ". $TUSK::Constants::Shibboleth{'displayName'});
	}		       

	
	foreach (sort keys %ENV) { $TUSK_Logger->logDebug("TMShib $_: $ENV{$_}", "login"); }

	my $ticketTool = Apache::TicketTool->new($r);
	$user = lc($user);
	$user =~ s/\s+//g;
	my $userObject = HSDB4::SQLRow::User->new->lookup_key($user);
	unless($userObject) {
		unless($TUSK::Constants::Shibboleth{'createUsers'}) {
			# if there was no user object than tell the user they are not allowed to login
			$TUSK_Logger->logError("TMShib there is no user $user in the database and we are not allowed to create one", "login");
			return Apache::TicketMaster::go_to_uri($r,$request_uri,undef,"You are unable to use $TUSK::Constants::SiteAbbr");
		}

		$TUSK_Logger->logWarn("TMShib there is no user $user in the database but we are going to create one", "login");
		# We have permission to create a new user
		$userObject = HSDB4::SQLRow::User->new();

		# Set the user ID and source
		$userObject->primary_key( $user );
		$userObject->field_value('source', 'external');

		my $message = '';
		for my $hsdb4UserAttribute (keys %{ $TUSK::Constants::Shibboleth{'attributes'} }) {
			my $attribType = $TUSK::Constants::Shibboleth{'attributes'}{$hsdb4UserAttribute}{'type'};
			my $attribValue = $TUSK::Constants::Shibboleth{'attributes'}{$hsdb4UserAttribute}{'value'};
			my $param = $TUSK::Constants::Shibboleth{'attributes'}{$hsdb4UserAttribute}{'param'};

			my $startString = "Processing $hsdb4UserAttribute of type $attribType with value $attribValue";
			if($attribType eq 'attribute') {
				$TUSK_Logger->logDebug("TMShib $startString expanded value is '". $ENV{$attribValue} ."'", "login");
				$userObject->field_value($hsdb4UserAttribute => $ENV{$attribValue});
				$message.= "\t". $hsdb4UserAttribute .' => '. $ENV{$attribValue} ."\n";
			} elsif($attribType eq 'hardcoded') {
				$TUSK_Logger->logDebug("TMShib $startString hardcoded value is ". $attribValue, "login");
				$userObject->field_value($hsdb4UserAttribute => $attribValue);
				$message.= "\t". $hsdb4UserAttribute .' => '. $attribValue ."\n";
			} elsif($attribType eq 'codeblock') {
				# get the package name from the variable and use it just incase its not already loaded
				my $packageName = $attribValue;
				$packageName =~ s/::[^:]+$//;
				eval "use $packageName;";
				if($@) {
					$TUSK_Logger->logError("TMShib Unable to load package ($packageName) required for codeblock of shibboleth attribute $hsdb4UserAttribute : $@", "login");
					next;
				}
				my $expandedParam = eval $param;
				my $value = eval { &{\&{$attribValue}}( $expandedParam ); };
				if($@) {
					$TUSK_Logger->logDebug("TMShib $startString threw an error: $@", "login");
					$message.= "\t". $hsdb4UserAttribute .' => ERROR: '. $@ ."\n";
				} else {
					$TUSK_Logger->logDebug("TMShib $startString evaled to $value", "login");
					$userObject->field_value($hsdb4UserAttribute => $value);
					$message.= "\t". $hsdb4UserAttribute .' => '. $value ."\n";
				}
			} else {
				$TUSK_Logger->logWarn("TMShib $startString - $attribType is not a valid attribute type, ignoring", "login");
				$message.= "\tUnused attribute: ". $attribType ." => ". $attribValue ."\n";
			}
		}

		if(exists($TUSK::Constants::Shibboleth{'postUserCreation'})) {
			my $function = $TUSK::Constants::Shibboleth{'postUserCreation'}{'function'};
			my $param = $TUSK::Constants::Shibboleth{'postUserCreation'}{'param'};
			my $expandedParam = eval $param;
			$TUSK_Logger->logInfo("TMShib postUserCreation is set, going to try and call it as $function with $expandedParam", "login");
			my ($email, $additionalMessage) = eval { &{\&{$function}}( \$userObject, $expandedParam ); };
			if($@) {
				$TUSK_Logger->logError("TMShib Unable to call postUserCreation : $@", "login");
				$additionalMessage = "Unable to call postUserCreation:\n$@\n";
			}
			if($additionalMessage) { $message .= "\n$additionalMessage"; }
		}

		my $returnValue = $userObject->save();
		if($returnValue && $TUSK::Constants::Shibboleth{'sendEmailOnUserCreation'}) {
			my $mail = TUSK::Application::Email->new({
				to_addr => $TUSK::Constants::Shibboleth{'sendEmailOnUserCreation'},
				from_addr => $TUSK::Constants::AdminEmail,
				subject => "New Shib User Signon: ".$userObject->primary_key,
				body => "A new user was created via the Shib signon process.\nPlease add them to the approprate groups.\n". $message,
			});
			my $response = $mail->send();
			unless($response) {
				$TUSK_Logger->logError("TMShib Failed to send email: ". $mail->getError(), "login");
			}
		}
	}

	my $ticket = $ticketTool->make_ticket($r, $user);
	unless ($ticket) {
		$TUSK_Logger->logError("TMShib Couldn't make ticket -- missing secret?", "login");
		return SERVER_ERROR;
	}

	# Indicate that the user logged in with Shib
	$userObject->field_value('shib_session', 1);
	$userObject->save();

	Apache::TicketMaster::logLogin($userObject);
	my $dest = $ticketTool->check_status($r, $userObject);
	if ($dest) {
		$TUSK_Logger->logInfo("TMShib redirecting $user to $dest", "login");
		return Apache::TicketMaster::go_to_uri($r, $dest, $ticket);
	} else {
		$request_uri = Apache::TicketMaster::setLoginMessage($userObject,$request_uri);
		$TUSK_Logger->logInfo("TMShib redirecting $user to requested $request_uri", "login");
		return Apache::TicketMaster::go_to_uri($r, $request_uri, $ticket);
	}
}


1;
__END__


