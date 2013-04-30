#! /bin/env perl

use strict;
use warnings;
use utf8;

use Sys::Hostname;
use JSON;
use JSON::PP;

my $text;
{
    local $/;
    $text = <>;
}

eval {
    my $json = decode_json($text);
}
confess "Error reading tusk.conf: $@" if $@;

my $host = hostname();
$json->{SiteWide}->{Domain} = $host;
$json->{Communication}->{ErrorEmail} = q{};
$json->{Middleware}->{Servers}->{$host} =
    $json->{Middleware}->{Servers}->{MYFQDN};
delete $json->{Middleware}->{Servers}->{MYFQDN};

my $cm = $json->{Authorization}->{DatabaseUsers}->{ContentManager};
$cm->{readusername} = 'content_mgr';
$cm->{readpassword} = 'vagrant';
$cm->{writeusername} = 'content_mgr';
$cm->{writepassword} = 'vagrant';

print JSON::PP->new()->pretty()->sort_by(1)->encode($json);
