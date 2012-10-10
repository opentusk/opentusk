package HSDB45::Eval::Question::Body::TeachingSite;

use strict;
use base qw(HSDB45::Eval::Question::Body);
use HSDB45::TeachingSite;

sub resp_cache {
    my $self = shift;
    unless ($self->{-resp_cache}) {
	my %cache = ();
	for my $site ($self->question()->parent_eval()->course()->child_teaching_sites()) {
	    $cache{$site->primary_key()} = $site->site_name();
	}
	$self->{-resp_cache} = \%cache;
    }
    return $self->{-resp_cache};
}

sub interpret_response {
    my $self = shift;
    my $resp = shift;

    return $self->resp_cache()->{$resp};
}

sub choices {
    my $self = shift;
    return sort {$a cmp $b} values %{$self->resp_cache()};
}

1;
