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


package TUSK::Custom::TuftsAuth;

use strict;
use HSDB4::DateTime;
use HSDB4::Constants;
use TUSK::Constants;
use POSIX qw /strftime/;


sub determineGroup {
	# The user comes from the login function that calls this
	my $user = shift;
	my $schoolYear = shift;

	my $date = $schoolYear;
	if($date =~ /\d\d/) {
		# Here we come Y2100 bugs :)
		if($date < 75) {$date = "20$date";} else {$date = "19$date";}
	} elsif ($date eq '1ST') {
		$date = strftime("%Y", localtime(time)) + 4;
	} elsif ($date eq '2ND') {
		$date = strftime("%Y", localtime(time)) + 3;
	} elsif ($date eq '3RD') {
		$date = strftime("%Y", localtime(time)) + 2;
	} elsif ($date eq '4TH') {
		$date = strftime("%Y", localtime(time)) + 1;
	} else {
		$date = '';
	}

        my $sendUserEmail = 0;

	my @userGroupLabels;
	if (${$user}->field_value("affiliation") eq "Veterinary") {
		my $tempGroup = simpleUserGroup($date, ${$user}->field_value("affiliation"));
		if($tempGroup) { push @userGroupLabels, $tempGroup; }
	} elsif (${$user}->field_value("affiliation") eq 'Dental') {
		my $tempGroup = simpleUserGroup($date, ${$user}->field_value("affiliation"));
		if($tempGroup) { push @userGroupLabels, $tempGroup; }
	} elsif (${$user}->field_value("affiliation") eq 'Sackler') {
		my $tempGroup = simpleUserGroup($date, ${$user}->field_value("affiliation"));
		if($tempGroup) { push @userGroupLabels, $tempGroup; }
	} elsif (${$user}->field_value("affiliation") eq 'Nutrition') {
		push @userGroupLabels, "Entering Fall $date";
	} elsif (${$user}->field_value("affiliation") eq 'PHPD') {
		push @userGroupLabels, "PHPD Fall " . HSDB4::DateTime->current_year();
        } elsif (${$user}->field_value("affiliation") eq 'Medical') {
		my $tempGroup = simpleUserGroup($date, ${$user}->field_value("affiliation"));
		if($tempGroup && ${$user}->field_value("affiliation") !~ /Clinical Faculty/) { push @userGroupLabels, $tempGroup; warn("Adding a temp group of $tempGroup"); }
		#push @userGroupLabels, "testing";
	}

	#once we have saved, lets whip out an email if the admins want them
	my $message = "The user may need to be linked to a user group.\n\n";
	my @addedGroups;
	if(${$user}->field_value("affiliation")) {
		#OK, lets see if we can "auto-stuff" this user into a group
		my $schoolCode = HSDB4::Constants::code_by_school( ${$user}->field_value("affiliation") );
		if($schoolCode && scalar(@userGroupLabels)) {
			foreach my $userGroupLabel (@userGroupLabels) {
				my $pw = $TUSK::Constants::DatabaseUsers{ContentManager}->{writepassword};
				my $un = $TUSK::Constants::DatabaseUsers{ContentManager}->{writeusername};
				#Does the User Group already exist?
				my @userGroups = HSDB45::UserGroup->new(_school=>HSDB4::Constants::school_codes($schoolCode))->lookup_conditions("label='$userGroupLabel'");
				if(scalar(@userGroups > 1)) {
					$message .= "There were multiple user groups labeled $userGroupLabel!!!\nI'm putting this user in the first one (". $userGroups[0]->primary_key() . ")!\n";
				}

				my $userGroup;
				if(scalar(@userGroups) == 0) {
					$message.="\nCreating a new User Group ($userGroupLabel)\n\n";
					$userGroup = HSDB45::UserGroup->new(_school=>HSDB4::Constants::school_codes($schoolCode));
					$userGroup->set_field_values( 
						homepage_info => 'Hot Content,Announcements,Evals,Discussion',
						label => $userGroupLabel,
						description => $userGroupLabel,
						sub_group => 'No',
					);
					$userGroup->save($un, $pw);
				} else {
					$message.="\nAdding to existing group\n\n";
					$userGroup = $userGroups[0];
				}
				if($userGroup) {
					my ($returnValue, $message) = $userGroup->add_child_user($un, $pw, ${$user}->primary_key);
					unless($returnValue == 1)	{$message .= "There was an error when adding the user to group $userGroupLabel: $message\n";}
					else				{push @addedGroups, $userGroupLabel;}
				} else {
					$message .= "There was an error getting/creating the user group $userGroupLabel\n";
				}
			}
		}
		$message .= "Affiliation: ". ${$user}->field_value("affiliation") ."\n";
	} else {  
		$message .= "Affiliation: couldn't be set based on ". ${$user}->field_value("affiliation") ."/$schoolYear.\n";
		$sendUserEmail++;
	}
                
	if(scalar(@addedGroups)) {
		foreach my $userGroupLabel (@addedGroups) { $message.="Group: $userGroupLabel\n"; }
	} else {  
		$message .= "Group: couldn't be set based on ". ${$user}->field_value("affiliation") ."/$schoolYear.\n";
		$sendUserEmail++;
	}
                
	return $sendUserEmail, $message;
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

sub decideSchool {
        my $school = shift;

	my $affiliation;
	if ($school =~ /(Veterinary)/i) {
		$affiliation = "Veterinary";
	} elsif ($school =~ /(Dental)/i) {
		$affiliation = "Dental";
	} elsif ($school =~ /(Sackler)/i) {
		$affiliation = "Sackler";
	} elsif ($school =~ /(Nutrition)/i) {
		$affiliation = "Nutrition";
	} elsif ($school =~ /(Engineering)/i) {
		$affiliation = "Engineering";
	} elsif ($school =~ /(Central)/i) {
		$affiliation = "Administration";
	} elsif ($school =~ /School of Medicine - Graduate Studies/i) {
		$affiliation = "PHPD";
        } elsif ($school =~ /(Medical|Medicine|Clinical\ Faculty)/i) {
		$affiliation = "Medical";
	} elsif ($school =~ /(Liberal|Arts)/i) {
		$affiliation = "ArtsSciences";
	} else {
		# Return the default school
		$affiliation = $TUSK::Constants::Default{'School'};
	}
        return $affiliation;
}

sub postUserCreation {
	my $userObject = shift;
	my $year = shift;

	determineSchoolAndGroup($userObject, $year);
}

1;


