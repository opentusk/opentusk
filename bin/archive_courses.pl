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


#!/usr/bin/perl
use FindBin;
use lib "$FindBin::Bin/../lib";


###########
# this script was developed for Boston University and only for their specific
# implementation of TUSK. It is not recommended for other institutions to use.
#
# through command-line prompts, user selects a school, or all schools, and academic year.
# script will duplicate all active courses within that school; ie, all courses
# that do not have the string "Archive--AY" in their title - as this denotes
# an archive school. script prints course name to screen after it has been
# duped, as well as a count of any errors that occurred. an error log is also
# written to present directory with more detailed information.
###########

use strict;
use File::Copy;

use HSDB45::Course;
use HSDB4::Constants;
use TUSK::Constants;
use Sys::Hostname;
use TUSK::Course::CourseMetadata;
use TUSK::UploadContent;
use MySQL::Password;
use Data::Dumper;


my ($user_name, $password) = &get_user_pw();
&HSDB4::Constants::set_user_pw($user_name, $password);

my $unix_login = getpwuid($<) || "archive_script";
my @archive_schools;
my @archive_courses;
my $archive_title;
my %inserted_content;
my $home = $ENV{'HOME'} || $ENV{'LOGDIR'} ||
	    (getpwuid($<))[7] || die "You're homeless!\n";

#############
## get optional args from command line
use Getopt::Long;
my $GetOptArchiveSchool = 'archive';
my ($GetOptCourseID, $GetOptHelp);
$ENV{'DATABASE_ADDRESS'} = $TUSK::Constants::Servers{Sys::Hostname::hostname}->{'WriteHost'};


my $GetOptResult = GetOptions("course_id=i"      => \$GetOptCourseID,
                              "archive_school=s" => \$GetOptArchiveSchool,
                              "db_server=s"      => \$ENV{'DATABASE_ADDRESS'},
                              "help|h"           => \$GetOptHelp);

print_help() if $GetOptHelp;
##
#############

open(ERROR, ">>$home/archive_error_log") or die "couldn't open error log";
my $COURSE_ERROR_COUNT = 0;
my $COURSE_CONTENT_COUNT = 0;


@archive_schools = select_school();

$archive_title = select_archive_name();

if($GetOptCourseID){
	die "you provided a specific course id, but supplied more than one school." if(scalar(@archive_schools) > 1);
	push(@archive_courses, HSDB45::Course->new(_school => $archive_schools[0]->getSchoolName())->lookup_conditions("course_id=$GetOptCourseID"));
}
else {
	foreach my $school (@archive_schools){
		push(@archive_courses, HSDB45::Course->new(_school => $school->getSchoolName())->lookup_conditions(" title NOT LIKE '%Archive--AY%' "));
	}
}

foreach my $course (@archive_courses){
    
    print "Cloning: " . $course->primary_key() . " - " . $course->field_value('title'). "\n";

    $COURSE_ERROR_COUNT = 0;
    $COURSE_CONTENT_COUNT = 0;

    my $clone_course = &clone($course);

    my $clone_title =  $clone_course->field_value("title") . " " . $archive_title;

    $clone_course->field_value("title", $clone_title);

    my ($ret_value, $msg) = $clone_course->save();
    if ($ret_value < 0){
	# if we fail to clone course, don't clone any metadata, objectives, content, etc.
	print ERROR $msg . " : Failed to clone course: " . $course->field_value("title") . " (" . $course->primary_key() . " in " . $course->school() . " school)\n";
	$COURSE_ERROR_COUNT++;
	next;
    }

    &clone_objectives($course, $clone_course);
    &clone_teaching_sites($course, $clone_course);
    &clone_users($course, $clone_course);
    &clone_metadata($course, $clone_course);

    my @contents = $course->child_content();

    foreach my $content (@contents){
	&clone_content($content, $clone_course);
    }

    print "Completed Archiving Course: " . $course->field_value("title") . "\n";
    print "\tContent Cloned: $COURSE_CONTENT_COUNT\n";
    print "\tTotal Errors: $COURSE_ERROR_COUNT\n";

}

close ERROR;

###########
# duplicate objectives
sub clone_objectives{

    my ($original, $clone) = @_;
    my @objectives = $original->child_objectives();
    foreach my $objective (@objectives){
	my $clone_objective = &clone_and_save($objective);
	$clone->add_child_objective($user_name, $password, $clone_objective->primary_key(), $objective->aux_info("sort_order"));
    }
}

###########
# duplicate sites
sub clone_teaching_sites{
    my ($original, $clone) = @_;
    my @teaching_sites = $original->child_teaching_sites();
    foreach my $site (@teaching_sites){
	my ($r, $msg) = $clone->teaching_site_link()->insert(-user => $user_name, -password => $password,
							     -child_id => $site->site_id(),
							     -parent_id => $clone->primary_key(),
							     max_students => $site->aux_info("max_students"));
    }
}

###########
# duplicate users
sub clone_users{
    my ($original, $clone) = @_;
    my @users = $original->child_users();
    foreach my $user (@users){
	if (ref $clone eq "HSDB45::Course"){
	    #either you're a course
	    $clone->add_child_user($user_name, $password, $user->primary_key(), $user->aux_info("sort_order"), $user->aux_info("teaching_site_id"), $user->roles());
	} else {
	    # or, you're content
	    $clone->add_child_user($user_name, $password, $user->primary_key(), $user->aux_info("sort_order"), $user->roles());
	}
    }
}

###########
# duplicate metadata
sub clone_metadata{
    my ($original, $clone) = @_;
    my $tusk_course_id = $original->getTuskCourseID();
    my $tusk_clone_id = $clone->getTuskCourseID();
    my $obj = TUSK::Course::CourseMetadata->new();

    my $course_metadata = $obj->lookup("course_id = $tusk_course_id");

    foreach my $meta (@$course_metadata){
	my $clone_meta = &clone_tusk($meta);
	$clone_meta->setCourseID($tusk_clone_id);
	my $ret_value = $clone_meta->save({user=>$unix_login});
	if ($ret_value == -1){
	    print ERROR "Failed to save clone for metadata: " . $meta->getPrimaryKeyID() . "\n";
	    $COURSE_ERROR_COUNT++;
	}
    }
}

###########
# duplicate keywords
sub clone_keywords{

    my ($original, $clone) = @_;

    my $condition = $original->primary_key();
    my $links = TUSK::Core::LinkContentKeyword->lookup("parent_content_id = $condition");
    
    foreach my $link (@$links){
	my $obj = TUSK::Core::LinkContentKeyword->new();
	$obj->setParentContentID($clone->primary_key());
	$obj->setChildKeywordID($link->getChildKeywordID());
	$obj->setSortOrder($link->getSortOrder());
	my $ret_value = $obj->save({user=>$unix_login});
	if ($ret_value == -1){
	    print ERROR "Failed to save clone for keyword link: " . $link->getPrimaryKeyID() . "\n";
	    $COURSE_ERROR_COUNT++;
	}
    }
}

###########
# slides exist in binary_data table, so we need to copy those records, too
sub clone_binary_data {
    my ($original, $clone) = @_;
    my @fields = $original->fields();
    foreach my $field (@fields){
	if($field =~ /(data_id|thumbnail_id)/ && $original->field_value($field)){
	    my $bin_data = HSDB4::SQLRow::BinaryData->new()->lookup_key($original->field_value($field));
	    my $clone_bin_data = &clone_and_save($bin_data);
	    $clone->field_value($field,$clone_bin_data->primary_key());
	}
    }
    return $clone->save();
}

###########
# when cloning content that exists in file system, begin by copying the actual file.
# once this is done and file has uri, we update the 'uri' xml node in content table.
sub copy_file_and_update_uri {
    my ($original, $clone) = @_;

    my $type = lc($original->type());

    my $filepath = $original->out_file_path();
	    
    my $ext = substr($filepath,rindex($filepath,"."));

    my $clone_filename = $clone->primary_key() . $ext;
	    
    my $clone_filepath = ($type =~ /flashpix/)?
	                  $TUSK::UploadContent::path{$type} . $clone_filename 
			: $TUSK::UploadContent::path{$type} . "/" . $clone_filename;

    if ( -e $filepath ){
	unless(copy($filepath, $clone_filepath)) {
	    print ERROR "file copy failed for $filepath: $!\n";
	    $COURSE_ERROR_COUNT++;
	}
    } else {
	print ERROR "the file ($filepath) for originating content " . $original->primary_key() . " cannot be found on filesystem, so could not create new file $clone_filename.\n";
	$COURSE_ERROR_COUNT++;
    }

    # now, update uri
    my $uri_type = ($type =~ /downloadablefile/) ? "file" 
	         : ($type =~ /(audio|video)/)    ? "realvideo"
		 : $type;

    my $clone_uri;
    if($type =~ /shockwave/){
	# shockwave uri's all begin with /downloadable_file/
	$clone_uri = "/downloadable_file/" . $clone_filename;
    } elsif ($type =~ /flashpix/){
	$clone_uri = $filepath; 
	# remove the stuff that is common to flashpix uri's
	$clone_uri =~ s/$TUSK::UploadContent::path{$type}//;
	# now isolate the directory path before the filename
	$clone_uri = substr($clone_uri, 0, rindex($clone_uri,"/") + 1);
	# append clone file name to dir path
	$clone_uri .= $clone_filename;
    } else {
	# all other types just have file name in uri field
	$clone_uri = $clone_filename;
    }

    my $xml = $original->twig_body();

    my $twig = $xml->twig();
    my $root = $twig->root();

    unless ($root){
	print ERROR "Failed to update uri node of cloned body field with new filename. Reason: original content (id: " . $original->primary_key() . ") had a null or empty body field\n";
	$COURSE_ERROR_COUNT++;
	return;
    }

    # get the uri node from xml
    my $element = $root->first_child($uri_type . "_uri");
	    
    my $atts = $element->atts();

    # replace node with new one with clone uri
    $xml->replace_element_uri($clone_uri, $uri_type . "_uri");

    #since we replaced node, we need to re-insert all attributes (they were wiped out in replacement)
    foreach my $att_key (keys %$atts){
	$xml->replace_element_attribute($uri_type . "_uri",$att_key,$atts->{$att_key});
    }

    $clone->field_value("body",$xml->out_xml());
    return $clone->save();
}

###########
# duplicate content
sub clone_content{

    my ($content, $clone_parent) = @_;

    unless ( exists $inserted_content{$content->content_id()} ){
	
	# clone the content itself
	my $clone_content = &clone($content);

	my $clone_course_id = (ref $clone_parent eq "HSDB45::Course")? $clone_parent->primary_key() : $clone_parent->field_value("course_id");

	# and give it the new course and school ids
	$clone_content->field_value("course_id",$clone_course_id);
	$clone_content->field_value("school",$clone_parent->school());

	my $ret_value =	$clone_content->save();
	if ($ret_value == -1){
	    print ERROR "Failed to clone content and any children content (if applicable): " . $content->field_value("title") . " (" . $content->primary_key() . ")\n";
	    $COURSE_ERROR_COUNT++;
	    return;
	}

	# add content to our hash of cloned content, so we don't clone it again should it exist elsewhere
	$inserted_content{$content->content_id()} = $clone_content->primary_key();
	$COURSE_CONTENT_COUNT++;

	&clone_users($content, $clone_content);
	&clone_objectives($content, $clone_content);
	&clone_keywords($content, $clone_content);
	
	if($content->type() eq "Collection" || $content->type() eq "Multidocument"){
	    # recursively clone children content
	    my @children = $content->child_content();
	    foreach my $child (@children){
		&clone_content($child, $clone_content);			
	    }
	} elsif($content->type() =~ /Slide/){
	    # copy slides in binary_data table
	    my $ret_value = &clone_binary_data($content, $clone_content);
	    if ($ret_value == -1){
		print ERROR "Failed to update content's binary data fields: " . $content->field_value("title") . " (" . $content->primary_key() . ")\n";
		$COURSE_ERROR_COUNT++;	    
	    }
	} elsif($content->type() =~ /(Audio|Video|Flashpix|Shockwave|PDF|DownloadableFile)/){
	    # we need to copy actual files on fs, and update xml in "body" field of content db
	    my $ret_value = &copy_file_and_update_uri($content, $clone_content);
	    if ($ret_value == -1){
		print ERROR "Failed to update content's uri field: " . $content->field_value("title") . " (" . $content->primary_key() . ")\n";
		$COURSE_ERROR_COUNT++;	    
	    }	    
    	}
    }
    # add this child content to our cloned parent
    $clone_parent->add_child_content($user_name,$password,$inserted_content{$content->content_id()},$content->aux_info("sort_order"),$content->aux_info("label"));
}

###########
# get academic year from user and insert it into archive title. return it.
sub select_archive_name{
    
    my $input;
    my $confirm;
    my $archive_suffix;

    do {

	do {
	    print "Please input an academic year that will be appended to all course titles (Ex. 06/07): ";
    	    chomp($input = <>);
	} while $input !~ /\d\d\/\d\d/;

	$archive_suffix = "(Archive--AY " . $input . ")";

	print "Based on your input, your archive suffix will be: $archive_suffix\nIs this what you want? (y/n)\n";
	chomp($confirm = <>);
	
    } while lc($confirm) ne "y";
    return $archive_suffix;
}

###########
# get all schools on system and list them for user with last option being "ALL".
# insure that user selects a valid selection number and return array of all schools
# or selected single school.
###########
sub select_school {

	my $school_selection;
	my $confirmation;
	my $schools;
	my $num_schools;

    do{
	print "\n\n\nPlease select which school's courses you would like to archive by supplying the school's number from the list below.\n\n";

	$schools = TUSK::Core::School->new->lookup("",["school_name ASC"],["DISTINCT school_name"]);

	$num_schools = @$schools;
	
	for(my $i=0; $i<$num_schools; $i++){
	    print " " if $i < 10;
	    print "$i. " . $schools->[$i]->getSchoolName() . "\n";
	}

	print $num_schools . ". [All Schools]\n" ;

	print "\nYour selection: ";

	chomp($school_selection = <>);

	while($school_selection > $num_schools){
	    print "Invalid input. Please select a valid course index:";
	    chomp($school_selection = <>);
	}

	my $school_name = ($school_selection == $num_schools)? "All Schools" : $schools->[$school_selection]->getSchoolName();

	print "You selected: " . $school_name . "\n";

	print "Is this correct (y/n): ";

	chomp($confirmation = <>);

    } while lc($confirmation) ne "y";

    if($school_selection < $num_schools){
	return $schools->[$school_selection];
    } else {
	return @$schools;
    }
}


sub clone_and_save{
    my $self = shift;
    my $clone = &clone($self);
    my $ret_value = $clone->save();
    if ($ret_value == -1){
	print ERROR "Failed to save clone for: " . $self->primary_key() . "\n";
	$COURSE_ERROR_COUNT++;
    }
    return $clone;
}

sub clone{
    my ($obj) = @_;
    my $class = ref($obj);
    my %clone_args = ();
    if ($class =~ /^HSDB45/){
	$clone_args{_school} = $GetOptArchiveSchool;
    }
    my $clone = $class->new(%clone_args);
    my @time = localtime();

    my @fields = $obj->fields();
    foreach my $field (@fields){
	next if ($field eq $obj->primary_key_field());
	next if ($field =~ /(modified|modifiedon|modified_on)/);
	if ($field =~ /(created|createdon|created_on)/){
	    $clone->field_value($field, sprintf ("%d-%d-%d %d:%d:%d", $time[5]+1900, $time[4]+1, $time[3], $time[2], $time[1], $time[0])); 
	    next;
	}
	$clone->field_value($field, $obj->field_value($field));
    }
    return $clone;
}

sub clone_tusk_and_save{
    my $self = shift;
    my $clone = &clone_tusk($self);
    my $ret_value = $clone->save({user=>$unix_login});
    if ($ret_value == -1){
	print ERROR "Failed to save clone for: " . $self->getPrimaryKeyID() . "\n";
	$COURSE_ERROR_COUNT++;
    }
    return $clone;
}

sub clone_tusk{
    my ($obj) = @_;
    my $class = ref($obj);
    my $clone = $class->new();

    my $fields = $obj->getAllFields();
    foreach my $field (@$fields){
	next if ($field eq $obj->getPrimaryKey());
	next if (
	 ($field =~ /(modified_by|modified_on)/)
	 or 
	 ($field =~ /(created_by|created_on)/)
	 );
	$clone->setFieldValue($field, $obj->getFieldValue($field));
    }
    return $clone;
}

sub print_help{

    print <<EOM;

    Before this script is run, be sure that "Archive School" has already been created with /bin/create_school.pl.

    Should you need to run that script, be sure to use following values:
    School Display: Archive School
    School Name: Archive
    School DB: archive

    The inputs necessary to successfully run arhive_school_courses are:
        ** the school whose courses should be archived
        ** the academic year being archived: for example, 06/07

    The script will prompt for these inputs, validate them, and ask user to confirm them.
    
    Additionally, there are a few args that can be passed on command line:
 
        --help will bring up this help menu

        --archive_school will enable user to specify the school they want the archived course(s) to be entered into. By default, the school will be 'archive'.

        --course_id enables user to pass in only 1 course_id in order to archive only 1 course

        --db_server enables user to override DATABASE_ADDRESS specified in TUSK::Constants for server that is host of script. If this param is not passed for this execution of script, the value will be: $ENV{'DATABASE_ADDRESS'}

EOM
    exit 1;
}
