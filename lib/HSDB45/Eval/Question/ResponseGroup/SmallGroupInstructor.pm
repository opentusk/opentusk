package HSDB45::Eval::Question::ResponseGroup::SmallGroupInstructor;

use base qw(HSDB45::Eval::Question::ResponseGroup);

sub add_response {
    my $self = shift;
    my @valids = grep { ref $_ && $_->isa ('HSDB45::Eval::Question::Response') } @_;
    for (@valids) { $self->{-responses}{$_->field_value('user_code')} = $_ }
}


1;
