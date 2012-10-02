# Copyright 2012 Tufts University 
#
# Licensed under the Educational Community License, Version 1.0 (the "License"); 
# you may not use this file except in compliance with the License. 
# You may obtain a copy of the License at 
#
# http://www.opensource.org/licenses/ecl1.php 
#
# Unless required by applicable law or agreed to in writing, software 
# distributed under the License is distributed on an "AS IS" BASIS, 
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
# See the License for the specific language governing permissions and 
# limitations under the License.


package TUSK::Case::Phase::DifferentialDiagnosis;

use strict;
use base qw(TUSK::Case::Phase);
use Carp qw(confess cluck);

BEGIN {
    use vars qw($VERSION);
    $VERSION = do { my @r = (q$Revision: 1.4 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
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
