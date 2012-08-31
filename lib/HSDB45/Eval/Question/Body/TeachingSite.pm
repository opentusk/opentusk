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


package HSDB45::Eval::Question::Body::TeachingSite;

use strict;
use base qw(HSDB45::Eval::Question::Body);
use HSDB45::TeachingSite;

sub resp_cache {
    my $self = shift;
    unless ($self->{-resp_cache}) {
	my %cache = ();
	for my $site ($self->question()->parent_eval()->course()->child_teaching_sites()) {
	    $cache{$site->primary_key()} = $site->site_name();
	}
	$self->{-resp_cache} = \%cache;
    }
    return $self->{-resp_cache};
}

sub interpret_response {
    my $self = shift;
    my $resp = shift;

    return $self->resp_cache()->{$resp};
}

sub choices {
    my $self = shift;
    return sort {$a cmp $b} values %{$self->resp_cache()};
}

1;
