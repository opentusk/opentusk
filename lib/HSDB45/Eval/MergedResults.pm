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


package HSDB45::Eval::MergedResults;

use strict;
use vars qw($VERSION);

$VERSION = do { my @r = (q$Revision: 1.9 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
sub version { return $VERSION; }

my @mod_deps  = ('HSDB45::Eval::Results');
my @file_deps = ();

sub get_mod_deps  { return @mod_deps }
sub get_file_deps { return @file_deps }

use base qw(HSDB4::SQLRow HSDB45::Eval::Results);
use HSDB4::Constants qw(:school);
use TUSK::Constants;
use HSDB45::Eval::Question::MergedResults;

my $tablename = "merged_eval_results";
my $primary_key_field = "merged_eval_results_id";
my @fields = qw(merged_eval_results_id title primary_eval_id secondary_eval_ids modified);
my %blob_fields = ();
my %numeric_fields = ();
my %cache = ();

# Description: creates a new HSDB45::Eval::MergedResults object
# Input: (_school => $school, _id => $id) OR (_school => $school, $primary_eval_id, @secondary_eval_ids)
# Output: newly created object
sub new {
    my $incoming = shift();
    my $class = ref($incoming) || $incoming;
    
    my $self = HSDB45::Eval::MergedResults->SUPER::new(_tablename => $tablename,
						       _fields => \@fields,
						       _blob_fields => \%blob_fields,
						       _numeric_fields => \%numeric_fields,
						       _primary_key_field => $primary_key_field,
						       _cache => \%cache,
						       @_
						       );

    bless($self, "HSDB45::Eval::MergedResults");
    $self->init(@_);
    bless($self, $class);
    return $self;
}

sub split_by_school {
    my $self = shift;
    return 1;
}

# Description: performs private object initialization
# Input: a primary eval id, and one or more secondary eval ids
# Output: initialzed object
sub init {
    my $self = shift();
    shift(); # _school
    $self->{-school} = shift(); # $school
    
    if(defined ($_[0]) && ($_[0] ne "_id")) {
	$self->field_value("primary_eval_id", shift());
	$self->field_value("secondary_eval_ids", join(",", @_));
    }

    return $self;
}

sub parent_eval {
    my $self = shift();
    unless($self->{-parent_eval}) {
	$self->{-parent_eval} = HSDB45::Eval->new(_school => $self->school(), _id => $self->primary_eval_id());
    }
    return $self->{-parent_eval};
}

sub primary_eval_id {
    my $self = shift();
    return @_ ? $self->field_value("primary_eval_id", shift()) : $self->field_value("primary_eval_id");
}

sub secondary_eval_ids {
    my $self = shift();

    if(@_) {
	$self->field_value("secondary_eval_ids", join(",", @_));
	return @_;
    }
    else {
	return split(",", $self->field_value("secondary_eval_ids"));
    }
}

sub title {
	my $self = shift;
	my $title = shift;
	$self->field_value('title',$title) if (defined($title));
	return $self->field_value('title');
}

sub question_results {
    my $self = shift();

    unless ($self->{-question_results}) {
	$self->{-question_results} = {};
	for my $q ($self->parent_eval()->questions()) { 
	    my $qr = HSDB45::Eval::Question::MergedResults->new($q, $self);
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

# Description: Returns the number of students that are enrolled in the courses covered by the merged eval results
# Input:
# Output: The integer number of enrolled students
sub enrollment {
    my $self = shift;
    my $catted_ids = join(",", $self->primary_eval_id(), $self->secondary_eval_ids());
	my $dbh = HSDB4::Constants::def_db_handle();
	my $db = HSDB4::Constants::get_school_db($self->school());
	my $num;
	my $sql = "SELECT COUNT(distinct child_user_id) 
		FROM $db.eval, $db.link_course_student 
		WHERE eval_id in ($catted_ids) 
		AND parent_course_id = course_id 
		AND eval.time_period_id = link_course_student.time_period_id";
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	($num) = $sth->fetchrow_array();
	return $num;
}

# Description: Returns the number of completion tokens for the eval
# Input:
# Output: The integer number of completions
sub total_completions {
    my $self = shift;
    unless ($self->{-total_completions}) {
	my $dbh = HSDB4::Constants::def_db_handle();
	my $db = HSDB4::Constants::get_school_db($self->school());
	my $num = undef;
	eval {
	    my $catted_ids = join(",", $self->primary_eval_id(), $self->secondary_eval_ids());
	    my $sth = $dbh->prepare ("SELECT COUNT(*) " .
				     "FROM $db\.eval_completion " . 
				     "WHERE eval_id IN ($catted_ids)");
	    $sth->execute();
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
	my $catted_ids = join("," => $self->primary_eval_id(), $self->secondary_eval_ids());
	my %user_code_hash;
	my $blank_resp = HSDB45::Eval::Question::Response->new(_school => $self->parent_eval()->school());
	my @resps = $blank_resp->lookup_conditions('eval_id IN (' . $catted_ids . ')');
	foreach my $resp (@resps) { $user_code_hash{$resp->user_code()}++ }
	$self->{-user_codes} = [keys(%user_code_hash)];
    }

    return @{$self->{-user_codes}};
}

# Description: Returns the time of the last completion
# Input: 
# Output: Returns a HSDB4::DateTime of the relevant time
sub last_completion_timestamp {
    my $self = shift;
    my $dbh = HSDB4::Constants::def_db_handle();
    my $db = get_school_db($self->school());
    my $date;
    eval {
	my $catted_ids = join(",", $self->primary_eval_id(), $self->secondary_eval_ids());
	my $sth = $dbh->prepare("SELECT MAX(created) " .
				"FROM $db\.eval_completion " . 
				"WHERE eval_id IN ($catted_ids)");
	$sth->execute();
	($date) = $sth->fetchrow_array();
    };
    return unless $date;
    return HSDB4::DateTime->new()->in_mysql_timestamp($date);
}

sub edit_merged_eval{
	my $self = shift;
	my $school = shift;
	my $fields = shift;
	my $blank_eval = HSDB45::Eval->new(_school=>$school);
	my $eval;
	if ($fields->{primary_eval}){
		if ($fields->{primary_eval} !~ /^\s*\d+\s*$/){
			return (1,"That Primary Eval is not a number.");
		}
		$eval = $blank_eval->lookup_key($fields->{primary_eval});
		if (!defined($eval->primary_key())){
			return (1,"That Primary Eval was not found in the database.");
		} 	
	} else {
		return (1,"No Primary Eval found");	
	}
	if ($fields->{secondary_evals}){
		foreach my $id (split /,/, $fields->{secondary_evals}) {
			next if (!defined ($id) || $id eq '');
	                $eval = $blank_eval->lookup_key($id);        
			if ($id !~ /^\s*\d+\s*$/){
				return (1,"The Secondary Eval $id is not a number.");
			}
			if (!defined($eval->primary_key())){    
				return (1,"Secondary Eval $id was not found in the database.");
			}
		}
	} else {
		return (1,"No Secondary Evals found");    
	} 
	if (!$fields->{title}){
		return (1,"A Title is Required.");
	}
	$self->primary_eval_id($fields->{primary_eval});
	$self->secondary_eval_ids($fields->{secondary_evals});
	$self->title($fields->{title}); 
	$self->save($TUSK::Constants::DatabaseUsers->{ContentManager}->{writeusername},$TUSK::Constants::DatabaseUsers->{ContentManager}->{writepassword});
	return 0;


}

1;
__END__
