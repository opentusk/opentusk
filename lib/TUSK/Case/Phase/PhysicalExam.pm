package TUSK::Case::Phase::PhysicalExam;

use strict;
use base qw(TUSK::Case::Phase );
use Carp qw(confess cluck);
use Data::Dumper; 

BEGIN {
    use vars qw($VERSION);
    $VERSION = do { my @r = (q$Revision: 1.3 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
}

sub new {
    my $invocant = shift();
    my $class = ref($invocant) || $invocant;

    my $self = $class->SUPER::new();
    return $self;
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
	return 'Physical Exam';
}


sub getIncludeFile {
    my $self = shift;
    return 'physical_exam_phase';
}

1;
