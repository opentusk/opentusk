package HSDB45::Eval::Loader;

use strict;
use HSDB45::Eval;
use HSDB4::Constants qw(:school);
use XML::Twig;
use XML::Twig::Compare;

sub un_pw {
    my $self = shift;
    return ($self->{-username}, $self->{-password});
}

sub eval {
    my $self = shift;
    return $self->{-eval};
}

sub is_old_eval {
    my $self = shift;
    return $self->{-is_old_eval};
}

sub set_school {
    my $self = shift;
    my $school = shift;
    if ($school && grep(/$school/, eval_schools())) {
	$self->{-school} = $school;
    }
}

sub school {
    my $self = shift;
    return $self->{-school};
}

sub eval_elt {
    my $self = shift;
    return $self->{-eval_elt};
}

sub new {
    my $class = shift;
    $class = ref $class || $class;
    my $self = { -username => shift,
		 -password => shift };
    bless $self, $class;
    HSDB4::Constants::set_user_pw( $self->un_pw() );
    $self->{-verbose} = 0;
    return $self;
}

sub set_verbose {
    my $self = shift;
    my $in_verbose = shift;
    $self->{-verbose} = $in_verbose;
}

sub verbose {
    my $self = shift;
    return $self->{-verbose};
}

sub reset {
    my $self = shift;
    $self->{-eval_elt} = undef;
    $self->{-is_old_eval} = undef;
    $self->{-eval} = undef;
}

sub do_file {
    my $self = shift;
    my $filename = shift;

    die "Cannot open $filename." unless $filename && -e $filename;

    $self->reset();
    # Load the file, and make the eval
    my $twig = new XML::Twig;
    print STDERR "Loading and parsing file $filename.\n" if $self->verbose();
    $twig->parsefile($filename);
    $self->{-eval_elt} = $twig->first_elt('Eval');

    $self->do_eval_elt();
}

sub do_string {
    my $self = shift;
    my $string = shift;

    my $twig = new XML::Twig;
    print STDERR "Parsing input.\n" if $self->verbose();
    $twig->parse($string);

    $self->do_eval_elt();
}

sub do_eval_elt {
    my $self = shift;

    $self->do_eval;

    # Now, do the question
    my $sort_order = 0;
    my %found_questions = ();
    for my $question ($self->eval_elt()->children('EvalQuestion')) {
	my $qid;
	($qid, $sort_order) = $self->do_question($question, $sort_order);
	$found_questions{$qid} = 1;
    }

    # Now, delete the unmentioned questions
    for my $question ($self->eval()->questions()) {
	my $qid = $question->primary_key();
	unless ($found_questions{$qid}) {
	    print STDERR "Deleting link to question $qid\.\n" if $self->verbose();
	    my ($r, $m) = $self->eval()->delete_child_question($self->un_pw(), $qid);
	    print STDERR "Saved eval: [ $r ] $m\n" if $self->verbose();
	}
    }
}

my %types = (Title => 1, Instruction => 1, MultipleResponse => 1, MultipleChoice => 1,
	     DiscreteNumeric => 1, NumericRating => 1, PlusMinusRating => 1, Count => 1,
	     YesNo => 1, Ranking => 1, TeachingSite => 1, SmallGroupsInstructor => 1,
	     IdentifySelf => 1, FillIn => 1, NumericFillIn => 1 );

sub question_body {
    my $self = shift;
    my $elt = shift;
    for ($elt->children()) { 
	if ($types{$_->gi()}) { return $_ }
    }
    return;
}

sub do_eval {
    my $self = shift;
    
    my $school = $self->eval_elt()->att('school');
    my $eval_id = $self->eval_elt()->att('eval_id');

    if ($school && ! $self->school()) { $self->set_school($school) }
    $school = $self->school();
    die "Must specify a valid eval school for loading." unless $school;

    my $eval;
    $eval = HSDB45::Eval->new( _school => $school, _id => $eval_id ) if $eval_id;
    if ($eval && $eval->primary_key()) {
	print STDERR "Found eval_id=$eval_id\.\n" if $self->verbose();
	$self->{-eval} = $eval;
	if ($eval->complete_users()) {
	    die "Eval has been completed. Cannot modify through HSDB45::Eval::Loader.";
	}
	$self->{-is_old_eval} = 1;
    }
    else {
	print STDERR "  Creating new eval.\n" if $self->verbose();
	$self->{-eval} = HSDB45::Eval->new( _school => $school );
	$self->{-is_old_eval} = 0;
    }

    my %fields = ( 'time_period_id', $self->eval_elt()->att('time_period_id'),
		   'course_id', $self->eval_elt()->att('course_id'),
		   'title', $self->eval_elt()->first_child('eval_title')->text() );
    if (my $elt = $self->eval_elt()->first_child('available_date')) { 
	$fields{'available_date'} = $elt->text();
    }
    if (my $elt = $self->eval_elt()->first_child('due_date')) { 
	$fields{'due_date'} = $elt->text();
    }
    if (my $elt = $self->eval_elt()->first_child('prelim_due_date')) { 
	$fields{'prelim_due_date'} = $elt->text();
    }
			    
    $eval->set_field_values( %fields );

    my ($r, $m) = $eval->save($self->un_pw());
    print STDERR "  Saved eval: [ $r ] $m\n" if $self->verbose();
}

sub create_question {
    my $self = shift;
    my $question_elt = shift;

    my $question = HSDB45::Eval::Question->new( _school => $self->school() );

    $question->set_field_values('body', $self->question_body($question_elt)->sprint());

    my ($r, $m) = $question->save($self->un_pw());
    print STDERR "      Created question: [ $r ] $m\n" if $self->verbose();

    return $question;
}

sub link_fields {
    my $self = shift;
    my $question_elt = shift;

    my %fields = ();
    if ($question_elt->att('required')) { $fields{required} = $question_elt->att('required') }
    if ($question_elt->att('sort_order')) { $fields{sort_order} = $question_elt->att('sort_order') }
    my $group_ids = join ' ', map { $_->text() } $question_elt->children('grouping');
    if ($group_ids) { $fields{grouping} = $group_ids }
    if ($question_elt->first_child('question_label')) {
	$fields{label} = $question_elt->first_child('question_label')->text();
    }
    if ($question_elt->first_child('graphic_stylesheet')) {
	$fields{graphic_stylesheet} = $question_elt->first_child('graphic_stylesheet')->text();
    }
    return %fields;
}

sub do_question {
    my $self = shift;
    my $question_elt = shift;
    my $last_sort_order = shift || 0;

    my $question;
    my $qid = $question_elt->att('eval_question_id');
    my $is_old_question = 0;
    # If we've been given a eval_question_id...
    if ($qid) {
	# And if it leads to an actual question...
	$question = HSDB45::Eval::Question->new( _school => $self->school(),
						 _id => $qid );
	if ($question->primary_key()) {
	    print STDERR "  Found question $qid\.\n" if $self->verbose();
	    # And if it's different from what's in the database...
	    if (not compare_elts( $self->question_body($question_elt), $question->body->elt() )) {
		# ...and the question has been answered...
		if ($question->has_been_answered()) {
		    # ...then create a new question
		    print STDERR "    Question $qid has been answered, creating a new one.\n" if $self->verbose();
		    $self->create_question($question_elt);
		    $qid = $question->primary_key();
		}
		else {
		    # Otherwise, change the current question
		    print STDERR "    Question $qid being updated.\n" if $self->verbose();
		    $question->set_field_value('body', $self->question_body($question_elt));
		    my ($r, $m) = $question->save($self->un_pw());
		    print STDERR "      Updated question $qid : [ $r ] $m\n" if $self->verbose();
		    $is_old_question = 1;
		}
	    }
	    # Otherwise, we can just remember that this is an old question
	    else {
		print STDERR "    Question XML has not changed; leaving alone.\n" if $self->verbose();
		$is_old_question = 1;
	    }
	}
	# If we didn't find a corresponding question...
	else {
	    # Make a new one
	    print STDERR "    Didn't find question $qid\, creating a new question.\n" if $self->verbose();
	    $self->create_question($question_elt);
	    $qid = $question->primary_key();
	}
    }
    # If there's no eval_question_id, we don't need to worry about it.
    else {
	if ($self->verbose()) {
	    print STDERR "  Question found without ID.\n";
	    print STDERR "    Creating a new question.\n";
	}
	$question = $self->create_question($question_elt);
	$qid = $question->primary_key();
    }

    # Now, what about the linking?
    # First, let's get the linked fields themselves
    my %fields = $self->link_fields($question_elt);
    # And make sure the sort_order jives with the document order
    if ($fields{sort_order} <= $last_sort_order) {
	$fields{sort_order} = $last_sort_order + 5;
    }

    # Then, if there's already a link...
    if ($is_old_question && $self->is_old_eval() && $self->eval()->question($qid)) {
	print STDERR "    Updating a child question link.\n" if $self->verbose();
	# Then update it
	my ($r, $m) = $self->eval()->update_child_question_link( $self->un_pw(), $qid, %fields );
	print STDERR "      Updated child question link: [ $r ] $m\n" if $self->verbose();

    }
    else {
	# Otherwise, create the link
	print STDERR "    Inserting a child question link.\n" if $self->verbose();
	my ($r, $m) = $self->eval()->add_child_question( $self->un_pw(), $qid, %fields );
	print STDERR "      Inserted child question link: [ $r ] $m\n" if $self->verbose();
    }
    return ($qid, $fields{sort_order});
}

1;
