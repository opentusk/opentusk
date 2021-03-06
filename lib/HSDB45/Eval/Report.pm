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


package HSDB45::Eval::Report;

use strict;

use HSDB45::Eval;
use HSDB45::Eval::Results;
use HSDB45::Eval::MergedResults;
use HSDB45::Eval::Question;
use HSDB45::Eval::Question::Results;
use HSDB45::Eval::Question::MergedResults;
use JSON;

sub quick_report {
	my $eval = shift;
	my $evaluatee_id = shift;
	my $teaching_site_id = shift;

	my $results;
	my $overall;
	if ($eval->isa('HSDB45::Eval::MergedResults')) {
		$results = $eval;
		$eval = $results->parent_eval();
		$evaluatee_id = $results->evaluatee_id();
		$teaching_site_id = $results->teaching_site_id();
		$overall = HSDB45::Eval::MergedResults->new(_school => $results->school(), _id => $results->primary_key())->set_filter('', $teaching_site_id) if ($evaluatee_id && $teaching_site_id);
	} else {
		$results = HSDB45::Eval::Results->new($eval, $evaluatee_id, $teaching_site_id);
		$overall = HSDB45::Eval::Results->new($eval, '' , $teaching_site_id) if ($evaluatee_id && $teaching_site_id);
	}

	print '<ol>';
	foreach my $question ($eval->questions()) {
		my $body = $question->body();
		my $question_type = $body->question_type();
		next if ($question_type eq 'Title');
		print '<li>' unless ($question_type eq 'Instruction');
		printf('<p>%s</p>', $body->question_text());
		next if ($question_type eq 'Instruction');
		my $question_results;
		my $question_overall;
		if ($results->isa('HSDB45::Eval::MergedResults')) {
			$question_results = HSDB45::Eval::Question::MergedResults->new($question, $results);
			$question_overall = HSDB45::Eval::Question::MergedResults->new($question, $overall) if ($overall);
		} else {
			$question_results = HSDB45::Eval::Question::Results->new($question, $results);
			$question_overall = HSDB45::Eval::Question::Results->new($question, $overall) if ($overall);
		}
		if ($question_type =~ /IdentifySelf|FillIn|LongFillIn/) {
			print_responses($question_results);
		} else {
			print_statistics($question_results, $question_overall);
		}
		print '</li>';
	}
	print '</ol>';
}

sub print_responses() {
	my $question_results = shift;

	print '<ul>';
	foreach my $response ($question_results->responses()) {
		printf('<li>%s', $response->response()) if ($response->response());
	}
	print '</ul>';
}

sub print_statistics() {
	my $question_results = shift;
	my $question_overall = shift;

	my $body = $question_results->question()->body();
	my $question_type = $body->question_type();
	my $statistics_results = $question_results->statistics();
	my $statistics_overall = ($question_overall) ? $question_overall->statistics() : undef;

	if ($question_results->is_binnable()|| $question_results->is_multibinnable()) {
		my $histogram = $statistics_results->histogram();
		if ($question_results->is_numeric() || $question_type eq 'YesNo') {
			my %json;
			my @data = ();
			foreach my $bin ($histogram->bins()) {
				my $count = $histogram->bin_count($bin);
				push @data, {'bin' => $bin, 'count' => $count};
			}
			$json{'data'} = \@data;
			$json{'type'} = $question_type;
			if ($question_results->is_numeric()) {
				$json{'mean'} = $statistics_results->mean();
				$json{'low_text'} = $body->low_text();
				$json{'high_text'} = $body->high_text();
			}
			printf('<div class="graph"><script type="application/json">%s</script></div>', encode_json(\%json));
		} else {
			print '<div class="table"><table border="1" cellspacing="0">';
			print '<tr><th align="center">Selection</th><th align="center">Frequency</th></tr>';
			foreach my $bin ($histogram->bins()) {
				printf('<tr><td align="center">%s</td><td align="center">%d</td></tr>', $bin, $histogram->bin_count($bin));
			}
			print '</table></div>';
		}
	}

	if ($question_results->is_numeric()) {
		my $count = sformat('%d', 'count', $statistics_results, $statistics_overall);
		my $na_count = sformat('%d', 'na_count', $statistics_results, $statistics_overall);
		my $mean = sformat('%.2f', 'mean', $statistics_results, $statistics_overall);
		my $standard_deviation = sformat('%.2f', 'standard_deviation', $statistics_results, $statistics_overall);
		my $median = sformat('%.2f', 'median', $statistics_results, $statistics_overall);
		my $median25 = sformat('%.2f', 'median25', $statistics_results, $statistics_overall);
		my $median75 = sformat('%.2f', 'median75', $statistics_results, $statistics_overall);
		my $mode = sformat('%.2f', 'mode', $statistics_results, $statistics_overall);
		print '<div class="stats">';
		print "<b>N:</b> $count, <b>NA:</b> $na_count<br>";
		print "<b>&#x25b2; Mean:</b> $mean, <b>Std Dev:</b> $standard_deviation<br>";
		print "<b>Median:</b> $median, <b>25%:</b> $median25, <b>75%:</b> $median75<br>";
		print "<b>Mode:</b> $mode</div>";
	}
}

sub sformat {
	my $format = shift;
	my $method = shift;
	my $statistics_results = shift;
	my $statistics_overall = shift;

	if ($statistics_overall) {
		return sprintf("$format ($format)", $statistics_results->$method(), $statistics_overall->$method());
	} else {
		return sprintf($format, $statistics_results->$method());
	}
}

1;
__END__
