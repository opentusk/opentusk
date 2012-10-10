package HSDB45::Eval::Authoring;

use strict;
use HSDB45::Eval;
use HSDB4::Constants qw(:school);
use TUSK::Constants;
use XML::Twig;
# use XML::Twig::Compare;
use Carp qw(cluck confess);
use XML::EscapeText::HSCML qw(:html);

# the default spacing of sort_order values between adjacent questions
my $DEFAULT_SO_SPACING = 10;

sub get_dbh {
    my ($school, $un, $pw) = @_;
    my @dbc = HSDB4::Constants::db_connect($school);
    $dbc[1] = $un;
    $dbc[2] = $pw;
    return DBI->connect(@dbc);
}

sub release_dbh {
    my $dbh = shift;
    $dbh && $dbh->ping() && $dbh->disconnect ();
}

sub copy_eval_questions {
    my ($school,$orig_id, $new_id) = @_;
    my $dbh;
    my ($result, $msg) = (1, '');
    eval {
	$dbh = get_dbh($school, $TUSK::Constants::DatabaseUsers->{ContentManager}->{writeusername},$TUSK::Constants::DatabaseUsers->{ContentManager}->{writepassword});
	my $ins = $dbh->prepare(q[INSERT INTO link_eval_eval_question (parent_eval_id,child_eval_question_id,label,sort_order,required,grouping,graphic_stylesheet) VALUES (?, ?, ?, ?, ?, ?, ?)]);
	my $sel = $dbh->prepare(q[SELECT child_eval_question_id, label, sort_order, 
				  required, grouping, graphic_stylesheet 
				  FROM link_eval_eval_question WHERE parent_eval_id=?]);
	$sel->execute($orig_id);
	while (my ($qid, $lab, $sort, $req, $group, $gstyle) = $sel->fetchrow_array ) {
	    $ins->execute($new_id, $qid, $lab, $sort, $req, $group, $gstyle);
	}
    };
    ($result, $msg) = (0, $@) if $@;
    release_dbh($dbh);
    return wantarray ? ($result, $msg) : $result;
}

sub duplicate_eval {
    my ($school, $eval) = @_;
    my ($res, $msg) = (1, undef);
    my $new_eval = HSDB45::Eval->new(_school => $school);
    $new_eval->set_field_values(title => $eval->field_value('title'),
				course_id => $eval->field_value('course_id'),
				time_period_id => $eval->field_value('time_period_id'),
				available_date => $eval->field_value('available_date'),
				prelim_due_date => $eval->field_value('prelim_due_date')
				|| undef,
				due_date => $eval->field_value('due_date'));
    ($res, $msg) = $new_eval->save( );
    if (not $res) { return wantarray ? ($res, $msg) : $res; }
    ($res, $msg) = copy_eval_questions($school, $eval->primary_key(), $new_eval->primary_key());
    if (not $res) { return wantarray ? ($res, $msg) : $res; }
    return $new_eval->primary_key();
}

my %default_body = ();
$default_body{Title} = q[<Title>
  <question_text>Title text</question_text>
</Title>];
$default_body{Instruction} = q[<Instruction>
  <question_text>Instruction text</question_text>
</Instruction>];
$default_body{NumericRating} = q[<NumericRating na_available="no" num_steps="5">
  <question_text>Question text</question_text>
  <low_text>Lowest</low_text>
  <mid_text>Middle</mid_text>
  <high_text>Highest</high_text>
</NumericRating>];
$default_body{Count} = q[<Count>
  <question_text>How many question text</question_text>
  <low_bound lower_than_bound="no">0</low_bound>
  <high_bound higher_than_bound="yes">10</high_bound>
  <interval>2</interval>
</Count>];
$default_body{PlusMinusRating} = q[<PlusMinusRating na_available="no" num_steps="5">
  <question_text>Question text</question_text>
  <low_text>Most negative</low_text>
  <mid_text>Zero</mid_text>
  <high_text>Most positive</high_text>
</PlusMinusRating>];
$default_body{IdentifySelf} = q[<IdentifySelf>
  <question_text>Your response may be tied to your name.</question_text>
</IdentifySelf>];
$default_body{FillIn} = q[<FillIn longtext="no">
  <question_text>Question text</question_text>
</FillIn>];
$default_body{MultipleResponse} = q[<MultipleResponse>
  <question_text>Question text</question_text>
  <choice>First choice</choice>
  <choice>Second choice</choice>
  <choice>Third choice</choice>
  <choice>Fourth choice</choice>
  <choice>Fifth choice</choice>
</MultipleResponse>];
$default_body{MultipleChoice} = q[<MultipleChoice>
  <question_text>Question text</question_text>
  <choice>First choice</choice>
  <choice>Second choice</choice>
  <choice>Third choice</choice>
  <choice>Fourth choice</choice>
  <choice>Fifth choice</choice>
</MultipleChoice>];
$default_body{DiscreteNumeric} = q[<DiscreteNumeric>
  <question_text>Question text</question_text>
  <choice>First choice</choice>
  <choice>Second choice</choice>
  <choice>Third choice</choice>
  <choice>Fourth choice</choice>
  <choice>Fifth choice</choice>
</DiscreteNumeric>];
$default_body{YesNo} = q[<YesNo>
  <question_text>Question text</question_text>
</YesNo>];
$default_body{Ranking} = q[];
$default_body{TeachingSite} = q[<TeachingSite>
  <question_text>Question text</question_text>
</TeachingSite>];
$default_body{SmallGroupsInstructor} = q[<SmallGroupsInstructor>
  <question_text>Question text</question_text>
</SmallGroupsInstructor>];
$default_body{NumericFillIn} = q[<NumericFillIn longtext="no">
  <question_text>Question text</question_text>
</NumericFillIn>];
$default_body{QuestionRef} = q[<QuestionRef target_question_id="000">
  <question_text>Question text</question_text>
</QuestionRef>];

sub default_question_body {
    my $type = shift;
    return $default_body{$type};
}

# yuck... that's all I have to say
sub build_fdat {
    my ($qid, $sort_order, $label, $required) = @_;
    my %fdat = ();
    $fdat{"q_${qid}_sort_order"} = $sort_order;
    $fdat{"q_${qid}_label"} = $label;
    $fdat{"q_${qid}_required"} = $required;

    return \%fdat;
}

# figure out what sort_order to assign to a question that is to be
# inserted after the question with ID $qid_after, invoking
# reapportion_orderings if necessary to make space
sub prep_for_insertion {
    my ($user, $password, $eval, $preceding_qid) = @_;
    my @questions = $eval->questions();

    # if the eval is empty, this is trivial
    unless(@questions) {
	return $DEFAULT_SO_SPACING;
    }

    # if insertion is to be at the beginning of the eval...
    if($preceding_qid == 0) {
	# if the first question has the lowest possible sort_order,
	# then room must be made, and insertion will occur with a sort_order
	# value at the average of zero and $DEFAULT_SO_SPACING
	unless($questions[0]->aux_info('sort_order')) {
	    $eval->reapportion_orderings($user, $password);
	    return int($DEFAULT_SO_SPACING / 2);
	}

	return int($questions[0]->aux_info('sort_order') / 2);
    }

    # check to see if the question is to go at the end of a non-empty
    # eval...  this deals with a boundary case, as well as expedites
    # what is apt to be a common scenario
    if($questions[$#questions]->primary_key() == $preceding_qid) {
	return ($questions[$#questions]->aux_info('sort_order') +
		$DEFAULT_SO_SPACING);
    }

    # if execution is here, insertion is going to occur somewhere in the middle

    my $sort_order = 0; # the sort_order of the question with ID $preceding_qid
    my $preceding_question_offset = -1;

    foreach my $question (@questions) {
	# the question with ID $preceding_qid was found on last pass
	if($sort_order) {
	    my $space = $question->aux_info('sort_order') - $sort_order;

	    if($space > 1) {
		return $sort_order + int($space / 2);
	    }
	    else {
		$eval->reapportion_orderings($user, $password);
		return (($preceding_question_offset + 1) * $DEFAULT_SO_SPACING +
			int($DEFAULT_SO_SPACING / 2));
	    }
	}

	if($question->primary_key() == $preceding_qid) {
	    $sort_order = $question->aux_info('sort_order');
	}

	++$preceding_question_offset;
    }

    warn "could not find question with ID $preceding_qid" unless $sort_order;
}

sub create_question {
    my ($school, $un, $pw, $eval, $type, $qid_after) = @_;
    my $dbh;
    if (!defined($un) && !defined($pw)){
        ($un,$pw) =  ($TUSK::Constants::DatabaseUsers->{ContentManager}->{writeusername},$TUSK::Constants::DatabaseUsers->{ContentManager}->{writepassword});
    }
    my ($qid, $msg) = (0, '');
    eval {
	$dbh = get_dbh($school, $un, $pw);
	my $body = default_question_body($type);
	if ($type eq 'QuestionRef') { 
	    $body =~ s/000/$qid_after/gs; 
	}
	$dbh->do ('INSERT INTO eval_question (body) VALUES (?)', undef, $body);
	$qid = $dbh->{mysql_insertid};
    };
    ($qid, $msg) = (0, $@) if $@;
    if ($qid) {
	my ($r, $q_after, $sort_order);
	if ($qid_after) {
	    $q_after = $eval->question($qid_after);
	    $sort_order = $q_after->sort_order() + 1;
	}
	else {
	    $q_after = ($eval->questions())[0];
	    if($q_after) {
		$sort_order = $q_after->sort_order() - 1;
	    }
	    else {
		$sort_order = 10;
	    }
	}
	my $label = "auto";
	if (($type eq 'Title')	
		||($type eq 'Instruction')
		|| ($type eq 'TeachingSite')){
		$label = undef;
	}
	($r, $msg) = $eval->add_child_question($un, $pw, $qid,
					       sort_order => $sort_order,
					       label => $label,
					       required => "No");
    }
    release_dbh($dbh);
    return wantarray ? ($qid, $msg) : $qid;
}

   
sub make_question_duplicate {
    my ($school, $un, $pw, $eval, $orig_qid) = @_;
    my $dbh;
    if (!defined($un) && !defined($pw)){
	($un,$pw) =  ($TUSK::Constants::DatabaseUsers->{ContentManager}->{writeusername},$TUSK::Constants::DatabaseUsers->{ContentManager}->{writepassword});
    }
    my ($r, $qid, $msg) = (0, 0, '');
    my $q = $eval->question($orig_qid);
    my @refs_to_this = ();
    for my $otherq ($eval->questions()) {
	if ($otherq->body()->is_reference() && 
	    $otherq->body()->target_question_id() == $orig_qid) {
	    my $new_qid = 
		make_question_duplicate($school, $un, $pw, $eval, $otherq->primary_key());
	    push @refs_to_this, $new_qid;
	}
    }
    eval {
	$dbh = get_dbh($school, $un, $pw);
	my $body = $q->field_value('body');
	if ($body =~ /<question question_type=/) {
	    $body = $q->body()->elt()->sprint();
	}
	$dbh->do ('INSERT INTO eval_question (body) VALUES (?)', undef, $body);
	$qid = $dbh->{mysql_insertid};
    };
    ($qid, $msg) = (0, $@) if $@;
    release_dbh($dbh);

    if ($qid) {
	my %fields = ();
	for (qw/label sort_order required grouping graphic_stylesheet/) {
	    $fields{$_} = $q->aux_info($_);
	}
	($r, $msg) = $eval->add_child_question($un, $pw, $qid, %fields);
	for my $otherq ($eval->questions()) {
	    my @qids = $otherq->group_by_ids();
	    if (grep { $_ eq $orig_qid  } @qids) {
		for (0..$#qids) {
		    if ($qids[$_] == $orig_qid) {
			$qids[$_] = $qid;
		    }
		}
		$eval->update_child_question_link($un, $pw, $otherq->primary_key(), 
						  grouping => join(' ', @qids));
	    }
	}
    }

    if ($r) {
	for my $ref_id (@refs_to_this) {
	    my $q = $eval->question($ref_id);
	    $q->body()->set_target_question_id($qid);
	    $q->save($un, $pw);
	}
	($r, $msg) = $eval->delete_child_question($un, $pw, $orig_qid);
    }

    return wantarray ? ($qid, $msg) : $qid;
}

# this is basically a glue layer between the eval_edit embperl page
# and the do_question_edits subroutine, created in order to deal with
# unfortunate legacy code, as originally eval_edit called
# do_question_edits and specified a sort_order value, whereas now it
# is desired to perform question edits with the ID of the preceding
# question specified in lieu of a sort_order
sub edit_question {
    my ($eval, $question, $fdat) = @_;
    my ($user,$password) =  ($TUSK::Constants::DatabaseUsers->{ContentManager}->{writeusername},$TUSK::Constants::DatabaseUsers->{ContentManager}->{writepassword});

    my $qid = $question->primary_key();
    my $preceding_qid = $fdat->{"q_${qid}_preceding_qid"};

    $fdat->{"q_${qid}_sort_order"} =
	HSDB45::Eval::Authoring::prep_for_insertion($user, $password,
						    $eval, $preceding_qid);
    do_question_edits($user, $password, $eval, $question, $fdat);
}

# this method should no longer be used; please use edit_question
sub do_question_edits {
    my ($un, $pw, $eval, $question, $fdat) = @_;
    my $type = $question->body()->question_type();

    my ($r, $msg) = (1, '');

    my $qid = $question->primary_key();
    {
	my %fields = (sort_order => $fdat->{"q_$qid\_sort_order"},
		      label => $fdat->{"q_$qid\_label"},
		      required => ($fdat->{"q_$qid\_required"} ? 'Yes' : 'No'));
	if ($fdat->{"q_$qid\_group_by_ids"}) {
	    $fields{grouping} = $fdat->{"q_$qid\_group_by_ids"};
	}
	else {
	    $fields{grouping} = undef;
	}

	# Make sure Title and Instruction aren't required
	if ($type eq 'Title' or $type eq 'Instruction') {
	    $fields{required} = 'No';
	}
	
	($r, $msg) = $eval->update_child_question_link($un, $pw, $qid, %fields);
	return wantarray ? ($r, $msg) : $r unless $r;
    }

    {
	my $question_text = $fdat->{"q_$qid\_question_text"};
	($r, $msg) = $question->body()->set_question_text($question_text);
	return wantarray ? ($r, $msg) : $r unless $r;
    }

    {
	my $na_available = $fdat->{"q_$qid\_na_available"};
	$question->body()->set_na_available($na_available);
	return wantarray ? ($r, $msg) : $r unless $r;
    }

    if ($question->body()->is_reference()) {
	my $target_question_id = $fdat->{"q_$qid\_target_question_id"};
	($r, $msg) = $question->body()->set_target_question_id($target_question_id);
	return wantarray ? ($r, $msg) : $r unless $r;
    }
    elsif ($type eq 'NumericRating' || $type eq 'PlusMinusRating') {
	my $choice_style = $fdat->{"q_$qid\_choice_style"};
	my $choice_align = $fdat->{"q_$qid\_choice_align"};
	my $low_text = $fdat->{"q_$qid\_low_text"};
	my $mid_text = $fdat->{"q_$qid\_mid_text"};
	my $high_text = $fdat->{"q_$qid\_high_text"};
	my $num_steps = $fdat->{"q_$qid\_num_steps"};
	my $show_nums = $fdat->{"q_$qid\_show_numbers"};
	($r, $msg) = $question->body()->set_choice_style_align($choice_style, 
							       $choice_align);
	return wantarray ? ($r, $msg) : $r unless $r;
	($r, $msg) = $question->body()->set_low_mid_high_text($low_text,
							      $mid_text, 
							      $high_text);
	return wantarray ? ($r, $msg) : $r unless $r;
	($r, $msg) = $question->body()->set_num_steps($num_steps);
	($r, $msg) = $question->body()->set_show_numbers($show_nums);
    }
    elsif ($type eq 'Count') {
	my $choice_style = $fdat->{"q_$qid\_choice_style"};
	my $choice_align = $fdat->{"q_$qid\_choice_align"};
	my $low_bound = $fdat->{"q_$qid\_low_bound"};
	my $lower_than_bound = $fdat->{"q_$qid\_lower_than_bound"};
	my $high_bound = $fdat->{"q_$qid\_high_bound"};
	my $higher_than_bound = $fdat->{"q_$qid\_higher_than_bound"};
	my $interval = $fdat->{"q_$qid\_interval"};
	($r, $msg) = $question->body()->set_choice_style_align($choice_style, 
							       $choice_align);
	return wantarray ? ($r, $msg) : $r unless $r;
	($r, $msg) = $question->body()->set_low_high_bound($low_bound,
							   $high_bound, 
							   $lower_than_bound,
							   $higher_than_bound);
	return wantarray ? ($r, $msg) : $r unless $r;
	($r, $msg) = $question->body()->set_interval($interval);
    }
    elsif ($type eq 'MultipleChoice' || $type eq 'MultipleResponse' || 
	   $type eq 'DiscreteNumeric') {
	my $num_columns = $fdat->{"q_$qid\_num_columns"};
	($r, $msg) = $question->body()->set_num_columns($num_columns);
	return wantarray ? ($r, $msg) : $r unless $r;
	my @choices = ();
	for my $num (0..19) {
	    my $choice = $fdat->{"q_$qid\_choice_$num"};
	    push @choices, $choice if $choice;
	}
	($r, $msg) = $question->body()->set_choices(@choices);
    }
    elsif ($type eq 'FillIn') {
	my $longtext = $fdat->{"q_$qid\_longtext"};
	($r, $msg) = $question->body()->set_longtext($longtext);
    }
    return wantarray ? ($r, $msg) : $r unless $r;
    
    ($r, $msg) = $question->save($un, $pw);
    return wantarray ? ($r, $msg) : $r unless $r;
}

sub message_processor {
    my $msg = shift;
    # Look for XML errors
    if ($msg =~ /Could not parse text/) {
	cluck $msg;
	return "XML is incorrect; is there a mismatched tag?";
    }
    if ($msg =~ /DBI\-\>connect.*Access denied/) {
	return "Database connection was denied; did you mis-type your password?";
    }
    return $msg;
}

sub fix_inline_text {
    my $text = shift;
    return unless $text;
    return $html_inline->xml_escape($text);
}

sub fix_flow_text {
    my $text = shift;
    return unless $text;
    return $html_flow->xml_escape($text);
}

sub check_field_values {
    my $fdat = shift;

    my ($res, $msg) = (1, '');
    unless ($fdat->{title}) {
	$res = 0;
	$msg .= "Must specify an eval title.\n";
    }
    unless ($fdat->{course_id}) {
	$res = 0;
	$msg .= "Must select a course.\n";
    }
    unless ($fdat->{time_period_id}) {
	$res = 0;
	$msg .= "Must select a time period.\n";
    }
    if ($fdat->{available_date} && $fdat->{due_date}) {
	my $adate = HSDB4::DateTime->new()->in_mysql_date($fdat->{available_date});
	my $ddate = HSDB4::DateTime->new()->in_mysql_date($fdat->{due_date});
	my $pdate = HSDB4::DateTime->new()->in_mysql_date($fdat->{prelim_due_date}) if $fdat->{prelim_due_date};

	if ($adate->has_value() && $ddate->has_value()) {
	    unless ($adate->out_unix_time() <= $ddate->out_unix_time()) {
		$res = 0;
		$msg .= "Available date must be less than or equal to due date.\n";
	    }
	    if ($pdate && $pdate->has_value()) {
		unless ($pdate->out_unix_time() <= $ddate->out_unix_time()) {
		    $res = 0;
		    $msg .= "Preliminary due date must be less than or equal to due date.\n";
		}
	    }
	}
	else {
	    $res = 0;
	    $msg .= "Available and due dates must be valid YYYY-MM-DD format.\n";
	}
    }
    else {
	$res = 0;
	$msg .= "Must specify available and due dates.\n";
    }
    return wantarray ? ($res, $msg) : $res;
}

1;
__END__
