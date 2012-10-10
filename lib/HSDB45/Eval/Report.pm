package HSDB45::Eval::Report;

use strict;

# Description:
# Input:
# Output:


# Description:
# Input:
# Output:
sub new {
    my $class = shift;
    $class = ref $class || $class;
    my $self = {};
    bless $self, $class;
    return $self->init (@_);
}

# Description:
# Input:
# Output:
sub init {
    my $self = shift;
    # Do something with the arguments...
    return $self;
}


package HSDB45::Eval::Report::Format;

use strict;

# Description:
# Input:
# Output:
sub new {
    my $class = shift;
    $class = ref $class || $class;
    my $self = {};
    bless $self, $class;
    return $self->init (@_);
}

# Description:
# Input:
# Output:
sub init {
    my $self = shift;
    # Do something with the arguments...
    return $self;
}


1;
__END__
