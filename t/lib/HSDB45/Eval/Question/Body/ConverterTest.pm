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


package HSDB45::Eval::Question::Body::ConverterTest;

use strict;
use base qw/Test::Unit::TestCase/;
use Test::Unit;
use HSDB45::Eval;

sub sql_files {
    return qw(base_course.sql base_time_period.sql base_user_group.sql eval.sql);
}

sub new {
    my $self = shift()->SUPER::new(@_);
    return $self;
}

sub set_up {

}

sub tear_down {

}

sub test_choice_labels {
    my ($eval_id, $question_id) = (33, 11760);
    my $e = HSDB45::Eval->new(_id => $eval_id, _school => "Regress");
    my $q = $e->question($question_id);
    my @labels = $q->body()->choice_labels();
    my @right_labels = qw/a d e f b/;
    for my $i (0..4) {
	assert($labels[$i] eq $right_labels[$i], "Failed to copy choice labels correctly.");
    }
}

1;
