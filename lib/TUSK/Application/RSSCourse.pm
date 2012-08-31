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


package TUSK::Application::RSSCourse;

use strict;
use HSDB4::Constants;
use TUSK::Constants;
use TUSK::Core::ServerConfig;
use HSDB4::SQLRow::User;
use HSDB4::SQLRow::Content;


##----------------------------------------------------------
##----------------------------------------------------------
## this sub controls the overarching process given a course id and school
## it will create a feed for a course

sub runProcess {

my $x = shift;
my $r = Apache2::Request->new();
my $crsID = shift;
my $cSchool = shift;

my $course = HSDB45::Course->new(_school => $cSchool )->lookup_key($crsID);
my @allchildren = $course->active_child_content();
my @allContent;

$r->content_type("application/xml");

#the name of the RSS file is a concat of the course ID and the course school
my $filename = $TUSK::Constants::FeedPath . "/".$course->course_id."_".$course->school.".rss";

# define the school/id prefix for the URL
my $prefix = getPrefix($cSchool, $crsID);

my $link = "$ENV{'HOSTNAME'}/view/course/".$course->school."/".$course->course_id;

createRSSBegin($link,$course->title,$course->school);

my $refchildren = \@allchildren;
my $refallcontent = \@allContent;


traverse($prefix,$refchildren,$refallcontent);


my $allSize = @allContent;

my @sortedContent = sort by_date(@allContent);

for (my $i=0; $i< $allSize; $i++)
{
    createRSSItem($sortedContent[$i]);
}

createRSSEnd($filename);

 }


#---------------------------------------
#---------------------------------------
# this sub checks to see if a collection is a podcast 
sub remoteCheckPodcast{
	my $self = shift;
	my $crsID = shift;
	my $cSchool = shift;
	my $colID = shift;
	my $course = HSDB45::Course->new(_school => $cSchool )->lookup_key($crsID);
	my $content = HSDB4::SQLRow::Content->new->lookup_key($colID);
	my $val = 0;

	if ($course->field_value("rss") == 1 && $content->type() eq "Collection"){
		my @temparray = $content->active_child_content();
		$val =  allMedia(\@temparray); 
	}
	return $val;
}


#----------------------------------------
# given a collection in a course, this sub will create an appropriate feed
sub processCollection {
	my $self = shift;
	my $course_id = shift;
	my $school_name = shift;
	my $colID = shift;
	my $isPOD = shift;

	my $content = HSDB4::SQLRow::Content->new->lookup_key($colID);

	my $r = Apache2::Request->new();
	$r->content_type("application/xml");

	my @temparray = $content->active_child_content();
	my @children = $content->active_child_content();
	my @allsubcont;

	my $prefix = getPrefix($school_name, $course_id);

	traverse($prefix,\@children,\@allsubcont);

	my @sortedSubContent = sort by_date(@allsubcont);
	my $childrenAreMedia = allMedia(\@temparray);
		
	if ($childrenAreMedia && $isPOD == 1 ){	
		createPodcastBegin("$TUSK::Constants::Domain/view/content/$prefix/$colID", $content->title(),$content->type());
	} 
	else {
		createRSSBegin("$TUSK::Constants::Domain/view/content/$prefix/$colID", $content->title(),$content->type());
	}

	foreach my $subcontent (@sortedSubContent){
		if ($childrenAreMedia && $isPOD == 1){
			createPodcastItem($subcontent);
		}
		else {
			createRSSItem($subcontent);
		}
	}
	
	createRSSEnd();
	
} 


#-------------------------------------------------------------
#-------------------------------------------------------------
# this sub figures out if all the contents in a collection are media files or not
# if they are, returns 1, if not returns 0

sub allMedia{
    my ($refcollection) = @_;
	
	# if collection has no children, cannot syndicate.
    my $val = (scalar @$refcollection)? 1 : 0;
    
    #look through all content of given collection, if any items are not audio or video
    #immediately return 0 and exit since this wont be podcasted
    #otherwise if it makes it through all the children, return 1 and podcast the collection
	foreach my $content (@$refcollection){
		if($content->type() ne "Audio" && $content->type() ne "Video"){
			$val= 0;
			last;
		}
	}
	return $val;

}

##----------------------------------------------------------
# this sub is just a tool i use to print interesting data when/if i need it 

sub debugInfo
{
    my $cid = shift;
    my $csch = shift;

   
    open (RSSdebug, ">> " . $TUSK::Constants::FeedPath . "/debugInfo.txt") or die "cannot open file $!\n";
    #print RSSdebug "courseid is $cid\n";
    #print RSSdebug "school is $csch\n";
    #print RSSdebug "<rss version='2.0' xmlns:dc='http://purl.org/dc/elements/1.1/'>\n";
    #print RSSdebug "<channel>\n";
    close (RSSdebug) or die "RSStest didnt close: $!\n";
    
}



##----------------------------------------------------------
# this sub is used to order an array by date

sub by_date {
 
    return ( $b->{"modified"} cmp $a->{"modified"} );
}



##---------------------------------------------------------
# this sub recurses through content, creating the appropriate url references for our feeds
# and returning the array refall in the proper order we need for our feed

sub traverse
{
  
    my ($parentTitle,$refchildrn, $refall) = @_;
    my $famSize = $#{$refchildrn};
    push(@$refall,@$refchildrn);   
   
    
    for (my $i=0; $i < $famSize+1; $i++)
    {
        
        ${$refchildrn}[$i]{url} = $parentTitle."/".${$refchildrn}[$i]{content_id};

        if (${$refchildrn}[$i]{type} eq "Collection")
        {
                
            my @grandchildren = ${$refchildrn}[$i]->active_child_content();  
            traverse($parentTitle."/".${$refchildrn}[$i]{content_id}, \@grandchildren,$refall);
           
        }  
    
 
    }
}

##---------------------------------------------------------
# this sub creates the head part of an rss feed

sub createRSSBegin
{
   
 
    my ($link,$title,$description) = @_;
    print "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n";
    print "<rss version=\"2.0\">\n";
    print "<channel>\n";
    print "<title> ".encodeText($title)." </title> \n";
    print "<description> ".encodeText($description)." </description> \n";
    print "<link> http://$link </link>\n";

    
}

##---------------------------------------------------------
# this sub creates the head part of a podcast

sub createPodcastBegin
{
     
    my ($link,$title,$description) = @_;
 
  
    print  "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n";
    print  "<rss xmlns:itunes=\"http://www.itunes.com/dtds/podcast-1.0.dtd\" version=\"2.0\">\n";
    print  "<channel>\n";
    print  "<title> ".encodeText($title)." </title> \n";
    print  "<description> ".encodeText($description)." </description> \n";
    print  "<link> http://$link </link>\n";

}


##---------------------------------------------------------
# this sub simply adds the closing tags to a feed

sub createRSSEnd
{

    print "</channel>\n";
    print "</rss>\n";

}

##---------------------------------------------------------


##---------------------------------------------------------
# this sub adds a new item to an rss feed

sub createRSSItem
{
    my ($cntnt) = @_;
    my $link = "$TUSK::Constants::Domain/view/content/$cntnt->{url}"; 
    print "<item>\n";
    print "<title> ".encodeText($cntnt->{title})." </title>\n";
    print "<description> $cntnt->{school} : $cntnt->{type} </description>\n";
    print "<link> http://$link </link>\n";
    print "<pubDate> $cntnt->{modified} </pubDate>";
    print "</item>\n";

}


##---------------------------------------------------------
# this sub adds a new item to a podcast

sub createPodcastItem {
	my ($cntnt) = @_;

	my $body = $cntnt->body;
	my ($uri) = $body->tag_values ('realvideo_uri') if ($body);
	$uri = $uri->value;
	$uri = "/" . $uri unless ($uri=~/^\//);

	my $link= &TUSK::Core::ServerConfig::dbAudioHost;
	$link = "$link/download" . $uri;
  
	print "<item>\n";
	print "<title>".encodeText($cntnt->{title})." </title>\n";
	print "<description> $cntnt->{school} </description>\n";
	print "<enclosure url='$link' length='10' type=''/>\n";
	print "<guid>$link</guid>\n";
	print "<pubDate> $cntnt->{modified} </pubDate>";
	print "</item>\n";
}

sub getPrefix{
	my ($school_name, $course_id) = @_;

	my $prefix = HSDB4::Constants::code_by_school($school_name);
	$prefix = $prefix . $course_id . "C";
	return $prefix;
}

##----------------------------------------------------------
# this sub handles the proper escaping of certain characters for the feeds

sub encodeText
{

    my $text = shift;
    $text =~ s/>/&gt;/g;
    $text =~ s/&/&amp;/g;
    $text =~ s/</&lt;/g;
    return $text;
}

1;


