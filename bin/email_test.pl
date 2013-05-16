#!/usr/bin/perl
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
#

use lib '/usr/local/tusk/current/lib';
use strict;
use warnings;
use Mail::Sendmail qw(%mailcfg );
use Sys::Hostname;
use TUSK::Constants;
use Data::Dumper;
my $host = Sys::Hostname::hostname;
my $to;
my $rx = $Mail::Sendmail::address_rx;
print "Hit <enter> to quit\n";
my %fromAddresses;
if($TUSK::Constants::Email)		{ $fromAddresses{ $TUSK::Constants::Email } = 1; }
if($TUSK::Constants::ErrorEmail)	{ $fromAddresses{ $TUSK::Constants::ErrorEmail } = 1; }
if($TUSK::Constants::PageEmail)		{ $fromAddresses{ $TUSK::Constants::PageEmail } = 1; }
if($TUSK::Constants::FeedbackEmail)	{ $fromAddresses{ $TUSK::Constants::FeedbackEmail } = 1; }
my @useFromAddresses = keys %fromAddresses;

if(%TUSK::Constants::Smtp) {
	unshift(@{$Mail::Sendmail::mailcfg{smtp}}, @{$TUSK::Constants::Smtp{Relays}}) if(exists($TUSK::Constants::Smtp{xRelays}));
	print Dumper(\%mailcfg);
} else {
	print "No Smtp"; <STDIN>;
}
print "Emails will be sent from ". join(',', @useFromAddresses) ."\n";
while(1) {
        print "Enter to address: ";
        chomp($to = <STDIN>);
        last if($to =~ /^\s*$/);
        if( $to =~ /$rx/ ) {
                send_mail($to);
        } else {
                print "Address appears invalid try again.\n";
        }

}
sub send_mail {
        my $to = shift;
        
	foreach my $address (@useFromAddresses) {
		print "Sending mail from $address...";
		my $data = {
			smpt	   => 'mail.kenet.or.ke',
			To         => $to,
			From       => $address,
			Subject    => "Email Test from $host",
			Body       => "This is a email functionality test from $host"
		};
		my $r = Mail::Sendmail::sendmail(%$data);
		if( $r ) {
			print "Done\n";
		} else {
			printf("Error = %s\n",$Mail::Sendmail::error);
		}
	}
}

