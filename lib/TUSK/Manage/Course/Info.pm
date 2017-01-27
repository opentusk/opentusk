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


package TUSK::Manage::Course::Info;

use Carp;
use TUSK::Core::CourseCode;
use HSDB4::Constants;
use TUSK::Functions;
use HSDB4::SQLRow::User;
use HSDB45::TimePeriod;
use TUSK::Constants;

use strict;

my $pw = $TUSK::Constants::DatabaseUsers{ContentManager}->{writepassword};
my $un = $TUSK::Constants::DatabaseUsers{ContentManager}->{writeusername};

sub info_process{
    my ($req, $course_id, $school, $user_id, $fdat) = @_;
    my ($rval, $msg);

    my $course = HSDB45::Course->new( _school => $school )->lookup_key( $course_id );

    my $tusk_course_id = $course->getTuskCourseID();

    my $tusk_course = TUSK::Course->lookupReturnOne("course_id = $tusk_course_id");

    my $landing_type = $fdat->{landing_type};

    my $landing_type_id = TUSK::Enum::Data->lookupReturnOne("short_name = '$landing_type'")->getPrimaryKeyID();

    $tusk_course->setLandingPage($landing_type_id);

    $tusk_course->save({ user => $user_id });

    $course->set_field_values( title => $fdat->{cr_title},
				      oea_code => $fdat->{cr_oea_code},
				      color => $fdat->{cr_color},
                                      course_source=>$fdat->{cr_course_source},
                                      type=>$fdat->{cr_type},
				      abbreviation => $fdat->{cr_abbreviation},
				      associate_users => $fdat->{associate_users},
				      rss => $fdat->{cr_rss}
				      );
    ($rval, $msg) = $course->save($un, $pw);

	my @new_subcourses;
	foreach my $new_subcourse ( TUSK::Functions::get_data($fdat, 'subcourses') ) {
		push @new_subcourses, HSDB45::Course->new( _school => $course->school() )->lookup_key( $new_subcourse->{'course_id'} );
	}
	$course->set_subcourses( $user_id, \@new_subcourses );

    my @data = TUSK::Functions::get_data($fdat,'codes');
   
    my $school_id = $course->get_school()->getPrimaryKeyID();
    my ($code,$pks) = (undef,{});
    my $all_codes = $course->get_course_codes();
    foreach my $set (@data){
	 next unless ($set->{code});
	if ($set->{pk} eq 0){
		# new record, do insert
		$code = TUSK::Core::CourseCode->new();
		$code->setCode($set->{code});
		$code->setCourseID($course_id);
		$code->setSchoolID($school_id);
		$code->setCodeType($set->{code_type});
		$code->save({user=>$user_id});	
	} else {
		$pks->{$set->{pk}} = 1;
		# this is an update
		if ($set->{elementchanged}){
			$code = TUSK::Core::CourseCode->lookupKey($set->{pk});
			$code->setCode($set->{code});
			$code->setCourseID($course_id);
			$code->setSchoolID($school_id);
			$code->setCodeType($set->{code_type});
			$code->save({user=>$user_id});    
		}
	}
    }
    foreach my $code (@{$all_codes}){
		if (!defined($pks->{$code->getPrimaryKeyID()})){
			$code->delete({user=>$user_id});
		}
    }
     
    return($rval, $msg) if ($rval < 1);

    return(1, "Course Edited Successfully");
    
}

sub info_pre_process{
    my ($req, $course_id, $school, $is_school_admin, $fdat) = @_;
    my ($data);

	my $course = HSDB45::Course->new( _school => $school )->lookup_key( $course_id );

    
    if ($course){
		$fdat->{page}="edit";
    }else{
		# something bad here
    }
    
    if ($is_school_admin and $course){
		if ($course->field_value('associate_users') eq "User Group"){
			$data->{groups} = [ $course->user_group_link()->get_children($course_id, "sub_group='No'")->children ];
		}
    }else{
		#$req->{image} = "BasicInformation";
    }
    
    return $data;
}

1;
