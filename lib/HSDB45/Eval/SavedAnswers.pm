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


package HSDB45::Eval::SavedAnswers;

use strict;
use HSDB4::Constants qw/:school/;
use HSDB4::SQLRow::User;
use HSDB45::Eval;
use Digest::MD5;
use Sys::Hostname;
use vars qw($VERSION);

BEGIN { $ENV{PERL_JSON_BACKEND} = 'JSON::PP' }
use JSON;

$VERSION = do { my @r = (q$Revision: 1.21 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
sub version { return $VERSION; }

my @mod_deps  = ('HSDB45::Eval');
my @file_deps = ();

sub get_mod_deps  { return @mod_deps  }
sub get_file_deps { return @file_deps }


# Example:
#   # Save some answers from %fdat
#   my $answers = HSDB45::Eval::SavedAnswers->new($eval, $user, "password");
#   $answers->set_answers(%fdat);
#
#   # Do the loading
#   $answers = HSDB45::Eval::SavedAnswers->new($eval, $user, "password");
#   %fdat = $answers->get_answers();

# Takes an student's partially saved eval form and prepares to store results
# INPUT: An Eval, and a User, and their password
# OUTPUT: The SavedAnswers object.
# Dies if the password is not verified; that isn't right
sub new {
    my $class = shift;
    $class = ref $class || $class;
    my $eval = shift;
    return unless $eval->isa('HSDB45::Eval');
    my $user = shift;
    unless ($user->isa('HSDB4::SQLRow::User')) {
	my $tmp = HSDB4::SQLRow::User->new();
	$tmp->lookup_key($user);
	return unless $tmp->primary_key() eq $user;
	$user = $tmp;
    }
    my $password = shift;
    # unless ($user->verify_password($password)) {
    # return;
    # }
    my $self = { -hash => make_hash($user->primary_key(), $password, $eval->primary_key()),
		 -eval => $eval, -school => $eval->school() };
    bless $self, $class;
    $self->do_lookup();
    return $self;
}

sub new_school_id {
    my $class = shift;
    $class = ref $class || $class;
    my $school = shift;
    return unless get_school_db($school);
    my $self = {};
    $self->{-school} = $school;
    my $id = shift;
    $self->{-id} = $id;
    bless $self, $class;
    $self->do_lookup();
    return $self;
}

sub school {
    my $self = shift;
    return $self->{-school};
}

sub school_db {
    my $self = shift;
    return get_school_db($self->school());
}

# Wraps an MD5 hashing function
# INPUT: A list of arguments
# OUTPUT: The digest string
sub make_hash {
    my $ctx = Digest::MD5->new;
    $ctx->add (@_);
    return $ctx->add ($ctx->b64digest())->b64digest ();
}

# Returns the hashed object
# INPUT:
# OUTPUT: The hash that will be used as a key
sub hash {
    my $self = shift;
    return $self->{-hash};
}

# Returns the ID in the saved_answers table
# INPUT:
# OUTPUT: The ID
sub id {
    my $self = shift;
    return $self->{-id};
}

sub primary_key {
    my $self = shift;
    return $self->id();
}

# Returns the Eval object
# INPUT:
# OUTPUT: The Eval object
sub eval {
    my $self = shift;
    return $self->{-eval};
}

# Does a lookup in the eval_save_data table for this object, and thaws the data if found
# INPUT:
# OUTPUT:
sub do_lookup {
    my $self = shift;
    my $dbh = HSDB4::Constants::def_db_handle();
    return if $self->has_answers();
    eval {
	my $db = $self->school_db();
	my $data;
	
	if ($self->id()) {
	    my $sth = $dbh->prepare(qq[SELECT data FROM $db\.eval_save_data
				       WHERE eval_save_data_id=?]);
	    $sth->execute($self->id());
	    ($data) = $sth->fetchrow_array();
	}
	else {
	    my $sth = $dbh->prepare(qq[SELECT eval_save_data_id, data FROM $db\.eval_save_data 
				       WHERE user_eval_code=?]);
	    $sth->execute($self->hash());
	    my $id;
	    ($id, $data) = $sth->fetchrow_array();
	    $self->{-id} = $id;
	}
	if ($data) {
		#Get JSON to expect a character string, rather than octets.
		#This is because the default database handle will transform query results into
		#character strings on the way in. 
	    $self->{-answers} = JSON->new->loose->decode($data);
	    $self->{-has_answers} = 1;
	}
    };
    warn if $@;
}

sub has_answers {
    my $self = shift;
    return $self->{-has_answers};
}

# Actually does the saving into the database
# INPUT:
# OUTPUT:
sub do_save {
    my $self = shift;
    my $dbh = HSDB4::Constants::def_db_handle();
	my $answers = $self->answers();

	my $json_answers = encode_json($answers);
	$json_answers =~ s/'/\\'/g;      #Snip out single quote characters.
	$json_answers =~ s/\\r\\n/\\n/g; #Snip out the extra carriage returns introduced by encode_json.

    eval {
	my $db = $self->school_db();
	if ($self->id()) {
		$dbh->do("UPDATE $db\.eval_save_data SET data = ? WHERE eval_save_data_id = ?", undef, $json_answers, $self->id());
	}
	else {
		$dbh->do("INSERT INTO $db\.eval_save_data (user_eval_code, data) VALUES (?, ?)", undef, $self->hash(), $json_answers);
	    $self->{-id} = $dbh->{'mysql_insertid'};
	}
    };
    die $@ if $@;
}

# Deletes an answers object when that's appropriate
# INPUT:
# OUTPUT:
sub do_delete {
    my $self = shift;

    return unless $self->id();

    my $dbh = HSDB4::Constants::def_db_handle();
    eval {
	my $db = $self->school_db();
	$dbh->do(qq[DELETE FROM $db\.eval_save_data WHERE eval_save_data_id=?],
		 undef, $self->id());
    };
    warn if $@;
}

# Returns the reference to the answers hash
# INPUT:
# OUTPUT: The reference to the answers hash
sub answers {
    my $self = shift;
    return $self->{-answers};
}

# Sets the answers from an fdat hash
# INPUT: A hash of answers to save
# OUTPUT:
sub set_answers {
    my $self = shift;
    my %save_fdat = ();
    while (@_) {
	my ($key, $val) = splice(@_, 0, 2);
	if ($key =~ /^eval_q_(\d+)$/) { $save_fdat{$1} = $val }
    }
    $self->{-answers} = \%save_fdat;
    $self->{-has_answers} = 1;
    $self->do_save();
}

# Gets a hash of answers
# INPUT:
# OUTPUT: The answers as a big hash
sub get_answers {
    my $self = shift;
    return unless $self->has_answers();
    return %{$self->answers()};
}

1;

__END__
