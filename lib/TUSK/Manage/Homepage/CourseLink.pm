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


package TUSK::Manage::Homepage::CourseLink;

use HSDB4::Constants;
use HSDB4::SQLLink;
use HSDB45::Course;
use TUSK::HomepageCourse;
use TUSK::HomepageCategory;
use TUSK::Constants;

use strict;

my $pw = $TUSK::Constants::DatabaseUsers{ContentManager}->{writepassword};
my $un = $TUSK::Constants::DatabaseUsers{ContentManager}->{writeusername};

sub show_pre_process{
    my ($req) = @_;
    my ($data); 

    $data->{category} = TUSK::HomepageCategory->new(_school => $req->{school})->lookup_key($req->{category_id}); 

    $data->{courselinks} = [ $data->{category}->get_homepage_courses ];

    return $data;

}

sub show_process{
    my ($req, $sort, $data) = @_;
    my ($rval, $msg, $index, $insert);
   
    ($index, $insert) = split('-', $sort) if ($sort);
	
    splice(@{$data->{courselinks}}, ($insert-1), 0, splice(@{$data->{courselinks}}, ($index-1),1));
    
    for(my $i=0; $i < scalar(@{$data->{courselinks}}); $i++){
	@{$data->{courselinks}}[$i]->set_field_values( sort_order=>10*($i+1));
	($rval, $msg) = @{$data->{courselinks}}[$i]->save($un, $pw);
	return ($rval, $msg, $data) if ($rval < 1);
    }

    return (1, "Order Successfully Changed", $data);
}

sub addedit_pre_process{
    my ($req, $fdat) = @_;
    my ($data);

    my @conditions = ("order by title");
    # the 4th year courses don't get used in these dropdowns
    push(@conditions,"(oea_code is null or oea_code not regexp '.{3}4[[:digit:]]{2}')") if ($req->{school} =~ /medical/i);
    $data->{courses} = [ HSDB45::Course->new(_school => $req->{school})->lookup_conditions(@conditions) ];
    
    if ($fdat->{page} eq "add"){
	$req->{image} = "AddCourseLink";
    }else{
	$req->{image} = "ModifyCourseLink";
    }

    return $data;
}

sub addedit_process{
    my ($req, $fdat) = @_;
    my ($rval, $msg);

    if ($fdat->{page} eq "add"){
	$req->{courselink} = TUSK::HomepageCourse->new(_school => $req->{school});
	$req->{courselink}->set_field_values(
					     sort_order => 65535,
					     category_id => $req->{category_id}
					     ); 
    }
    
    $req->{courselink}->set_field_values( 
					  indent => $fdat->{indent},
					  label => $fdat->{label},
					  course_id => $fdat->{course_id},
					  url => $fdat->{url},
					  show_date => $fdat->{showDate},
					  hide_date => $fdat->{hideDate},
				      );

    ($rval, $msg) = $req->{courselink}->save($un, $pw);
    return ($rval, $msg) if ($rval < 1);
    
    if ($fdat->{page} eq "add"){
	$msg = "Course Link Successfully Added";
    }else{
	$msg = "Course Link Successfully Modified";
    }
    	return (1, $msg);

}

sub delete_process{
    my ($req) = @_;

    $req->{courselink}->delete($un, $pw);

    return (1, "Course Link");
}

1;
