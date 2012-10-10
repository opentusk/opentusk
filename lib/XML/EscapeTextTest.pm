package XML::EscapeTextTest;

use strict;

use base qw/Test::Unit::TestCase/;
use Test::Unit;
use XML::EscapeText qw(:escape :demoronise);
use XML::EscapeText::HSCML;
use XML::Twig;

sub sql_files { return }

sub new {
    my $class = shift;
    my $self = $class->SUPER::new(@_);
    return $self;
}

sub set_up {}

sub tear_down {}

sub test_make_pcdata {
    my $text = "This is some text with an & and some <tag> values.";
    my $right_text = "This is some text with an &amp; and some &lt;tag&gt; values.";
    my $fixed_text = make_pcdata($text);
    assert($right_text eq $fixed_text, 
	   "Basic make_pcdata() fails; expected $right_text, got $fixed_text");

    $text = "Text with a moron character: and em-dash: \x97 & smart apostrophe: \x92";
    $right_text = 'Text with a moron character: and em-dash: &#8212; &amp; smart apostrophe: &#8217;';
    $fixed_text = make_pcdata($text);
    assert($right_text eq $fixed_text, 
	   "Basic make_pcdata() fails; expected $right_text, got $fixed_text");

    $text = "What happens if we &amp; include some <markup>?";
    $right_text = "What happens if we &amp; include some &lt;markup&gt;?";
    $fixed_text = make_pcdata($text);
    assert($right_text eq $fixed_text, 
	   "Basic make_pcdata() fails; expected $right_text, got $fixed_text");
}

sub test_spec_char {
    my $text = "Garc\xEDa-L\xF3pez";
    my $right_text = "Garc&iacute;a-L&oacute;pez";
    my $fixed_text = spec_chars_name($text);
    assert($right_text eq $fixed_text,
	   "Basic spec_chars_name() fails; expected $right_text, got $fixed_text ($text)");

    my $right_text = "Garc&#237;a-L&#243;pez";
    my $fixed_text = spec_chars_number($text);
    assert($right_text eq $fixed_text, 
	   "Basic spec_chars_name() fails; expected $right_text, got $fixed_text ($text)");
}

sub test_fix_tag {
    my $fixer = XML::EscapeText->new();
    $fixer->add_tag(qw(emph strong break));
    $fixer->add_entity('baz');
    my $text = "Garc\xEDa-L\xF3pez\x97what <foo class=\"whatever\">was</foo> he <emph>thinking</emph>? & what could it all mean? &amp; why does &baz; anyone <strong>care</strong>?";
    my $right_text = "Garc&#237;a-L&#243;pez&#8212;what &lt;foo class=\"whatever\"&gt;was&lt;/foo&gt; he <emph>thinking</emph>? &amp; what could it all mean? &amp; why does &baz; anyone <strong>care</strong>?";
    my $fixed_text = $fixer->xml_escape($text);
    assert($right_text eq $fixed_text, 
	   "Basic xml_escape() fails; expected $right_text, got $fixed_text ($text)");

    $fixer->add_tagsub('foo', 'strong');
    my $right_text = "Garc&#237;a-L&#243;pez&#8212;what <strong class=\"whatever\">was</strong> he <emph>thinking</emph>? &amp; what could it all mean? &amp; why does &baz; anyone <strong>care</strong>?";
    my $fixed_text = $fixer->xml_escape($text);
    assert($right_text eq $fixed_text,
	   "Basic xml_escape() fails; expected $right_text, got $fixed_text ($text)");

    my $xml = "<!DOCTYPE text [<!ENTITY baz \"&\#10;\">]><text>$fixed_text</text>";
    eval {
	my $twig = XML::Twig->new();
	$twig->parse($xml);
    };
    assert(! $@, "Error trying to parse $xml ($@)");

    eval {
	use XML::LibXML;
	use XML::LibXSLT;
	my $parser = XML::LibXML->new();
	my $xslt = XML::LibXSLT->new();
	my $source = $parser->parse_string($xml);
	my $style_doc = $parser->parse_file('stylesheet.xsl');
	my $stylesheet = $xslt->parse_stylesheet($style_doc);
	my $results = $stylesheet->transform($source);
    };
    assert(! $@, "Error trying to transform $xml ($@)");

    $fixer->add_entity_sub(%XML::EscapeText::HSCML::HSCML_ENTSUBS);
    my $right_text = "Garc&iacute;a-L&oacute;pez&mdash;what <strong class=\"whatever\">was</strong> he <emph>thinking</emph>? &amp; what could it all mean? &amp; why does &baz; anyone <strong>care</strong>?";
    my $fixed_text = $fixer->xml_escape($text);
    assert($right_text eq $fixed_text,
	   "Basic xml_escape() fails; expected $right_text, got $fixed_text ($text)");

}

1;
