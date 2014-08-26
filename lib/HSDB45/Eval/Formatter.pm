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


package HSDB45::Eval::Formatter;

use strict;
use vars qw($VERSION);
use base qw(XML::Formatter);
use XML::Twig;
use XML::EscapeText qw(:escape);
use HSDB45::Eval;
use TUSK::Constants;
use Carp;

$VERSION = do { my @r = (q$Revision: 1.24 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
sub version { return $VERSION; }

my @mod_deps  = ('HSDB45::Eval');
my @file_deps = ();

sub get_mod_deps {
    return @mod_deps;
}

sub get_file_deps {
    return @file_deps;
}

# Description: Generic constructor
# Input: A Eval object
# Output: Blessed, initialized HSDB45::Eval::Formatter object
sub new {
    my $incoming = shift;
    my $object = shift;
    my $self = $incoming->SUPER::new($object);
    $self->{-doctype_decl} = 'Eval';
    $self->{-dtd_decl} = 'http://'. $TUSK::Constants::Domain .'/DTD/eval.dtd';
    $self->{-stylesheet_decl} = 'http://'. $TUSK::Constants::Domain .'/XSL/Eval/eval.xsl';
    return $self;
}

sub new_from_path {
    my $incoming = shift;
    my $path = shift;
    my $object = $incoming->class_expected()->lookup_path($path);
    return $incoming->new($object);
}

sub class_expected { return 'HSDB45::Eval' }

# Description: Returns the eval object
# Input:
# Output: The HSDB45::Eval object
sub eval {
    my $self = shift;
    return $self->object();
}

sub eval_attributes {
    my $self = shift;
    my $eval_type = $self->eval()->eval_type();
    return { 
	eval_id => $self->eval()->primary_key(),
	school => $self->eval()->school(),
	course_id => $self->eval()->field_value('course_id'),
	time_period_id => $self->eval()->field_value('time_period_id'),
	eval_type => (defined $eval_type) ? $eval_type->getToken() : undef,
    };
}

sub eval_info_elts {
    my $self = shift;
    my @elts = ();

    my $elt = XML::Twig::Elt->new('eval_title',
				  make_pcdata($self->eval()->field_value('title')));
    $elt->set_asis();
    push @elts, $elt;

    $elt = XML::Twig::Elt->new('available_date',
			       make_pcdata($self->eval()->field_value('available_date')));
    $elt->set_asis();
    push @elts, $elt;

    $elt = XML::Twig::Elt->new('due_date',
			       make_pcdata($self->eval()->field_value('due_date')));
    $elt->set_asis();
    push @elts, $elt;

    if ($self->eval()->field_value('prelim_due_date')) {
	$elt = XML::Twig::Elt->new('prelim_due_date',
				   make_pcdata($self->eval()->field_value('prelim_due_date')));
	$elt->set_asis();
	push @elts, $elt;
    }
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
    eval {
	    $elt = XML::Twig::Elt->new( 'EvalQuestion', $atts, @elts, $question->body()->elt() );
    };
    if ($@){
	confess $@;
    }
    return $elt;
}

sub get_xml_elt {
    my $self = shift;

    my $elt = XML::Twig::Elt->new( 'Eval',
				   $self->eval_attributes(),
				   $self->eval_info_elts(),
				   );

    # Now, do all of the questions
    my $last_real_id = 0;
    my $in_group = 0;
    for my $question ($self->eval()->questions()) {
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
    $modified->in_mysql_timestamp($self->eval()->field_value('modified'));
    return 1 if $modified > $timestamp;
    for my $question ($self->eval()->questions()) {
	$modified->in_mysql_timestamp($question->field_value('modified'));
	return 1 if $modified > $timestamp;
    }
    return;
}

1;
__END__
