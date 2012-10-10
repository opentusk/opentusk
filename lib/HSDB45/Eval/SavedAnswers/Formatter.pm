package HSDB45::Eval::SavedAnswers::Formatter;

use strict;
use vars qw($VERSION);
use base qw(XML::Formatter);
use XML::Twig;
use XML::EscapeText qw(:escape);
use HSDB45::Eval::SavedAnswers;

$VERSION = do { my @r = (q$Revision: 1.6 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

sub version { return $VERSION; }

my @mod_deps  = ('HSDB45::Eval::SavedAnswers');
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
    $self->{-doctype_decl} = 'saved_answers';
    $self->{-dtd_decl} = 'http://tusk.tufts.edu/DTD/eval_answers.dtd';
    return $self;
}


sub new_from_path {
    my $incoming = shift();
    my $path = shift();
    $path =~ s/^\///;
    my ($school, $id) = split(/\//, $path);
    my $object = class_expected()->new_school_id($school, $id);
    my $self = $incoming->SUPER::new($object);
    $self->{-doctype_decl} = 'eval_saved_answers';
    $self->{-dtd_decl} = 'http://tusk.tufts.edu/DTD/eval_saved_answers.dtd';
    $self->{-stylesheet_decl} = 'http://tusk.tufts.edu/XSL/Eval/saved_answers.xsl';
    return $self;
}

sub class_expected {
    return 'HSDB45::Eval::SavedAnswers';
}

sub modified_since { return 1; }

sub get_xml_elt {
    my $self = shift;

    my $answers = $self->object();

    my @answers = ();
    while (my ($qid, $answer) = each %{$answers->answers()}) {
	my $elt = XML::Twig::Elt->new('eval_answer', { qid => $qid }, make_pcdata($answer));
	$elt->set_asis();
	push @answers, $elt;
    }
    return XML::Twig::Elt->new('EvalAnswers', @answers);
}

1;

__END__
