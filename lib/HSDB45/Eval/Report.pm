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
use HSDB45::Eval::Question;
use HSDB45::Eval::Question::Results;

sub quick_report {
	my $eval = shift;
	my $evaluatee_id = shift;
	my $teaching_site_id = shift;

  my $results = HSDB45::Eval::Results->new($eval, $evaluatee_id, $teaching_site_id);

  print "<ol>";
  foreach my $question ($eval->questions()) {
		my $question_text = $question->body()->question_text();
		my $question_type = $question->body()->question_type();
		next if ($question_type eq 'Title');
    print "<li>" unless ($question_type eq 'Instruction');
		print "<p>$question_text</p>";
		next if ($question_type eq 'Instruction');
		my $question_results = HSDB45::Eval::Question::Results->new($question, $results);
		print_statistics($question_results) if ($question_results->is_numeric());
		print "</li>";
	}
  print "</ol>";
}

sub print_results() {
	my $question_results = shift;

	my $responses = $question_results->responses();
}

sub print_statistics() {
	my $question_results = shift;

	my $statistics = $question_results->statistics();

	printf('<p><b>N:</b> %d, <b>NA:</b> %d<br>', $statistics->count(), $statistics->na_count());
	printf('<b>Mean:</b> %.2f, <b>Std Dev:</b> %.2f<br>', $statistics->mean(), $statistics->standard_deviation());
	printf('<b>Median:</b> %.2f, <b>25%%:</b> %.2f, <b>75%%:</b> %.2f<br>', $statistics->median(), $statistics->median25(), $statistics->median75());
	printf('<b>Mode:</b> %.2f</p>', $statistics->mode());
}

1;
__END__
