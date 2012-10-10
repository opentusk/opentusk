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


package HSDB45::Eval::SavedAnswers::Formatter;

use strict;
use vars qw($VERSION);
use base qw(XML::Formatter);
use XML::Twig;
use XML::EscapeText qw(:escape);
use HSDB45::Eval::SavedAnswers;
use TUSK::Constants;

$VERSION = do { my @r = (q$Revision: 1.8 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };

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
    $self->{-dtd_decl} = 'http://'. $TUSK::Constants::Domain .'/DTD/eval_answers.dtd';
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
    $self->{-dtd_decl} = 'http://'. $TUSK::Constants::Domain .'/DTD/eval_saved_answers.dtd';
    $self->{-stylesheet_decl} = 'http://'. $TUSK::Constants::Domain .'/XSL/Eval/saved_answers.xsl';
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
