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


package Apache::TicketTool;

use strict;
use Apache2::Cookie ();
use Digest::MD5 qw(md5_hex);
use Apache2::URI ();
use Apache::Session::MySQL::NoLock;
use HSDB4::Constants;
use TUSK::Constants;
use HSDB4::SQLRow::User;
use HSDB4::Constants;
use HSDB45::Authentication;

my $ServerName;
if (Apache->can('server')) {
    $ServerName = Apache->server->server_hostname;
}
else {
    $ServerName = 'test';
}

my %DEFAULTS = (
   'TicketExpires'  =>  240,
   'TicketExpiresShort'  => 120,
);

my %CACHE;  # cache objects by their parameters to minimize time-consuming operations

# Set up default parameters by passing in a request object
sub new {
my($class, $r) = @_;
my %self = ();
    foreach (keys %DEFAULTS) {
	# $self{$_} = $r->dir_config($_) || $DEFAULTS{$_};
	$self{$_} = $DEFAULTS{$_};
    }

    # try to return from cache
    my $id = join '', sort values %self;
    return $CACHE{$id} if $CACHE{$id};

    # otherwise create new object
    return $CACHE{$id} = bless \%self, $class;
} 

# TicketTool::authenticate()
# Call as:
# ($result,$explanation) = $ticketTool->authenticate($user,$passwd)
sub authenticate {
    my($self, $un, $pw) = @_;
    my $authen = HSDB45::Authentication->new();
    my ($res,$msg) = $authen->verify($un,$pw);
    return ($res,$msg);
}

# TicketTool::fetch_secret()
# Call as:
# $ticketTool->fetch_secret();
sub fetch_secret {
    my $self = shift;
    $self->{SECRET_KEY} = $TUSK::Constants::CookieSecret unless ($self->{SECRET_KEY});
    return $self->{SECRET_KEY};
}

# invalidate the cached secret
sub invalidate_secret { undef shift->{SECRET_KEY}; }

# TicketTool::make_ticket()
# Call as:
# $cookie = $ticketTool->make_ticket($r);
#
sub make_ticket {
    my($self, $r, $user_name) = @_;
    my $expires = $self->{TicketExpires};
    my $now = time;
    my $secret = $self->fetch_secret() or return undef;
    my $idForCookie;
    unless($TUSK::Constants::CookieUsesUserID) {
    	# Create an apache session object
    	my %session;
    	create_apache_session(undef, \%session);
    	$session{'user'} = $user_name;
    	$idForCookie = $session{_session_id};
    	#undef the hash to force a save and unlock the database
    	if(tied(%session))	{tied(%session)->save();}
    	else		{warn("make_ticket session was not tied... unable to save");}
    	destroy_apache_session(\%session);
    } else {
	$idForCookie = $user_name;
    }

    my $hash = md5_hex($secret .
                 md5_hex(join ':', $secret, $now, $expires, $idForCookie)
               );

    return Apache2::Cookie->new($r,
			       -name => 'Ticket',
			       -path => '/',
			       -value => {
				   'time' => $now,
				   'user' => $idForCookie,
				   'hash' => $hash,
				   'expires' => $expires,
			       });
}

sub make_string_ticket {
    my($self, $user_name) = @_;
    my $expires = $self->{TicketExpiresShort};
    my $now = time;
    my $secret = $self->fetch_secret() or return undef;
    my $hash = md5_hex($secret .
                 md5_hex(join ':', $secret, $now, $expires, $user_name)
               );
    return join '!!',$now,$user_name,$hash,$expires;
}

# TicketTool::verify_ticket()
# Call as:
# ($result,$msg) = $ticketTool->verify_ticket($r)
sub verify_ticket {
    my($self, $r) = @_;
    my $cookieJar = Apache2::Cookie::Jar->new($r);
    my @cookieNames = $cookieJar->cookies();
    unless(scalar(@cookieNames) > 0) {return (0, 'user has no cookies');}
    my $ticketCookie = $cookieJar->cookies('Ticket');
    unless($ticketCookie) {return $self->delete_cookies($cookieJar, 0, 'user has no ticket', $r);}
    my %ticket = $ticketCookie->value();
    unless($ticket{'hash'} && $ticket{'user'} && $ticket{'time'} && $ticket{'expires'}) { return $self->delete_cookies($cookieJar, 0, 'malformed ticket', $r); }
    unless((time - $ticket{'time'})/60 < $ticket{'expires'}) { return $self->delete_cookies($cookieJar, 0, 'ticket has expired', $r); }
    my $secret;
    unless($secret = $self->fetch_secret) { return $self->delete_cookies($cookieJar, 0, "can't retrieve secret", $r); }
    my $newhash = md5_hex($secret .  md5_hex(join ':', $secret, @ticket{qw(time expires user)}));
    unless ($newhash eq $ticket{'hash'}) {
        $self->invalidate_secret;  #maybe it's changed?
        return $self->delete_cookies($cookieJar, 0, 'ticket mismatch', $r);
    }
    my $user = get_user_from_ticket(\%ticket);

    if (!HSDB45::Authorization->valid_account($user)){
        return (0,'invalid user account');
    }
    $r->user($user);
    my $cookie = $self->make_ticket($r, $user);
    $cookie->bake($r);
    return (1, 'ok');
}

sub delete_cookies{
    my ($self, $cookieJar, $result, $msg, $r) = @_;
    $self->remove_cookie('TUSKMasonCookie', $r) if $cookieJar->cookies('TUSKMasonCookie');
    $self->remove_cookie('Ticket', $r) if $cookieJar->cookies('Ticket');
    return ($result, $msg);
}

sub verify_string_ticket {
    my $self = shift;
    my $input_ticket = shift;
    ## are all the elements of the ticket present
    my ($time,$user_name,$hash,$expires) = split('!!',$input_ticket);
    return (0,"02") if (!$time || !$user_name || !$hash || !$expires);
    my $secret;
    return (0,"99") unless $secret = $self->fetch_secret;
    ## check time since this token was made
    my $now = time;
    my $elapsed = sprintf "%1.0f", ($now - $time)/60;
    ## has this ticket expired?
    return (0,"03") if ($elapsed > $self->{TicketExpiresShort});
    ## does this ticket match the secret hash?
    my $newhash = md5_hex($secret.md5_hex(join ':', $secret,$time,$expires,$user_name));
    unless ($newhash eq $hash) {
	return (0,"02");
    }
    return (1,"00");
}

#
# Someday, I'll use this to force people to go to the right page when
# their status is screwed up
#
sub check_status {
    my ($self, $r, $userObject) = @_;
    return '' if $userObject->user_id eq $ENV{'HSDB_GUEST_USERNAME'};
    my $status = $userObject->field_value ('profile_status');
    return undef if (!defined($status ));
    return "/tusk/tools/pswdchange" 
        if ($status =~ /ChangePassword/);
    return undef;
}

sub remove_cookie {
        my ($self, $cookieName, $r) = @_;
        my $newCookie = Apache2::Cookie->new($r,
                -name           => $cookieName,
                -value          => '',
                -expires        => '-3H',
                -path           => '/',
        );
        $newCookie->bake($r);
}

sub get_user_from_ticket {
	my $ticketRef = shift;
	# the user field of the ticket actually contains the session id so lets create the session from it.
	my $user;
	unless($TUSK::Constants::CookieUsesUserID) {
		eval {
			my %session;
			create_apache_session(${$ticketRef}{'user'}, \%session);
			unless(tied(%session)) {
				warn("get_user_from_ticket: session was not correctly tied, returning udef for user");
				return undef;
			}
			$user = $session{'user'};
			destroy_apache_session(\%session);
		};
		if($@) {
			warn("get_user_from_ticket: unable to get user: $@\n");
		}
	} else {
		$user = ${$ticketRef}{'user'};
	}
	return $user;
}

sub create_apache_session {
	#
	# If you create a session it is your responsibility to destroy it (i.e. call destroy_apache_session and then undef the variable this returns)
	#

	my $sessionID = shift;
	my $hashRefToTie = shift;
	# Create an apache session object
	eval {
	    my $dbh = HSDB4::Constants::def_db_handle('_session');
	    tie %{$hashRefToTie}, 'Apache::Session::MySQL::NoLock', $sessionID, {
		Handle     => $dbh,
	    };
	};
	if($@) {
		warn("Unable to tie session to Apache::Session::MySQL::NoLock for $sessionID: $@\n");
	}
}

sub destroy_apache_session {
	my $sessionRef = shift;
	if(tied(%{$sessionRef})) {
#		tied(%{$sessionRef})->DESTROY();
		undef %{$sessionRef};
	} else {
		warn("destroy_apache_session: sessionRef was not tied, unable to destroy object\n");
	}
}

1;
__END__







