#!/usr/local/bin/perl

use strict;
use HSDB4::SQLRow::User;
use MySQL::Password;

HSDB4::Constants::set_user_pw (get_user_pw);

my @users = HSDB4::SQLRow::User->new()->lookup_all();
my $i =1;

foreach my $user (@users) {

	$user->set_field_values("uid" => $i) ;
	$user->save();
	$i++;
}
print "Total # of User table rows modified is $i";

