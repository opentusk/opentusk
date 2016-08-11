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


package HSDB45::Authentication::LDAP;

use strict;
use HSDB4::DateTime;
use HSDB4::Constants;
use HSDB4::SQLRow::User;
use HSDB45::LDAP;
use Net::LDAPS;
use TUSK::Constants;
use TUSK::Application::Email;
use TUSK::Custom::TuftsAuth;
use POSIX qw /strftime/;


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

# Sub takes a user object and a password string and verifies that it works
sub verify_password {
    my $self = shift;
    my $user = shift;
    my $pw = shift;
    return unless ($user->primary_key);
    my $user_id = $user->primary_key;
    my $ldap = HSDB45::LDAP->new();
    my ($res,$msg) = $ldap->bind_user($user_id,$pw);
    return 1 if ($res);
}

sub verify {
    my ($self,$user_id,$pw) = @_;
    my $user = HSDB4::SQLRow::User->new->lookup_key($user_id);
    my $ldap = HSDB45::LDAP->new();
    my ($res,$msg) = $ldap->bind_user($user_id,$pw);
    ## if the bind didn't work then we must return
    return ($res,$msg) unless ($res);
    ## check for presence of an affiliation
    return (0,"no valid affiliation") unless ($ldap->valid_affiliation);

    ## we have a valid user
    ## if this user is set to look at LDAP for auth, update their info
    if (!$user->source || $user->source eq "external") {
	$user->set_last_name($ldap->attr_values("sn"));
	my $firstname = $ldap->attr_values("givenname");
	$firstname =~ s/ [a-z]$//i;
	$user->set_first_name($firstname);
	$user->field_value("trunk",$ldap->attr_values("tuftsEduTRUNK"));
	$user->set_email($ldap->email);
	$user->field_value("password",my $null);
	$user->field_value("source","external");
	$user->field_value("status","Active");
    }

    if (!$user->primary_key) {
	$user->primary_key($ldap->uid);

	#once we have saved, lets whip out an email if the admins want them
	my $message = "A new user has signed on to " . $TUSK::Constants::SiteName . " for the first time using LDAP and the automatic account set-up.\n";
	$message .= "The user may need to be linked to a user group.\n\n";
                
	my $affiliation = TUSK::Custom::TuftsAuth::decideSchool($ldap->school_info);
	$user->field_value("affiliation",$affiliation);

	my ($sendUserEmail, $additionalMessages) = TUSK::Custom::TuftsAuth::determineGroup(\$user, $ldap->school_year());

	$message .= $additionalMessages;
	$message .= "UTLN: ".$user->primary_key."\n";
	$message .= "Email: ".$user->email."\n"; 
	$message .= "\nPlease change information that is not correct.\n";
	
        # send off an email to TUSK admins
        if($TUSK::Constants::emailWhenNewUserLogsIn && $message) {
                my $mail = TUSK::Application::Email->new({
                        to_addr => $TUSK::Constants::AdminEmail,
                        from_addr => $TUSK::Constants::AdminEmail,
                        subject => "New User Signon: ".$user->primary_key,
                        body => $message,
                });
                $mail->send();
        }

        # send off an email to new User
        if($TUSK::Constants::SendEmailUserWhenNoAffiliationOrGroup && $user->email && $sendUserEmail) {
                my $mail = TUSK::Application::Email->new({
                        to_addr => $user->email,
                        from_addr => $TUSK::Constants::AdminEmail,
                        subject => "$TUSK::Constants::SiteAbbr User Account",
                        body => $TUSK::Constants::EmailUserWhenNoAffiliationOrGroupText,
                });
                $mail->send();
        }

    }

    ## update hsdb4.user password
    $user->save($TUSK::Constants::DatabaseUsers{ContentManager}->{writeusername},$TUSK::Constants::DatabaseUsers{ContentManager}->{writepassword});
    return (undef, "Inactive Account $user_id") unless $user->active;
    return (undef, "Account Expired") if $user->is_expired;
    return (1,"Success");
}

#
# Returns user group in the form "M 2007"
#
sub simpleUserGroup {
        my $date = shift;
	my $affiliation = shift;
        my $schoolCode = HSDB4::Constants::code_by_school( $affiliation );
        if($date =~ /^\d{4}$/ && $schoolCode) {return("$schoolCode $date");}
        return '';
}

1;


