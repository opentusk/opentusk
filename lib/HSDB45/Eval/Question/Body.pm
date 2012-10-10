# $Id: Body.pm,v 1.24 2005-05-16 19:55:29 bkessler Exp $
# Package for storing and accessing the attributes of a eval_question's body
# $Revision: 1.24 $
package HSDB45::Eval::Question::Body;

use strict;
use XML::Twig;
use XML::EscapeText::HSCML qw(:html);
use HSDB45::Eval::Question::Body::Converter;
use vars qw($VERSION);
use Carp;
use TUSK::Constants;

our $prolog = $TUSK::Constants::EvalDTD; 

sub version {
    return $VERSION;
}

# dependencies for things that relate to caching
my @mod_deps  = ();
my @file_deps;

sub get_mod_deps {
    return @mod_deps;
}

sub get_file_deps {
    return @file_deps;
}

BEGIN {
    use vars qw(@Types %TypeClass);
    @Types = qw(Title Instruction MultipleResponse MultipleChoice DiscreteNumeric
		NumericRating PlusMinusRating Count YesNo TeachingSite
		SmallGroupsInstructor IdentifySelf FillIn QuestionRef);
    # Unimplemented: Ranking, NumericFillIn
    %TypeClass = ( 'Title'                 => 'HSDB45::Eval::Question::Body::Title',
  		   'Instruction'           => 'HSDB45::Eval::Question::Body::Instruction',
		   'MultipleResponse'      => 'HSDB45::Eval::Question::Body::MultipleResponse',
  		   'MultipleChoice'        => 'HSDB45::Eval::Question::Body::MultipleChoice',
		   'DiscreteNumeric'       => 'HSDB45::Eval::Question::Body::MultipleChoice',
  		   'NumericRating'         => 'HSDB45::Eval::Question::Body::NumericRating',
		   'PlusMinusRating'       => 'HSDB45::Eval::Question::Body::PlusMinusRating',
		   'Count'                 => 'HSDB45::Eval::Question::Body::Count',
		   'YesNo'                 => 'HSDB45::Eval::Question::Body::YesNo',
		   # 'Ranking'               => 'HSDB45::Eval::Question::Body::Ranking',
		   'TeachingSite'          => 'HSDB45::Eval::Question::Body::TeachingSite',
		   'SmallGroupsInstructor' => 'HSDB45::Eval::Question::Body::SmallGroupsInstructor',
		   'IdentifySelf'          => 'HSDB45::Eval::Question::Body::IdentifySelf',
		   'FillIn'                => 'HSDB45::Eval::Question::Body::FillIn',
		   # 'NumericFillIn'         => 'HSDB45::Eval::Question::Body::NumericFillIn',
		   'QuestionRef'           => 'HSDB45::Eval::Question::Body::QuestionRef',
		   );

    require HSDB45::Eval::Question::Body::Title;
    require HSDB45::Eval::Question::Body::Instruction;
    require HSDB45::Eval::Question::Body::FillIn;
    require HSDB45::Eval::Question::Body::MultipleChoice;
    require HSDB45::Eval::Question::Body::MultipleResponse;
    require HSDB45::Eval::Question::Body::NumericRating;
    require HSDB45::Eval::Question::Body::SmallGroupsInstructor;
    require HSDB45::Eval::Question::Body::YesNo;
    require HSDB45::Eval::Question::Body::PlusMinusRating;
    require HSDB45::Eval::Question::Body::IdentifySelf;
    require HSDB45::Eval::Question::Body::SmallGroupsInstructor;
    require HSDB45::Eval::Question::Body::TeachingSite;
    require HSDB45::Eval::Question::Body::Count;
    require HSDB45::Eval::Question::Body::QuestionRef;
}

sub question_types {
    return @Types;
}

# Description: Constructor for a Body
# Input: The Eval::Question object which contains it
# Output: The new Body object
sub new {
    my $class = shift;
    $class = ref $class || $class;
    my $self = {};
    bless $self, $class;
    return $self->init( @_ );
}

# Description: Private initializer for the question
# Input: The Eval::Question object
# Output: The properly (re-)blessed Body object
sub init {
    my $self = shift;
    my $question = shift;
    $self->{-question} = $question;
    my $twig = XML::Twig->new('EmptyTags' => 'html', 
			      'comments' => 'keep',
			      # 'input_filter' => 'safe',
			      'output_filter' => 'safe'
			      );
    eval { 
		my $body = $question->field_value( 'body' );
		if ($body !~ m/^\<\?xml/){
			$body = $prolog.$body;	
		}
		$twig->parse( $body ); };
    if ($@) {
	print STDERR "Could not parse eval_question ID=", $question->primary_key(), "\n";
	print STDERR $question->field_value('body'), "\n";
	confess "$@";
    }
    $self->{-elt} = $twig->first_elt();
    # Deal with the old-time question problem
    if ($self->elt()->gi() eq 'question') {
	my $convert = 
	  HSDB45::Eval::Question::Body::Converter->new ($self->question(),
							$self->elt());

	# if ($self->elt()->att('group_by')) {
	# $self->question()->set_aux_info('old_grouping' => $self->elt()->att('group_by'));
        # }

	$self->{-is_oldstyle} = 1;
	$self->{-elt} = $convert->convert();
    }

    return $self->rebless();
}

# Description: Blesses a new Body object into the right class
# Input: 
# Output: The re-blessed Eval::Question::Body::* object		 
sub rebless {
    my $self = shift;
    my $type = $self->question_type();

    if ($type && $TypeClass{$type}) { bless $self, $TypeClass{$type} }
    else { confess "Could not figure out question type: $type" }

    return $self;
}

sub is_reference {
    return;
}

sub is_oldstyle {
    my $self = shift;
    return $self->{-is_oldstyle};
}

# Description: Accessor for the Question object to which this Body belongs
# Input:
# Output: The Eval::Question object
sub question {
    my $self = shift;
    return $self->{-question};
}

# Description: Accessor for the XML::Twig::Elt which represents the Body
# Input:
# Output: The XML::Twig::Elt object
sub elt {
    my $self = shift;
    if ($self->{-elt}){
	    $self->{-elt} = XML::Twig::Elt->parse($prolog.$self->{-elt}->sprint());
    }
    return $self->{-elt};
}

# Description: Figures out the question type
# Input:
# Output: The question type (or tag name, in the new scheme)
sub question_type {
    my $self = shift;
    return $self->elt()->gi();
}

# Description: Determines whether NA should be an available choice
# Input:
# Output: 1 if NA is available, 0 otherwise (default)
sub na_available {
    my $self = shift();
    my $na_available = $self->elt()->att('na_available');
    if($na_available && ($na_available eq 'yes')) { return 1; }
    return 0;
}

sub set_na_available {
    my $self = shift;
    my $available = shift;
    $self->elt()->set_att( na_available => ($available ? 'yes' : 'no') );
    $self->question()->set_field_values('body', $self->elt()->sprint());
    return $self->na_available;
}

# Description: Gets the eval_question_id, if it's set for the body
# Input:
# Output: The ID, or undef if there is none
sub eval_question_id {
    my $self = shift();
    return $self->elt()->att('eval_question_id');
}

# Description: Interprets a response; by default, this just returns the response itself
#    (override for more sophisticated interpretations)
# Input: The response to interpret
# Output: The response
# OVERRIDE
sub interpret_response {
    my $self = shift;
    my $resp = shift;
    return $resp;
}

sub question_text {
    my $self = shift;
    my $qte = $self->elt()->first_child('question_text');
    $qte->sprint();
    return $qte->sprint(1);
}

sub set_question_text {
    my $self = shift;
    my $new_text = shift;

    $new_text = XML::EscapeText::spec_chars_name($new_text);

    my $new_elt;
    my $question_text = <<EOM;
$prolog
<question_text>$new_text\</question_text>
EOM
    my ($r, $msg) = (1, '');
    eval {
 	$new_elt = XML::Twig::Elt->parse($question_text);
    };
    if ($@) {
 	return wantarray ? (0, "Could not parse text: $@ \n\n $question_text") : 0;
    }

    my $old_elt = $self->elt()->first_child('question_text');

    $new_elt->replace($old_elt);
    $self->question()->set_field_values('body', $self->elt()->sprint());

    return 1;
}

sub set_body_elt {
    my $self = shift;
    my $elt_gi = shift;
    my $new_value = shift;
    my $afters = shift;
    # It might be nice to have some way of doing attributes

    my $old_elt = $self->elt()->first_child($elt_gi);

    $new_value = $html_flow->xml_escape($new_value);
    # If neither is defined, then we don't have to do anything
    if (defined $old_elt) {
	if (defined $new_value) {
	    # Replace the old one with the new one
	    my $new_elt = XML::Twig::Elt->new($elt_gi, $new_value);
	    $new_elt->set_asis();
	    $new_elt->replace($old_elt);
	}
	else {
	    # Delete the old one
	    $old_elt->delete();
	}
    }
    else {
	if (defined $new_value) {
	    my $new_elt = XML::Twig::Elt->new($elt_gi, $new_value);
	    $new_elt->set_asis();
	    # If there's an afters list, then put it after that elt, if we can find it
	    if ($afters && ref($afters) eq 'ARRAY') {
		for my $gi (@$afters) {
		    my $after = $self->elt()->first_child($gi) or next;
		    $new_elt->paste('after', $after), last;
		}
	    }
	    # Otherwise, just make it the last child
	    else {
		$new_elt->paste('last_child', $self->elt());
	    }
	}
	# If neither is defined, don't do anything.
    }
    return 1;
}

1;
__END__
