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


package HSDB45::Course;

use strict;

BEGIN {
    use vars qw($VERSION @non_blob_fields %primary_keys);
    use base qw/HSDB4::SQLRow/;
    
    $VERSION = do { my @r = (q$Revision: 1.152 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
}

sub version {
    return $VERSION;
}

use HSDB4::Constants qw(:school);
use TUSK::Constants;
use Carp;

require HSDB4::SQLRow::Content;
require HSDB4::SQLRow::PersonalContent;
require HSDB4::SQLRow::Objective;
require HSDB45::ClassMeeting;
require HSDB45::UserGroup;
require TUSK::Core::HSDB4Tables::User;
require TUSK::Application::Course::User;

use HSDB4::SQLRow::User;
use HSDB45::Course::Body;
use TUSK::Core::School;
use TUSK::Core::CourseCode;
use TUSK::FormBuilder::Form;
use TUSK::Course;
use TUSK::Course::User;
use TUSK::Course::CourseMetadata;
use TUSK::Course::CourseMetadataDisplay;
use TUSK::Course::CourseSharing;
use TUSK::Core::LinkCourseCourse;
use HSDB45::TeachingSite;
use HSDB4::SQLLink;
use TUSK::Application::HTML::Strip;


# File-private lexicals
my $tablename = "course";
my $primary_key_field = "course_id";
my @fields = qw(course_id title oea_code color abbreviation 
		associate_users type course_source modified body rss);
@non_blob_fields= qw(course_id title oea_code color abbreviation associate_users modified rss);
my %primary_keys=(course_id=>1);
my %blob_fields = (body => 1);
my %numeric_fields = ();

my %cache = ();

# dependencies for things that relate to caching
my @mod_deps  = ('HSDB4::SQLRow::Content',
		 'HSDB4::SQLRow::PersonalContent',
		 'HSDB45::ClassMeeting',
		 'HSDB45::UserGroup',
		 'HSDB45::Course::Body');
my @file_deps;

sub get_mod_deps {
    return @mod_deps;
}

sub get_file_deps {
    return @file_deps;
}


#######################################################

=item B<save>

($returnValue, $message) = $obj->save();

This is an overload of the save function.
It save the course and then also creates a TUSK course.

=cut

sub save {
    my $self = shift;
    my $user = shift;
    my $addTuskCourse = 0;
    my $rval;
    my $msg;

    #start by saving myself.
    unless($self->primary_key()) {$addTuskCourse = 1;}
    ($rval, $msg) = $self->SUPER::save($TUSK::Constants::DatabaseUsers{ContentManager}->{readusername},$TUSK::Constants::DatabaseUsers{ContentManager}->{readpassword});

    if($msg) {return ($rval, $msg);}

    if($addTuskCourse) {
      my $tuskCoursePK;
      # Create the new TUSK course for this course.
      my $tuskCourse = TUSK::Course->new();
      # We can use this to record what user is creating the course if we wanted to.
      # $tuskCourse->setUser();
      $tuskCourse->setSchoolID(  TUSK::Core::School->getSchoolID($self->school())  );
      $tuskCourse->setSchoolCourseCode($self->primary_key());
      ($tuskCoursePK) = $tuskCourse->save({ user => $user });
      if(!$tuskCoursePK) {
        $rval = $self->delete($TUSK::Constants::DatabaseUsers{ContentManager}->{readusername},$TUSK::Constants::DatabaseUsers{ContentManager}->{readpassword});
        if($rval) {return (-1, "Unable to save TUSK Course");}
        else      {return (-2, "Unable to add TUSk Course, Failed to delete HSDB Course! Please call for help!");}
      }
    }

    return ($rval, $msg);
}

#######################################################

=item B<getSchoolMetadata>

$hashRef = $obj->getSchoolMetadata($value);

Get a hash reference that represent what the school has chosen for display data.
The hash looks like:
$hash{metadataOrder} = ["Item1", "Item2", "Item3"];
$hash{<metadataID>}{displayName} = "Grading And Evulation";
$hash{<metadataID>}{editType} = "List";
$hash{<metadataID>}{children} = %anotherHashJustLikeThisOne;
This is done my implementing getMetadataDisplayHash from CourseMetadataDisplay

=cut

sub getSchoolMetadata{
    my ($self) = @_;
    
    my %returnHash;
    my $schoolMetadataDisplay = TUSK::Course::CourseMetadataDisplay->new();
    $schoolMetadataDisplay->getMetadataDisplayHash($self->get_school()->getPrimaryKeyID(), \%returnHash);
    foreach my $metadataIDNumber (keys %returnHash) {
	unless($metadataIDNumber eq 'metadataOrder') {
		my $condition = "metadata_type=$metadataIDNumber AND course_id=" . $self->getTuskCourseID();
		$returnHash{$metadataIDNumber}{numberOfItems} = $#{$self->metadata->lookup($condition, undef, undef, undef)}+1;
	}
    }
    return (\%returnHash);
}

#######################################################

=item B<getCourseMetadataByType>

@values = $obj->getCourseMetadataByType($tuskCourseID, $metadataType, $parent, $order_by);

returns an array ref of objects values for those types of data.

=cut

sub getCourseMetadataByType{
    my ($self, $tuskCourseID, $metadataType, $parent, $order_by) = @_;
    
    my $condition = "course_id=$tuskCourseID";
    if($metadataType =~ /,/) {$condition .= " AND metadata_type IN ($metadataType)";}
    else                     {$condition .= " AND metadata_type=$metadataType";}
    if($parent) {
      if($parent =~ /,/) {$condition .= " AND parent IN ($parent)";}
      else               {$condition .= " AND parent=$parent";}
    }
    return($self->metadata->lookup($condition, $order_by, undef, undef));
}



#######################################################

=item B<printCourseMetadataTable>

$obj->printCourseMetadataTable($hashRefToCourseMetadataTable);

Prints an html table for course metadata table type.

=cut

sub printCourseMetadataTable{
    my ($self, $hashRefToCourseMetadataTable) = @_;
    my $table = '';
    my $rowCounter = 0;
    $table .= "<table border=\"0\" cellpadding=\"5\" cellspacing=\"0\">\n";
    foreach my $tableRow (sort keys %{ ${$hashRefToCourseMetadataTable}{children} }) {
      unless($tableRow eq 'metadataOrder') {
        $table .= "<tr>\n";
        my $rowHash = \%{ ${$hashRefToCourseMetadataTable}{children}{$tableRow} };
        my $tableCells = '';
        foreach my $column (@{ ${$rowHash}{children}{metadataOrder} }) {
          $table .= "<td style=\"border-bottom:1px solid black;\" valign=\"bottom\"><b>${$rowHash}{children}{$column}{displayName}</b></td>\n";
          $tableCells.= "$column, ";
        }
        $table .= "</tr>\n";
        $tableCells =~ s/, $//;
        my %tableRows;
        foreach (@{$self->getCourseMetadataByType($self->getTuskCourseID(), $tableCells, undef, undef)}) {
          $tableRows{ $_->getFieldValue('parent') }{ $_->getFieldValue('metadata_type') } = $_->getFieldValue('value');
        }
        foreach my $tableDataRow (sort keys %tableRows) {
          $table .= "<tr onMouseOver=\"this.style.backgroundColor='lightgrey';\" onMouseOut=\"this.style.backgroundColor='';\">\n";
          foreach my $column (@{ ${$rowHash}{children}{metadataOrder} }) {
            $tableRows{$tableDataRow}{$column} ||= "&nbsp;";
            if((${$rowHash}{children}{$column}{displayName} =~ /url/i) && ($tableRows{$tableDataRow}{$column} ne '&nbsp;')) {
              $table .= "<td style=\"border-bottom:1px solid lightgrey;\"><a href=\"$tableRows{$tableDataRow}{$column}\">$tableRows{$tableDataRow}{$column}</a></td>\n";
            } else {
              $table .= "<td style=\"border-bottom:1px solid lightgrey;\">$tableRows{$tableDataRow}{$column}</td>\n";
            }
          }
          $table .= "</tr>\n";
          $rowCounter++;
        }
      }
    }
    $table .= "</table>\n";

    if($rowCounter > 0) {print $table;}
    else {
      print "<table width=\"100%\" height=\"100%\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\">\n";
      print "  <tr><td align=\"center\" valign=\"middle\">None</td></tr>\n";
      print "</table>\n";
    }
}

#######################################################

=item B<printCourseMetadataList>

$obj->printCourseMetadataList($hashRefToCourseMetadataTable);

Prints an html list for course metadata list type.

=cut

sub printCourseMetadataList{
    my ($self, $hashRefToCourseMetadataList) = @_;

    print "<ul>";
    my @bullets = @{ ${$hashRefToCourseMetadataList}{children}{metadataOrder} };
    my $printCategories = 0;
    my $lastBulletWasATable = 0;
    if($#bullets > 0) {$printCategories = 1;}

    foreach my $bulletOrder (@{ ${$hashRefToCourseMetadataList}{children}{metadataOrder} }) {
      if(${$hashRefToCourseMetadataList}{children}{$bulletOrder}{editType} ne 'table') {
        foreach (@{$self->getCourseMetadataByType($self->getTuskCourseID(), $bulletOrder, undef, undef)}) {
          if($lastBulletWasATable) {print "<li style=\"padding-top:30px;\">";}
          else                     {print "<li>";}
          if($printCategories) {print "<b>${$hashRefToCourseMetadataList}{children}{$bulletOrder}{displayName}</b><br>";}
          print $_->getFieldValue('value');
          print "</li>";
          $lastBulletWasATable = 0;
        }
      }
      else {
        print "<li>";
        if($printCategories) {print "<b>${$hashRefToCourseMetadataList}{children}{$bulletOrder}{displayName}</b><br>";}
        $self->printCourseMetadataTable(${$hashRefToCourseMetadataList}{children}{$bulletOrder});
        print "</li>";
        $lastBulletWasATable = 1;
      }
    }
    print "</ul>";
}



sub metadata {
  my $self = shift;

  unless($self->{_metadata}) {
    #Create the metadata object using the courseID
    $self->{_metadata} = TUSK::Course::CourseMetadata->new();
  }
  return $self->{_metadata};
}

sub getShares {
        #Returns an array of shares for a course
        my $self = shift;
        unless($self->{_shares}) {
                #Get the shares from the TUSK::Course object
                $self->{_shares} = TUSK::Course::CourseSharing->new()->lookup("course_id='" . $self->getTuskCourseID() . "'");
        }
        return $self->{_shares};
}


sub getTuskCourseID {
  my $self = shift;

  unless($self->{_tuskCourseNumber}) {
    #get the courseID from the tusk.course dabase.
    my $tuskCourse = TUSK::Course->new();
    $self->{_tuskCourseNumber} = $tuskCourse->getTuskCourseIDFromSchoolID($self->get_school()->getPrimaryKeyID(), $self->primary_key());
  }
  return $self->{_tuskCourseNumber};
}


# Creation methods

sub new {
    # Find out what class we are
    my $incoming = shift;
    # Call the super-class's constructor and give it all the values
    my $self = $incoming->SUPER::new ( _tablename => $tablename,
				       _fields => \@fields,
				       _blob_fields => \%blob_fields,
				       _numeric_fields => \%numeric_fields,
				       _primary_key_field => $primary_key_field,
				       _cache => \%cache,
				       @_);
    # Finish initialization...
    return $self;
}


# these two functions are used to temp store a timeperiod_id with a particular course
sub setTimePeriod{
    my ($self, $tp) = @_;
    $self->{_saved_time_period} = $tp;
}

sub getTimePeriod{
    my ($self) = @_;
    return $self->{_saved_time_period};
}

sub announcement_link {
    my $self = shift();
    my $db = HSDB4::Constants::get_school_db($self->school());
    return $HSDB4::SQLLinkDefinition::LinkDefs{"$db\.link_course_announcement"};
}

sub add_announcement {
    my $self = shift();
    my ($username, $password, $announcement_id) = @_;

    my ($r, $msg) = $self->announcement_link()->insert(-user => $username,
						       -password => $password,
						       -parent_id => $self->primary_key(),
						       -child_id => $announcement_id);
    return ($r, $msg);
}

sub remove_announcement {
    my $self = shift();
    my ($username, $password, $announcement_id) = @_;

    my ($r, $msg) = $self->announcement_link()->delete(-user => $username,
						       -password => $password,
						       -parent_id => $self->primary_key(),
						       -child_id => $announcement_id);
    return ($r, $msg);
}

sub announcements { # namely, unexpired ones
    my $self = shift;

	unless ( $self->{-current_ann} ) {
		my @ann = grep { $_->current() } $self->announcement_link()->get_children($self->primary_key)->children();
		$self->{-current_ann} = \@ann;
	}

    return @{$self->{-current_ann}};
}

sub all_announcements { # notably, including expired ones
    my $self = shift;

    return $self->announcement_link()->get_children($self->primary_key)->children();
}

sub body {
    my $self = shift();
    unless($self->{-body}) { $self->{-body} = HSDB45::Course::Body->new($self) }
    return $self->{-body};
}

sub course_id {
    my $self = shift();
    return $self->field_value('course_id');
}

sub registrar_code {
    my $self = shift();
    return $self->field_value('oea_code');
}

sub oea_code {
    my $self = shift();
    return $self->field_value('oea_code');
}

sub type {
    my $self = shift;
    return $self->field_value('type');
}

sub split_by_school {
    my $self = shift;
    return 1;
}

sub get_school {
	my $self = shift;
	my $cond = sprintf (" lower(school_name) = lower('%s') ",$self->school);
	my $school = pop @{TUSK::Core::School->lookup($cond)};
	return $school;
}


#
# >>>>> Linked objects <<<<<
#
###  Used for customization of default display of forms
my $current_user = '';
sub set_current_user {
    my $self = shift();
    $current_user = shift();
}

sub course_link {
    #
    # Return the HSDB4::SQLLinkDefinition for link_course_course
    #
    my $self = shift;
    my $db = $self->school_db();
    return $HSDB4::SQLLinkDefinition::LinkDefs{"$db\.link_course_course"};
}

sub parent_courses {
    #
    # Return the courses this course is linked to (using link_course_course)
    #

    my $self = shift;
    # Check the cache...
    unless ($self->{-parent_courses}) {
        # And use it to get a LinkSet, if possible
        $self->{-parent_courses} = $self->course_link()->get_parents($self->primary_key);
    }
    # Return the list
    return $self->{-parent_courses}->parents();
}


sub child_courses {
    #
    # Get the course linked down from this course (using link_course_course)
    #

    my $self = shift;
    # Check cache...
    unless ($self->{-child_courses}) {
        # And use it to get a LinkSet of users
        $self->{-child_courses} = $self->course_link()->get_children($self->primary_key);
    }
    # Return the list
    return $self->{-child_courses}->children();
}
 
sub objective_link {
    #
    # Get the HSDB4::SQLLinkDefinition for school-specific link_course_objective
    #
    my $self = shift;
    my $db = $self->school_db();
    return $HSDB4::SQLLinkDefinition::LinkDefs{"$db\.link_course_objective"};
}

sub child_topics {
    #
    # Get the objectives linked down from this course (from link_course_objective)
    #

    my $self = shift;
    # Get the link definition
    # And use it to get and return a LinkSet of users
    unless ($self->{-child_topics}) {
	$self->{-child_topics} = 
	    $self->objective_link()->get_children($self->primary_key);
    }
    return $self->{-child_topics}->children();
}

sub delete_objectives{
    my $self = shift;
    my ($u, $p) = @_;
    # Get the link definition

    my ($r,$msg) = $self->objective_link()->delete_children(-user => $u, -password => $p,
					     -parent_id => $self->primary_key,
					     );
    return ($r,$msg);   
}


sub add_child_objective{
    #
    # These are objectives that define the purpose of the course,
    # so the course is the parent of the objective. 
    #
        
    my $self = shift;
    my ($u,$p,$objective_id, $sort_order) = @_;
    
    my ($r,$msg) = $self->objective_link()->insert(-user => $u, -password => $p,
				    -parent_id => $self->primary_key,
				    -child_id => $objective_id,
				    sort_order => $sort_order);
    return ($r,$msg);
}

sub update_objectives{
    my ($self, $array) = @_;
    my ($rval, $msg);
    ($rval, $msg) = $self->delete_objectives($TUSK::Constants::DatabaseUsers{ContentManager}->{readusername}, $TUSK::Constants::DatabaseUsers{ContentManager}->{readpassword});
    return (0,$msg) unless (defined($rval));
    return (1) unless $array;
    if (scalar @$array){
	my $sort=10;
	for(my $i=0; $i<scalar(@$array); $i++){
	    unless (@$array[$i]->{pk}){
		my $objective = HSDB4::SQLRow::Objective->new;
		
		$objective->set_field_values(body => @$array[$i]->{body});
		
		($rval, $msg) = $objective->save($TUSK::Constants::DatabaseUsers{ContentManager}->{readusername}, $TUSK::Constants::DatabaseUsers{ContentManager}->{readpassword});
		return (0, $msg) unless ($rval > 0);
		
		@$array[$i]->{pk} = $objective->primary_key;
	    }elsif (@$array[$i]->{elementchanged} == '1'){
		my $objective = HSDB4::SQLRow::Objective->new->lookup_key(@$array[$i]->{pk});
		
		$objective->set_field_values(body => @$array[$i]->{body});
		
		($rval, $msg) = $objective->save($TUSK::Constants::DatabaseUsers{ContentManager}->{readusername}, $TUSK::Constants::DatabaseUsers{ContentManager}->{readpassword});
		return (0, $msg) unless ($rval > 0);
	    }
	    
	    ($rval, $msg) = $self->add_child_objective($TUSK::Constants::DatabaseUsers{ContentManager}->{readusername}, $TUSK::Constants::DatabaseUsers{ContentManager}->{readpassword}, @$array[$i]->{pk}, ($i+10));	
	    
	    return (0, $msg) unless (defined($rval));
	}
    }
}

sub child_objectives {
    #
    # Alias for link_course_topics
    #
    my $self = shift;
    return $self->child_topics();
}

sub personal_content_link {
    my $self = shift;
    my $db = $self->school_db();
    return $HSDB4::SQLLinkDefinition::LinkDefs{"$db\.link_course_personal_content"};
}

sub child_personal_content {
    #
    # Get the personal_content linked down from this course
    #

    my $self = shift;
    # Check cache...
    unless ($self->{-child_personal_content}) {
        # And use it to get a LinkSet of users
        $self->{-child_personal_content} = 
	    $self->personal_content_link()->get_children($self->primary_key);
    }
    # Return the list
    return $self->{-child_personal_content}->children();
}

sub student_link {
    my $self = shift;
    my $db = $self->school_db();
    return $HSDB4::SQLLinkDefinition::LinkDefs{"$db\.link_course_student"};
}

sub email_students{
    my ($self, $subject, $email_from, $time_period_id, $message) = @_;

    $time_period_id = $self->get_current_timeperiod() unless ($time_period_id);

    my @students = $self->get_students($time_period_id);

    foreach my $child_user (@students){
	$child_user->send_email_from($email_from);
	$child_user->send_email($subject, $message);
    }
}


#######################################################

=item B<get_current_and_future_time_periods>

    $timeperiods = $course->get_current_and_future_time_periods();

	Returns an array of all ongoing and future timeperiods in this course's school. 
	Optionally, return ONLY ongoing timeperiods.

=cut

sub get_current_and_future_time_periods{
	my ($self, $only_current_timeperiods) = @_;
	my @tp_ids;
	my $only_current_clause = $only_current_timeperiods ? "and start_date <= curdate()" : ""; 

    my $dbh = HSDB4::Constants::def_db_handle;
    my $db = $self->school_db();

    my $sql = "select time_period_id from $db\.time_period where end_date >= curdate() " . $only_current_clause;
    eval {
	my $sth = $dbh->prepare ($sql);
	$sth->execute ();
	while (my ($tp_id) = $sth->fetchrow_array()) {
	    push (@tp_ids, $tp_id);
	}
     $sth->finish;
    };

	if (scalar(@tp_ids)){
	    @{$self->{-current_and_future_time_periods}} = HSDB45::TimePeriod->new( _school => $self->school() )->lookup_conditions("time_period_id IN (" . join(", ", @tp_ids) . ") order by start_date, end_date");
	}

	return ($self->{-current_and_future_time_periods});
}


#######################################################

=item B<get_time_periods_for_enrollment>

    $timeperiods = $course->get_time_periods_for_enrollment();

	Returns an array of all timeperiods associated with this course. 

=cut

sub get_time_periods_for_enrollment{
    my ($self) = @_;

    unless ($self->{-time_periods_for_enrollment}){
	$self->{-time_periods_for_enrollment} = [];
	my $dbh = HSDB4::Constants::def_db_handle;
	my $db = $self->school_db();
	my $sql = qq[select time_period_id from $db\.link_course_student where parent_course_id = ? group by time_period_id];
	
	eval {
	    my $sth = $dbh->prepare ($sql);
	    $sth->execute ($self->primary_key());
	    while (my ($tp_id) = $sth->fetchrow_array()) {
		push (@{$self->{-time_periods_for_enrollment}}, $tp_id) if ($tp_id);
	    }
         $sth->finish;
	};
	confess $@, return if $@;

    }

    return (@{$self->{-time_periods_for_enrollment}});
}

#######################################################

=item B<get_time_periods>

    $timeperiods = $course->get_time_periods();

	If this course's enrollment is managed by user groups, return an array of the timeperiods for each associated
	group. Otherwise, return an array of all timeperiods associated with this course that are also ongoing.

=cut
sub get_time_periods{
    my ($self) = @_;
    my (@tp_ids, %checkperiod);
    my $time_periods;

    unless ($self->{-time_periods}){
	if ($self->associate_user_group){
	    my @user_groups = $self->user_group_link()->get_children($self->primary_key,"sub_group='No'")->children();
	    
	    foreach my $group (@user_groups){
		my $tp_id = $group->aux_info('time_period_id');
		push (@tp_ids, $tp_id) if ($tp_id);
	    }
	    
	}else{
	    my $timeperiod_sql = "";
	    @tp_ids = $self->get_time_periods_for_enrollment();

	    if (scalar(@tp_ids)){
		$timeperiod_sql = "or time_period_id IN (" . join(", ", @tp_ids) . ")";
	    }

	    my $dbh = HSDB4::Constants::def_db_handle;
	    my $db = $self->school_db();
	    my $sql = "select time_period_id from $db\.time_period where (start_date <= curdate() and end_date >= curdate()) $timeperiod_sql";

	    eval {
		my $sth = $dbh->prepare ($sql);
		$sth->execute ();
		@tp_ids = ();
		while (my ($tp_id) = $sth->fetchrow_array()) {
		    push (@tp_ids, $tp_id);
		}
		$sth->finish;
	    };
	    confess $@, return if $@;
	}

	if (scalar(@tp_ids)){
	    @{$time_periods} = HSDB45::TimePeriod->new( _school => $self->school() )->lookup_conditions("time_period_id IN (" . join(", ", @tp_ids) . ") order by start_date desc, end_date desc");
	}

    }
    return $time_periods;
}

=item <B><get_universal_time_periods>
    We now have time periods in both link_course_student and tusk.course_user
    Return a list of time period objects for both link_course_student and tusk.course_user
=cut

sub get_universal_time_periods {
    my $self = shift;
    my $dbh = HSDB4::Constants::def_db_handle;
    my $db = $self->school_db();
    my $course_id = $self->primary_key();
    my $school_id = $self->school_id();
    my $sql = qq(
		 SELECT distinct time_period_id 
		 FROM $db.link_course_student 
		 WHERE parent_course_id = $course_id
		 UNION
		 SELECT distinct time_period_id 
		 FROM tusk.course_user 
		 WHERE course_id = $course_id AND school_id = $school_id
		 UNION
		 SELECT time_period_id 
		 FROM $db\.time_period 
		 WHERE (start_date <= curdate() and end_date >= curdate())
		 );
    my @tp_ids = ();    
    eval {
	my $sth = $dbh->prepare ($sql);
	$sth->execute();

	while (my ($tp_id) = $sth->fetchrow_array()) {
	    push (@tp_ids, $tp_id);
	}
        $sth->finish();
    };
    confess $@, return if $@;

    return (scalar @tp_ids) 
	? [ HSDB45::TimePeriod->new( _school => $self->school() )->lookup_conditions("time_period_id IN (" . join(", ", @tp_ids) . ") order by start_date desc, end_date desc") ]
	: [];
}

########################################################

=item B<get_current_timeperiod>

    $timeperiods = $course->get_current_timeperiod();

	Return the time period associated with this course which starts and ends most recently. 

=cut

sub get_current_timeperiod{
    my ($self) = @_;
    my @tp_ids;
 
    unless ($self->{-current_timeperiod}){
	    my $timeperiods = $self->get_time_periods();
		$self->{-current_timeperiod} = 0;
		if ($timeperiods and scalar(@$timeperiods)){
			    foreach my $tp (@$timeperiods){
					push (@tp_ids, $tp->primary_key);
			    }
		
			    my @non_past_tps = HSDB45::TimePeriod->new( _school => $self->school() )->lookup_conditions("time_period_id in (" . join(',', @tp_ids) . ") and start_date <= curdate() and end_date >= curdate()", "ORDER BY start_date DESC, end_date ASC");
		
			    if (!$self->associate_user_group() and scalar(@non_past_tps) > 1){
					my @enrollment_time_periods = $self->get_time_periods_for_enrollment();
					my %enrollment_tp_hash = map {$_ => 1} @enrollment_time_periods;
		
					foreach my $np_tp (@non_past_tps){
				    	if ($enrollment_tp_hash{$np_tp->primary_key()}){
							$self->{-current_timeperiod} = $np_tp;
							last;
				    	}
					}
			    }
		
			    if (scalar(@non_past_tps) and !$self->{-current_timeperiod}){
					$self->{-current_timeperiod} = $non_past_tps[0]; # we want the last time period
			    }
			}
	    }

    return ($self->{-current_timeperiod});
}

########################################################

=item B<get_users_current_timeperiod>

    $timeperiod = $course->get_users_current_timeperiod($user);

	Return the most recent time period in which a student is linked
	to this course.

=cut

sub get_users_current_timeperiod{ 
	my ($self, $user) = @_;	
    my $timeperiods = $self->get_time_periods();
	my ($tp, $tp_id);

    my $dbh = HSDB4::Constants::def_db_handle;
    my $db = $self->school_db();
	my $sql = "select lcs.time_period_id from $db.link_course_student lcs join $db.time_period tp on lcs.time_period_id = tp.time_period_id where parent_course_id = " . $self->primary_key() . " and child_user_id = '$user' and start_date <= curdate() and end_date >= curdate() order by start_date desc";
	
	eval {
		my $sth = $dbh->prepare($sql);
		$sth->execute();
		($tp_id) = $sth->fetchrow_array();
		$sth->finish;
	};

	if ( $tp_id ) {
		($tp) = HSDB45::TimePeriod->new( _school => $self->school() )->lookup_conditions("time_period_id = $tp_id");
	}

	return $tp;
}


########################################################

=item B<get_users_active_timeperiods>

    $timeperiods = $course->get_users_active_timeperiods($user);

	Find all ongoing timeperiods in which a user is enrolled in this course.
	Returns an arrayref of HSDB45::TimePeriod objects.

=cut

sub get_users_active_timeperiods {
	my ($self, $user) = @_;
	my $dbh = HSDB4::Constants::def_db_handle;
	my $db = $self->school_db();

	#Get all currently ongoing timeperiods for this course.
	my $only_current_timeperiods = 1;
	my $ongoing_tps = $self->get_current_and_future_time_periods($only_current_timeperiods);
	my %ongoing_tp_hash;	
	map { $ongoing_tp_hash{$_->primary_key()} = 1 } @$ongoing_tps;

	#Then, compare ongoing timeperiods to timeperiods in which the student is enrolled, taking
	#the union of these two lists (i.e. only current timeperiods in which the student is enrolled).
	my %enrolled_tps;  
	my $sql = "select lcs.time_period_id from $db.link_course_student lcs join $db.time_period tp on lcs.time_period_id = tp.time_period_id where parent_course_id = " . $self->primary_key() . " and child_user_id = '$user'";

	eval {
		my $sth = $dbh->prepare($sql);
		$sth->execute();
		my $result;
		while ($result = $sth->fetchrow_arrayref()) {
			$enrolled_tps{$result->[0]} = 1;
		}
		$sth->finish;
	};
	
	foreach my $ongoing_tp (keys(%ongoing_tp_hash)) {
		#Ignore this timeperiod if the user is not enrolled in it.
		unless ($enrolled_tps{$ongoing_tp}) {
			delete $ongoing_tp_hash{$ongoing_tp}; 
			next;
		}
		$ongoing_tp_hash{$ongoing_tp} = HSDB45::TimePeriod->new( _school => $self->school())->lookup_key($ongoing_tp);
	}
	my @active_timeperiods_for_user = values(%ongoing_tp_hash);
	return \@active_timeperiods_for_user;
}


### this will get the last element of time periods that is linked to the course.
### therefore, it could be future or past time period
sub get_most_recent_timeperiod {
	my $self = shift;
	my @tp_ids = $self->get_time_periods_for_enrollment();
	if (@tp_ids) {
		my @time_periods = HSDB45::TimePeriod->new( _school => $self->school())->lookup_conditions("time_period_id IN (" . join(", ", @tp_ids) . ") order by start_date, end_date");
		if (my $num = scalar @time_periods) {
			return $time_periods[$num-1];
		}
	}
	return undef;
}

########################################################

=item B<get_users_timeperiods>

    $timeperiods = $course->get_users_timeperiods($user);

	Find all ongoing timeperiods in which a faculty/staff is assigned in this course.
	Returns an arrayref of HSDB45::TimePeriod objects.

=cut

sub get_users_time_periods {
	my ($self) = @_;
	my $dbh = HSDB4::Constants::def_db_handle;
	my $db = $self->school_db();

	my $sql = "select time_period_id, count(*) from tusk.course_user where course_id = " . $self->primary_key() . " AND school_id = " . $self->school_id() . " group by time_period_id";

	my (@tp_ids, %cnts);
	eval {
		my $sth = $dbh->prepare($sql);
		$sth->execute();
		while (my ($tp_id, $cnt) = $sth->fetchrow_array()) {
		    push @tp_ids, $tp_id;
		    $cnts{$tp_id} = $cnt;
		}
		$sth->finish();
	};
	confess "Problem getting data" if @$;

	return (scalar @tp_ids) 
	    ? ([HSDB45::TimePeriod->new( _school => $self->school())->lookup_conditions("time_period_id in (" . join(', ', @tp_ids) . ') order by end_date desc, start_date desc')], \%cnts)
	    : ([], {});
}



sub get_students {
    #
    # Get the students from this course (either from link_course_student or link_user_group_user)
    # with no time period (uses the current), single time period, or ref to an array of time periods
    # students from multiple time periods will be returned sorted alphabetically by last name
    #
    my ($self, $timeperiod_id, $site_id) = @_;
    my @students;
    
    if (!$timeperiod_id){
		my $tp = $self->get_current_timeperiod;
		return unless ($tp);
		$timeperiod_id = $tp->primary_key;
    }
    
	my $site_condition = (defined $site_id) ? "AND teaching_site_id = $site_id" : '';
    
    if (ref($timeperiod_id) eq 'ARRAY') {
		@students = sort { $a->{lastname} cmp $b->{lastname} } $self->student_link()->get_children($self->primary_key,"time_period_id IN(" . join(",", @$timeperiod_id) . ") $site_condition GROUP BY user_id")->children();
    }
    else {
		@students = $self->student_link()->get_children($self->primary_key,"time_period_id = $timeperiod_id $site_condition")->children();
    }
	
	return @students;
}

sub get_single_student {
    #
    # Gets the details of a single student link
    #
    my ($self, $user_id, $timeperiod_id) = @_;

    return "" unless ($user_id);
    
    my @students = $self->student_link()->get_children($self->primary_key,"time_period_id = $timeperiod_id and child_user_id = '$user_id'")->children();
	
    return $students[0];
}


sub get_student_site {
    my ($self, $student_id, $timeperiod_id) = @_;

    my $dbh = HSDB4::Constants::def_db_handle;
    my $db = $self->school_db();
    my $ts_id = undef;

    eval {
	$ts_id = $dbh->selectrow_array("select teaching_site_id from $db\.link_course_student where parent_course_id = " . $self->primary_key() . " and child_user_id = '$student_id' and time_period_id = $timeperiod_id");
    };

    if ($@) {
	confess $@, return;
    } else {
	return HSDB45::TeachingSite->new(_school => $self->school())->lookup_key($ts_id);
    }
}


=item <B><users>
    All users for a given time period
=cut

sub users {
    my ($self, $time_period_id, $conditions, $sort_orders) = @_;
    confess "missing time period id" unless defined $time_period_id;

    $sort_orders = ['course_user.sort_order', 'lastname', 'firstname'] unless defined $sort_orders;

    return $self->find_users($conditions, $sort_orders, $time_period_id);
}


=item <B><user_primary_role
  Parmeter: user_id
  Return: a user permission_role object if exists, else undef
=cut

sub user_primary_role {
    my ($self, $user_id) = @_;
    my $users = $self->find_users("course_user.user_id = '$user_id'");
    return (scalar @$users) ? $users->[0]->getRole() : undef;
}


=item <B><users_by_period>
    All users grouped by time period
=cut

sub users_by_period {
    my ($self, $conditions, $sort_orders) = @_;
    $sort_orders = ['course_user.time_period_id', 'course_user.sort_order', 'lastname', 'firstname'] unless defined $sort_orders;

    my $users = $self->find_users($conditions, $sort_orders);
    my %users = ();
    push @{$users{$_->getCourseUser()->getTimePeriodID()}}, $_ foreach (@$users);
    return \%users;
}

=item
    All users from all time periods with unique roles, sites. 

  Return:  
    A reference to an array of user structs  
{
    user => TUSK::Core::HSDB4Tables::User, 
    roles => { role_token => TUSK::Permission::Role }, 
    sites => { site_id => TUSK::Core::HSDB4Tables::TeachingSite }
}
=cut

sub unique_users {
    my ($self, $conditions, $sort_orders) = @_;
    $sort_orders = ['lastname', 'firstname', 'course_user.user_id'] unless defined $sort_orders;

    my $users = $self->find_users($conditions, $sort_orders);
    my %unique_users = ();

    foreach my $user (@$users) {
	my $user_id = $user->getPrimaryKeyID();
	foreach my $role (@{$user->getRoleLabels()}) {
	    if (ref $role eq 'TUSK::Permission::Role') {
		$unique_users{$user_id}{roles}{$role->getRoleToken()} = $role;
	    }
	}
	foreach my $site (@{$user->getSites()}) {
	    if (ref $site eq 'TUSK::Core::HSDBTables::TeachingSite') {
		$unique_users{$user_id}{sites}{$site->getPrimaryKeyID()} = $site;
	    }
	}

	unless (exists $unique_users{$user_id}{user}) {
	    $user->{'_join_objects'} = {};   ## try to be a slimmer user object as we already keep the data as above
	    $unique_users{$user_id}{user} = $user;
	}
    }

    return [ values %unique_users ];
}


=item
    Generic method to get a list of users
=cut
sub find_users {
    my ($self, $conditions, $sort_orders, $tp_id) = @_;
    my $school = $self->get_school() or confess "missing school object";
    return TUSK::Core::HSDB4Tables::User->lookup($conditions, $sort_orders, undef, undef, [
		   TUSK::Core::JoinObject->new('TUSK::Course::User', { joinkey => 'user_id', jointype => 'inner', joincond =>"course_id = " . $self->primary_key() . " AND school_id = " . $school->getPrimaryKeyID() . ((defined $tp_id) ? " AND time_period_id = $tp_id" : '') }),
		   TUSK::Core::JoinObject->new('TUSK::Course::User::Site', { joinkey => 'course_user_id', origkey => 'course_user.course_user_id' }),
		   TUSK::Core::JoinObject->new('TUSK::Core::HSDB45Tables::TeachingSite', { database => $school->getSchoolDb(), joinkey => 'teaching_site_id', origkey => 'course_user_site.teaching_site_id' }),
		   TUSK::Core::JoinObject->new('TUSK::Permission::UserRole', { joinkey => 'feature_id', origkey => 'course_user.course_user_id' }),		
		   TUSK::Core::JoinObject->new('TUSK::Permission::Role', { joinkey => 'role_id', origkey => 'permission_user_role.role_id' }),
		   TUSK::Core::JoinObject->new('TUSK::Permission::FeatureType', { joinkey => 'feature_type_id', origkey => 'permission_role.feature_type_id', joincond => "feature_type_token = 'course'" }),
    ]);
}


sub child_students {
    #
    # Get the user linked down from this course
    #

    my $self = shift;
    my @cond = @_;
    # Check cache...
    unless ($self->{-child_students} and !@cond) {
        # Get the link definition
        # And use it to get a LinkSet of users
        $self->{-child_students} = $self->student_link()->get_children($self->primary_key,@cond);
    }
    # Return the list
    return $self->{-child_students}->children();
}


sub is_child_student{
    my $self = shift;
    my $user_id = shift;
    my $cond = shift || '';

    unless($user_id){
	warn 'user_id needs to be defined';
	return 0;
    }

    $cond = ' and ' . $cond if ($cond);
    my @child_students = $self->child_students("child_user_id = '" . $user_id . "'" . $cond);
    return scalar @child_students;
}


sub child_user_hash {
    #
    # Get a hashref of the users indexed by user name
    #

    my $self = shift;
    unless ($self->{-child_user_hash}) {
	$self->{-child_user_hash} = { map { $_->primary_key() => $_ } $self->users() };
    }
    return $self->{-child_user_hash};
}

sub reset_user_list {
    # 
    # Reset the user lists
    #

    my $self = shift;
    $self->{-child_users} = 0;
    $self->{-child_user_hash} = 0;
}


sub add_child_student {
    #
    # Add a user to this course
    #

    my $self = shift;
    my ($u, $p, $username,$tp,$ts,$elective) = @_;
    my ($r, $msg);
    
    if ($self->associate_user_group()){
	my @usergroups = $self->child_user_groups($tp);
	return(0, "Could not find User Group") unless ($usergroups[0]);
	($r, $msg) = $usergroups[0]->add_child_user($u, $p, $username, $tp, $ts);
    }else{
	unless($ts) {$ts = 0;}
	($r, $msg) = $self->student_link()->insert (-user => $u, -password => $p,
						       -child_id => $username,
						       -parent_id => $self->primary_key,
						       time_period_id=>$tp,
						       teaching_site_id => $ts || 0,
							   elective => $elective || 0 );
    }
    return ($r, $msg);
}


sub update_child_student {
    #
    # Add a user to this course
    #

    my $self = shift;
    my ($u, $p, $username,$tp,$ts,$elective) = @_;

    my ($r, $msg) = $self->student_link()->update(
						  -user => $u, -password => $p,
						  -child_id => $username,
						  -parent_id => $self->primary_key,
						  time_period_id=>$tp,
						  teaching_site_id =>$ts || 0,
						  elective => $elective || 0,
						  -cond => ' AND time_period_id = ' . $tp );
    return ($r, $msg);
}

sub delete_child_student {
	#
	# Delete a user
	# If course is a usergroup course, we will iterate through all active
	# usergroups during this timeperiod and delete the user from all
	# of the groups (if present within them)
	#

	my ($self, $u, $p, $username, $tp, $ts) = @_;
	my ($r, $msg);

	if ($self->associate_user_group()){
		my @usergroups = $self->child_user_groups($tp);
		return(0, "Could not find User Group") unless ($usergroups[0]);
		foreach my $ug (@usergroups){
			($r, $msg) = $ug->delete_child_user($u, $p, $username);
		}
	}
	else{
		($r, $msg) =  $self->student_link()->delete (-user => $u, -password => $p,
							-parent_id => $self->primary_key,
							-child_id => $username,
						        time_period_id=>$tp,
						        teaching_site_id=>$ts,
								-cond => ' AND time_period_id = ' . $tp);
	}
	return ($r, $msg);
}

################################
# AUTHORIZATION
################################
sub user_has_role {
    my ($self, $user_id, $role_tokens) = @_;

    unless (exists $self->{course_role_token}{$user_id}) {
	my $users = $self->find_users("course_user.user_id = '$user_id'");
	my $role = $users->[0]->getRole() if (scalar @$users && ref $users->[0] eq 'TUSK::Core::HSDB4Tables::User');
	$self->{course_role_token}{$user_id} = ($role) ? $role->getRoleToken() : '';
    }
    
    if ($role_tokens && scalar @$role_tokens) {
	foreach my $token (@$role_tokens) {
	    return 1 if ($token eq $self->{course_role_token}{$user_id});
	}
    } else {
	return 1 if ($self->{course_role_token}{$user_id} ne '');
    }
    return 0;
}

sub can_user_manage_course {
    my ($self, $user) = @_;

    # If it's a course director or administrator, they can edit
    if ($self->user_has_role($user->primary_key(), ['director', 'administrator'])) { 
	return 1; 
    }

    # If the user is in the school admin group, then they're also set
    my $admin_group = HSDB45::UserGroup->get_admin_group($self->school());
    if ($admin_group->contains_user($user)) {
	return 1;
    }
    return 0;
}

sub can_user_edit {
    my ($self, $user) = @_;

    # first check the user's role (as opposed to label) in this course
    return 1 if ($self->user_has_role($user->primary_key()));

    foreach ($user->parent_user_groups()) {
	return 1 if ($_->can_edit_course($self));
    }
    return 0;
}

sub can_user_add {
    my ($self, $user) = @_;

    # first check the user's role (as opposed to label) in this course
    return 1 if ($self->user_has_role($user->primary_key()));

    foreach ($user->parent_user_groups()) {
	return 1 if ($_->can_edit_course($self));
    }
    return 0;
}


sub child_small_group_leaders {
    #
    # Get the list of small group instructors
    #
    my ($self, $time_period_id) = @_;
    warn "I am being called in course object\n";
    my $user = TUSK::Core::HSDB4Tables::User->new();
    $user->setErrorLevel(9);
    return $user->lookup(undef, ['lastname', 'firstname'], undef, undef, 
	   [ 
	     TUSK::Core::JoinObject->new('TUSK::Course::User::Site', { joinkey => 'user_id', jointype => 'inner', }),
	     TUSK::Core::JoinObject->new('TUSK::Course::User', { joinkey => 'course_user_id', origkey => 'course_user_site.course_user_id', jointype => 'inner', joincond => "time_period_id = $time_period_id"  }),
	     TUSK::Core::JoinObject->new('TUSK::Permission::UserRole', { joinkey => 'feature_id', origkey => 'course_user.course_user_id', jointype => 'inner'  }),
	     TUSK::Core::JoinObject->new('TUSK::Permission::Role', { joinkey => 'role_id', origkey => 'permission_user_role.role_id',  jointype => 'inner',  joincond => "role_token = 'instructor'" }),
    ]);
}

sub content_link {
    my $self = shift;
    my $db = $self->school_db();
    return $HSDB4::SQLLinkDefinition::LinkDefs{"$db\.link_course_content"};
}


sub child_content {
    #
    # Get the content linked down from this course
    #

    my $self = shift;
    # Check cache...
    unless ($self->{-child_content}) {
        # Get the link definition
        # And use it to get a LinkSet of content
	my $set = $self->content_link()->get_children($self->primary_key,@_);
	my $path = sprintf("%s%dC", code_by_school( $self->school() ), $self->primary_key );
	foreach my $child ($set->children) {
	    $child->set_aux_info ('uri_path', $path);
	}
	$self->{-child_content} = $set;
    }
    # Return the list
    return $self->{-child_content}->children();
}

sub active_child_content{
    #
    # only get active content
    #

    my ($self) = @_;
    return $self->child_content("(start_date <= now() or start_date is null) and (end_date >= now() or end_date is null)");
}

sub active_child_content_during_span{
    #
    # only get active content
    #

    my ($self, $born, $rip) = @_;
    return $self->child_content("(start_date <= '$rip' or start_date is null) and (end_date >= '$born' or end_date is null)");
}

sub child_contentref {
    #
    # Get the content linked down from this course
    #

    my $self = shift;
    # Check cache...
    unless ($self->{-child_contentref}) {
	@{$self->{-child_contentref}}=$self->child_content;
    }
    # Return the list
    return $self->{-child_contentref};
}


sub add_child_content {
    #
    # Add a piece of content to this course
    #

    my $self = shift;
    my ($u, $p, $content_id, $sort, $title) = @_;
    my ($r, $msg) = $self->content_link()->insert (-user => $u, 
						-password => $p,
						-child_id => $content_id,
						-parent_id => $self->primary_key,
						sort_order => $sort,
						label => $title);
    return ($r, $msg);
}

sub delete_child_content_link {
    #
    # Delete a content
    #

    my $self = shift;
    my ($u, $p, $content_id) = @_;
    my ($r, $msg) =  $self->content_link()->delete (-user => $u, 
						    -password => $p,
						    -parent_id => $self->primary_key,
						    -child_id => $content_id);
    return ($r, $msg);
}

sub class_meetings {
    #
    # Get the schedule for the class and all its children
    #

	my $self = shift;
	my $timeperiod = shift;
	my $date = shift || undef;

	# Make a list of this course and all the subsidiary courses
	my @course_list = ( $self->primary_key );
	# Get the subcourses
	foreach ($self->child_courses) { push @course_list, $_->primary_key }
	# Make the condition
	my $condition = sprintf ("course_id in (%s)", join (', ', @course_list));
	my $dates;
	if (ref $timeperiod eq 'HSDB45::TimePeriod'){
		$dates = "meeting_date BETWEEN '" .$timeperiod->start_date->out_mysql_date."' AND '".$timeperiod->end_date->out_mysql_date."'"; 
	}
	elsif (defined $date){
		$dates = "meeting_date = '$date'";
	}
	else {
		$dates = "meeting_date > SUBDATE(CURDATE(), INTERVAL 3 MONTH)";
	}
	my $order = "ORDER BY meeting_date, starttime";
	my $blankmeeting = HSDB45::ClassMeeting->new( _school => $self->school() );
	$self->{-class_meetings} = [ $blankmeeting->lookup_conditions ($condition, $dates, $order) ];

	return @{$self->{-class_meetings}};
}

sub meetings_on_date{
	my $self = shift;
	my $date = shift;

	return $self->class_meetings('', $date);
}

sub todays_meetings {
	my $self = shift;
	my $today = HSDB4::DateTime->new()->out_mysql_date;
	return $self->meetings_on_date($today);
}

sub title {
    my $self = shift;
    return $self->field_value('title');
}

sub abbreviation {
    my $self = shift();
    return $self->field_value('abbreviation');
}

sub color {
    my $self = shift();
    return $self->field_value('color');
}

sub user_group_link {
    my $self = shift;
    my $db = $self->school_db();
    return $HSDB4::SQLLinkDefinition::LinkDefs{"$db\.link_course_user_group"};
}


sub sub_user_groups {
    #
    # Get the user_group objects associated with this
    #

    my ($self, $timeperiod_id) = @_;
    unless ($timeperiod_id){
	my $tp = $self->get_current_timeperiod;
	return unless ($tp);
	$timeperiod_id = $tp->primary_key;
    }
    unless ($self->{-sub_user_groups}) {
	$self->user_group_link()->{'-order_by'} = "sort_order";
	$self->{-sub_user_groups} = $self->user_group_link()->get_children($self->primary_key,"sub_group='Yes' and time_period_id = ". $timeperiod_id);
    }
    return $self->{-sub_user_groups}->children();
}


sub child_user_groups {
    #
    # Get the user_group objects associated with this
    #

    my $self = shift;
    unless ($self->{-child_user_groups}) {
		$self->user_group_link()->{'-order_by'} = "sort_order";
		$self->{-child_user_groups} = $self->user_group_link()->get_children( $self->primary_key(), "sub_group = 'No'" );
    }

    # If there weren't any time_period_ids passed in, then return the whole list
    if (not @_) {
	return $self->{-child_user_groups}->children();
    }
    # But if there were, then filter for those time_period_ids
    my %tpids = ();
    for (@_) { $tpids{$_} = 1 }
    return 
	grep { $tpids{$_->aux_info('time_period_id') } } $self->{-child_user_groups}->children();
}
sub add_child_user_group_link {
    my $self = shift;
    my ($u,$p,$ug_id,$tp_id) = @_;
    return (0, "missing user_group_id and time_period_id") unless ($ug_id && $tp_id);
    my ($r, $msg) = $self->user_group_link()->insert(-user => $u, 
						     -password => $p,
						     -child_id => $ug_id,
						     -parent_id => $self->primary_key,
						     time_period_id => $tp_id);
    return ($r, $msg);
}

sub delete_child_user_group_link {
    my $self = shift;
    my ($u,$p,$ug_id) = @_;
    return (0, "missing user_group_id") unless ($ug_id);
    my ($r,$msg) = $self->user_group_link()->delete(-user => $u,
						    -password => $p,
						    -parent_id => $self->primary_key,
						    -child_id => $ug_id);
    return ($r,$msg);
}

sub is_user_registered {

    my $self = shift;
    my $username = shift;
    my $time_period_id = shift;
    my $teaching_site_id = shift;
    my $dbh = HSDB4::Constants::def_db_handle;
    my $registered = 0;
    my $db = $self->school_db();
    my $sql = qq[SELECT time_period_id FROM $db\.link_course_student 
		 WHERE parent_course_id=? AND child_user_id=? AND time_period_id=?];
    if ($teaching_site_id) {
	$sql .= " AND teaching_site_id=$teaching_site_id";
    }
    eval {
	my $sth = $dbh->prepare ($sql);
	$sth->execute ($self->primary_key(), $username, $time_period_id);
	($registered) = $sth->fetchrow_array;
     $sth->finish;
    };

    return $registered;
}

sub associate_user_group {
    #
    # Find out how we associate users
    #

    my $self = shift;
    my $assoc = $self->field_value ('associate_users');
    if ($assoc =~ /User Group/) { return 1; }
    return 0;
}

sub teaching_site_link {
    my $self = shift;
    my $db = $self->school_db();
    return $HSDB4::SQLLinkDefinition::LinkDefs{"$db\.link_course_teaching_site"};
}

sub child_teaching_sites {
    #
    # Get the teaching_site objects associated with this
    #

    my $self = shift;
    unless ($self->{-child_teaching_sites}) {
	$self->{-child_teaching_sites} = 
	    $self->teaching_site_link()->get_children( $self->primary_key(), @_ );
    }
    return $self->{-child_teaching_sites}->children();
}

sub get_teaching_sites_for_enrolled_time_period {
	my ($self, $time_period_id) = @_;

    $time_period_id = $self->get_current_timeperiod() unless ($time_period_id);

	my $dbh = HSDB4::Constants::def_db_handle;
	my $db = $self->school_db();
    my $sth = $dbh->prepare(qq(select distinct b.teaching_site_id from $db\.link_course_student a, $db\.teaching_site b where parent_course_id = ? and time_period_id = ? and a.teaching_site_id = b.teaching_site_id order by site_name));
	$sth->execute ($self->primary_key(),$time_period_id);

	my @teaching_sites;
	while (my ($id) = $sth->fetchrow_array) {
		push @teaching_sites, HSDB45::TeachingSite->new(_school => $self->school(), _id => $id);
	}
     $sth->finish;
	return \@teaching_sites;
}

sub get_course_codes{
	my $self = shift or confess "Course code requires an object to be passed";
	unless($self->primary_key()) {return [];}
	my $school = $self->get_school() or confess "Unable to obtain school object";
	my $school_id = $school->getPrimaryKeyID() or confess "Unable to obtain school_id";
	return TUSK::Core::CourseCode->lookup(" course_id = ".$self->primary_key()
		." and school_id = $school_id ");

}

sub get_self_assessment_quizzes{
    my ($self, $user) = @_;
    my ($quizzes);

    my $school_id = TUSK::Core::School->new->getSchoolID($self->school);
	my $tp_list = $self->get_users_active_timeperiods($user);
	
	my $tp_cond = "";
	if ($tp_list and scalar(@$tp_list)) {
		my @tp_ids = map { $_->primary_key() } @$tp_list;
		$tp_cond = "and time_period_id in (" . join(',', @tp_ids ) . ")";
	}
    

    my $sql = "select q.quiz_id, q.title from tusk.quiz q, tusk.link_course_quiz l where (school_id = '" . $school_id . "' and parent_course_id = " . $self->primary_key . ") and q.quiz_id = l.child_quiz_id and q.quiz_type = 'SelfAssessment' and available_date < now() and (due_date > now() or due_date is null) $tp_cond order by l.sort_order";

    my $dbh = HSDB4::Constants::def_db_handle ();
    
    eval {
	my $sth = $dbh->prepare ($sql);
	$sth->execute ();
	while (my ($quiz_id, $title) = $sth->fetchrow_array) {
	    push @$quizzes, {'quiz_id' => $quiz_id, 'title' => $title, 'school_id' => $school_id, 'course_id' => $self->primary_key};
	}
     $sth->finish;
    };

    return $quizzes
    
}

sub get_evals {
    my $self = shift;
    my $time_period_id = shift;

    my @evals = ();
    # We skip unless the Evals flag is set in homepage_info field.
    my $dbh = HSDB4::Constants::def_db_handle ();
    if (!$time_period_id){
	    my $time_period = $self->get_current_timeperiod();
	    if ($time_period){
		    $time_period_id = $time_period->primary_key() or return ();
	    } else {
		    return ();	
            }		
    }

    eval {
        my $db = $self->school_db();
        # Do a lookup to get all the appropriate evals: that is, evals where
        # we can find a link_course_user_group which specifies an appropriate
        # time_period_id and where the course also specifies User Group
        my $sth = $dbh->prepare (<<EOM);
SELECT eval_id FROM
        $db\.eval e
        WHERE e.course_id = ? 
        AND e.time_period_id = ?
EOM

        $sth->execute ($self->primary_key,$time_period_id);

        while (my ($eval_id) = $sth->fetchrow_array) { push @evals, $eval_id }
        $sth->finish;
    };
    confess $@ if $@;

    # Return the list
    return map { HSDB45::Eval->new( _school => $self->school(), _id => $_ ) } @evals;


}

sub check_user_patient_log{
    my ($self, $user_id) = @_;

    my $patientlogs;

    my $db = HSDB4::Constants::get_school_db($self->school());;
    my $course_id = $self->course_id();
    my $school_id = TUSK::Core::School->new->getSchoolID($self->school());

    my $sql =<<EOM;
select $course_id as course_id, $school_id as school_id, 
if ((t.start_date <= curdate() and t.end_date >= curdate()), 1, 0) as form_link from 
tusk.link_course_form f, 
tusk.form_builder_form fo, 
$db\.link_course_student l, 
$db\.time_period t
where 
f.school_id = ? and f.parent_course_id = ? and
f.parent_course_id = l.parent_course_id and 
l.time_period_id = t.time_period_id and 
l.child_user_id = ? and
f.child_form_id = fo.form_id and
fo.publish_flag = 1
order by t.start_date desc;
EOM
    my $dbh = HSDB4::Constants::def_db_handle ();

    eval {
	my $sth = $dbh->prepare ($sql);
	$sth->execute ($school_id, $course_id, $user_id);
	$patientlogs = $sth->fetchall_arrayref({});
    };
    if ($@){
	confess "$@";
    }
    if (scalar(@$patientlogs)){
	return $patientlogs->[0];
    }else{
	return "";
    }
}

sub get_patient_log{
    my ($self) = @_;

    my $school_id = TUSK::Core::School->new->getSchoolID($self->school());

    unless (defined($self->{_patient_log})){
		my $form = TUSK::FormBuilder::Form->new()->lookup("parent_course_id = " . $self->course_id() . " and school_id = " . $school_id . " and token='PatientLog'",undef, undef, undef, [ TUSK::Core::JoinObject->new("TUSK::FormBuilder::LinkCourseForm",  { origkey => 'form_id', joinkey => 'child_form_id'}), TUSK::Core::JoinObject->new("TUSK::FormBuilder::FormType", {origkey => 'form_type_id', joinkey => 'form_type_id'}) ]);

		$self->{_patient_log} = (scalar(@$form)) ? $form->[0] : '';
   
    }
	return ($self->{_patient_log});
}

sub has_patient_log {
    my ($self) = @_;
    if ($self->get_patient_log()){
	return 1;
    }else{
	return 0;
    }
}


#
# >>>>>  Input Methods <<<<<
#

sub in_xml {
    #
    # Suck in a bunch of XML and push it into the appropriate places
    #

    my $self = shift;
}

sub in_fdat_hash {
    #
    # Read in a hash of key => value pairs and make changes
    #

    my $self = shift;
    while (my ($key, $val) = splice(@_, 0, 2)) {
    }
}

#
# >>>>>  Output Methods  <<<<<
#

sub out_title {
    #
    # Return nice title for the course
    #
    
    my $self = shift;

    my $title = $self->field_value('title');
    return "" if ( ! length ($title) );
    $title = uc(substr($title,0,1)).substr($title,1,length($title));

    if (length($title) > 50){
	$title=substr($title,0,50)."...";
    }

    my $oea_code = $self->field_value('oea_code');
    if ($oea_code){
	    my $stripObj = TUSK::Application::HTML::Strip->new();
		$oea_code = $stripObj->removeHTML($oea_code);
		unless ($title=~/^$oea_code/i){
			$title .= " (".$oea_code.")";
		}
    }

    return $title;
}

sub out_log_item {
    #
    # Return an item for logging
    #

    my $self = shift;
    my $id = $self->primary_key;
    return sprintf "Course:%d::", $id;
}

sub out_html_div {
    #
    # Formatted blob of HTML
    #

    my $self = shift;
    return '';
}

sub out_xml {
    #
    # An XML representation of the row
    #

}

sub out_html_row {
    # 
    # A four-column HTML row
    #

    my $self = shift;
    return sprintf ("<TR><TD>%s</TD><TD COLSPAN=2>%s</TD><TD>%s</TD></TR>\n",
		    $self->field_value('oea_code'),
		    $self->out_html_label, $self->school());
}

sub out_label {
    #
    # A label for the object: its title
    #

    my $self = shift;
    return $self->field_value('title');
}

sub out_abbrev {
    #
    # An abbreviation for the object: the first twenty characters of its
    # title
    #

    my $self = shift;
    return $self->field_value('abbreviation') || $self->field_value('title');
}

sub out_rgb_color {
    #
    # Return a RGB triplet of color on a 0-255 scale for the color in the color
    # field of the object
    #

    my $self = shift;
    my $color = $self->field_value('color');
    if ($color and $color =~ /\#(\w\w)(\w\w)(\w\w)/){
	return map { hex $_ } ($1, $2, $3);
    }else{
	return();
    }
}

sub dark_color {
	my $self = shift;
	my ($r, $g, $b) = $self->out_rgb_dark_color;

	if (defined($r)) {	
		return "#" . sprintf('%02x', $r) . sprintf('%02x', $g) . sprintf('%02x', $b);
	} else {
		return "#666666";
	}
}

sub out_rgb_dark_color {
    #
    # Try to figure out a darker color from the regular color
    #

    my $self = shift;
    my $color = $self->field_value ('color');
    if ($color and $color =~ /\#(\w\w)(\w\w)(\w\w)/){
	my ($r,$g,$b) = map { my $out = hex($_) - 51;
			      $out < 0 ? 0 : $out } ($1,$2,$3);
	return ($r, $g, $b);
    }else{
	return();
    }
}

# Overloaded from SQLRow
sub out_html_label {
	my ( $self, $url, $label ) = @_;
	
	if ( defined($url) ) {
		$url = $self->out_url . $url;
	}
	else {
		$url = $self->out_url;
	}
	
	if ( !defined($label) ) {
		$label = $self->out_label;
	}

	return sprintf("<a href=\"%s\">%s</a>", $url, $label);
}

sub out_url_mobi{
	my $self = shift;

	my $url = '/mobi' . $self->SUPER::out_url();
	return $url;
}

sub is_a_subcourse{
	my $self        = shift;
	my $tusk_course = TUSK::Course->new()->lookupKey($self->getTuskCourseID());

    foreach (@{TUSK::Core::LinkCourseCourse->new()->passValues($tusk_course)->lookup("link_course_course.child_course_id=".$tusk_course->getFieldValue('course_id'))} ) {
		my $i_tusk_course = TUSK::Course->new()->lookupKey( $_->getParentCourseID() );
		# It should only be part of one, but if it's more than one, just return the 1st.
		return $i_tusk_course->getHSDB45CourseFromTuskID(); 
	}
}

sub get_subcourses{
	my $self        = shift;
	my $tusk_course = TUSK::Course->new()->lookupKey($self->getTuskCourseID());

    my $ret = [];
    foreach (@{ TUSK::Core::LinkCourseCourse->new()->passValues($tusk_course)->lookup("link_course_course.parent_course_id=".$tusk_course->getFieldValue('course_id')) }) { 
		my $i_tusk_course = TUSK::Course->new()->lookupKey( $_->getChildCourseID() );
		push @{$ret}, $i_tusk_course->getHSDB45CourseFromTuskID();
	}
	
	return $ret;
}

sub set_subcourses{
	my $self        = shift;
	my $user        = shift;
	my $subcourses  = shift;
	my $tusk_course = TUSK::Course->new()->lookupKey($self->getTuskCourseID());

    foreach (@{ TUSK::Core::LinkCourseCourse->new()->passValues($tusk_course)->lookup("link_course_course.parent_course_id=".$tusk_course->getFieldValue('course_id')) }) { 
		$_->delete();
	}

	foreach (@{$subcourses}) {
		my $new_tusk_course = TUSK::Course->new()->lookupKey($_->getTuskCourseID());
		my $new_subcourse   = TUSK::Core::LinkCourseCourse->new()->passValues($tusk_course);
		
		$new_subcourse->setParentCourseID( $tusk_course->getFieldValue('course_id') );
		$new_subcourse->setChildCourseID(  $new_tusk_course->getFieldValue('course_id') );
		
		$new_subcourse->save( { 'user' => $user } );
	}

}


1;
__END__

