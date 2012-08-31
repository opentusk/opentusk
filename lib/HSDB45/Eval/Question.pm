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


package HSDB45::Eval::Question;

use strict;
use HSDB45::Eval::Question::Body;
use Carp;
#use overload ('<=>' => \&sort_order_compare,
#	      'bool' => \&valid_question);

BEGIN {
    use vars qw($VERSION);
    use base qw(HSDB4::SQLRow);

    $VERSION = do { my @r = (q$Revision: 1.34 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
}

=head1 NAME

B<HSDB45::Eval::Question> - Class for manipulating entries in table eval_question

=head1 DESCRIPTION

Object that represents an eval question.  Subclass of HSDB4::SQLRow

=over 4

=head1 METHODS

=cut

sub version {
    return $VERSION;
}

# dependencies for things that relate to caching
my @mod_deps  = ('HSDB45::Eval::Question::Body',
		 'HSDB45::Eval');
my @file_deps = ();

sub get_mod_deps {
    return @mod_deps;
}

sub get_file_deps {
    return @file_deps;
}


# Non-exported package globals go here
use vars ();

# File-private lexicals
my $tablename = "eval_question";
my $primary_key_field = "eval_question_id";
my @fields = qw(eval_question_id body modified);
my %blob_fields = ();
my %numeric_fields = ();

my %cache = ();

sub new {
    # Find out what class we are
    my $incoming = shift;
	
    # Call the super-class's constructor and give it all the values
    my $self = $incoming->SUPER::new ( _tablename => $tablename,
				       _fields => \@fields,
				       _blob_fields => \%blob_fields,
				       _numeric_fields => \%numeric_fields,
				       _primary_key_field => $primary_key_field,
				       _cache => \%cache,
				       @_);
    # This is a little crufty, but it should help
    if ($self->field_value('body')) {
	my ($old_grouping) = $self->field_value('body') =~ /group_by\s*=\s*[\"\'](\d+)[\"\']/;
	$self->set_aux_info('old_grouping' => $old_grouping) if $old_grouping;
    }
    return $self;
}

sub split_by_school {
    my $self = shift;
    return 1;
}

# Description: Gets the body
# Input:
# Output: Returns the Body object for this Question
sub body {
    my $self = shift;
    unless ($self->{-body}) {
	$self->{-body} = HSDB45::Eval::Question::Body->new($self);
    }
    return $self->{-body};
}

sub group_by_ids {
    my $self = shift();
    if ($self->aux_info('grouping')) {
	return split(/\D+/, $self->aux_info('grouping'));
    }
    elsif ($self->aux_info('old_grouping')) {
	return $self->aux_info('old_grouping');
    }
    return;
}

sub group_questions {
    my $self = shift();
    
    unless($self->{-group_questions}) {
	$self->{-group_questions} = [];
	foreach my $group_by ($self->group_by_ids()) {
	    push(@{$self->{-group_questions}}, $self->parent_eval()->question($group_by));
	}
    }

    return @{$self->{-group_questions}};
}

# Description: Return the parent eval for this question
# Input:
# Output: The parent Eval object
sub parent_eval {
    my $self = shift;
    return $self->aux_info ('parent_eval');
}


# Description: Given a textual response, determines how to display it to a user
# Input: The text of the response
# Output: The interpreted response
sub interpret_response {
    my $self = shift;
    my $response = shift;
    return $self->body()->interpret_response($response);
}

# Description: Does a sorting by the sort order
# Input: $a and $b are the first and second question objects to compare
# Output: -1, 0, 1
sub sort_order_compare {
    my ($left, $right) = @_;
    my $result;
    return $left->aux_info ('sort_order') <=> $right->aux_info ('sort_order');
}

sub sort_order { 
    my $self = shift; 
    return $self->aux_info('sort_order'); 
}

sub out_edit_url {
    my $self = shift;
    my $class = ref $self || $self;
    my $url = $HSDB4::Constants::EditURLs{$class};
    return unless $url;
    return sprintf("%s/%s/%d/%d", $url, $self->school(), $self->parent_eval()->primary_key(),
		   $self->primary_key());
}

# Description: Returns true if the question is valid
# Input:
# Output: 0 or 1
sub valid_question {
    my $self = shift;
    unless ($self->primary_key) { return }
    unless ($self->aux_info ('parent_eval')) { return }
    unless ($self->isa ('HSDB45::Eval::Question') &&
	    ref $self ne 'HSDB45::Eval::Question') { return }
    return 1;
}

# Description: Determines whether a question is required
# Input:
# Output: 1 if the question is required, 0 otherwise (default)
sub is_required {
    my $self = shift;
    my $req = $self->aux_info('required');
    if ($req && $req eq 'Yes') { return 1; }
    return 0;
}

# gets the label that has been auto-generated by the parent Eval object
sub label {
    my $self = shift;
    my $label = $self->aux_info('label');
}

# sets an auto-generated label... called by the parent Eval object
sub set_label {
    my ($self, $label) = @_;
    $label = $self->set_aux_info('label', $label);
}

# gets the "real label", i.e. the label as it actually lives in the DB
sub get_real_label {
    my ($self) = @_;
    return $self->aux_info('real_label');
}

# sets the "real label", i.e. the label as it actually lives in the DB
sub set_real_label {
    my ($self, $real_label) = @_;
    $self->set_aux_info('real_label', $real_label);
}

sub graphic_stylesheet {
    my $self = shift;
    return $self->aux_info('graphic_stylesheet');
}

#################################################

=item  B<has_been_answered>

    $question->has_been_answered($eval_id);

This sub returns whether a question has been answered.  If an eval_id
is passed, then the function checks if the question has been answered for that 
eval.  If the eval_id is omitted, then it checks to see if this question has
been answered at all. Returns the number of times it has been answered.

=cut

sub has_been_answered {
    my $self = shift;
    my $eval_id = shift;
    my $where_clause = '';
    if (defined($eval_id)){
	$where_clause = " and eval_id = $eval_id ";
    } 
    my $num;
    eval {
	my $dbh = HSDB4::Constants::def_db_handle();
	my $db = HSDB4::Constants::get_school_db( $self->school() );
	my $sth = $dbh->prepare ("SELECT COUNT(*) FROM $db\.eval_response WHERE eval_question_id=? $where_clause");
	$sth->execute( $self->primary_key() );
	($num) = $sth->fetchrow_array();
    };
    if ($@) { confess "Error trying to find if question has been answered: $@" }
    return $num;
}
##################################################

sub other_eval_ids {
    my $self = shift;
    my @eval_ids = ();
    eval {
	my $dbh = HSDB4::Constants::def_db_handle();
	my $db = HSDB4::Constants::get_school_db( $self->school() );
	my $cond = '';
	my $parent_eval;
	if ($self->parent_eval()){
		$parent_eval = $self->parent_eval();
		$cond = "AND parent_eval_id <> ?";
	}

	my $sth = $dbh->prepare(<<EOM);

SELECT parent_eval_id 
FROM $db\.link_eval_eval_question 
WHERE child_eval_question_id= ? 
$cond

EOM
	if ($parent_eval){
		$sth->execute( $self->primary_key(), $parent_eval->primary_key);
	} else {
		$sth->execute( $self->primary_key());
	}
	while (my ($eval_id) = $sth->fetchrow_array()) {
	    push @eval_ids, $eval_id;
	}
    };
    if ($@) { confess "Error trying to find other evals for question: $@" }
    return @eval_ids;
}

sub other_evals_answered {
    my $self = shift;
    my @eval_ids = $self->other_eval_ids();
    return unless @eval_ids;
    eval {
	my $dbh = HSDB4::Constants::def_db_handle();
	my $db = HSDB4::Constants::get_school_db( $self->school() );
	my $idString = join(',',@eval_ids); 
	my $sth = 
	    $dbh->prepare(qq[SELECT eval_id, COUNT(*) 
			     FROM $db\.eval_response
			     WHERE eval_id in ($idString)
			     GROUP BY eval_id]);
	$sth->execute() ;
	@eval_ids = ();
	while (my ($eval_id, $count) = $sth->fetchrow_array()) {
	    if ($count > 0) {
		push @eval_ids, $eval_id;
	    }
	}
    };
    if ($@) { confess "Error trying to find other evals which have been answered: $@" }
    return wantarray ? @eval_ids : scalar(@eval_ids);
}

sub out_text_display {
	my $self = shift;
	my $question_text = $self->body()->question_text();
	$question_text =~ s/<.*?>//g;
	return substr($question_text,0,40).'...';

}

1;
__END__

=head1 AUTHOR

TUSK <tuskdev@tufts.edu>

=head1 BUGS

None Reported.

=head1 SEE ALSO

B<TUSK::Core::SQLRow> - parent class

=head1 COPYRIGHT



=cut

