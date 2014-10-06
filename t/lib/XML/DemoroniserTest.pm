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


package XML::DemoroniserTest;

use strict;
use base qw/Test::Unit::TestCase/;
use Test::Unit;
use XML::Demoroniser;

sub sql_files {
    return ();
}

sub new {
    my $self = shift()->SUPER::new(@_);
    return $self;
}

sub set_up {

}

sub tear_down {

}

sub test_constructor {
    my $demon = XML::Demoroniser->new();
    assert($demon->isa("XML::Demoroniser"), "Can't create instance of XML::Demoroniser");
}

sub test_demoronise {
    local $/; # slurp file for now, but don't trash the input record separator forever!!!

    # get moronic data
    my $filename = "moronic_data.xml";
    open FILE, $filename or die "Could not open $filename";
    my $moronic_data = <FILE>;
    close FILE;

    # demornonise
    my $demon = XML::Demoroniser->new($moronic_data);
    my $demoronised_data = $demon->demoronise;

    $filename = "demoronized_data.xml";
    open FILE, $filename or die "Could not open $filename";
    my $existing_data = <FILE>;
    close FILE;    

    # see if the demoronized data matches the existing demoronized data
    assert($demoronised_data == $existing_data,"Failed to properly demoronise data");
}

sub test_get_data {
    my $data = "here is a simple string to verify that the data can be put into and taken out of the demoroniser";
    my $demon = XML::Demoroniser->new($data);
    
    assert($demon->get_data == $data,"Failed to get data");
}

sub test_set_data {
    my $data = "here is a simple string to verify that the data can be put into and taken out of the demoroniser";
    my $demon = XML::Demoroniser->new;
    $demon->set_data($data);
    assert($demon->get_data == $data,"Failed to set data");
}

1;
