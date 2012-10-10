package TUSK::Case::Phase::DifferentialDiagnosis;

use strict;
use base qw(TUSK::Case::Phase);
use Carp qw(confess cluck);

BEGIN {
    use vars qw($VERSION);
    $VERSION = do { my @r = (q$Revision: 1.3 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
}


###################
# Field Accessors #
###################


##########################
# End of Field Accessors #
##########################

############
# LinkDefs #
############


###################
# End of LinkDefs #
###################



sub getIncludeFile {
    my $self = shift;
    return "diff_diagnosis_phase";
}


1;
