package HSDB45::Survey::Response;

use strict;
use base 'HSDB4::SQLRow';
use HSDB45::Eval::Question::Results;;

# File-private lexicals
my $tablename = "survey_response";
my $primary_key_field = [ 'user_code', 'survey_id', 'eval_question_id'];
my @fields = qw(user_code survey_id eval_question_id response);
my %blob_fields = (response => 1);
my %numeric_fields = ();

BEGIN {
    use vars qw($VERSION);
    $VERSION = do { my @r = (q$Revision: 1.2 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
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
    return $self->field_value ('user_code');
}

sub response {
    my $self = shift;
    return $self->field_value ('response');
}

sub interpreted_response {
    my $self = shift;
    # If there's no argument, then interpret its own response
    my $resp = $self->response ();
    return $self->parent_results()->question()->body()->interpret_response($resp);
}

1;
__END__
