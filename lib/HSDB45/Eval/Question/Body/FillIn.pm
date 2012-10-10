package HSDB45::Eval::Question::Body::FillIn;

use strict;
use base qw(HSDB45::Eval::Question::Body);

# INPUT:  none
# OUTPUT: true if the longtext option is set to yes, false otherwise
# EFFECT: none
sub longtext {
    my $self = shift();
    my $longtext = $self->elt()->att('longtext');
    if($longtext && ($longtext eq 'yes')) { return 1; }
    return 0;
}

sub set_longtext {
    my $self = shift;
    my $val = shift;
    $self->elt()->set_att('longtext', $val ? 'yes' : 'no');
    $self->question()->set_field_values('body', $self->elt()->sprint());
    return 1;
}

sub choices {
	return ;
}
1;
