package HSDB45::Survey::Formatter;

use strict;
use vars qw($VERSION);
use base qw(XML::Formatter);
use XML::Twig;
use XML::EscapeText qw(:escape);
use HSDB45::Survey;
use TUSK::Constants;

$VERSION = do { my @r = (q$Revision: 1.6 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

sub version { return $VERSION; }

my @mod_deps  = ('HSDB45::Survey');
my @file_deps = ();

sub get_mod_deps {
    return @mod_deps;
}

sub get_file_deps {
    return @file_deps;
}

sub new {
    my $incoming = shift;
    my $object = shift;
    my $self = $incoming->SUPER::new($object);
    $self->init_decls();
    return $self;
}

sub new_from_path {
    my $incoming = shift();
    my $path = shift();
    my $object = class_expected()->lookup_path($path);
    my $self = $incoming->SUPER::new($object);
    $self->init_decls();
    return $self;
}

sub init_decls {
    my $self = shift;
    $self->{-doctype_decl} = 'Survey';
    $self->{-dtd_decl} = 'http://'. $TUSK::Constants::Domain .'/DTD/survey.dtd';
    $self->{-stylesheet_decl} = 'http://'. $TUSK::Constants::Domain .'/XSL/Eval/survey.xsl';
    return;
}

sub class_expected { return 'HSDB45::Survey' }

# Description: Returns the survey object
# Input:
# Output: The HSDB45::Eval object
sub survey {
    my $self = shift;
    return $self->object();
}

sub survey_attributes {
    my $self = shift;
    return { survey_id => $self->survey()->primary_key(),
	     school => $self->survey()->school(),
	     };
}

sub survey_info_elts {
    my $self = shift;
    my @elts = ();
    my $elt;
    $elt = XML::Twig::Elt->new('survey_title',
			       make_pcdata($self->survey()->field_value('title')));
    $elt->set_asis();
    push @elts, $elt;
    $elt = XML::Twig::Elt->new('start_date',
			       make_pcdata($self->survey()->field_value('start_date')));
    $elt->set_asis();
    push @elts, $elt;
    $elt = XML::Twig::Elt->new('stop_date',
			       make_pcdata($self->survey()->field_value('stop_date')));
    $elt->set_asis();
    push @elts, $elt;

    return @elts;
}

sub eval_question_elt {
    my $self = shift;
    my $question = shift;
    my @elts = ();
    my $elt;
    if ($question->label()) {
	$elt = XML::Twig::Elt->new('question_label', make_pcdata($question->label()));
	$elt->set_asis();
	push @elts, $elt;
    }
    for my $gid ($question->group_by_ids()) {
	my $gelt = XML::Twig::Elt->new('grouping', { group_by_id => $gid });
	$gelt->set_empty();
	push @elts, $gelt;
    }
    my $atts = { required => $question->is_required() ? 'Yes' : 'No',
		 sort_order => $question->sort_order(),
		 eval_question_id => $question->primary_key() };
    my $gi = $question->body()->is_reference() ? 'EvalQuestionRef' : 'EvalQuestion';
    $elt = XML::Twig::Elt->new( $gi, $atts, @elts, $question->body()->elt() );
    
    return $elt;
}

sub get_xml_elt {
    my $self = shift;

    my $elt = XML::Twig::Elt->new( 'Survey',
				   $self->survey_attributes(),
				   $self->survey_info_elts(),
				   );

    # Now, do all of the questions
    my $last_real_id = 0;
    my $in_group = 0;
    for my $question ($self->survey()->questions()) {
	my $qelt = $self->eval_question_elt($question);
	# If it's a reference to the last real question ID, then put it in the group
	if ($question->body()->is_reference() &&
	    $question->body()->target_question_id() == $last_real_id) {
	    # If we're not already in a group, we have to make one
	    if (not $in_group) {
		my $real_q = $elt->last_child();
		$real_q->cut();
		my $group_elt = XML::Twig::Elt->new('QuestionGroup', $real_q, $qelt);
		$group_elt->paste('last_child', $elt);
		$in_group = 1;
	    }
	    else {
		# Paste the question into the QuestionGroup
		$qelt->paste('last_child', $elt->last_child());
	    }
	}
	# Not a reference
	else {
	    $in_group = 0;
	    $qelt->paste('last_child', $elt);
	    $last_real_id = $question->primary_key();
	}
    }

    return $elt;
}

sub modified_since {
    my $self = shift;
    my $timestamp = shift;

    my $modified = HSDB4::DateTime->new();
    $modified->in_mysql_timestamp($self->survey()->field_value('modified'));
    return 1 if $modified > $timestamp;
    for my $question ($self->survey()->questions()) {
	$modified->in_mysql_timestamp($question->field_value('modified'));
	return 1 if $modified > $timestamp;
    }
    return;
}

1;
__END__
