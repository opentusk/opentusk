package HSDB45::Eval::Results::Formatter;

use strict;
use base qw(XML::Formatter);

use XML::Twig;
use XML::EscapeText qw(:escape);
use HSDB4::Constants;
use HSDB45::Eval::Results;
use HSDB45::Eval::Question::ResponseStatistics;
use HSDB45::Eval::Results::BarGraphCreator;

BEGIN {
    use vars qw($VERSION);
    $VERSION = do { my @r = (q$Revision: 1.48 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
}

sub version { return $VERSION }

# dependencies for things that relate to caching
my @mod_deps  = ('HSDB45::Eval::Results',
		 'HSDB45::Eval::Question::ResponseStatistics',
		 'HSDB45::Eval::Results::BarGraphCreator');
my @file_deps = ();

sub get_mod_deps { return @mod_deps }
sub get_file_deps { return @file_deps }


# Description: Generic constructor
# Input: A Eval::Results object
# Output: Blessed, initialized HSDB45::Eval::Results::Formatter object
sub new {
    my $incoming = shift();
    my $object = shift();
    my $self = $incoming->SUPER::new($object);
    return $self->_init(@_);
}

sub object_id {
    my $self = shift();
    return $self->object()->parent_eval()->primary_key();
}

sub new_from_path {
    my $incoming = shift();
    my $path = shift();
    $path =~ s/^\///;
    my ($school, $id) = split(/\//, $path);
    my $object = class_expected()->new(HSDB45::Eval->new(_school => $school, _id => $id));
    my $self = $incoming->SUPER::new($object);
    $self->_init($object);
    $self->{-doctype_decl} = 'Eval_Results';
    $self->{-dtd_decl} = 'http://tusk.tufts.edu/DTD/Eval_Results.dtd';
    $self->{-stylesheet_decl} = 'http://tusk.tufts.edu/XSL/Eval/eval_results.xsl';
    return $self;
}

sub class_expected {
    return 'HSDB45::Eval::Results';
}

sub modified_since {
    my $self = shift;
    my $timestamp = shift;

    my $dbh = HSDB4::Constants::def_db_handle();
    my $db = HSDB4::Constants::get_school_db($self->object()->parent_eval()->school());
    my $sth = $dbh->prepare("SELECT COUNT(*) from $db.eval_completion WHERE eval_id=? AND created>?");
    $sth->execute($self->object_id(), $timestamp->out_mysql_timestamp());
    my ($count) = $sth->fetchrow_array();
    return $count ? 1 : 0;
}


# Description: Private initializer
# Input: An Eval::Results object
# Output: Initialized object
sub _init {
    my $self = shift;
    $self->{-user_letter} = 'a';
    $self->{-user_number} = 0;
    $self->{-user_code_letters} = {};
    $self->{-comparison_eval_ids} = [];
    return $self;
}

sub get_xml_elt {
    my $self = shift();
    return $self->eval_results_elt();
}


# Description: Returns the XML::Twig::Elt object for Eval_Results, generating if necessary
# Input: 
# Output: said XML::Twig::Elt object
sub eval_results_elt {
    my $self = shift();
    my $no_bargraphs = shift();

    unless($self->{-eval_results_elt}) {
	my $eval = $self->object()->parent_eval();
	my $elt = 
	  XML::Twig::Elt->new("Eval_Results",
			      {"school"         => $eval->school(),
			       "eval_id"        => $eval->primary_key()});
	$elt->set_pretty_print("indented");
	# $self->eval_header_elt()->paste('last_child', $self->{-eval_results_elt});
        # $self->enrollment_elt()->paste('last_child', $self->{-eval_results_elt});
	foreach my $question_results_elt ($self->question_results_elts()) {
	    $question_results_elt->paste('last_child', $elt);
	}
        $self->{-eval_results_elt} = $elt;
	$self->do_bar_graphs() unless $no_bargraphs;
    }

    return $self->{-eval_results_elt};
}

sub do_bar_graphs {
    my $self = shift;
    my $eval = $self->object()->parent_eval();
    my $bar_graph_creator = 
      HSDB45::Eval::Results::BarGraphCreator->new($eval->school(), $eval->primary_key(),
						  $self->eval_results_elt()->sprint());
    $bar_graph_creator->save_svg_graphs();
}


# Description: Returns the XML::Twig::Elt object for eval_header, generating it if necessary
# Input: 
# Output: said XML::Twig::Elt object
sub eval_header_elt {
    my $self = shift();

    unless($self->{-eval_header_elt}) {
	my $eval = $self->object()->parent_eval();
	$self->{-eval_header_elt} = 
	  XML::Twig::Elt->new("eval_header",
			      );

	my $eval_title_elt = XML::Twig::Elt->new("eval_title", {}, $eval->field_value('title'));
	my $course_ref_elt = XML::Twig::Elt->new("course-ref",
						 {"code"      => $eval->course->field_value('oea_code'),
						  "school"    => $eval->course()->school(),
						  "course-id" => $eval->course()->primary_key()},
						 $eval->course()->out_label()
						 );
	my $available_date_elt = XML::Twig::Elt->new("available_date", {}, $eval->field_value('available_date'));
	my $due_date_elt = XML::Twig::Elt->new("due_date", {}, $eval->field_value('due_date') );

	$eval_title_elt->paste('last_child', $self->{-eval_header_elt});
	$course_ref_elt->paste('last_child', $self->{-eval_header_elt});
	$available_date_elt->paste('last_child', $self->{-eval_header_elt});
	$due_date_elt->paste('last_child', $self->{-eval_header_elt});

	if($eval->field_value('prelim_due_date')) {
	    my $prelim_due_date_elt = XML::Twig::Elt->new("prelim_due_date");
	    $prelim_due_date_elt->paste('last_child', $self->{-eval_header_elt});
	}
    }

    return $self->{-eval_header_elt};
}

# Description: Returns the XML::Twig::Elt object for Enrollment, generating it if necessary
# Input: 
# Output: said XML::Twig::Elt object
sub enrollment_elt {
    my $self = shift();

    unless($self->{-enrollment_elt}) {
	my $eval = $self->object()->parent_eval();
	my $num_users = $eval->num_users();
	my $num_comps = $self->object()->total_user_codes() || 0;
	my $num_incomps = $num_users - $num_comps;

	$self->{-enrollment_elt} = XML::Twig::Elt->new("Enrollment", {"count" => $num_users});

	my $complete_users_elt = XML::Twig::Elt->new("CompleteUsers",
						     {"count"   => $num_comps,
						      "percent" => $num_comps == 0 ? 0 : sprintf("%.2f", 100 * $num_comps / $num_users)});
	foreach my $complete_user ($eval->complete_users()) {
	    my $complete_user_elt = XML::Twig::Elt->new("user-ref",
							{"user-id" => $complete_user->primary_key()},
							$complete_user->out_full_name());
	    $complete_user_elt->paste('last_child', $complete_users_elt);
	}
	$complete_users_elt->paste('last_child', $self->{-enrollment_elt});

	my $incomplete_users_elt = XML::Twig::Elt->new("IncompleteUsers",
						       {"count"   => $num_incomps,
							"percent" => $num_comps == 0 ? 0 : sprintf("%.2f", 100 * $num_incomps / $num_users)});
	foreach my $incomplete_user ($eval->incomplete_users()) {
	    my $incomplete_user_elt = XML::Twig::Elt->new("user-ref",
							  {"user-id" => $incomplete_user->primary_key()},
							  $incomplete_user->out_full_name());
	    $incomplete_user_elt->paste('last_child', $incomplete_users_elt);
	}
	$incomplete_users_elt->paste('last_child', $self->{-enrollment_elt});

	my $deficit;
	if(($deficit = $self->object()->total_user_codes() - $self->object()->total_completions()) > 0) {
	    my $completion_token_deficit_elt = XML::Twig::Elt->new("CompletionTokenDeficit", {}, $deficit);
	    $completion_token_deficit_elt->paste('last_child', $self->{-enrollment_elt});
	}

	my $excess;
	if(($excess = $self->object()->total_user_codes() > $eval->num_users()) > 0) {
	    my $excess_completions_elt = XML::Twig::Elt->new("ExcessCompletions", {}, $excess);
	    $excess_completions_elt->paste('last_child', $self->{-enrollment_elt});
	}
    }

    return $self->{-enrollment_elt};
}

sub question_results_elts {
    my $self = shift();

    unless($self->{-question_results_elts}) {
	$self->{-question_results_elts} = [];
	foreach my $question_results ($self->object()->question_results()) {
	    my $type = $question_results->question()->body()->question_type();
	    next if ($type eq 'Title' || $type eq 'Instruction');
	    if($self->verbose()) {
		print STDERR sprintf("Starting question %d [%s] (Size: %d)\n", 
				     $question_results->question()->primary_key(),
				     $question_results->question()->body()->question_type()
				     );
	    }

	    push(@{$self->{-question_results_elts}}, $self->question_results_elt($question_results));
	}
    }

    return @{$self->{-question_results_elts}};
}

sub question_results_elt {
    my $self = shift();
    my $question_results = shift();

    my $question_results_elt = 
      XML::Twig::Elt->new("Question_Results",
			  {"eval_question_id" => 
			       $question_results->question()->primary_key() }
			  );
    
    # my $eval_question_elt = $self->eval_question_elt($question_results);
    # $eval_question_elt->paste('last_child', $question_results_elt);
    
    if ($question_results->responses()) {
	my $response_group_elt = XML::Twig::Elt->new("ResponseGroup");
	my $statistics_elt = $self->statistics_elt($question_results->statistics());
	$statistics_elt->paste('last_child', $response_group_elt);
	foreach my $response ($question_results->responses()) {
	    my $response_elt = $self->response_elt($response);
	    $response_elt->paste('last_child', $response_group_elt) if($response_elt);
	}

	$response_group_elt->paste('last_child', $question_results_elt);

	foreach my $categorization ($question_results->categorizations()) {
	    my $categorization_elt = $self->categorization_elt($categorization);
	    $categorization_elt->paste('last_child', $question_results_elt);
	}
    }

    return $question_results_elt;
}

sub response_group_elt {
    my $self = shift();
    my $response_group = shift();
    my $for_categorization = shift();

    my $response_group_elt = XML::Twig::Elt->new("ResponseGroup");

    my $grouping_value_elt = XML::Twig::Elt->new("grouping_value", {}, $response_group->label());
    $grouping_value_elt->paste('last_child', $response_group_elt);

    my $statistics_elt = $self->statistics_elt($response_group->statistics(), $for_categorization);
    $statistics_elt->paste('last_child', $response_group_elt);

    foreach my $response ($response_group->responses()) {
	my $response_elt = $self->response_elt($response);
	$response_elt->paste('last_child', $response_group_elt) if $response_elt;
    }

    return $response_group_elt;
}

sub categorization_elt {
    my $self = shift();
    my $categorization = shift();

    my $categorization_elt = XML::Twig::Elt->new("Categorization",
						 {"group_by_question_id" =>
						      $categorization->grouping_results()->question()->primary_key()});

    foreach my $resp_group_label (sort $categorization->response_group_labels()) {
	my $resp_group = $categorization->response_group($resp_group_label);
	my $response_group_elt = $self->response_group_elt($resp_group, 1);
	$response_group_elt->paste('last_child', $categorization_elt);
    }

    return $categorization_elt;
}

sub eval_question_elt {
    my $self = shift();
    my $question_results = shift();

    my $eval_question_elt = XML::Twig::Elt->new("EvalQuestion",
						{"required" => $question_results->question()->is_required ? 'Yes' : 'No',
						 "sort_order" => $question_results->question()->sort_order(),
						 "eval_question_id" => $question_results->question()->primary_key()});
    
    if($question_results->question()->label()) {
	my $question_label_elt = XML::Twig::Elt->new("question_label", {}, $question_results->question()->label());
	$question_label_elt->paste('last_child', $eval_question_elt);
    }

    foreach my $gid ($question_results->question()->group_by_ids()) {
	my $grouping_elt = XML::Twig::Elt->new("grouping", {"group_by_id" => $gid});
	$grouping_elt->paste('last_child', $eval_question_elt);
    }

    $question_results->question()->body()->elt()->copy()->paste('last_child', $eval_question_elt);
    
    return $eval_question_elt;
}

sub statistics_elt {
    my $self = shift();
    my $statistics = shift();
    my $for_categorization = shift();

    my $response_statistics_elt = XML::Twig::Elt->new("ResponseStatistics");

    my $response_count_elt = XML::Twig::Elt->new("response_count", {}, $statistics->count());
    $response_count_elt->paste('last_child', $response_statistics_elt);

    my $no_response_count_elt;
    if($for_categorization) {
	my @group_by_question_results = $statistics->response_group()->parent_results()->group_by_question_results();
	my $label = $statistics->response_group()->label();
	my $no_response_count;
	if($label eq '__NULL__') {
	    $no_response_count = 0;
	}
	else {
	    if($group_by_question_results[0]->statistics()->histogram()) {
		$no_response_count = $group_by_question_results[0]->statistics()->histogram()->bin_count($label) - 
		    $statistics->count() - $statistics->na_count();
	    }
	    else {
		$no_response_count = 0;
	    }
	}

	$no_response_count_elt = 
	  XML::Twig::Elt->new("no_response_count", {}, $no_response_count);
    }
    else {
	$no_response_count_elt = XML::Twig::Elt->new("no_response_count", {},
						     $self->object()->total_user_codes() - 
						     $statistics->count() - $statistics->na_count());
    }


    $no_response_count_elt->paste('last_child', $response_statistics_elt);

    my $na_response_count_elt = XML::Twig::Elt->new("na_response_count", {}, 
						    $statistics->na_count());
    $na_response_count_elt->paste('last_child', $response_statistics_elt);

    if($statistics->histogram()) {
	my $histogram = $statistics->histogram();
	my $histogram_elt = XML::Twig::Elt->new("Histogram");
	foreach my $resp ($histogram->bins()) {
	    my $histogram_bin_elt = XML::Twig::Elt->new("HistogramBin",
							{"count" => $histogram->bin_count($resp)}, $resp);
	    $histogram_bin_elt->paste('last_child', $histogram_elt);
	}
	$histogram_elt->paste('last_child', $response_statistics_elt);
    }
    
    if($statistics->mean()) {
	my $mean_elt = XML::Twig::Elt->new("mean", {}, sprintf("%.2f", $statistics->mean()));
	$mean_elt->paste('last_child', $response_statistics_elt);
    }
    
    if($statistics->standard_deviation()) {
	my $standard_deviation_elt = XML::Twig::Elt->new("standard_deviation", {},
						      sprintf("%.2f", $statistics->standard_deviation()));
	$standard_deviation_elt->paste('last_child', $response_statistics_elt);
    }

    if($statistics->median()) {
	my $median_elt = XML::Twig::Elt->new("median", {}, sprintf("%.2f", $statistics->median()));
	$median_elt->paste('last_child', $response_statistics_elt);
    }

    if($statistics->median25()) {
	my $median25_elt = XML::Twig::Elt->new("median25", {}, sprintf("%.2f", $statistics->median25()));
	$median25_elt->paste('last_child', $response_statistics_elt);
    }

    if($statistics->median75()) {
	my $median75_elt = XML::Twig::Elt->new("median75", {}, sprintf("%.2f", $statistics->median75()));
	$median75_elt->paste('last_child', $response_statistics_elt);
    }

    if($statistics->mode()) {
	my $mode_elt = XML::Twig::Elt->new("mode", {}, sprintf("%.2f", $statistics->mode()));
	$mode_elt->paste('last_child', $response_statistics_elt);
    }
    return $response_statistics_elt;
}

# Description: Returns whether or not verbose is on
# Input: 
# Output: 1 if verbose is on
sub verbose {
    my $self = shift;
    return 1 if $self->{-verbose};
}

# Description: Writes the XML for a question results object
# Input: A HSDB45::Eval::Question::Results object
# Output:
# Description: Turns a user_code into a nice letter.
# Input: The user_code
# Output: A nice letter unique to the given user_code.
sub user_code_labeler {
    my $self = shift;
    my $user_code = shift;
    # If we already have this user, then just return that
    return $self->{-user_code_letters}{$user_code} if $self->{-user_code_letters}{$user_code};
    # If it's a new user, the either be "a" or "1c" or whatever
    $self->{-user_code_letters}{$user_code} = 
	$self->{-user_number} == 0 ? $self->{-user_letter} : 
	    $self->{-user_number} . $self->{-user_letter};
    # Now increment properly; we have to wrap around at 'z' and increment the number
    if ($self->{-user_letter} eq 'z') {
	$self->{-user_letter} = 'a';
	$self->{-user_number}++;
    }
    else { $self->{-user_letter}++ }
    # And return the code
    return $self->{-user_code_letters}{$user_code};
}

sub response_elt {
    my $self = shift();
    my $response = shift();
    my $interpreted_response = $response->interpreted_response();
    if($interpreted_response) {
	my $response_elt = XML::Twig::Elt->new("Response",
					       {"user_token" => $response->user_code(),
						"pretty_user_label" => 
						    $self->user_code_labeler($response->user_code())},
					       make_pcdata($interpreted_response));
	$response_elt->set_asis();
	return $response_elt;
    }

    return 0;
}

1;
__END__
