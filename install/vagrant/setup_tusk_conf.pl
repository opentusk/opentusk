#! /bin/env perl

use strict;
use warnings;
use utf8;

use Carp;
use Sys::Hostname;
use JSON::PP;

my $text;
{
    local $/;
    $text = <>;
}

my $json;
eval {
    $json = decode_json($text);
};
croak "Error reading tusk.conf: $@" if $@;

my $host = hostname();
$json->{SiteWide}->{Domain} = $host;
$json->{Communication}->{ErrorEmail} = q{};
$json->{Middleware}->{Servers}->{$host} =
    $json->{Middleware}->{Servers}->{MYFQDN};
# delete $json->{Middleware}->{Servers}->{MYFQDN};

my $cm = $json->{Authorization}->{DatabaseUsers}->{ContentManager};
$cm->{readusername} = 'content_mgr';
$cm->{readpassword} = 'vagrant';
$cm->{writeusername} = 'content_mgr';
$cm->{writepassword} = 'vagrant';

$json->{Path}->{MasonCacheRoot} = '/var/www/mason_cache';

print JSON::PP->new()->pretty()->sort_by(1)->encode($json);
