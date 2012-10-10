package Apache::XMLObject;

use strict;

use HSDB45::Course::Formatter;
use HSDB45::Eval::Results::Formatter;
use HSDB45::Eval::SavedAnswers::Formatter;
use HSDB45::Eval::Completion::Formatter;
use HSDB45::Eval::MergedCompletion::Formatter;
use HSDB45::Survey::Formatter;
use HSDB45::Eval::Formatter;
use HSDB45::Eval::Filter::Formatter;
use HSDB45::Eval::MergedResults::Formatter;
use Apache::Constants ':common';

sub handler {
    my $r = shift();
    my @pieces = split(/\//, $r->path_info());
    shift(@pieces); # goodbye null field
    my $requestList = 0;
    my $what = lc(shift(@pieces));
    
    if($what eq "list") {
	$requestList = 1;
	$what = lc(shift(@pieces));
    }

    my %formatter_map = ("course"       => "HSDB45::Course::Formatter",
			 "eval_results" => "HSDB45::Eval::Results::Formatter",
			 "merged_eval_results" => "HSDB45::Eval::MergedResults::Formatter",
			 "eval_saved_answers" => "HSDB45::Eval::SavedAnswers::Formatter",
			 "eval_completions" => "HSDB45::Eval::Completion::Formatter",
			 "merged_eval_completions" => "HSDB45::Eval::MergedCompletion::Formatter",
			 "eval" => "HSDB45::Eval::Formatter",
			 "filtered_eval" => "HSDB45::Eval::Filter::Formatter",
			 "survey" => "HSDB45::Survey::Formatter");

    return NOT_FOUND unless($formatter_map{$what});

    $r->content_type("text/xml");
    $r->send_http_header();
    $r->print("<?xml version=\"1.0\" encoding=\"utf-8\"?>\n");

    if($requestList) {
	my $school = shift(@pieces);
	my $ids = shift(@pieces);
	my @ids = split(/\-/, $ids);

	$r->print("<list>");
	foreach my $id (@ids) {
	    my $path = '/' . join('/', $school, $id, @pieces);
	    my $formatter = $formatter_map{$what}->new_from_path($path);
	    return NOT_FOUND unless($formatter->object());
	    return NOT_FOUND unless($formatter->get_xml_text());
	    $r->print($formatter->get_xml_text());
	}
	$r->print("</list>");
    }
    else {
	my $formatter = $formatter_map{$what}->new_from_path('/' . join('/', @pieces));
	return NOT_FOUND unless($formatter->object());
	return NOT_FOUND unless($formatter->get_xml_text());
	$r->print($formatter->get_xml_text());
    }

    return OK;
}

1;
