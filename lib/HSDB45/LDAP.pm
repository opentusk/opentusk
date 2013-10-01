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


package HSDB45::LDAP;

use strict;
use Net::LDAPS;
use TUSK::Constants;
use TUSK::Configuration::Password;

sub new {
    #
    # creates a new class
    #
    my $class = shift;
    $class = ref $class || $class;
    my $self = {_server => $TUSK::Constants::LDAP{SERVER},
		_dn => $TUSK::Constants::LDAP{DN},
		_password => TUSK::Configuration::Password::decrypt($TUSK::Constants::LDAP{PASSWORD}),
    };
    return bless $self, $class;
}

#
# sub binds to the ldap server specified in constants with the user and pass in constants
#
sub bind {
    my $self = shift;
    my $server = shift;
    my $dn = shift;
    my $pw = shift;
    my $ld = Net::LDAPS->new($server);
    warn "LDAP ERROR: Error establishing connection with $server : $@" unless $ld;
    return (0,"Error establishing connection with $server") unless $ld;
    my $msg = $ld->bind($dn, password => $pw);
    if ($msg->code()) {
	    ## the server returned some error, process the reason
	    $ld->unbind;
	    $ld->{net_ldap_socket}->close if ($ld->{net_ldap_socket});
	    warn "LDAP BIND CONNECTION ERROR: ".$msg->error();
	    return (0,$msg->error());
    }
    return ($ld,"Successfully bound to LDAP server.");
}

sub search {
    my $self = shift;
    my $ld = shift;
    return $ld->search(@_);
}

##
## this sub takes a user_id and looks up one entry, it then sets values in the object
##
sub lookup {
    my $self = shift;
    my $filter = shift;
    my ($ld,$msg) = $self->bind($self->bind_params);
    return (0,$msg) unless ($ld);

    my $res = $self->search($ld,base => 'dc=tufts, dc=edu',scope => 'sub',filter => $filter);

    if ($res->code()) {
	    $ld->unbind;
	    $ld->{net_ldap_socket}->close if ($ld->{net_ldap_socket});
	    warn "LDAP Result ERROR : ".$res->error();
	    return(0,$res->error());
    }
    $self->entry($res->entry(0));
    $ld->unbind;
    $ld->{net_ldap_socket}->close if ($ld->{net_ldap_socket});
    return ($res,"Success");
}

sub lookup_user_id {
    my $self = shift;
    my $user_id = shift;
    my ($ldap,$msg) = $self->lookup("(uid=$user_id)");
    return (0,"Error in performing lookup") if (!$ldap);
    return (0,"invalid account $user_id (".$ldap->count." ldap entries)") if ($ldap->count != 1);
    return (1,"Found user");
}

sub bind_user {
    my $self = shift;
    my $user_id = shift;
    my $pw = shift;
    my ($res,$msg) = $self->lookup_user_id($user_id);
    return (0,$msg) unless ($res);
    my $ld;
    ($ld,$msg) = $self->bind($self->server,$self->user_dn,$pw);
    return (0,$msg) unless ($ld);
    $ld->unbind;
    $ld->{net_ldap_socket}->close if ($ld->{net_ldap_socket});
    return (1,"User can bind");
}

sub lookup_lastname {
    my $self = shift;
    my $lastname = shift;
    my ($res,$msg) = $self->lookup("(sn=$lastname)");
    return ($res,$msg);
}

#
# returns an array filled with the values for the specific attribute
#
sub attr_values {
    my $self = shift;
    my $attr = shift;
    my $entry = $self->entry;
    return $self->entry->get_value($attr);
}

#
# returns an array with the default bind parameters
#
sub default_bind_params {
    return ($TUSK::Constants::LDAP{SERVER},$TUSK::Constants::LDAP{DN},TUSK::Configuration::Password::decrypt($TUSK::Constants::LDAP{PASSWORD}));
}

#
# Input methods, gets (and sets) values in the object
#

#
# takes an array of server, dn, and password to be used for binding, returns the same array, or default if not set
#
sub bind_params {
    my $self = shift;
    my ($server,$dn,$password) = @_;
    if ($server) {
	$self->server($server);
    }
    if ($dn) {
	$self->{_dn} = $dn;
    }
    if ($password) {
	$self->{_password} = $password;
    }
    return ($self->{_server},$self->{_dn},$self->{_password});
}

sub server {
    my $self = shift;
    my $server = shift;
    if ($server) {
	$self->{_server} = $server;
    }
    return $self->{_server};
}

#
# takes an LDAP entry, sets the object entry as well as all other object variables, returns existing LDAP entry
#
sub entry {
    my $self = shift;
    my $entry = shift;
    if ($entry) {
	## clear out any previous entry
	$self->clear_entry;
	## now repopulate the object with a new entry
	$self->{_entry} = $entry;
	$self->user_dn($entry->dn);
	$self->affiliation(($entry->get_value("edupersonprimaryaffiliation"))[0]);
	$self->email(($entry->get_value("mail"))[0]);
	$self->displayname(($entry->get_value("displayname"))[0]);
	$self->firstname(($entry->get_value("givenname"))[0]);
	$self->lastname(($entry->get_value("sn"))[0]);
	$self->school_info(($entry->get_value("o"))[0]);
	$self->private(($entry->get_value("tuftsedupersonunpublished"))[0]);
	$self->uid(($entry->get_value("uid"))[0]);
	$self->school_year(($entry->get_value("tuftsEduClassYear"))[0]);
	$self->title(($entry->get_value("tuftsEduClinicalTitle"))[0]);
	$self->title(($entry->get_value("tuftsEduEmployeeTitle"))[0]);
    }
    return $self->{_entry};
}

sub clear_entry {
    my $self = shift;
    $self->{_entry} = "";
    $self->{_user_dn} = "";
    $self->{_uid} = "";
    $self->{_affiliation} = "";
    $self->{_email} = "";
    $self->{_displayname} = "";
    $self->{_school_info} = "";
    $self->{_private_entry} = "";
    $self->{_school_year} = "";
    $self->{_title} = "";
}

sub user_dn {
    my $self = shift;
    my $user_dn = shift;
    if ($user_dn) {
	$self->{_user_dn} = $user_dn;
    }
    return $self->{_user_dn};
}

sub uid {
    my $self = shift;
    my $uid = shift;
    if ($uid) {
	$self->{_uid} = $uid;
    }
    return $self->{_uid};
}

sub affiliation {
    my $self = shift;
    my $affiliation = shift;
    if ($affiliation) {
	$self->{_affiliation} = $affiliation;
    }
    return $self->{_affiliation};
}

sub other_affiliation {
    my $self = shift;
    my $entry = $self->entry;
    my @other_affs = $entry->get_value("edupersonaffiliation");
    return @other_affs;
}

sub valid_affiliation {
    my $self = shift;
    return 1 if ($self->affiliation);
    return 1 if ($self->other_affiliation);
}

sub email {
    my $self = shift;
    my $email = shift;
    if ($email) {
	$self->{_email} = $email;
    }
    return $self->{_email};
}

sub displayname {
    my $self = shift;
    my $name = shift;
    if ($name) {
	$self->{_displayname} = $name;
    }
    return $self->{_displayname};
}

sub firstname {
    my $self = shift;
    my $name = shift;
    if ($name) {
	$self->{_firstname} = $name;
    }
    return $self->{_firstname};
}

sub lastname {
    my $self = shift;
    my $name = shift;
    if ($name) {
	$self->{_lastname} = $name;
    }
    return $self->{_lastname};
}

sub school_info {
    my $self = shift;
    my $school_info = shift;
    if ($school_info) {
	$self->{_school_info} = $school_info;
    }
    return $self->{_school_info};
}

sub private {
    my $self = shift;
    my $private_entry = shift;
    if ($private_entry) {
	$self->{_private_entry} = $private_entry;
    }
    return $self->{_private_entry};
}

sub school_year {
    my $self = shift;
    my $school_year = shift;
    if ($school_year) {
	$self->{_school_year} = $school_year;
    }
    return $self->{_school_year};
}

sub title {
    my $self = shift;
    my $title = shift;
    if ($title) {
	$self->{_title} = $title;
    }
    return $self->{_title};
}

1;












