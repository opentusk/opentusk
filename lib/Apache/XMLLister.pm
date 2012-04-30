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


package Apache::XMLLister;

use strict;

use HSDB45::TimePeriod;
use Apache2::Const ':common';
use Apache2::RequestRec();


sub handler {
    my $r = shift();
    my @pieces = split(/\//, $r->path_info());
    shift(@pieces); # goodbye null field
    my $what = lc(shift(@pieces)) or return NOT_FOUND;
    my $school = shift(@pieces);

    my %lister_map = ("timeperiod" => "HSDB45::TimePeriod::Lister");


    return NOT_FOUND unless($lister_map{$what});
    $r->content_type("text/xml");

    my $xml_text = $lister_map{$what}->get_xml_text($school);
    return NOT_FOUND unless($xml_text);
    $r->print($xml_text);
    return OK;
}

1;

