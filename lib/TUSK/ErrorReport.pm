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

# Should be TUSK::ErrorReport to match the file path and use
# statements. Will require refactor of several files.
package ErrorReport;

use strict;
use Carp;
use Apache2::ServerUtil;
use Apache2::Cookie;
use Apache2::Connection;
use Apache2::Log;
use Apache::TicketTool;
use TUSK::Constants;
use TUSK::Application::Email;

sub sendErrorReport {
	my $req_rec = shift or &sendDefaultReport();
	my $param_hash = shift || {};
	my $email_receiver = $param_hash->{'To'} || $TUSK::Constants::ErrorEmail;
	my $email_sender = $param_hash->{'From'} || $TUSK::Constants::ErrorEmail;
	my $addtlMsg = $param_hash->{'Msg'} || '';
	my $always_send = $param_hash->{'always_send'}; 
	my $conn = $req_rec->connection();
	my $user;
	unless ($user = $req_rec->user) {
		my $cookieJar = Apache2::Cookie::Jar->new($req_rec);
		if ($cookieJar->cookies('Ticket')) {
			my %ticket = $cookieJar->cookies('Ticket')->value;
			$user = Apache::TicketTool::get_user_from_ticket(\%ticket);
		}
	}
	$user ||= 'unknown user';
	my $host = $ENV{HOSTNAME} || "unknown host";
	my $remote_ip = $conn->remote_ip() || "unknown ip";
	my $lastRequest = 'Unknown';
	my $uriRequest = $param_hash->{'uriRequest'} || $req_rec->uri()
            || "unknown uri";
	my ($error,$error_text,$errArray,%localArgs) = ("","",[],());
        my $postString = '';
	if ($req_rec->prev()){
		if($req_rec->prev()->prev()) {
			$lastRequest = $req_rec->prev()->prev()->as_string();
		}
		$uriRequest = $req_rec->prev()->uri() || "unknown uri"; 
		%localArgs = $req_rec->prev()->args();
                # $postString = readPost($req_rec->prev());
		$error = $req_rec->prev()->pnotes('error');
		$error_text = UNIVERSAL::can( $error, 'as_text' ) ? $error->as_text : $error;
	}
	my $subject = $param_hash->{'Subject'} || $TUSK::Constants::SiteAbbr." Error ($host): $user - $uriRequest";
	my $queryString = '' ;
	foreach my $arg (keys(%localArgs)){
		$queryString .= "$arg : ".$localArgs{$arg}."\n";
	}	

	$queryString = $ENV{'QUERY_STRING'} unless $queryString;
	$queryString = '(No query string)' unless $queryString;
	my $errString = $error_text;

        # $postString = readPost($req_rec) unless $postString;
        $postString = '(HTTP POST data reporting not yet supported)' unless $postString;

	my $msgBody =<<EOM;
Error from user $user on machine $host

Their ip is $remote_ip.

Their last request was:
$lastRequest

Their uri request was:
$uriRequest

Their query string was:
$queryString

HTTP POST data:
$postString

Error:
$errString 

Addtl Message: 
$addtlMsg

EOM

	if ((!Apache2::ServerUtil::exists_config_define('DEV') && !Apache2::ServerUtil::exists_config_define('FINCH'))
		  || defined($always_send)){
		my $mail = TUSK::Application::Email->new({ 
			to_addr   => $email_receiver,
			from_addr => $email_sender ,
			subject   => $subject,
			body      => $msgBody
		});

		my $msg;
		if (my $err = $mail->send()) {
			$msg = 0; 
		} else {
			$req_rec->log_error("Unable to send email: " . $mail->getError() . "\n".
					"\tTo: $email_receiver\n".
					"\tFrom: $email_sender\n".
					"\tSubject: $subject\n".
					"\tMessage: $msgBody\n"
			);
		}
		warn "Message Sent";
	    }else{
		warn $addtlMsg if $addtlMsg;
	    }
	return $msgBody;
	
} 

sub send404Report {
	my $req_rec = shift || &sendDefaultReport();
	my $param_hash = shift;
	my @errorDirs = qw/content course schedule query personal_content
		data small_data thumbnail binary orig xlarge large medium small 
		thumb icon chooser_icon daygif evalgraph mergedevalgraph 
		XMLObject XMLLister forum/;

	if (my $uri = $req_rec->prev()->uri()){
		foreach my $errorDir (@errorDirs){
			if ($uri =~ m/\b$errorDir\b/){
				return &sendErrorReport($req_rec,$param_hash);	
			}
		}
	}	

}

sub sendDefaultReport {
    Carp::cluck "Error Sending ERROR REPORT";
    my $msgBody = <<EOM;
This message has been sent because the Error Reporter was called incorrectly.
Most likely request object was not sent.  This Report will trigger a cluck and a
message to go into the Apache Log.
EOM
    my $mail = TUSK::Application::Email->new({ 
        to_addr   => $TUSK::Constants::ErrorEmail,
        from_addr => $TUSK::Constants::ErrorEmail,
        subject   => "Error Report Incorrectly Called",
        body      => $msgBody
    });

    if ( ! ( my $err = $mail->send() ) ) {
        Carp::cluck $mail->getError();
    }

    confess "Error sending ERROR REPORT";
}

sub readPost {
    my $r = shift;
    my $postdata = '';
    if ($r->method() eq "POST") {
        my $buf = '';
        # limit reported POST data to first 1024 bytes
        if ($r->read($buf, 1024)) {
            $postdata = $postdata . $buf;
        }
    }
    return $postdata;
}

1;
