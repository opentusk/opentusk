package HSDB45::Eval::Results::Format;

use strict;

BEGIN {
    require XML::Twig;
}


# Description: Generic constructor
# Input: 
# Output: Blessed, initialized HSDB45::Eval::Results::Format object
sub new {
    my $class = shift;
    $class = ref $class || $class;
    my $self = {};
    bless $self, $class;
    return $self->init (@_);
}

# Description: Private initializer
# Input: 
# Output: Blessed, initialized object
sub init {
}



# Description: generates and returns the XML blob that is the header xml twig
# Input: HSDB45::Eval object
# Output: header XML::Twig::Elt object
sub eval_results_header_elt {
    my $eval = shift();
    
    unless($self->{-header_elt}) {
	my $title = 
	    XML::Twig::Elt->new ('eval_title', $self->field_value ('title'));
	my $available_date = 
	    XML::Twig::Elt->new ('available_date', $self->field_value ('available_date'));
	my $due_date = 
	    XML::Twig::Elt->new ('due_date', $self->field_value ('due_date'));
	my $prelim_due_date = 
	    XML::Twig::Elt->new ('prelim_due_date', $self->field_value ('prelim_due_date'));
	$self->{-header_elt} = 	
	    XML::Twig::Elt->new('eval_header', 
				{ 
				    school => $self->school,
				    course_id => $self->field_value ('course_id'),
				    time_period_id => $self->field_value ('time_period_id'),
			        }, 
				$title, $available_date, $due_date, $prelim_due_date);

    }

    return $self->{-header_elt};
}

1;
__END__
