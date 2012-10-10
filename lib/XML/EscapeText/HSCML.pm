package XML::EscapeText::HSCML;
# $Id: HSCML.pm,v 1.6 2005-05-11 15:39:38 bkessler Exp $
use strict;
use XML::EscapeText;
use base qw(Exporter);
use vars qw($VERSION @EXPORT @EXPORT_OK %EXPORT_TAGS 
	    @HSCML_ENTITIES %HSCML_ENTSUBS @REF_TAGS @GRAPHIC_TAGS @EMPH_TAGS @OTHER_INLINE_TAGS 
	    @LIMITED_INLINE_TAGS @INLINE_TAGS 
	    @LIST_TAGS @TABLE_TAGS @BLOCK_TAGS @LIMITED_BLOCK_TAGS @FLOW_TAGS @LIMITED_FLOW_TAGS 
	    @STRUCTURE_TAGS @HEADER_TAGS @HSCML_BODY_TAGS @HSCML_TAGS
	    %HTML_TO_HSCML_INLINE %HTML_TO_HSCML_FLOW
	    $hscml_all $hscml_flow $hscml_inline $hscml_limited_inline $hscml_limited_flow
	    $html_inline $html_flow);

$VERSION = do { my @r = (q$Revision: 1.6 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

@EXPORT = ();
@EXPORT_OK = qw(@HSCML_ENTITIES %HSCML_ENTSUBS @INLINE_TAGS @BLOCK_TAGS @FLOW_TAGS @HSCML_TAGS
		%HTML_TO_HSCML_INLINE %HTML_TO_HSCML_FLOW
		$hscml_all $hscml_flow $hscml_inline $hscml_limited_inline 
		$hscml_limited_flow $html_inline $html_flow);
%EXPORT_TAGS = (all => [qw($hscml_all $hscml_flow $hscml_inline $hscml_limited_inline 
			   $hscml_limited_flow $html_inline $html_flow)],
		hscml => [qw($hscml_all $hscml_flow $hscml_inline $hscml_limited_inline 
			     $hscml_limited_flow)],
		html => [qw($html_inline $html_flow)],
		tags => [qw(@HSCML_ENTITIES %HSCML_ENTSUBS @INLINE_TAGS @BLOCK_TAGS @FLOW_TAGS
                            @HSCML_BODY_TAGS @HEADER_TAGS @HSCML_TAGS)],
		tagsub => [qw(%HTML_TO_HSCML_INLINE %HTML_TO_HSCML_FLOW)],
		);

=head1 NAME

B<XML::EscapeText::HSCML> - Convenience defintions for escaping text for HSCML

=head1 SYNOPSIS

    use XML::EscapeText::HSCML;

    my ($in_text, $right_text, $out_text);
    $in_text = "<i>How\x92d I such & such?</i>";
    $out_text = $XML::EscapeText::HSCML::html_inline->xml_escape($in_text);
    # $out_text: "<emph>How&#8217;d I such &amp; such?</emph>"

=head1 DESCRIPTION

General methods for escaping text for XML are found in B<XML::EscapeText> (L<XML::EscapeText>). B<XML::EscapeText::HSCML> defines methods for escaping text for use in XML files conforming to the Health Sciences Curricular Markup Language (HSCML). Therefore, its escaping spares tags found in HSCML, and maps HTML-like tags to HSCML analogues.

In addition, it defines useful lists of HSCML elements and entities.

=head2 LIST DEFINITIONS

=over

=item @HSCML_ENTITIES

A list of all of the text entities defined in HSCML.

=cut

@HSCML_ENTITIES = qw(nbsp iexcl cent pound curren yen brvbar sect uml copy ordf 
		     laquo not shy reg macr deg plusmn sup2 sup3 acute micro para
		     middot cedil sup1 ordm raquo frac14 frac12 frac34 iquest Agrave
		     Aacute Acirc Atilde Auml Aring AElig Ccedil Egrave Eacute Ecirc
		     Euml Igrave Iacute Icirc Iuml ETH Ntilde Ograve Oacute Ocirc 
		     Otilde Ouml times Oslash Ugrave Uacute Ucirc Uuml Yacute THORN
		     szlig agrave aacute acirc atilde auml aring aelig ccedil egrave
		     eacute ecirc euml igrave iacute icirc iuml eth ntilde ograve 
		     oacute ocirc otilde ouml divide oslash ugrave uacute ucirc uuml 
		     yacute thorn yuml OElig oelig Scaron scaron Yuml circ tilde ensp
		     emsp thinsp zwnj zwj lrm rlm ndash mdash lsquo rsquo sbquo ldquo
		     rdquo bdquo dagger Dagger permil lsaquo rsaquo euro fnof Alpha 
		     Beta Gamma Delta Epsilon Zeta Eta Theta Iota Kappa Lambda Mu 
		     Nu Xi Omicron Pi Rho Sigma Tau Upsilon Phi Chi Psi Omega 
		     alpha beta gamma delta epsilon zeta eta theta iota kappa lambda 
		     mu nu xi omicron pi rho sigmaf sigma tau upsilon phi chi psi 
		     omega thetasym upsih piv bull hellip prime Prime oline frasl 
		     weierp image real trade alefsym larr uarr rarr darr harr crarr
		     lArr uArr rArr dArr hArr forall part exist empty nabla isin
		     notin ni prod sum minus lowast radic prop infin ang and or cap
		     cup int there4 sim cong asymp ne equiv le ge sub sup nsub sube
		     supe oplus otimes perp sdot lceil rceil lfloor rfloor lang rang 
		     loz spades clubs hearts diams liter co lbbar rx ounce mho frac18
		     frac38 frac58 frac78 frac13 frac23 nwarr nearr searr swarr 
		     acwharp cwharp luharp ldharp urharp ulharp ruharp rdharp drharp
		     dlharp rolarr lorharp rolharp ubdarr lorarr because male female
		     benzene smsqu smtri blsqu bltri blcir bldia);

%HSCML_ENTSUBS = ( 160 => 'nbsp',      161 => 'iexcl',     162 => 'cent',      163 => 'pound',
		   164 => 'curren',    165 => 'yen',       166 => 'brvbar',    167 => 'sect',
		   168 => 'uml',       169 => 'copy',      170 => 'ordf',      171 => 'laquo',
		   172 => 'not',       173 => 'shy',       174 => 'reg',       175 => 'macr',
		   176 => 'deg',       177 => 'plusmn',    178 => 'sup2',      179 => 'sup3',
		   180 => 'acute',     181 => 'micro',     182 => 'para',      183 => 'middot',
		   184 => 'cedil',     185 => 'sup1',      186 => 'ordm',      187 => 'raquo',
		   188 => 'frac14',    189 => 'frac12',    190 => 'frac34',    191 => 'iquest',
		   192 => 'Agrave',    193 => 'Aacute',    194 => 'Acirc',     195 => 'Atilde',
		   196 => 'Auml',      197 => 'Aring',     198 => 'AElig',     199 => 'Ccedil',
		   200 => 'Egrave',    201 => 'Eacute',    202 => 'Ecirc',     203 => 'Euml',
		   204 => 'Igrave',    205 => 'Iacute',    206 => 'Icirc',     207 => 'Iuml',
		   208 => 'ETH',       209 => 'Ntilde',    210 => 'Ograve',    211 => 'Oacute',
		   212 => 'Ocirc',     213 => 'Otilde',    214 => 'Ouml',      215 => 'times',
		   216 => 'Oslash',    217 => 'Ugrave',    218 => 'Uacute',    219 => 'Ucirc',
		   220 => 'Uuml',      221 => 'Yacute',    222 => 'THORN',     223 => 'szlig',
		   224 => 'agrave',    225 => 'aacute',    226 => 'acirc',     227 => 'atilde',
		   228 => 'auml',      229 => 'aring',     230 => 'aelig',     231 => 'ccedil',
		   232 => 'egrave',    233 => 'eacute',    234 => 'ecirc',     235 => 'euml',
		   236 => 'igrave',    237 => 'iacute',    238 => 'icirc',     239 => 'iuml',
		   240 => 'eth',       241 => 'ntilde',    242 => 'ograve',    243 => 'oacute',
		   244 => 'ocirc',     245 => 'otilde',    246 => 'ouml',      247 => 'divide',
		   248 => 'oslash',    249 => 'ugrave',    250 => 'uacute',    251 => 'ucirc',
		   252 => 'uuml',      253 => 'yacute',    254 => 'thorn',     255 => 'yuml',
		   338 => 'OElig',     339 => 'oelig',     352 => 'Scaron',    353 => 'scaron',
		   376 => 'Yuml',      710 => 'circ',      732 => 'tilde',    8194 => 'ensp',
		   8195 => 'emsp',     8201 => 'thinsp',   8204 => 'zwnj',     8205 => 'zwj',
		   8206 => 'lrm',      8207 => 'rlm',      8211 => 'ndash',    8212 => 'mdash',
		   8216 => 'lsquo',    8217 => 'rsquo',    8218 => 'sbquo',    8220 => 'ldquo',
		   8221 => 'rdquo',    8222 => 'bdquo',    8224 => 'dagger',   8225 => 'Dagger',
		   8240 => 'permil',   8249 => 'lsaquo',   8250 => 'rsaquo',   8364 => 'euro',
		   402 => 'fnof',      913 => 'Alpha',     914 => 'Beta',      915 => 'Gamma',
		   916 => 'Delta',     917 => 'Epsilon',   918 => 'Zeta',      919 => 'Eta',
		   920 => 'Theta',     921 => 'Iota',      922 => 'Kappa',     923 => 'Lambda',
		   924 => 'Mu',        925 => 'Nu',        926 => 'Xi',        927 => 'Omicron',
		   928 => 'Pi',        929 => 'Rho',       931 => 'Sigma',     932 => 'Tau',
		   933 => 'Upsilon',   934 => 'Phi',       935 => 'Chi',       936 => 'Psi',
		   937 => 'Omega',     945 => 'alpha',     946 => 'beta',      947 => 'gamma',
		   948 => 'delta',     949 => 'epsilon',   950 => 'zeta',      951 => 'eta',
		   952 => 'theta',     953 => 'iota',      954 => 'kappa',     955 => 'lambda',
		   956 => 'mu',        957 => 'nu',        958 => 'xi',        959 => 'omicron',
		   960 => 'pi',        961 => 'rho',       962 => 'sigmaf',    963 => 'sigma',
		   964 => 'tau',       965 => 'upsilon',   966 => 'phi',       967 => 'chi',
		   968 => 'psi',       969 => 'omega',     977 => 'thetasym',  978 => 'upsih',
		   982 => 'piv',       8226 => 'bull',     8230 => 'hellip',   8242 => 'prime',
		   8243 => 'Prime',    8254 => 'oline',    8260 => 'frasl',    8472 => 'weierp',
		   8465 => 'image',    8476 => 'real',     8482 => 'trade',    8501 => 'alefsym',
		   8592 => 'larr',     8593 => 'uarr',     8594 => 'rarr',     8595 => 'darr',
		   8596 => 'harr',     8629 => 'crarr',    8656 => 'lArr',     8657 => 'uArr',
		   8658 => 'rArr',     8659 => 'dArr',     8660 => 'hArr',     8704 => 'forall',
		   8706 => 'part',     8707 => 'exist',    8709 => 'empty',    8711 => 'nabla',
		   8712 => 'isin',     8713 => 'notin',    8715 => 'ni',       8719 => 'prod',
		   8721 => 'sum',      8722 => 'minus',    8727 => 'lowast',   8730 => 'radic',
		   8733 => 'prop',     8734 => 'infin',    8736 => 'ang',      8743 => 'and',
		   8744 => 'or',       8745 => 'cap',      8746 => 'cup',      8747 => 'int',
		   8756 => 'there4',   8764 => 'sim',      8773 => 'cong',     8776 => 'asymp',
		   8800 => 'ne',       8801 => 'equiv',    8804 => 'le',       8805 => 'ge',
		   8834 => 'sub',      8835 => 'sup',      8836 => 'nsub',     8838 => 'sube',
		   8839 => 'supe',     8853 => 'oplus',    8855 => 'otimes',   8869 => 'perp',
		   8901 => 'sdot',     8968 => 'lceil',    8969 => 'rceil',    8970 => 'lfloor',
		   8971 => 'rfloor',   9001 => 'lang',     9002 => 'rang',     9674 => 'loz',
		   9824 => 'spades',   9827 => 'clubs',    9829 => 'hearts',   9830 => 'diams',
		   8467 => 'liter',    8453 => 'co',       8468 => 'lbbar',    8478 => 'rx',
		   8485 => 'ounce',    8487 => 'mho',      8539 => 'frac18',   8540 => 'frac38',
		   8541 => 'frac58',   8542 => 'frac78',   8531 => 'frac13',   8532 => 'frac23',
		   8598 => 'nwarr',    8599 => 'nearr',    8600 => 'searr',    8601 => 'swarr',
		   8634 => 'acwharp',  8635 => 'cwharp',   8636 => 'luharp',   8637 => 'ldharp',
		   8638 => 'urharp',   8639 => 'ulharp',   8640 => 'ruharp',   8641 => 'rdharp',
		   8642 => 'drharp',   8643 => 'dlharp',   8644 => 'rolarr',   8651 => 'lorharp',
		   8652 => 'rolharp',  8645 => 'ubdarr',   8646 => 'lorarr',   8757 => 'because',
		   9794 => 'male',     9792 => 'female',   9004 => 'benzene',  9642 => 'smsqu',
		   9662 => 'smtri',    9632 => 'blsqu',    9660 => 'bltri',    9679 => 'blcir',
		   9670 => 'bldia',
		 );


@REF_TAGS = qw(umls-concept hsdb-cite-content web-cite index-item objective-item 
	       user-ref non-user-ref course-ref date-ref place-ref biblio-ref);
@GRAPHIC_TAGS = qw(web-graphic hsdb-graphic);
@EMPH_TAGS = qw(nugget topic-sentence summary keyword);
@OTHER_INLINE_TAGS = qw(span strong emph foreign species media warning sub super 
			verbatim linebreak);

=item @LIMITED_INLINE_TAGS

Inline tags including reference tags, emphasis tags, and general inline tags. Does I<not> include graphics.

=cut

@LIMITED_INLINE_TAGS = (@REF_TAGS, @EMPH_TAGS, @OTHER_INLINE_TAGS);

=item @INLINE_TAGS

All of the inline-level tags for HSCML.

=cut

@INLINE_TAGS = (@REF_TAGS, @GRAPHIC_TAGS, @EMPH_TAGS, @OTHER_INLINE_TAGS);

@LIST_TAGS = qw(enumerated-list itemized-list outline-list definition-list 
		list-title list-item definition-term definition-data);
@TABLE_TAGS = qw(table thead tfoot tbody colgroup col tr th td);

=item @BLOCK_TAGS

All of the block-level tags for HSCML.

=cut

@BLOCK_TAGS = (qw(pagebreak para block-quote equation figure hsdb-cite-include caption),
	       @LIST_TAGS, @TABLE_TAGS);
@STRUCTURE_TAGS = qw(section-level-1 section-level-2 section-level-3 section-level-4
		     section-level-5 section-title);

=item @LIMITED_BLOCK_TAGS

A small subset of the block-level tags for HSCML.

=cut

@LIMITED_BLOCK_TAGS = qw( para );

=item @FLOW_TAGS

General text tags in HSCML: C<@BLOCK_TAGS> and C<@INLINE_TAGS>.

=cut

@FLOW_TAGS = (@BLOCK_TAGS, @INLINE_TAGS);

=item @LIMITED_FLOW_TAGS

The general text tags in HSCML without the graphics tags.

=cut

@LIMITED_FLOW_TAGS = (@LIST_TAGS, @TABLE_TAGS, @LIMITED_INLINE_TAGS, @LIMITED_BLOCK_TAGS);

=item @HSCML_BODY_TAGS

All of the HSCML tags in a body.

=cut

@HSCML_BODY_TAGS = (@INLINE_TAGS, @BLOCK_TAGS, @STRUCTURE_TAGS);

=item @HEADER_TAGS

All of the tags which appear in an HSCML header.

=cut

@HEADER_TAGS = qw(title author contact-person editor creation-date modified-history status-history
                  header-keyword mime-type acknowledgement source copyright collection-list 
                  header-objective-item user-identifier non-user-identifier non-user status 
                  status-date assigner status-note copyright-text copyright-structure 
                  copyright-owner copyright-years member-of);

=item @HSCML_TAGS

All HSCML tags, regardless of how they work.

=cut

@HSCML_TAGS = ('content', 'header', 'db-content', 'brief-header', 'associated-data', 'body',
	       @HEADER_TAGS, @HSCML_BODY_TAGS);

=item %HTML_TO_HSCML_INLINE

Mappings of HTML inline tags to HSCML tags for use in C<XML::EscapeText> objects.

=cut

%HTML_TO_HSCML_INLINE = (b => 'strong', B => 'strong', STRONG => 'strong',
			 i => 'emph', I => 'emph', em => 'emph', EM => 'emph',
			 u => 'span style="text-decoration: underline"',
			 img => 'web-graphic',
			 U => 'span style="text-decoration: underline"',
			 br => 'linebreak/', BR => 'linebreak/',
			 h1 => 'strong class="h1"', H1 => 'strong class="h1"', 
			 h2 => 'strong class="h2"', H2 => 'strong class="h2"', 
			 h3 => 'strong class="h3"', H3 => 'strong class="h3"', 
			 h4 => 'strong class="h4"', H4 => 'strong class="h4"', 
			 h5 => 'strong class="h5"', H5 => 'strong class="h5"', 
			 h6 => 'strong class="h6"', H6 => 'strong class="h6"', 
			 );

=item %HTML_TO_HSCML_FLOW

Mappings of HTML flow tags to HSCML tags for use in C<XML::EscapeText> objects.

=cut

%HTML_TO_HSCML_FLOW = (%HTML_TO_HSCML_INLINE,
		       div => '!-- --', center => '!-- --',
		       p => 'para', 'P' => 'para',
		       HR => 'pagebreak/', hr => 'pagebreak/',
		       TABLE => 'table', TR => 'tr', TD => 'td', TH => 'th',
		       ul => 'itemized-list', UL => 'itemized-list', 
		       ol => 'enumerated-list', OL => 'enumerated-list',
		       li => 'list-item', LI => 'list-item',
		       dl => 'definition-list', DL => 'definition-list',
		       dt => 'definition-term', DT => 'definition-term', 
		       dd => 'definition-data', DD => 'definition-data', 
		       a => 'web-cite');

=back

=head2 Predefined C<XML::EscapeText> Objects

=over

=item $hscml_all

An C<XML::EscapeText> which protects C<all> HSCML tags and entities.

=cut

$hscml_all = XML::EscapeText->new();
$hscml_all->add_entity(@HSCML_ENTITIES);
$hscml_all->add_entity_sub(%HSCML_ENTSUBS);
$hscml_all->add_tag(@HSCML_TAGS);
$hscml_all->make_immutable();

=item $hscml_flow

An C<XML::EscapeText> which protects HSCML flow tags and entities.

=cut

$hscml_flow = XML::EscapeText->new();
$hscml_flow->add_entity(@HSCML_ENTITIES);
$hscml_flow->add_entity_sub(%HSCML_ENTSUBS);
$hscml_flow->add_tag(@FLOW_TAGS);
$hscml_flow->make_immutable();

=item $hscml_inline

An C<XML::EscapeText> which protects HSCML inline tags and entities.

=cut

$hscml_inline = XML::EscapeText->new();
$hscml_inline->add_entity(@HSCML_ENTITIES);
$hscml_inline->add_entity_sub(%HSCML_ENTSUBS);
$hscml_inline->add_tag(@INLINE_TAGS);
$hscml_inline->make_immutable();

=item $hscml_limited_inline

An C<XML::EscapeText> which protects a subset of HSCML inline tags and I<no> entities.

=cut

$hscml_limited_inline = XML::EscapeText->new();
$hscml_limited_inline->add_tag(@LIMITED_INLINE_TAGS);
$hscml_limited_inline->make_immutable();

=item $hscml_limited_flow

An C<XML::EscapeText> which protects a subset of HSCML flow tags and I<no> entities.

=cut

$hscml_limited_flow = XML::EscapeText->new();
$hscml_limited_flow->add_tag(@LIMITED_FLOW_TAGS);
$hscml_limited_flow->make_immutable();

=item $html_inline

An C<XML::EscapeText> which protects a subset of HSCML inline tags,
translates inline HTML tags to HSCML, and protects I<no> entities.

=cut

$html_inline = XML::EscapeText->new();
$html_inline->add_tag(@LIMITED_INLINE_TAGS);
$html_inline->add_tagsub(%HTML_TO_HSCML_INLINE);
$html_inline->make_immutable();

=item $html_flow

An C<XML::EscapeText> which protects a subset of HSCML flow tags,
translates HTML flow tags to HSCML, and protects I<no> entities.

=cut

$html_flow = XML::EscapeText->new();
$html_flow->add_tag(@LIMITED_FLOW_TAGS);
$html_flow->add_tagsub(%HTML_TO_HSCML_FLOW);
$html_flow->make_immutable();

=back

=head1 EXPORT TAGS

=over

=item :all

C<$hscml_all>, C<$hscml_flow>, C<$hscml_inline>, C<$hscml_limited_inline>, C<$hscml_limited_flow>,  C<$html_inline>, C<$html_flow>

=item :hscml

C<$hscml_all>, C<$hscml_flow>, C<$hscml_inline>, C<$hscml_limited_inline>, C<$hscml_limited_flow>

=item :html

C<$html_inline>, C<$html_flow>

=item :tags
C<%ENTITIES>, C<@INLINE_TAGS>, C<@BLOCK_TAGS>, C<@FLOW_TAGS>, C<@HSCML_TAGS>

=item :tagsub

C<%HTML_TO_HSCML_INLINE>, C<%HTML_TO_HSCML_FLOW>

=back

=head1 SEE ALSO

L<XML::EscapeText>, L<http:E<sol>E<sol>www.whis.netE<sol>storiesE<sol>2002E<sol>06E<sol>17E<sol>amp151AndAllThat.html>

=head1 AUTHOR

Tarik Alkasab, tarik.alkasab@tufts.edu

=cut

1;
__END__
