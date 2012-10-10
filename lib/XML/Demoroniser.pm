package XML::Demoroniser;

use strict;
use XML::Twig;
use vars qw(%entmap %wincodes);

%entmap = ("C0" => "\&Agrave;", 
	   "C1" => "\&Aacute;", 
	   "C2" => "\&Acirc;",
	   "C3" => "\&Atilde;",
	   "C4" => "\&Auml;",
	   "C5" => "\&Aring;",
	   "C6" => "\&AElig;",
	   "C7" => "\&Ccedil;",
	   "C8" => "\&Egrave;",
	   "C9" => "\&Eacute;",
	   "CA" => "\&Ecirc;",
	   "CB" => "\&Euml;",
	   "CC" => "\&Igrave;",
	   "CD" => "\&Iacute;",
	   "CE" => "\&Icirc;",
	   "CF" => "\&Iuml;",
	   "D0" => "\&ETH;",
	   "D1" => "\&Ntilde;", 
	   "D2" => "\&Ograve;",
	   "D3" => "\&Oacute;",
	   "D4" => "\&Ocirc;",
	   "D5" => "\&Otilde;",
	   "D6" => "\&Ouml;",
	   "D8" => "\&Oslash;",
	   "D9" => "\&Ugrave;",
	   "DA" => "\&Uacute;",
	   "DB" => "\&Ucirc;",
	   "DC" => "\&Uuml;",
	   "DD" => "\&Yacute;",
	   "DE" => "\&THORN;",
	   "DF" => "\&szlig;",
	   "91" => "\&#8216;", #"\&lsquo;",
	   "92" => "\&#8217;", #"\&rsquo;",
	   "93" => "\&#8220;", #"\&ldquo;",
	   "94" => "\&#8221;", #"\&rdquo;",
	   "96" => "\&#8211;", #"\&ndash;",
	   "97" => "\&#8212;", #"\&mdash;",
	   "99" => "\&#8482;", #"\&trade;",
	   "83" => "\&fnof;",
	   "85" => "\&#8230;", # "\&hellip;",
	   "AE" => "\&reg;",
	   "E0" => "\&agrave;",
	   "E1" => "\&aacute;",
	   "E2" => "\&acirc;",
	   "E3" => "\&atilde;",
	   "E4" => "\&auml;",
	   "E5" => "\&aring;",
	   "E6" => "\&aelig;",
	   "E7" => "\&ccedil;",
	   "E8" => "\&egrave;",
	   "E9" => "\&eacute;",
	   "EA" => "\&ecirc;",
	   "EB" => "\&euml;",
	   "EC" => "\&igrave;",
	   "ED" => "\&iacute;",
	   "EE" => "\&icirc;",
	   "EF" => "\&iuml;",
	   "F0" => "\&eth;",
	   "F1" => "\&ntilde;",
	   "F2" => "\&ograve;",
	   "F3" => "\&oacute;",
	   "F4" => "\&ocirc;",
	   "F5" => "\&otilde;",
	   "F6" => "\&ouml;",
	   "F8" => "\&oslash;",
	   "F9" => "\&ugrave;",
	   "FA" => "\&uacute;",
	   "FB" => "\&ucirc;",
	   "FC" => "\&uuml;",
	   "FD" => "\&yacute;",
	   "FE" => "\&thorn;",
	   "FF" => "\&yuml;",
	   "A1" => "\&iexcl;",
	   "BF" => "\&iquest;",
	   "A2" => "\&cent;",
	   "A3" => "\&pound;",
	   "A4" => "\&curren;",
	   "A5" => "\&yen;",
	   "B6" => "\&para;",
	   "A7" => "\&sect;",
	   "A9" => "\&copy;",
	   "AA" => "\&ordf;",
	   "BA" => "\&ordm;",
	   "AB" => "\&laquo;",
	   "BB" => "\&raquo;",
	   "B5" => "\&micro;",
	   "B0" => "\&deg;",
	   "B7" => "\&middot;",
	   "D7" => "\&times;",
	   "F7" => "\&divide;",
	   "B1" => "\&plusmn;",
	   "B2" => "\&sup2;",
	   "B3" => "\&sup3;",
	   "B9" => "\&sup1;",
	   "BC" => "\&frac14;",
	   "BD" => "\&frac12;",
	   "BE" => "\&frac34;", 
	   "A6" => "\&brvbar;",
	   "80" => "\&#8364;", #&euro;
	   "82" => "\&#8218;", #&sbquo;
	   "84" => "\&#8222;",
	   "85" => "\&#8230;",
	   "86" => "\&#8224;",
	   "87" => "\&#8225;",
	   "95" => "\&#8226;",
	   "89" => "\&#8240;",
	   "8B" => "\&#8249;",
	   "9B" => "\&#8250;",
	   );

sub new {
    my $class = shift;
    my $data = shift;
    $class = ref $class || $class;
    my $self = {-data => $data};
    return bless $self, $class;
}

sub set_data {
    my $self = shift;
    my $data = shift;
    return unless ($data);
    $self->{-data} = $data;
}

sub get_data {
    my $self = shift;
    return $self->{-data};
}

sub demoronise {
    my $self = shift;
    my $s = shift;
    $s = $self->get_data unless ($s);

    foreach my $key (keys %entmap) {
	my $value = $entmap{$key};
	# my $value = "\&#x$key\;";
	$s =~ s/\x$key/$value/g;
    }
    $self->set_data($s);
    return $s;
}

1;
