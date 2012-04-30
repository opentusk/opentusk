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


package TUSK::Tracking;

use strict;

BEGIN {
    require Exporter;
    require HSDB4::SQLRow;
    
    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

    @ISA = qw(HSDB4::SQLRow Exporter);
    @EXPORT = qw( );
    @EXPORT_OK = qw( );
    $VERSION = do { my @r = (q$Revision: 1.15 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
}

use HSDB4::Constants qw(:school);
use HSDB4::DateTime;
use HSDB45::UserGroup;
use HSDB45::Course;
use HSDB4::SQLRow::Content;
use HSDB45::TimePeriod;


# Non-exported package globals go here
use vars ();

#
# File-private lexicals
#
my $tablename         = 'tracking';
my $primary_key_field = 'tracking_id';
my @fields =       qw(tracking_id course_id user_group_id content_id start_date end_date page_views unique_visitors sort_order time_period_id);

my %numeric_fields = (      );
my %blob_fields =    ();
my %cache = ();

sub new {
    #
    # Do the default creation stuff
    #

    # Find out what class we are
    my $class = shift;
    $class = ref $class || $class;
    # Call the super-class's constructor and give it all the values
    my $self = $class->SUPER::new ( _tablename => $tablename,
				    _fields => \@fields,
				    _blob_fields => \%blob_fields,
				    _numeric_fields => \%numeric_fields,
				    _primary_key_field => $primary_key_field,
				    _cache => \%cache,
				    @_);
    # Finish initialization...
    return $self;
}

# This is overloaded to allow the object_selection_box to operate on compound fields from the database.
sub field_value {
    my ($self, $field, $val, $flag) = @_;

	if ( $field eq "full_title" ) {
		return $self->getTrackingTitle() . " [ " . $self->getTrackingInfo() . " ]";
	} elsif ( $field eq "type" ) {
		return $self->getIcon();
	}

	return $self->SUPER::field_value($field, $val, $flag);
}

sub split_by_school {
    my $self = shift;
    return 1;
}

sub getTimePeriodId{
    my $self = shift();
    return $self->field_value('time_period_id');
}

sub getCourseId{
    my $self = shift();
    return $self->field_value('course_id');
}

sub getUserGroupId{
    my $self = shift();
    return $self->field_value('user_group_id');
}

sub getContentId{
    my $self = shift();
    return $self->field_value('content_id');
}

sub getStartDate{
    my $self = shift();
    return $self->field_value('start_date');
}

sub getEndDate{
    my $self = shift();
    return $self->field_value('end_date');
}

sub getPageViews{
    my $self = shift();
    return $self->field_value('page_views');
}

sub getUniqueVisitors{
    my $self = shift();
    return $self->field_value('unique_visitors');
}

sub getUserGroupName{
    my $self = shift();
    if ($self->field_value('user_group_id')){
	my $ug = HSDB45::UserGroup->new(_school=>$self->{_school})->lookup_key($self->field_value('user_group_id'));
	return ($ug->field_value('label'));
    }else{
	my $course = HSDB45::Course->new(_school=>$self->{_school})->lookup_key($self->field_value('course_id'));
	return("All ".$course->field_value('title'));
    }
}

sub isAllDate{
    my $self = shift();
    if ($self->field_value('start_date') eq "1000-01-01" and $self->field_value('end_date') eq "2037-12-31"){
	return 1;
    }else{
	return 0;
    }
}

sub getDateRange{
    my $self = shift();
    if ($self->isAllDate){
	return ("All Dates");
    }else{
	return ($self->field_value('start_date')." to ".$self->field_value('end_date'));
    }
}

sub getContent{
    my $self = shift();
    unless ($self->{_content}){
	$self->{_content} = HSDB4::SQLRow::Content->new()->lookup_key($self->field_value('content_id'));
    }
    return $self->{_content};
}

sub getTrackingTitle{
    my $self = shift();
    if ($self->field_value('content_id')){
	return ($self->getContent->field_value('title'));
    }else{
	return ("Course Homepage");
    }
}

sub getIcon{
    my $self = shift();
    if ($self->field_value('content_id')){
	return ($self->getContent->out_icon);
    }else{
	return ("\&nbsp;");
    }
}

sub getPreview{
    my ($self, $school) = @_;
    if ($self->field_value('content_id')){
	return ("/hsdb4/content/" . $self->field_value('content_id'));
    }else{
	return("/hsdb45/course/" . $school . "/" . $self->field_value('course_id'));
    }

}

sub getTrackingInfo{
    my ($self) = @_;
    my $string = $self->getUserGroupName . "; ";
    $string .= $self->getDateRange;

    return $string;
}

sub calculate{
    my $self = shift;
    my $user = shift;
    my $password = shift;

    my (@results,$sql);

    my $db = HSDB4::Constants::get_school_db($self->{_school});

    if ($self->getContentId){
	if ($self->getUserGroupId){
	    $sql=$self->sqlUserGroupContent($db);
	}else{
	    $sql=$self->sqlCourseContent($db);
	}
    }else{
	if ($self->getUserGroupId){
	    $sql=$self->sqlUserGroupCourse($db);
	}else{
	    $sql=$self->sqlCourseCourse($db);
	}
	
    }

    if ($sql){
	my $sth = HSDB4::Constants::def_db_handle()->prepare($sql);

	$sth->execute();
	@results = $sth->fetchrow_array();
     $sth->finish;
    }else{
	@results = (0, 0);
    }
    $self->set_field_values(page_views => $results[0], unique_visitors => $results[1]);
    my ($rval,$msg) = $self->save($user,$password);
}

sub sqlCourseCourse{
    my $self = shift;
    my $db = shift;
    my @students = HSDB45::Course->new(_school => $self->{_school})->lookup_key($self->getCourseId)->get_students($self->getTimePeriodId);
    return unless @students;

    my $sql = "select count(1), count(distinct l.user_id) 
		 from hsdb4.log_item as l,
			tusk.log_item_type t 
		 where to_days(hit_date) >= to_days('".$self->getStartDate."') and 
		  to_days(hit_date) <= to_days('".$self->getEndDate."') and 
		  t.label = 'Course' and
		  t.log_item_type_id = l.log_item_type_id and
		  l.course_id = '" . $self->getCourseId . "' and
		  l.user_id IN (" . join(', ', map{"'" . $_->primary_key . "'"} @students) . ")";
    return $sql;
}
sub sqlUserGroupCourse{
    my $self = shift;
    my $db = shift;
     my $sql = "select count(1), count(distinct l.user_id) 
		 from hsdb4.log_item as l,  
		tusk.log_item_type t,
		$db\.link_user_group_user as uu 
		 where to_days(hit_date) >= to_days('".$self->getStartDate."') and 
		  to_days(hit_date) <= to_days('".$self->getEndDate."') and 
		  t.label = 'Course' and
		  t.log_item_type_id = l.log_item_type_id and
		  l.course_id = '".$self->getCourseId."' and
		  uu.parent_user_group_id = '".$self->getUserGroupId."' and
		  l.user_id = uu.child_user_id";
    return $sql;
}

sub sqlCourseContent{
    my $self = shift;
    my $db = shift;
    my @students = HSDB45::Course->new(_school => $self->{_school})->lookup_key($self->getCourseId)->get_students($self->getTimePeriodId);
    return unless @students;

    my $sql = "select count(1), count(distinct l.user_id) 
		 from hsdb4.log_item as l ,
			tusk.log_item_type t
		 where to_days(hit_date) >= to_days('".$self->getStartDate."') and 
		  to_days(hit_date) <= to_days('".$self->getEndDate."') and 
		  t.label = 'Content' and
		  l.log_item_type_id = t.log_item_type_id and
		  l.content_id = '" . $self->getContentId . "' and
                  l.user_id IN (" . join(', ', map{"'" . $_->primary_key . "'"} @students) . ")";
    
    return $sql;
}

sub sqlUserGroupContent{
    my $self = shift;
    my $db = shift;
    my $sql = "select count(1), count(distinct l.user_id) 
		 from hsdb4.log_item as l,  
			$db\.link_user_group_user as uu ,
			tusk.log_item_type t
		 where to_days(hit_date) >= to_days('".$self->getStartDate."') and 
		  to_days(hit_date) <= to_days('".$self->getEndDate."') and 
		  t.label = 'Content' and
		  l.log_item_type_id = t.log_item_type_id and
		  l.course_id = '".$self->getCourseId."' and
		  l.content_id = '".$self->getContentId."' and
		  uu.parent_user_group_id = '".$self->getUserGroupId."' and
		  l.user_id = uu.child_user_id";
    return $sql;
}

1;
