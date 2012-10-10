package TUSK::Application::Email;

use strict;
use MIME::Lite;

sub new {
    my ($class, $args) = @_;
    my $self = $args;
    bless($self, $class);
    return $self;
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







