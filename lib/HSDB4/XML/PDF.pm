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


package HSDB4::XML::PDF;

use strict;
use Carp;

use HSDB45::Course;
use TUSK::Constants;

our $domain = "http://$ENV{SERVER_NAME}:$ENV{SERVER_PORT}";
our $tufts_icon = "$domain/icons/little/alhsdb4-style.gif";

sub generate_slide_xml{
	my $doc = shift;
	my $other_location = shift;
	if (!$doc) {
		confess "A content object is a required parameter";
	}
        my @content = $doc->child_content;
        my $authors = "";
        my $xml = "";
        foreach (@content){
            next unless ($_->field_value('type') eq 'Slide');
	    if ($other_location){
		## we don't want overlays in PDFs for now
		#my $overlay = $_->overlay_data();
		#if ($overlay){
		#    $bin_id = $overlay->primary_key();
		#}else{
		#    my $large = $_->large();
		#    $bin_id = $large->primary_key();
		#}
		
		$xml .= $_->out_xml($other_location . $_->primary_key() . "_large.jpg");
	    }else{
                $xml.=$_->out_xml;
	    }
                my @users  = $_->child_users;
                my @non_users = $_->child_non_users;
                push(@users,@non_users);
                next unless (@users);
                foreach my $user (@users){
                        next unless ($user->aux_info('roles') eq "Author");
                        my $author_name=$user->out_short_name;
                        unless ($authors=~/$author_name/){
                                unless ($authors){
                                        $authors=$author_name;
                                }else{
                                        $authors.=", ".$author_name;
                                }
                        }
                }
        }

	my $copyright;
        ($copyright=$doc->field_value("copyright"))=~s/"/\\"/g;
        my $title=$doc->field_value("title");
        $title=~s/"//g;
        $title =~ s/<br>/\n/g;
        $title =~ s/</\&lt;/g;
        $title =~ s/>/\&gt;/g;

        $authors=~s/"/\&quot;/g;
        $copyright=~s/"/\&quot;/g;
        
        $xml=~s/([\x80-\xff])/sprintf("\&#%d;",ord($1))/eg;
	
	$xml =~ s/&amp;#(\d+);/&#$1;/g;

	my $course_name;

	my $course = $doc->course();
	if ($course && $course->primary_key()){
	    $course_name = $course->title();
	}
        if ($xml){
	    return '<?xml version="1.0" encoding="utf-8"?>' . "\n" . 
		'<!DOCTYPE content SYSTEM "' . $TUSK::Constants::XMLRulesPath . 'hscmlpdf.dtd">' . "\n" . 
		"<COLLECTION NAME=\"".$title."\" 
                                COURSE=\"" . $course_name . "\"
                                AUTHOR=\"".$authors."\" 
                                COPYRIGHT=\"".$copyright."\"
                                ICONSOURCE=\"".$tufts_icon."\">\n".
				$xml.
				"</COLLECTION>";
        }else{
	    return;
        }
    }

1;
