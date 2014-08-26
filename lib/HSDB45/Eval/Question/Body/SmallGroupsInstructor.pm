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


package HSDB45::Eval::Question::Body::SmallGroupsInstructor;

use strict;
use base qw(HSDB45::Eval::Question::Body);

sub resp_cache {
    my $self = shift;
    unless ($self->{-resp_cache}) {
	my %cache = ();
	my $eval = $self->question()->parent_eval();
	for my $instructor ($eval->course()->child_small_group_leaders($eval->time_period()->primary_key())) {
	    $cache{$instructor->getPrimaryKeyID()} = $instructor->outLastFirstName();
	}
	$self->{-resp_cache} = \%cache;
    }
    warn $self->{-resp_cache};
    return $self->{-resp_cache};
}

sub interpret_response {
    my $self = shift;
    my $resp = shift;

    return $self->resp_cache()->{$resp};
}

sub choices {
    my $self = shift;
    return values %{$self->resp_cache()};
}

1;
__END__
