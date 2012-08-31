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

package TUSK::Configuration;

=head1 NAME

B<TUSK::Configuration> - Class for manipulating entries in table configuration in tusk database

=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 INTERFACE


=head2 GET/SET METHODS

=over 4

=cut

use strict;
use HSDB4::DateTime;
use TUSK::Configuration::Variable;


# Maybe this should be in both places... after all if its not here then how are we going to add it? i.e. you could get an error on an admin page.
# If we set this here then we have to do a restart when we add a new variable... i.e. this would not be dynamic.
# Double check but the variables should get created in the DB not pulled from here.
our %_defaultValues = (
	'institutionAbbr'	=> 'Tufts',
	'institutionName'	=> 'Tufts University',
	'siteAbbr'		=> 'TUSK',
	'siteName'		=> 'Tufts University Sciences Knowledgebase',
	'copyrightOrg'		=> 'config:institutionName',
	'systemWideUserGroupSchool'	=> 'hsdb',
	'systemWideUserGroup'	=> '666',
	'siteAdmins'		=> 'admin',

	'loginImage'		=> 'elephant_home.jpg',
	'loginGradient'		=> 'gradient.jpg',
	'loginLogo'		=> 'logo_sm.gif',
	'loginBottomTopColor'	=> '#99ccff',
	'loginBottomColor'	=> '#336699',

	'degrees'		=> "\nM.D.\nPh.D.\nM.D., M.P.H.\nM.D., Ph.D.\nD.D.S.\nD.M.D.\nD.V.M.\nD.V.M., Ph.D.\nD.V.M., D.Sc.\nR.N.\nM.S.W.\nEd.D.\nM.P.H",
	'suffixes'		=> "\bII\nIII\nIV\nJr.\nSr.",
        'emailWhenNewUserLogsIn'	=> 'yes',
        'emailUserWhenNoAffiliationOrGroup'	=> "Hello and thank you for using the config:siteAbbr system.\nWe were unable to determine the school or group with which you are affiliated.\nPlease reply to this email and let us know your school affiliation and, if you are a student, please include your year of graduation.\n\nconfig:siteAbbr Support\nconfig:supportEmail\nconfig:supportAddress",



	'useLdap'		=> '',


	'errorEmail'		=> '',
	'pageEmail'		=> '',
	'supportEmail'		=> '',
	'feedbackEmail'		=> '',
	'supportPhone'		=> '617-636-2969',
	'supportAddress'	=> "145 Harrison Ave\nBoston, Ma. 02111\nHirsh Health Sciences Library, 5th Floor (Rm. 503)",


	'homepageMessage'	=> 'Tufts University Hirsh Health Sciences Library, with the support of the Medical, Dental, and Veterinary schools, has created a dynamic multimedia knowledge management system (TUSK) to support faculty and students in teaching and learning.  TUSK provides a portal to an integrated body of knowledge and ways to personally organize the vast array of health information through its online curricular materials and related applications.',
	'responsibleUseMessage'	=> 'We refer you to the <a href="http://uit.tufts.edu/?pid=444" target="_blank">Tufts Responsible Use Policy</a>.',
	'externalPasswordReset'	=> '',


	'emailProgram'		=> '/usr/lib/sendmail -t',
	'SMTPServer'		=> 'localhost',
	'pptServiceEnabled'	=> '',
	'tuskDocServiceEnabled'	=> '',
	'wordTextExtract'	=> '/usr/local/bin/antiword',
	'pdfTextExtract'	=> '/usr/local/bin/pdftotext',
	'mmtxExecutable'	=> '/data/umls/nls/mmtx/bin/MMTx',

 


	'useShibboleth'		=> '',
	'shibSPSecurePort'	=> '443',
	'shibbolethSP'		=> '',
	'shibbolethUserID'	=> 'shib_user',




	'deepHelpLinksOn'	=> '',
	'helpURL'		=> '',
	'contactURL'		=> '/about/contact_us',
	'aboutURL'		=> '/about/',
	'pdaHelpURL'		=> '',
	'faqURL'		=> '',
	'manageHelpURL'		=> '',
	'patientLogsHelp'	=> '',
	'printPDFHelp'		=> '',
	'searchHelp'		=> '',
	'patientLogsHelp'	=> '',



	'evalDTD'		=> '<?xml version="1.0"?><!DOCTYPE question_text SYSTEM "http://tusk.tufts.edu/DTD/eval.dtd">',
	'evalErrorMessage'	=> "Instead, please  1) contact the Registar's Office at 617-636-6568 and 2) notify <a href=\"mailto:samantha.fleming\@tufts.edu\">Samantha Fleming(samantha.fleming\@tufts.edu)</a> and we will create a new evaluation for you.",


	'schedulePasswordProtected'	=> 1,
	'scheduleMonthsDisplayedAtOnce'	=> 6,
	'scheduleDisplayMonthsInARow'	=> 1,


	'forumMaxAttachLen'	=> '10000000',
	'forumAttachementDir'	=> '/data/forum_data/',
	'forumEmail'		=> 'config:supportEmail',
	'forumName'		=> 'config:siteAbbr Forum',
	'forumHomeURL'		=> '',
	'forumHomeTitle'	=> 'config:siteAbbr',
	'forumAttachURL'	=> '/forum_attachments',
	'forumScriptURLPath'	=> '/forum',
	'forumPolicyTitle'	=> 'config:forumHomeTitle Policy',
	'forumPolicy'		=> 'Please see the <a href="http://uit.tufts.edu/?pid=444&c=104">Information Technology Responsible Use Policy</a>.',
	'forumAnimatedAvatar'	=> 0,
	'forumUserTimeZone'	=> '-5',
	'forumMailer'		=> 'sendmail',


	'mailMissingPageErrors'		=> '',
	'missingPageMessage'		=> "<p>\"Dang...I could have sworn it was around here somewhere...\"</p><p>I couldn't find the page you requested.  If you typed it in from something else, maybe you made a typo. If, on the other hand, you followed a link, then something might be wrong, and you should probably <a href=\"config:contactURL\">contact us</a> and tell us the location, and from where you followed that link. You can call us at config:supportPhone for immediate assistance.</p>",
	'error500EmailCount'		=> 5,
	'error500EmailTime'		=> 300, #5 minutes
	'error500EmailTimeBetween'	=> '300', #60 sec/min & 20 min
	'error500EmailTo'		=> 'john.westcott@tufts.edu',
	'error500FailoverFile'		=> '/tmp/500Error.backup_file.txt',
	'error500Message'		=> '<p>The page you requested is having trouble getting from our server to your web browser.</p><p>Your problem has been reported to TUSK and we will do our best to help you with this issue. If you would like to contact us with additional information please email <a href=\"mailto:config:supportEmail\">config:supportEmail</a> or call config:supportPhone.  Thank you for your patience.</p>',
	'error500EmailMessage'		=> 'More than config:Error500EmailCount have been revieced within config:Error500EmailTime.\nNext page no sooner than config:Error500EmailTimeBetween seconds.\n',
	'evalPageMessage'		=> "Instead, please  1) contact the Registar's Office at 617-636-6568 and 2) notify <a href=\"mailto:samantha.fleming\@tufts.edu\">Samantha Fleming(samantha.fleming\@tufts.edu)</a> and we will create a new evaluation for you.",



	'domain'		=> 'shib-service.tusk.tufts.edu',
	'permissibleIPs'	=> '127.0.0.1',




	'cookieSecret'		=> 'ladedadeda',
	'ticketExpireTime'	=> 240,
	'XMLRulesPath'		=> '/usr/local/apache/apache/HSCML/Rules/',

	'useTracking'		=> 0,
	'trackingString'	=> "<script type=\"text/javascript\"> var gaJsHost = ((\"https:\" == document.location.protocol) ? \"https://ssl.\" : \"http://www.\"); document.write(unescape(\"%3Cscript src='\" + gaJsHost + \"google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E\")); </script> <script type=\"text/javascript\"> var pageTracker = _gat._getTracker(\"UA-4877903-2\"); pageTracker._trackPageview(); </script>",

);






our %_descriptions = (
	'institutionAbbr'	=> 'The short version of the Institutions name',
	'institutionName'	=> 'The long version of the Institutions name',
	'siteAbbr'		=> 'The abbrievation that this site will use',
	'siteName'		=> 'The fill name that this site will use',
	'copyrightOrg'		=> "copyrightOrg is inserted into CMS copyright boxes, pre-populated with 'Copyright &lt;current year&gt;, &lt;copyrightOrg&gt;'",
	'systemWideUserGroupSchool'	=> 'SystemWideUserGroupSchool is used for announcement broadcasting. Announcements in this school and group will appear for all users in the system.',
	'systemWideUserGroup'	=> 'SystemWideUserGroup is used for announcement broadcasting. Announcements in this school and group will appear for all users in the system.',
	'siteAdmins'		=> 'Administrators of this installation.',


	'loginImage'		=> 'Name of the image file for the homepage.',
	'loginGradient'		=> 'The gradient on the login page.',
	'loginLogo'		=> 'THe logo in the upper left corner of tusk.',
	'loginBottomTopColor'	=> 'The color seperating the gradient and the bottom area.',
	'loginBottomColor'	=> 'The color of the bottom area.',


	'degrees'		=> 'These are the degrees that a user can be associated with.',
	'suffixes'		=> 'The suffixes that can be applied to a users name.',
        'emailWhenNewUserLogsIn'	=> 'Email support when a new user logs into the system.',
        'emailUserWhenNoAffiliationOrGroup'	=> 'The body of the email to send to a new user if they login and an affiliation cantbe determined',


	'useLdap'		=> 'Enable LDAP servers to be used for authentication.', 



	'errorEmail'		=> 'Email address where error emails will be sent',
	'pageEmail'             => 'Addresses that pages are sent to if there is a critical issue',
	'supportEmail'		=> 'Email address where users are refered to for support',
	'feedbackEmail'		=> 'Email address where feedback is sent to',
	'supportPhone'		=> 'Phone number displayed for support calls',
	'supportAddress'	=> 'Physical address of support personel',


	'homepageMessage'	=> 'A message displayed on the home page',
	'responsibleUseMessage'	=> 'A statement of privacy displayed in various areas to remind students of being honest',
	'externalPasswordReset'	=> 'If set this message will be displayed on the password reset page',


	'emailProgram'		=> 'Client program for sending emails',
	'SMTPServer'		=> 'SMTP server to use for emails',
	'pptServiceEnabled'	=> 'Use the PPT conversion service',
	'tuskDocServiceEnabled'	=> 'Use the TUSK Doc conversion service',
	'wordTextExtract'	=> 'Antiword executable',
	'pdfTextExtract'	=> 'Pdftotext executable',
	'mmtxExecutable'	=> 'MMTx executable',


	'useShibboleth'		=> 'Should the shibboleth module be used for external authentication.',
	'shibSPSecurePort'	=> 'What port should the shibboleth SP be run on',
	'shibbolethSP'		=> 'What server does the SP run on?',
	'shibbolethUserID'	=> 'This is the prefix and user used for shibboleth',


	'deepHelpLinksOn'	=> '',
	'helpURL'		=> 'The URL for the course which contains the help (blue button)',
	'contactURL'		=> 'The URL for the contact us page (blue button) ',
	'aboutURL'		=> 'The URl for the about page (blue button)',
	'pdaHelpURL'		=> 'Content ID for PDA help',
	'faqURL'		=> 'Content ID for the FAQ',
	'manageHelpURL'		=> 'Content ID for manage help',
	'patientLogsHelp'	=> 'Content ID for the patient logs help',
	'printPDFHelp'		=> 'Content ID for PDF printing help',
	'searchHelp'		=> 'Content ID for search help',



	'evalDTD'		=> 'The DTD included with when evals are generated',
	'evalErrorMessage'	=> 'A message displaed when the evals have errors',


	'schedulePasswordProtected'	=> 'Should a user be required to login to see the schedule',
	'scheduleMonthsDisplayedAtOnce'	=> 'How many months should be displayed',
	'scheduleDisplayMonthsInARow'	=> 'How many months should be in a row',


        'forumMaxAttachLen'	=> 'Max size in bites of uploaded files',
        'forumAttachementDir'	=> 'Directory where files are stored',
        'forumEmail'		=> 'Email to send support emails to',
        'forumName'		=> 'Name of the forum',
        'forumHomeURL'		=> 'Where does the image take you, leave this blank to disable the home link in the top forum bar',
        'forumHomeTitle'	=> 'The title of the forum',
        'forumAttachURL'	=> 'The url where attachements are stored',
        'forumScriptURLPath'	=> 'The url where the forum scripts are',
        'forumPolicyTitle'	=> 'The name of the forum policy',
        'forumPolicy'		=> 'The message of the forum policy',
        'forumAnimatedAvatar'	=> 'Are enimated gifs allowed as avatars?',
        'forumUserTimeZone'	=> 'The timezone the forums are in',
        'forumMailer'		=> 'The program the forums use to send mails',


	'mailMissingPageErrors',	=> 'If this is checked user support will recieve emails when pages requested are not found',
	'missingPageMessage'		=> 'Display this message if someone requests a page that does not exist',
	'error500EmailCount'		=> 'Send an email to site admins if this number of server errors are generated over some ammount of time',
	'error500EmailTime'		=>'Send an email to site admins if some number of errors are encountered of this ammount of seconds',
	'error500EmailTimeBetween'	=> 'The number of seconds between the error emails/pages',
	'error500EmailTo'		=> 'Who will errors go to?',
	'error500FailoverFile'		=> 'A file on the local OS where information can be stored in the case of a DB failure',
	'error500Message'		=> 'The message that you want the user to see',
	'error500EmailMessage'		=> 'The email/page text',
	'evalPageMessage'		=> 'Message displayed if there is an error with an eval',




	'domain'		=> 'The domain the site runs under',
	'permissibleIPs'	=> 'List of IP addresses of machines that will automatically be authorized to get content. Also used for XML requests during XSLT and FOP transformations',




	'cookieSecret'		=> 'Used in creating the cookie hash',
	'ticketExpireTime'	=> 'Time before the tick cookie expires',
	'XMLRulesPath'		=> 'default location to look for XML rules, can be overridden in method call',
);




sub new {
	my $class = shift;
	$class = ref $class || $class;
	my $self = {
		_variables  => {},
	};
	bless $self, $class;
	$self->loadAllValues();
	return $self;
}


# load all of the values.
# set any missing values
# When someone requests a value get all of the values that have changed since we last checked for them and update our cache

sub loadAllValues {
	my ($self, $forceReload) = @_;

	# Load all of the existing keys
	foreach my $loadedVariable (@{TUSK::Configuration::Variable->new()->lookup()}) {
		$self->{_variables}{$loadedVariable->getName()} = $loadedVariable;
	}

	# Check to make sure they are all there
	foreach my $defaultKey (keys %_defaultValues) {
		unless(exists($self->{_variables}{$defaultKey})) {
			# The variable did not exist so we need to create it with the default value
			$self->{_variables}{$defaultKey} = TUSK::Configuration::Variable->new();
			$self->{_variables}{$defaultKey}->setName($defaultKey);
			$self->{_variables}{$defaultKey}->setValue($_defaultValues{$defaultKey});
			if(exists($_descriptions{$defaultKey})) {$self->{_variables}{$defaultKey}->setDescription($_descriptions{$defaultKey});}
			warn("Creating new variable $defaultKey");
			$self->{_variables}{$defaultKey}->save();
		}
	}

	# Make sure that lastChanged was set and if not create it.
	unless(exists($self->{_variables}{'lastChanged'})) {
		# The variable did not exist so we need to create it with the default value
		$self->{_variables}{'lastChanged'} = TUSK::Configuration::Variable->new();
		$self->{_variables}{'lastChanged'}->setName('lastChanged');
		$self->{_variables}{'lastChanged'}->setValue(time);
		eval {
			$self->{_variables}{'lastChanged'}->save();
		};
		if($@) {
			#This got created already, lets just load it
			$self->{_variables}{'lastChanged'} = TUSK::Configuration::Variable->new()->lookup("name='lastChanged'");
		}
	}
}


sub getDescription {
	my ($self, $variableName) = @_;
	unless(exists($_defaultValues{$variableName})) {return undef;}
	if(exists($_descriptions{$variableName})) {return $_descriptions{$variableName};}
	return "";
}


sub existsInMultiValue {
	# Get the value of the variable and splits it at \n
	my ($self, $variableName, $findValue) = @_;

	$findValue ||= "\$^";
	my $value = "\n";
	if($self->getValue($variableName)) {$value.= $self->getValue($variableName);}
	$value =~ s/\r/\n/g;
	$value =~ s/\f/\n/g;
	$value.= "\n";
	if($value =~ /\n${findValue}\n/) {return 1;}
	return 0;
}

sub getMultiValue {
	# Get the value of the variable and splits it at \n
	my ($self, $variableName) = @_;

	my @returnValue;
	foreach my $variableValue (split /\n/, $self->getValue($variableName)) {
		$variableValue =~ s/[\n\r\f]//g;
		push @returnValue, $variableValue;
	}
	return @returnValue;
}

sub getHelpValue {
	# Get the value of the variable and splits it at \n
	my ($self, $variableName) = @_;

	my $tempValue = $self->getValue($variableName);
	if($tempValue) {return "/view/content/$tempValue";}
	return "";
}

sub getValue {
	my ($self, $variableName) = @_;

	# Load any variables that have been changed if we have not checked within the last 5 seconds
	my $lastLoadTime = HSDB4::DateTime->new()->in_mysql_timestamp(  $self->{_variables}{'lastChanged'}->getModifiedOn()  );
	
	if(time - $lastLoadTime->out_unix_time() >= 5000) {
		foreach my $updatedVariable (@{TUSK::Configuration::Variable->new()->lookup("modified_on > '" . $self->{_variables}{'lastChanged'}->getModifiedOn() . "'")}) {
			$self->{_variables}{$updatedVariable->getName()} = $updatedVariable;
		}
		$self->{_variables}{'lastChanged'}->setValue(time);
		eval { $self->{_variables}{'lastChanged'}->save(); };
	}

	# Does this variable exists? If not then give back undef
	unless(exists($_defaultValues{$variableName})) {return undef;}

	unless(exists($self->{_variables}{$variableName})) {return undef;}

	# if the value does not match out sequience return right away
	if($self->{_variables}{$variableName}->getValue() !~ /config:/) {return $self->{_variables}{$variableName}->getValue();}


	my $tempValue = $self->{_variables}{$variableName}->getValue();
	while($tempValue =~ /config:([A-Za-z0-9]+)/) {
		my $wikiVariable = $1;
		my $substution = "";
		if(!exists($_defaultValues{$wikiVariable})) {$substution = "Unknown Variable $wikiVariable";}
		else {
			if(exists($self->{_variables}{$wikiVariable})) {
				$substution = $self->getRawValue($wikiVariable);
			} else {
				$substution = "unloaded variable $wikiVariable";
			}
		}
		$tempValue =~ s/config:$wikiVariable/$substution/;
	}

	return $tempValue;
}

sub getRawValue {
	my ($self, $variableName) = @_;

	# Load any variables that have been changed
	foreach my $updatedVariable (@{TUSK::Configuration::Variable->new()->lookup("modified_on > '" . $self->{_variables}{'lastChanged'}->getModifiedOn() . "'")}) {
		$self->{_variables}{$updatedVariable->getName()} = $updatedVariable;
	}

	# Does this variable exists? If not then give back undef
	unless(exists($_defaultValues{$variableName})) {return undef;}

	unless(exists($self->{_variables}{$variableName})) {return undef;}
	return $self->{_variables}{$variableName}->getValue();
}


sub setValue {
	my ($self, $variableName, $newVariableValue) = @_;
	# Does this variable exists? If not then give back undef
	unless(exists($_defaultValues{$variableName})) {return undef;}

	$self->{_variables}{$variableName}->setValue($newVariableValue);
	if($self->{_variables}{$variableName}->save()) {return 1;}
	return 0;
}

sub dumpConfiguration {
	my ($self) = @_;
	foreach my $variableName (sort keys %{$self->{_variables}}) {
		print "$variableName\t" . $self->{_variables}{$variableName}->getValue() . "\n";
	}
}

sub getYesNoAsBoolean {
	my ($self, $variableName) = @_;
	if($variableName eq 'Yes') {return 1;}
	return;
}

=back

=cut

### Other Methods

=head1 BUGS

None Reported.

=head1 SEE ALSO

=head1 AUTHOR

TUSK Development Team <tuskdev@tufts.edu>

=cut

1;

