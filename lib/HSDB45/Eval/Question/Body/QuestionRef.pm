# $Id: QuestionRef.pm,v 1.5 2002-11-04 20:12:28 agibbs Exp $
# Package representing a question body which is a reference to a different question body
# $Revision: 1.5 $
package HSDB45::Eval::Question::Body::QuestionRef;

use strict;
use base qw(HSDB45::Eval::Question::Body);

sub target_question {
    my $self = shift;
    unless ($self->{-target_question}) {
	my $eval = $self->question()->parent_eval();
	$self->{-target_question} = $eval->question($self->target_question_id());
    }
    return $self->{-target_question};
}

sub target_question_id {
    my $self = shift;
    unless ($self->{-target_question_id}) {
	$self->{-target_question_id} = $self->elt()->att('target_question_id');
    }
    return $self->{-target_question_id};
}

sub set_target_question_id {
    my $self = shift;
    my $new_target_id = shift;

    # Validate; make sure we have the question (in this eval)
    my $new_target = $self->question->parent_eval()->question($new_target_id);
    unless ($new_target && $new_target->isa('HSDB45::Eval::Question')) {
	return (0, "Cannot find suggested target question.");
    }
    # Now, if it's a reference, look it up, instead of letting references chain
    if ($new_target->body()->is_reference()) {
	$new_target_id = $new_target->body()->target_question_id();
	$new_target = $new_target->target_question();
    }
    # Set the attributes
    $self->elt()->set_att('target_question_id' => $new_target_id);
    $self->question()->set_field_values('body', $self->elt()->sprint());
    return wantarray ? (1, "") : 1;
}

sub question_type {
    my $self = shift;
    return $self->target_question()->body()->question_type();
}

sub interpret_response {
    my $self = shift;
    return $self->target_question()->interpret_response(@_);
}

sub is_reference {
    return 1;
}

sub choices {
    my $self = shift();
    return $self->target_question()->body()->choices();
}

1;
