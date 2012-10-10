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


package HSDB45::Eval::Question::Body::YesNo;

use base qw(HSDB45::Eval::Question::Body::AbstractChoice);

sub choice_labels {
    return qw/a b/;
}

sub setup_labels {
    return;
}

# Description: Turns a label of a choice into the choice text itself
# Input: The choice label ('a' or 'b')
# Output: The choice text (Yes or No)
#    e.g., if NA is chosen)
sub interpret_response {
    my $self = shift;
    my $label = shift;
    my $choice;
    if ($label eq 'a' || $label eq 'A' || $label eq '1') { $choice = 'Yes' }
    elsif ($label eq 'b' || $label eq 'B' || $label eq '2') { $choice = 'No' }
    return $choice;
}

1;
