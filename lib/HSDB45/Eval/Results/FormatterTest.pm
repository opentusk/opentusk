package HSDB45::Eval::Results::FormatterTest;

use strict;
use base qw/Test::Unit::TestCase/;
use Test::Unit;
use XML::Twig;
use XML::Twig::Compare;
use HSDB45::Eval::Results::Formatter;

sub sql_files {
    return qw(base_course.sql base_time_period.sql base_user_group.sql eval.sql);
}

sub new {
    my $self = shift()->SUPER::new(@_);
    return $self;
}

sub set_up {

}

sub tear_down {

}

sub test_whole_file {
    my $filetwig = XML::Twig->new();
    my $filename = 'eval_results_regress_3.xml';
    $filetwig->parsefile($filename);
    my $formatter = HSDB45::Eval::Results::Formatter->new_from_path('/regress/3');
    my $formelt = $formatter->eval_results_elt(1);
    my $fileelt = $filetwig->root();
    assert(compare_elts($formelt, $fileelt), "Result of formatting differs from reference file."); 
    # . $formelt->sprint() . "\n" . $fileelt->sprint());
}

sub test_demoroniser {
    my $filetwig = XML::Twig->new(keep_encoding => 1);
    my $filename = 'eval_results_regress_5306.xml';
    $filetwig->parsefile($filename);
    my $formatter = HSDB45::Eval::Results::Formatter->new_from_path('/regress/5306');
    my $formelt = $formatter->eval_results_elt(1);
    my $fileelt = $filetwig->root();
    assert(compare_elts($formelt, $fileelt), "Result of demoronising differs from reference file.");
    # . $formelt->sprint() . "\n" . $fileelt->sprint());
}

1;
