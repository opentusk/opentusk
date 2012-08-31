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


package TUSK::FTS::Eval;

use strict;
use DBIx::FullTextSearch;
use DBIx::FullTextSearch::StopList;
use HSDB4::SQLRow::User;
use HSDB4::Constants;
use HSDB45::Eval::Question;
use HSDB45::Eval::Question::Body;
use HSDB45::Eval::Question::Results;
use HSDB45::Eval::Question::Results::SmallGroupInstructor;
use HSDB45::Eval::Results;
use HSDB45::Eval::Question::ResponseStatistics;
use HSDB45::Eval::Question::ResponseGroup;
use HSDB4::DateTime;
use TUSK::Application::Eval::Search;


sub new {

    my $class = shift;
    my %args = @_;

    HSDB4::Constants::set_db('fts');
    my $dbh = HSDB4::Constants::def_db_handle();
    HSDB4::Constants::set_db('hsdb4');

    my $self = {
    	school					=> $args{school},
	    original_search_strings	=> $args{search_string},
		eval_title				=> $args{eval_title},
		course_name				=> $args{course_name},
		start_time_period		=> $args{start_time_period_id},
		end_time_period			=> $args{end_time_period_id},
		start_available_date	=> $args{start_available_date},
		end_available_date		=> $args{end_available_date},
		start_due_date			=> $args{start_due_date},
		end_due_date			=> $args{end_due_date},
		partial_word			=> $args{partial_word},
		all_words				=> $args{all_words},
		numeric_ranking			=> $args{numeric_ranking},
		no_response				=> $args{no_response},
		small_group				=> $args{small_group},
		merged					=> $args{merged},
		single					=> $args{single},
		outsidetime				=> $args{outsidetime},
		onlysingle				=> $args{onlysingle},
		fts						=> DBIx::FullTextSearch->open($dbh,'fts_eval'),
		single_evals			=> undef,
		merged_evals			=> undef,
		questions				=> undef,
		responses				=> undef,
	};

    return bless $self, $class;
}


sub search {
    my $self = shift;

	## get full-text search results and format into hash keyed on eval_id(s) and then quesion_id(s);
	## if no FTS results, exit
    $self->_modify_search_strings();
    my @results = $self->_get_results();
	unless (@results) { return 0; }
	my %results_hash;

	foreach (@results) {
		$_ =~ m/(\w+)_(\d+)_(\d+)/;
		$results_hash{$2}{$3} = $2;
	}

	## narrow down evals by time period, available date and or due date filters from search form
	my $fts_eval_ids_subset = $self->narrow_down_eval_ids([ keys %results_hash ]);
	unless (scalar @$fts_eval_ids_subset) { return 0; }
	
	my $tmpeval = HSDB45::Eval->new( _school => $self->{school} );
	my %eval_hash = map { $_->primary_key() => $_ } $tmpeval->lookup_conditions('eval_id IN (' . join(",", @$fts_eval_ids_subset) . ')');

	my %merged_hash;
	my $all_nonmerged;
	
	## if user wants merged results, check to see if time restriction is loose or strict
	if ($self->{merged}) {
		my $merged_array = TUSK::Application::Eval::Search::getMergedEvalsThatContain($self->{school}, $fts_eval_ids_subset);
		## if strict
		if (!$self->{outsidetime}) {
			## merge array of matched and narrow down by time evals to all other evals that fit the time requirements
			my @time_evals_ids_subset = (@{$self->narrow_down_eval_ids()}, @$fts_eval_ids_subset);
			## and remove duplicates by converting it into a hash and then grabbing the keys
			my %tmp_hash = map { $_, 1 } @time_evals_ids_subset;
			@time_evals_ids_subset = sort keys %tmp_hash;

			## get loose results and then loop through and narrow down
			##
			## NOTE: this would not be necessary if the link between a merged_eval_id and various eval_ids was done in a normalized way in the DB 
			##
			%merged_hash = map { $_->primary_key() => $_ } @$merged_array;
			while (my($merged_eval_id, $merged_eval) = each(%merged_hash)) {
				## check if primary eval id is in the time range
				## if it is, add to $merged_evals
				if (!(grep {$_ eq $merged_eval_id} @time_evals_ids_subset)) {
					$self->_set_merged_eval($merged_eval, $merged_eval_id);
					next;
				}
				## check if all the secondary eval ids are in the time range
				## if they are, add to $merged_evals
				my %time_evals_ids_subset = map {$_=>1} @time_evals_ids_subset;				
				if (!(scalar (grep { !$time_evals_ids_subset{$_} } $merged_eval->secondary_eval_ids()))) {
					$self->_set_merged_eval($merged_eval, $merged_eval_id);
				}
			}
		}
		## else, go loose
		else {
			map { $self->_set_merged_eval($_, $_->primary_key()) } @$merged_array;
		}
	}

	## get set of all nonmerged evals
	if ($self->{onlysingle}) {
		$all_nonmerged = TUSK::Application::Eval::Search::getNonmergedEvalIdsSubset($self->{school}, $fts_eval_ids_subset);
	}

	## get all associated questions for the single eval ids
	my $tmpquestion = HSDB45::Eval::Question->new( _school => $self->{school} );
	my @question_ids = map { keys %{$results_hash{$_}} } @$fts_eval_ids_subset;
	my %question_hash = map { $_->primary_key() => $_ } $tmpquestion->lookup_conditions('eval_question_id IN (' . join(",", @question_ids) . ')');

	while (my($eval_id, $eval) = each(%eval_hash)){
		## if user only wants non-merged arrays, check for membership in $all_nonmerged array ref first
		if ($self->{onlysingle}) {
			next unless (grep { $_ eq $eval_id } @$all_nonmerged);
		}
		my $question_ids = $results_hash{$eval_id};

		foreach my $question_id (keys %$question_ids) {
			my $question = $question_hash{$question_id};
			my ($results_eval, $results, $question_type, $question_text);
			eval {
				$question_type = $question->body()->question_type(); 
				next if $question_type =~ /Instruction|Title/;
				$question->set_aux_info(parent_eval => $eval);		## necessary in order to get results using $question object
				$results_eval = HSDB45::Eval::Results->new($eval);
				$results = HSDB45::Eval::Question::Results->new($question,$results_eval);
				$question_text = $question->body()->question_text();
			};
		
			## if user wants to see single evals, add eval to single eval hash
			if ($self->{single}) {			
				next if $self->_set_single_eval($eval, $eval_id) == 0;
			}
			$question_text =~ s/<.*?>//g if defined $question_text;
			$self->{questions}{$eval_id}{$question_id} = $question->aux_info('label') . " $question_text <span class=\"smallfont\">($question_type)</span>";
			my $nameInTheQuestion = 1 if $question_text =~ /$self->{search_string}/i ;		
			my @responses = $results->responses();
			if (@responses) {
				if ($question_type =~ m/QuestionRef|FillIn/) {  	
					foreach (@responses) {
						my $response = $_->response();
						if ($nameInTheQuestion) {
							$self->_set_response($eval_id,$question_id,$response);
						}
						else {
							my $search_string = $self->{search_string};
							if ($response =~ /$search_string/i) {
								$self->_set_response($eval_id,$question_id,$response);
							}
						}
					}
				}
				elsif ($question_type =~ m/SmallGroupsInstructor/) {
					next unless defined $self->{small_group};
					my ($cnt, $user_codes) = $self->_count_instructor(@responses);
					
					foreach (@{$cnt}) {
						$self->_set_response($eval_id,$question_id,$_ );
					}
		
					## grab Question objects that are linked in the same small group
					my @groupings = $eval->question_link()->get_children($eval_id, "grouping =  $question_id")->children();
			
					$self->_get_other_small_group_questions($eval, $eval_id, \@groupings, $user_codes);
		
				}
				else {  ## ranking question
					if (defined $self->{numeric_ranking}) {
						$self->_set_response($eval_id,$question_id,$self->_display_numeric_ranking($results));
					}
				}
			}
			else {
				if ($self->{no_response}) {
					$self->_set_response($eval_id,$question_id,'No response.');
				}
			}
		}
	}

    return ($self->{single_evals}, $self->{merged_evals}, $self->{questions}, $self->{responses});
}


sub _set_single_eval {

    my ($self, $eval, $eval_id) = @_;

    if (defined $self->{eval_title} && $self->{eval_title} =~ /\w+/) {
		unless ($eval->out_label() =~ /$self->{eval_title}/gi) {
			return 0;
		}
    }

    if (defined $self->{course_name} && $self->{course_name} =~ /\w+/) {
		unless ($eval->course()->title() =~ /$self->{course_name}/gi) {
			return 0;
		}
    }

    $self->{single_evals}{$eval_id} = {  
		title => $eval->out_label(),
		course => $eval->course()->title(),
		course_id => $eval->course()->course_id(),
		timeperiod  =>  $eval->time_period()->out_display() . " " . $eval->time_period()->out_date_range(),
		timeperiod_sort => $eval->time_period()->end_date()
    };

    return 1;
}


sub _set_merged_eval {

    my ($self, $merged_eval, $merged_eval_id) = @_;
	my $tmpeval = HSDB45::Eval->new( _school => $self->{school}, _id => $merged_eval->primary_eval_id());

    $self->{merged_evals}{$merged_eval_id} = {  
		title => $merged_eval->title(),
		primary_eval => {id => $merged_eval->primary_eval_id(), title => $tmpeval->out_label()},
		secondary_evals => []
    };
 
	if ($merged_eval->secondary_eval_ids()) {
		my @secondary_evals = $tmpeval->lookup_conditions('eval_id IN (' . join(",", $merged_eval->secondary_eval_ids()) . ')'); 
		foreach my $eval (@secondary_evals) {
			push @{$self->{merged_evals}{$merged_eval_id}{secondary_evals}}, {id => $eval->primary_key(), title=> $eval->out_label()};
		}
	}

    return 1;
}


sub _set_response {

    my ($self, $eval_id, $question_id, $response) = @_;
    push @{$self->{responses}{$eval_id}{$question_id}}, $response;
}


sub _modify_search_strings {

    my $self = shift;
    my @search_strings = ();

    if (defined $self->{partial_word}) { 	
		push @search_strings, map { "$_*" } @{$self->{original_search_strings}};
    }
    else {
		push @search_strings, @{$self->{original_search_strings}};
    }

    ### include some words that contain single quotes, hyphens
    push @search_strings, map { "$_'*" } @{$self->{original_search_strings}};
    push @search_strings, map { "$_-*" } @{$self->{original_search_strings}};

    $self->{search_strings} = \@search_strings;

    my @search_strings_for_match = (defined $self->{partial_word}) 
	? @{$self->{original_search_strings}}
        : map { "\\b$_\\b" } @{$self->{original_search_strings}};

    push @search_strings_for_match, map { "$_'" } @{$self->{original_search_strings}};
    push @search_strings_for_match, map { "$_-" } @{$self->{original_search_strings}};

    $self->{search_string} = join('|', @search_strings_for_match);
}


sub get_modified_search_strings {
    my $self = shift;
    return $self->{search_strings};
}


sub narrow_down_eval_ids {
    my $self = shift;
    my $eval_ids = shift;
	my $db = HSDB4::Constants::get_school_db($self->{school});
	my $sql = "SELECT eval_id FROM $db.eval e";
	my @conditions;
	if ($eval_ids) {
		push @conditions, ("eval_id IN(" . join(",", @$eval_ids) . ")");
	}
	my @binds;

	# compose conditions/bound values related to time periods, if they've been submitted
	if ($self->{start_time_period} && $self->{end_time_period}) {
		$sql .= ", $db.time_period tp, $db.time_period start_tp, $db.time_period end_tp WHERE ";
		push @conditions, ("e.time_period_id = tp.time_period_id","tp.start_date >= start_tp.start_date", "start_tp.time_period_id = ?", "tp.end_date <= end_tp.end_date", "end_tp.time_period_id = ?"); 
		push @binds, ($self->{start_time_period}, $self->{end_time_period});
	}
	else {
		$sql .= " WHERE ";
	}
	
	# compose conditions/bound values related to available date range, if it's been submitted
	if ($self->{start_available_date} && $self->{end_available_date}) {
		push @conditions, ("e.available_date >= ?", "e.available_date <= ?");
		push @binds, ($self->{start_available_date}, $self->{end_available_date});
	}
	
	# compose conditions/bound values related to due date range, if it's been submitted
	if ($self->{start_due_date} && $self->{end_due_date}) {
		push @conditions, ("e.due_date >= ?", "e.due_date <= ?");
		push @binds, ($self->{start_due_date}, $self->{end_due_date});
	}
	
	$sql .= join " AND ", @conditions;

	my $dbh = HSDB4::Constants::def_db_handle();
    HSDB4::Constants::set_db('hsdb4');
	my $sth = $dbh->prepare($sql);
	$sth->execute(@binds);
	my @narrowed;
	while (my $eval_id = $sth->fetchrow_array()) {
		push (@narrowed, $eval_id);
	}
	$sth->finish();

	return \@narrowed;
}

sub _get_results {

    my $self = shift;
    my @results = ();

    if (defined $self->{all_words}) {
		@results = $self->{fts}->econtains(map { "+$_" } @{$self->{original_search_strings}});  
    }
    else {
		@results = $self->{fts}->contains(@{$self->{search_strings}});  
    }

    return grep { /$self->{school}/ } @results;
}



sub _display_numeric_ranking {

    my ($self,$results) = @_;

    my $stats = $results->statistics();

    return 'Number of students: ' . $stats->count() . ' &nbsp;&nbsp; Mean: ' . sprintf("%.2f", $stats->mean()) . ' &nbsp;&nbsp; Standard Deviation: ' . sprintf("%.2f", $stats->standard_deviation()) . ' &nbsp;&nbsp; N/A: ' . $stats->na_count();

}


sub _get_other_small_group_questions {

    my ($self, $eval, $eval_id, $groupings, $user_codes) = @_;
    my ($question_id, $q, $results_eval, $results, $question_type);

    foreach my $gr (@{$groupings}) {
		eval {
			$question_id = $gr->getPrimaryKeyID();
			$q = $eval->question($question_id);
			$results_eval = HSDB45::Eval::Results->new($eval);
			$results = HSDB45::Eval::Question::Results::SmallGroupInstructor->new($q,$results_eval,$user_codes);
			$question_type = $q->body()->question_type(); 
		};
	
		$self->{questions}{$eval_id}{$question_id} = $q->body()->question_text() . " ($question_type)";
	
		if ($question_type =~ m/FillIn/) {
			foreach ($results->responses()) {
				$self->_set_response($eval_id,$question_id,$_->response()) if exists $user_codes->{$_->field_value('user_code')};
			}
		}
		else {  ## ranking question
			if (defined $self->{numeric_ranking}) {
				$self->_set_response($eval_id,$question_id,$self->_display_numeric_ranking($results));
			}
			$self->{response_group} = $results;
		}
    }
}



sub interprete_responses {

    my ($self,@responses) = @_;
    my %responses = ();
    foreach (@responses) {
		$responses{$_->response()}++;
    }
    
    my $data = "<table>\n<tr>";
    my $tcnt = "<tr>";
    foreach (sort keys %responses) {
		$data .= "<td align=\"center\" width=\"30\">$_</td>";
		$tcnt .= "<td align=\"center\">$responses{$_}</td>";
    }

    $data .= "</tr>\n$tcnt</tr>\n</table>";

    return $data;
}


### input:  Response objects
### output:  array of counts and array of usercodes list
### we use an array so as to handle if the search names appear more than once
### in the list of small grouop instructors
sub _count_instructor {

    my ($self,@responses) = @_; 
    my %responses = ();
    my @results = ();
    my @results_user_codes = ();

    ### a hash of instructors' userids of an array of students' usercodes
    push @{$responses{$_->response()}}, $_->field_value('user_code') foreach (@responses);

    foreach my $instructor_userid (keys %responses) {
		my $user = HSDB4::SQLRow::User->new(_school => $self->{school}, _id => $instructor_userid);
	
		my $name = (defined $user) ? $user->first_name() . ' ' . $user->last_name() : $instructor_userid;
	
		if ($name =~ /$self->{search_string}/i) {
			push @results,  scalar @{$responses{$instructor_userid}} . ' out of ' . scalar @responses . " students had $name as a small group instructor.";
			push @results_user_codes, @{$responses{$instructor_userid}};
		}
    }

    my %user_codes = map { $_ => '' } @results_user_codes;

    return (\@results, \%user_codes);
}


1;

