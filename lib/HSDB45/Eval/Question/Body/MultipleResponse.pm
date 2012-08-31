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


package HSDB45::Eval::Question::Body::MultipleResponse;

use strict;
use base qw(HSDB45::Eval::Question::Body::AbstractChoice);

# Description: Returns a list of the texts the user chose
# Input: A string of white-space seprated labels
# Output: A list of choice texts
sub interpret_response {
    my $self = shift;
    my $string = shift;
    return join( "\t", grep { defined } map { $self->SUPER::interpret_response( $_ ) } split (/\s+/, $string) );
}

# Description: Returns the multiple choice style value
# Input:
# Output: Either "combobox" or "checkbox" (default)
sub choice_style {
    my $self = shift;
    my $style = $self->elt()->att( 'choice_style' );
    return $style || 'checkbox';
}

# Description: Returns the number of rows to display in a combobox
# Input:
# Output: The number of rows (defaults to 5)
sub display_rows {
    my $self = shift;
    my $style = $self->elt()->att( 'display_rows' );
    return $style || 5;
}

1;
