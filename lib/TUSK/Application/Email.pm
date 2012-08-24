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


package TUSK::Application::Email;

use strict;
use MIME::Lite;
use Mail::Sendmail;
use utf8;
use Encode;
use TUSK::Constants;

my $sendmail_error;


sub new {
    my ($class, $args) = @_;
    my $self = $args;
    bless($self, $class);
    return $self;
}


sub send {
	my $self = shift;
	my $mailhash = { 
		To => $self->{to_addr},
		From => $self->{from_addr},
		Subject => $self->{subject},
		Message => $self->{body},
	};
	$mailhash->{'Content-Type'} = $self->{'Content-Type'} || 'text/plain; charset="utf-8"';
	if ($mailhash->{'Content-Type'} =~ m/html/i) {
		$mailhash = fixHTMLPaths($mailhash);
	}
	$mailhash->{'BCC'} = $self->{bcc} if $self->{bcc};
	$mailhash = fixUTF8($mailhash);

	my %mail = %$mailhash;
	my $result = Mail::Sendmail::sendmail(%$mailhash);
	$sendmail_error = $Mail::Sendmail::error unless $result;
	return $result;
}


sub getError {
	return $sendmail_error;
}


sub fixUTF8 {
	my $mailhash      = shift;
	my $contains_utf8 = 0;

	#Look through the email fields for UTF-8 strings (probably
	#marked so by utf8::decode in MasonX::Plugin::UTF8).
	foreach my $key (keys(%$mailhash)) {
		if (utf8::is_utf8($mailhash->{$key})) {
			$contains_utf8 = 1;
			last;
		}
	}

	#If we found such a string, ensure all of the email fields
	#are turned into byte strings, so Mail::Sendmail won't complain
	#about wide characters. Also, if a Content-Type was specified,
	#make sure to specify the proper encoding.
	if ($contains_utf8) {
		foreach my $key (keys(%$mailhash)) {
			#Do MIME header encoding on email header fields.
			if ($key =~ m/(to|from|subject)/i) {
				$mailhash->{$key} = Encode::encode("MIME-Header", $mailhash->{$key});
			}

			#Encode the body as a byte string. 
			else {
				utf8::encode($mailhash->{$key});
			}
		}
	}
	return $mailhash;
}

# make all relative paths absolute for HTML email so that links/images 
# will work as expected in email clients
sub fixHTMLPaths {
	my $mailhash = shift;
	$mailhash->{'Message'} =~ s/([src|href]=["|'])\//$1http:\/\/$TUSK::Constants::Domain\//sg;
	return $mailhash;
}


sub sendWithFHAttachments {
	my $self = shift;

    my $msg = MIME::Lite->new(
							  From    => $self->{from_addr},
							  To      => $self->{to_addr},
							  Subject => $self->{subject},
							  Type    => 'multipart/mixed',
    );

	MIME::Lite->send("sendmail", "/usr/lib/sendmail -t -oi -oem");

	$msg->attach(
		Type 	=> 'TEXT',
		Data 	=> $self->{body},
    );


	foreach my $data (@{$self->{attachments}}) {
		if (defined $data && scalar @$data == 3 && defined $data->[0]) {
			$data->[0]->setpos($data->[1]);
			$msg->attach(
						 Type 	 => 'application/vnd.ms-excel',
						 FH       => $data->[0],
						 Filename => $data->[2],
						 ReadNow  => 1,
						 Disposition => 'attachment',
						 );
		}
	}

    $ENV{PATH} = '/usr/local/bin:/usr/bin:/bin';  ## taint the path
	$msg->send();
}



1;







