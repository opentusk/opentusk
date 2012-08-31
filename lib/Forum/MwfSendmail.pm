# Based on Mail::Sendmail by Milivoj Ivkovic <mi@alma.ch>
# This version has been slightly modified for mwForum.
# The original version can be obtained from CPAN.

package MwfSendmail;
$VERSION = "1.15.0";

# *************** Configuration you may want to change *******************
# You probably want to set your SMTP server here (unless you specify it in
# every script), and leave the rest as is. See pod documentation for details

%mailcfg = (
    # List of SMTP servers:
    'smtp'    => [ ],

    'from'    => '', # default sender e-mail, used when no From header in mail

    'mime'    => 1, # use MIME encoding by default

    'retries' => 1, # number of retries on smtp connect failure
    'delay'   => 1, # delay in seconds between retries

    'tz'      => '', # only to override automatic detection
    'port'    => 25, # change it if you always use a non-standard port
    'debug'   => 0 # prints stuff to STDERR
);

# *******************************************************************

use strict;
require Exporter;
use vars qw(
            $VERSION
            @ISA
            @EXPORT
            @EXPORT_OK
            %mailcfg
            $default_smtp_server
            $default_smtp_port
            $default_sender
            $TZ
            $use_MIME
            $address_rx
            $debug
            $log
            $error
            $retry_delay
            $connect_retries
           );

use Socket;
use Time::Local; # for automatic time zone detection

# use MIME::QuotedPrint if available and configured in %mailcfg
eval("use MIME::QuotedPrint");
$mailcfg{mime} &&= (!$@);

@ISA        = qw(Exporter);
@EXPORT     = qw(&sendmail);
@EXPORT_OK  = qw(
                 %mailcfg
                 time_to_date
                 $default_smtp_server
                 $default_smtp_port
                 $default_sender
                 $TZ
                 $address_rx
                 $debug
                 $log
                 $error
                );

# regex for e-mail addresses where full=$1, user=$2, domain=$3
# see pod documentation about this regex

my $word_rx = '[\x21\x23-\x27\x2A-\x2B\x2D\w\x3D\x3F]+';
my $user_rx = $word_rx         # valid chars
             .'(?:\.' . $word_rx . ')*' # possibly more words preceded by a dot
             ;
my $dom_rx = '\w[-\w]+(?:\.\w[-\w]+)*'; # less valid chars in domain names
my $ip_rx = '\[\d{1,3}(?:\.\d{1,3}){3}\]';

$address_rx = '\b((' . $user_rx . ')\@(' . $dom_rx . '\b|' . $ip_rx . '))';
; # v. 0.4

sub time_to_date {
    # convert a time() value to a date-time string according to RFC 822

    my $time = $_[0] || time(); # default to now if no argument

    my @months = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
    my @wdays  = qw(Sun Mon Tue Wed Thu Fri Sat);

    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)
        = localtime($time);

    $TZ ||= $mailcfg{tz};

    if ( $TZ eq "" ) {
        # offset in hours
        my $offset  = sprintf "%.1f", (timegm(localtime) - time) / 3600;
        my $minutes = sprintf "%02d", ( $offset - int($offset) ) * 60;
        $TZ  = sprintf("%+03d", int($offset)) . $minutes;
    }
    return join(" ",
                    ($wdays[$wday] . ','),
                     $mday,
                     $months[$mon],
                     $year+1900,
                     sprintf("%02d", $hour) . ":" . sprintf("%02d", $min),
                     $TZ
               );
} # end sub time_to_date

sub sendmail {
    # original sendmail 1.21 by Christian Mallwitz.
    # Modified and 'modulized' by mi@alma.ch

    $error = '';
    $log = "MwfSendmail v. $VERSION - "    . scalar(localtime()) . "\n";

    local $_;
    local $/ = "\015\012";

    my (%mail, $k,
        $smtp, $server, $port, $connected, $localhost,
        $message, $fromaddr, $recip, @recipients, $to, $header,
       );

    sub fail {
        # things to do before returning a sendmail failure
        #print STDERR @_ if $^W;
        $error .= join(" ", @_) . "\n";
        close S;
        return 0;
    }

    # all config keys to lowercase, to prevent typo errors
    foreach $k (keys %mailcfg) {
        if ($k =~ /[A-Z]/) {
            $mailcfg{lc($k)} = $mailcfg{$k};
        }
    }

    # redo hash, arranging keys case etc...
    while (@_) {
        # arrange keys case
        $k = ucfirst lc(shift @_);

        if (!$k and $^W) {
            warn "Received false mail hash key: \'$k\'. Did you forget to put it in quotes?\n";
        }

        $k =~ s/\s*:\s*$//o; # kill colon (and possible spaces) at end, we add it later.
        $mail{$k} = shift @_;
    }

    $smtp = $mail{Smtp} || $mail{Server} || $default_smtp_server;
    unshift @{$mailcfg{smtp}}, $smtp if ($smtp and $mailcfg{smtp}->[0] ne $smtp);

    # delete non-header keys, so we don't send them later as mail headers
    # I like this syntax, but it doesn't seem to work with AS port 5.003_07:
    # delete @mail{'Smtp', 'Server'};
    # so instead:
    delete $mail{Smtp}; delete $mail{Server};

    $mailcfg{port} = $mail{Port} || $default_smtp_port || $mailcfg{port} || 25;
    delete $mail{Port};

    # for backward compatibility only
    $mailcfg{retries} = $connect_retries if defined($connect_retries);
    $mailcfg{delay} = $retry_delay if defined($retry_delay);

    {    # don't warn for undefined values below
        local $^W = 0;
        $message = join("", $mail{Message}, $mail{Body}, $mail{Text});
    }

    # delete @mail{'Message', 'Body', 'Text'};
    delete $mail{Message}; delete $mail{Body}; delete $mail{Text};

    # Extract 'From:' e-mail address

    $fromaddr = $mail{From} || $default_sender || $mailcfg{from};
    unless ($fromaddr =~ /$address_rx/) {
        return fail("Bad or missing From address: \'$fromaddr\'");
    }
    $fromaddr = $1;

    # add Date header if needed
    $mail{Date} ||= time_to_date() ;
    $log .= "Date: $mail{Date}\n";

    # cleanup message, and encode if needed
    $message =~ s/^\./\.\./gom;     # handle . as first character
    $message =~ s/\r\n/\n/go;     # normalize line endings, step 1 of 2 (next step after MIME encoding)

    $mail{'MIME-version'} ||= '1.0';
    $mail{'Content-type'} ||= "text/plain; charset=\"iso-8859-1\"";

    unless ( $mail{'Content-transfer-encoding'}
          || $mail{'Content-type'} =~ /multipart/io )
    {
        if ($mailcfg{mime}) {
            $mail{'Content-transfer-encoding'} = 'quoted-printable';
            $message = encode_qp($message);
        }
        else {
            $mail{'Content-transfer-encoding'} = '8bit';
            if ($message =~ /[\x80-\xFF]/o) {
                $error .= "MIME::QuotedPrint not present!\nSending 8bit characters, hoping it will come across OK.\n";
                warn "MIME::QuotedPrint not present!\n",
                     "Sending 8bit characters, hoping it will come across OK.\n"
                     if $^W;
            }
        }
    }

    $message =~ s/\n/\015\012/go; # normalize line endings, step 2.

    # Get recipients
    {    # don't warn for undefined values below
        local $^W = 0;
        $recip = join(", ", $mail{To}, $mail{Cc}, $mail{Bcc});
    }

    delete $mail{Bcc};

    @recipients = ();
    while ($recip =~ /$address_rx/go) {
        push @recipients, $1;
    }
    unless (@recipients) {
        return fail("No recipient!")
    }

    # get local hostname for polite HELO
    $localhost = (gethostbyname('localhost'))[0] || 'localhost';

    foreach $server ( @{$mailcfg{smtp}} ) {
        # open socket needs to be inside this foreach loop on Linux,
        # otherwise all servers fail if 1st one fails !??! why?
        unless ( socket S, AF_INET, SOCK_STREAM, (getprotobyname 'tcp')[2] ) {
            return fail("socket failed ($!)")
        }

        #print "- trying $server\n" if $mailcfg{debug} > 1;

        $server =~ s/\s+//go; # remove spaces just in case of a typo
        # extract port if server name like "mail.domain.com:2525"
        ($server =~ s/:(.+)$//o) ? $port = $1    : $port = $mailcfg{port};
        $smtp = $server; # save $server for use outside foreach loop

        my $smtpaddr = inet_aton $server;
        unless ($smtpaddr) {
            $error .= "$server not found\n";
            next; # next server
        }

        my $retried = 0; # reset retries for each server
        while ( ( not $connected = connect S, pack_sockaddr_in($port, $smtpaddr) )
            and ( $retried < $mailcfg{retries} )
              ) {
            $retried++;
            $error .= "connect to $server failed ($!)\n";
            #print "- connect to $server failed ($!)\n" if $mailcfg{debug} > 1;
            #print "retrying in $mailcfg{delay} seconds...\n" if $mailcfg{debug} > 1;
            sleep $mailcfg{delay};
        }

        if ( $connected ) {
            #print "- connected to $server\n" if $mailcfg{debug} > 3;
            last;
        }
        else {
            $error .= "connect to $server failed\n";
            #print "- connect to $server failed, next server...\n" if $mailcfg{debug} > 1;
            next; # next server
        }
    }

    unless ( $connected ) {
        return fail("connect to $smtp failed ($!) no (more) retries!")
    };

    {
        local $^W = 0; # don't warn on undefined variables
        # Add info to log variable
        $log .= "Server: $smtp Port: $port\n"
              . "From: $fromaddr\n"
              . "Subject: $mail{Subject}\n"
              . "To: ";
    }

    my($oldfh) = select(S); $| = 1; select($oldfh);

    chomp($_ = <S>);
    if (/^[45]/ or !$_) {
        return fail("Connection error from $smtp on port $port ($_)")
    }

    print S "HELO $localhost\015\012";
    chomp($_ = <S>);
    if (/^[45]/ or !$_) {
        return fail("HELO error ($_)")
    }
    
    print S "mail from: <$fromaddr>\015\012";
    chomp($_ = <S>);
    if (/^[45]/ or !$_) {
        return fail("mail From: error ($_)")
    }

    foreach $to (@recipients) {
        #if ($debug) { print STDERR "sending to: <$to>\n"; }
        print S "rcpt to: <$to>\015\012";
        chomp($_ = <S>);
        if (/^[45]/ or !$_) {
            $log .= "!Failed: $to\n    ";
            return fail("Error sending to <$to> ($_)\n");
        }
        else {
            $log .= "$to\n    ";
        }
    }

    # start data part
    print S "data\015\012";
    chomp($_ = <S>);
    if (/^[45]/ or !$_) {
           return fail("Cannot send data ($_)");
    }

    # print headers
    foreach $header (keys %mail) {
        $mail{$header} =~ s/\s+$//o; # kill possible trailing garbage
        print S "$header: ", $mail{$header}, "\015\012";
    };

    #- test diconnecting from network here, to see what happens
    #- print STDERR "DISCONNECT NOW!\n";
    #- sleep 4;
    #- print STDERR "trying to continue, expecting an error... \n";

    # send message body
    print S "\015\012",
            $message,
            "\015\012.\015\012";

    chomp($_ = <S>);
    if (/^[45]/ or !$_) {
           return fail("message transmission failed ($_)");
    }

    # finish
    print S "quit\015\012";
    $_ = <S>;
    close S;

    return 1;
} # end sub sendmail

1;
