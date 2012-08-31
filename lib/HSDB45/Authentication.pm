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


package HSDB45::Authentication;

use strict;
# list of modules to use for authentication must be included here
use HSDB45::Authentication::MySQL;
use TUSK::Constants;

my @authen_modules;
if ($TUSK::Constants::LDAP{UseLDAP}) {
    my $ldap_module = 'HSDB45::Authentication::LDAP';

    eval "use $ldap_module;";
    if ($@) {
	die "\n\nERROR: Missing LDAP module(s). Set UseLDAP = 0 in tusk.conf if LDAP is not being used for authentication.\n\n";
    }
    @authen_modules = ($ldap_module,"HSDB45::Authentication::MySQL");
}
else {
	@authen_modules = ("HSDB45::Authentication::MySQL");
}
#
# Sub takes a user object and a password string
#
sub new {
    #
    # creates a new class
    #
    my $class = shift;
    $class = ref $class || $class;
    my $self = {};
    return bless $self, $class;
}

#
# sub takes a user object and password string and attempts to verify password in all 
# classes listed in the authen_modules array
#
sub verify_password {
    my $self = shift;
    my $user = shift;
    my $pw = shift;
    return 0 unless ($user->primary_key && $pw);
    foreach (@authen_modules) {
	return 1 if ($_->verify_password($user,$pw));
    }
}

#
# sub takes a user_id and password and returns a boolean and message
# the wrapped classes do much more than with verify_password
#
sub verify {
    my $self = shift;
    my $user_id = shift;
    my $pw = shift;
    my ($res,$msg);
    foreach (@authen_modules) {
	($res,$msg) = $_->verify($user_id,$pw);
	return ($res,$msg) if ($res);
    }
    return ($res,$msg);
}

1;










