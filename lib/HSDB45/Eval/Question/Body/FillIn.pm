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


package HSDB45::Eval::Question::Body::FillIn;

use strict;
use base qw(HSDB45::Eval::Question::Body);

# INPUT:  none
# OUTPUT: true if the longtext option is set to yes, false otherwise
# EFFECT: none
sub longtext {
    my $self = shift();
    my $longtext = $self->elt()->att('longtext');
    if($longtext && ($longtext eq 'yes')) { return 1; }
    return 0;
}

sub set_longtext {
    my $self = shift;
    my $val = shift;
    $self->elt()->set_att('longtext', $val ? 'yes' : 'no');
    $self->question()->set_field_values('body', $self->elt()->sprint());
    return 1;
}

sub choices {
	return ;
}
1;
