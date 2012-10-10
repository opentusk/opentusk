package HSDB45::Eval::Filter;

use strict;
use HSDB45::Eval;
use HSDB45::Eval::Question;
use HSDB45::Eval::Question::Body;
use HSDB45::Eval::Filter::Rule;
use HSDB45::StyleSheet;
use HSDB4::StyleSheetType;

our $flag = 0;

sub new ($$$$$@) {
    my $incoming = shift();
    my $class = ref($incoming) || $incoming;
    my $self = {};
    bless($self, $class);
    $self->{-school} = shift();
    $self->{-eval_id} = shift();
    $self->{-label} = shift();
    $self->{-description} = shift();
    $self->{-rule_hash} = {};
    $self->{-rule_hash}{$_->question_type()} = $_ foreach @_;
    $self->{-eval_object} = HSDB45::Eval->new(_school => $self->{-school}, _id => $self->{-eval_id});
    return $self;
}

sub school {
    my $self = shift();
    return $self->{-school};
}

sub eval_id ($) {
    my $self = shift();
    return $self->{-eval_id};
}

sub eval_object ($) {
    my $self = shift();
    return $self->{-eval_object};
}

sub label {
    my $self = shift();
    return $self->{-label};
}

sub description {
    my $self = shift();
    return $self->{-description};
}

sub rule ($$) {
    my $self = shift();
    my $question_type = shift();
    return $self->{-rule_hash}{$question_type};
}

sub rules ($) {
    my $self = shift();
    return values(%{$self->{-rule_hash}});
}

sub question_types ($) {
    my $self = shift();
    return keys(%{$self->{-rule_hash}});
}

sub exclusion_hash ($) {
    my $self = shift();

    unless($self->{-exclusion_hash}) {
	my %inclusion_hash = $self->inclusion_hash();
	my %exclusion_hash = ();
	foreach my $eval_question ($self->eval_object()->questions()) {
	    $exclusion_hash{$eval_question->primary_key()} = 1 unless $inclusion_hash{$eval_question->primary_key()};
	}
	$self->{-exclusion_hash} = \%exclusion_hash;
    }

    return %{$self->{-exclusion_hash}};
}

sub inclusion_hash ($) {
    my $self = shift();

    unless($self->{-inclusion_hash}) {
	my %inclusion_hash;

	foreach my $eval_question ($self->eval_object()->questions()) {
	    my $question_type = $eval_question->body()->question_type();
	    my $rule_type = $self->rule($question_type)->rule_type();
	    if(($rule_type eq 'include_all') || ($rule_type eq 'exclude_selected')) {
		$flag = 1;
		$inclusion_hash{$eval_question->primary_key()} = 1;
	    }
	}

	foreach my $rule ($self->rules()) {
	    if($rule->rule_type() eq 'exclude_selected') {
		$flag = 1;
		foreach my $id ($rule->ids()) { delete $inclusion_hash{$id} }
	    }
	    elsif($rule->rule_type() eq 'include_selected') {
		$flag = 1;
		foreach my $id ($rule->ids()) { $inclusion_hash{$id} = 1 }
	    }
	}

	$self->{-inclusion_hash} = \%inclusion_hash;
    }

    return %{$self->{-inclusion_hash}};
}

sub create_stylesheet ($) {
    my $self = shift();
    my $stylesheet = HSDB45::StyleSheet->new(_school => $self->school());
    $stylesheet->stylesheet_type_id(HSDB4::StyleSheetType::label_to_id('Eval'));
    if (HSDB45::StyleSheet::is_unique_label($self->school(),$self->label())){
	    $stylesheet->label($self->label());
	} else {
		return (0,'Please select a unique name for the Filter.  The name '.$self->label.' is taken.');
	}
    $stylesheet->description($self->description());
    $stylesheet->body($self->stylesheet_text());
    $stylesheet->save();
    return $stylesheet->primary_key();
}

sub stylesheet_text {
    my $self = shift();
    return '<?xml version="1.0" encoding="utf-8"?>' . "\n" . $self->stylesheet_elt()->sprint();
}

sub stylesheet_elt ($) {
    my $self = shift();

    unless($self->{-stylesheet_elt}) {
	my $stylesheet_elt = XML::Twig::Elt->new('xsl:stylesheet',
						 { 'xmlns:xsl' => 'http://www.w3.org/1999/XSL/Transform',
						   'version'   => '1.0' });

	$self->root_template_elt()->paste('last_child', $stylesheet_elt);
	$self->header_template_elt()->paste('last_child', $stylesheet_elt);

	foreach my $question_template_elt ($self->question_template_elts()) {
	    $question_template_elt->paste('last_child', $stylesheet_elt);
	}

	$stylesheet_elt->set_pretty_print('indented');
	$self->{-stylesheet_elt} = $stylesheet_elt;
    }

    return $self->{-stylesheet_elt};
}

sub root_template_elt ($) {
    my $self = shift();

    my $root_template_elt = XML::Twig::Elt->new('xsl:template', { 'match' => '/Eval' });

    my $eval_elt = XML::Twig::Elt->new('Eval',
				       { 'course_id' => '{@course_id}',
					 'eval_id'   => '{@eval_id}',
					 'school'    => '{@school}',
					 'time_period_id' => '{@time_period_id}' });

    $eval_elt->paste('last_child', $root_template_elt);

    my $apply_templates_elt = XML::Twig::Elt->new('xsl:apply-templates');
    $apply_templates_elt->paste('last_child', $eval_elt);

    return $root_template_elt;
}

sub header_template_elt ($) {
    my $self = shift();
    my $header_template_elt = XML::Twig::Elt->new('xsl:template',
						  { 'match' => 'eval_title|available_date|due_date|prelim_due_date'});

    my $copy_elt = XML::Twig::Elt->new('xsl:copy-of', { 'select' => '.' });
    $copy_elt->paste('last_child', $header_template_elt);

    return $header_template_elt;
}

sub question_template_elts {
    my $self = shift();
    my %inclusion_hash = $self->inclusion_hash();

    my $eval_question_template_elt = XML::Twig::Elt->new('xsl:template',  { 'match' => 'EvalQuestion|EvalQuestionRef' });
    my $question_group_template_elt = XML::Twig::Elt->new('xsl:template', { 'match' => 'QuestionGroup' });

    my $question_choose_elt = XML::Twig::Elt->new('xsl:choose');
    my $question_group_choose_elt = XML::Twig::Elt->new('xsl:choose');

    $question_choose_elt->paste('last_child', $eval_question_template_elt);
    $question_group_choose_elt->paste('last_child', $question_group_template_elt);

    my $potential_group_leader_id = 0;
    my $included_group = 0;
    my $in_group = 0;

    foreach my $question ($self->eval_object()->questions()) {
	if($question->body()->is_reference() &&
	   $question->body()->target_question_id() == $potential_group_leader_id) {

	    unless($in_group) { # just hit the first EvalQuestionRef in a QuestionGroup
		if($inclusion_hash{$potential_group_leader_id}) {
		    $question_choose_elt->last_child()->cut();
		    my $when_elt = $self->when_elt('./EvalQuestion[@eval_question_id=\'' . 
						   $potential_group_leader_id . '\']');
		    $when_elt->paste('last_child', $question_group_choose_elt);
		    $included_group = 1;
		}

		$in_group = 1;
	    }

	    unless($included_group) { 
		if($inclusion_hash{$question->primary_key()}) { # this QuestionGroup needs to appear in the report
		    my $when_elt = $self->when_elt('./EvalQuestion[@eval_question_id=\'' . 
						   $potential_group_leader_id . '\']');
		    $when_elt->paste('last_child', $question_group_choose_elt);
		    $included_group = 1;
		}
	    }
	}
	else { # global EvalQuestion (or as yet to be placed into a QuestionGroup) or global EvalQuestionRef
	    $in_group = 0;
	    $included_group = 0;
	    $potential_group_leader_id = $question->primary_key();

	    if($inclusion_hash{$question->primary_key()}) {
		my $when_elt = $self->when_elt('@eval_question_id=\'' . $question->primary_key() . '\'');
		$when_elt->paste('last_child', $question_choose_elt);
	    }
	}
    }

    return ($eval_question_template_elt, $question_group_template_elt);
}

sub when_elt {
    my $self = shift();
    my $test = shift();

    my $when_elt = XML::Twig::Elt->new('xsl:when', { 'test'   => $test });
    my $copy_elt = XML::Twig::Elt->new('xsl:copy-of', { 'select' => '.'   });
    $copy_elt->paste('last_child', $when_elt);
    
    return $when_elt;
}

sub sanity_check ($) {
    my $self = shift();
    my $result = '';

    foreach my $question_type ($self->question_types()) {
	my $rule = $self->rule($question_type);
	$result .= $question_type . ' | ' . $rule->rule_type() . ' | ' . join(',' => $rule->ids()) . '<br/>' . "\n";
    }

    return $result;
}

sub sanity_check_2 ($) {
    my $self = shift();
    $self->exclusion_hash();
    return join(',' => keys(%{$self->{-exclusion_hash}}));
}

sub sanity_check_3 ($) {
    my $self = shift();
    $self->inclusion_hash();
    return join(',' => keys(%{$self->{-inclusion_hash}}));
}

1;
