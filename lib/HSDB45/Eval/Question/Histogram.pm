package HSDB45::Eval::Question::Histogram;

use strict;
#use XML::Twig;
use vars qw($VERSION);

$VERSION = do { my @r = (q$Revision: 1.10 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
sub version { return $VERSION; }

my @mod_deps  = ();
my @file_deps = ();

sub get_mod_deps {
    return @mod_deps;
}

sub get_file_deps {
    return @file_deps;
}

sub new {
    my $class = shift;
    $class = ref $class || $class;
    my $self = {};
    bless $self, $class;
    return $self->init (@_);
}

sub init {
    my $self = shift;
    $self->{-histogram} = {};
    my @choices = @{shift()};
    $self->{-choices} = [@choices];
    foreach my $choice (@choices) { $self->{-histogram}{$choice} = 0; }
    return $self;
}

sub add_response {
    my $self = shift;
    my $resp = shift;
    $self->{-histogram}{$resp}++;
}

sub bins {
    my $self = shift;
    return @{$self->{-choices}};
#    return sort( keys( %{$self->{-histogram}} ) );
}

sub bin_count {
    my $self = shift;
    my $resp = shift;
    return $self->{-histogram}{$resp};
}

1;
__END__
