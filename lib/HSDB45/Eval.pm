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


package HSDB45::Eval;

use strict;
use base qw(HSDB4::SQLRow);
use HSDB45::Eval::Question;
use HSDB45::Eval::Question::Results;
use HSDB45::Eval::Completion;
use HSDB4::SQLLink;
use HSDB45::Course;
use HSDB45::StyleSheet;
use HSDB4::StyleSheetType;
use TUSK::Constants;
use TUSK::Eval::Type;
use TUSK::Enum::Data;
use TUSK::Eval::Association;
use TUSK::Eval::Entry;
use TUSK::Eval::Role;

BEGIN {
    use vars qw($VERSION);

    $VERSION = do { my @r = (q$Revision: 1.70 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
}

sub version {
    return $VERSION;
}

# dependencies for things that relate to caching
my @mod_deps  = ('HSDB45::Eval::Question',
                 'HSDB45::Eval::Question::Results',
                 'HSDB45::Eval::Completion',
                 'HSDB45::Course');

my @file_deps = ();

sub get_mod_deps {
    return @mod_deps;
}

sub get_file_deps {
    return @file_deps;
}


# File-private lexicals
my $tablename = "eval";
my $primary_key_field = "eval_id";
my @fields = qw(eval_id course_id time_period_id teaching_site_id title available_date modified
                due_date prelim_due_date submittable_date question_stylesheet results_stylesheet eval_type_id published);
my %blob_fields = ();
my %numeric_fields = ();

my %cache = ();

# Creation methods

# Description: creates a new HSDB45::Eval object
# Input: _school => school, _id => id
# Output: newly created object
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
                                       @_,
                                       );
    return $self;
}

sub split_by_school {
    my $self = shift;
    return 1;
}

sub admin_group {
    my $self = shift;
    my $group_id = HSDB4::Constants::get_eval_admin_group( $self->school() );
    return HSDB45::UserGroup->new( _school => $self->school(), _id => $group_id );
}

###############################
# Stylesheet lookup functions #
###############################

sub question_stylesheet_type {
    return HSDB4::StyleSheetType->new(_id => HSDB4::StyleSheetType::label_to_id("Eval"));
}

sub question_stylesheet_id {
    my $self = shift;
    return (@_) ? $self->field_value('question_stylesheet', shift) : $self->field_value('question_stylesheet');
}

sub title {
    my $self = shift;
    return $self->field_value('title');
}

sub eval_type {
    my $self = shift;
    my $eval_type_id = $self->field_value('eval_type_id');
    my $eval_type = TUSK::Eval::Type->lookupReturnOne("eval_type_id = $eval_type_id");
    return ($eval_type) ? $eval_type : TUSK::Eval::Type->lookupReturnOne("token = 'course'") ;
}

sub is_teaching_eval {
    my $self = shift;
    my $eval_type = $self->eval_type();
    return (ref $eval_type eq 'TUSK::Eval::Type' && $eval_type->getToken eq 'teaching');
}

sub question_stylesheet_ids {
    my $self = shift();
    return $self->question_stylesheet_type()->stylesheet_ids($self->school());
}

sub question_stylesheet {
    my $self = shift();
    my $stylesheet_id = $self->question_stylesheet_id();

    if($stylesheet_id) {
        return HSDB45::StyleSheet->new(_school => $self->school(), _id => $stylesheet_id);
    }
    else {
        my $stylesheet = $self->question_stylesheet_type()->default_stylesheet($self->school());
        return $stylesheet if($stylesheet->primary_key());
        return undef;
    }
}

sub question_stylesheets {
    my $self = shift();
    return $self->question_stylesheet_type()->stylesheets($self->school());
}

sub global_question_stylesheet {
    my $self = shift();
    return $self->question_stylesheet_type()->global_stylesheet();
}

sub results_stylesheet_type {
    return HSDB4::StyleSheetType->new(_id => HSDB4::StyleSheetType::label_to_id("EvalResults"));
}

sub results_stylesheet_id {
    my $self = shift();
    return @_ ? $self->field_value('results_stylesheet', shift()) : $self->field_value('results_stylesheet');
}

sub results_stylesheet_ids {
    my $self = shift();
    return $self->results_stylesheet_type()->stylesheet_ids($self->school());
}

sub results_stylesheet {
    my $self = shift();
    my $stylesheet_id = $self->results_stylesheet_id();

    if($stylesheet_id) {
        return HSDB45::StyleSheet->new(_school => $self->school(), _id => $stylesheet_id);
    }
    else {
        my $stylesheet = $self->results_stylesheet_type()->default_stylesheet($self->school());
        return $stylesheet if($stylesheet->primary_key());
        return undef;
    }
}

sub results_stylesheets {
    my $self = shift();
    return $self->results_stylesheet_type()->stylesheets($self->school());
}

sub global_results_stylesheet {
    my $self = shift();
    return $self->results_stylesheet_type()->global_stylesheet();
}

sub user_groups {
    #
    # Gets the user groups associated with this ID
    #

    my $self = shift;
    unless ($self->{-user_groups}) {
        my $course = $self->course();
        my @groups = $course->child_user_groups($self->field_value('time_period_id'));
        $self->{-user_groups} = \@groups;
    }
    return @{$self->{-user_groups}};
}



# Description: returns the course object to which the eval belongs
# Input: none
# Output: course object
sub course {
    my $self = shift();
    # Check the cache
    unless ($self->{-course}) {
        $self->{-course} = HSDB45::Course->new (_school => $self->school,
                                                _id => $self->field_value ('course_id'));
    }
    return $self->{-course};
}

# Description: returns the time_period object to which the eval belongs
# Input: none
# Output: course object
sub time_period {
    my $self = shift();
    # Check the cache
    unless ($self->{-time_period}) {
        $self->{-time_period} =
          HSDB45::TimePeriod->new (_school => $self->school,
                                   _id => $self->field_value ('time_period_id'));
    }
    return $self->{-time_period};
}

sub question_link {
    my $self = shift;
    my $db = $self->school_db();
    return $HSDB4::SQLLinkDefinition::LinkDefs{"$db.link_eval_eval_question"};
}

# Description: returns question objects that belong to the eval
# Input: none
# Output: list of question objects
sub questions {
    my ($self) = @_;

    my $auto_increment = 0;
    my $child_items = $self->question_link()->get_children($self->primary_key());

    my @children = $child_items->children();
    for my $q (@children) {
        $q->set_aux_info(parent_eval => $self);

        my $label = $q->label();
        $q->set_real_label($label);

    }

    return $child_items->children();
}

sub binnable_questions {
    my $self = shift;
    my @binnables = ();
    for my $q ($self->questions()) {
        if (HSDB45::Eval::Question::Results::is_type_binnable($q->body()->question_type())) {
            push @binnables, $q;
        }
    }
    return @binnables;
}

# Description: Returns some SPECIFIC questions, as defined for this eval object
# Input: eval_question_id's
# Output: A list of the Eval::Question::Objects (or just the first one, if in scalar context)
sub question {
    my $self = shift;
    my %question_ids = ();
    my @questions = ();
    for (@_) { $question_ids{$_} = 1 }
    # Go through all of the questions
    for ($self->questions ()) {
        if ($question_ids{$_->field_value ('eval_question_id')}) {
            delete $question_ids{$_->field_value ('eval_question_id')};
            push @questions, $_;
            last unless keys %question_ids;
        }
    }
    return unless @questions;
    return wantarray ? @questions : $questions[0];
}

# Description: Makes sure there's no cached items in the question list
# Input:
# Output:
sub reset_question_cache {
    my $self = shift;
    return;
}

# Description: Adds a link to a child question
# Input: DB username/password, the child question ID,
#        and then the link fields in 'field => "value"' format
# Output: Success flag, and a message describing an error
sub add_child_question {
    my $self = shift;
    my ($u, $p, $qid, %fields) = @_;

    my ($r, $msg) = $self->question_link()->insert( -user => $u, -password => $p,
                                                    -child_id => $qid,
                                                    -parent_id => $self->primary_key,
                                                    %fields);
    if ($r) { $self->reset_question_cache() }
    return ($r, $msg);
}

# Description: Delete's a link to a child question
# Input: DB username/password, and the child question ID
# Output:
sub delete_child_question {
    my $self = shift;
    my ($first,$second,$qid) = @_;
    my ($u,$p);
    # handling case where password is not passed to function;
    if (!defined($second) && !defined($qid)){
        ($u,$p) =  ($TUSK::Constants::DatabaseUsers{ContentManager}->{writeusername},$TUSK::Constants::DatabaseUsers{ContentManager}->{writepassword});
        $qid = $first;
    } else {
        ($u,$p) = ($first,$second);
    }

    my ($r, $msg) = $self->question_link()->delete( -user => $u, -password => $p,
                                                    -child_id => $qid,
                                                    -parent_id => $self->primary_key );
    if ($r) {
        # Now, delete all of the QuestionRef's which referred to that one
        for my $refq ( grep { $_->body()->is_reference() } $self->questions() ) {
            next unless $refq->body()->target_question_id() == $qid;
            $self->question_link()->delete( -user => $u, -password => $p,
                                            -child_id => $refq->primary_key(),
                                            -parent_id => $self->primary_key() );
        }
        $self->reset_question_cache();
    }
    return ($r, $msg);
}

# Description: Updates a link to a child question
# Input: DB username/password, the child question ID, and the link fields in 'field => "value"' format
# Output:
sub update_child_question_link {
    my $self = shift;
    my ($u, $p, $qid, %fields) = @_;

    my ($r, $msg) = $self->question_link()->update( -user => $u, -password => $p,
                                                    -child_id => $qid,
                                                    -parent_id => $self->primary_key,
                                                    %fields);
    if ($r) { $self->reset_question_cache() }
    return ($r, $msg);
}

sub available_date {
    #
    # Return a date object which is the available date
    #

    my $self = shift;
    unless ($self->{-available_date}) {
        return unless $self->field_value ('available_date') =~ /[1-9]+/;
        my $dt = HSDB4::DateTime->new ();
        $dt->in_mysql_date ($self->field_value ('available_date'));
        $self->{-available_date} = $dt;
    }
    return $self->{-available_date};
}

sub due_date {
    #
    # Return a date object which is the due date
    #

    my $self = shift;
    unless ($self->{-due_date}) {
        return unless $self->field_value ('due_date') =~ /[1-9]+/;
        my $dt = HSDB4::DateTime->new ();
        $dt->in_mysql_date ($self->field_value ('due_date'));
        $self->{-due_date} = $dt;
    }
    return $self->{-due_date};
}


sub prelim_due_date {
    #
    # Return a date object which is the prelim due date
    #

    my $self = shift;
    unless ($self->{-prelim_due_date}) {
        return unless $self->field_value ('prelim_due_date') =~ /[1-9]+/;
        my $dt = HSDB4::DateTime->new ();
        $dt->in_mysql_date ($self->field_value ('prelim_due_date'));
        $self->{-prelim_due_date} = $dt;
    }
    return $self->{-prelim_due_date};
}

sub student_short_due_date {
    #
    # Return (Month, date) that student needs to submit by
    #
    my $self = shift;
    return ($self->prelim_due_date) ? $self->prelim_due_date->out_string_date_short_short : $self->due_date->out_string_date_short_short;
}

sub student_due_date {
    #
    # Return a date that student needs to submit by
    #
    my $self = shift;
    return ($self->prelim_due_date) ? $self->prelim_due_date()->out_string_date() : $self->due_date()->out_string_date();
}

sub academic_year {
    my $self = shift();
    return 1998 unless($self->due_date);
    my @gmtime = gmtime($self->due_date->out_unix_time());
    my $month = $gmtime[4];
    my $year  = $gmtime[5] + 1900;
    return ($month >= 7) ? $year : $year-1;
}

sub is_overdue {
    my $self = shift;
    my $now = HSDB4::DateTime->new;
    return 0 unless($self->due_date);
    # If it's overdue, return 1
    if ($now->out_unix_time > ($self->due_date->out_unix_time + 86400)) {
        return 1;
    }
    return 0;
}

sub is_notyetavailable {
    my $self = shift;
    my $now = HSDB4::DateTime->new;

    return 1 unless ($self->available_date());
    # If it's not yet available, return 1
    if ($now->out_unix_time < $self->available_date->out_unix_time) {
        return 1;
    }
    return 0;
}

sub get_submittable_date {
    my $self = shift();
    return $self->field_value('submittable_date');
}

sub set_submittable_date {
    my $self = shift();
    my $submittable_date = shift() or die "expected a date";
    $self->field_value('submittable_date', $submittable_date);
}

sub is_submittable {
    my $self = shift();

    return ( HSDB4::DateTime->new()->out_mysql_date() ge $self->get_submittable_date() );
}

sub is_available {
    #
    # Say whether an eval is available (by its date)
    #

    my $self = shift;

    return (1, '');
}

sub is_user_allowed {
    #
    # Say whether a user object is permitted to get to the eval
    #

    my $self = shift;
    # Read in the user
    my $user = shift;

    my $username = ref $user ? $user->primary_key : $user;

    # Start with date issues

    # If there's no available date, or if it's too early, return 0
    if (not $self->available_date or $self->is_notyetavailable) {
        return (0, sprintf ("Form is not available until %s",
                            $self->available_date->out_string_date));
    }

    # Check if something is overdue
    if ($self->due_date and $self->is_overdue) {
        return (0, sprintf ("Form is no longer available (due %s)",
                            $self->due_date->out_string_date));
    }

    if (not $self->course()->is_user_registered($username,
                                                $self->field_value ('time_period_id'))) {
        return (0, sprintf("User %s is not registered for course %s during %s.",
                           $username, $self->course()->out_label(),
                           $self->time_period()->out_label()));
    }

    # Check for the user having already completed the form
    my $comp = HSDB45::Eval::Completion->new( _school => $self->school() );
    $comp->lookup_key ($username, $self->primary_key);
    if ($comp->primary_key && $comp->field_value('status') eq 'Done') {
        return (0, sprintf ("User %s has already completed evaluation.",
                            $username));
    }

    # So it's all OK
    return (1, '');
}

sub users {
    my $self = shift;

    unless ($self->{-users}) {     # Cache...
        $self->{-users} = [ sort { $a cmp $b } $self->link_enrolled_users() ];
    }
    return @{$self->{-users}};
}

sub group_enrolled_users {
    my $self = shift;
    my @users = ();
    # take user groups, then get the users in them
    if ($self->course()->associate_user_group()) {
        my @groups =
            $self->course()->child_user_groups($self->field_value('time_period_id'));
        foreach (@groups) {
            push @users,
            grep { ! $self->admin_group()->contains_user($_) } $_->child_users();
        }
    }
    return @users;
}

sub link_enrolled_users {
    my $self = shift;

    my @user_ids = ();
    my $dbh = HSDB4::Constants::def_db_handle();
    my $db = $self->school_db();
    my $sql = qq[SELECT child_user_id
                 FROM $db.link_course_student
                 WHERE parent_course_id=?
                 AND time_period_id=?];

    if ($self->field_value('teaching_site_id') && $self->field_value('teaching_site_id') ne '') {
        $sql .= " AND ( teaching_site_id IS NULL OR  teaching_site_id = " . $self->field_value('teaching_site_id') . " )";
    }

    eval {
        my $sth = $dbh->prepare($sql);
        $sth->execute($self->field_value('course_id'),
                      $self->field_value ('time_period_id'));
        while (my ($user_id) = $sth->fetchrow_array) { push @user_ids, $user_id }
     $sth->finish;
    };

    my @users = ();
    for my $user_id (@user_ids) {
        next if $self->admin_group()->contains_user($user_id);
        push @users, HSDB4::SQLRow::User->new->lookup_key($user_id);
    }

    return @users;
}

sub num_users {
    my $self = shift;
    return scalar($self->users());
}

sub eval_completions {
    #
    # Get the completion objects associated with the eval
    #

    my $self = shift;

    # Form the conditions
    my @conds = ('eval_id = ' . $self->primary_key(), @_, 'ORDER BY created DESC');
    # Return the results of the lookup
    my $blankcomp = HSDB45::Eval::Completion->new( _school => $self->school() );
    return $blankcomp->lookup_conditions(@conds);
}

sub is_editable {
    my $self = shift;
    if ($self->eval_completions()) { return 0 }
    my $db = $self->school_db();
    my $count = 0;
    eval {
        my $dbh = HSDB4::Constants::def_db_handle();
        my $sth = $dbh->prepare(qq[SELECT COUNT(*) FROM $db.eval_response WHERE eval_id = ?]);
        $sth->execute($self->primary_key());
        ($count) = $sth->fetchrow_array();
        $sth->finish;
    };
    if ($@) {
        warn sprintf("Could not find the number of responses for eval_id = %d", $self->primary_key());
    }
    return !$count;
}

sub divide_users {
    #
    # Divide the users into those who have completed and those who haven't
    #

    my $self = shift;
    # Check for cached results
    unless ($self->{-complete_users} && $self->{-incomplete_users}) {
        # Make a hash of the users who have completed the eval
        my %comp_hash = ();
        my ($complete_hash,$incomplete_hash) = ({},{});
        foreach my $eval_obj ($self->eval_completions()) {
            $comp_hash{$eval_obj->field_value ('user_id')} = 1;
        }
        # Make the list to store the answers
        my @complete = ();
        my @incomplete = ();
        # Now for each user
        foreach my $user_obj ($self->users) {
            # If the user's ID is in the comp_hash, put it on completes...
            if ($comp_hash{$user_obj->primary_key}) {
                push @complete, $user_obj ;
                $complete_hash->{$user_obj->primary_key} = $user_obj;
            }
            # Otherwise, put it on incompletes
            else {
                push @incomplete, $user_obj;
                $incomplete_hash->{$user_obj->primary_key} = $user_obj;
            }
        }

        # Now, store the results in the cache
        $self->{-complete_users} = \@complete;
        $self->{-incomplete_users} = \@incomplete;
        $self->{-complete_users_hash} = $complete_hash;
        $self->{-incomplete_users_hash} = $incomplete_hash;

    }
    return;
}

sub complete_users {
    #
    # Get the set of complete users
    #

    my $self = shift;
    # Do the division unless the cache has the results
    $self->divide_users() unless $self->{-complete_users};
    # Return the cached result
    return @{$self->{-complete_users}};
}

sub incomplete_users {
    #
    # Get the set of incomplete users
    #

    my $self = shift;
    # Do the division unless the cache has the results
    $self->divide_users() unless $self->{-incomplete_users};
    # Return the cached result
    return @{$self->{-incomplete_users}};
}

sub save {
        my $self = shift;
        return $self->SUPER::save ($TUSK::Constants::DatabaseUsers{ContentManager}->{writeusername},$TUSK::Constants::DatabaseUsers{ContentManager}->{writepassword});
}

sub is_user_complete {
        my $self = shift;
        my $user = shift;
        die "User not passed to is_user_complete " if (!defined($user));
        die "User is not HSDB4::SQLRow::User" if (ref($user) ne 'HSDB4::SQLRow::User');
        my $cond = sprintf(" user_id = '%s' ", $user->user_id());

        # only expect one row for one eval and one user
        my ($comp) = $self->eval_completions($cond);
        return 0 if (!defined($comp));
        return 1 if (defined($comp->primary_key()));
        return undef;

}

sub validate_form {
    #
    # Read in a hash of key => value pairs and return the required fields
    # that aren't filled in
    #

    my $self = shift;
    my $fdat = shift;
    # Make a place to put the id's of problems
    my @problems = ();
    # Now go through the list of required questions...
    foreach my $q_id ($self->required_questions) {
        # ...and push the problem ID's onto the list
        push @problems, $q_id unless $fdat->{"eval_q_$q_id"};
    }
    # And return the whole list
    return @problems;
}


sub answer_form {
    #
    # Actually fill in all the user's answers
    #

    my ($self, $user, $fdat) = @_;

    my $is_teaching_eval = $self->is_teaching_eval();

    # Make the user code
    my $user_code = $user->out_user_code($fdat->{submit_password});
    my $evaluator_code = ($is_teaching_eval) ? $user_code . '-' . $fdat->{evaluatee_id}  : $user_code;

    my ($result, $msg) = (0, '');
    eval {
        # Go through the list of keys
        foreach my $key (keys %{$fdat}) {
            next unless my ($q_id) = $key =~ /eval_q_(\d+)/;
            $fdat->{$key} = join("\t" , @{$fdat->{$key}}) if (ref($fdat->{$key}) eq 'ARRAY');
            my $resp = HSDB45::Eval::Question::Response->new ( _school => $self->school() );
            $resp->primary_key($evaluator_code, $self->primary_key(), $q_id);
            $resp->field_value('response', $fdat->{$key});
            my ($r, $msg) = $resp->save;
            die "Could not save $q_id ($r) [$fdat->{$key}]: $msg" unless $r;
        }

        if ($is_teaching_eval) {
            my $entry = TUSK::Eval::Entry->new();
            $entry->setFieldValues({
                school_id => $self->school_id(),
                eval_id => $self->primary_key(),
                evaluator_code => $evaluator_code,
                evaluatee_id => $fdat->{evaluatee_id},
                teaching_site_id => $fdat->{site_id},
            });
            $entry->save({user => $user_code});
            $self->set_teaching_eval_entry_status($user, $fdat->{evaluatee_id}, 'completed');
        } else {
            # We complete by default course evals
            $self->completion_token($user);
          }

        # Phew! We got there.
        $result = 1;
    };
    die $@ if $@;
    return ($result, '');
}

sub completion_token {
    my ($self, $user) = @_;

    my $comp = HSDB45::Eval::Completion->new ( _school => $self->school() );
    $comp->primary_key ($user->primary_key, $self->primary_key);
    $comp->field_value ('status' => 'Done');
    my ($r, $msg) = $comp->save;
    die "Could not save the completion token: $msg" unless $r;
}

sub set_teaching_eval_entry_status {
    my ($self, $evaluator, $evaluatee_id, $entry_status) = @_;

    if (my $link = TUSK::Eval::Association->lookupReturnOne("school_id = " . $self->school_id() . " AND eval_id = " . $self->primary_key() . " AND evaluator_id = '" . $evaluator->primary_key() . "' and evaluatee_id = '$evaluatee_id'")) {
        if (my $status_enum = TUSK::Enum::Data->lookupReturnOne("namespace = 'eval_association.status' AND short_name = '$entry_status'")) {
            $link->setStatusEnumID($status_enum->getPrimaryKeyID());
            $link->setStatusDate(HSDB4::DateTime->new()->out_mysql_timestamp());
            $link->save({user => $evaluator->primary_key()});
        }
    }
}

sub is_user_teaching_eval_role_enabled {
    my ($self, $evaluator, $role_id) = @_;

    my $completions = $self->get_teaching_eval_completions_by_roles($evaluator);
    foreach (@$completions) {
        return ($_->{completed_evals} < $_->{maximum_evals}) if ($_->{role_id} == $role_id);
    }

    return 0;
}

sub is_user_teaching_eval_complete {
    my ($self, $evaluator) = @_;

    my $completions = $self->get_teaching_eval_completions_by_roles($evaluator);
    foreach (@$completions) {
        return 0 if ($_->{completed_evals} < $_->{required_evals});
    }

    return 1;
}

sub get_teaching_eval_completions_by_roles {
    my ($self, $evaluator) = @_;

    unless (defined $self->{teaching_eval_completions_by_role}) {
        my $course = $self->course();
        my $time_period_id = $self->field_value('time_period_id');
        my $student_site = $course->get_student_site($evaluator->primary_key(), $time_period_id);

        my $student_site_id = $student_site->primary_key() || 0;
        my $evaluator_id = $evaluator->primary_key() || 0;
        my $eval_id = $self->primary_key() || 0;
        my $school_id = $self->school_id() || 0;

        my $db = $self->school_db();
        my $sql = qq(
            SELECT ur.role_id, COUNT(DISTINCT cs.user_id), COUNT(DISTINCT cs.user_id, ea.status_enum_id)
            FROM $db.eval e
            INNER JOIN tusk.course_user cs ON (e.course_id = cs.course_id AND e.time_period_id = cs.time_period_id)
            INNER JOIN tusk.course_user_site us ON (cs.course_user_id = us.course_user_id AND us.teaching_site_id = ?)
            INNER JOIN tusk.permission_user_role ur ON (cs.user_id = ur.user_id and cs.course_user_id = ur.feature_id)
            LEFT JOIN tusk.eval_association ea ON (e.eval_id = ea.eval_id AND cs.school_id = ea.school_id AND cs.user_id = ea.evaluatee_id AND ea.evaluator_id = ? AND ea.status_enum_id =
            (SELECT ed.enum_data_id FROM tusk.enum_data ed WHERE ed.namespace = 'eval_association.status' AND ed.short_name = 'completed'))
            WHERE e.eval_id = ? AND cs.school_id = ?
            GROUP BY ur.role_id
        );

        my $dbh = HSDB4::Constants::def_db_handle();
        my $sth = $dbh->prepare($sql);
        $sth->execute($student_site_id, $evaluator_id, $eval_id, $school_id);

        my %completions = ();
        while (my ($role_id, $total, $completed) = $sth->fetchrow_array()) {
            $completions{$role_id} = { total_evals => $total, completed_evals => $completed };
        }

        my @completions_by_role = ();
        foreach my $eval_role (@{TUSK::Eval::Role->lookup('eval_id = ' . $self->primary_key() . ' and school_id = ' . $self->school_id(), ['sort_order'], undef, undef, [ TUSK::Core::JoinObject->new('TUSK::Permission::Role', { joinkey => 'role_id', jointype => 'inner'})],)}) {
            my $role_id = $eval_role->getRoleID();
            my $total_evals = $completions{$role_id}{total_evals} || 0;
            my $completed_evals = $completions{$role_id}{completed_evals} || 0;
            my $required_evals = $eval_role->getRequiredEvals() || 0;
            my $maximum_evals = $eval_role->getMaximumEvals() || 255;
            $maximum_evals = $total_evals if ($maximum_evals > $total_evals);
            $required_evals = $maximum_evals if ($required_evals > $maximum_evals);
            push @completions_by_role, {
                role_id    => $role_id,
                role_label => $eval_role->getJoinObject('TUSK::Permission::Role')->getRoleDesc(),
                total_evals => $total_evals,
                completed_evals => $completed_evals,
                required_evals => $required_evals,
                maximum_evals => $maximum_evals,
                sort_order => $eval_role->getSortOrder(),
            };
        }

        $self->{teaching_eval_completions} = \@completions_by_role;
    }

    return $self->{teaching_eval_completions};
}

sub get_teaching_eval_completions_by_evaluators {
    my $self = shift;

    unless (defined $self->{teaching_eval_completions_by_evaluator}) {
        my $db = $self->school_db();
        my $sql = qq(
            SELECT evaluator_id, er.role_id, COUNT(DISTINCT cs.user_id)
            FROM tusk.eval_association ea
            INNER JOIN $db.eval e ON (ea.eval_id = e.eval_id)
            INNER JOIN tusk.enum_data ed ON (ea.status_enum_id = enum_data_id AND ed.namespace = 'eval_association.status' AND ed.short_name = 'completed')
            INNER JOIN tusk.course_user cs ON (cs.user_id = ea.evaluatee_id AND cs.course_id = e.course_id AND cs.time_period_id = e.time_period_id AND cs.school_id = ea.school_id)
            INNER JOIN tusk.permission_user_role ur ON (ur.user_id = cs.user_id AND ur.feature_id = cs.course_user_id)
            INNER JOIN tusk.permission_role r ON (r.role_id = ur.role_id)
            INNER JOIN tusk.eval_role er ON (er.role_id = ur.role_id AND er.eval_id = ea.eval_id AND er.school_id = ea.school_id)
            WHERE er.eval_id = ? AND er.school_id = ?
            GROUP BY evaluator_id, er.role_id;
        );
        my $dbh = HSDB4::Constants::def_db_handle();
        my $sth = $dbh->prepare($sql);
        $sth->execute($self->primary_key(), $self->school_id());

        my %completions = ();
        while (my ($evaluator_id, $role_id, $completions) = $sth->fetchrow_array()) {
            $completions{$evaluator_id}{$role_id} = $completions;
            $completions{$evaluator_id}{total} += $completions;
        }
        $self->{teaching_eval_completions_by_evaluator} = \%completions;

    }

    return $self->{teaching_eval_completions_by_evaluator};
}

sub is_site_director {
    my $self = shift;
    my $user_id = shift;
    my $teaching_site_id = shift;

    return 0 unless ($self->is_published());

    my $time_period_id = $self->field_value('time_period_id');
    my $course = $self->course();
    my $conds = "role_token = 'site_director' AND course_user.user_id = '$user_id'";
    $conds .= " AND course_user_site.teaching_site_id = $teaching_site_id" if ($teaching_site_id);
    my $users = $course->users($time_period_id, $conds);

    return scalar(@$users);
}

sub is_published {
    my $self = shift;

    return $self->field_value('published');
}

sub set_published {
    my $self = shift;

    $self->field_value('published', 1);
}

sub required_questions {
    #
    # Return the list of questions which are required
    #

    my $self = shift;
    return ( map { $_->primary_key }
             grep { $_->is_required }
             $self->questions );
}


sub out_html_row {
    #
    # A four-column HTML row
    #

    my $self = shift;
    my $outval = "<td>" . $self->out_html_label . "</td>";
    $outval .= "<td>" . $self->course->out_html_label . "</td>";
    $outval .= "<td>";
    $outval .= $self->available_date->out_string_date_short
      if $self->available_date;
    $outval .= "</td>";
    $outval .= "<td><b>Due: </b>";
    $outval .= $self->due_date->out_string_date_short
      if $self->due_date;
    $outval .= "</td>";
    return "<tr>$outval</tr>";
}

sub out_label {
    #
    # A label for the object: its title
    #

    my $self = shift;
    return $self->field_value('title');
}


sub out_abbrev {
    #
    # An abbreviation for the object: the first twenty characters of its
    # title
    #

    my $self = shift;
    return $self->field_value ('title');
}


# spreads out the sort_order values of questions to have a padding of ten
sub reapportion_orderings {
    my ($self, $user, $password) = @_;

    my $sort_order = 0;
    foreach my $question ($self->questions()) {
        $sort_order += 10;
        $self->update_child_question_link($user, $password,
                                          $question->primary_key(),
                                          ('sort_order', $sort_order));
    }
}

# returns the ID of the question that precedes the question with ID
# $qid within the context of this eval...  since caching of questions
# does not yet occur, this is a painfully inefficient operation, but
# it doesn't happen much so getting too uppity and writing raw SQL
# would probably be premature optimization, the root of all evil
sub get_preceding_qid {
    my ($self, $qid) = @_;

    my $last_qid = 0;
    foreach my $question ($self->questions()) {
        return $last_qid if $question->primary_key() == $qid;
        $last_qid = $question->primary_key();
    }

    die "did not find question (ID=$qid)";
}

sub automate_all_labels {
    my ($self) = shift;

    my ($username,$password) = ($TUSK::Constants::DatabaseUsers{ContentManager}->{writeusername},$TUSK::Constants::DatabaseUsers{ContentManager}->{writepassword});
    my $type;
    foreach my $q ($self->questions()) {
        $type = $q->body()->question_type();
        if (($type ne 'Title' )
               && ($type ne 'TeachingSite')
               && ($type ne 'Instruction')){
           $self->update_child_question_link($username,$password,$q->primary_key(),
                'label'=>'auto' );
        }
    }
}

sub count_users {
    my $self = shift;
    my $count = 0;
    my $db = $self->school_db();
    my $sth;

    eval {
        my $dbh = HSDB4::Constants::def_db_handle();
        my $admin_group_id = HSDB4::Constants::get_eval_admin_group($self->school());
        $sth = $dbh->prepare(qq(
                SELECT count(child_user_id)
                FROM $db.link_course_student a, $db.eval b
                WHERE parent_course_id = course_id
                and a.time_period_id = b.time_period_id
                and eval_id = ?
                and (a.teaching_site_id = b.teaching_site_id or b.teaching_site_id is null or b.teaching_site_id = 0)
                AND child_user_id not in
                    (select child_user_id
                    from $db.link_user_group_user
                    where parent_user_group_id = $admin_group_id)
            ));
        $sth->execute($self->primary_key());

        $count = $sth->fetchrow_array();
        $sth->finish();
    };

    if ($@) {
        warn sprintf("Could not find the number of all users for eval_id=%d", $self->primary_key());
    }

    return $count;
}


sub count_complete_users {
    my $self = shift;
    my $count = 0;
    my $db = $self->school_db();

    eval {
        my $admin_group_id = HSDB4::Constants::get_eval_admin_group($self->school());
        my $dbh = HSDB4::Constants::def_db_handle();
        my $sth = $dbh->prepare(qq(
                                select count(*)
                                from $db.eval_completion
                                where eval_id = ?
                                AND user_id not in
                                        (select child_user_id
                                        from $db.link_user_group_user
                                        where parent_user_group_id = $admin_group_id)
                                ));

        $sth->execute($self->primary_key());
        $count = $sth->fetchrow_array();
        $sth->finish();
    };

    if ($@) {
        warn sprintf("Could not find the number of complete users for eval_id=%d",
                     $self->primary_key());
    }

    return $count;
}


1;
__END__
