package TUSK::XMLRenderer;

use strict;
use XML::Twig;


# Description: applies an xsl transform to the xml of the course object
# Input: a string containing the path of the style sheet to be applied, and a hash of parameters
# Output: a string containing the transformed XML
sub transform {
    my $xml = shift;
    return unless ($xml);
    my $stylesheet_path = shift;
    my $parser = XML::LibXML->new();
    my $xslt = XML::LibXSLT->new();
    my $source = $parser->parse_string($xml);
    my $style_doc = $parser->parse_file($stylesheet_path);
    my $stylesheet = $xslt->parse_stylesheet($style_doc);
    my $results =  $stylesheet->transform($source, XML::LibXSLT::xpath_to_string(@_));
    return $stylesheet->output_string($results);
}

sub encode{
    my $data = shift;

    my $characters = '\<|\>|\;|\,|\/|\?|\\|\||\=|\+|\)|\(|\*|\&|\^|\%|\$|\#|\@|\!|\~|\`|\:';

    $data =~ s/($characters)/sprintf("&#%03d;", ord($1))/seg;
    return $data;

}
1;
__END__
