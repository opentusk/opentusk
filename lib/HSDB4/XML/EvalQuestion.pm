package HSDB4::XML::EvalQuestion;

use strict;
use vars qw(@ISA);
require HSDB4::XML;
@ISA = qw(HSDB4::XML::Element);


# Shorthand for the XML types
my $simple = 'HSDB4::XML::SimpleElement';
my $attr = 'HSDB4::XML::Attribute';
my $element = 'HSDB4::XML::Element';

# The label for a question
my $question_label = $simple->new (-tag=>'question_label', -label => "Label");
# The text for a question
my $question_text = $simple->new (-tag=>'question_text', -label => "Text");

# The label for a choice
my $choice_label = $attr->new (-name=>'choice_label', 
			       -label => "Choice Label");
# The choice object itself
my $question_choice = $simple->new (-tag => 'question_choice', 
				    -label => 'Choice',
				    -attributes => [ $choice_label ]
				    );

# The attributes for a question: required, question_type, default_answer
my $required = $attr->new (-name => 'required',
			   -choices => {'yes' => 'Yes',
					'no' => 'No'},
			   -label => 'Required',
			   -default => 'no',
			   );
my $question_type = $attr->new (-name => 'question_type', 
				-label => 'Type',
				-choices => {'fill-in' => 'Fill In',
					     'radio-box' => 'Radio Box',
					     'pop-up' => 'Pop-up Menu',
					     'instruction' => 'Instruction',
					     'title' => 'Title',
					     'check_box' => 'Check Box',
					     'small_groups' => 'Small Groups',
					    },
				-required => 1
				);

my $default_answer = $attr->new (-name=>'default_answer',
				 -label => 'Default Answer'
				 );

my $group_by = $attr->new (-name => 'group_by',
			   -label => 'Group Answers By');

my $group_by_range = $attr->new (-name => 'group_by_range',
				 -label => 'Group Answer By (Range)');


# The question object itself
my $question = $element->new (-tag=>'question',
			      -label => 'Question',
			      -subelements => [ [ $question_label,  0, 1 ],
						[ $question_text,   1, 1 ],
						[ $question_choice, 0, 0 ]  ],
			      -attributes => [ $required, $question_type,
					       $default_answer, $group_by,
					       $group_by_range
					     ],
			      );

# A constructor object for the question bodies
sub new { 
    my $class = shift;
    $class = ref $class || $class;
    return bless $question->new, $class;
}

1;
