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


package Apache::HSDBMergedEvalGraph;

use strict;
use Apache2::Const qw(:common);
use Apache2::URI;
use HSDB45::Eval::MergedResults::BarGraph;
use HSDB45::Eval::MergedResults::Formatter;
use HSDB4::DateTime;

sub handler {
    my $r = shift;

    my $bar = HSDB45::Eval::MergedResults::BarGraph->new_from_path($r->path_info);
    # If we didn't load the graph, try re-generating
    unless ($bar->primary_key) {
	# Extract the school and eval_id from the URL
	my $formatter = 
	  HSDB45::Eval::MergedResults::Formatter->new_from_path($r->path_info());
	if ($formatter->is_cache_valid()) {
	    my $bar_graph_creator = 
	      HSDB45::Eval::MergedResults::BarGraphCreator->new($formatter->school(), 
								$formatter->object_id(),
								$formatter->get_xml_text());
	    $bar_graph_creator->save_svg_graphs();
	}
	else {
	    $formatter->get_xml_text();
	}

	# Now, reload the bar graph object
	$bar = HSDB45::Eval::MergedResults::BarGraph->new_from_path($r->path_info);
    }
    $bar->primary_key or return NOT_FOUND;

    $r->update_mtime($bar->get_modified->out_unix_time());
    $r->set_last_modified;
    $r->content_type($bar->get_mime_type());

    unless ($r->header_only()) {
	$r->print($bar->get_graphic());
    }
    return OK;
}

1;
