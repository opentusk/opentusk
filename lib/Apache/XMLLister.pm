package Apache::XMLLister;

use strict;

use HSDB45::TimePeriod;
use Apache::Constants ':common';


sub handler {
    my $r = shift();
    my @pieces = split(/\//, $r->path_info());
    shift(@pieces); # goodbye null field
    my $what = lc(shift(@pieces)) or return NOT_FOUND;
    my $school = shift(@pieces);

    my %lister_map = ("timeperiod" => "HSDB45::TimePeriod::Lister");


    return NOT_FOUND unless($lister_map{$what});
    $r->content_type("text/xml");
    $r->send_http_header();

    my $xml_text = $lister_map{$what}->get_xml_text($school);
    return NOT_FOUND unless($xml_text);
    $r->print($xml_text);
    return OK;
}

1;

