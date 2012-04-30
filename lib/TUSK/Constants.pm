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


package TUSK::Constants;

use strict;
use Carp;
use JSON;

initConfigs();
initStatics();

sub initConfigs {
    ### read from conf/config.yml
    ### read from db  if no value in db, yell out and die?

    my $data = getConfig();

    {
	my %seen_variables = ();
	no strict 'refs';

	foreach my $category (keys %{$data}) {
	    foreach my $item (keys %{$data->{$category}}) {		
		if ($item !~ /^([A-z]+)(_*)([A-z]+)$/) {
		    carp "Bad Variable Name: $item\n"  unless $category eq 'Servers';
		}

		## check for duplicate names
		if (exists $seen_variables{$item}) {
		    carp "Duplicate Variable: $item\n";
		} else {
		    $seen_variables{$item} = $data->{$category}{$item};
		}
		my $varname = $item;
		if (ref $data->{$category}{$item} eq 'ARRAY') {
		    @{$varname} = @{$data->{$category}{$item}};
		} elsif (ref $data->{$category}{$item} eq 'HASH') {
		    %{$varname} = %{$data->{$category}{$item}}; 
		} else { 
		    ${$varname} = $data->{$category}{$item}; 
	        }
	    }
	}
    }
}


sub getConfig {
    my $file = '/usr/local/tusk/conf/tusk.conf';
    local $/;
    open( my $fh, '<', $file );
    my $data   = <$fh>;
    close $fh;

    my $conf;
    eval {
	$conf = decode_json($data);
    };
    print $@ if $@;
    return $conf;
}


sub initStatics {
    our $DefaultDb = 'hsdb4';

    #########################################
    ## Forum Variables
    #########################################
    our $MaxAttachLen = '10000000';

    our $ForumEmail = $TUSK::Constants::Institution{Email};
    our $ForumName = $TUSK::Constants::SiteAbbr . ' Forum';
    our $HomeUrl = ''; # leave this blank to disable the home link in the top forum bar
    our $HomeTitle = $TUSK::Constants::SiteAbbr;

    our $ScriptUrlPath = '/forum';
    our $ForumPolicyTitle = $ForumName . ' Policy';
    our $userTimezone = "-5";
    our $Mailer = "sendmail";
    
    ### case simulator
    our $release_stamp_3_6_1 = 1;

    our $ContactURL = '/about/contact_us';

    #### EVAULATIONS ####
    our @evalGraphicsFormats = ('png', 'jpeg', 'gif');
    our $EvalDTD = <<EOM;
<?xml version="1.0"?><!DOCTYPE question_text SYSTEM "http://$TUSK::Constants::Domain/DTD/eval.dtd">
EOM

    our $WebError = 
    "<p>The page you requested is having trouble getting from our server to your web browser.</p>" . 
    "<p>Your problem has been reported to $TUSK::Constants::SiteAbbr and we will do our best to help you with this issue." .
    "  If you would like to contact us with additional information please email ".
    "<a href=mailto:" . $TUSK::Constants::Institution{Email} . ">" . $TUSK::Constants::Institution{Email} . "</a>".
    " or call " . $TUSK::Constants::Institution{Phone} . ".  Thank you for your patience.";

    our $EmailUserWhenNoAffiliationOrGroupText = "Hello and thank you for using the $TUSK::Constants::SiteAbbr system.\nWe were unable to determine the school or group with which you are affiliated.\nPlease reply to this email and let us know your school affiliation and, if you are a student, please include your year of graduation.\n\n$TUSK::Constants::SiteAbbr Support\n$TUSK::Constants::Institution{Email}\n$TUSK::Constants::Institution{Phone}\n" . join("\n", @{$TUSK::Constants::Institution{Address}}); 
}


1;
