package HSDB45::Eval::Results;

=head1 NAME

B<HSDB45::Eval::Results> 

=head1 DESCRIPTION

Used to represent a set of results for a users responses to an eval

=over 4

=cut

use strict;

use HSDB4::Constants qw(:school);
use HSDB45::Eval::Question::Results;
use vars qw($VERSION);

$VERSION = do { my @r = (q$Revision: 1.11 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
sub version { return $VERSION; }

my @mod_deps  = ('HSDB45::Eval::Question::Results');
my @file_deps = ();

sub get_mod_deps {
    return @mod_deps;
}

sub get_file_deps {
    return @file_deps;
}

# Description: creates a new HSDB45::Eval::Results object
# Input: HSDB45::Eval object
# Output: newly created object
sub new {
    my $self = {};
    my $class = shift();
    $class = ref($class) || $class;
    bless($self, $class);
    return $self->init(@_);
}

# Description: performs private object initialization
# Input: HSDB45::Eval object
# Output: initialzed object
sub init {
    my $self = shift();
    $self->{'-eval'} = shift();
    return $self;
}

sub school {
    my $self = shift;
    return $self->parent_eval()->school ();
}

# Description: Returns the associated eval object
# Input: none
# Output: associated eval object
sub parent_eval {
    my $self = shift();
    return $self->{'-eval'};
}

# Description: Returns the results for the eval's questions
# Input: Optionally, some 
# Output: List of HSDB45::Eval::Question::Results objects
sub question_results {
    my $self = shift();

    # If there are no question_results, then make all the objects, and put them in the 
    # hash
    unless ($self->{-question_results}) {
	$self->{-question_results} = {};
	for my $q ($self->parent_eval ()->questions ()) { 
	    my $qr = HSDB45::Eval::Question::Results->new ($q, $self);
	    $self->{-question_results}{$q->primary_key} = $qr;
	}
    }

    # If there are arguments, use them as question_ids to return
    if (@_) {
	my @results = ();
	for my $qid (@_) {
	    push @results, $self->{-question_results}{$qid} if ($self->{-question_results}{$qid});
	}
	return @results;
    }

    # If there are no arguments, then just return them all (sorted, of course)
    return sort { $a->question()->aux_info('sort_order') <=> $b->question()->aux_info('sort_order') } values %{$self->{-question_results}};
}

#######################################################

=item B<total_completions>

   $num = $obj->total_completions();

Returns the number of distinct user_codes for the eval.  This 
is essentially the count of the number of people who have 
submitted a particular eval. This is different from total_user_codes
in that this counts users who have submitted an eval, but have not answered
any of the questions.

=cut

sub total_completions {
    my $self = shift;
    unless ($self->{-total_completions}) {
	my $dbh = HSDB4::Constants::def_db_handle();
	my $db = HSDB4::Constants::get_school_db( $self->school );
	my $num = undef;
	eval {
	    my $sth = $dbh->prepare ("SELECT COUNT(*) FROM $db\.eval_completion WHERE eval_id=? GROUP BY eval_id");
	    $sth->execute( $self->parent_eval()->primary_key() );
	    ($num) = $sth->fetchrow_array();
	};
	if ($@) { warn "Error trying to get total completions: $@" }
	$self->{-total_completions} = $num;
    }
    return $self->{-total_completions};
}

sub user_codes {
    my $self = shift();

    unless($self->{-user_codes}) {
	my %user_code_hash;
	my $blank_resp = HSDB45::Eval::Question::Response->new(_school => $self->parent_eval()->school());
	my @resps = $blank_resp->lookup_conditions('eval_id=' . $self->parent_eval()->primary_key());
	foreach my $resp (@resps) { $user_code_hash{$resp->user_code()}++ }
	$self->{-user_codes} = [keys(%user_code_hash)];
    }

    return @{$self->{-user_codes}};
}


#######################################################

=item B<total_user_codes>

   $num = $obj->total_user_codes();

Returns the number of distinct user_codes for the eval.  This 
is essentially the count of the number of people who have 
answered a question on a particular eval.

=cut

sub total_user_codes {
    my $self = shift;
    return scalar($self->user_codes());
}

# Description: Returns the time of the last completion
# Input: 
# Output: Returns a HSDB4::DateTime of the relevant time
sub last_completion_timestamp {
    my $self = shift;
    my $dbh = HSDB4::Constants::def_db_handle();
    my $db = get_school_db($self->parent_eval()->school);
    my $date;
    eval {
	my $sth = $dbh->prepare("SELECT MAX(created) FROM $db\.eval_completion WHERE eval_id=?");
	$sth->execute($self->parent_eval()->primary_key());
	($date) = $sth->fetchrow_array();
    };
    return unless $date;
    return HSDB4::DateTime->new()->in_mysql_timestamp($date);
}


1;
__END__
