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


package TUSK::ImportLog;

sub new {
    my $class = shift;
    $class = ref $class || $class;
    my $self = {_type => shift};
    return bless $self, $class;
}

sub set_type {
    my $self = shift;
    $self->{_type} = shift;
}

sub get_type {
    my $self = shift;
    return $self->{_type};
}

sub set_message {
    my $self = shift;
    $self->{_message} = shift;
}

sub get_message {
    my $self = shift;
    return $self->{_message};
}

1;


