package TUSK::ImportLog;

sub new {
    my $class = shift;
    $class = ref $class || $class;
    my $self = {_type => shift};
    return bless $self, $class;
}

sub set_type {
    my $self = shift;
    $self->{_type} = shift;
}

sub get_type {
    my $self = shift;
    return $self->{_type};
}

sub set_message {
    my $self = shift;
    $self->{_message} = shift;
}

sub get_message {
    my $self = shift;
    return $self->{_message};
}

1;


