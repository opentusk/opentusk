package TUSK::Case::Phase::Diagnosis;

use strict;
use base qw(TUSK::Case::Phase);
use Carp qw(confess cluck);

BEGIN {
    use vars qw($VERSION);
    $VERSION = do { my @r = (q$Revision: 1.3 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
}


sub getIncludeFile {
    my $self = shift;
    return "diagnosis_phase";
}


1;
