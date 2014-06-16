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


package HSDB45::ClassMeeting;

use strict;

BEGIN {
    use base qw/HSDB4::SQLRow/;
    require HSDB4::SQLLink;

    use vars qw($VERSION);
    
    $VERSION = do { my @r = (q$Revision: 1.40 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
}

sub version { return $VERSION }

# dependencies for things that relate to caching
my @mod_deps  = ('HSDB45::UserGroup',
		 'HSDB45::TimePeriod');
my @file_deps;

sub get_mod_deps {
    return @mod_deps;
}

sub get_file_deps {
    return @file_deps;
}

use HSDB4::Constants qw(:school);
use HSDB4::DateTime;
use HSDB45::UserGroup;
use HSDB45::TimePeriod;
use TUSK::Constants;
use TUSK::Schedule::ClassMeetingObjective;
use TUSK::Schedule::ClassMeetingKeyword;
use TUSK::ClassMeeting::Type;
use GD;
use Text::Wrap qw(wrap $columns);
use TUSK::Competency::Competency;
use TUSK::Competency::ClassMeeting;
use TUSK::Competency::Content;


# Non-exported package globals go here
use vars ();

# File-private lexicals
my $UserID = $TUSK::Constants::DatabaseUsers{ContentManager}->{writeusername} ;
my $Password = $TUSK::Constants::DatabaseUsers{ContentManager}->{writepassword} ; 
my $tablename = "class_meeting";
my $primary_key_field = "class_meeting_id";

my @fields = qw(class_meeting_id title oea_code course_id type_id
                meeting_date starttime endtime location is_duplicate
                is_mandatory modified flagtime body);
my %blob_fields = (body => 1);
my %numeric_fields = ();

my %cache = ();


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

# static method to check class meeting types
sub get_type_obj{
	my ($self, $type_lbl, $school_id) = @_;

	return TUSK::ClassMeeting::Type->new()->lookupReturnOne("school_id=$school_id AND label='$type_lbl'");
}

sub split_by_school { return 1; }

#
# >>>>> Linked objects <<<<<
#

sub objective_link {
	my $self = shift;
	return TUSK::Schedule::ClassMeetingObjective->new();
}

sub child_objectives {
	#
	# Get the objectives linked down from this class_meeting
	#

	my $self = shift;
	my $ignore_cache = shift;
	# Check cache...
	if ( !defined($self->{-child_objectives}) || $ignore_cache ) {
		$self->{-child_objectives} = 
			$self->objective_link()->getObjectivesByClassMeeting($self->course->get_school()->getPrimaryKeyID(), $self->primary_key);
	}
	# Return the list
	
	return $self->{-child_objectives};
}

sub child_competencies {
        #
	# Get the competencies(objectives) linked from this class_meeting
	#

	my $self = shift;
	
	my $school_id = $self->course->get_school()->getPrimaryKeyID();
	my $class_meeting_id = $self->primary_key;
	my $competencies = TUSK::Competency::Competency->lookup( "school_id = $school_id", ['competency_class_meeting.sort_order', 'competency.competency_id'], undef, undef,
				[TUSK::Core::JoinObject->new("TUSK::Competency::ClassMeeting", {joinkey => 'competency_id', origkey => 'competency_id', jointype => 'inner', joincond => "class_meeting_id = $class_meeting_id"})]);
	
	return $competencies;
}

sub child_competencies_from_linked_content {
        #
	# Get the competencies(objectives) linked from this class_meeting including those from related content
	#
        my $self = shift;
	
	my $school_id = $self->course->get_school()->getPrimaryKeyID();
	my $class_meeting_id = $self->primary_key;

        my $dbh = HSDB4::Constants::def_db_handle();
	my $school = TUSK::Core::School->new()->lookupReturnOne("school_id = 1");
	my $school_db = $school->getSchoolDb();
	my $sql = qq(SELECT child_content_id FROM $school_db.link_class_meeting_content WHERE parent_class_meeting_id = $class_meeting_id);
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	my $linked_content_ids = $sth->fetchall_arrayref();
	
	my @linked_content_competencies;
	
	foreach my $content_id (@{$linked_content_ids}) {
	    my $competencies = TUSK::Competency::Competency->lookup('', ['competency_content.sort_order', 'competency.competency_id'], undef, undef,
				[TUSK::Core::JoinObject->new("TUSK::Competency::Content", {joinkey => 'competency_id', origkey => 'competency_id', jointype => 'inner', joincond => "content_id = $content_id->[0]"})]);

	    push @linked_content_competencies, $competencies;
        }
	
	return \@linked_content_competencies;
}


sub keyword_link {
    my $self = shift;
    return TUSK::Schedule::ClassMeetingKeyword->new();
}

sub child_keywords {
	#
	# Get the keywords linked down from this class_meeting
	#

	my $self = shift;
	# Check cache...
	my $ignore_cache = shift;
	if ( !defined($self->{-child_keywords}) || $ignore_cache ) {
		$self->{-child_keywords} = 
			$self->keyword_link()->getKeywordsByClassMeeting($self->course->get_school()->getPrimaryKeyID(), $self->primary_key);
	}
	# Return the list
	return $self->{-child_keywords};
}

sub child_author_defined_keywords {
	#
	# Get just the author-defined keywords linked down from this class_meeting
	#

	my $self = shift;
	# Check cache...
	my $ignore_cache = shift;
	if ( !defined($self->{-child_author_defined_keywords}) || $ignore_cache ) {
		$self->{-child_author_defined_keywords} = 
			$self->keyword_link()->getAuthorDefinedKeywordsByClassMeeting($self->course->get_school()->getPrimaryKeyID(), $self->primary_key);
	}
	# Return the list
	return $self->{-child_author_defined_keywords};

}

sub child_umls_concepts {
	#
	# Get the UMLS concepts linked down from this class_meeting
	#

	my $self = shift;
	# Check cache...
	my $ignore_cache = shift;
	if ( !defined($self->{-child_umls_concepts}) || $ignore_cache ) {
		$self->{-child_umls_concepts} = 
			$self->keyword_link()->getUmlsConceptsByClassMeeting($self->course->get_school()->getPrimaryKeyID(), $self->primary_key);
	}
	# Return the list
	return $self->{-child_umls_concepts};
}

sub user_link {
    my $self = shift;
    my $db = $self->school_db();
    return $HSDB4::SQLLinkDefinition::LinkDefs{"$db\.link_class_meeting_user"};
}

sub child_users {
    #
    # Get the user linked down from this class_meeting
    #

    my $self = shift;
    # Check cache...
    unless ($self->{-child_users}) {
        # Get the link definition
        # And use it to get a LinkSet of users
        $self->{-child_users} = $self->user_link()->get_children($self->primary_key);
    }
    # Return the list
    return $self->{-child_users}->children();
}

sub content_link {
    my $self = shift;
    my $db = $self->school_db();
    return $HSDB4::SQLLinkDefinition::LinkDefs{"$db\.link_class_meeting_content"};
}

sub child_content {
    #
    # Get the user linked down from this class_meeting
    #

    my $self = shift;
    my $cond = shift || " 1 = 1 ";
    # Get the link definition
    # And use it to get a LinkSet of content
    my $set = $self->content_link()->get_children($self->primary_key,$cond);
    my $path = sprintf("%s%dM", code_by_school( $self->school() ), $self->primary_key );
    foreach my $child ($set->children) {
        $child->set_aux_info ('uri_path', $path);
    }
    $self->{-child_content} = $set;
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

sub add_child_content {
	my $self = shift;
	my $params = shift;
	my $content_link = $self->content_link();
	my $content_id = $params->{'content_id'};
	my $content_type_id = $params->{'class_meeting_content_type_id'};
	delete $params->{'content_id'};
	if ($content_link->check_for_link($self->primary_key(),$content_id,
		" AND class_meeting_content_type_id = ".$content_type_id)){
		return (0,"Duplicate found.");
	}
	return $content_link->insert(-user=>$UserID,
				-password=>$Password,
				-child_id=>$content_id,
				-parent_id=>$self->primary_key(),
				%{$params} );

}


sub delete_child_content {
	my $self = shift;
	my $content_id = shift;
	my $content_link = $self->content_link();
	return $content_link->delete(-user=>$UserID,
                                -password=>$Password,
                                -child_id=>$content_id,
                                -parent_id=>$self->primary_key());
}
sub course {
    #
    # Get the course object
    #

    my $self = shift;
    # Check cache
    return $self->{-course} if $self->{-course};
    my $course = HSDB45::Course->new( _school => $self->school(),
				      _id => $self->field_value('course_id') );
    return $self->{-course} = $course;
}

sub user_groups {
    #
    # Get the user_group to which this class meeting must apply
    #

    my $self = shift;
    # Check cache
    return @{$self->{-user_groups}} if $self->{-user_groups};
    my $blank_tp = HSDB45::TimePeriod->new( _school => $self->school() );
    my @tpids = 
	map { $_->primary_key() } $blank_tp->time_periods_for_date( $self->meeting_date() );
    my @user_groups = $self->course()->child_user_groups( @tpids );
    $self->{-user_groups} = \@user_groups;
    return @user_groups;
}


#                                   #
# >>>>> Field Accessor Methods <<<< #
#                                   #

sub course_id {
    my $self = shift();
    return $self->field_value('course_id');
}

sub class_meeting_id {
    my $self = shift();
    return $self->field_value('class_meeting_id');
}

sub meeting_date {
    my $self = shift();
    return $self->field_value('meeting_date');
}

sub start_time {
    my $self = shift();
    return $self->field_value('starttime');
}

sub end_time {
    my $self = shift();
    return $self->field_value('endtime');
}

sub location {
    my $self = shift();
	my $loc = $self->field_value('location');
	$loc =~ s/^"//;
	$loc =~ s/"$//;
	return $loc;	
}

sub type {
	my $self = shift;

	my $lbl = '';
	my $type_id = $self->type_id();
	if (defined $type_id) {
		my $type = TUSK::ClassMeeting::Type->new()->lookupKey($type_id);
		$lbl = $type->getLabel();
	}

	return $lbl;
}

sub type_id {
    my $self = shift;
    return $self->field_value('type_id');
}

sub is_duplicate {
	my $self = shift;
	return $self->field_value('is_duplicate');
}

sub is_mandatory {
	my $self = shift;
	return $self->field_value('is_mandatory');
}

sub is_mandatory_answer {
	my $self = shift;
	if ($self->field_value('is_mandatory')) {
		return 'Yes';
	}
	else {
		return 'No';
	}
}

sub title {
    my $self = shift();
	my $title = $self->field_value('title');
	$title =~ s/^"//;
	$title =~ s/"$//;
	return $title;	
}

sub oea_code {
    my $self = shift();
    return $self->field_value('oea_code');
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

sub set_flagtime {
    my $self = shift;
    $self->set_field_values(flagtime => HSDB4::DateTime->new->out_mysql_timestamp());
    return;
}

sub set_type_id {
	my $self = shift;
	my $type_id = shift;

	$self->field_value('type_id' => $type_id);
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

sub flagtime {
    my $self = shift;
    unless ($self->{-flagtime}) {
	my $flagtime = $self->field_value('flagtime');
	$self->{-flagtime} = HSDB4::DateTime->new()->in_mysql_timestamp($flagtime);
    }
    return $self->{-flagtime}->has_value() ? $self->{-flagtime} : undef;
}

sub group_flagtime {
    my $self = shift;
    unless ($self->{-group_flagtime}) {
	my $group_flag_time = 0;
	for my $group ($self->user_groups()) {
	    my $time = $group->flagtime->out_unix_time;
	    if ($time > $group_flag_time) {
		$self->{-group_flagtime} = $group->flagtime();
	    }
	}
    }
    return $self->{-group_flagtime};
}

sub out_url {
	my $self = shift;
	my $original_url = $self->SUPER::out_url;
	my $old_link = $self->school . "/" . $self->class_meeting_id;
	my $new_link = $self->school . "/" . $self->course_id . "/schedule/" . $self->class_meeting_id;
	my $updated_url = $original_url;
	
	$updated_url =~ s/${old_link}/${new_link}/;

	return $updated_url;
}

sub out_url_mobi{
	my $self = shift;

	return '/mobi/view/schedule/classmeeting/' . $self->school . '/' . $self->class_meeting_id;
}

sub out_html_div {
    #
    # Formatted blob of HTML
    #

    my $self = shift;
}

sub out_xml {
    #
    # An XML representation of the row
    #

}

sub out_starttime {
    #
    # Return a date-time object which is the start time
    #

    my $self = shift;
    return $self->{-starttime} if $self->{-starttime};
    my $t = HSDB4::DateTime->new ();
    $t->in_mysql_date ($self->get_field_values ('meeting_date', 'starttime'));
    return $self->{-starttime} = $t;
}

sub out_endtime {
    #
    # Return a date-time object which is the end time
    #

    my $self = shift;
    return $self->{-endtime} if $self->{-endtime};
    my $t = HSDB4::DateTime->new ();
    $t->in_mysql_date ($self->get_field_values ('meeting_date', 'endtime'));
    return $self->{-endtime} = $t;
}

sub out_html_row {
    # 
    # A four-column HTML row
    #

    my $self = shift;
    my $date = $self->out_starttime->out_string_date_short;
    my $time = sprintf ("%s to %s", $self->out_starttime->out_string_time,
			$self->out_endtime->out_string_time);
    my $title = sprintf("<B>%s: %s</B>", 
			$self->type(), $self->title());
    $title = sprintf ('<A HREF="%s">%s</A>', $self->out_url, $title);
    my $fac = join (' ', map { $_->field_value('lastname') } 
		    $self->child_users);
    my $outval = "<TD>$date</TD><TD>$time</TD><TD>$title</TD><TD>$fac</TD>";
    $outval = "<TR>$outval</TR>";
    if (my $location = $self->field_value ('location')) {
	$outval .= "<tr><td>&nbsp;</td><td colspan=3>$location</td></tr>";
    }
    return $outval;
}

sub out_label {
    #
    # A label for the object: its title
    #

    my $self = shift;
}

sub out_abbrev {
    #
    # An abbreviation for the object: the first twenty characters of its
    # title
    #

    my $self = shift;
    my $out_string = $self->field_value('title');
    if (length($out_string) > 40) {
    	$out_string = sprintf("%s...",substr($self->field_value('title'),0,40));
    } 
    return $out_string;

}

sub build_meeting_links {
	#
	# This builds the links back to the calendar for a particular meeting.
	#
    my $self = shift;
	my @meeting_links = ();

	my $date = HSDB4::DateTime->new();
	$date->in_mysql_date ($self->field_value('meeting_date'));
	my $school = $self->school();

	my @groups = $self->user_groups();
	my @hrefs  = ();
	my @labels = ();
	
	if(scalar(@groups) == 1) {
		push(@hrefs, sprintf("%s/%s/%s/%s", '/view/schedule',
								$school,
								$groups[0]->field_value('user_group_id'),
								$date->out_mysql_date()));
		push(@labels, $date->out_string_date());
	}
	elsif(scalar(@groups) > 1) {
		foreach my $group (@groups) {
			push(@hrefs, sprintf("%s/%s/%s/%s", '/view/schedule',
									$school,
									$group->field_value('user_group_id'),
									$date->out_mysql_date()));
			push(@labels, $group->out_label() . ": " . $date->out_string_date());
		}
	}

	my $count = 0;
	
	foreach my $href (@hrefs) {
		push(@meeting_links, "$labels[$count] <a href=\"$href\">(weekly schedule)</a>");
		$count++;
	}
	
	return @meeting_links;
}

1;
__END__
