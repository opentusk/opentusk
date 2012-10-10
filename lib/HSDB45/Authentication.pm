package HSDB45::Authentication;

use strict;
# list of modules to use for authentication must be included here
use HSDB45::Authentication::MySQL;
use HSDB45::Authentication::LDAP;

# array must match use statements above and an actual library file in the Authentication tree
my @authen_modules = ("HSDB45::Authentication::LDAP","HSDB45::Authentication::MySQL");

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










