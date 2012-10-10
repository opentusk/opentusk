package XML::EscapeText;

use strict;
use base qw(Exporter);
use vars qw(@EXPORT @EXPORT_OK %EXPORT_TAGS %MORON_NAMES %MORON_NUMBERS %LATIN_ENTITIES %NUMBER_NAMES);
use Unicode::String qw(utf8 latin1);

=head1 NAME

B<XML::EscapeText> - a module for escaping text going to or from XML.

=head1 SYNOPSIS

=head2 Utility Functions

    use XML::EscapeText qw(:escape);

    my $text = "This is some text with an & and some <tag> values.";
    my $fixed_text = make_pcdata($text);
    # $fixed_text: "This is some text with an &amp; and some &lt;tag&gt; values."

    $text = "Text with a moron character: and em-dash: \x97 & smart apostrophe: \x92";
    $fixed_text = make_pcdata($text);
    # $fixed_text: 'Text with a moron character: and em-dash: &#8212; &amp; smart \
    #               apostrophe: &#8217;'

    $text = "Garc\xEDa-L\xF3pez";
    $fixed_text = spec_chars_name($text);
    # $fixed_text: "Garc&iacute;a-L&oacute;pez";
    my $fixed_text = spec_chars_number($text);
    # $fixed_text: "Garc&#237;a-L&#243;pez"

=head2 Object-Oriented Escaper

    my $fixer = XML::EscapeText->new();
    $fixer->add_tag(qw(emph strong break));
    $fixer->add_entity('baz');

    $text = "Garc\xEDa-L\xF3pez\x97what <foo class=\"whatever\">was</foo> he ";
    $text .= "<emph>thinking</emph>? & what could it all mean? &amp; why does ";
    $text .= "&baz; anyone <strong>care</strong>?";
    $fixed_text = $fixer->xml_escape($text);
    # $fixed_text: "Garc&#237;a-L&#243;pez&#8212;what &lt;foo \
    #              class=\"whatever\"&gt;was&lt;/foo&gt; he <emph>thinking</emph>? \
    #              &amp; what could it all mean? &amp; why does &baz; anyone \
    #              <strong>care</strong>?"

    $fixer->add_tagsub('foo', 'strong');
    $fixed_text = $fixer->xml_escape($text);
    # $fixed_text = "Garc&#237;a-L&#243;pez&#8212;what <strong \
    #               class=\"whatever\">was</strong> he <emph>thinking</emph>? &amp; \
    #               what could it all mean? &amp; why does &baz; anyone \
    #               <strong>care</strong>?";

=head1 DESCRIPTION

XML::EscapeText has methods and an OO interface for dealing with
problems of including strings in XML documents. Specifically, it
provides methods for dealing with the following issues in text you
might want to put into some XML.

=over

=item *

The text might contain &, E<lt>, or E<gt> characters which would cause
parsing problems.

=item *

The text might contain "moron" characters (that is, characters in the
ASCII range 0x80-0x9f) which should be mapped to either named or
numbered XML entities.

=item *

The text might contain non-"moron" special charactes which you would
like to have mapped either the numbered or named entities.

=item *

The text might be intended to contain I<some> markup, and you would like
to insure that that markup is I<not> escaped.

=back

=head1 EXPORTABLE LISTS AND MAPS

=over

=cut

@EXPORT = ();
@EXPORT_OK = qw( xml_escape make_pcdata
		 demoronise_name demoronise_number
		 demoronize_name demoronize_number
		 spec_chars_name spec_chars_number
		 );

%EXPORT_TAGS = ( escape     => [qw(xml_escape make_pcdata 
				   spec_chars_name spec_chars_number)],
		 entitymaps => [qw(%MORON_NAMES %MORON_NUMBERS %LATIN_ENTITIES)],
		 demoronise => [qw(demoronise_name demoronise_number)],
		 demoronize => [qw(demoronize_name demoronize_number)],
		 );

=item %MORON_NAMES

Maps ASCII codes 0x80 through 0x9f from the CP1252 codes to HTML standard entity names.

=cut

%MORON_NAMES = ( 128 => 'euro',  129 =>'',       130 => 'sbquo',  131 => 'fnof',
		 132 => 'bdquo', 133 =>'hellip', 134 => 'dagger', 135 => 'Dagger',
		 136 => 'circ',  137 =>'permil', 138 => 'Scaron', 139 => 'lsaquo',
		 140 => 'OElig', 141 =>'',       142 => '',       143 => '',
		 144 => '',      145 =>'lsquo',  146 => 'rsquo',  147 => 'ldquo',
		 148 => 'rdquo', 149 =>'bull',   150 => 'ndash',  151 => 'mdash',
		 152 => 'tilde', 153 =>'trade',  154 => 'scaron', 155 => 'rsaquo',
		 156 => 'oelig', 157 =>'',       158 => '',       159 => 'Yuml'    );

{
    my %ALL_NAMES = ( %MORON_NAMES,
		       8364 => 'euro', 8218 => 'sbquo', 402 => 'fnof',
		       8222 => 'bdquo', 8230 => 'hellip', 8224 => 'dagger', 8225 => 'Dagger',
		       710 => 'circ', 8240 => 'permil', 352 => 'Scaron', 8249 => 'lsaquo',
		       338 => 'OElig',
		       8216 => 'lsquo', 8217 => 'rsquo', 8220 => 'ldquo',
		       8221 => 'rdquo', 8226 => 'bull', 8211 => 'ndash', 8212 => 'mdash',
		       732 => 'tilde', 8482 => 'trade', 353 => 'scaron', 8250 => 'rsaquo',
		       339 => 'oelig', 376 => 'Yuml' );
    while (my ($key, $val) = each %ALL_NAMES) {
	my @numbers = map { ord } ('&', split(//, $val), ';');
	$NUMBER_NAMES{$key} = \@numbers;
    }
}

=item %MORON_NUMBERS

Maps ASCII codes 0x80 through 0x9f from the CP1252 codes to Unicode standard codes.

=cut

%MORON_NUMBERS = ( 128 => 8364, 129 =>  129, 130 => 8218, 131 =>  402,
		   132 => 8222, 133 => 8230, 134 => 8224, 135 => 8225,
		   136 =>  710, 137 => 8240, 138 =>  352, 139 => 8249,
		   140 =>  338, 141 =>  141, 142 =>  381, 143 =>  143,
		   144 =>  144, 145 => 8216, 146 => 8217, 147 => 8220,
		   148 => 8221, 149 => 8226, 150 => 8211, 151 => 8212,
		   152 =>  732, 153 => 8482, 154 =>  353, 155 => 8250,
		   156 =>  339, 157 =>  157, 158 =>  382, 159 =>  376  );

=item %LATIN_ENTITIES

Maps ASCII codes 0xa0 through 0xff to HTML standard entity names.

=cut

%LATIN_ENTITIES = ( "A1" => "iexcl",  "A2" => "cent",   "A3" => "pound",
		    "A4" => "curren", "A5" => "yen",    "A6" => "brvbar",
		    "A7" => "sect",   "A9" => "copy",   "AA" => "ordf",
		    "AB" => "laquo",  "B0" => "deg",    "B1" => "plusmn",
		    "B2" => "sup2",   "B3" => "sup3",   "B5" => "micro",
		    "B6" => "para",   "B7" => "middot", "B9" => "sup1",
		    "BA" => "ordm",   "BB" => "raquo",  "BC" => "frac14",
		    "BD" => "frac12", "BE" => "frac34", "BF" => "iquest",
		    "C0" => "Agrave", "C1" => "Aacute", "C2" => "Acirc",
		    "C3" => "Atilde", "C4" => "Auml",   "C5" => "Aring",
		    "C6" => "AElig",  "C7" => "Ccedil", "C8" => "Egrave",
		    "C9" => "Eacute", "CA" => "Ecirc",  "CB" => "Euml",
		    "CC" => "Igrave", "CD" => "Iacute", "CE" => "Icirc",
		    "CF" => "Iuml",   "D0" => "ETH",    "D1" => "Ntilde",
		    "D2" => "Ograve", "D3" => "Oacute", "D4" => "Ocirc",
		    "D5" => "Otilde", "D6" => "Ouml",   "D7" => "times",
		    "D8" => "Oslash", "D9" => "Ugrave", "DA" => "Uacute",
		    "DB" => "Ucirc",  "DC" => "Uuml",   "DD" => "Yacute",
		    "DE" => "THORN",  "DF" => "szlig",  "AE" => "reg",
		    "E0" => "agrave", "E1" => "aacute", "E2" => "acirc",
		    "E3" => "atilde", "E4" => "auml",   "E5" => "aring",
		    "E6" => "aelig",  "E7" => "ccedil", "E8" => "egrave",
		    "E9" => "eacute", "EA" => "ecirc",  "EB" => "euml",
		    "EC" => "igrave", "ED" => "iacute", "EE" => "icirc",
		    "EF" => "iuml",   "F0" => "eth",    "F1" => "ntilde",
		    "F2" => "ograve", "F3" => "oacute", "F4" => "ocirc",
		    "F5" => "otilde", "F6" => "ouml",   "F7" => "divide",
		    "F8" => "oslash", "F9" => "ugrave", "FA" => "uacute",
		    "FB" => "ucirc",  "FC" => "uuml",   "FD" => "yacute",
		    "FE" => "thorn",  "FF" => "yuml",
		    );
while (my ($key, $val) = each %LATIN_ENTITIES) {
    my @numbers = map { ord } ('&', split(//, $val), ';');
    $NUMBER_NAMES{hex($key)} = \@numbers;
}

=back

=cut

# an array of all possible HTML tags.
my @html_tags = qw(a abbrev acronym address applet area au author b banner base basefont 
		   bgsound big blink blockquote bq body br caption center cite code col 
		   colgroup credit del dfn dir div dl dt dd em embed fig fn font form frame 
		   frameset h1 h2 h3 h4 h5 h6 head hr html i iframe img input ins isindex 
		   kbd lang lh li link listing map marquee math menu meta multicol nobr 
		   noframes note ol overlay p param person plaintext pre q range samp script 
		   select small spacer spot strike strong sub sup tab table tbody td textarea 
		   textflow tfoot th thead title tr tt u ul var wbr xmp);

sub moron_to_num_entity {
    # Take a (moron) character, and give back a numbered entity
    my $char = shift;
    my $number = ord $char;
    if ($MORON_NUMBERS{$number}) { 
	return "\&\#$MORON_NUMBERS{$number}\;";
    }
    return '';
}

sub moron_to_name_entity {
    # Take a (moron) character, and give back a named entity, or a numbered one if
    # we don't know one.
    my $char = shift;
    my $number = ord $char;
    if ($MORON_NAMES{$number}) { 
	return "\&$MORON_NAMES{$number}\;";
    }
    elsif ($MORON_NUMBERS{$number}) { 
	return "\&\#$MORON_NUMBERS{$number}\;";
    }
    return '';
}

=head1 UTILITY FUNCTIONS

=over

=item demoronise_name()

Takes a string or a list of strings and returns the string with its
"moron" characters replaced with HTML-standard named entities.

=cut

sub demoronise_name {
    # Take a string and transform moron characters to named entities
    my @out = ();
    while (my $text = shift) {
	$text =~ s{([\x80-\x9f])} {moron_to_name_entity($1)}ge;
	push @out, $text;
    }
    return wantarray ? @out : ($out[0] || '');
}

=item demoronize_name()

Synonym for C<demoronise_name()>.

=cut

sub demoronize_name { return demoronise_name(@_) }

=item demoronise_number()

Takes a string or a list of strings and returns the string with its
"moron" characters replaced with numbered entities.

=cut

sub demoronise_number {
    # Take a string and transform moron characters to numbered entities
    my @out = ();
    while (my $text = shift) {
	$text =~ s{([\x80-\x9f])} {moron_to_num_entity($1)}ge;
	push @out, $text;
    }
    return wantarray ? @out : ($out[0] || '');
}

=item demoronize_number()

Synonym for C<demoronise_number()>.

=cut

sub demoronize_number { return demoronise_number(@_) }

sub char_to_name_entity {
    # Take a character and return a named entity for it, if we have one
    my $char = shift;
    my $key = sprintf("%X", ord($char));
    return "\&$LATIN_ENTITIES{$key}\;" || char_to_num_entity($char);
}

sub char_to_num_entity {
    # Take a chracters and return a numbered entity for it
    my $char = shift;
    my $key = ord($char);
    return "\&\#$key\;";
}

sub make_spec_char_translate {
    my $num_to_ords = shift;
    die "Must give a CODE ref to make_spec_char_translate()"
      unless $num_to_ords && ref $num_to_ords eq 'CODE';
    return sub {
	# my @in = demoronise_name(@_);
	my $encodingre = qr/(latin1|utf8|utf7)/;
	my $encoding = 'utf8';
	if ($_[-1] =~ $encodingre) { $encoding = pop @_ }
	*encoding_sub = $Unicode::String::{$encoding};
	my @out = ();
	while (my $text = shift @_) {
	    next unless $text;
	    $text = &encoding_sub($text);
	    my @outchars = ();
	    for ($text->unpack()) {
		if ($_ < 32 and $_ != 9 and $_ != 10) { next } # pass line returns and tabs but throw away all other non-displayed chars
		elsif ($_ < 128) {
		    push @outchars, $_;
		    next;
		}
		elsif ($_ >= 128 && $_ <= 159) {
		    $_ = $MORON_NUMBERS{$_};
		}
		push @outchars, &$num_to_ords($_);
	    }
	    $text->pack(@outchars);
	    push @out, $text->utf8();
	}
	return wantarray ? @out : ($out[0] || '');
    };
}

sub _num_to_num_ent_ords { return map { ord } ('&', '#', split(//, $_[0]), ';') }

*spec_chars_name = 
  make_spec_char_translate( sub {
				return @{$NUMBER_NAMES{$_[0]}} if ($NUMBER_NAMES{$_[0]});
				goto &_num_to_num_ent_ords;
			    }
			  );


=item spec_chars_name()

Takes a string or a list of strings and returns the strings with all
characters greater than ASCII 127 transformed into HTML-standard named
entities.

=cut

=item spec_chars_number()

Takes a string or a list of strings and returns the strings with all
characters greater than ASCII 127 transformed into numbered entities.

=cut

#  sub spec_chars_number {
#      my @in = demoronise_number(@_);
#      my @out = ();
#      while (my $text = shift @in) {
#  	$text =~ s{([\xA0-\xFF])} {char_to_num_entity($1)}ge;
#  	push @out, $text;
#      }
#      return wantarray ? @out : ($out[0] || '');
#  }

*spec_chars_number = make_spec_char_translate(\&_num_to_num_ent_ords);


=item do_xml_escape()

Takes a string and turns its &, E<lt>, and E<gt> characters into
C<&amp;>, C<&lt;>, and C<&gt;>, respectively. Note that it spares
ampersands which are already part of one of C<&amp;>, C<&lt;>, and
C<&gt;> or a numbered entity.

=cut

sub do_xml_escape {
    my @out = ();
    while (my $text = shift) {
	$text =~ tr/\cM/\n/;
	$text =~ s{&(?!(?:amp|lt|gt|\#\d+|\#x[a-f0-9]+);)}{&amp;}gs;
	$text =~ s{<(?!\?)}{&lt;}gs;
	$text =~ s{(?<!\?)>}{&gt;}gs;
	push @out, $text;
    }
    return wantarray ? @out : ($out[0] || '');
}

=item make_pcdata()

Takes a string or list of strings, demoronises it to numbered entities
(using C<demoronise_number()>), and escapes special characteres (using
<do_xml_escape()>). The resulting string is usually safe for including
in an XML #PCDATA element. (Markup will be ruined by the XML escaping).

=cut

sub make_pcdata {
    my @out = demoronise_number(@_);
    @out = do_xml_escape(@out);
    return wantarray ? @out : ($out[0] || '');
}

=back

=head1 OBJECT-ORIENTED INTERFACE

The object-oriented interface is designed for escaping text which may
contain some allowed markup. An C<XML::EscapeText> object is created,
and allowed tags and entities are specified. In addition, tag
substitutions may be specified. This object can then be used to escape
markup-containg text while sparing the allowed tags/entities.

=over

=cut

=item new()

Creates a new C<XML::EscapeText> object.

=cut

sub new {
    my $class = shift;
    $class = ref $class || $class;
    my $self = { 
	-tags => [ ],
	-tagsubs => { '!DOCTYPE' => '!-- --' },
	-entities => [],
	-entity_subs => {},
	-mutable => 1,
    };
    bless $self, $class;
    return $self;
}

=item add_tag()

Sets tags (without E<lt> and E<gt>) which should be spared escaping.

=cut

sub add_tag {
    my $self = shift;
    die "Object is immutable" unless $self->is_mutable();
    while (my $tag = shift @_) {
	# Make sure it's an acceptable tag name; this is a close approximation
	next unless $tag =~ /^\w\S*$/;
	push @{$self->{-tags}}, $tag;
    }
}

=item add_html_tags()

Spares all html tags from escaping.

=cut

sub add_html_tags() {
    my $self = shift;
    die "Object is immutable" unless $self->is_mutable();
    push @{$self->{-tags}},@html_tags;
}

=item get_tags()

Gets the tags which are to be spared.

=cut

sub get_tags {
    my $self = shift;
    return @{$self->{-tags}};
}

=item add_entity()

Adds named entities which should be spared escaping.

=cut

sub add_entity {
    my $self = shift;
    die "Object is immutable" unless $self->is_mutable();
    while (my $entity = shift @_) {
	# Make sure it's an acceptable entity name; this is a close approximation
	next unless $entity =~ /^\w\S*$/;
	push @{$self->{-entities}}, $entity;
    }
}

=item get_entities()

Gets the names of the entities which will be spared.

=cut

sub get_entities {
    my $self = shift;
    return @{$self->{-entities}};
}

=item add_entity_sub()

Adds a mapping between a Unicode character code and a named
entity. Note that the character code must be larger than 128.

=cut

sub add_entity_sub {
    my $self = shift;
    die "Object is immutable" unless $self->is_mutable();
    my %entsubs = @_;
    while (my ($code, $entity) = each %entsubs) {
	next unless $code > 128;
	next unless $entity =~ /^\w\S*$/;
	$self->{-entity_subs}{$code} = $entity;
	push @{$self->{-entities}}, $entity unless grep { $_ eq $entity } @{$self->{-entities}};
    }
}

=item get_entsubref()

Returns a reference to the hash of substitutions from Unicode
character codes to named entities.

=cut

sub get_entsubref {
    my $self = shift;
    return $self->{-entity_subs};
}

=item add_tagsub()

Add a tag substitution definition. This consists of a tag that might
be found in input text and the tag which should be
substituted. Attributes will be copied directly into the substituted
tag. Only a straight tag name is acceptable as the tag. If the
substitution value is "C<!-- -->", then the tags will be commented out
wherever they appear. The substitution may also include attributes to
be added.

=cut

sub add_tagsub {
    my $self = shift;
    die "Object is immutable" unless $self->is_mutable();
    my %tagsubs = @_;
    while (my ($tag, $sub) = each %tagsubs) {
	next unless $tag =~ /^\w\S*$/;
	next unless $sub;
	$self->{-tagsubs}{$tag} = $sub;
    }
}

=item get_tagsubref()

Gets a reference to the hash of tag substitutions to be performed.

=cut

sub get_tagsubref {
    my $self = shift;
    return $self->{-tagsubs};
}

=item make_immutable()

Makes the object immutable such that its tags, entities, and
substitutions cannot be changed.

=cut

sub make_immutable {
    my $self = shift;
    return unless $self->{-mutable};
    $self->{-mutable} = 0;
}

=item is_mutable()

Returns a true value if the object can be changed.

=cut

sub is_mutable() {
    my $self = shift;
    return $self->{-mutable};
}

=item clone()

Returns a mutable copy of this object.

=cut

sub clone {
    my $self = shift;
    my $clone = $self->new();
    $clone->add_tag($self->get_tags());
    $clone->add_entity($self->get_entities());
    $clone->add_tagsub(%{$self->get_tabsubref});
    return $clone;
}

sub do_fix_tag {
    my $text = shift;
    return unless $text && $text =~ /\S/;
    my $tag = shift;
    my $sub = shift;
    $sub ||= $tag;

    no warnings; # Ignore "Use of uninitialized value in concatenation (.) or string" warnings

    # Commenting a tag out
    if ($sub eq '!-- --') {
	$text =~ s{&lt;(/)?$tag(/)?&gt;} {<!-- $1$tag$2 -->}g;
	$text =~ s{&lt;$tag\s([^\&]+)\&gt;} {<!-- $tag $1 -->}sg;
	return $text;
    }

    if (my ($subtag, $subatts) = $sub =~ /^(\S+)\s(.+)$/) {
	$text =~ s{&lt;$tag&gt;} {<$sub>}g;
	$text =~ s{&lt;/$tag&gt;} {</$subtag>}g;
	$text =~ s{&lt;$tag\s([^\&]+)\&gt;} {<$sub $1>}sg;
	return $text;
    }

    # There might be a problem here if there's complicated stuff in the attributes.
    $text =~ s{&lt;(/)?$tag(/)?&gt;} {<$1$sub$2>}g;
    $text =~ s{&lt;$tag\s([^\&]+)\&gt;} {<$sub $1>}sg;
    return $text;
}

=item xml_escape()

Takes an input string and escapes it for XML, sparing tags and
entities and making substitutions as defined.

=back

=cut

sub xml_escape {
    my $self = shift;
    unless (ref $self && $self->isa('XML::EscapeText')) {
	return make_pcdata($self);
    }

    my $text = shift;
    my $encoding = shift || 'utf8';

    # if ($self->get_entities()) {
    #     $text = spec_chars_name($text, $encoding);
    # }
    # else {
    $text = spec_chars_number($text, $encoding);
    # }
    $text = do_xml_escape($text);
    while (my ($code, $ent) = each %{$self->get_entsubref()}) {
	my $code_re = sprintf("&#(%d|x%x|x%X);", $code, $code, $code);
	$text =~ s/$code_re/&$ent\;/g;
    }

    # Fix all of the acceptable named entities
    my $ent_re = join('|', $self->get_entities());
    $text =~ s|&amp;($ent_re)\;|&$1\;|g;

    # Fix all of the acceptable tags
    for my $tag ($self->get_tags()) {
	$text = do_fix_tag($text, $tag);
    }

    # Now, do all of the tag substitutions
    while (my ($tag, $sub) = each %{$self->get_tagsubref()}) {
	$text = do_fix_tag($text, $tag, $sub);
    }

    return $text;
}

=head1 EXPORTS

=over

=item :escape

C<xml_escape()>, C<make_pcdata()>, C<spec_chars_name()>, C<spec_chars_number()>

=item :entitymaps

C<%MORON_NAMES>, C<%MORON_NUMBERS>,  C<%LATIN_ENTITIES>

=item :demoronise

C<demoronise_name()>, C<demoronise_number()>

=item :demoronize

C<demoronize_name()>, C<demoronize_number()>

=back

=head1 BUGS/ISSUES

One problem (especially in tag substitution) is that attributes get
copied over without any particular thought.

=head1 AUTHOR

Tarik Alkasab, tarik.alkasab@tufts.edu

=cut

1;

__END__
