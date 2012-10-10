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


package HSDB45::Eval::Filter::Rule;

use strict;

my %rule_types = ( 'include_all'      => 1,
		   'include_selected' => 1,
		   'exclude_all'      => 1,
		   'exclude_selected' => 1
	       );

sub new ($$$@) {
    my $incoming = shift();
    my $class = ref($incoming) || $incoming;
    my $self = {};
    bless($self, $class);
    $self->{-question_type} = shift();
    $self->{-rule_type} = shift();
    die 'bogus rule type: ' . $self->{-rule_type} unless $rule_types{$self->{-rule_type}};
    $self->{-question_id_hash}  = {};
    $self->{-question_id_hash}{$_} = 1 foreach @_;
    return $self;
}

sub question_type ($) {
    my $self = shift();
    return $self->{-question_type};
}

sub rule_type ($) {
    my $self = shift();
    return $self->{-rule_type};
}

sub ids ($) {
    my $self = shift();
    return keys(%{$self->{-question_id_hash}});
}

sub references_id ($$) {
    my $self = shift();
    my $id = shift();
    return $self->{-question_id_hash}{$id} ? 1 : 0;
}

1;
