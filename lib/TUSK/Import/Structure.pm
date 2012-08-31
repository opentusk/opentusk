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


package TUSK::Import::Structure;

use strict;
use Data::Dumper;

sub new {
    my $class = shift;
    $class = ref $class || $class;
    my $self = {_course_users => [],
	        };
    return bless $self, $class;
}

sub add_course_student {
    my ($self,$course_id,$user_id,$time_period_id) = @_;
    my $course_student = {"course_id" => $course_id,
			  "user_id" => $user_id,
			  "time_period_id" => $time_period_id};
    push(@{$self->{_course_users}},$course_student);
}

sub save {
    my ($self,$un,$pw) = @_;
    foreach (@{$self->{_course_users}}) {
	print Dumper($_);
    }    
}

1;
