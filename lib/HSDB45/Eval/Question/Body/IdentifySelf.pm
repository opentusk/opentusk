package HSDB45::Eval::Question::Body::IdentifySelf;

use base qw(HSDB45::Eval::Question::Body);

sub interpret_response {
    my $self = shift;
    my $resp = shift;
    my $user = HSDB4::SQLRow::User->new();
    $user->lookup_key( $resp );
    return $user->out_label();
}

sub choices {
	return ;
}

1;
