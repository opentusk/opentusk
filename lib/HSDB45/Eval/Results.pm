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

$VERSION = do { my @r = (q$Revision: 1.12 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
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
    my $class = shift;
    $class = ref($class) || $class;
    bless($self, $class);
    return $self->init(@_);
}

# Description: performs private object initialization
# Input: HSDB45::Eval object
# Output: initialzed object
sub init {
    my $self = shift;
    $self->{'-eval'} = shift;
    $self->{'-evaluatee_id'} = shift;
    $self->{'-teaching_site_id'} = shift;
    return $self;
}

sub school {
    my $self = shift;
    return $self->parent_eval()->school();
}

# Description: Returns the associated eval object
# Input: none
# Output: associated eval object
sub parent_eval {
    my $self = shift;
    return $self->{'-eval'};
}

sub evaluatee_id {
    my $self = shift;
    return $self->{'-evaluatee_id'};
}

sub teaching_site_id {
    my $self = shift;
    return $self->{'-teaching_site_id'};
}

# Description: Returns the results for the eval's questions
# Input: Optionally, some
# Output: List of HSDB45::Eval::Question::Results objects
sub question_results {
    my $self = shift;

    # If there are no question_results, then make all the objects, and put them in the
    # hash
    unless ($self->{-question_results}) {
        $self->{-question_results} = {};
        for my $q ($self->parent_eval()->questions()) {
            my $qr = HSDB45::Eval::Question::Results->new($q, $self);
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
        my $db = HSDB4::Constants::get_school_db($self->school());
        my $num = undef;
        eval {
            my $sth = $dbh->prepare("SELECT COUNT(*) FROM $db.eval_completion WHERE eval_id = ? GROUP BY eval_id");
            $sth->execute($self->parent_eval()->primary_key());
            ($num) = $sth->fetchrow_array();
        };
        warn "Error trying to get total completions: $@" if ($@);
        $self->{-total_completions} = $num;
    }

    return $self->{-total_completions};
}

sub user_codes {
    my $self = shift;

    unless($self->{-user_codes}) {
        my %user_codes;
        my $eval_id = $self->parent_eval()->primary_key();

        if ($self->parent_eval()->is_teaching_eval()) {
            my $evaluatee_id = $self->evaluatee_id();
            my $teaching_site_id = $self->teaching_site_id();
            my $dbh = HSDB4::Constants::def_db_handle();
            my $op1 = ($evaluatee_id) ? '=' : '<>';
            my $op2 = ($teaching_site_id) ? '=' : '<>';
            my $sql = qq(
                SELECT DISTINCT evaluator_code
                FROM tusk.eval_entry
                WHERE eval_id = ? AND evaluatee_id $op1 ? AND teaching_site_id $op2 ?
            );
            eval {
                my $sth = $dbh->prepare($sql);
                $sth->execute($eval_id, $evaluatee_id, $teaching_site_id);
                while ((my $code) = $sth->fetchrow_array()) {
                    $user_codes{$code}++;
                }
            };
            warn "Error trying to get user codes: $@" if ($@);
        } else {
            my $blank_resp = HSDB45::Eval::Question::Response->new(_school => $self->parent_eval()->school());
            my @conds = ("eval_id = $eval_id");
            my @resps = $blank_resp->lookup_conditions(@conds);
            foreach my $resp (@resps) {
                $user_codes{$resp->user_code()}++;
            }
        }

        $self->{-user_codes} = [keys(%user_codes)];
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
        my $sth = $dbh->prepare("SELECT MAX(created) FROM $db.eval_completion WHERE eval_id = ?");
        $sth->execute($self->parent_eval()->primary_key());
        ($date) = $sth->fetchrow_array();
    };
    return unless $date;
    return HSDB4::DateTime->new()->in_mysql_timestamp($date);
}


1;
__END__
