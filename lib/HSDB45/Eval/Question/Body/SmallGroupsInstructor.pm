package HSDB45::Eval::Question::Body::SmallGroupsInstructor;

use strict;
use base qw(HSDB45::Eval::Question::Body);

sub resp_cache {
    my $self = shift;
    unless ($self->{-resp_cache}) {
	my %cache = ();
	for my $inst ($self->question()->parent_eval()->course()->child_small_group_leaders()) {
	    $cache{$inst->primary_key()} = $inst->out_label();
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
    return values %{$self->resp_cache()};
}

1;
__END__
