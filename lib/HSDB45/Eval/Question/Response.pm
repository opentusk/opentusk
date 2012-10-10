package HSDB45::Eval::Question::Response;

use strict;
use base 'HSDB4::SQLRow';
use HSDB45::Eval::Question::Results;;

# File-private lexicals
my $tablename = "eval_response";
my $primary_key_field = [ 'user_code', 'eval_id', 'eval_question_id'];
my @fields = qw(user_code eval_id eval_question_id response fixed);
my %blob_fields = (response => 1);
my %numeric_fields = ();

my %cache = ();

# Description: Constructor
# Input: _school => school
# Output: HSDB45::Eval::Question::Results object
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
}

sub split_by_school {
    my $self = shift;
    return 1;
}

sub parent_results {
    my $self = shift;
    return $self->aux_info ('parent_results');
}


sub user_code {
    my $self = shift;

    # brace yourself for a two-tiered kludge...  don't ask, or ever hope to understand...
    unless($self->fixed() && $self->fixed() eq 'Y') { # kludge for User.pm
	unless($self->{_fixed_user_code}) { # kludge for SQLRow.pm
	    my $ctx = Digest::MD5->new();
	    $ctx->add($self->field_value('user_code'));
	    $ctx->add($self->field_value('eval_id'));
	    $self->{_fixed_user_code} = $ctx->b64digest();
	}
	return $self->{_fixed_user_code};
    }

    return $self->field_value('user_code');
}

sub fixed {
    my $self = shift();
    return $self->field_value('fixed');
}

sub response {
    my $self = shift;
    return $self->field_value('response');
}

sub parent_question {
	my $self = shift;
	unless ($self->aux_info('-parent_question')){
		$self->set_aux_info('-parent_question',HSDB45::Eval::Question->new(_school=>$self->school,
			_id=>$self->field_value('eval_question_id')));
	}
	return $self->aux_info('-parent_question');
}
sub parent_eval {
	my $self = shift;
	unless ($self->aux_info('-parent_eval')){
		$self->set_aux_info('-parent_eval',HSDB45::Eval->new(_school=>$self->school,
			_id=>$self->field_value('eval_id')));
	}
	return $self->aux_info('-parent_eval');
}
sub interpreted_response {
    my $self = shift;
    # If there's no argument, then interpret its own response
    my $resp = $self->response();
    return $self->parent_results()->question()->body()->interpret_response($resp);
}

1;
__END__
