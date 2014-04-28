# Copyright 2012 Tufts University 

# Licensed under the Educational Community License, Version 1.0 (the "License"); 
# you may not use this file except in compliance with the License. 
# You may obtain a copy of the License at 

# http://www.opensource.org/licenses/ecl1.php 

# Unless required by applicable law or agreed to in writing, software 
# distributed under the License is distributed on an "AS IS" BASIS, 
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
# See the License for the specific language governing permissions and 
# limitations under the License.


package TUSK::Application::Competency::Category;

use strict;

use TUSK::Competency::Competency;
use TUSK::Competency::Course;
use TUSK::Competency::Hierarchy;

#######################################################


my @comp_categories;

sub getCategories {
    my ($lib, $data) = @_;
    
    getCategoriesSub($data);
    
    return \@comp_categories;
}

sub getCategoriesSub {

    my ($data) = @_;

    foreach my $d (@{$data}){
	if (($d->{'children'})){
	    my %comp_category;
	    $comp_category{$d->{'id'}} = $d->{title};
	    push @comp_categories, \%comp_category;	
	    getCategoriesSub ($d->{'children'});
	}
    }
    
}

#######################################################

1;
