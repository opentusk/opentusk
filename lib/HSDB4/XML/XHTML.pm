package HSDB4::XML::XHTML;

use strict;
use HSDB4::SQLRow::Content;

require HSDB4::XML;

# Shorthand for the XML types
my $simple = 'HSDB4::XML::SimpleElement';
my $attr = 'HSDB4::XML::Attribute';
my $element = 'HSDB4::XML::Element';
my $empty = 'HSDB4::XML::EmptyElement';

# Core attributes
my $id_attr = $attr->new (-name => 'id');
my $class_attr = $attr->new (-name => 'class');
my $style_attr = $attr->new (-name => 'style');
my $title_attr = $attr->new (-name => 'title');
my @attrs = ($id_attr, $class_attr, $style_attr, $title_attr);

#
# Paragraph-like things
#
my $p = $element->new (-tag => 'p', -attributes => [ @attrs ],
		       -allow_pcdata => 1);
my $h1 = $element->new (-tag => 'h1', -attributes => [ @attrs ],
			-allow_pcdata => 1);
my $h2 = $element->new (-tag => 'h2', -attributes => [ @attrs ],
			-allow_pcdata => 1);
my $h3 = $element->new (-tag => 'h3', -attributes => [ @attrs ],
			-allow_pcdata => 1);
my $h4 = $element->new (-tag => 'h4', -attributes => [ @attrs ],
			-allow_pcdata => 1);
my $h5 = $element->new (-tag => 'h5', -attributes => [ @attrs ],
			-allow_pcdata => 1);
my $h6 = $element->new (-tag => 'h6', -attributes => [ @attrs ],
			-allow_pcdata => 1);
my $div = $element->new (-tag => 'div', -attributes => [ @attrs ],
			 -allow_pcdata => 1);

#
# List stuff
#
my $li = $element->new (-tag => 'li', -attributes => [ @attrs ],
			-allow_pcdata => 1);
my $ol = $element->new (-tag => 'ol', -attributes => [ @attrs ],
			-subelements => [ [ $li, 1, 0 ] ]);
my $ul = $element->new (-tag => 'ul', -attributes => [ @attrs ],
			-subelements => [ [ $li, 1, 0 ] ]);
my $dt = $element->new (-tag => 'dt', -attributes => [ @attrs ],
			-allow_pcdata => 1);
my $dd = $element->new (-tag => 'dd', -attributes => [ @attrs ],
			-allow_pcdata => 1);
my $dl = $element->new (-tag => 'dl', -attributes => [ @attrs ],
			-subelements => [ [$dt, 1, 0], [$dd, 1, 0] ]);

#
# Basic text stuff
#
my $address = $element->new (-tag => 'dl', -attributes => [ @attrs ],
			     -allow_pcdata => 1);

my $hr = $empty->new (-tag => 'hr', -attributes => [ @attrs ]);
my $br = $empty->new (-tag => 'br', -attributes => [ @attrs ]);

my $cite_attr = $attr->new (-name => 'cite');
my $blockquote = $element->new (-tag => 'blockquote', 
				-attributes => [ @attrs, $cite_attr ],
			       );

my $pre = $element->new (-tag => 'pre', -attributes=> [ @attrs ],
			 -allow_pcdata => 1);

my $name_attr = $attr->new (-name=>'name');
my $href_attr = $attr->new (-name=>'href');
my $a = $element->new (-tag=>'a',
		       -attributes => [ @attrs, $name_attr, $href_attr ],
		       -allow_pcdata => 1);

sub hsdb_content_link_xhtml {
    my ($self, $writer) = @_;
    my %attrs = $self->attribute_hash;
    my $content_id = $attrs{content_id};
    delete $attrs{content_id};
    $attrs{href} = $HSDB4::Constants::URLs{'HSDB4::SQLRow::Content'} . '/' .
      $content_id;
    $writer->startTag ('a', %attrs);
    # Go through the value list
    foreach my $node ($self->value) {
	next unless $node;
	# If it's a object, then get it to write itself to the writer
	if (ref $node) { $node->out_xml ($writer, 1) }
	# Otherwise, just put the text blob onto the list
	else { $writer->characters ($node) if $node =~ /\S/ }
    }
    $writer->endTag;
}

my $content_id_attr = $attr->new (-name => 'content_id');

my $hsdb_content_link = 
  $element->new (-tag => 'hsdb_content_link',
		 -attributes => [ @attrs, $content_id_attr ],
		 -allow_pcdata => 1,
		 -xhtml_filter => \&hsdb_content_link_xhtml,
		 );

my $span = $element->new (-tag => 'span', -attributes => [ @attrs ],
			  -allow_pcdata => 1);

my $em = $element->new (-tag => 'em', -attributes => [ @attrs ],
			-allow_pcdata => 1);
my $strong = $element->new (-tag => 'strong', -attributes => [ @attrs ],
			    -allow_pcdata => 1);
my $dfn = $element->new (-tag => 'dfn', -attributes => [ @attrs ],
			 -allow_pcdata => 1);
my $code = $element->new (-tag => 'code', -attributes => [ @attrs ],
			  -allow_pcdata => 1);
my $samp = $element->new (-tag => 'samp', -attributes => [ @attrs ],
			  -allow_pcdata => 1);
my $kbd = $element->new (-tag => 'kbd', -attributes => [ @attrs ],
			 -allow_pcdata => 1);
my $var = $element->new (-tag => 'var', -attributes => [ @attrs ],
			 -allow_pcdata => 1);
my $cite = $element->new (-tag => 'cite', -attributes => [ @attrs ],
			  -allow_pcdata => 1);
my $abbr = $element->new (-tag => 'abbr', -attributes => [ @attrs ],
			  -allow_pcdata => 1);
my $acronym = $element->new (-tag => 'acronym', -attributes => [ @attrs ],
			     -allow_pcdata => 1);
my $q = $element->new (-tag => 'q', -attributes => [ @attrs, $cite_attr ],
		       -allow_pcdata => 1);
my $sub = $element->new (-tag => 'sub', -attributes => [ @attrs ],
			 -allow_pcdata => 1);
my $sup = $element->new (-tag => 'sup', -attributes => [ @attrs ],
			 -allow_pcdata => 1);
my $tt = $element->new (-tag => 'tt', -attributes => [ @attrs ],
			-allow_pcdata => 1);
my $i = $element->new (-tag => 'i', -attributes => [ @attrs ],
		       -allow_pcdata => 1);
my $b = $element->new (-tag => 'b', -attributes => [ @attrs ],
		       -allow_pcdata => 1);

#
# Image
#
my $width_attr = $attr->new (-name => 'width');
my $height_attr = $attr->new (-name => 'height');
my $alt_attr = $attr->new (-name => 'alt', -required => 1);
my $src_attr = $attr->new (-name => 'src', -required => 1);
my $usemap_attr = $attr->new (-name => 'usemap');
my $ismap_attr = $attr->new (-name => 'ismap');
my $img = $empty->new (-tag => 'img', 
		       -attributes => [ @attrs, $src_attr, $alt_attr, 
					$height_attr, $width_attr, 
					$usemap_attr, $ismap_attr ]
		      );
my $binary_data_id_attr = $attr->new (-name => 'binary_data_id', 
				      -required => 1);
sub binary_data_xhtml {
    my ($self, $writer) = @_;
    my %att_hash = $self->attribute_hash;
    $att_hash{'src'} = $HSDB4::Constants::URLs{'binary'} .
      '/' . $att_hash{binary_data_id};
    delete $att_hash{binary_data_id};
    $writer->emptyTag ('img', %att_hash);
}

my $binary_data = $empty->new (-tag => 'binary_data',
			       -attributes => [ @attrs, $alt_attr,
						$height_attr, $width_attr,
						$binary_data_id_attr ],
			       -xhtml_filter => \&binary_data_xhtml,
			      );

my $data_size_attr = $attr->new (-name => 'data_size',
				 -choices => { full => 'Full size',
					       small => 'Smaller size',
					       thumb => 'Thumbnail size',
					      },
				 -default => 'full',
				);
sub content_data_xhtml {
    my $self = shift;
    my $writer = shift;
    my %attrs = $self->attribute_hash;
    my $doc = HSDB4::SQLRow::Content->new->lookup_key ($attrs{content_id});
    return unless $doc->primary_key;
    delete $attrs{content_id};
    my $data;
    if ($attrs{data_size} eq 'small') { $data = $doc->small_data }
    elsif ($attrs{data_size} eq 'thumb') { $data = $doc->thumbnail }
    else { $data = $doc->data }
    return unless $data && $data->primary_key;
    delete $attrs{data_size};
    $attrs{src} = $data->out_url;
    $attrs{width} = $data->field_value ('width') unless $attrs{width};
    $attrs{height} = $data->field_value ('height') unless $attrs{height};
    $writer->emptyTag ('img', %attrs);
}

my $content_data = $empty->new (-tag => 'content_data',
				-attributes => [ @attrs, $alt_attr,
						 $height_attr, $width_attr,
						 $content_id_attr,
						 $data_size_attr ],
				-xhtml_filter => \&content_data_xhtml
				);
#
# Tables
#
my $align_attr = $attr->new (-name => 'align',
			     -choices => { 'left' => 'Left',
					   'center' => 'Centered',
					   'right' => 'Right',
					   'justify' => 'Justified' }
			    );
my $valign_attr = $attr->new (-name => 'valign',
			      -choices => { top => 'Top',
					    middle => 'Middle',
					    bottom => 'Bottom',
					    baseline => 'Baseline' }
			     );
my $rowspan_attr = $attr->new (-name => 'rowspan', -default => 1);
my $colspan_attr = $attr->new (-name => 'colspan', -default => 1);


my $caption = $element->new (-tag => 'caption', -attributes => [ @attrs ],
			     -allow_pcdata => 1);

my $th = $element->new (-tag => 'th',
			-attributes => [ @attrs, $rowspan_attr,
					 $colspan_attr, $align_attr, 
					 $valign_attr ],
			);
my $td = $element->new (-tag => 'td',
			-attributes => [ @attrs, $rowspan_attr,
					 $colspan_attr, $align_attr, 
					 $valign_attr ],
			-allow_pcdata => 1,
		       );
my $tr = $element->new (-tag => 'tr',
			-attributes => [ @attrs, $align_attr, $valign_attr ],
			-subelements => [ [$th], [$td] ]
		       );

my $summary_attr = $attr->new (-name => 'summary');
my $border_attr = $attr->new (-name => 'border');
my $cellspacing_attr = $attr->new (-name => 'cellspacing');
my $cellpadding_attr = $attr->new (-name => 'cellpadding');
my $table = $element->new (-tag => 'table',
			   -attributes => [@attrs, $summary_attr, $border_attr,
					   $cellspacing_attr,
					   $cellpadding_attr],
			   -subelements => [ [$caption, 0, 1],
					     [$tr, 1, 0 ] ]
			  );

#
# Groups for subelementing
#

# Build up @Inline, the list for text markup
my @special = ([$br], [$span], [$img], [$binary_data]);
my @fontstyle = ([$tt], [$i], [$b]);
my @phrase = ([$em], [$strong], [$dfn], [$code], [$q], [$sub], [$sup],
	      [$samp], [$kbd], [$var], [$cite], [$abbr], [$acronym]);
my @Inline = ([$a], [$hsdb_content_link], @special, @fontstyle, @phrase);
# Now do a bunch of renewing
foreach ($p, $h1, $h2, $h3, $h4, $h5, $h6, $div, $dt, $address, 
	 $span, $em, $strong, $dfn, $code, $samp, $kbd, $var, $cite,
	 $abbr, $acronym, $q, $sub, $sup, $tt, $i, $b, $caption)
  {
      $_->new_subelements (\@Inline);
  }
# Now tack on the stuff for <a> and <pre>
$a->new_subelements ( [ @special, @fontstyle, @phrase ] );
$hsdb_content_link->new_subelements ( [ @special, @fontstyle, @phrase ] );
$pre->new_subelements ( [ [$a], [$hsdb_content_link], [$br], [$span],
			  [$tt], [$i], [$b], @phrase ] );

# Now build up @Block for structure markup
my @heading = ([$h1], [$h2], [$h3], [$h4], [$h5], [$h6]);
my @lists=([$ul], [$ol], [$dl]);
my @blocktext=([$pre], [$hr], [$blockquote], [$address]);
my @Block = ([$p], @heading, [$div], @lists, [$table]);
# And do the appropriate renewing...
foreach ($blockquote) {
    $_->new_subelements (\@Block);
}

# Now add @Flow, for both text and structure markup
my @Flow = (@Block, @Inline);
# And do the appropriate renewing
foreach ($li, $dd, $th, $td) { 
    $_->new_subelements (\@Flow);
}

# Now make a <xhtml-body> tag...
my $body = $element->new (-tag => 'xhtml-body',
			  -attributes => [],
			  -subelements => \@Block);

sub inline_elements { return [ @Inline ] }

sub flow_elements { return [ @Flow ] }

sub block_elements { return [ @Block ] }

sub new { return $body->new }

1;
