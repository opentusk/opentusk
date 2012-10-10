package TUSK::Case::Phase::DiagnosticStudies;

use strict;
use base qw(TUSK::Case::Phase );
use Carp qw(confess cluck);
use HSDB4::SQLLink;
use Data::Dumper; 

BEGIN {
    use vars qw($VERSION);
    $VERSION = do { my @r = (q$Revision: 1.1 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
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


sub getBatteryType{
	return 'Diagnostic Studies';
}
sub getIncludeFile {
    my $self = shift;
    return "diagnostic_studies_phase";
}


1;

