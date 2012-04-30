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


package TUSK::Application::DeleteContent;

use strict;

use HSDB4::SQLLink;
use HSDB4::SQLRow::Content;
use HSDB4::Constants;
use TUSK::Constants;

my $pw = $TUSK::Constants::DatabaseUsers->{ContentManager}->{writepassword};
my $un = $TUSK::Constants::DatabaseUsers->{ContentManager}->{writeusername};

sub process_delete {
	my $remove_content = shift;
	my $user_object_deleting_content = shift;
	my $parent_object = shift;
	my $contentIdsArrayRef = shift;

	my ($parent_id, $linkdef, @content_that_could_not_be_deleted, $userDeleting, @contentThatCouldNotBeDeleted);

	if($user_object_deleting_content) {$userDeleting = $user_object_deleting_content->primary_key();} else {$userDeleting = 'contentmanager';}

	unless($parent_object) {return(1, "You need to give me a parent object to delete the content from!");}

        if($parent_object->isa('HSDB45::Course')) {
		$parent_id = $parent_object->primary_key();
		$linkdef = $HSDB4::SQLLinkDefinition::LinkDefs{HSDB4::Constants::get_school_db($parent_object->school()) . "\.link_course_content"};
	} elsif ($parent_object->isa('HSDB4::SQLRow::Content')) {
		$parent_id = $parent_object->primary_key();
		$linkdef = $HSDB4::SQLLinkDefinition::LinkDefs{'link_content_content'};
	} else {return(2, "Trying to delete from an unknow parent object : (" . ref($parent_object) . ")");}

	unless($linkdef) {return(3, "Could not establish the linkdef!");}

	foreach my $content_id (@{$contentIdsArrayRef}) {
		my ($rval,$msg) = $linkdef->delete(-user =>$un, -password => $pw, -parent_id => $parent_id, -child_id => $content_id);
		#At some point we should put a check like this to make sure it actually got deleted!
#		unless($rval >= 1) {push @contentThatCouldNotBeDeleted, ($content_id, $msg);}

		my @links;
		# crazy logic to see if this content is linked anywhere
		if($remove_content) {
			@links = $HSDB4::SQLLinkDefinition::LinkDefs{'link_content_content'}->get_parents($content_id)->parents;
			if(scalar(@links) == 0) {
				foreach my $schooldb (map { HSDB4::Constants::get_school_db($_) } HSDB4::Constants::course_schools()) {
					@links = $HSDB4::SQLLinkDefinition::LinkDefs{"$schooldb\.link_course_content"}->get_parents($content_id)->parents;
					last if (scalar(@links));
				}
			}
			if(scalar(@links) == 0) {
				my $content = HSDB4::SQLRow::Content->new->lookup_key($content_id);
				$content->set_field_values(display => 0);
				$content->save_version("Content deleted", $userDeleting);
			} else {
				push (@content_that_could_not_be_deleted, $content_id);
			}
		}
	}

	my $error_msg = '';
	foreach(@content_that_could_not_be_deleted) {$error_msg .= " $_ - content had multiple links<br>\n";}
	foreach(@contentThatCouldNotBeDeleted) {$error_msg.= " " . $_[0] . " - " . $_[1] . "<br>\n";}
	if($error_msg) {return (4, "Unable to remove the following Content:<br>\n" . $error_msg);}
	return (0, "Content Deleted");
}


1;
