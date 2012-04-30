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


package TUSK::Import::LogTest;

use strict;
use base qw/Test::Unit::TestCase/;
use Test::Unit;
use TUSK::ImportLog;

sub new {
    my $self = shift()->SUPER::new(@_);
    return $self;
}

sub sql_files {
    return;
}

sub set_up {
    return;
}

sub tear_down {
    return;
}

sub test_new {
    my $log = TUSK::Import::Log->new("user");
    assert($log->isa("TUSK::Import::Log"),"Instantiating TUSK::Import::Log object failed");
    assert($log->get_type eq "user","Setting type failed");
}

sub test_set_get_message {
    my $log = TUSK::Import::Log->new;
    my $res = $log->set_message("the item failed");
    assert($res,"Could not set message in Import::Log");
    assert($log->get_message eq "the item failed","Could not get message in Import::Log"); 
}
1;
