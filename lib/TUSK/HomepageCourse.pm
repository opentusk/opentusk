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


package TUSK::HomepageCourse;

use strict;
use HSDB45::Course;
use TUSK::HomepageCategory;
use TUSK::ContentTree;

BEGIN {
    use base qw/HSDB4::SQLRow/;
    use vars qw($VERSION);    
    $VERSION = do { my @r = (q$Revision: 1.10 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
}

my $tablename = "homepage_course";
my $primary_key_field = "id";
my @fields = qw(id
		course_id
		category_id
		sort_order
                label
		indent
		show_date
		hide_date
		last_changed
		url
                modified);

sub new {
    # Find out what class we are
    my $incoming = shift;
    # Call the super-class's constructor and give it all the values
    my $self = $incoming->SUPER::new ( _tablename => $tablename,
				       _fields => \@fields,
				       _primary_key_field => $primary_key_field,
				       @_);
    # Finish initialization...
    return $self;
}

# This is overloaded to allow the object_selection_box to operate on compound fields from the database.
sub field_value {
    my ($self, $field, $val, $flag) = @_;

	if ( $field eq "formatted_course" ) {
		return $self->get_url if $self->get_url;
		return $self->get_course->out_label;
	} elsif ( $field eq "formatted_label" ) {
		return "&nbsp;"x($self->get_indent*3) . $self->get_label;
	} elsif ( $field eq "displaying" ) {
		return "Yes" if $self->isCurrent;
		return "No";
	}

	return $self->SUPER::field_value($field, $val, $flag);
}

sub split_by_school {
    return 1;
}

sub get_course_id {
    my $self = shift;
    return $self->field_value("course_id");
}

sub get_category_id {
    my $self = shift;
    return $self->field_value("category_id");
}

sub get_label {
    my $self = shift;
    return $self->field_value("label");
}

sub get_indent {
    my $self = shift;
    return $self->field_value("indent");
}

sub get_show_date {
    my $self = shift;
    return $self->field_value("show_date");
}

sub get_hide_date {
    my $self = shift;
    return $self->field_value("hide_date");
}


sub get_sort_order {
    my $self = shift;
    return $self->field_value("sort_order");
}

sub get_last_changed {
    my $self = shift;
    return $self->field_value("last_changed");
}

sub get_last_changed_unix_timestamp {
    my $self = shift;
    my $dt = HSDB4::DateTime->new;
    $dt->in_mysql_timestamp($self->get_last_changed);
    return $dt->out_unix_time;
}

sub get_url {
    my $self = shift;
    return $self->field_value("url");
}

sub get_course {
    my $self = shift;
    ## return the Course object associated with this HomepageCourse
    return HSDB45::Course->new(_school => $self->school, _id => $self->get_course_id);
}

sub get_category {
    my $self = shift;
    ## return the Category object for this particulary HomepageCourse
    return TUSK::HomepageCategory->new(_school => $self->school, _id => $self->get_category_id);
}

sub update_last_changed {
    # sub has been updated to use new ContentTree it has not been tested as this sub is not used anywhere --Paul
    my $self = shift;
    ## grab all content on Course page
    my $course = $self->get_course;
    my (@child_content) = $course->child_content;
    ## find the most recently updated piece of content and set our time to that    
    ## get a tree of all content linked to the course that has been updated in last three days
    my $tree = TUSK::ContentTree->new(\@child_content);
    my @branches = $tree->{branches};
    print $course->out_label . "(" . $course->primary_key . ") - " . scalar @branches . " items\n";
    foreach (sort {$b->{content}->modified cmp $a->{content}->modified} @branches) {
	print $_->{content}->out_label," - ",$_->{content}->modified->out_mysql_timestamp,"\n";
	last;
    }
}

sub isCurrent {
	# Check to see if today is between start and end date
	my $self = shift;

	my $now = time();
	my $showDT;
	if($self->get_show_date) {$showDT = HSDB4::DateTime->new()->in_mysql_date($self->get_show_date);}
	my $hideDT;
	if($self->get_hide_date) {$hideDT = HSDB4::DateTime->new()->in_mysql_date($self->get_hide_date);}
	

	# if we dont have a show date or an end date were not displaying
	unless($showDT || $hideDT) {return 0;}

	# if we have a show date in the future then we cant display
	if($showDT && ($showDT->out_unix_time > $now)) {return 0;}

	# if we have a hide date in the past then we cant display
	if($hideDT && ($hideDT->out_unix_time <= $now)) {return 0;}

	# Well we have a show or hide date and were within the range so we are all set to display
	return 1;
}

1;
