#!/usr/bin/perl

use strict;
use warnings;
use XML::LibXML;

__PACKAGE__->run();

sub run {
    my $xsd = 'http://ns.medbiq.org/curriculuminventory/v1/curriculuminventory.xsd';
    my $xml = $ARGV[0];

    my $schema = XML::LibXML::Schema->new(location =>$xsd); 
    my $parser = XML::LibXML->new;  
    my $doc = $parser->parse_file($xml); 
    eval { $schema->validate( $doc ) };  
    if ( my $ex = $@ ) {
	print $ex;
    } else {
	print "Schema is validated ok";
    }
}
