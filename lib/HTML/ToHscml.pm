package HTML::ToHscml;

use base qw(Exporter);
use XML::Twig;
use XML::EscapeText qw(:escape);
use XML::EscapeText::HSCML qw(:hscml :tagsub);
use HTML::Tidy;
use vars qw(@EXPORT);
@EXPORT = qw(convert);

my %base_handlers = ( p => \&make_para, ul => \&make_itemized_list,
		      ol => \&make_enumerated_list, li => \&make_list_item,
		      dl => \&make_definition_list, dt => \&make_definition_term,
		      dd => \&make_definition_data, u => \&make_underline,
		      strong => \&empty_check, em => \&make_emph,
		      i => \&make_emph, b => \&make_strong,
		      sup => \&make_super, span => \&span_check,
		      a => \&fix_link, img => \&fix_image,
		      blockquote => \&make_block_quote,
		      hr => \&make_pagebreak, br => \&make_linebreak,
		      pre => \&pre_to_span,
		      h1 => \&empty_check, h2 => \&empty_check, h3 => \&empty_check,
		      h4 => \&empty_check, h5 => \&empty_check, h6 => \&empty_check,
		      );

sub convert {
  my $string = shift;
  my $in_twig = new XML::Twig ( TwigHandlers => \%base_handlers, 
				load_DTD => 0,
				keep_encoding => 1,
				EmptyTags => 'normal',
				comments => 'keep',
			      );
  my $tidier = HTML::Tidy->new();
  $tidier->set_msword_options();
  my $tidystring = $tidier->tidy_string($string);
  $tidystring =~ s/\xDF/\&beta;/gs;
  $in_twig->parse('<body>' . $tidystring . '</body>');
  my $body = $in_twig->first_elt('body');

  my $out_twig = new XML::Twig ();
  $out_twig->parse (join ('', <DATA>));
  my $header = $out_twig->first_elt ('brief-header');
  my $assocdata = $out_twig->first_elt ('associated-data');

  # Start alignment in tables
  for my $table ($body->descendants ('table')) {
    fix_align $table;
    for ($table->descendants) {
      fix_align $_;
    }
  }

  # Kill empty <para>'s
  for ($body->descendants ('para')) { 
    $_->delete unless ($_->text =~ /\S/);
  }

  # Now, go look at a bunch of elements and see if they get fixed
  for (qw/para list-item td/) {
    for my $elt ($body->descendants ($_)) {
      check_inline ($elt);
    }
  }
}


sub make_para {
    #
    # Convert a <p> to <para>
    # (TwigHandler)
    #
    $_[1]->set_gi ('para');
}

sub make_emph {
    #
    # Convert a <whatever> to an <emph>
    # (TwigHandler)
    #
    if (empty_check (@_)) { $_[1]->set_gi ('emph') }
}

sub make_underline {
  #
  # Convert a <u> to a <span style="text-decoration: underline">
  #
  if (empty_check(@_) { 
    $_[1]->set_gi('span');
    $_[1]->set_add('style' => 'text-decoration: underline');
  }
}

sub make_enumerated_list {
    #
    # Convert a <ol> to <enumerated-list>
    # (TwigHandler)
    #
    $_[1]->set_gi ('enumerated-list');
}

sub make_itemized_list {
    #
    # Convert a <ul> to <itemized-list>
    # (TwigHandler)
    #
    $_[1]->set_gi ('itemized-list');
}

sub make_list_item {
    #
    # Convert a <li> to <list-item>
    # (TwigHandler)
    #
    $_[1]->set_gi ('list-item');
}

sub make_definition_list {
    #
    # Convert a <dl> to <definition-list>
    # (TwigHandler)
    #
    $_[1]->set_gi ('definition-list');
}

sub make_definition_term {
    #
    # Convert a <dt> to <definition-term>
    # (TwigHandler)
    #
    $_[1]->set_gi ('definition-term');
}

sub make_definition_data { 
    #
    # Convert a <dd> to <definition-data>
    # (TwigHandler)
    #
    $_[1]->set_gi ('definition-data') ;
}

sub make_strong { 
    #
    # Converts an element to <strong>
    # (Twig Handler)
    #
    if (empty_check (@_)) { $_[1]->set_gi ('strong') }
}

sub make_super { 
    #
    # Converts <sup> to <super> (and does an empty check)
    # (TwigHandler)
    #
    if (empty_check (@_)) { $_[1]->set_gi ('super') }
}

sub make_block_quote { 
    #
    # Converts <sup> to <super> (and does an empty check)
    # (TwigHandler)
    #
    if (empty_check (@_)) { $_[1]->set_gi ('block-quote') }
}

sub make_pagebreak {
  $_[1]->set_gi('pagebreak');
}

sub make_linebreak {
  $_[1]->set_gi('linebreak');
}

sub empty_check {
    #
    # Deletes an element if it has no non-space characters
    # (TwigHandler)
    #
    my ($t, $elt) = @_;
    unless ($elt->text () =~ /\S/) { 
	$elt->delete (); 
	return 0;
    }
    return 1;
}

sub pre_to_span {
    #
    # Turns <pre> elements to <span class="pre"> elements
    #
    my ($t, $elt) = @_;
    $elt->set_gi ('span');
    $elt->set_att ('class', 'pre');
    return 1;
}

sub span_check {
    # 
    # Deletes a span element if it has no class or style attribute set
    # (TwigHandler)
    #
    my ($t, $elt) = @_;
    unless ($elt->att ('class') || $elt->att('style')) {
	$elt->delete ();
    }
    return 1;
}

sub lcase_att {
    #
    # Takes a element and a attribute name, and makes sure it's in lower case.
    #
    my ($elt, $att) = @_;
    if ($elt->att ($att)) {
	my $a = $elt->att ($att);
	$a =~ tr/A-Z/a-z/;
	$elt->set_att ($att, $a);
    }
}

sub fix_align {
    #
    # Takes an element, and if it has any "align" or "valign" attributes, makes sure
    # that they're in lower case (especially for tables
    #
    my $elt = shift;
    lcase_att ($elt, 'align');
    lcase_att ($elt, 'valign');
}

sub do_section {
    #
    # Take a big blob of HTML and make the sectioning work with it. That is,
    # make something like...
    # 
    #   <h2>Title</h2>
    #     <para>...</para>
    #     <h4>Subtitle</h4>
    #       <para>...</para>
    #       <para>...</para>
    #   <h2>Another title</h2>
    #     <para>...</para>
    # 
    # into...
    #
    #   <section-level-1>
    #     <title>Title</title>
    #     <para>...</para>
    #     <section-level-2>
    #       <title>Subtitle</title>
    #       <para>...</para>
    #       <para>...</para>
    #     </section-level-2>
    #   </section-level-1>
    #   <section-level-1>
    #     <title>Another title</title>
    #     <para>...</para>
    #   </section-level-1>
    #
    # INPUT: 
    #   1: An XML::Twig::Elt object to do the dirty work on
    #   2: An array-ref of the section-levels remaining to go in sub-elements
    #   3: An array-ref of the HTML heading levels that correspond with 2.
    #
    # RETURN:
    #
    #   A list of the elements which are the result.
    # So for the above example, it would be...
    #
    #   $body = new XML::Twig::Elt ('body', 
    #                               do_section ($elt, [ 1, 2 ], [ 2, 4 ]));
    #
    # ...which would make a new <body> element with the <section-level-1> 
    # elements as its children
    
    my ($inelt, $levels, $headings) = @_;
    my $level = shift @$levels;
    my $heading = shift @$headings;

    my @elts = ();
    # Check to make sure there are actually appropriate children. If there
    # aren't, then just return a copy of the children
    unless ($heading && $inelt->children ("h$heading")) { 
	for ($inelt->children) {
	    push @elts, $_->copy;
	}
	return @elts;
    }

    # Now, for each child, see if it's the right heading. If it is, then make
    # an appropriate element. If not, add it to the current section.
    my $substart = 0;
    my @section =  ();
    for my $child ($inelt->children) {
	if ($child->gi eq "h$heading") {
	    $substart = 1;
	    # If there's stuff in the section, make up the new element, and
	    # add it to the big list, and reset
	    if (@section) {
		my $elt = new XML::Twig::Elt ("section-level-$level", 
					      @section);
		push @elts, $elt;
	    }
	    # Reset the section
	    @section = ();
	    # Make a copy of this element to be the section title, and
	    # push it onto the new section
	    my @children = ();
	    for ($child->children) { push @children, $_->copy }
	    push @section,  new XML::Twig::Elt ('section-title', @children);
	}
	# Copy and add to the current section
	elsif ($substart) {
	    push @section, $child->copy;
	}
	else {
	    push @elts, $child->copy;
	}
    }

    # If there's a leftover current section, let's close it
    if (@section) {
	my $elt = new XML::Twig::Elt ("section-level-$level", 
				      @section);
	push @elts, $elt;
    }
	    
    # If there's no more down to go, then just return the list of elements
    unless (@{$levels} && @{$headings}) {
	return @elts;
    }

    # Otherwise, let's go through the sections we've formed, and do the next
    # level down, if there's more down to go
    my @newelts = ();
    for (@elts) {
	if ($_->gi eq 'section-title') {
	    push @newelts, $_;
	    next;
	}
	my @sections = do_section ($_, [ @$levels ], [ @$headings ]);
	push @newelts, new XML::Twig::Elt ($_->gi, @sections);
    }
    return @newelts;
}

sub fix_anchor {
    #
    # Find the nearest appropriate neighbor for sticking this label on
    #
    my $elt = shift;
    # Get the name
    my $anchorname = $elt->att ('name');
    # Check the next sibling first
    my $node = $elt->next_sibling;
    # And if it's good, then use it
    unless ($node && $nodetags{$node->gi}) {
	# Otherwise, start checking parents
      PARENT: for ($elt->ancestors) { 
	    if ($nodetags{$_->gi}) {
		$node = $_;
		last PARENT;
	    }
	}
    }
    # Set the ID attribute, and put it in the used list
    $node->set_id ($anchorname);
    $nodeids{$anchorname} = 1;
    # Then, delete the anchor
    $elt->delete;
    return 1;
}

# Types of links:
# x. Outside HSDB: no problem, default web-cite
# 2. Ovid.com: make an medline-cite
# 3. Real: ramgen/ramfiles: realmedia-ref
# x. hsdb4/content: easy, make hsdb-cite-content
# x. Mailto: default web-cite
# x. Images: default web-cite

sub fix_link {
    #
    # Figure out what to do with an <a> element
    #
    my ($t, $elt) = @_;
    my $uri = $elt->att ('href');
    if (! $uri && $elt->att ('name')) {
	$elt->set_gi ('anchor');
	return 1;
    }
    # If it's an internal link...
    if ($uri =~ /^\#(.+)$/) {
	$elt->set_gi ('hsdb-cite-content');
	$elt->del_att ('href');
	$elt->set_att ('content-id', $content->primary_key);
	$elt->set_att ('node-id', $1);
    }
    # Or if it's a medline link...
    # elsif ($uri =~ m!ovidweb\.cgi\?.*AN=(\d+-\d+-\d+)&!) {
    # $elt->del_att ('href');
    # $elt->set_gi ('medline-ref');
    # $elt->set_att ('accession-no', $1)
    # }
    elsif ($uri =~ m!ovidweb\.cgi\?.*AN=(\d+-\d+-\d+)&!) {
	$elt->del_att ('href');
	$elt->set_gi ('web-cite');
	$elt->set_att ('uri', $1);
    }
    # Or if it's a real media link...
    elsif ($uri =~ m!\.edu:8080(/ramgen/.+)$!) {
	$elt->del_att ('href');
	$elt->set_gi ('realmedia-ref');
	$elt->set_att ('uri', $1);
    }
    # Or if it referes to some content...
    elsif (my ($content_id) = $uri =~ m!/hsdb4/content/(?:.+/)*(\d+)!) {
	$elt->set_gi ('hsdb-cite-content');
	$elt->del_att ('href');
	$elt->set_att ('content-id', $content_id);
	# Check to see if there's an internal link as well
	if ($uri =~ /$content_id\#(\w+)/) {
	    $elt->set_att ('node-id', $1);
	}
    }
    # Otherwise, just make a regular link
    else {
	$elt->set_gi ('web-cite');
	$elt->del_att ('href');
	$elt->set_att ('uri', $uri);
    }

    # Set the link-type to deal well with the a popup situation
    if ($uri =~ m!javascript:openWindow\(&apos;(.+)&apos;!) {
	$elt->set_att ('link-type', 'popup');
	$elt->set_att ('uri', $1) if ($elt->gi eq 'web-cite');
    }
    elsif ($elt->gi ne 'web-cite') {
	$elt->set_att ('link-type', 'link');
    }

    return 1;
}

sub check_for_link {
    #
    # Figure out if the immediate parent is a link, and if it is, then
    # set the link-type attributes
    #
    my $elt = shift;
    my $parent = $elt->parent;
    if ($parent->gi eq 'hsdb-cite-content' &&
	$parent->children () == 1 &&
	$elt->att ('content-id') eq $parent->att ('content-id')) {
	# Make a copy of the image
	my $new_elt = $elt->copy;
	# Get the link-type from the link
	$new_elt->set_att ('link-type', $parent->att ('link-type'));
	# Flag this as empty...
	$new_elt->set_content('#EMPTY');
	$new_elt->set_empty();
	# ...and make sure this is it
	$new_elt->replace ($parent);
    }
}

sub set_nodeid {
    #
    # Sets a random nodeid
    #
    my $elt = shift;
    # Return of the node already has an ID
    return if ($elt->id && $elt->id =~ /^[A-za-z_]/);
    # Make a random one we haven't already used
    my $nodeid = 0;
    while ($nodeids{$nodeid}) { $nodeid = "_" . int(rand (9999) + 1) }
    $nodeids{$nodeid} = 1;
    # And set it for the element
    $elt->set_id ($nodeid);
}

sub fix_image {
    my %icons = 
	("ell.gif" => '&liter;',
	 "gror=.gif" => '&ge;',
	 "uparrow.gif" => '&uarr;',
	 "epsilonlowercase.gif" => '&epsilon;',
	 "deltalowercase.gif" => '&delta;',
	 "pi.gif" => '&pi;',
	 "not_equal_to.gif" => '&ne;',
	 "plus_minus.gif" => '&plusmn;',
	 "deltalowercasebold.gif" => '&delta;',
	 "betalowercase.gif " => '&beta;',
	 "rightarrowbold.gif" => '&rarr;',
	 "alphalowercasebold.gif" => '&alpha;',
	 "zetalowercase.gif" => '&zeta;',
	 "psilowercase.gif" => '&psi;',
	 "gammalowercasebold.gif" => '&gamma;',
	 "alpha.gif" => '&alpha;',
	 "uparrow1.gif" => '&uarr;',
	 "Downarrow.gif" => '&darr;',
	 "downarrow.gif" => '&darr;',
	 "philowercase.gif" => '&phi;',
	 "darrow1.gif" => '&darr;',
	 "almost.gif" => '&asymp;',
	 "downarrow1.gif" => '&darr;',
	 "pilowercase.gif" => '&pi;',
	 "alphalowercase.gif" => '&alpha;',
	 "lsor=.gif" => '&le;',
	 "sigmalowercase.gif" => '&sigma;',
	 "lambda.gif" => '&lambda;',
	 "triangledots.gif" => '&there4;',
	 "plus_minus.gif" => '&plusmn;',
	 "filledcircle.gif" => '&bull;',
	 "delta.gif" => '&Delta;',
	 "approximately.gif" => '&cong;',
	 "betalowercas.gif" => '&beta;',
	 "rightarrow.gif" => '&rarr;',
	 "beta.gif" => '&beta;',
	 "gammalowercase.gif" => '&gamma;',
	 "mu.gif" => '&mu;',
	 "sigma_capital.gif" => '&Sigma;',
	 "infinity.gif" => '&infin;',
	 "chilowercase.gif" => '&chi;',
	 "alpha.gif" => '&alpha;',
	 "deltauppercase.gif" => '&Delta;',
	 "gamma.gif" => '&gamma;',
	 "betafontsize09.gif" => '&beta;',
	 "psiuppercase.gif" => '&Psi;',
	 "rho.gif" => '&rho;',
	 "leftarrow.gif" => '&larr;',
	 "square_root.gif" => '&radic;',
	 "Uparrow.gif" => '&uarr;',
	 "two_arrows_opposite_directions.gif" => '&rolarr;',
	 "bothwaysarrow.gif" => '&harr;',
	 "decrease.gif" => '&darr;',
	 "circle.gif" => '&deg;',
	 "chiuppercase.gif" => '&Chi;',
	 "lambdauppercase.gif" => '&Lambda;',
	 "omegauppercase.gif" => '&Omega;',
	 "phiuppercase.gif" => '&Phi;',
	 "piuppercase.gif" => '&Pi;',
	 "thetauppercase.gif" => '&Theta;',
	 "upsilonuppercase.gif" => '&Upsilon;',
	 "xiuppercase.gif" => '&Xi;',
	 "etalowercase.gif" => '&eta;',
	 "gammalowercase.gif" => '&gamma;',
	 "iotalowercase.gif" => '&iota;',
	 "kappalowercase.gif" => '&kappa;',
	 "nulowercase.gif" => '&nu;',
	 "omegalowercase.gif" => '&omega;',
	 "omicronlowercase.gif" => '&omicron;',
	 "taulowercase.gif" => '&tau;',
	 "thetalowercase.gif" => '&theta;',
	 "upsilonlowercase.gif" => '&upsilon;',
	 "xilowercase.gif" => '&xi;',
	 "alpha" => '&alpha;',
	 "beta" => '&beta;',
	 "gamma" => '&gamma;',
	 );

    my %content_ids = 
	("4028-08" => 410,
	 "4028-03" => 405,
	 "4028-26" => 1326,
	 "4028-12" => 414,
	 "4028-35" => 1333,
	 "4028-58" => 1354,
	 "4025-89" => 425,
	 "4028-21" => 1755,
	 "4025-98" => 434,
	 "4028-15" => 417,
	 "4028-30" => 1328,
	 "4028-53" => 1350,
	 "4025-93" => 429,
	 "4028-05" => 407,
	 "4028-28" => 1327,
	 "4028-37" => 1335,
	 "4028-23" => 1756,
	 "4028-46" => 1377,
	 "4028-17" => 419,
	 "4028-32" => 1330,
	 "4028-55" => 1352,
	 "4025-86" => 422,
	 "4028-41" => 1339,
	 "4025-95" => 431,
	 "4028-50" => 1347,
	 "4025-90" => 426,
	 "4028-07" => 409,
	 "4028-39" => 1337,
	 "4028-02" => 404,
	 "4028-25" => 1325,
	 "4028-48" => 1345,
	 "4028-19" => 421,
	 "4028-11" => 413,
	 "4028-34" => 1332,
	 "4028-57" => 1353,
	 "4025-88" => 424,
	 "4028-20" => 1758,
	 "4028-43" => 1341,
	 "4025-97" => 433,
	 "4028-14" => 416,
	 "4028-52" => 1349,
	 "4028-61" => 1357,
	 "4025-92" => 428,
	 "4028-09" => 411,
	 "4028-04" => 406,
	 "4028-27" => 1375,
	 "4028-13" => 415,
	 "4028-36" => 1334,
	 "4028-59" => 1355,
	 "4028-45" => 1343,
	 "4025-99" => 435,
	 "4028-16" => 418,
	 "4028-31" => 1329,
	 "4028-54" => 1351,
	 "4028-40" => 1338,
	 "4025-94" => 430,
	 "4028-06" => 408,
	 "4028-29" => 1376,
	 "4025-00" => 436,
	 "4028-38" => 1336,
	 "4028-01" => 402,
	 "4028-24" => 1757,
	 "4028-47" => 1344,
	 "4028-18" => 420,
	 "4028-10" => 412,
	 "4028-33" => 1331,
	 "4025-87" => 423,
	 "4025-96" => 432,
	 "4028-51" => 1348,
	 "4028-60" => 1356,
	 "4025-91" => 427,
	 );

    #
    # Figure out what to do with a <img> element
    #
    my ($t, $elt) = @_;
    my $src = $elt->att ('src');
    # See if it's a glyph image
    if (my ($hexcode) = $src =~ m!/icons/glyphs/U([0-9A-Fa-f]{4})\.png!) {
      my $entity = $elt->att('alt') || "#x$hexcode";
      my $span = XML::Twig::Elt->new('span', { class => 'unicode' }, sprintf('&%s;', $entity ));
      $entity->set_asis();
      $entity->replace($elt);
      return 1;
    }
    # Now see if it's in our entities; if it is, then let's put in the
    # appropriate entity instead of a graphic of any kind
    # (we can also wrap it in a <span> element)
    elsif ($src =~ m!(symbols|icons)/([^/]+\.gif)$! && $icons{$2}
	   or $src =~ m!/(images)/(alpha|beta|gamma)lc.gif!) {
	my $span = new XML::Twig::Elt ('span', { class => "unicode" }, $icons{$2});
	$span->set_asis();
	$span->replace ($elt);
	# We don't worry about anything else
	return 1;
    }
    # See if it's a content link (full data)
    elsif ($src =~ m!data/(\d+)(\.gif|\.jpeg)?$!) {
	$elt->set_gi ('hsdb-graphic');
	$elt->del_att ('src');
	$elt->set_att ('image-class', 'full');
	$elt->set_att ('content-id', $1);
    }
    # See if it's a content link (thumbnail)
    elsif ($src =~ m!thumbnail/(\d+)$!) {
	$elt->set_gi ('hsdb-graphic');
	$elt->del_att ('src');
	$elt->set_att ('image-class', 'thumb');
	$elt->set_att ('content-id', $1);
    }
    # See if it's a content link (small_data)
    elsif ($src =~ m!small_data/(\d+)$!) {
	$elt->set_gi ('hsdb-graphic');
	$elt->del_att ('src');
	$elt->set_att ('image-class', 'half');
	$elt->set_att ('content-id', $1);
    }
    # Now check to see if we know what the content_id is from the filename
    elsif ($src =~ m!\D(\d\d\d+-\d\d+)\.! && $content_ids{$1}) {
	$elt->set_gi ('hsdb-graphic');
	$elt->del_att ('src');
	$elt->set_att ('content-id', $content_ids{$1});
	# See if there's a hint about the class in the file
	if ($src =~ m!\.h\.!) { $elt->set_att ('image-class', 'half') }
	elsif ($src =~ m!\.t\.!) { $elt->set_att ('image-class', 'thumbnail') }
	else { $elt->set_att ('image-class', 'full') }
    }
    # And if we can't do anything else, then we make it a <web-graphic>, and
    # set the URI
    else {
	$elt->set_gi ('web-graphic');
	$elt->del_att ('src');
	$elt->set_att ('uri', $src);
	$elt->set_content('#EMPTY');
	$elt->set_empty();
    }

    # If the alt tag is set, use it as a description attribute
    if ($elt->att ('alt')) {
	$elt->set_att ('description', $elt->att ('alt'));
	$elt->del_att ('alt');
    }
    # Otherwise, get the label
    else {
	$elt->set_att ('description', '');
	$elt->del_att ('alt');
    }

    # Now, if we've got an <hsdb-graphic>, we have to make sure
    # it's all set; proper attributes defined, etc.
    if ($elt->gi eq 'hsdb-graphic') {
	# Get the relevant content object
	my $content = HSDB4::SQLRow::Content->new;
	$content->lookup_key ($elt->att ('content-id'));
	# Unless width and height are set...
	unless ($elt->att ('width') && $elt->att ('height')) {
	    # go find the data object, and use its width and height
	    my $dataobj;
	    if ($elt->att ('image-class') eq 'half') {
		$dataobj = $content->small_data;
	    }
	    elsif ($elt->att ('image-class') eq 'thumbnail') {
		$dataobj = $content->thumbnail;
	    }
	    else { $dataobj = $content->data }
	    $elt->set_att ('width', $dataobj->field_value ('width'));
	    $elt->set_att ('height', $dataobj->field_value ('height'));
	}
	# Unless we already have a description, set it from the content
	# title
	unless ($elt->att ('description')) {
	    $elt->set_att ('description', $content->out_label);
	}
    }
    # For an external graphic, it's harder to find width and height
    else {
	unless ($elt->att ('width') && $elt->att ('height')) {
	    # Figure out if it's a filename
	    my $uri = $elt->att ('uri');
	    my $filename = "/data/html/$uri";
	    # And if it is, then use the file size to set our attributes
	    if ($filename && -e $filename) {
		my ($w, $h) = imgsize ($filename);
		$elt->set_att ('width', $w);
		$elt->set_att ('height', $w);
	    }
	    # We don't want to deal with that (and we shouldn't have to)
	    else { die "Can't figure out image size: $uri" }
	}
    }

    # A depressing state of affairs; set "description" to "Unknown image".
    # How embarassing.
    unless ($elt->att ('description')) {
	$elt->set_att ('description', 'Unknown image');
    }

    return 1;
}

1;
__DATA__
<?xml version="1.0" encoding="utf-8" standalone="no"?>
<!DOCTYPE db-content PUBLIC "-//Tufts HDSB Project//DTD database content//EN"
    "http://tusk.tufts.edu/DTD/dbcontent.dtd">
<db-content> 
  <brief-header> 
    <mime-type>text/xml</mime-type>
  </brief-header> 
  <associated-data></associated-data>
</db-content>
