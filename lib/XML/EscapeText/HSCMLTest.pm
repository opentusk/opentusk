package XML::EscapeText::HSCMLTest;

use strict;

use base qw/Test::Unit::TestCase/;
use Test::Unit;
use XML::EscapeText::HSCML qw(:html);
use XML::Twig;

sub sql_files { return }

sub new {
    my $class = shift;
    my $self = $class->SUPER::new(@_);
    return $self;
}

sub set_up {}

sub tear_down {}

sub test_html_inline {
    my ($in_text, $right_text, $out_text);
    $in_text = "<i>How\x92d I such & such?</i>";
    $right_text = "<emph>How&#8217;d I such &amp; such?</emph>";
    $out_text = $html_inline->xml_escape($in_text);
    assert($right_text eq $out_text, "Didn't succeed with simple tags.");

    $in_text = "<i>How\x92d I <u>such & such</u>?</i>";
    $right_text = "<emph>How&#8217;d I <span style=\"text-decoration: underline\">such &amp; such</span>?</emph>";
    $out_text = $html_inline->xml_escape($in_text);
    assert($right_text eq $out_text, "Didn't succeed for complicated mapping (wanted $right_text, got $out_text).");

}

sub test_html_flow {
    my ($in_text, $right_text, $out_text);
    $in_text = "<p><hr><br><h1><u>AMBULATORY</u></h1><p><b><u>GENERAL QUESTIONS</u></b></p></p>";
    $right_text = "<para><pagebreak/><linebreak/><strong class=\"h1\"><span style=\"text-decoration: underline\">AMBULATORY</span></strong><para><strong><span style=\"text-decoration: underline\">GENERAL QUESTIONS</span></strong></para></para>";
    $out_text = $html_flow->xml_escape($in_text);
    assert($right_text eq $out_text, "Didn't succeed for complicated mapping (wanted $right_text, got $out_text).");

    eval {
	my $twg = XML::Twig->new();
	$twg->parse($out_text);
    };
    assert (! $@, "Got an error ($@) trying to parse some XML: [ $out_text ].");
}

1;
