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


package TUSK::Manage::Homepage::Category;

use HSDB4::Constants;
use HSDB4::SQLLink;
use TUSK::HomepageCategory;
use HSDB45::UserGroup;
use TUSK::Constants;

use strict;

my $pw = $TUSK::Constants::DatabaseUsers{ContentManager}->{writepassword};
my $un = $TUSK::Constants::DatabaseUsers{ContentManager}->{writeusername};

sub show_pre_process{
    my ($req) = @_;
    my ($data); 

    my $category = TUSK::HomepageCategory->new(_school => $req->{school});
    $data->{categories} = [ $category->lookup_conditions("order by sort_order") ];

    $data->{user_groups} = get_user_groups($req);
    foreach my $ug (@{$data->{user_groups}}){
	$data->{user_group_hash}->{$ug->primary_key} = $ug;
    }

    return $data;
}

sub show_process{
    my ($req, $sort, $data) = @_;
    my ($rval, $msg, $index, $insert);
   
    ($index, $insert) = split('-', $sort) if ($sort);
	
    splice(@{$data->{categories}}, ($insert-1), 0, splice(@{$data->{categories}}, ($index-1),1));
    
    for(my $i=0; $i < scalar(@{$data->{categories}}); $i++){
	@{$data->{categories}}[$i]->set_field_values( sort_order=>10*($i+1));
	($rval, $msg) = @{$data->{categories}}[$i]->save($un, $pw);
	return ($rval, $msg, $data) if ($rval < 1);
    }

    return (1, "Order Successfully Changed", $data);
    
}

sub addedit_process{
    my ($req, $fdat) = @_;
    my ($rval, $msg);

    if ($fdat->{page} eq "add"){
	$req->{category} = TUSK::HomepageCategory->new(_school => $req->{school});
	$req->{category}->set_field_values(sort_order => 65535); 
    }
    
    $req->{category}->set_field_values( 
					label => $fdat->{label},
					primary_user_group_id => $fdat->{primary_user_group_id},
					secondary_user_group_id => $fdat->{secondary_user_group_id},
					schedule => $fdat->{schedule}
				      );

    ($rval, $msg) = $req->{category}->save($un, $pw);
    return ($rval, $msg) if ($rval < 1);
    
    if ($fdat->{page} eq "add"){
	$msg = "Category Successfully Added";
    }else{
	$msg = "Category Successfully Modified";
    }
    	return (1, $msg);
}

sub addedit_pre_process{
    my ($req, $fdat) = @_;
    my $data;
    
    $data->{user_groups} = get_user_groups($req);
    if ($fdat->{page} eq "add"){
	$req->{image} = "AddCategory";
    }else{
	$req->{image} = "ModifyCategory";
    }

    return $data;
}

sub delete_process{
    my ($req) = @_;

    $req->{category}->delete($un, $pw);

    return (1, "Category Deleted");
}

sub get_user_groups{
    my ($req) = @_;
    return [ HSDB45::UserGroup->new(_school => $req->{school})->lookup_conditions("order by label") ];
}

1;
