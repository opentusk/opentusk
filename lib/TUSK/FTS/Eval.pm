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


sub new {

    my $class = shift;
    my %args = @_;

    HSDB4::Constants::set_db('fts');
    my $dbh = HSDB4::Constants::def_db_handle();
    HSDB4::Constants::set_db('hsdb4');

    my $self = { school        => $args{school},
	         original_search_strings => $args{search_string},
		 eval_title    => $args{eval_title},
		 course_name   => $args{course_name},
		 from_date     => HSDB4::DateTime->new()->in_mysql_date($args{from_date}),
		 to_date       => HSDB4::DateTime->new()->in_mysql_date($args{to_date}),
		 partial_word  => $args{partial_word},
		 all_words     => $args{all_words},
		 numeric_ranking => $args{numeric_ranking},
		 no_response   => $args{no_response},
		 small_group   => $args{small_group},
		 fts           => DBIx::FullTextSearch->open($dbh,'fts_eval'),
		 evals         => undef,
		 questions     => undef,
		 responses     => undef,
	     };

    return bless $self, $class;
}


sub isWithinDateRange {

    my ($self, $start_date, $end_date) = @_;

    return 0 unless defined $start_date && defined $end_date;

    if ((HSDB4::DateTime::compare($start_date, $self->{from_date}) > 0) && (HSDB4::DateTime::compare($end_date, $self->{to_date}) < 0)) {
	return 1;
    }
    return 0;
}

sub search {
    my $self = shift;
    $self->_modify_search_strings();
    my @results = $self->_get_results();

    foreach (@results) {
	my ($school, $eval_id, $question_id) = split /_/;
	my ($eval, $q, $results_eval, $results, $question_type, $question_text); 

	eval { $eval = HSDB45::Eval->new(_school => $school, _id => $eval_id); };

	### handle some invalid time period
	next unless defined $eval->time_period()->field_value('start_date') && defined $eval->time_period()->field_value('end_date');

	my $start_date = HSDB4::DateTime->new()->in_mysql_date($eval->time_period()->field_value('start_date'));
	my $end_date = HSDB4::DateTime->new()->in_mysql_date($eval->time_period()->field_value('end_date'));
	next unless $self->isWithinDateRange($start_date,$end_date);

	eval {
	    $q = $eval->question($question_id);
	    next unless defined $q;
	    $question_type = $q->body()->question_type(); 
	    next if $question_type =~ /Instruction|Title/;
	    $results_eval = HSDB45::Eval::Results->new($eval);
	    $results = HSDB45::Eval::Question::Results->new($q,$results_eval);
	    $question_text = $q->body()->question_text();
	};

	next if $self->_set_eval($eval, $eval_id, $start_date, $end_date) == 0;

	$question_text =~ s/<.*?>//g if defined $question_text;
	$self->{questions}{$eval_id}{$question_id} = $q->aux_info('label') . " $question_text <span class=\"smallfont\">($question_type)</span>";
	my $nameInTheQuestion = 1 if $question_text =~ /$self->{search_string}/i ;

	my @responses = $results->responses();

	if (@responses) {
	    if ($question_type =~ m/QuestionRef|FillIn/) {  	
		foreach (@responses) {
		    my $response = $_->response();
		    if ($nameInTheQuestion) {
			$self->_set_response($eval_id,$question_id,$response);
		    } else {
			my $search_string = $self->{search_string};
			if ($response =~ /$search_string/i) {
			    $self->_set_response($eval_id,$question_id,$response);
			}
		    }
		}
	    } elsif ($question_type =~ m/SmallGroupsInstructor/) {
		next unless defined $self->{small_group};
		my ($cnt, $user_codes) = $self->_count_instructor(@responses);

		foreach (@{$cnt}) {
		    $self->_set_response($eval_id,$question_id,$_ );
		}

		 ### grab Question objects that are linked in the same small group
		 my @groupings = $eval->question_link()->get_children($eval_id, "grouping =  $question_id")->children();

		$self->_get_other_small_group_questions($eval, $eval_id, \@groupings, $user_codes);

	     } else {  ## ranking question
		 if (defined $self->{numeric_ranking}) {
		     $self->_set_response($eval_id,$question_id,$self->_display_numeric_ranking($results));
		 }
	     }
	} else {
	    if ($self->{no_response}) {
		$self->_set_response($eval_id,$question_id,'No response.');
	    }
	}
    }

    return ($self->{evals}, $self->{questions}, $self->{responses});
}



sub _set_eval {

    my ($self, $eval, $eval_id, $start_date, $end_date) = @_;

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

    $self->{evals}{$eval_id} = {  
	title => $eval->out_label(),
	course => $eval->course()->title(),
	course_id => $eval->course()->course_id(),
	timeperiod  =>  $start_date->out_string_date() . ' - ' . $end_date->out_string_date(),
	timeperiod_sort => $end_date->out_unix_time(),
    };

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
    } else {
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


sub _get_results {

    my $self = shift;
    my @results = ();

    if (defined $self->{all_words}) {
	@results = $self->{fts}->econtains(map { "+$_" } @{$self->{original_search_strings}});  
    } else {
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
	} else {  ## ranking question
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












