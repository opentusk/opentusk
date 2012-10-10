package Apache::HSDBEvalGraph;

use strict;
use Apache::Constants qw(:common);
use Apache::URI;
use HSDB45::Eval::Results::BarGraph;
use HSDB45::Eval::Results::Formatter;
use HSDB4::DateTime;

sub handler {
    my $r = shift;

    my $bar = HSDB45::Eval::Results::BarGraph->new_from_path($r->path_info);
    # If we didn't load the graph, try re-generating
    unless ($bar->primary_key) {
	# Extract the school and eval_id from the URL
	my $formatter = HSDB45::Eval::Results::Formatter->new_from_path($r->path_info());
	if ($formatter->is_cache_valid()) {
	    my $bar_graph_creator = 
	      HSDB45::Eval::Results::BarGraphCreator->new($formatter->school(), 
							  $formatter->object_id(),
							  $formatter->get_xml_text());
	    $bar_graph_creator->save_svg_graphs();
	}
	else {
	    $formatter->get_xml_text();
	}

	# Now, reload the bar graph object
	$bar = HSDB45::Eval::Results::BarGraph->new_from_path($r->path_info);
    }
    $bar->primary_key or return NOT_FOUND;

    $r->update_mtime($bar->get_modified->out_unix_time());
    $r->set_last_modified;
    $r->content_type($bar->get_mime_type());
    $r->send_http_header();

    unless ($r->header_only()) {
	$r->print($bar->get_graphic());
    }
    return OK;
}

1;
