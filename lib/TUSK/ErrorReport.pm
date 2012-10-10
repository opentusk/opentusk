package ErrorReport;

use strict; 
use Apache;
use Apache::Cookie;
use Apache::TicketTool;
use TUSK::Constants;

sub sendErrorReport {
	my $req_rec = shift or &sendDefaultReport();
	my $param_hash = shift || {};
	my $email_receiver = $param_hash->{'To'} || $TUSK::Constants::ErrorEmail;
	my $email_sender = $param_hash->{'From'} || $TUSK::Constants::ErrorEmail;
	my $addtlMsg = $param_hash->{'Msg'} || '';
	my $always_send = $param_hash->{'always_send'}; 
	my $conn = $req_rec->connection();
	my $user;
	unless ($user = $req_rec->connection->user) {
		if (my %cookies = Apache::Cookie->new($req_rec)->parse) {
			my %ticket = $cookies{'Ticket'}->value;
			$user = Apache::TicketTool::get_user_from_ticket(\%ticket);
		}
	}
	$user ||= 'unknown user';
	my $host = $ENV{HOSTNAME} || "unknown host";
	my $remote_ip = $conn->remote_ip() || "unknown ip";
	my $lastRequest = $req_rec->last()->as_string() || ''; 
	my $uriRequest = $param_hash->{'uriRequest'} || "unknown uri";
	my ($error,$error_text,$errArray,%localArgs) = ("","",[],());
	if ($req_rec->prev()){
		$uriRequest = $req_rec->prev()->uri() || "unknown uri"; 
		%localArgs = $req_rec->prev()->args();
		$errArray = $req_rec->prev()->pnotes("EMBPERL_ERRORS") || []; 
		$error = $req_rec->prev()->pnotes('error');
		$error_text = UNIVERSAL::can( $error, 'as_text' ) ? $error->as_text : $error;
	}
	my $subject = $param_hash->{'Subject'} || $TUSK::Constants::SiteAbbr." Error ($host): $user - $uriRequest";
	my $queryString = '' ;
	foreach my $arg (keys(%localArgs)){
		$queryString .= "$arg : ".$localArgs{$arg}."\n";
	}	

	$queryString = $ENV{'QUERY_STRING'} unless $queryString;
	my $errString = $error_text;
	
	## soon to be depricated -- checking for Embperl errors
	if (scalar @$errArray) {
		$errString .= "\n-- Begin Embperl Errors --\n\n\t";
		$errString .= join ("\n\t",@{$errArray});
		$errString .= "\n\n-- End Embperl Errors --\n\n";
	}
	
	my $msgBody =<<EOM;
Error from user $user on machine $host

Their ip is $remote_ip.

Their last request was:
$lastRequest

Their uri request was:
$uriRequest

Their query string was:
$queryString

Error:
$errString 

Addtl Message: 
$addtlMsg

EOM

	if ((!Apache->define('DEV') && !Apache->define('FINCH'))
		  || defined($always_send)){
		my %mail = ( To => $email_receiver,
		From => $email_sender ,
		Subject => $subject,
		Message => $msgBody);

		my $msg;
		if (my $err = Mail::Sendmail::sendmail(%mail)) {
			$msg = 0; 
		} else {
			Apache->warn($Mail::Sendmail::error);
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

sub sendDefaultReport{
        if (Apache->define('PROD')){
		Carp::cluck "Error Sending ERROR REPORT";
		my $msgBody = <<EOM;
This message has been sent because the Error Reporter was called incorrectly.
Most likely request object was not sent.  This Report will trigger a cluck and a
message to go into the Apache Log.
EOM
                my %mail = ( To => $TUSK::Constants::ErrorEmail,
                From => $TUSK::Constants::ErrorEmail,
                Subject => "Error Report Incorrectly Called",
                Message => $msgBody);

                if (!(my $err = Mail::Sendmail::sendmail(%mail))) {
                        Carp::cluck $Mail::Sendmail::error;
                }
        }

	exit 1;
}
1;
