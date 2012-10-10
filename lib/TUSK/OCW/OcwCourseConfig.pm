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


package TUSK::OCW::OcwCourseConfig;

=head1 NAME

B<TUSK::OCW::OcwCourseConfig> - Class for manipulating entries in table ocw_course_config in tusk database

=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 INTERFACE


=head2 GET/SET METHODS

=over 4

=cut

use strict;

BEGIN {
    require Exporter;
    require TUSK::Core::SQLRow;

    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
    
    @ISA = qw(TUSK::Core::SQLRow Exporter);
    @EXPORT = qw( );
    @EXPORT_OK = qw( );
}

use vars @EXPORT_OK;
use HSDB45::Course;
use HSDB45::Course::XMLRenderer;
use TUSK::OCW::OcwCalendarConfig;
use TUSK::Core::ClassMeetingContentType;
use Carp;

# Non-exported package globals go here
use vars ();

# A list of tokens that correspond to functions in this object and pages to be outputed for a course
our @coursePages = qw ( CourseHome Syllabus Calendar LectureNotes SeminarNotes Labs 
			Exams ExamsAndQuizzes Readings Assignments Projects 
			StudentNotes LectureHandouts ImageGallery StudentWork
			SmallGroups Cases 
			CourseDocuments Tools
			Activities Lessons Topics LearningUnits
			SupplementaryMaterial
			);

# These are used to output folders of content to certain pages
our @folderCoursePages = qw ( Exams ExamsAndQuizzes Labs Assignments Projects 
		ImageGallery Cases SupplementaryMaterial SmallGroups SeminarNotes Resources StudentWork CourseDocuments Tools LectureHandouts);

# This Hash is for the case where the name of the courseOption does not match the name of the 
# folder in the course (only needed if content is linked through the folder and not the 
# schedule)

our %coursePageLabels = map { ($_ , $_ ) } @coursePages;
%coursePageLabels = ( %coursePageLabels, 
			CourseHome => 'Course Home',
			LectureNotes=>'Lecture Notes',
			LectureHandouts=>'Lecture Handouts',
		        SeminarNotes=>'Seminar Notes',
			Documents=>'Lecture Notes',
			ImageGallery=>'Image Gallery',
			SmallGroups => 'Small Groups',
		        StudentWork => 'Student Work',
		      ExamsAndQuizzes => 'Exams and Quizzes',
			SupplementaryMaterial => 'Supplementary Material',
		      CourseDocuments => 'Course Documents',
		      LearningUnits => 'Learning Units',
		      StudentWork => 'Student Work',
		      );
				
our $FolderPrefix = 'OCW Project:';

sub new {
    # Find out what class we are
    my $class = shift;
    $class = ref $class || $class;
    # Call the super-class's constructor and give it all the values
    my $self = $class->SUPER::new ( 
				    _datainfo => {
					'database' => 'tusk',
					'tablename' => 'ocw_course_config',
					'usertoken' => 'ContentManager',
					'database_handle' => '',
					},
				    _field_names => {
					'ocw_course_config_id' => 'pk',
					'status' => '',
					'metadata_course_id' => '',
					'metadata_school_id' => '',
					'content_course_id' => '',
					'content_school_id' => '',
					'ocw_school_id' => '',
					'time_period_id' => '',
					'level_label' => '',
					'time_period_label' => '',
					'show_faculty' => '',
					'graphic_name' => '',
					'small_graphic' => '',
					'short_description' => '',
					'graphic_caption'=>'',
					'highlights'=>'',
					'subject' => '',
					'pub_year'=>'',
					'pub_month'=>'',
					'keywords'=>'',
				    },
				    _attributes => {
					save_history => 0,
					tracking_fields => 1,	
				    },
				    _levels => {
					reporting => 'warn',
					error => 0,
				    },
				    _default_join_objects  =>  [
					TUSK::Core::JoinObject->new("TUSK::OCW::OcwSchool")
					],
					
				    @_
				  );
    # Finish initialization...
    return $self;
}

### Get/Set methods

#######################################################

=item B<getStatus>

    $string = $obj->getStatus();

    Get the value of the status field: Unpublished, Draft or Published

=cut

sub getStatus{
    my ($self) = @_;
    return $self->getFieldValue('status');
}

#######################################################

=item B<setStatus>

    $obj->setStatus();

    Set the value of the status field: Unpublished, Draft or Published

=cut

sub setStatus{
    my ($self,$value) = @_;
    return $self->setFieldValue('status', $value);
}

#######################################################

=item B<getMetadataCourseID>

    $string = $obj->getMetadataCourseID();

    Get the value of the metadata_course_id field

=cut

sub getMetadataCourseID{
    my ($self) = @_;
    return $self->getFieldValue('metadata_course_id');
}

#######################################################

=item B<setMetadataCourseID>

    $obj->setMetadataCourseID($value);

    Set the value of the metadata_course_id field

=cut

sub setMetadataCourseID{
    my ($self, $value) = @_;
    $self->setFieldValue('metadata_course_id', $value);
}


#######################################################

=item B<getMetadataSchoolID>

    $string = $obj->getMetadataSchoolID();

    Get the value of the metadata_school_id field

=cut

sub getMetadataSchoolID{
    my ($self) = @_;
    return $self->getFieldValue('metadata_school_id');
}

#######################################################

=item B<setMetadataSchoolID>

    $obj->setMetadataSchoolID($value);

    Set the value of the metadata_school_id field

=cut

sub setMetadataSchoolID{
    my ($self, $value) = @_;
    $self->setFieldValue('metadata_school_id', $value);
}


#######################################################

=item B<getContentCourseID>

    $string = $obj->getContentCourseID();

    Get the value of the content_course_id field

=cut

sub getContentCourseID{
    my ($self) = @_;
    return $self->getFieldValue('content_course_id');
}

#######################################################

=item B<setContentCourseID>

    $obj->setContentCourseID($value);

    Set the value of the content_course_id field

=cut

sub setContentCourseID{
    my ($self, $value) = @_;
    $self->setFieldValue('content_course_id', $value);
}


#######################################################

=item B<getContentSchoolID>

    $string = $obj->getContentSchoolID();

    Get the value of the content_school_id field

=cut

sub getContentSchoolID{
    my ($self) = @_;
    return $self->getFieldValue('content_school_id');
}

#######################################################

=item B<setContentSchoolID>

    $obj->setContentSchoolID($value);

    Set the value of the content_school_id field

=cut

sub setContentSchoolID{
    my ($self, $value) = @_;
    $self->setFieldValue('content_school_id', $value);
}


#######################################################

=item B<getOcwSchoolID>

    $string = $obj->getOcwSchoolID();

    Get the value of the ocw_school_id field

=cut

sub getOcwSchoolID{
    my ($self) = @_;
    return $self->getFieldValue('ocw_school_id');
}

#######################################################

=item B<setOcwSchoolID>

    $obj->setOcwSchoolID($value);

    Set the value of the ocw_school_id field

=cut

sub setOcwSchoolID{
    my ($self, $value) = @_;
    $self->setFieldValue('ocw_school_id', $value);
}


#######################################################

=item B<getTimePeriodID>

    $string = $obj->getTimePeriodID();

    Get the value of the time_period_id field

=cut

sub getTimePeriodID{
    my ($self) = @_;
    return $self->getFieldValue('time_period_id');
}

#######################################################

=item B<setTimePeriodID>

    $obj->setTimePeriodID($value);

    Set the value of the time_period_id field

=cut

sub setTimePeriodID{
    my ($self, $value) = @_;
    $self->setFieldValue('time_period_id', $value);
}


#######################################################

=item B<getLevelLabel>

    $string = $obj->getLevelLabel();

    Get the value of the level_label field

=cut

sub getLevelLabel{
    my ($self) = @_;
    return $self->getFieldValue('level_label');
}

#######################################################

=item B<setLevelLabel>

    $obj->setLevelLabel($value);

    Set the value of the level_label field

=cut

sub setLevelLabel{
    my ($self, $value) = @_;
    $self->setFieldValue('level_label', $value);
}


#######################################################

=item B<getTimePeriodLabel>

    $string = $obj->getTimePeriodLabel();

    Get the value of the time_period_label field

=cut

sub getTimePeriodLabel{
    my ($self) = @_;
    return $self->getFieldValue('time_period_label');
}

#######################################################

=item B<setTimePeriodLabel>

    $obj->setTimePeriodLabel($value);

    Set the value of the time_period_label field

=cut

sub setTimePeriodLabel{
    my ($self, $value) = @_;
    $self->setFieldValue('time_period_label', $value);
}


#######################################################

=item B<getShowFaculty>

    $string = $obj->getShowFaculty();

    Get the value of the show_faculty field

=cut

sub getShowFaculty{
    my ($self) = @_;
    return $self->getFieldValue('show_faculty');
}

#######################################################

=item B<setShowFaculty>

    $obj->setShowFaculty($value);

    Set the value of the show_faculty field

=cut

sub setShowFaculty{
    my ($self, $value) = @_;
    $self->setFieldValue('show_faculty', $value);
}


#######################################################

=item B<getGraphicName>

    $string = $obj->getGraphicName();

    Get the value of the graphic_name field

=cut

sub getGraphicName{
    my ($self) = @_;
    return $self->getFieldValue('graphic_name');
}

#######################################################

=item B<setGraphicName>

    $obj->setGraphicName($value);

    Set the value of the graphic_name field

=cut

sub setGraphicName{
    my ($self, $value) = @_;
    $self->setFieldValue('graphic_name', $value);
}

#######################################################

=item B<getGraphicCaption>

    $string = $obj->getGraphicCaption();

    Get the value of the graphic_caption field

=cut

sub getGraphicCaption{
    my ($self) = @_;
    return $self->getFieldValue('graphic_caption');
}

#######################################################

=item B<setGraphicCaption>

    $obj->setGraphicCaption($value);

    Set the value of the graphic_caption field

=cut

sub setGraphicCaption{
    my ($self, $value) = @_;
    $self->setFieldValue('graphic_caption', $value);
}

#######################################################

=item B<getHighlights>

    $string = $obj->getHighlights();

    Get the value of the highlights field

=cut

sub getHighlights{
    my ($self) = @_;
    return $self->getFieldValue('highlights');
}

#######################################################

=item B<setHighlights>

    $obj->setHighlights($value);

    Set the value of the highlights field

=cut

sub setHighlights{
    my ($self, $value) = @_;
    $self->setFieldValue('highlights', $value);
}

#######################################################

=item B<getPubYear>

    $string = $obj->getPubYear();

    Get the value of the pub_year field

=cut

sub getPubYear{
    my ($self) = @_;
    return $self->getFieldValue('pub_year');
}

#######################################################

=item B<setPubYear>

    $obj->setPubYear($value);

    Set the value of the pub_year field

=cut

sub setPubYear{
    my ($self, $value) = @_;
    $self->setFieldValue('pub_year', $value);
}

#######################################################

=item B<getPubMonth>

    $string = $obj->getPubMonth();

    Get the value of the pub_month field

=cut

sub getPubMonth{
    my ($self) = @_;
    return $self->getFieldValue('pub_month');
}

#######################################################

=item B<setPubMonth>

    $obj->setPubMonth($value);

    Set the value of the pub_month field

=cut

sub setPubMonth{
    my ($self, $value) = @_;
    $self->setFieldValue('pub_month', $value);
}

#######################################################

=item B<getKeywords>

    $string = $obj->getKeywords();

    Get the value of the keywords field

=cut

sub getKeywords{
    my ($self) = @_;
    return $self->getFieldValue('keywords');
}

#######################################################

=item B<setKeywords>

    $obj->setKeywords($value);

    Set the value of the keywords field

=cut

sub setKeywords{
    my ($self, $value) = @_;
    $self->setFieldValue('keywords', $value);
}

#######################################################

=item B<getSmallGraphic>

    $string = $obj->getSmallGraphic();

    Get the value of the small_graphic field

=cut

sub getSmallGraphic{
    my ($self) = @_;
    return $self->getFieldValue('small_graphic');
}

#######################################################

=item B<setSmallGraphic>

    $obj->setSmallGraphic($value);

    Set the value of the small_graphic field

=cut

sub setSmallGraphic{
    my ($self, $value) = @_;
    $self->setFieldValue('small_graphic', $value);
}

#######################################################

=item B<getShortDescription>

    $string = $obj->getShortDescription();

    Get the value of the short_description field

=cut

sub getShortDescription{
    my ($self) = @_;
    return $self->getFieldValue('short_description');
}

#######################################################

=item B<setShortDescription>

    $obj->setShortDescription($value);

    Set the value of the short_description field

=cut

sub setShortDescription{
    my ($self, $value) = @_;
    $self->setFieldValue('short_description', $value);
}

=back

=cut

#######################################################

=item B<getSubject>

    $string = $obj->getSubject();

    Get the value of the subject field

=cut

sub getSubject{
    my ($self) = @_;
    return $self->getFieldValue('subject');
}

#######################################################

=item B<setSubject>

    $obj->setSubject($value);

    Set the value of the subject field

=cut

sub setSubject{
    my ($self, $value) = @_;
    $self->setFieldValue('subject', $value);
}

=back

=cut

### Other Methods

#######################################################

=item B<getCourseOptions>

    $options = $courseConfig->getCourseOptions();

	This function returns a hashref of available navigation options
for this course.  Basically this specifies what information to include for
the course.

=cut

sub getCourseOptions {
	my $self = shift;
	my $course_options = {};
	my $optionFunc;
	foreach my $option (@coursePages) {
		$optionFunc = 'has'.$option;
		$course_options->{$option} = $self->$optionFunc;
	}
	return $course_options;

}

sub getCourseHomeLabel {
	my $self = shift;
	my $course = $self->getMetadataCourse();
	my $label = sprintf("%s %s",$course->registrar_code,
		$self->getCourseTitle);
	return $label;
}

sub getCourseDesc {
	my $self = shift;
	my $course = $self->getMetadataCourse();

	my $metaDataRef = $course->getSchoolMetadata();
	my $description_key;

	foreach my $key (keys (%$metaDataRef)){
	    next if ($key eq "metadataOrder");
	    
	    if ($metaDataRef->{$key}->{'displayName'} eq "Description"){
		$description_key = $key;
		last;
	    }
	}

	my $description = shift @{$course->getCourseMetadataByType($course->getTuskCourseID(), $description_key)};

	return $description->getValue() if ($description);
}

sub getCourseStaff {
	my $self = shift;
	my $course = $self->getContentCourse();
	my @directors = grep { $_->aux_info('roles') =~ m/Director/ } $course->child_users;
	my @authors = grep { $_->aux_info('roles') !~ m/Director/ 
				&& $_->aux_info('roles') =~ m/Author/ } 
				$course->child_users;

	my @assistants = grep { $_->aux_info('roles') !~ m/(Director|Author)/ 
				&& $_->aux_info('roles') =~ m/Teaching Assistant/ } 
				$course->child_users;
	my @lecturers = (@directors,@authors);
	return (\@lecturers, \@assistants);
}

sub getCourseObjectives {
	my $self = shift;
	my $course = $self->getMetadataCourse();
	return $course->child_objectives();
}

sub getAdditionalMetadata{
	my $self = shift;
	my $course = $self->getContentCourse();
	my @content = grep { &titleMatch($_->title, 'Additional Metadata') } $course->child_content();
	if (@content){
		$content[0]->xsl_stylesheet($ENV{'XSL_ROOT'}.'/OCW/Document.xsl');
		return $content[0]->out_html_body();
	} 
	return '';


}

sub getCourseCalendar {
	my $self = shift;
	my $course = $self->getContentCourse();
	my @meetings = $course->class_meetings($self->getTimePeriod());
	my $calendarDates = TUSK::OCW::OcwCalendarConfig->lookup(" ocw_course_config_id = ".$self->getPrimaryKeyID(),
		['calendar_date'],undef);
	return (\@meetings,$calendarDates);
} 

sub getContent {
	my $self = shift;
	unless ($self->{-complete_content}){
	    my %contentHash;
		foreach my $courseOption (@folderCoursePages){
			%contentHash = (%contentHash, map { $_->primary_key(), { 'content' => $_, 'course_page' => $courseOption }  }  
				@{$self->getFolderContent($courseOption, 1)});
		}

	        my $classMeetingContentType = TUSK::Core::ClassMeetingContentType->lookup("1=1");
		my %classMeetingContentTypeHash = map { ($_->getPrimaryKeyID(), $_->getLabel() )} @$classMeetingContentType;
		my ($meetings,$calendar) = $self->getCourseCalendar();
		%contentHash = (%contentHash, map { ( $_->primary_key, {'content' => $_, 'course_page' => $classMeetingContentTypeHash{$_->aux_info('class_meeting_content_type_id')} } ) } map { $_->child_content() } @{$meetings});  
		%contentHash = (%contentHash, map { ( $_->primary_key(), {'content' => $_, 'course_page' => $classMeetingContentTypeHash{$_->aux_info('class_meeting_content_type_id')} } ) } 
			map { @{$_->getContent} } @{$calendar});
		my @contentArray = map { $contentHash{$_} } (keys %contentHash);
		$self->{-complete_content} =  \@contentArray;
	}

	return $self->{-complete_content};
}

#######################################################

=item B<getFolderContent>

	$arr_ref = $obj->getFolderContent(FOLDER_TYPE[, 1] );

    Return all of the content within the folder titled as 'FOLDER_TYPE'.
    If a second param of "1" is passed, then the caller is expecting that
    there might be multiple directories with the same name, and wants the 
    content from all appropriately titled folders. This was implemented
    because some courses have hundreds of 'Resources'. To place hundreds
    of pieces of content in one directory in tusk can make maintenance 
    difficult and slow. This enables the content to be split amongst 
    several collections with the same name. 

=cut
sub getFolderContent {
	my $self = shift;
	my $folderName = shift;
	my $getDups = shift;

	$folderName = $coursePageLabels{$folderName} || $folderName;
	my $content_course = $self->getContentCourse();
	if (!$self->hasFolder($folderName)){
		return [];	
	}

	my @child_content = ();
	foreach my $content ($content_course->child_content){
		if (&titleMatch($content->title, $folderName)){
			push @child_content, $content->child_content();
			last unless $getDups;
		}

	}
	return [@child_content];
}

sub getFolderHeader{
	my $self = shift;
	my $contentType = shift;
	return '' unless ($contentType);
	my $content = $self->getFolderContent($contentType);
	my @headerContent = grep { &titleMatch($_->title, 'Instructions') or $_->title eq 'Instructions' } @{$content};
	if (@headerContent){
		return $headerContent[0]->out_html_body();
	}
	return '';

}

sub getTimePeriod {
	my $self = shift;
	return HSDB45::TimePeriod->new(_id=>$self->getTimePeriodID(),
                _school=>$self->getMetadataSchoolID());

}
sub getCourseTitle {
	my $self = shift;
	return sprintf("%s, %s",$self->getCourseLabel(), $self->getTimePeriod()->period());
}

sub getCourseLabel {
	my $self = shift;
	my $course = $self->getContentCourse();
	my $title = $course->title();
	$title =~ s/OCW: ?//;
	return $title;
}

sub getSchoolName {
	my $self = shift;
	my $school = $self->getSchoolObject();
	if ($school){
		return $school->getSchoolLabel();
	}
	return "No school defined";

}

sub getSchoolObject{
    my $self = shift;
    return $self->getJoinObject("TUSK::OCW::OcwSchool");
}

sub getContentCourse{
	my $self = shift;
        unless ($self->{-content_course}){
                $self->{-content_course} = HSDB45::Course->new(_id=>$self->getContentCourseID(),
                        _school=>$self->getContentSchoolID());
		if (!defined($self->{-content_course}->primary_key)){
			confess "Content Course not valid for id #:".$self->getPrimaryKeyID();
		}
        }
        return  $self->{-content_course};
}

sub getMetadataCourse{
        my $self = shift;
        unless ($self->{-metadata_course}){
                $self->{-metadata_course} = HSDB45::Course->new(_id=>$self->getMetadataCourseID(),
                        _school=>$self->getMetadataSchoolID());
                if (!defined($self->{-metadata_course}->primary_key)){
                        confess "Metadata Course not valid for id #:".$self->getPrimaryKeyID();
                }
        }
        return  $self->{-metadata_course};
}

sub getTotalTime {
	my $self = shift;
	my $course = $self->getContentCourse();
	my $timeperiod = $self->getTimePeriod;
	my ($course_id,$startDate,$endDate,$db) = ($course->primary_key,
		$timeperiod->start_date(),$timeperiod->end_date(),$course->school_db());
	($startDate,$endDate) = map { $_->out_mysql_date } ($startDate,$endDate) ;
	my $stmt = <<EOM;
	SELECT HOUR(SEC_TO_TIME(SUM(TIME_TO_SEC(endtime) - TIME_TO_SEC(starttime)))) 
FROM $db.class_meeting
WHERE course_id = $course_id  
AND meeting_date BETWEEN '$startDate' AND '$endDate'
EOM

	my $sth = $self->databaseSelect($stmt);
	my ($totalTime) = $sth->fetchrow_array;
	$sth->finish;
	return $totalTime;

}

sub hasFolder{
	my $self = shift;
	my $name = shift;
	my $content_course = $self->getContentCourse();
	foreach my $content ($content_course->child_content){
	    if (&titleMatch($content->title, $name)){
		if (scalar($content->child_content)){
		    return 1;
		}else{
		    return 0;
		}
	    }
	}
	return 0;
}

sub titleMatch{
    my ($title, $match) = @_;

    if ($title eq "$FolderPrefix $match"){
	return 1;
    }
    else{
	return 0;
    }
}

sub hasCourseHome {
	return 1;
}

sub hasSyllabus	{
	return 1;

} 
sub hasCalendar{
	return 1;

} 
sub hasLectureNotes{
	my $self = shift;
	if ($self->hasFolder('Lecture Documents')){
		return 1;
	}
	if ($self->hasFolder('Lecture Slides')){
		return 1;
	}
	return 0; 
} 

sub hasSeminarNotes{
	my $self = shift;
	if ($self->hasFolder('Seminar Documents')){
		return 1;
	}
	if ($self->hasFolder('Seminar Slides')){
		return 1;
	}
	return 0; 
} 

sub hasLabs{
	my $self = shift;
	if ($self->hasFolder('Labs')){
		return 1;
	}
	return 0; 
} 

sub hasStudentWork{
	my $self = shift;
	if ($self->hasFolder('Student Work')){
		return 1;
	}
	return 0; 
}

sub hasCases{
    my $self = shift;
    if ($self->hasFolder('Cases')){
	return 1;
    }
    return 0; 
}

sub hasExams{
    my $self = shift;
    if ($self->hasFolder('Exams')){
	return 1;
    }
    
    return 0;
}

sub hasExamsAndQuizzes{
    my $self =shift;
    
    if ($self->hasFolder('Exams and Quizzes')){
	return 1;
    }
    
    return 0; 
}

sub hasReadings{
    my $self = shift;

    my ($meetings,$calendarConfigs) = $self->getCourseCalendar();
    my $class_meeting_content_types = TUSK::Core::ClassMeetingContentType->new()->lookup("label = 'Readings'");
    return 0 unless (scalar(@$class_meeting_content_types));
    my $contentTypeID = $class_meeting_content_types->[0]->getPrimaryKeyID();
    return 0 unless ($contentTypeID);

    foreach my $meeting (@$meetings){
	if (scalar($meeting->child_content("class_meeting_content_type_id = $contentTypeID"))){
	    return 1;
	}
    }

    foreach my $calendarConfig (@$calendarConfigs){
	if (scalar($calendarConfig->getContent($contentTypeID))){
	    return 1;
	}
    }

    return 0;
} 

sub hasAssignments{
	my $self = shift;
	if ($self->hasFolder('Assignments')){
		return 1;
	}
	return 0; 

} 

sub hasSmallGroups{
        my $self = shift;
        if ($self->hasFolder('Small Groups')){
                return 1;
        }
        return 0;
}

sub hasStudentNotes {
        my $self = shift;
        if ($self->hasFolder('Student Notes')){
                return 1;
        }
        return 0;
}

sub hasLectureHandouts {
        my $self = shift;
        if ($self->hasFolder('Lecture Handouts')){
                return 1;
        }
        return 0;
}

sub hasActivities {
        my $self = shift;
        if ($self->hasFolder('Activities')){
                return 1;
        }
        return 0;
}

sub hasLessons {
        my $self = shift;
        if ($self->hasFolder('Lessons')){
                return 1;
        }
        return 0;
}

sub hasTopics {
        my $self = shift;
        if ($self->hasFolder('Topics')){
                return 1;
        }
        return 0;
}

sub hasLearningUnits {
        my $self = shift;
        if ($self->hasFolder('Learning Units')){
                return 1;
        }
        return 0;
}

sub hasImageGallery {
        my $self = shift;
        if ($self->hasFolder('Image Gallery')){
                return 1;
        }
        return 0;
}

sub hasSupplementaryMaterial{
        my $self = shift;
        if ($self->hasFolder('Supplementary Material')){
                return 1;
        }
        return 0;
}

sub hasCourseDocuments{
        my $self = shift;
        if ($self->hasFolder('Course Documents')){
                return 1;
        }
        return 0;
}

sub hasTools{
        my $self = shift;
        if ($self->hasFolder('Tools')){
                return 1;
        }
        return 0;
}

sub hasProjects{
	my $self = shift;
	if ($self->hasFolder('Projects')){
		return 1;
	}
	return 0; 
}

=head1 BUGS

None Reported.

=head1 SEE ALSO

B<TUSK::Core::SQLRow> - parent class

=head1 AUTHOR

TUSK Development Team <tuskdev@tufts.edu>

=head1 COPYRIGHT

Copyright (c) Tufts University Sciences Knowledgebase, 2004.

=cut

1;

