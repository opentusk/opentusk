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


package TUSK::Application::Quiz::ItemAnalysis;

use strict;
use TUSK::Quiz::Quiz;
use TUSK::Quiz::LinkQuizQuizItem;
use Statistics::Descriptive;

sub new {
    my ($class, $args) = @_;

    my $self = { 
	_quiz         => TUSK::Quiz::Quiz->lookupKey($args->{quiz_id}),
	_quiz_id      => $args->{quiz_id},
	_upper_group  => 27,
	_lower_group  => 27,
	_desc_stats   => Statistics::Descriptive::Full->new(),
	_question_index => 0,
	_items_count  => undef,
	_errors       => [],
    };

    bless($self, $class);
    return $self;
}

sub getData {
    my $self = shift;
    return undef unless defined $self->{_quiz};
	## only correct answers
    my $sth = $self->{_quiz}->databaseSelect(qq(
SELECT user_id, link_id, link_type, ans.quiz_question_id, sort_order
FROM tusk.quiz_response resp, tusk.quiz_result resu, tusk.quiz_answer ans, tusk.quiz_question q 
WHERE resp.quiz_result_id = resu.quiz_result_id 
AND ans.quiz_answer_id = resp.quiz_answer_id 
AND q.quiz_question_id = ans.quiz_question_id 
AND quiz_id = $self->{_quiz_id} 
AND resp.graded_points > 0 
AND type = 'MultipleChoice' 
AND preview_flag = 0 
order by user_id;
    ));

    my $data = $sth->fetchall_arrayref();
    $sth->finish;
    return $data;
}


sub addData {
    my ($self, $data) = @_;
    return 0 unless ref $data eq 'ARRAY';

    foreach (@{$data}) {
		$self->{_questions}{$_->[1] . '_' . $_->[2]} = $_->[3];
		$self->{_scores}{$_->[0]}++;
		$self->{_total_items}++;
		$self->{_questions_count}{$_->[3]} += 1;
    }

    $self->{_total_members} = scalar keys %{$self->{_scores}};
    $self->{_desc_stats}->add_data([$self->getScores()]);
    $self->createGroups();
    $self->calculateCorrections();
}


sub getNames {
    my $self = shift;
    return keys %{$self->{_scores}};    
}


sub getScores {
    my $self = shift;
    return values %{$self->{_scores}};
}


sub getScoresFrequency {
    my $self = shift;

    my %scores;
    foreach ($self->getScores()) {
	$scores{$_}++;
    }
    return \%scores;
}


sub getScore {
    my ($self,$key) = @_;
    return undef unless defined $key;
    return $self->{_scores}{$key};
}

sub getCorrectGroupResponses {
    my $self = shift;

    $self->createGroups() unless (scalar @{$self->{_upper_group_members}} && scalar @{$self->{_lower_group_members}});

    my $upper_group_members = join(", ", map { "'$_'" } @{$self->{_upper_group_members}});
    my $lower_group_members = join(", ", map { "'$_'" } @{$self->{_lower_group_members}});

    return ($self->getCorrectionByGroup($upper_group_members), $self->getCorrectionByGroup($lower_group_members));
}


sub getCorrectionByGroup {
    my ($self,$user_ids) = @_;

    return undef unless defined $self->{_quiz} && defined $user_ids && $user_ids =~ /\w+/;

    ### this includes all question types
    my $sth = $self->{_quiz}->databaseSelect(qq(
	SELECT link_id, link_type, count(*)
	FROM tusk.quiz_response a, tusk.quiz_result b
	WHERE a.quiz_result_id = b.quiz_result_id 
        AND graded_points > 0
        AND quiz_id = $self->{_quiz_id} 
	AND preview_flag = 0
        AND user_id in ( $user_ids )
        group by link_id, link_type;
    ));

    my %group_correct_responses;

    while (my($link_id, $link_type, $count) = $sth->fetchrow_array()) {
	$group_correct_responses{$self->{_questions}{$link_id . '_' . $link_type}} = $count;
    }

    $sth->finish();
    return \%group_correct_responses;
}


sub createGroups {
    my $self = shift;

    return if $self->{_err_creating_groups};

    my @members = grep { defined($_) } (sort {$self->{_scores}{$b} <=> $self->{_scores}{$a}} (keys %{$self->{_scores}}));

    my $upper_end = int($self->{_upper_group} / 100 * $self->{_total_members});
    $self->{_upper_group_members} = [@members[0..$upper_end-1]];

    my $lower_start = $self->{_total_members} - int($self->{_lower_group} / 100 * $self->{_total_members});


    if ($lower_start < 0) {
		$self->{_err_creating_groups} = 1;
		return;
    }

    $self->{_lower_group_members} = [@members[$lower_start .. $self->{_total_members}-1]];
}



sub getCountForUpperGroup {
    my $self = shift;
    return scalar @{$self->{_upper_group_members}};
}

sub getCountForLowerGroup {
    my $self = shift;
    return scalar @{$self->{_lower_group_members}};
}


sub getAllUniqueScores {
    my $self = shift;
    my @scores = values %{$self->{_scores}};
    my %saw;
    @saw{@scores} = ();
    return sort { $a <=> $b } keys %saw;
}


sub getDescriptiveStatsObject {
    my $self = shift;
    return $self->{_desc_stats};
}


sub getTestReliabilityEstimate {
    my $self = shift;
    my $decimal_point = shift || 2;
    return sprintf("%." . $decimal_point . "F", $self->{_test_reliability_estimate});

}


sub getCountForEachItem {
    my $self = shift;
    return $self->{_questions_count};
}


sub calculateCorrections {
    my $self = shift;

    return undef unless defined $self->{_quiz};
    my $sth = $self->{_quiz}->databaseSelect(qq(
	SELECT link_id, link_type, count(*), (count(*)/$self->{_total_members}) * (1-(count(*)/$self->{_total_members})) as pq 
	FROM tusk.quiz_response a, tusk.quiz_result b, tusk.quiz_answer c, tusk.quiz_question q
	WHERE a.quiz_result_id = b.quiz_result_id
	AND q.quiz_question_id = c.quiz_question_id
	AND a.quiz_answer_id = c.quiz_answer_id					
        AND quiz_id = $self->{_quiz_id} 
        AND a.graded_points > 0
	AND preview_flag = 0
        AND type = 'MultipleChoice'
        group by link_id, link_type;

    ));

    my (%items_count, $pqs);
    while (my ($link_id, $link_type, $count, $pq) = $sth->fetchrow_array()) {
	$items_count{$self->{_questions}{$link_id . '_' . $link_type}} = $count;
	$pqs += $pq;
    }
    $sth->finish;

    ## KR20 = (k/(k-1) * 1-(sum of pqs/stdev))
    if (defined $self->{_desc_stats}) {
		my $variance = $self->{_desc_stats}->variance();
		if (defined $variance && $variance > 0 && defined $self->{_total_items} && $self->{_total_items} > 1) {
			$self->{_test_reliability_estimate} = (($self->{_total_items} / ($self->{_total_items}-1)) * (1 - ($pqs / $variance)));
		}
    }
}


sub getResponses {
    my $self = shift;

    return undef unless defined $self->{_quiz};
    my $sth = $self->{_quiz}->databaseSelect(qq(
	SELECT link_id, link_type, sort_order, count(*) 
        FROM tusk.quiz_response resp, tusk.quiz_answer ans, tusk.quiz_result resu
        WHERE resp.quiz_answer_id = ans.quiz_answer_id 
        AND response_text = value 
        AND resp.quiz_result_id = resu.quiz_result_id 
        AND quiz_id = $self->{_quiz_id}
	group by link_id, link_type, sort_order
    ));

    my %responses;
    while (my ($link_id, $link_type, $sort_order, $count) = $sth->fetchrow_array()) {
	$responses{$self->{_questions}{$link_id . '_' . $link_type}}[$sort_order] = $count;
    }
    $sth->finish;
    return \%responses;
}


### limit to MultipleChoice questions
sub getQuestions {
    my $self = shift;

    my $cond = "quiz_id = $self->{_quiz_id} and type in ('MultipleChoice', 'Section')";

    my $links = TUSK::Quiz::LinkQuizQuizItem->new()->lookup($cond, ['link_quiz_quiz_item.sort_order'], undef, undef, [ TUSK::Core::JoinObject->new("TUSK::Quiz::Answer", { origkey => 'quiz_item_id', joinkey => 'quiz_question_id', joincond => 'correct = 1' }), TUSK::Core::JoinObject->new("TUSK::Quiz::Question", { origkey => 'quiz_item_id', joinkey => 'quiz_question_id', jointype => 'inner'}) ]);

=for
    foreach my $link(@{$links}) {
	print $link->getSortOrder();
    }
=cut

    $self->setQuestions($links);
    return $self->{_all_mc_questions};
}


sub setQuestions {
    my ($self, $links) = @_;

    foreach my $link (@{$links}) {
	my $question = $link->getJoinObject('TUSK::Quiz::Question');
	my $type = $question->getType();
	my $question_id = $question->getPrimaryKeyID(); 

	if ($type eq 'Section') {
	    $self->setQuestions($self->getChildrenQuestions($question_id));
	} elsif ($type eq 'MultipleChoice') {
	    $self->{_questions_sort_order}{$question_id} = $self->{_question_index};
	    $self->{_all_mc_questions}[$self->{_question_index}] = [$question_id, [ grep { ref $_ eq 'TUSK::Quiz::Answer' } @{$link->getJoinObjects('TUSK::Quiz::Answer')} ], $link->getSortOrder() ];
	    $self->{_question_index}++;
	} 
    }
}


sub getChildrenQuestions {
    my ($self, $parent_question_id) = @_;

    my $cond = "parent_question_id = $parent_question_id and type in ('MultipleChoice', 'Section')";

    my $links = TUSK::Quiz::LinkQuestionQuestion->lookup($cond, ['link_question_question.sort_order'], undef, undef, [ TUSK::Core::JoinObject->new("TUSK::Quiz::Answer", { origkey => 'child_question_id', joinkey => 'quiz_question_id', joincond => 'correct = 1'}), TUSK::Core::JoinObject->new("TUSK::Quiz::Question", { origkey => 'child_question_id', joinkey => 'quiz_question_id', jointype => 'inner'}) ]);

    return $links;
}


sub getQuestionsCount {
    my $self = shift;
    return $self->{_question_index};
}


sub getSortOrders {
    my $self = shift;

    return undef unless defined $self->{_quiz};
    my $question_ids = join(',', keys %{$self->{_questions_sort_order}});

    my $sth = $self->{_quiz}->databaseSelect(qq(
	SELECT quiz_question_id, max(sort_order) 
	FROM tusk.quiz_answer 
        WHERE quiz_question_id in ($question_ids)
        group by quiz_question_id
    ));

    my (%sort_orders, $max) = ((), 0);
    while (my ($question_id, $sort_order) = $sth->fetchrow_array()) {
	$sort_orders{$question_id} = $sort_order;
	$max = $sort_order if $sort_order > $max;
    }
    $sth->finish;
    return (\%sort_orders, $max);
}


sub isMultipleChoiceQuiz {
    my $self = shift;

    my $items = $self->{_quiz}->getQuizItems();
    return ($self->areMultipleChoiceQuestions($items)) ? 1 : 0;
}

sub areMultipleChoiceQuestions {
    my ($self, $items) = @_;

    return 0 if (!defined $items && scalar @$items == 0);

    foreach my $item (@$items) {
	my $question = $item->getQuestionObject();
	my $question_type = $question->getType();

	if ($question_type !~ /^MultipleChoice|Section$/) {
	    return 0;
	}
	
	if ($question_type eq  'Section') {
	    $self->areMultipleChoiceQuestions($question->getSubQuestionLinks('link_question_question'));
	} 
    }

    return 1;
}


1;
