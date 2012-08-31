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


package HSDB45::Survey;

use strict;
use base qw(HSDB4::SQLRow);
use HSDB45::Eval::Question;
use HSDB4::SQLLink;
use HSDB45::Survey::Response;
use HSDB4::DateTime;

BEGIN {
    use vars qw($VERSION);    
    $VERSION = do { my @r = (q$Revision: 1.6 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
}

sub version { return $VERSION; }

# dependencies for things that relate to caching
my @mod_deps  = ('HSDB45::Eval::Question',
		 'HSDB45::Survey::Response');
my @file_deps = ();

sub get_mod_deps {
    return @mod_deps;
}

sub get_file_deps {
    return @file_deps;
}


# File-private lexicals
my $tablename = "survey";
my $primary_key_field = "survey_id";
my @fields = qw(survey_id title start_date stop_date user_groups modified);
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

sub user_groups {
    #
    # Gets the user groups associated with this ID
    #

    my $self = shift;
    unless ($self->{-user_groups}) {
	if ($self->field_value('user_groups')) {
	    my @group_ids = split(/\D+/, $self->field_value('user_groups'));
	    my @groups = map { 
	      HSDB45::UserGroup->new(_school => $self->school(), _id => $_) 
	      } @group_ids;
	    $self->{-user_groups} = \@groups;
	    return @groups;
	}
	else {
	    return;
	}
    }
    return @{$self->{-user_groups}};
}


sub question_link {
    my $self = shift;
    my $db = $self->school_db();
    return $HSDB4::SQLLinkDefinition::LinkDefs{"$db\.link_survey_eval_question"};
}

# Description: returns question objects that belong to the eval
# Input: none
# Output: list of question objects
sub questions {
    my $self = shift();
    my $child_items = $self->question_link()->get_children( $self->primary_key() );
    for my $q ($child_items->children()) {
	$q->set_aux_info(parent_eval => $self);
    }
    return $child_items->children ();
}

sub binnable_questions {
    my $self = shift;
    return grep { HSDB45::Eval::Question::Results::is_type_binnable($_->body()->question_type()) }
	$self->questions();
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
    my ($u, $p, $qid) = @_;

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

sub start_date {
    #
    # Return a date object which is the available date
    #

    my $self = shift;
    unless ($self->{-start_date}) {
	return unless $self->field_value ('start_date') =~ /[1-9]+/;
	my $dt = HSDB4::DateTime->new ();
	$dt->in_mysql_date ($self->field_value ('start_date'));
	$self->{-start_date} = $dt;
    }
    return $self->{-start_date};
}

sub stop_date {
    #
    # Return a date object which is the due date
    #
    
    my $self = shift;
    unless ($self->{-stop_date}) {
	return unless $self->field_value ('stop_date') =~ /[1-9]+/;
	my $dt = HSDB4::DateTime->new ();
	$dt->in_mysql_date ($self->field_value ('stop_date'));
	$self->{-stop_date} = $dt;
    }
    return $self->{-stop_date};
}

sub is_notyetavailable {
    my $self = shift;
    my $now = HSDB4::DateTime->new;

    # If it's not yet available, return 1
    if (not $self->start_date) {
	return 1;
    }
    elsif ($now->out_unix_time < $self->start_date->out_unix_time) {
	return 1;
    }
    return 0;
}

sub is_pastavailable {
    my $self = shift;
    my $now = HSDB4::DateTime->new;

    # If it's not yet available, return 1
    if (not $self->stop_date()) {
	return 1;
    }
    elsif ($now->out_unix_time > $self->stop_date->out_unix_time) {
	return 1;
    }
    return 0;
}

sub is_user_allowed {
    #
    # Say whether a user object is permitted to get to the eval
    #

    my $self = shift;
    # Read in the user
    my $user = shift;

    my $username = ref $user ? $user->primary_key : $user;

    # If there's a username, and it's in the admin group, then just go
    if ($username) {
	if ($self->admin_group()->contains_user($username)) { return (1, '') }
    }


    # Otherwise, Start with date issues
    # If if it's too early or too late, return 0
    if ($self->is_notyetavailable) {
	return (0, sprintf ("Survey is not available until %s",
			    $self->start_date->out_string_date));
    }
    if ($self->is_pastavailable) {
	return (0, sprintf ("Survey is no longer available (stopped %s)",
			    $self->stop_date->out_string_date));
    }

    # Now, let's check for user groups. 
    my @groups = $self->user_groups();
    if (@groups) {
	# If there are defined user groups, then one must be logged in
	if (not $username) {
	    return (0, "Must be logged in to submit this eval.");
	}
	my $allowed = 0;
	for my $group (@groups) {
	    if ($group->contains_user ($username)) {
		$allowed = 1;
		last;
	    }
	}
	if ($allowed) {
	    return (1, '');
	}
	else {
	    return (0, sprintf ("User %s is not part of an allowed group.", 
				$username));
	}
    }
    else {
	# If no user group is defined, then anyone may submit
	return (1, '');
    }
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

    my ($self, $fdat) = @_;

    # Make the user code
    my $time = HSDB4::DateTime->new()->out_mysql_timestamp();
    my $ctx = Digest::MD5->new;
    $ctx->add($self->out_label(), $time, int(rand(1<<32)));
    my $code = $ctx->add($ctx->b64digest())->b64digest ();

    my ($result, $count, $msg) = (0, '');
    eval {
	# Go through the list of keys
	foreach my $key (keys %{$fdat}) {
	    next unless my ($q_id) = $key =~ /eval_q_(\d+)/;
	    my $resp = 
	      HSDB45::Survey::Response->new ( _school => $self->school() );
	    $resp->primary_key ($code, $self->primary_key(), $q_id);
	    $resp->field_value('response', $fdat->{$key});
	    my ($r, $msg) = $resp->save;
	    die "Could not save $q_id ($r) [$fdat->{$key}]: $msg" unless $r;
	    $count++;
	}
	my $resp = HSDB45::Survey::Response->new( _school => $self->school() );
	$resp->primary_key($code, $self->primary_key, 0);
	$resp->field_value('response', $time);
	my ($r, $msg) = $resp->save;
	$count++;

	# Phew! We got there.
	$result = $count;
    };
    return (0, $@) if $@;
    return ($count, '');
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

sub admin_url {
    my $self = shift;
    return sprintf( "%s/%s/%d", $HSDB4::Constants::URLs{survey_admin},
		    $self->school(), $self->primary_key() );
}

sub out_admin_link {
    #
    # Return the admin URL and a link
    #

    my $self = shift;
    return sprintf ('<a href="%s">%s</a>', $self->admin_url, $self->out_label);
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

1;
__END__
