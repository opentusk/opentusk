# Copyright 2012 Tufts University 
#
# Licensed under the Educational Community License, Version 1.0 (the "License"); 
# you may not use this file except in compliance with the License. 
# You may obtain a copy of the License at 
#
# http://www.opensource.org/licenses/ecl1.php 
#
# Unless required by applicable law or agreed to in writing, software 
# distributed under the License is distributed on an "AS IS" BASIS, 
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
# See the License for the specific language governing permissions and 
# limitations under the License.


package HSDB4::XML::Attribute;
use strict;

# 
# Constructor
#

sub new {
    #
    # Create a new attribute object, using first arguments for the settings,
    # then a template, if it's available.  The only thing *required* is the
    # name; it must be able to figure out a name, either from 
    # "-name => 'foo'" in the argument list or becuase it's called as a method
    # from an object with a name
    #

    my $self = shift;
    my $class = ref $self || $self;
    my $newself = { name => '',          # The name of the attribute in XML
		    default => '',       # Its default value, if it has one
		    choices => {},       # A hash of choices/labels
		    label => '',         # A label for the attribute in forms
		    id_attribute => 0,   # Whether it's a ID attribute
		    required => 0,       # Whether it must be set for validity
		    fixed => 0,          # Whether it should not be editable
		    dtd_definition => '',# A string for the DTD, if necessary
		    value => '' };       # Someplace to actually store the info

    # Suck in the arguments as key/value pairs.  The keys are:
    #   -name           scalar
    #   -default        scalar
    #   -choices        hashref
    #   -label          scalar
    #   -id_attribute   0/1
    #   -required       0/1
    #   -fixed          0/1
    #   -dtd_definition scalar
    my %args = @_;

    # Figure out how to set the name
    if ($args{-name}) { $newself->{name} = $args{-name} }
    elsif (ref $self) { $newself->{name} = $self->{name} }
    else { die "Cannot determine attribute name: " . join (' ', @_) }

    # Set up the choices, if there are any
    if ($args{-choices} && ref $args{-choices} eq 'HASH') {
	$newself->{choices} = { %{$args{-choices}} };
    }
    elsif (ref $self) { $newself->{choices} = $self->{choices} }

    # Get the default choice
    if ($args{-default}) { $newself->{default} = $args{-default} }
    elsif (ref $self) { $newself->{default} = $self->{default} }

    # Set up the label, if possible
    if ($args{-label}) { $newself->{label} = $args{-label} }
    elsif (ref $self) { $newself->{label} = $self->{label} }
    else { $newself->{label} ||= ucfirst $newself->{name} }

    # See if there's something telling us that this attribute is required
    if ($args{-required} or ref $self && $self->{required}) { 
	$newself->{required} = 1;
    }

    # See if there's something telling us that this attribute is fixed (non-
    # editable on a form)
    if ($args{-fixed} or ref $self && $self->{fixed}) { $newself->{fixed} = 1 }

    # See if this is an ID attribute, in which case, we'll assume that it's
    # both fixed and required
    if ($args{-id_attribute} or ref $self && $self->{id_attribute}) { 
	@{$newself}{qw(id_attribute required fixed)} = (1, 1, 1);
    }

    # See if there's info on the DTD string
    if ($args{-dtd_definition}) {
	$newself->{dtd_definition} = $args{-dtd_definition};
    }
    elsif (ref $self) {
	$newself->{dtd_definition} = $self->{dtd_definition};
    }

    return bless $newself, $class;
}

#
# Accessor Functions
#

sub name {
    my $self = shift;
    return $self->{name};
}

sub label {
    my $self = shift;
    return $self->{label};
}

sub required {
    my $self = shift;
    return $self->{required};
}

sub fixed {
    my $self = shift;
    return $self->{fixed};
}

sub id_attribute {
    my $self = shift;
    return $self->{fixed};
}

sub default {
    my $self = shift;
    return $self->{default};
}

sub choices {
    my $self = shift;
    return unless $self->{choices};
    return %{$self->{choices}};
}

sub dtd_definition {
    #
    # Return a DTD string, either by figuring it out from parameters or from
    # the creation specification
    #

    my $self = shift;
    return $self->{dtd_definition} if $self->{dtd_definition};

    # Start forming the information on the attribute
    my $info = '';
    # Check to see if it's an ID attribute
    if ($self->id_attribute) {
	$info = 'ID #REQUIRED';
    }
    # ...or if it's a fixed attribute
    elsif ($self->fixed) {
	$info = sprintf ('CDATA #FIXED "%s"', $self->default);
    }
    # Otherwise...
    else {
	# ...do we have choices?
	my @choices = keys %{$self->{choices}};
	# If so, then print the choices
	if (@choices) {
	    $info = sprintf ('(%s)', join ('|', @choices));
	}
	# If not, then just use CDATA
	else {
	    $info = 'CDATA';
	}
	# Check for required-ness
	$info .= ' #REQUIRED' if $self->required;
	# Check for a default
	$info .= sprintf (' "%s"', $self->default) if $self->default;
    }

    return $info;
}

sub value {
    # 
    # Get/set the value of the attribute
    #

    my $self = shift;
    # If we have arguments, we're going to try to set
    if (@_) {
	# Get a list of good choices
	my @choices = keys %{$self->{choices}};
	if (@choices) {
	    my $val = shift;
	    # Problem if there are defined choices and our val isn't among them
	    if (@choices and not grep { $_ eq $val } @choices) {
		die "Attribute $self->{name} cannot be set to $val";
	    }
	    # Set the value
	    $self->{value} = $val;
	}
	else {
	    $self->{value} = join (' ', @_);
	}
    }
    # Return the value (with its new setting, if that happened)
    return $self->{value}
}

#
# Output Functions
#

sub out_xml_string {
    #
    # Return a 'key="val"' string for use in an XML tag
    #

    my $self = shift;
    return sprintf '%s="%s"', $self->name, $self->value if $self->value;
    return;
}

sub out_dtd {
    #
    # Return a DTD string for the attribute (take the tag name as an arg)
    #

    my $self = shift;

    # Now return the result
    return $self->name . ' ' .  $self->dtd_definition;
}

sub out_html_form {
    #
    # Return a bit of HTML for making up an HTML form. If it's fixed, then
    # just show the value. If it has choices, make a drop-down menu. Otherwise,
    # use a text box to get the value. Prepend with a boldened label.
    #

    my $self = shift;
    # Get the prefix if it's there (for making the right name for the field)
    my $prefix = shift || '';
    # Figure out if we have choices
    my @choices = keys %{$self->{choices}};

    # Start forming an output string
    my $out = '';
    
    # Just give the value if we're fixed
    if ($self->fixed) {
	$out = sprintf("%s: %s\n", $self->label, $self->value);
    }
    # Make up the drop-down box if there are choices
    elsif (@choices) {
	# Make the bold label and <SELECT>...
	$out .= sprintf ("%s:<select name=\"%s:a_%s\">\n", 
			 $self->label, $prefix, $self->name);
	# And then the <OPTION>'s...
	foreach (@choices) {
	    $out .= sprintf ("\t<option value=\"%s\"%s>%s</option>\n", 
			     $_, $_ eq $self->value ? ' selected' : '',
			     $self->{choices}{$_});
	}
	# ...and close the <SELECT>.
	$out .= "</select>\n";
    }
    # Otherwise, we're just making a text box.
    else {
	# Make the bold label and text box with the right values thrown in
	my $temp = "%s:<input type=\"TEXT\" name=\"%s:a_%s\"";
	$temp .= " SIZE=\"15\" VALUE=\"%s\">\n", 
	$out .= sprintf ($temp, $self->label, $prefix, $self->name, 
			 $self->value || $self->default);
    }
    
    # Return the fruits of our labor
    return $out;
}

package HSDB4::XML;
use strict;
require XML::Parser;
require XML::Writer;
require IO::Scalar;

#
# Constructor
#

sub new {
    #
    # Create a new SimpleElement object.  Used in two ways:  called with the
    # class invocation and information to create a template object and as a
    # method of that template to create particular data-holding invocations.
    #

    # Object reference: hashref, with the following meaningful entries:
    #   Template data:
    #     tag              The actual name of the tag used in XML (string)
    #     attributes       Hashref of tag-indexed attributes (which are
    #                      HSDB4::XML::Attribute object templates)
    #     label            The label to be used on forms, etc.
    #   Object data:
    #     value            The PCDATA that is stored in this element
    #     attribute_values Hashref of tag-indexed attributes (which are
    #                      value-storing HSDB4::XML::Attributes)
    # Calling:
    # Create a new template object:
    #   my $template = HSDB4::XML::SimpleElement->new (-tag => 'tagname',
    #                                                  -label => 'Label',
    #                                                  -attributes => [ ... ],
    #                                                  -html_filter => \&foo,
    #                                                  );
    # Making a new object from the template
    #   my $obj = $template->new();

    # Get the template and class names, possibly (at least one of them,
    # right?)
    my $self = shift;
    my $class = ref $self || $self;
    # Start up the new object
    my $newself = { value => '',
		    attribute_values => {} };

    # Suck in the rest of the arguments as key/val pairs. Used keys:
    #   -tag            scalar
    #   -label          scalar
    #   -attributes     arrayref
    #   -html_filter    coderef
    #   -dtd_definition scalar
    #   -dtd_preface    scalar
    my %arguments = @_;

    # Get the tag, if possible; first, check the '-tag' argument, then
    # check to see whether we're copying another object and can get its
    # tag, and if not that, then we just die, because there's nothing else
    # to do.
    $newself->{tag} = $arguments{-tag} || (ref $self && $self->tag)
	or die "Could not find tag name for $class";

    # Get the label in the same way: look for a '-label' argument, then
    # look to suck in the template's label, and barring that, use a 
    # capitalized version of the tag
    $newself->{label} = $arguments{-label} || (ref $self && $self->label)
	|| ucfirst $newself->{tag};

    # Get the attribute list in more or less the same way. Get it from
    # the argument '-attributes', from the template object, or make it
    # a new empty arrayref.
    if ($arguments{-attributes} && ref $arguments{-attributes} eq 'ARRAY') {
	my %attr_index = ();
	foreach my $attr (@{$arguments{-attributes}}) {
	    $attr_index{$attr->name} = $attr;
	}
	$newself->{attributes} = \%attr_index;
    }
    elsif (ref $self && ref ($self->{attributes}) eq 'HASH') {
	$newself->{attributes} = $self->{attributes};
    }
    else {
	$newself->{attributes} = {};
    }

    # Check to see if there's a html_filter...
    if ($arguments{-html_filter} && ref $arguments{-html_filter} eq 'CODE') {
	$newself->{html_filter} = $arguments{-html_filter};
    }
    elsif (ref $self && ref ($self->{html_filter}) eq 'CODE') {
	$newself->{html_filter} = $self->{html_filter};
    }

    # Check to see if there's an xhtml_filter...
    if ($arguments{-xhtml_filter} && ref $arguments{-xhtml_filter} eq 'CODE') {
	$newself->{xhtml_filter} = $arguments{-xhtml_filter};
    }
    elsif (ref $self && ref ($self->{xhtml_filter}) eq 'CODE') {
	$newself->{xhtml_filter} = $self->{xhtml_filter};
    }

    # Check to see if there's a DTD string
    if ($arguments{-dtd_definition}) {
	$newself->{dtd_definition} = $arguments{-dtd_definition};
    }
    elsif (ref $self) {
	$newself->{dtd_definition} = $self->{dtd_definition};
    }

    if ($arguments{-dtd_preface}) {
	$newself->{dtd_preface} = $arguments{-dtd_preface};
    }
    elsif (ref $self) {
	$newself->{dtd_preface} = $self->{dtd_preface};
    }

    return bless $newself, $class;
}

#
# Accessor functions
#

sub tag {
    my $self = shift;
    return $self->{tag};
}

sub label {
    my $self = shift;
    return $self->{label};
}

sub dtd_definition {
    my $self = shift;
    return $self->{dtd_definition} ? $self->{dtd_definition} : '#PCDATA';
}

sub dtd_preface {
    my $self = shift;
    my $preface = sprintf ("<!-- %s -->", $self->label);
    return $preface unless $self->{dtd_preface};
    return "$preface\n$self->{dtd_preface}";
}

sub out_dtd_attributes {
    my $self = shift;
    return unless $self->get_attributes;
    my $attlist = '<!ATTLIST ' . $self->tag . ' ';
    my $pre = ' ' x length($attlist);
    $attlist .= join ("\n$pre", map { $_->out_dtd } $self->get_attributes);
    return $attlist . '>';
}

sub out_dtd {
    #
    # Return a DTD element for this element
    #

    my $self = shift;

    my $attr = $self->out_dtd_attributes;
    $attr = "\n$attr" if $attr;
    # Just return the simple element along with attributes
    return sprintf ("%s\n<!ELEMENT %s (%s)>%s",
		    $self->dtd_preface, $self->tag, $self->dtd_definition,
		    $attr);
}

# 
# Attribute manipulation
#

sub attribute_keys {
    my $self = shift;
    return keys %{$self->{attributes}};
}

sub get_attributes {
    #
    # Get an actually named attribute object
    #

    my $self = shift;

    # Return 'em all if there are no attributes
    return values %{$self->{attributes}} unless @_;
    # Get the values from each attribute named in @_ which has something
    # in the attribute_values hashref, and call value for each.  Put
    # undef's in each place where there wasn't a good key.
    my @vallist = map { defined $self->{attributes}{$_} ?
			    $self->{attributes}{$_} : undef } @_;

    return @vallist if @_ > 1;
    return $vallist[0] if @vallist;
    return;
}

sub get_attribute_values {
    #
    # Get either a single attribute value or a slice from the attribute hash
    #

    my $self = shift;

    # Don't do anything if there are no arguments
    return unless @_;
    # Get the values from each attribute named in @_ which has something
    # in the attribute_values hashref, and call value for each.  Put
    # undef's in each place where there wasn't a good key.
    my @vallist = map { defined $self->{attribute_values}{$_} ?
			    $self->{attribute_values}{$_} : undef } @_;

    return @vallist if @_ > 1;
    return $vallist[0];
}

sub set_attributes {
    # 
    # Set a whole bunch of attributes in (key, value) pairs
    #

    my $self = shift;

    # Get the attribute hashref
    my $attr_vals = $self->{attribute_values};
    # Now go through the list of arguments, and set the values in the
    # hashref one by one.
    while (my ($key, $val) = splice (@_, 0, 2)) { 
	# Forget it unless we have a valid attribute key
	my $template = $self->{attributes}{$key} or next;
	# Create a new attribute unless it's already defined
	$attr_vals->{$key} = $template->new unless $attr_vals->{$key};
	# Now, actually set its value
	$attr_vals->{$key}->value ($val);
    }
}

sub attribute_hash {
    #
    # Get the attributes as a string like:
    #     key1="val" key2="val2" key3="another val"
    # for putting actually into the tags, if need be
    #

    my $self = shift;

    # Now make a big list of (key, val) pairs from the actually defined
    # attributes
    return map { ($_->name, $_->value) } values %{$self->{attribute_values}};
}

sub attribute_html_form {
    #
    # Return form stuff for each of attributes for the file
    #

    my $self = shift;

    # Place to build up the form
    my $out = '';
    # Foreach attribute name...
    foreach my $attr_name ($self->attribute_keys) {
	# See if we have a value with that name, and if not, see if we have
	# a template for it, and if not skip (!)
	my $attr = $self->get_attribute_values ($attr_name) ||
	    $self->get_attributes ($attr_name) or next;
	# Make a little form bloblet, and tack it on to our output value
	$out .= $attr->out_html_form (@_);
    }
    # Return the output value
    return $out;
}

sub attribute_fdat_hash {
    #
    # Return key/val pairs for the attributes of a tag
    #

    my $self = shift;
    my @attr_list = ();
    # For each attribute name
    foreach my $attr_name ($self->attribute_keys) {
	# See if we have a value
	my $attr = $self->get_attribute_values ($attr_name);
	# And if not, get a raw attribute
	$attr ||= $self->get_attributes ($attr_name);
	next unless $attr;
	# Find the value (or the default)
	my $val;
	$val = $self->value || $self->default;
	# And if we have a value, then push the right thing onto the list
	push @attr_list, sprintf("%s:a_%s", $self->tag, $attr->name), $val
	    if $val;
    }
    return @attr_list;
}

sub attribute_validate {
    #
    # Go through the set of attributes, and make sure the required ones are
    # set.
    #

    my $self = shift;
    # Get a list of the attributes which are required
    my @required = grep { $_->required } $self->get_attributes;
    # Get the values for the required attributes
    my @req_values = $self->get_attribute_values (map {$_->name} @required);
    # Count the required attributes that have undefined values
    my $problems = grep { not defined $_ } @req_values;
    # And return 0 if there are any, and 1 if there are none
    return $problems ? 0 : 1;
}

# 
# Input functions
#

# A file-global parser, since we only need it once, we only have to define
# it once
my $parser = undef;

sub parse {
    #
    # Do the business of taking a bunch of stuff and making it an object
    # of the right type.
    #

    # Get the object and make sure it's an object
    my $self = shift;

    # Get the incoming text, and make sure it's there
    my $intext = join('', @_) or die "Could not find text to parse";

    # Make the parser, and parse it
    $parser = new XML::Parser (Style=>'Tree') unless $parser;
    my ($intag, $vals) = @{$parser->parse ($intext)};
    $intag eq $self->tag or die "$self is not a $intag";
    $self->in_xml_tree (@$vals);
}

sub parsefile {
    #
    # Do the same parsing bit, only do it on a file rather than a bit of text,
    # using XML::Parser::parsefile().
    #

    my $self = shift;
    my $filename = shift or return;

    # Make the parser, and do it
    $parser = new XML::Parser (Style=>'Tree') unless $parser;
    my ($intag, $vals) = @{$parser->parsefile ($filename)};
    $intag eq $self->tag or die "$self is not a $intag";
    $self->in_xml_tree (@$vals);
}

sub out_xhtml {
    #
    # Give a big HTML output
    #

    my $self = shift;

    # In this case, we call out_xml, but we set the do_xhtml flag
    return $self->out_xml (undef, 1);
}

package HSDB4::XML::SimpleElement;
use strict;
use vars qw(@ISA);
@ISA = qw(HSDB4::XML);

#
# Input functions
#

sub in_xml_tree {
    # 
    # Read in a branch of an XML tree
    #

    my $self = shift;

    # Arguments after object should be like...
    #    ({attr1 => 'val', attr2 => 'val2'}, 0, "this is the real value")
    my ($inattrs, $zero, $value) = @_;
    # Return without doing anything unless $zero is 0, because we're barking
    # up the wrong tree
	die "HSDB4::XML::SimpleElement got a bad set of arguments" 
	unless (!defined $zero || $zero == 0);

    # Actually set the incoming attributes
    $self->set_attributes (%$inattrs);
    # And then set the value
    $self->{value} = $value;
}

sub set_value {
    my $self = shift;
    my $val = shift;
    $self->{value} = $val;
}

sub in_fdat_hash {
    #
    # Take in a pair, and use it to set the value
    #

    # Get the object and make sure it's an object
    my $self = shift;

    my @attr_list = ();
    # Get the values
    while (my ($tag, $val) = splice (@_, 0, 2)) {
	if ($tag eq $self->tag) {
	    $self->{value} = $val;
	}
	elsif ($tag =~ /^a_(.+)$/) {
	    push @attr_list, $1, $val;
	}
	else {
	    die "Wrong tag ($tag) for ::SimpleElement::in_fdat_hash()";
	}
    }
    $self->set_attributes (@attr_list) if @attr_list;
}

#
# Accessor functions
#

sub value {
    #
    # Return the value from the object
    #

    my $self = shift;

    # ...and return the value
    return $self->{value};
}

#
# Output functions
#

sub out_xml {
    #
    # Return the object as an XML-ized tag
    #

    my ($self, $writer, $do_xhtml) = @_;

    # Make up the XML::Writer if we don't have it, and allocate someplace for
    # it to put its business
    my $outvar = '';
    my $iostring;
    unless ($writer) {
	$iostring = new IO::Scalar \$outvar;
	$writer = new XML::Writer (OUTPUT => $iostring,
				   NEWLINES => 1);
	# A DTD would go here if I knew how to make them
	$writer->xmlDecl() unless $do_xhtml;
    }

    # Check to see if we're doing an XHTML translation (if the flag is set
    # and we have a filter to do it with).
    if ($do_xhtml && $self->{xhtml_filter}) {
	&{$self->{xhtml_filter}} ($self, $writer);
    }
    # Otherwise, just make our tag
    else { 
	$writer->startTag ($self->tag, $self->attribute_hash); 
	$writer->characters ($self->value);
	$writer->endTag;
    }

    # Are we supposed to return something?
    if ($outvar) {
	$writer->end;
	return $outvar;
    }
}

sub out_fdat_hash {
    # 
    # Return a pair for putting into a %fdat hash
    #

    my $self = shift;
    my @outlist = ();
    push @outlist, $self->attribute_fdat_hash;
    push @outlist, $self->tag, $self->value if $self->value;
    return @outlist;
}

sub out_html_value {
    # 
    # Return an HTML-ized value for this object, if possible
    #

    my $self = shift;

    # If we don't have a filter, then don't worry about it
    return $self->value unless $self->{html_filter};

    # But if we do, then call it on the value and return that
    return &{$self->{html_filter}} ($self->value);
}

sub out_html_row {
    #
    # Output the data as a row in an HTML table to be used in displaying
    # the whole XML tree.
    #

    my $self = shift;
    my $lastrow = shift || '';

    # Skip it unless we have a value
    return unless $self->value;

    # Make up the row...
    my $out;
    $out = sprintf("<tr><td align=\"RIGHT\"><b>%s:</b></td>\n", 
		   $self->tag eq $lastrow ? '&nbsp;' : $self->label);
    $out .= sprintf ("<td>%s</td>", $self->out_html_value);

    # ...and return it
    return $out;
}

sub out_html_form_input {
    # 
    # Return the actual business of an HTML form, with the appropriate
    # name, etc. This can be overridden if it's appropriate, obviously
    #

    my $self = shift;

    # Figure out the form name
    my ($prefix, $index) = @_;
    $index = 0 unless defined $index;
    my $name = defined $prefix ? "$prefix:$index:"  : '';
    $name .= $self->tag;

    return sprintf ("<input type=\"TEXT\" name=\"%s\" size=\"50\" value=\"%s\">",
		    $name, $self->value);
}

sub out_html_form_row {
    #
    # Return a row for an HTML table with a label name, etc.
    #

    # Get the object and make sure it's an object
    my $self = shift;

    # Figure out the form name
    my ($prefix, $index) = @_;
    $index = 0 unless defined $index;
    my $name = defined $prefix ? "$prefix:$index:"  : '';
    $name .= $self->tag;

    # Make up the output data
    my $out;
    $out = sprintf("<tr><td align=\"RIGHT\">%s:</td>\n", 
		   $self->label);
    $out .= sprintf ("<td>%s", $self->out_html_form_input (@_));

    # Put the inputs for the attributes, if applicable
    my $attr = $self->attribute_html_form ($name);
    $out .= "<br>\n$attr" if $attr;

    $out .= "</td></tr>\n";
    return $out;
}

#
# Validation
#

sub validate {
    #
    # Decide if the tag is valid; for such a simple tag, this means that
    # all the required attributes have values
    #

    my $self = shift;
    return $self->attribute_validate;
}

package HSDB4::XML::EmptyElement;
use strict;
use vars qw(@ISA);
@ISA = qw(HSDB4::XML);

#
# Input functions
#

sub in_xml_tree {
    # 
    # Read in a branch of an XML tree
    #

    my $self = shift;

    # Arguments after object should be like...
    #    ({attr1 => 'val', attr2 => 'val2'}, 0, "this is the real value")
    my ($inattrs, $zero, $value) = @_;
    # Return without doing anything unless $zero is 0, because we're barking
    # up the wrong tree
    die "HSDB4::XML::SimpleElement got a bad set of arguments" 
	unless $zero == 0;

    # Actually set the incoming attributes
    $self->set_attributes (%$inattrs);

    # And then don't do anything else
    return $self;
}

sub in_fdat_hash {
    #
    # Take in a pair, and use it to set the value
    #

    # Get the object and make sure it's an object
    my $self = shift;

    my @attr_list = ();
    # Get the attributes
    while (my ($tag, $val) = splice (@_, 0, 2)) {
	if ($tag =~ /^a_(.+)$/) {
	    push @attr_list, $1, $val;
	}
	else {
	    die "Wrong tag ($tag) for ::SimpleElement::in_fdat_hash()";
	}
    }

    $self->set_attributes (@attr_list) if @attr_list;
}

#
# Accessor functions
#

sub value {
    #
    # Return the value from the object
    #

    my $self = shift;

    return undef;
}

#
# Output functions
#

sub dtd_definition {
    my $self = shift;
    return $self->{dtd_definition} ? $self->{dtd_definition} : 'EMPTY';
}

sub out_xml {
    #
    # Return the object as an XML-ized tag
    #

    my ($self, $writer, $do_xhtml) = @_;

    # Make up the XML::Writer if we don't have it, and allocate someplace for
    # it to put its business
    my $outvar = '';
    my $iostring;
    unless ($writer) {
	$iostring = new IO::Scalar \$outvar;
	$writer = new XML::Writer (OUTPUT => $iostring,
				   NEWLINES => 1);
	# A DTD would go here if I knew how to make them
	$writer->xmlDecl() unless $do_xhtml;
    }

    # Check to see if we're doing an XHTML translation (if the flag is set
    # and we have a filter to do it with).
    if ($do_xhtml && $self->{xhtml_filter}) {
	&{$self->{xhtml_filter}} ($self, $writer);
    }
    # Otherwise, just make our tag
    else { 
	$writer->emptyTag ($self->tag, $self->attribute_hash);
    }

    # Are we supposed to return something?
    if ($outvar) {
	$writer->end;
	return $outvar;
    }
}

sub out_fdat_hash {
    # 
    # Return a pair for putting into a %fdat hash
    #

    my $self = shift;
    my @outlist = ();
    push @outlist, $self->attribute_fdat_hash;
    push @outlist, $self->tag, 1;
    return @outlist;
}

sub out_html_value {
    # 
    # Return an HTML-ized value for this object, if possible
    #

    my $self = shift;

    return 'Present' unless $self->{html_filter};

    # But if we do, then call it on the value and return that
    return &{$self->{html_filter}} (1);
}

sub out_html_row {
    #
    # Output the data as a row in an HTML table to be used in displaying
    # the whole XML tree.
    #

    my $self = shift;
    my $lastrow = shift || '';

    # Skip it unless we have a value
    return unless $self->value;

    # Make up the row...
    my $out;
    $out = sprintf("<tr><td align=\"RIGHT\"><b>%s:</b></td>\n", 
		   $self->tag eq $lastrow ? '&nbsp' : $self->label);
    $out .= sprintf ("<td>%s</td>", $self->out_html_value);

    # ...and return it
    return $out;
}

sub out_html_form_input {
    # 
    # Return the actual business of an HTML form, with the appropriate
    # name, etc. This can be overridden if it's appropriate, obviously
    #

    my $self = shift;

    # Figure out the form name
    my ($prefix, $index) = @_;
    $index = 0 unless defined $index;
    my $name = defined $prefix ? "$prefix:$index:"  : '';
    $name .= $self->tag;

    return sprintf ("<input type=\"checkbox\" name=\"%s\" value=\"%s\">",
		    $name, $self->tag);
}

sub out_html_form_row {
    # 
    # Return a row for an HTML table with a label name, etc.
    #

    # Get the object and make sure it's an object
    my $self = shift;

    # Figure out the form name
    my ($prefix, $index) = @_;
    $index = 0 unless defined $index;
    my $name = defined $prefix ? "$prefix:$index:"  : '';
    $name .= $self->tag;

    # Make up the output data
    my $out;
    $out = sprintf("<tr><td align=\"right\">%s:</td>\n", 
		   $self->label);
    $out .= sprintf ("<td>%s", $self->out_html_form_input (@_));

    # Put the inputs for the attributes, if applicable
    my $attr = $self->attribute_html_form ($name);
    $out .= "<br>\n$attr" if $attr;

    $out .= "</td></tr>\n";
    return $out;
}

#
# Validation
#

sub validate {
    #
    # Decide if the tag is valid; for such a simple tag, this means that
    # all the required attributes have values
    #

    my $self = shift;
    return $self->attribute_validate;
}

package HSDB4::XML::Element;
use strict;
use vars qw(@ISA);
use CGI::Carp;
@ISA = qw(HSDB4::XML);

#
# Constructor
#

sub new {
    #
    # Create a more complicated element which takes in a bunch of values,
    # which can either be simple things or more complicated ones.
    #

    # $self is the first argument, which might be a class name, but that
    # doesn't matter at this level; either way, it gets bumped up to the
    # superclass's constructor, which does the work
    my $self = shift;

    # The rest of the arguments are the same as to HSDB4::XML::Element, except
    # there's also -subelements, which looks like...
    #   -subelements => [ [ $template1 ],
    #                     [ $template2, 0, 2],
    #                     [ $template3, 1] ],
    # ...where the order matters. The first argument is an HSDB4::XML
    # template object (either ::SimpleElement or ::Element). The first number
    # is the *minimum* number of objects of this type.  The second
    # number is the *maximum* number of objects of this type.  If 
    # neither number is given, the numbers are assumed to be 0 and 1,
    # respectively. If only one number is given, it is assumed to be
    # a minimum with no maximum.  Therefore, in the above example,
    # $template1 can have either zero or one of the objects. $template2 can
    # have 0, 1, or 2 of the objects. And $template3 *must* have at least
    # one, but may have as many as necessary.

    my %arguments = @_;
    my $newself = $self->SUPER::new (@_);

    # Check to see if #PCDATA is allowed
    if ($arguments{-allow_pcdata}) {
	$newself->{allow_pcdata} = $arguments{-allow_pcdata};
    }
    elsif (ref $self) {	$newself->{allow_pcdata} = $self->{allow_pcdata} }
    else { $newself->{allow_pcdata} = 0 }

    # Elements deal in arrays instead of scalars
    $newself->{value} = [];

    # Got to get the subelements array... it's similar (sort of) to the
    # attributes array from before...Get it from
    # the argument '-subelements', from the template object, or make it
    # a new empty references
    if ($arguments{-subelements} && ref $arguments{-subelements} eq 'ARRAY') {
	$newself->new_subelements ($arguments{-subelements});
    }
    elsif (ref $self) {
	# It's an object, so we can just copy the references over
	$newself->{_classindex} = $self->{_classindex};
	$newself->{_min_counts} = $self->{_min_counts};
	$newself->{_max_counts} = $self->{_max_counts};
	$newself->{_formorder}  = $self->{_formorder};
    }
    else {
	# Otherwise, we assume that they're blank, not that that makes
	# any sense
	$newself->{_classindex} = {};
	$newself->{_min_counts} = {};
	$newself->{_max_counts} = {};
	$newself->{_formorder}  = [];
    }

    # Return our newly created object
    return $newself;
}

sub new_subelements {
    #
    # Do the business of setting up the subelements given a list structure
    # as detailed for new.
    #

    my $self = shift;
    my $subelements = shift;
    ref $subelements eq 'ARRAY' or return;
    @{$self}{'_classindex', '_min_counts', '_max_counts', '_formorder'} =
      $self->construct_indices ($subelements);
}

sub construct_indices {
    #
    # Convenience function for forming indices from the constructor's
    # -subelements argument
    #

    # Read in the class name
    my $class = shift;

    # Read in the subelements arrayref
    my $subelements = shift;

    # Convenience indices---this is not the way to do this, because we recreate
    # these anew for each object, not for the class. We should create these
    # once for each new class that we use.
    my %classindex = ();
    my %mins = ();
    my %maxs = ();
    my @formorder = ();
    foreach (@$subelements) { 
	my ($template, $min, $max) = @$_;
	if (not defined $min and not defined $max) { ($min, $max) = (0, 1) }
	elsif (not defined $max) { $max = 0 }
	my $tag = $template->tag;
	$classindex{$tag} = $template;
	$mins{$tag} = $min;
	$maxs{$tag} = $max;
	push @formorder, $tag;
    }
    return (\%classindex, \%mins, \%maxs, \@formorder);
}

#
# Input functions
#

sub in_xml_tree {
    #
    # Read in an branch of an XML Tree
    #

    my $self = shift;

    # Arguments after object should be like...
    #   ( { attr1 => 'val', attr2 => 'val' },
    #     'tag', [ { ... attrs ...},
    #              0, "value" ],
    #     'tag_again', [ {},
    #                    'tag', [ { attrs }, 0, "value" ],
    #                    'tag', [ { attrs }, 0, "value" ] ],
    #     0, 'value'
    #   )

    # Store away the attributes
    my $inattrs = shift;
    my @invals;
    # Make a place to put our values and start making the values
    while (my ($tag, $data) = splice (@_, 0, 2)) {
	# If tag is '0', it's just a string to push onto our list, but we
	# can only do that if allow_pcdata is set to true;
	if ($tag eq '0') {
	    # This is fine if we take #PCDATA
	    if ($self->{allow_pcdata}) {
		push @invals, $data if $data =~ /\S/;
	    }
	    # Otherwise, we just ignore it
	}
	# Otherwise, we need to figure out which class it is, make a new
	# object of that class, and snarf the data with it, and push the
	# new object onto our list.
	else {
	    my $class = $self->{_classindex}{$tag} 
	      or die "Bad tag: <$self->{tag}> does not take <$tag>";
	    my $newobj = $class->new or die "Couldn't make a $class object";
	    $newobj->in_xml_tree (@$data);
	    push @invals, $newobj;
	}
    }

    # If we survived to here, we can set the values
    # Actually set the incoming attributes
    $self->set_attributes (%$inattrs);
    # And then push things onto the value list
    push @{$self->{value}}, @invals;
}

sub in_fdat_hash {
    #
    # Take in the pairs and stick the appropriate values in
    #

    my $self = shift;

    # We're going to take the incoming pairs of fdat keys and values
    # and sort them.  There's a bunch of redundancy in there, obviously.
    # The idea is to sort them from this...
    #   mytag:0:zero_subtag:1:one_subsubtag => value
    #   mytag:0:zero_subtag:0:zero_subsubtag => value
    #   mytag:2:two_subtag:0:subsubtag => value
    #   mytag:1 => value
    # into this:
    #   ( [ zero_subtag,
    #       zero_subtag:1:one_subsubtag => value,
    #       zero_subtag:0:zero_subsubtag => value ],
    #     [ 0, value ],
    #     [ two_subtag,
    #       two_subtag:0:subsubtag => value ]
    #   )
    # so that we can then recursively call in_fdat_hash() with the right
    # bunch of arguments.
    my @attr_list = ();
    my @sublists = ();
    # For each pair coming in...
    while (my ($key, $val) = splice (@_, 0, 2)) {
	# Get break off the front tag and index and leave the subkey
	my ($tag, $ind, $subkey) = split /:/, $key, 3;
	# Forget it unless we've got the right tag
	next unless $tag eq $self->tag;
	if ($ind =~ /^a_(.+)$/) {
	    push @attr_list, $1, $val;
	    next;
	}
	# If we haven't previously done a tag like this...
	unless (defined $sublists[$ind]) {
	    # Get the subtag name
	    my ($subtag) = split /:/, $subkey;
	    # And initialize the sublist entry
	    $sublists[$ind] = [ $subtag ];
	}
	# Push the actual subkey/value pair onto the list
	push @{$sublists[$ind]}, $subkey, $val;
    }

    $self->set_attributes (@attr_list) if @attr_list;

    my $count = -1;
    foreach (@sublists) {
	$count++;
	next unless $_;
	my @sublist = @$_;
	my $tag = shift @sublist;
	# If the tag is '0', then it's just a value, without any tags 
	if ($tag eq '0') { 
	    $self->{value}[$count] = $sublist[0];
	    next;
	}
	# Make sure that the right kind of thing is in the right place
	if (not defined $self->{value}[$count] or
	       not ref $self->{value}[$count] or
	       $self->{value}[$count]->tag ne $tag) {
	    my $class = $self->{_classindex}{$tag} or die "Unacceptable tag";
	    my $newobj = $class->new or die "Couldn't make a $class object";
	    $self->{value}[$count] = $newobj;
	}
	$self->{value}[$count]->in_fdat_hash (@sublist);
    }

    # Deal with undefineds, etc, running around
    $self->clean_up;
}

#
# Accessor functions
#   (In addition to those inherited...)
#

sub clean_up {
    #
    # Clean up the tree of objects to get rid of blanks, especially those
    # caused by inputting hashes
    #

    my $self = shift;

    # Make a list for the elements that pass muster
    my @newlist = ();
    # Go through the values, one by one
    foreach my $subelement ($self->value) {
	# Skip them if they're not defined
	next unless defined $subelement;
	# If the subelement can do a clean_up, make sure it returns
	# a true value
	if ($subelement->can('clean_up')) {
	    push @newlist, $subelement if $subelement->clean_up;
	}
	# If it can't, it should be pushed on if it's defined
	else { push @newlist, $subelement }
    }
    # Make our new list the official value list
    $self->{value} = \@newlist;
    # And return the number of items in it
    return scalar(@newlist);
}

sub value {
    # 
    # Return either the whole list of values, or a slice from the list
    # of values or a single value. The arguments are indices into the
    # list of values.
    #

    my $self = shift;

    # If we have more than one argument...
    if (@_ > 1) {
	# ...then we'll treat them as indices into our array of values
	return @{$self->{value}}[@_];
    }
    # ...and if we have just one argument...
    elsif (@_ == 1) {
	# ...then just return that single value
	return $self->{value}[$_[0]];
    }
    # ...otherwise, we'll just return the whole list of values
    return @{$self->{value}};
}

sub xml_push {
    my $self = shift;
    push @{$self->{value}}, @_;
}

sub xml_splice {
    my $self = shift;
    splice @{$self->{value}}, @_;
}

sub xml_insert {
    my $self = shift;
    my $index = shift;
    splice (@{$self->{value}}, $index, 0, @_);
}

sub clear_contents {
    my $self = shift;
    $self->{value} = [];
}

sub tag_values {
    #
    # Get the values in the set which are of a particular tag type
    #

    my $self = shift;
    
    my $tag = shift or return;
    foreach ($self->value) { 
	carp join ("\n", $self->value) . "Undefined value in tag_values!" unless defined $_;
    }
    my @array = grep { $_->tag eq $tag } $self->value;
    return wantarray ? @array : $array[0];
}

#
# Output functions
#

sub out_xml {
    #
    # Return the object as an XML-ized tag
    #

    my ($self, $writer, $do_xhtml) = @_;
    
    # Make up the XML::Writer if we don't have it, and allocate someplace for
    # it to put its business
    my $outvar = '';
    my $iostring;
    unless ($writer) {
	$iostring = new IO::Scalar \$outvar;
	$writer = new XML::Writer (OUTPUT => $iostring,
				   NEWLINES => 1);
	# A DTD would go here if I knew how to make them
	$writer->xmlDecl() unless $do_xhtml;
    }

    # Check to see if we're doing an XHTML translation (if the flag is set
    # and we have a filter to do it with).
    if ($do_xhtml && $self->{xhtml_filter}) {
	&{$self->{xhtml_filter}} ($self, $writer);
    }
    # Otherwise, just descend the tree
    else { 
	$writer->startTag ($self->tag, $self->attribute_hash);
	# Go through the value list
	foreach my $node ($self->value) {
	    next unless $node;
	    # If it's a object, then get it to write itself to the writer
	    if (ref $node) { $node->out_xml ($writer, $do_xhtml) }
	    # Otherwise, just put the text blob onto the list
	    else { $writer->characters ($node) if $node =~ /\S/ }
	}
	$writer->endTag;
    }

    # Is it our responsibility to return something?
    if ($outvar) {
	$writer->end;
	return $outvar;
    }
}

sub tag_quantifier {
    #
    # Return ?, +, or * based on min/max counts of a given sub-tag
    #

    my $self = shift;
    my $tag = shift;

    my $quant = '';
    # Get the min/max
    my $min = $self->{_min_counts}{$tag};
    my $max = $self->{_max_counts}{$tag};
    # If the min is 0, then we can only care about * or ?
    if ($min <= 0) { $quant = $max == 1 ? '?' : '*' }
    # If the min is more than zero, we only care if we can have more than one
    else { $quant = '+' unless $max == 1 }
    # Now return the value
    return $quant;
}

sub dtd_definition {
    #
    # Return the information for the DTD after the tag name. If it isn't 
    # explicitly spelled out, figure it out as well as possible from the 
    # parameters.
    #

    my $self = shift;

    # Return an explicit one
    return $self->{dtd_definition} if $self->{dtd_definition};

    # Return the subtags in formorder, quantified as well as possible
    my @sub_els = map {$_ . $self->tag_quantifier($_)} @{$self->{_formorder}};
    unshift @sub_els, '#PCDATA' if $self->{allow_pcdata};

    return join (', ', @sub_els);
}

sub out_dtd {
    #
    # Return a DTD for this element
    #

    my $self = shift;

    # Get the main definition
    my $info =  $self->SUPER::out_dtd();

    # Now, tack on all the sub elements as needed
    for my $tag (@{$self->{_formorder}}) {
	my $el = $self->{_classindex}{$tag};
	$info .= "\n\n" . $el->out_dtd;
    }
    return $info;
}

sub out_fdat_hash {
    #
    # Makes a big list of key value pairs, where the values are the
    # values in the tags, and the keys are of the form:
    #   tagname:3:subtagname:2:subsubtagname
    # and the values which can then be read back in
    #

    my $self = shift;

    # Get some handy variables
    my $tag = $self->tag;
    my $count = 0;
    my @pairs = $self->attribute_fdat_hash;
    # For each subvalue...
    for my $val ($self->value) {
	# If it's a reference...
	if (ref $val) {
	    # ...get its fdat_hash, and prepend "$tag:$count" to all its
	    # keys, and push the new pairs onto the current list
	    my @subhash = $val->out_fdat_hash;
	    while (my ($key, $val) = splice (@subhash, 0, 2)) {
		push @pairs, "$tag:$count:$key", $val;
	    }
	}
	# But if it's just a string...
	else {
	    # ...then just make a simple key, and push that value onto our list
	    push @pairs, "$tag:$count", $val;
	}
	# Increment the count
	$count++;
    }
    # Now, return the list we built up
    return @pairs;
}

sub out_html_form_input {
    # 
    # Return the actual business of an HTML form, with the appropriate
    # name, etc. This can be overridden if it's appropriate, obviously
    #

    my $self = shift;

    # Figure out the form name
    my ($prefix, $index) = @_;
    $index = 0 unless defined $index;
    my $name = defined $prefix ? "$prefix:$index:"  : '';
    $name .= $self->tag;

    my $out = "<table border=\"0\">\n";
    my $count = 0;
    foreach my $tag (@{$self->{_formorder}}) {
	my @tagvals = $self->tag_values ($tag);
	my $tagcount = 0;
	foreach my $val (@tagvals) {
	    if ($val->can('out_html_form_row')) {
		$out .= $val->out_html_form_row ($name, $count);
	    }
	    else {
		$out .= "<tr><td width=\"40\">&nbsp;</td>\n";
		$out .= "<td><text name=\"$name:$count\" value=\"$val\"";
		$out .= "size=\"50\"></td></tr>\n";
	    }
	    $count++;
	    $tagcount++;
	}
	my $max = $self->{_max_counts}{$tag};
	$max = $tagcount + 1 if $max == 0;
	if ($tagcount < $max) {
	    my $newval = $self->{_classindex}{$tag}->new;
	    foreach ($tagcount..$max-1) {
		$out .= $newval->out_html_form_row ($name, $count);
		$count++;
	    }
	}
    }
    $out .= "</table>\n";
		       
    return $out;
}

sub out_html_form_row {
    # 
    # Return a pair of rows for an HTML table with a label name, etc.
    #

    my $self = shift;

    # Figure out the form name
    my ($prefix, $index) = @_;
    $index = 0 unless defined $index;
    my $name = defined $prefix ? "$prefix:$index:"  : '';
    $name .= $self->tag;

    # Make up the output data
    my $out;
    $out = sprintf("<tr><td colspan=\"2\"><div class=\"TITLE\">%s:</div></td></tr>\n", 
		   $self->label);

    # Put the inputs for the attributes, if applicable
    my $attr = $self->attribute_html_form($name);
    $out .= "<tr><td colspan=\"2\">$attr</td></tr>\n" if $attr;

    $out .= "<tr><td width=\"40\">&nbsp;</td>\n";
    $out .= sprintf ("<td>%s</td></tr>\n", $self->out_html_form_input (@_));

    return $out;
}

sub out_html_row {
    # 
    # Return a pair of rows for an HTML table with a label name, etc.
    #

    my $self = shift;
    my $class = shift;
    $class = "TITLE" unless $class;
    # Make up a list of data for the sub-table, if necessary
    my @rows;
    # For each of the values
    my $lastrow = '';
    foreach my $val ($self->value) {
	# Skip it if it's blank or undefined
	next unless $val;
	# If it's a reference, then get its row
	if (ref $val && $val->can('out_html_row')) { 
	    push @rows, $val->out_html_row ($lastrow);
	    $lastrow = $val->tag;
	}
	# Otherwise, it's just a value, and we can make up a row for that
	else { push @rows, "<tr><td>&nbsp;</td><td>$val</td></tr>\n" }
    }
    # If there are no rows, then there's nothing to return
    return unless @rows;
    
    # Make up the output data
    my $out;
    # Header row
    $out = sprintf("<tr><td colspan=\"2\"><div class=\"%s\">%s:</div></td></tr>\n",$class, 
		   $self->label);
    # Blank cell
    $out .= "<tr><td width=\"40\">&nbsp;</td>\n";
    # Cell with the subtable 
    $out .= sprintf ("<td><table class=\"%s\" border=\"0\">%s\n</table></td></tr>\n",$class,  
		     join ("\n", @rows));
    # And that'll do it
    return $out;
}

#
# Validation
#

sub validate {
    #
    # Decide if the tag is valid by checking the attributes and then
    # checking all of the required sub-elements recursively
    #

    my $self = shift;
    # First, check the attributes are OK
    return 0 unless $self->attribute_validate;

    # Now, count up what we've got
    my %tagcount = ();
    foreach my $element ($self->value) {
	next unless ref $element;
	# If a sub-element isn't valid, then we aren't either, so 
	# invalidate right here
	return 0 unless $element->validate;
	$tagcount{$element->tag}++;
    }

    # Now check to see if we have what we should have
    foreach my $tag (@{$self->{_formorder}}) {
	$tagcount{$tag} = 0 unless exists $tagcount{$tag};
	# Invalidate if we have too few
	return 0 unless $tagcount{$tag} >= $self->{_min_counts}{$tag};
	# Invalidate if we have too many
	return 0 unless $tagcount{$tag} <= $self->{_max_counts}{$tag};
    }

    # Phew! We've run the gauntlet!
    return 1;
}

__END__

=head1 NAME

B<HSDB4::XML> - Classes for dealing with HSDB4's XML blobs

=head1 DESCRIPTION

HSDB4-based clases for snarfing up XML, manipulating it, spitting it
out, converting it to HTML forms, taking in data from HTML
forms... the whole bit.

=head1 SYNOPSIS

    use HSDB4::XML;

    # Attribute definitions
    my $attr1 = 
      HSDB4::XML::Attribute->new (-name => 'attrname1',
				  -label => 'First Attribute Name',
				  -required => 0,
				  -fixed => 0,
				  );
    my $attr2 = 
      HSDB4::XML::Attribute->new (-name => 'attrname2',
				  -choices => {choice1 => 'Label One',
					       choice2 => 'Label Two',
					       choice3 => 'Label Three'},
				  -label => 'Attribute Name'
				  -default => 'choice1',
				  -required => 1,
				  );
    my $id_attr = 
      HSDB4::XML::Attribute->new (-name => 'attr_id',
				  -label => 'ID Attribute',
				  -id_attribute => 1,
				  );
    
    # A simple XML element definition
    my $el1 =
      HSDB4::XML::SimpleElement->new (-tag => 'element_one',
				      -label => 'First Element',
				      -attributes => [ $attr1 ],
				      -html_filter => \&filtersub,
				      );
    
    # Define a more complicated element
    my $element = 
      HSDB4::XML::Element->new ( -tag => 'element_two',
				 -label => 'Second Element',
				 -attributes => [ $attr1, $attr2 ],
				 #                   Elem  Min  Max
				 #                   ----  ---  ---
				 -subelements => [ [ $el1,  0,   1 ],
						   [ $el2,  1,   1 ],
						   [ $el3,  0      ],
						   [ $el4,  1      ],
						   [ $el5,  2      ] ],
				 );

    # Actual uses of the objects...

    # Create an actual working object from the template
    my $root = $element->new;
    # Get the data in an XML file
    $root->parsefile ('filename.xml');

    # Now make a big HTML form with it...
    print "<FORM METHOD=\"POST\"><TABLE>\n",
    $root->out_html_form_row,
    "</TABLE></FORM>\n";

    # If HTML::Embperl gave us an %fdat hash of the user's 
    # interaction with our form, we can reset the object
    $root->in_fdat_hash (%fdat);

    die "Not valid!" unless $root->validate;

    # And print a nice HTML display of the object
    print "<TABLE>\n", $root->out_html_row, "</TABLE>";

    # And we could use this to save back to our XML file...
    open XML, ">filename.xml" or die "Could not open filename.xml";
    print XML $root->out_xml;
    close XML;

=head1 HSDB4::XML::Attribute

An attribute for a XML element.  There are facilities to hold
multiple-choice and free-form sorts of responses in these right now.
These are designed to be part of either an XML::Element or
XML::SimpleElement.

=head2 Constructor

B<new()> creates a new attribute, either from the class name or a
template.  The arguments are C<(-key =E<gt> 'value')> pairs.  C<-name> is a
scalar, and is the actual XML tag name.  This is required when calling
as a class method rather than a object method. C<-default> is a scalar
which is the default value of the attribute. C<-choices> is a hash
reference with the actual XML values as keys, and labels for user
presentation as the values.  C<-label> is a label for the attribute
for user presentation. C<-id_attribute>, C<-required>, and C<-fixed>
are all Boolean flags.  C<-required> and C<-fixed> determine whether
an attribute must be set to be valid and whether it should be
non-editable, respectively.  C<-id_attribute> implies both
C<-required> and C<-fixed>, and it indicates that the attribute is an
XML ID attribute. (Note: for now, there is no more functionality than
this with the ID attribute setting.)

=head2 Accessor Functions

B<name()>, B<label()>, B<required()>, B<fixed()>, B<id_attribute()>
and B<default()> are all simple accessor functions to retrive the
attribute's data.

In addition B<value()> can be used to retrieve the attribute's current
value, or to set it when called with arguments.  When setting, the
value is checked against the possible choices. When setting to
multiple values, it is set to a space-joined string of all the inputs.

=head2 Output Functions

B<out_xml_string()> returns a simple C<key="val"> string for use in an
XML tag.

B<out_html_form()> returns a labeled HTML form for setting an
attribute, which should fit in with all of the other HTML forms in the
B<HSDB4::XML> library.  Will make a drop-down list if there are
choices, and will make a text box otherwise.


=head1 HSDB4::XML::SimpleElement, HSDB4::XML::Element

B<HSDB4::XML::SimpleElement> is a simple XML element (in DTD terms,
one which holds only PCDATA); it might also have attributes. The more
comples B<HSDB4::XML::Element>, which sub-elements, including its
simpler cousins.  The interface for the two classes is as similar as
possible for the sake of polymorphism.

=head2 Constructor

B<new()> is used to create a new object.  The philosophy is that
template objects will be created using a class method and then used to
spawn new objects with its object method to hold values.  B<new()>
takes its arguments in C<(-key =E<gt> 'value')> form.  C<-tag> is the XML
name of the tag. This is required when called as a class
method. C<-label> is a label for the tag to be used in user
presentations.  C<-attributes> is an array reference, holding a list
of B<HSDB4::XML::Attribute> objects.  C<-html_filter> is a reference
to a subroutine that takes a single value (the value of the element)
and formats it for display in HTML (for example, making an e-mail
address a link).  B<new()> will C<die> if it has a problem, so C<eval>
it if that's inconvenient for you.

For more complicated elements (B<HSDB4::XML::Element>), B<new()> has
an added dimension: sub-elements.  These are defined with the
C<-subelements> argument, and the value should look like

    -subelements => [ [ $template1 ],
                      [ $template2, 0, 2],
                      [ $template3, 1] ],

where the order matters. The first argument is an B<HSDB4::XML>
template object (either B<::SimpleElement> or B<::Element>). The first
number is the I<minimum> number of objects of this type.  The second
number is the I<maximum> number of objects of this type.  If neither
number is given, the numbers are assumed to be 0 and 1,
respectively. If only one number is given, it is assumed to be a
minimum with no maximum.  Therefore, in the above example, $template1
can have either zero or one of the objects. $template2 can have 0, 1,
or 2 of the objects. And $template3 I<must> have at least one, but may
have as many as necessary.

=head2 Accessor Functions

B<tag()> and B<label()> are used to get these properties of the object.

B<value()> is used to retrieve either the scalar value of a simple
element or the list of sub-element objects for a more complicated
element.

B<tag_values()> is defined for a more complicated element to return
the sub-element objects which have the tag which is given as the
argument to this method.

=head2 Attribute Manipulation

B<attribute_keys()> returns a list of the names of the attributes
which are associated with an element.

B<get_attribute_values()> for each attribute name given as an
argument, returns the value of the attribute for that tag or C<undef>
if the attribute is not defined for that tag.

B<set_attributes()> takes C<(key =E<gt> 'val')> pairs and sets the
attributes named C<key> to the value given by C<val>.  Note: this will
C<die> if it encounters a badly-named tag, so C<eval> it to catch
errors if that's a problem.

B<attribute_hash> returns a big set of C<(key, val>> pairs for the
subset of attributes for a tag which have values.

=head2 Input Functions

B<parse()> and B<parsefile()> are used to input actual XML code (from
a scalar and a file, respectively) into an object. They work by
instantiating an B<XML::Parser> and then recursively going through the
tree created by it.  They C<die> if there's a problem, so if you don't
like that, C<eval> them to catch errors.

B<in_fdat_hash()> is used to set the values of the object given a hash
as would be set from something like B<HTML::Embperl> after it makes a
form.  See B<out_html_form_row()> below.  This way, a simple process
is to use the top level object to generate a form and then use
C<%fdat> as an argument to B<in_fdat_hash()> to set all the values
from the results. (This also calls functions which will C<die> if
there's a problem.)

=head2 Output Functions

B<out_xml()> spits out an XML version of the element, including
attributes and sub elements.  Note that it uses B<XML::Writer>, so it
has all the well-formedness checks etc. that your installation of that
package does.

B<out_fdat_hash()> spits out C<name =E<gt> 'value'> pairs, where the
names are coded to reflect the position of an element (or attribute)
within a tree, and the value is the value of that element. Can be used
to preset C<%fdat> in B<HTML::Embperl>.

B<out_html_value()> returns a version of the value which has been
formatted with the element's HTML filter (defined using the
C<-html_filter> argument to B<new()>).

B<out_html_row()> returns a HTML table row of two columns where the
left side is a boldened label and the right side is the (filtered)
value of the object.  For more complex tags containing sub-elements,
the label is in a C<COLSPAN=2> row above, and the right column
contains a table, so that a very complicated tree is recursively
displayed easily, like:

    print "<TABLE BORDER=0>\n", $element->out_html_row, "</TABLE>";

B<out_html_form_row()> returns a HTML table row of two columns where
the left side is a label, and the right side is an form input for the
values. This is also recursive with subtables appear in the right
column for complicated elements, so you can make a big form with your
root element by doing,

    print "<FORM METHOD=\"POST\">\n<TABLE BORDER=0>\n", 
    $element->out_html_form_row,
    "</TABLE>\n</FORM>\n";

=head2 Validation

B<validate()> will return a true value if the element is valid (that
is, has the prescribed number of each sub-type and the required
attributes), and a false value otherwise.

=head1 TO DO/BUGS

=over 4

=item *

More thorough testing.

=item *

Make a C<canonical_order()> method to re-sort sub-elements in the
right order, with a appropriate numbers.

=item *

Spit out a DTD from an appropriate definition.  (This might be
hard...)

=back

=head1 SEE ALSO

L<HSDB4>, L<HSDB4::SQLRow>, L<XML::Parser>, L<HTML::Embperl>, L<XML::Writer>

=head1 AUTHOR

Tarik Alkasab <talkas01@tufts.edu>

=cut
