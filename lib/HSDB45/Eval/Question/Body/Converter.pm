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


# $Id: Converter.pm,v 1.32 2012-04-20 16:52:38 scorbe01 Exp $
# Package for converting old-style XML eval questions to new-style eval questions.
# Specifically, it maps one XML::Twig::Elt object (the one stored in the database)
# and makes a whole new one out of it.
# $Revision: 1.32 $
package HSDB45::Eval::Question::Body::Converter;

use strict;
use HSDB4::Constants;
# use HSDB45::Eval::Authoring;
use XML::Twig;
use XML::EscapeText::HSCML qw(:html);
use Carp;

# Description: Initalizes the converter by taking in an element object
# Input: The Eval::Question and XML::Twig::Elt representing the old <eval_question>
# Output: The new Converter object
sub new {
    my $class = shift;
    my $eval_question = shift;
    my $elt = shift;
    $class = ref $class || $class;
    my $self = {};
    $self->{-eval_question} = $eval_question;
    $self->{-elt} = $elt;
    $self->{-atts} = {};
    bless $self, $class;
    if ( not $self->check_for_manual() ) {
	$self->setup_element();
	$self->setup_attributes();
	$self->setup_choice_elts();
    }
    return $self;
}

# Description: Does a bunch of setting up attributes (required, etc.)
# Input: 
# Output: 
sub setup_attributes {
    my $self = shift;

    # Default answer
    if ($self->get_default_answer()) { 
	$self->set_attribute( 'default_answer' => $self->get_default_answer() );
    }
}

# Description: Check to see if the manual table has an entry for this question
# Input:
# Output: 1 if there's something there, 0 otherwise
sub check_for_manual {
    my $self = shift;
    my $db = HSDB4::Constants::get_school_db( $self->get_eval_question()->school() );
    my $query = sprintf( "SELECT new_body FROM %s.%s WHERE eval_question_id=?",
			 $db, 'eval_question_convert');
    my $dbh = HSDB4::Constants::def_db_handle();
    my $body;
    eval {
	my $sth = $dbh->prepare( $query );
	$sth->execute( $self->get_eval_question()->primary_key() );
	($body) = $sth->fetchrow_array();
    };
    if ($@) {
	return 0;
    }
    elsif ($body) {
	my $twig = XML::Twig->new( EmptyTags => 'normal',
				   PrettyPrint => 'indented',
				   comments => 'keep');

	$twig->parse( $body );
	$self->{-manual_elt} = $twig->first_elt();
	return 1;
    }
    else {
	return 0;
    }
}

# Description: Returns the manual Elt object if it's been set
# Input:
# Output: The Elt object itself
sub get_manual_elt {
    my $self = shift;
    return $self->{-manual_elt};
}


# Description: Sets an attribute value
# Input: Attribute name, and attribute value
# Output:
sub set_attribute {
    my $self = shift;
    my ($key, $val) = @_;
    $self->{-atts}->{$key} = $val;
}

# Description: Gets the attributes to set on the main Element
# Input:
# Output: The hash-ref of attributes
sub get_attributes {
    my $self = shift;
    return $self->{-atts};
}

# Description: Do a lookup to see if the question_type for this question has been 
#    set manually
# Input:
# Output: The value of the question_type if it's there
sub lookup_question_type {
    my $self = shift;
    # Somehow, use $self->eval_question in a lookup.
    # For now, just return null, as if we didn't find anything.
    return;
}

# Description: Returns the name of the new element of the object
# Input:
# Output: The element name
sub get_element {
    my $self = shift;
    return $self->{-element_name};
}

# Description: Sets the name of the new element
# Input: The new element name
# Output:
sub set_element {
    my $self = shift;
    my $new_name = shift;
    $self->{-element_name} = $new_name;
}

# Description: Takes a question_type attribute and figures out what 
#     the new question type should be.
# Input: 
# Output: The name of the new-style element
sub setup_element {
    my $self = shift;

    # This is where we'll check in some database table for more information
    # on this particular question
    if ($self->lookup_question_type) {
	return $self->lookup_question_type;
    }

    # Otherwise, we'll use the default mapping
    my $in_type = $self->get_question_type;
    my %TypeMap = ('fill-in' => 'FillIn',
		   'radio-box' => 'MultipleChoice',
		   'pop-up' => 'MultipleChoice', 
		   'instruction' => 'Instruction',
		   'title' => 'Title',
		   'check_box' => 'MultipleResponse',
		   'small_groups' => 'SmallGroupsInstructor');

    # Pop-ups are <MultipleChoice choice_style="dropdown">
    if ($in_type eq 'pop-up') {
	$self->set_attribute( 'choice_style' => 'dropdown' );
    }
    elsif ($in_type eq 'fill-in') {
	$self->set_attribute( 'longtext' => 'yes' );
    }
    
    $self->set_element( $TypeMap{$in_type} );
}

# Description: Returns the value of the question_type attribute
# Input:
# Output: String of the question_type
sub get_question_type {
    my $self = shift;
    return $self->get_elt()->att ('question_type');
}

# Description: Method for fixing up the screwed up text of these questions
# Input: The element for a wrapper, the (potentially) screwed up text
# Output: An Elt object which has bee parsed.
sub make_good_elt {
    my $self = shift;
    my $gi = shift;
    my $text = shift;

    $text = $html_flow->xml_escape($text);
    # $text = HSDB45::Eval::Authoring::fix_flow_text($text);

    my $twig = XML::Twig->new( EmptyTags => 'normal',
			       PrettyPrint => 'indented',
			       comments => 'keep');

    eval { $twig->parse( "<$gi>$text</$gi>" ); };
    if ($@) {
	print STDERR "*** XML Error: Couldn't deal with Eval Question " . 
	    $self->get_eval_question()->primary_key() . ".\n";
	print STDERR "    Text was:\n---\n";
	print STDERR $self->get_elt()->sprint();
	print STDERR "\n---\nElement was <$gi>\n";
	confess $@;
    }
    
    my $elt =  $twig->first_elt( $gi );
    return $elt;
}

# Description: Returns the question_text.
# Input:
# Output: An appropriate question_text Elt.
sub get_question_text_elt {
    my $self = shift;
    my $qt_elt = $self->get_elt()->first_child('question_text');

    my $q_text;
    if ($qt_elt) {
        $q_text = $qt_elt->text();
    }

    $qt_elt = $self->make_good_elt( 'question_text', $q_text );
    return $qt_elt;
}

# Description: Returns the question_label
# Input:
# Output: An appropriate question_label Elt.
sub get_question_label_elt {
    my $self = shift;
    my $qt_elt = $self->get_elt()->first_child('question_label');
    return unless $qt_elt;
    my $q_text = $qt_elt->text();
    return unless $q_text =~ /\S/s;
    $qt_elt = $self->make_good_elt( 'question_label', $q_text );
    return $qt_elt;
}

# Description: Determines whether the choice labels are just 'a', 'b', 'c'...
# Input:
# Output: 1 if they are, and 0 if they're not
sub is_alphabetical_choices {
    my $self = shift;
    my @choices = @_;
    my $letter = 'a';
    for my $choice_elt( @choices ) {
	my $label = $choice_elt->att( 'choice_label' );
	return 0 if $label ne $letter;
	$letter++;
    }
    return 1;
}

# Description: Gets an array of choice elements
# Input:
# Output: An array of XML::Twig::Elt objects representing the choices
sub get_choice_elts {
    my $self = shift;
    if ( not defined $self->{-choice_elts} ) { return }
    return @{$self->{-choice_elts}};
}

# Description: Adds an element to the other elements
# Input: Arguments to Elt constructor: $gi_name, \%opt_atts, @contents
# Output:
sub add_other_elt {
    my $self = shift;
    my $new_elt = XML::Twig::Elt->new (@_);
    if ( not defined $self->{-other_elts} ) { 
	$self->{-other_elts} = [ $new_elt ];
    }
    else {
	push @{$self->{-other_elts}}, $new_elt;
    }
}

# Description: Gets an array of other elemtns
# Input:
# Output: An array of XML::Twig::Elt objects representing the choices
sub get_other_elts {
    my $self = shift;
    if ( not defined $self->{-other_elts} ) { return }
    return @{$self->{-other_elts}};
}

# Description: Determines whether a question is really a YesNo question
# Input: 
# Output: 1 if it seems like a YesNo, 0 otherwise
sub is_yes_no {
    my $self = shift;
    my @choices = map { $_->text } @_;
    return 0 unless @choices == 2;
    if ($choices[0] =~ /\b[Yy]es\b/ && length($choices[0]) < 12 &&
	$choices[1] =~ /\b[Nn]o\b/ && length($choices[1]) < 12) {
	$self->set_element( 'YesNo' );
	return 1;
    }
    return 0;
}

# Description: Determines whether a question is really a NumericRating object
# Input: 
# Output: 1 if it seems like a NumericRating, 0 otherwise
sub is_numeric_rating {
    my $self = shift;
    my @choices = map { $_->text } @_;
    # Are there more than four choices?
    return 0 unless @choices > 4;
    # Do they all have numbers?
    for (@choices) { return 0 unless /^\W*\d/ }
    # Do the first and the last have other words?
    my ($first_word, $last_word, $mid_word);

    my $qt_elt = $self->get_elt()->first_child('question_text');
    my $q_text = $qt_elt->text();

    # Excluded question text words; this is for med school evals
    if ($q_text =~ /^average number of/i ||
	$q_text =~ /^hours per/i
	) { 
	return 0;
    }


    my $school = lc($self->get_eval_question()->school());
    # This is a Nutrition school thing
    if ($school eq 'nutrition') {
	my ($real_text, $low, $high) =
	    $q_text =~ /(^.+\.{3}).*\[(\w.+\w)\s*\<.*\>\s*(\w.+\w)\]/s;
	if ($real_text && $low && $high) {
	    $first_word = $low;
	    $last_word = $high;
	    $qt_elt->set_text( $real_text );
	    $self->set_attribute('show_numbers' => 'yes');
	}
    }

    unless ($first_word && $last_word) {
	($first_word) = $choices[0] =~ /^\W*\d\d?\W*(?:\()?(\w.+)(?:\))?/;
	($last_word) = $choices[-1] =~ /^\W*\d\d?\W*(?:\()?(\w.+)(?:\))?/;
	$first_word =~ s/\)$//;
	$last_word =~ s/\)$//;
	if (@choices % 2) {
	    ($mid_word) = $choices[@choices/2] =~ /^\W*\d\d?\W*(?:\()(\w.+)(?:\))/;
	}
    }
    return 0 unless $first_word && $last_word;
    # And do none of the others?
    # Belay this right now...
    # $first_word =~ /[Ss]trongly [Aa]gree/ && $last_word =~ /[Ss]trongly [Dd]isagree/
    # or $last_word =~ /[Ss]trongly [Aa]gree/ && $first_word =~ /[Ss]trongly [Dd]isagree/
    # or 
    if ($school ne 'phpd' and $school ne 'nutrition' and
  	($first_word =~ /[Nn]ot enough/ && $last_word =~ /[Tt]oo much/
  	 or $last_word =~ /[Nn]ot enough/ && $first_word =~ /[Tt]oo much/
  	 or $last_word =~ /\b[Tt]oo\b/ && $first_word =~ /\b[Tt]oo\b/
  	 or $first_word =~ /[Pp]ositively/ && $last_word =~ /[Nn]egatively/
  	 or $last_word =~ /[Pp]ositively/  && $first_word =~ /[Nn]egatively/)
	) {
  	$self->set_element( 'PlusMinusRating' );
    }
    else {
  	$self->set_element( 'NumericRating' );
    }
    # $self->set_element('NumericRating');
    $self->set_attribute( 'num_steps' => scalar(@choices) );
    $self->add_other_elt( 'low_text', $first_word );
    if ($mid_word) { $self->add_other_elt ( 'mid_text', $mid_word ) }
    $self->add_other_elt( 'high_text', $last_word );
    
    return 1;
}

sub check_for_dental_pm {
    my $self = shift;
    my @choices = map { $_->text } @_;
    return unless @choices == 6;
    for (@choices) { return unless /^\d$/ }
    $self->set_attribute('na_available' => 'yes');
    $self->set_element('PlusMinusRating');
    $self->set_attribute( 'num_steps' => 5 );
    $self->add_other_elt( 'low_text', "Strongly Agree" );
    $self->add_other_elt ( 'mid_text', "Neutral" );
    $self->add_other_elt( 'high_text', "Strongly Disagree" );
}

# Description: Determines if a <question_choice> element is really a NA
# Input: The <question_choice> XML::Twig::Elt object
# Output: 1 if it's a NA; 0 otherwise
sub is_na {
    my $self = shift;
    # Make sure we're being called as a method
    my $elt;
    if ( $self->isa( 'XML::Twig::Elt' ) ) { 
	$elt = $self;
	$self = undef;
    }
    else { $elt = shift; }
    my $choice_text = $elt->text;
    # What we checked for is text beggining with 'NA' (with any non-word stuff first)
    if ( $choice_text =~ /^\W*N\/?A/ ) { return 1; }
    if ( $choice_text =~ /\bNA\b/ ) { return 1; }
    if ( $choice_text =~ m![Dd]on\'t [Kk]now/NA! ) { return 1; }
    if ( $choice_text =~ m![Nn]ever [Uu]sed! ) { return 1; }
    if ( $choice_text =~ m![Nn]ot [Aa]pplicable! ) { return 1; }
    return 0;
}

# Description: Sets up the question choices, if there are any
# Input:
# Output: 
sub setup_choice_elts {
    my $self = shift;
    my @choices = ();

    # Get the <question_choice> elements from the <question>
    my @in_choices = $self->get_elt()->children( 'question_choice' );
    return unless @in_choices;

    my $alphabetical = $self->is_alphabetical_choices(@in_choices);

    # Is the last one a NA? If so, then kill it and set the na_available attribute
    if ( $self->is_na( $in_choices[-1] ) ) {
	$self->set_attribute( 'na_available' => 'yes' );
	pop @in_choices;
    }

    # Do we have Yes/No?
    if ($self->is_yes_no( @in_choices )) { return; }

    # Do we have a numeric rating?
    if (lc($self->get_eval_question()->school) eq 'dental') {
	if ($self->check_for_dental_pm( @in_choices )) { return; }
    }
    elsif ($self->is_numeric_rating( @in_choices )) { return; }

    my $max_choice_length = 0;
    for my $choice_elt( @in_choices ) {
	my $c_text = $choice_elt->text();
	$max_choice_length = 
	    length($c_text) > $max_choice_length ? length($c_text) : $max_choice_length;
	my %new_atts = ();

	# If the choices labels are not alphabetical, then we have to 
	# copy them over. If they ARE alphabetical, then we don't bother,
	# because alphabetical is assumed.
	if (not $alphabetical) {
	    if ($choice_elt->att( 'choice_label' ) ) {
		$new_atts{stored_value} = $choice_elt->att( 'choice_label' );
	    }
	}

	my $new_elt = $self->make_good_elt( 'choice', $c_text );
	$new_elt->set_atts( \%new_atts );
	push @choices, $new_elt;
    }
    $self->{-choice_elts} = \@choices;
    if ($max_choice_length > 80) {
	$self->set_attribute( 'num_columns' => '1' );
    }
    elsif ($max_choice_length > 40) {
	$self->set_attribute( 'num_columns' => '2' );
    }
    elsif (@choices <= 6) {
	$self->set_attribute( 'num_columns' => scalar(@choices) );
    }
    
}

# Description: Returns the old element object
# Input: 
# Output: The XML::Twig::Elt object
sub get_elt { 
    my $self = shift;
    return $self->{-elt};
}

# Description: Returns the eval_question
# Input: 
# Output: The eval_question
sub get_eval_question { 
    my $self = shift;
    return $self->{-eval_question};
}

# Description: Finds out if the question was required
# Input:
# Output: "yes" or "no" (or nothing) depending on the value of the attribute
sub get_required {
    my $self = shift;
    return $self->get_elt()->att( 'required' );
}

# Description: Finds out the default answer
# Input:
# Output: The default answer, depending on the value of the attribute
sub get_default_answer {
    my $self = shift;
    return $self->get_elt()->att( 'default_answer' );
}

# Description: Makes the new XML object and returns it.
# Input:
# Output: The new XML::Twig::Elt object which should be used
sub convert {
    my $self = shift;

    #
    if ($self->get_manual_elt() && $self->get_manual_elt()->isa( 'XML::Twig::Elt' )) {
	return $self->get_manual_elt();
    }

    my @other_elts = ();
    my @choice_elts = ();

    foreach my $other_elt ($self->get_other_elts()) { push(@other_elts, $other_elt->copy()) }
    foreach my $choice_elt ($self->get_choice_elts()) { push(@choice_elts, $choice_elt->copy()) }

    # Now, make up the new element
    my $new_elt = XML::Twig::Elt->new( 
				       $self->get_element(),
				       $self->get_attributes(),
				       $self->get_question_text_elt()->copy(),
				       @other_elts,
				       @choice_elts );

    return $new_elt;
}

1;
__END__
