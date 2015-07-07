#!/usr/bin/perl

##################################################################
# 
# Fixes the URI column for national competencies to meet the AAMC
# standards. Changes 'http' to 'https' 
#
##################################################################

use strict;
use warnings;

use Getopt::Long;
my ($school);

BEGIN {
    GetOptions("school=s" => \$school
	       );

    if (!$school) {
	print "Usage: fix_national_competency_uri.pl --school=<school_name>\nExample: fix_sort_order --school=Medical\n";
	exit;
    }
}

use TUSK::Enum::Data;
use TUSK::Feature::Link;
use TUSK::Application::Competency::Competency;
use TUSK::Competency::Competency;
use TUSK::Competency::Hierarchy;

use Data::Dumper;

main();

sub main {
    my $feature_type_enum_id = TUSK::Enum::Data->lookupReturnOne("namespace = \"feature_link.feature_type\" AND short_name = \"competency\"")->getPrimaryKeyID;
    my $uris = TUSK::Feature::Link->lookup("feature_type_enum_id = $feature_type_enum_id");

    my ($orig_uri, @split_uri, $new_uri);

    foreach my $uri (@{$uris}){
	$orig_uri = $uri->getUrl();
	@split_uri = split('://', $orig_uri);
	if ($split_uri[0] && $split_uri[0] eq "http" ) {
	    $split_uri[0] = "https";
	    $new_uri = join( '://', @split_uri);
	    print $orig_uri . " : " . $new_uri . "\n";
	    $uri->setUrl($new_uri);
	    $uri->save();
	}
    }
}
