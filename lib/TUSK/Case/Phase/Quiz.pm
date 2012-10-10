package TUSK::Case::Phase::Quiz;

use strict;
use base qw(TUSK::Case::Phase);
use Carp qw(confess cluck);

BEGIN {
    use vars qw($VERSION);
    $VERSION = do { my @r = (q$Revision: 1.1 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
}


sub getIncludeFile {
    my $self = shift;
    return "quiz_phase";
}


1;
