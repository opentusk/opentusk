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


package HSDB4::SQLRow::Content;

use strict;

require HSDB4::XML::Content;
require HSDB4::DateTime;

require HSDB45::Course;
require HSDB4::SQLRow::PersonalContent;
require HSDB45::ClassMeeting;
require HSDB4::SQLRow::Objective;
require HSDB4::SQLRow::Answer;
require HSDB45::Authorization;

use TUSK::Search::SearchQuery;
use TUSK::Search::LinkSearchQueryContent;
use HSDB4::SQLLink;
use HSDB4::XML::HSCML;
use TUSK::Constants;
use TUSK::UploadContent;
use TUSK::Core::Keyword;
use TUSK::Core::LinkContentKeyword;
use TUSK::Core::LinkIntegratedCourseContent;
use TUSK::Content::MSTextExtractor;
use TUSK::Content::External::MetaData;
use TUSK::Course;
use TUSK::Session;
use Carp;
use Image::Magick;
use TUSK::ProcessTracker::ProcessTracker;

use POSIX 'setsid';

BEGIN {
    require Exporter;
    require HSDB4::SQLRow;

    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
    
    @ISA = qw(HSDB4::SQLRow Exporter);
    @EXPORT = qw( );
    @EXPORT_OK = qw( );
    $VERSION = do { my @r = (q$Revision: 1.264 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
}

use HSDB4::SQLRow::ContentHistory;

sub version { return $VERSION }

my @mod_deps  = ();
my @file_deps = ();

sub get_mod_deps  { return @mod_deps  }
sub get_file_deps { return @file_deps }

use HSDB4::Constants qw(:school);
use TUSK::Constants;
use vars @EXPORT_OK;

# Non-exported package globals go here
use vars ();

# File-private lexicals
my $tablename = "content";
my $primary_key_field = "content_id";
my @fields = qw(content_id type title course_id school system copyright source 
		body hscml_body style 
		modified created read_access write_access 
		checked_out_by check_out_time conversion_status display reuse_content_id start_date end_date);
my %blob_fields = (body => 1, hscml_body=>1);
my %numeric_fields = (course_id => 1);

my %cache = ();

# Creation methods

my %TypeClass = ( 'Document' => 'HSDB4::SQLRow::Content::Document',
		  'Slide' => 'HSDB4::SQLRow::Content::Slide',
		  'Question' => 'HSDB4::SQLRow::Content::Question',
		  'Flashpix' => 'HSDB4::SQLRow::Content::Flashpix',
		  'Video' => 'HSDB4::SQLRow::Content::Video',
		  'Audio' => 'HSDB4::SQLRow::Content::Audio',
		  'URL' => 'HSDB4::SQLRow::Content::URL',
		  'Multidocument' => 'HSDB4::SQLRow::Content::Multidocument',
		  'Quiz' => 'HSDB4::SQLRow::Content::Quiz',
		  'PDF' => 'HSDB4::SQLRow::Content::PDF',
		  'Shockwave' => 'HSDB4::SQLRow::Content::Shockwave',
		  'Collection' => 'HSDB4::SQLRow::Content::Collection',
		  'DownloadableFile' => 'HSDB4::SQLRow::Content::DownloadableFile',
		  'Reuse' => 'HSDB4::SQLRow::Content::Reuse',
		  'External' => 'HSDB4::SQLRow::Content::External',
		  'TUSKdoc' => 'HSDB4::SQLRow::Content::TUSKdoc',
		  );

sub rebless {
    my $self = shift;

    my $type = $self->field_value('type');

    if ($type && $type eq "Reuse"){
	$self->load_reuse();    
	$type = $self->field_value('type');
    }
    
    if ($type && $TypeClass{$type}) { 
	bless ($self, $TypeClass{$type}); 
    }

    return $self;
}

sub new {
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
    return $self->rebless;
}

sub load_reuse{
    my ($self) = @_;
    my $reuse_content_id = $self->field_value('reuse_content_id');
    unless ($reuse_content_id){
	confess("Invalid reuse_content_id for content " . $self->primary_key);
    }
    my $load_content = HSDB4::SQLRow::Content->new->lookup_key($reuse_content_id);
    unless ($load_content->primary_key){
	confess("Invalid reuse_content_id for content " . $self->primary_key);
    }
    $self->field_value('title', $load_content->title(), 1) if ($load_content->field_value('type') eq "Document");
    $self->field_value('conversion_status', $load_content->conversion_status(), 1);
    $self->field_value('style', $load_content->field_value('style'), 1);
    $self->field_value('hscml_body', $load_content->field_value('hscml_body'), 1);
    $self->field_value('source', $load_content->source(), 1);
    $self->field_value('copyright', $load_content->field_value('copyright'), 1);
    $self->field_value('system', $load_content->field_value('system'), 1);
    $self->field_value('type', $load_content->field_value('type'), 1);
    $self->field_value('start_date', $load_content->field_value('start_date'), 1);
    $self->field_value('end_date', $load_content->field_value('end_date'), 1);

    if (my $load_body = $load_content->body){
	my ($html) = $load_body->tag_values('html');
	if ($html){
		my $cs = $load_content->field_value('conversion_status') || 0;
		if($load_content->field_value('type') eq "Document" and $cs < 1){
		$self->{_orig_body} = $html->value;
	    }
	}else{
	    $html = HSDB4::XML::SimpleElement->new(-tag => 'html', -label => 'html');
	    $load_body->xml_insert(0, $html);
	}
	
	my $new_html = '';
	
	if ($self->body and $self->body->tag_values('html')){
	    $new_html = $self->body->tag_values('html')->value;
	}
	$html->set_value($new_html);
	
	$self->field_value('body', $load_body->out_xml, 1);
    } 
}


sub content_id {
    my $self = shift();
    return $self->field_value("content_id");
}

sub title {
    my $self = shift();
    return $self->field_value("title");
}

sub content_type {
    my $self = shift();
    return $self->field_value("type");
}

sub school {
    my $self = shift();
    return $self->field_value("school");
}

sub read_access {
    my $self = shift();
    return $self->field_value("read_access");
}

sub display {
    my $self = shift;
    return $self->field_value("display");
}

sub type {
    my $self = shift;
    return $self->field_value("type");
}

sub conversion_status {
    my $self = shift;
    return $self->field_value("conversion_status");
}

sub source {
    my $self = shift;
    return $self->field_value("source");
}

sub end_date {
    my $self = shift;
    return $self->field_value("end_date");
}

sub start_date {
    my $self = shift;
    return $self->field_value("start_date");
}

sub copyright {
    my $self = shift;
    return $self->field_value("copyright");
}

sub reuse_content_id {
    my $self = shift;
    return $self->field_value("reuse_content_id");
}

sub contributor{
    my $self = shift;
    
    my $contributor = '';
    
    if (my $body = $self->body()){
	$contributor = $self->body->tag_values('contributor')->value if ($self->body()->tag_values('contributor'));
    }
    return $contributor;
}


sub is_active{
    # check to see if this content is active
    my $self = shift;

    return 0 if ($self->is_expired() or $self->is_hidden());

    return 1;
}

sub is_hidden{
    # check to see if this content is hidden (not yet active)
    my $self = shift;

    my $now = time();

    if ($self->start_date()){
	my $start_date = HSDB4::DateTime->new()->in_mysql_date($self->start_date());
	return 1 if ($now <= $start_date->out_unix_time());
    }
    
    return 0;
}

sub is_expired{
    # check to see if this content has expired (was active at one point)
    my $self = shift;

    my $now = time();

    if ($self->end_date()){
	my $end_date = HSDB4::DateTime->new()->in_mysql_date($self->end_date());
	return 1 if ($now >= ($end_date->out_unix_time()));
    }

    return 0;
}



sub lookup_key {
    my $self = shift;
    $self->SUPER::lookup_key (@_);
    return $self->rebless;
}

sub lookup_conditions {
    my $self = shift;
    my @results = $self->SUPER::lookup_conditions (@_);
    return map { $_->rebless } @results;
}

sub is_xmetal_doc{
    my ($self) = @_;
    return 1 if ($self->type eq 'Document' and $self->conversion_status == 2);
    return 0;
}

sub save {
	my $self = shift;
	my $un = shift;
	return (0,'No fields have been changed') if (!scalar($self->changed_fields));
	$self->save_version("No note entered.",$un,"don't save");
	my ($rval,$msg) = $self->SUPER::save($TUSK::Constants::DatabaseUsers{ContentManager}->{readusername},$TUSK::Constants::DatabaseUsers{ContentManager}->{readpassword});	
	return ($rval,$msg);
}

sub save_version {
    #
    # Save a piece of content, but also write a copy of the old version
    # to content_history
    #

    my $self = shift;

    # Get the note (for the content_history table), and the $user/$pw for the 
    # save() function.
    my ($note, $user, $no_save) = @_;

    # Make the new version object;
    my $version = HSDB4::SQLRow::ContentHistory->new_version($self);

    # Put the user/note information in
    $version->field_value ('modified_by', $user);
    $version->field_value ('modify_note', $note);

    # And save it
    $version->save ($TUSK::Constants::DatabaseUsers{ContentManager}->{readusername},$TUSK::Constants::DatabaseUsers{ContentManager}->{readpassword});

    # Now save our actual object
    my ($rval,$msg) = $self->SUPER::save ($TUSK::Constants::DatabaseUsers{ContentManager}->{readusername},$TUSK::Constants::DatabaseUsers{ContentManager}->{readpassword}) unless($no_save);
    return ($rval,$msg);
}

sub index {
    my $self = shift;
    my $indexer = TUSK::Search::Indexer->new();
    $indexer->indexContent($self);
}

#
# >>>>> Linked objects <<<<<
#
sub parent_courses {
    #
    # Return the courses this content is directly linked to
    #

    my $self = shift;
    # Check the cache...
    unless ($self->{-parent_courses}) {
	my @courses = ();
        # Get the link definition
	for my $db (map { get_school_db($_) } course_schools()) {
	    my $linkdef = 
		$HSDB4::SQLLinkDefinition::LinkDefs{"$db\.link_course_content"};
	    # And use it to get a LinkSet, if possible
	    push @courses, $linkdef->get_parents( $self->primary_key() )->parents();
	}
	$self->{-parent_courses} = \@courses;
	return @courses;
    }
    # Return the list
    return @{$self->{-parent_courses}};
}

sub linked_courses {
    #
    # Return all courses this content is linked to, even indirectly with a maximum depth of 10
    #
    my $self = shift;
    my %courseHash = map { ( $_->primary_key => $_ ) } grep { $_ } $self->_linked_courses_recursion();
    return values (%courseHash);
}

sub _linked_courses_recursion {
    
    my $self = shift;
    my $depth = shift || 0;
    my @courses = $self->parent_courses; 
    if (@courses){
	return @courses;
    }
    if ($depth > 10){
	return ();
    }
    foreach my $contentItem ($self->parent_content){
	@courses = (@courses,$contentItem->_linked_courses_recursion($depth + 1 ));
    }
    return @courses;
}

sub course {
    #
    # Return the course this object was created as part of
    #

    my $self = shift;

    # Make a new Course object
    my $course = HSDB45::Course->new ( _school => $self->field_value('school'),
				       _id => $self->field_value('course_id') );

    return $course;
}

sub parent_class_meetings {         
    #
    # Get class_meetings to which the content is linked
    #
        
    my $self = shift;
	my $ignore_cache = shift || 0;
    # Check the cache...
    if ($ignore_cache || !$self->{-parent_class_meetings}) {
	my @meetings = ();
        # Get the link definition
	for my $db (map { get_school_db($_) } schedule_schools()) {
	    my $linkdef = 
		$HSDB4::SQLLinkDefinition::LinkDefs{"$db\.link_class_meeting_content"};
	    # And use it to get a LinkSet, if possible
	    push @meetings, $linkdef->get_parents( $self->primary_key() )->parents();
	}
	$self->{-parent_class_meetings} = \@meetings;
    }
    # Return the list
    return @{$self->{-parent_class_meetings}};
}


sub parent_objectives {         
    #
    # Get objectives to which a content is linked. These are objectives pointed to from the body of the content,
    # making the objective the parent and the content the child.
    #
        
    my $self = shift;

    # Get the link definition
    my $linkdef =
        $HSDB4::SQLLinkDefinition::LinkDefs{'link_objective_content'};
    # And use it to get a LinkSet of parents
    my $parent_objectives = 
	    $linkdef->get_parents($self->primary_key);

    # Return the list
    return $parent_objectives->parents();
}

sub add_parent_objective {         
    #
    # Make an objectives to which a content is linked. These are objectives pointed to from the body of the content,
    # making the objective the parent and the content the child.
    #
        
    my $self = shift;
    my ($u,$p,$objective_id) = @_;

    # Get the link definition
    my $linkdef =
        $HSDB4::SQLLinkDefinition::LinkDefs{'link_objective_content'};
    my ($r,$msg) = $linkdef->insert(-user => $u, -password => $p,
				    -parent_id => $objective_id,
				    -child_id => $self->primary_key);
    return ($r,$msg);
}

sub unlink_parent_objective {
    my $self = shift;
    my ($u,$p,$objective_id) = @_;
    # Get the link definition
    my $linkdef =
        $HSDB4::SQLLinkDefinition::LinkDefs{'link_objective_content'};
    my ($r,$msg) = $linkdef->delete(-user => $u, -password => $p,
				    -parent_id => $objective_id,
				    -child_id => $self->primary_key);
    return ($r,$msg);
}

sub child_objectives {         
    #
    # A little tricky here, these are objectives that define the purpose of the content,
    # so the content is the parent of the objective. These objectives appear in document headers. 
    #
        
    my $self = shift;

    # Get the link definition
    my $linkdef =
        $HSDB4::SQLLinkDefinition::LinkDefs{'link_content_objective'};
    # And use it to get a LinkSet of parents
    my $child_objectives = $linkdef->get_children($self->primary_key);

    # Return the list
    return $child_objectives->children();
}

sub delete_objectives{
    my $self = shift;
    my ($u, $p) = @_;
    # Get the link definition

    my $linkdef =
        $HSDB4::SQLLinkDefinition::LinkDefs{'link_content_objective'};
    my ($r,$msg) = $linkdef->delete_children(-user => $u, -password => $p,
					     -parent_id => $self->primary_key,
					     );
    return ($r,$msg);   
}


sub add_child_objective {         
    #
    # These are objectives that define the purpose of the content,
    # so the content is the parent of the objective. These objectives appear in document headers. 
    #
        
    my $self = shift;
    my ($u,$p,$objective_id, $sort_order) = @_;

    # Get the link definition
    my $linkdef =
        $HSDB4::SQLLinkDefinition::LinkDefs{'link_content_objective'};
    my ($r,$msg) = $linkdef->insert(-user => $u, -password => $p,
				    -parent_id => $self->primary_key,
				    -child_id => $objective_id,
				    sort_order => $sort_order);
    return ($r,$msg);
}

sub unlink_child_objective {
    my $self = shift;
    my ($u,$p,$objective_id) = @_;
    # Get the link definition
    my $linkdef =
        $HSDB4::SQLLinkDefinition::LinkDefs{'link_content_objective'};
    my ($r,$msg) = $linkdef->delete(-user => $u, -password => $p,
				    -parent_id => $self->primary_key,
				    -child_id => $objective_id);
    return ($r,$msg);
}

sub parent_personal_content {         
    #
    # Get personal_content to which a content is linked. There's a twist, 
    # though---only do it for a particular user.
    #
        
    my $self = shift;
    my $user_id = shift or return; # user_id must be a user ID string
    if (ref($user_id) && $user_id->isa ('HSDB4::SQLRow::User')) {
        $user_id = $user_id->primary_key();
    }
    # No cache for this object, since it's too dynamic
    # Get the link definition
    my $linkname = 'link_personal_content_content';
    my $linkdef = $HSDB4::SQLLinkDefinition::LinkDefs{$linkname};
    # Now, get the query...
    my $select = $linkdef->parent_select($self->primary_key);
    # ...then modify it...
    $select->conditions()->add_and("parent.user_id='$user_id'");
    # ...then perform it
    my $linkset = $linkdef->get_links ($select);
    # Return the list
    return $linkset->parents ();
}

sub parent_content {
    #
    # Get the content documents from which this content is linked
    #

    my $self = shift;
	my $ignore_cache = shift || 0;
    # Check the cache...
    if ( $ignore_cache || !defined( $self->{-parent_content} ) ) {
        # Get the link definition
		my $linkdef = $HSDB4::SQLLinkDefinition::LinkDefs{'link_content_content'};
        # And use it to get a LinkSet of parents
        $self->{-parent_content} = $linkdef->get_parents($self->primary_key);
    }
    # Return the list
    return $self->{-parent_content}->parents ();
}

sub other_parents {
    #
    # Get the other context documents from which this document is linked
    #
    
    my $self = shift;
    # Get the list of parents
    my @context = ($self->parent_content, $self->parent_courses,
		   $self->parent_class_meetings);
    # Get the current parent
    my $cur_parent = $self->context_parent;
    
    if (ref($cur_parent) eq 'TUSK::Search::SearchQuery'){
	return ();
    }

    # If there is no current parent, then just return the context
    my $cur_parent_id;
    return @context unless $cur_parent_id = $cur_parent && $cur_parent->id;
    # Now just filter all of those which aren't the current parent, and
    # return that list
    return grep { $_->id ne $cur_parent_id } @context;
}

sub root_parents {
	#
	# Gets the highest-level root elements (always courses)
	#

	my $self = shift;
	my @roots;

	my @parents = $self->other_parents();
	push @parents, $self->context_parent;

	foreach my $parent ( @parents ) {
		if ( $parent && ref($parent) && $parent->isa( "HSDB45::Course" ) ) {
			push @roots, $parent;
		} elsif ( $parent && ref($parent) && $parent->isa( "HSDB4::SQLRow::Content::Collection" ) ) {
			foreach ( $parent->root_parents() ) {
				push @roots, $_;
			}
		}
	}

	my %seen = ();
	my @unique_roots;
	foreach (@roots) {
	    push(@unique_roots, $_) unless $seen{$_}++;
	}

	return @unique_roots;	
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

sub child_content {
    #
    # Get the content linked down from this content.
    #

    my $self = shift;
    # Check cache...
    unless ($self->{-child_content}) {
	# Get the link definition
	my $linkdef = 
	    $HSDB4::SQLLinkDefinition::LinkDefs{'link_content_content'};
	# And use it to get a LinkSet of users
	my $set = $linkdef->get_children($self->primary_key, @_);
	my $path = $self->aux_info('uri_path');
	$path = $path ? 
	    sprintf('%s/%d', $path, $self->primary_key) : $self->primary_key;
	my ($next_child,$prev_child);
	foreach my $child ($set->children) {
	    ($next_child,$prev_child) = ($set->get_next_child($child),$set->get_prev_child($child));
	    $child->set_aux_info ('uri_path', $path,
					'-next'=>$next_child,
					'-prev'=>$prev_child);
	}
	$self->{-child_content} = $set;
    }

    # Return the list ref
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

sub child_contentref_simple {
    ##
    ## this is like child_contentref but 1) doesn't use cache 2) allows args and 3) doesn't set aux info
    ##
    my $self = shift;
    my $linkdef = 
	$HSDB4::SQLLinkDefinition::LinkDefs{'link_content_content'};
    my @content = $linkdef->get_children($self->primary_key,@_)->children;
    return \@content;
}

sub add_child_content {         
    #
    # This sub allows content to be linked to this content as a parent
    #
        
    my $self = shift;
    my ($u,$p,$content_id,$sort,$title) = @_;

    # Get the link definition
    my $linkdef =
        $HSDB4::SQLLinkDefinition::LinkDefs{'link_content_content'};
    my ($r,$msg) = $linkdef->insert(-user => $u, -password => $p,
				    -parent_id => $self->primary_key,
				    -child_id => $content_id,
				    sort_order => $sort,
				    label => $title);
    return ($r,$msg);
}

sub draft {
    my $self = shift;
    my $draft = HSDB4::SQLRow::ContentDraft->new->lookup_content($self->primary_key);
    return unless ($draft->primary_key);
    return $draft;
}

sub child_users {
    #
    # Get the users who are linked under this document (includes all roles)
    #
    
    my ($self, $order_by, @cond) = @_;
    my $id;
    # Get the link definition
    my $linkdef = $HSDB4::SQLLinkDefinition::LinkDefs{'link_content_user'};
    $linkdef->order_by($order_by) if ($order_by);

    if ($self->field_value('reuse_content_id')){
	$id = $self->field_value('reuse_content_id');
    }else{
	$id = $self->primary_key;
    }

    # And use it to get a LinkSet of users
    my $child_users = $linkdef->get_children($id,@cond);

    # Return the list
    return $child_users->children();
}

sub child_users_select {
    #
    # Method that can get either the reuse_content users or the original content users
    #
    
    my ($self, $select_flag) = @_;
    my $id;
    # Get the link definition
    my $linkdef = $HSDB4::SQLLinkDefinition::LinkDefs{'link_content_user'};

    if ($self->field_value('reuse_content_id') and $select_flag == 0){
	$id = $self->field_value('reuse_content_id');
    }else{
	$id = $self->primary_key;
    }

    # And use it to get a LinkSet of users
    my $child_users = $linkdef->get_children($id);

    # Return the list
    return $child_users->children();
}

sub child_authors {
    #
    # Get the users who are linked under this document specifically as an author
    #    
    my $self = shift;
    my $order_by = shift;
    my @child_users = $self->child_users($order_by);
    if ($self->type() eq 'External') {
		my $metadata = TUSK::Content::External::MetaData->new()->lookupReturnOne("content_id = " . $self->primary_key());
		$self->{metadata} = $metadata;
		return ($metadata) ? ($metadata->getAuthor()) : undef;
    } else {
		return grep { $_->aux_info('roles') =~ /Author/ } @child_users;
    }
}

sub get_abstract {
    my $self = shift;
    if ($self->{metadata}) {
	return $self->{metadata}->getAbstract();
    } else {
	my $metadata = TUSK::Content::External::MetaData->new()->lookupReturnOne("content_id = " . $self->primary_key());	
	$self->{metadata} = $metadata;
	return ($metadata) ? ($metadata->getAbstract()) : undef;
    }
}

sub delete_child_users {
    #
    # Delete child users associated with this content
    #

    my ($self, $u, $p) = @_;

    # Get the link definition
    my $linkdef = $HSDB4::SQLLinkDefinition::LinkDefs{'link_content_user'};
    my ($r,$msg) = $linkdef->delete_children(-user => $u, -password => $p,
					     -parent_id => $self->primary_key);
    return ($r,$msg);   
}

sub child_user_roles {
    #
    # Get the roles of a child user
    #
    my ($self, $user_id) = @_;

    # Check for error; TODO how can this happen?
    my $pkey = $self->primary_key();
    confess "Unexpected content primary key ID not defined" if (! defined $pkey);

    my $linkdef = $HSDB4::SQLLinkDefinition::LinkDefs{'link_content_user'};

    # And use it to get a LinkSet of users
    my $child_users = $linkdef->get_children(
        $pkey,
        sprintf("child_user_id = %s",
                HSDB4::Constants::def_db_handle()->quote($user_id)),
    );

    my @users = $child_users->children();

    return split("," , $users[0]->aux_info('roles')) if (scalar(@users));
}

sub child_non_users {
    #
    # Get the non users who are linked under this document (ie, its authors)
    #

    my ($self, $order_by, @cond) = @_;    

    # Get the link definition
    my $linkdef = $HSDB4::SQLLinkDefinition::LinkDefs{'link_content_non_user'};
    $linkdef->order_by($order_by) if ($order_by);
    # And use it to get a LinkSet of users
    my $child_users = $self->non_user_link()->get_children($self->primary_key,@cond);

    # Return the list
    return $child_users->children();
}

sub child_non_user_roles {
    #
    # Get the list of small group instructors
    #
    my $self = shift;
    my $user_id = shift;
    my @non_users = grep { $_->primary_key =~ /$user_id/  } $self->child_non_users;
    return split(",",$non_users[0]->aux_info('roles')) if (@non_users);
}

sub user_primary_role {
    my $self = shift;
    my $user_id = shift;
    my @roles = $self->child_user_roles($user_id);
    return unless (@roles);
    return $roles[0];
}

sub child_personal_content {
    #
    # Get the personal content which is a child of this content for a
    # particular user, if there is any. (That would be their annotations.)
    #

    my $self = shift;
    # Get the user_id in question
    my $user_id = shift or return;
    # Now check to see if we got an object instead
    if (ref($user_id) && $user_id->isa('HSDB4::SQLRow::User')) {
	$user_id = $user_id->primary_key;
    }

    # No cache, because this is too dynamic
    # Get the link definition
    my $linkname = 'link_content_personal_content';
    my $linkdef = $HSDB4::SQLLinkDefinition::LinkDefs{$linkname};
    # Now, get the query...
    my $select = $linkdef->child_select($self->primary_key);
    # ...then modify it...
    $select->conditions()->add_and("child.user_id='$user_id'");
    # ...then perform it
    my $linkset = $linkdef->get_links ($select);
    # Return the list
    return $linkset->children ();
}

sub keywords_list{
    my $self = shift;
    my $typecond = shift;
    return join(', ', map {$_->field_value('keyword')} $self->keywords($typecond));
}

sub UMLSkeywords {
	my $self = shift;
	return $self->keywords (" concept_id is not null ");
}

sub keywords {
    #
    # Return useful keyword objects which match this course
    #

    my $self = shift;
    my @conds = @_;
    my $addtl_cond = '' ;
    if (@conds){
      	$addtl_cond = "AND " . join (' AND ',@conds);
    }
    my $condition = sprintf("parent_content_id=%s and (author_weight > 0 or author_weight is NULL) $addtl_cond", $self->primary_key);
    my $links = TUSK::Core::LinkContentKeyword->lookup($condition);
    my @keywords = map { $_->getKeywordObject() } @{$links} ;
    return @keywords;
}

sub content_history {
    #
    # Return the version history objects for a document
    #

    my $self = shift;

    # Check the cache
    unless ($self->{-content_history}) {
	# Make up the search
	my @conds = (sprintf("content_id=%s", $self->primary_key),
		     "ORDER BY modified DESC");
	# Perform the search
	my @history = HSDB4::SQLRow::ContentHistory->lookup_conditions(@conds);
	# Store it in the cache
	$self->{-content_history} = \@history;
    }
    return ( @{$self->{-content_history}} );
}

sub get_image_location {
	my $self = shift;
	my $temp;

	if ( $self->reuse_content_id ) {
		$temp = join "/", (split '', sprintf "%03d", $self->reuse_content_id)[0..2], $self->reuse_content_id;
	} else {
		$temp = join "/", (split '', sprintf "%03d", $self->primary_key)[0..2], $self->primary_key;
	}
	
	return $temp;
}

sub image_available {
    my $self    = shift;
    my $size    = shift || 'large';
	my $overlay = shift || 0;
    
	my $full_path;
	my $location = $self->get_image_location();
	
	if ( $overlay ) {
		$full_path = $TUSK::UploadContent::path{'slide'} . '/overlay/' . $HSDB4::Constants::URLs{$size} . '/' . $location;
	} else {
		$full_path = $TUSK::UploadContent::path{'slide'} . '/' . $HSDB4::Constants::URLs{$size} . '/' . $location;
	}

	return 'jpg' if ( -e $full_path . '.jpg' );
	return 'gif' if ( -e $full_path . '.gif' );
	return 'png' if ( -e $full_path . '.png' );
}

sub small_data_preferred {
    #
    # Return a 0 to indicate that the small_data is *not* preferred, but
    # obviously, sub-classes can override that.
    #
    my $self = shift;
    return 0;
}

sub body {
    # 
    # Get the HSDB4::XML::Content user_body object and let us manipulate it
    #

    my $self = shift;

    my $body = HSDB4::XML::Content->new('content_body');
    my $val = $self->field_value('body');
    if ($val) { 
        $val =~ s/([\200-\377])/sprintf("&#%03d;", ord($1))/eg;
        eval { 
		$body->parse($val);
        };
        if ($@) { 
		$self->error($@); 
	 	return 0 ; 
	}
    }
    return $body;
}

sub tag_values {
	my $self = shift;
	my $tag = shift;
	my $body;
	eval {
		$body = $self->body;
	};
	if ($@){
		$self->error($@);
		return 0;
	}
	if ($self->error()){
		return 0;
	}
	if (my $tag_value = $body->tag_values($tag)){
		return $tag_value;
	}
	return 0;
}

sub twig_body {
    require HSDB4::XML::HSCML;
    my $self = shift;
    my $val = $self->field_value('body');
    return my $body = HSDB4::XML::HSCML->new($val);
}

sub build_body {
    my $self = shift;
    my $stain = shift;
    my $type = shift;
    my $contributor = shift;
    my $text = shift;

    my $content = HSDB4::SQLRow::Content->new;
    my $body = $content->body;

    my @bodylist = ();
    	push @bodylist, ('content_body:0:slide_info:0:stain' => $stain)
		if ($stain);
    	push @bodylist, ('content_body:0:slide_info:1:image_type' => $type) 
		if ($type);
    	push @bodylist, ('content_body:2:contributor' => $contributor)
        	if ($contributor);
    	push @bodylist, ('content_body:3:html' => $text)
		if ($text);
    	$body->in_fdat_hash (@bodylist);
    	return $body->out_xml;
}

sub build_system {
    my $self=shift;
    my $system = shift;
    return join ',', split (/\t/, $system);
}

sub build_keyword {
    my $self = shift;
    my $keywords = shift;
    my $separator = shift;
    $separator = "[\cA-\cZ]{2}" if (!$separator);      
    $keywords =~ s/$separator/,/g;
    return $keywords;
}

sub modified {
    my $self = shift;
    my $modified = HSDB4::DateTime->new;
    $modified->in_mysql_timestamp ($self->field_value('modified'));
    return $modified;
}

sub modified_date {
    my $self = shift;
    return $self->modified->out_string_date_short();
}

sub reset_modified {
    my $self = shift;
    my $time = HSDB4::DateTime->new;
    $self->field_value("modified",$time->out_mysql_timestamp());
    $self->save;
}

sub created {
    my $self = shift;
    my $created = HSDB4::DateTime->new;
    $created->in_mysql_timestamp ($self->field_value ('created'));
    return $created;
}

#
# >>>>> URL Methods <<<<<
#

sub lookup_path {
    #
    # Takes the info from an Apache path and returns an object which can
    # be derived from the path
    #

    my ($self, $path) = @_;
    # Look for path items containing something other than white space
    my @path = grep { /\S/ } split '/', $path;
    # If there's nothing there, then there's no object
    return undef unless @path;
    # Otherwise, do the lookup and return the result
    my $key = pop @path;
    $key = int($key);
    $self->lookup_key($key);
    $self->set_aux_info ('uri_path', join ('/', @path));
    return $self;
}

sub lookup_doc_path {
    #
    # Takes the info from an Apache path and returns an object which can
    # be derived from the path
    #

    my ($self, $path) = @_;
    # Look for path items containing something other than white space
    my @path = grep { /\S/ } split '/', $path;
    # If there's nothing there, then there's no object
    return undef unless @path;
    # Otherwise, do the lookup and return the result
    my $key = shift @path;
    $self->lookup_key($key);
    $self->set_aux_info ('uri_path', join ('/', @path));
    return shift @path;
}

my %linkdefs = ( 
		 Q => 'TUSK::Search::LinkSearchQueryContent',
		 C => 'link_course_content',
		 P => 'link_personal_content_content',
		 M => 'link_class_meeting_content',
		 O => 'link_objective_content',
	       );

my %classes =  ( 
		 Q => 'TUSK::Search::SearchQuery',
		 C => 'HSDB45::Course',
		 P => 'HSDB4::SQLRow::PersonalContent',
		 M => 'HSDB45::ClassMeeting',
		 O => 'HSDB4::SQLRow::Objective',
	       );
my $class_re = "[QCPMO]";


sub get_bread_crumb_from_path {
    # Gets the bread crumb information from a passed in path.
    # Takes an array of items.
    # Returns an array of hashses with paths and stuff.
    my $self = shift;
    my $theCrumbsRef = shift;

    my @crumbArray;

    # If we've already figured it out...
#    return $self->aux_info('-breadCrumb') if $self->aux_info('-breadCrumb');

	if(${$theCrumbsRef}[0] =~ /^[a-zA-Z]*$/) {
		my $school = shift @{$theCrumbsRef};
		my $character = HSDB4::Constants::code_by_school($school);
		${$theCrumbsRef}[0] = $character . ${$theCrumbsRef}[0] . 'C';
	}
	my $trail = '/view/content/';
	foreach my $item (@{$theCrumbsRef}) {
		my $lastChar = substr($item, -1, 1);
		my $re = sprintf("(%s?)(\\d+)(%s?)\$", school_code_regexp(), $class_re);
		my ($school_id, $parent_id, $class_id) = $item =~ m!$re!io;

		$class_id = uc $class_id;

		if (not $parent_id) {warn "Couldn't sort out the item: '$item'";}
		else {
	  		if ($class_id eq 'Q'){
	      		push(@crumbArray, { href => '/tusk/search/form/' . $parent_id . '?Search=1', label => 'Query'});
	      		push(@crumbArray, { href =>  '/view/content/' . $parent_id . 'Q/' . $self->primary_key(), label => $self->title()});
	      		return (\@crumbArray);
	  		}

        	my $parent_class = $classes{$class_id} || 'HSDB4::SQLRow::Content';

        	# Get the parent itself
        	my $item;

        	if ($parent_class->split_by_school()) {
	  			$item = $parent_class->new( _school => school_codes($school_id), _id => $parent_id );
	  			my $db = $item->school_db();
        	}
        	else {$item = $parent_class->new ()->lookup_key ($parent_id);}

        	# Fail unless we found an object
        	unless ($item->primary_key) {warn "Looked up $parent_class ID $parent_id but failed";}
        	else {
	  			my $url = '';
 	  			my $text = '';

          		if(exists($linkdefs{$lastChar})) {
	    			if($lastChar eq 'C')    {$url = $HSDB4::Constants::URLs{$classes{$lastChar}} . "/" .$item->school() . "/" . $item->primary_key; $text = $item->title();}
	    			elsif($lastChar eq 'P') {$url = ''; $text = 'Personal Content';}
	    			elsif($lastChar eq 'M') {
						$url = '/view/course/' . $item->school() . '/' . $item->course_id; $text = HSDB45::Course->new(_school=>$item->school())->lookup_key($item->course_id)->title;
						push @crumbArray, { href => $url, label => $text };
						
						$url = '/view/course/' . $item->school() . '/' . $item->course_id . '/schedule/' . $item->primary_key; $text = $item->title();
					}
	    			elsif($lastChar eq 'O') {$url = ''; $text = 'Objective';}
          		} else {
            		if($item->out_url() =~ /view\/content/) {$url = $trail . $item->primary_key();}
            		else                                  {$url = $item->out_url();}
            		$text = $item->out_label();
          		}
	  			if($url && $text) {  push @crumbArray, { href => $url, label => $text };  }
        	}
      	}
      	$trail .= "$item/";
    }
	# Save it in aux_info
	$self->set_aux_info('-breadCrumb', @crumbArray);
	return \@crumbArray;
}

sub get_bread_crumb_ids {
    # 
    # tries to reverse engineer list of breadcrumb content ids for a given piece of content
    # 
	my $self = shift;
	my @path_ids;
	my $counter = 0;			## this is to bail out of a possible infinite loop

	if ($self->course()->primary_key() && $self->parent_content()) {
		my @content_parents = $self->parent_content();
		my $parent_course_id = $self->course()->primary_key();
		my $new_parent;
		do {
			$new_parent = undef;
			foreach my $parent_content (@content_parents) {
				my $counted_already = grep {$_ eq $parent_content->primary_key()} @path_ids;
				if (!$counted_already && ($parent_content->course()->primary_key() eq $parent_course_id)) {
					$new_parent = $parent_content;
					last;
				}
			}
			if ($new_parent) {
				unshift @path_ids, $new_parent->primary_key();
				@content_parents = $new_parent->parent_content();		
			}
			$counter += 1;
		} while ($new_parent && $new_parent->parent_content() && $counter < 100);
	}
	return \@path_ids;
}


sub context_parent {
    #
    # Given a path, find the parent and sibling objects for this document
    #

    my $self = shift;

    # If we've already figured it out...
    return $self->aux_info('-parent') if $self->aux_info('-parent');

    # Otherwise, we have to sort it out from the path
    my $path = $self->aux_info('uri_path');
    if (not $path) { return undef; }
    # What's the ID and class of the parent?
    my $re = sprintf("(%s?)(\\d+)(%s?)\$", 
		   school_code_regexp(), $class_re);

    my ($school_id, $parent_id, $class_id) = $path =~ m!$re!io;
    if (not $parent_id) {
	warn "Couldn't sort out the path: '$path'";
	return undef;
    }

    $class_id = uc $class_id;

    my $parent_class = $classes{$class_id} || 'HSDB4::SQLRow::Content';
    my $linkdef = $linkdefs{$class_id} || 'link_content_content';

    my $parent;

    # for new query object
    if ($parent_class eq 'TUSK::Search::SearchQuery'){
	$parent = $parent_class->new()->lookupKey($parent_id);
	my $link_objs = TUSK::Search::LinkSearchQueryContent->new()->lookup("parent_search_query_id = '" . $parent_id . "'", ['computed_score desc']);

	for (my $i = 0; $i <= scalar(@$link_objs); $i++){
	    if ($link_objs->[$i] && $link_objs->[$i]->getChildContentID() == $self->primary_key()){
		if ($i > 0){
		    my $prev =  HSDB4::SQLRow::Content->new()->lookup_key($link_objs->[$i-1]->getChildContentID());
		    $prev->set_aux_info('uri_path', $parent_id . 'Q');
		    $self->set_aux_info('-prev' => $prev);
		}

		if ($i < scalar(@$link_objs) - 1 ){
		    my $next =  HSDB4::SQLRow::Content->new()->lookup_key($link_objs->[$i+1]->getChildContentID());
		    $next->set_aux_info('uri_path', $parent_id . 'Q');
		    $self->set_aux_info('-next' => $next);
		}

		last;
	    }

	    $self->aux_info('-breadCrumb' => ({ href => '/tusk/search/form/' . $parent_id . '?Search=1', label => 'Query'}))
	}
    }else{

	# Get the parent itself
	if ($parent_class->split_by_school()) {
	    $parent = $parent_class->new( _school => school_codes($school_id),
					  _id => $parent_id );
	    my $db = $parent->school_db();
	    $linkdef = "$db\.$linkdef";
	}
	else {
	    $parent = $parent_class->new ()->lookup_key ($parent_id);
	}
	
	# Fail unless we found an object
	unless ($parent->primary_key) {
	    warn "Looked up $parent_class ID $parent_id but failed";
	    return undef;
	}
	# Set the parent's path, if we can
	$re = sprintf("%s?\\d+%s?\$", 
		      school_code_regexp(), $class_re);
	my ($parent_path) = $path =~ m!^(.+)/$re!io;

	$parent->set_aux_info ('uri_path', $parent_path) if $parent_path;
	# Save it in aux_info
	$self->set_aux_info('-parent', $parent);
	
	# Get the link definition, and its children
	my $ld = $HSDB4::SQLLinkDefinition::LinkDefs{$linkdef};
	my $set = $ld->get_children($parent->primary_key);
	# Now, get the next object
	my $next = $set->get_next_child ($self);
	$next->set_aux_info ('uri_path', $path) if $next;
	# And get the prev object
	my $prev = $set->get_prev_child ($self);
	$prev->set_aux_info ('uri_path', $path) if $prev;
	
	# Save the next and prev
	$self->set_aux_info ('-next', $next, '-prev', $prev);
    }
    
    return $parent;
}

sub context_next {
    #
    # Return the next object in the set, if it's relevant
    #

    my $self = shift;
    # Make sure there's a parent, or this has no meaning
    unless ($self->aux_info('-next')){
	    my $parent = $self->context_parent or return;
    }
    return $self->aux_info ('-next');
}

sub context_prev {
    #
    # Return the previous object in the set, if it's relevant
    #

    my $self = shift;
    # Make sure there's a parent, or this has no meaning
    unless ($self->aux_info('-prev')){
	    my $parent = $self->context_parent or return;
    }
    return $self->aux_info ('-prev');
}

sub is_user_authorized {
    # 
    # Decide whether a named user is authorized to look at this item from
    # the database.
    #
    
    my ($self, $user_id) = @_;
    my $authz = HSDB45::Authorization->new();
    return $authz->can_user_view_content($user_id,$self);
}

sub is_user_author {
    #
    # Determine if a named user is an author of a document
    #

    my ($self, $user) = @_;
    # We can't decide for a blank user...
    return unless $user;
    # For each author
    foreach ($self->child_users) {
	# Return affirmative if this author's ID matches
	return 1 if $_->primary_key eq $user;
    }
    # Return 0 if none of them matched
    return 0;
}

# TODO Make Readonly
# Readonly my @CONTENT_EDIT_ROLES =>
my @CONTENT_EDIT_ROLES = (
    'Director',
    'Manager',
    'Student Manager',
);

# TODO Make Readonly
# Readonly my @CONTENT_ADD_ROLES =>
my @CONTENT_ADD_ROLES = (
    'Director',
    'Manager',
    'Editor',
    'Author',
    'Student Manager',
);

sub can_user_edit {
    my $self = shift;
    my $user = shift;
    # first check the user's role in this content
    my $role = $self->user_primary_role($user->primary_key);

	## allow if user is associated with content
	return 1 if ($role eq 'Editor' || $role eq 'Author');

	## allow if school admin
	if ($self->field_value('school')) {
	    return 1 if $user->check_school_permissions($self->school());
	}
	
    ## allow if user has role in course that allows editing of other
    ## people's content
	if ($self->course()->user_primary_role($user->primary_key)) {
		return 1 if (join(q{,}, @CONTENT_EDIT_ROLES) =~ $self->course()->user_primary_role($user->primary_key));
	}
}

sub can_user_add {
    my $self = shift;
    my $user = shift;
    # first check the user's role in this course
    my $role = $self->user_primary_role($user->primary_key);
    return 1 if ($role && join(q{,}, @CONTENT_ADD_ROLES) =~ /$role/);
    return 1 if ($self->course()->can_user_add($user));
}

sub contains_slides {
    # to see if this piece of content contains slides
    my $self = shift;
    my @content = $self->child_content;
    foreach (@content) {
	return 1 if ($_->field_value('type') =~ /Slide/)
    }
    return 0;
}

sub add_child_user {
    my $self = shift;
    my ($u, $p, $username, $so, @roles) = @_;

    # backward compatibility? sort_order didn't used to be available with
    # this function...
    if ($so !~ /^\d+$/){
    	push (@roles, $so);
		$so = undef;
    }

    ## look up to see if user is already linked, then need to get, delete, and reinsert
    if ($self->child_user_roles($username)) {
	push (@roles,$self->child_user_roles($username));
	$self->user_link()->delete(-user => $u, 
				   -password => $p,
				   -child_id => $username,
				   -parent_id => $self->primary_key);
    }
    my @so = ();
    if (defined($so)){
    	@so = (sort_order => $so);
    }

    my ($r, $msg) = $self->user_link()->insert (-user => $u, -password => $p,
						-child_id => $username,
						-parent_id => $self->primary_key,
						@so,
						roles => join (',', @roles));
    return ($r, $msg);
}

sub user_link {
    return $HSDB4::SQLLinkDefinition::LinkDefs{"link_content_user"};
}

sub content_link {
    return $HSDB4::SQLLinkDefinition::LinkDefs{'link_content_content'};
}

sub student_content {
    my ($self, $child_user_id) = @_;
    my $link = $self->user_link();
    my $select = $link->parent_select($child_user_id, "roles rlike 'Student-'");
    my $linkset = $link->get_links($select);
    return $linkset->parents();
}


sub add_child_non_user {
    my $self = shift;
    my ($u, $p, $nonusername, @roles) = @_;
    ## look up to see if user is already linked, then need to get, delete, and reinsert
    if ($self->child_non_user_roles($nonusername)) {
	push (@roles,$self->child_non_user_roles($nonusername));
	$self->non_user_link()->delete(-user => $u, 
				   -password => $p,
				   -child_id => $nonusername,
				   -parent_id => $self->primary_key);
    }

    my ($r, $msg) = $self->non_user_link()->insert (-user => $u, -password => $p,
						-child_id => $nonusername,
						-parent_id => $self->primary_key,
						roles => join (',', @roles));
    return ($r, $msg);
}


sub non_user_link {
    return $HSDB4::SQLLinkDefinition::LinkDefs{"link_content_non_user"};
}

#
# >>>>>  Input Methods <<<<<
#

sub in_xml {
}

sub in_fdat_hash {
}

sub make_annotation {
    #
    # Make and save an object to personal content for the user as an
    # annotation.
    #

    my $self = shift;
    # Get the user_id, even if it's an object we've got
    my $user_id = shift;
    if (ref($user_id) && $user_id->isa('HSDB4::SQLRow::User')) {
	$user_id = $user_id->primary_key;
    }
    # Get the note itself
    my $note = shift;

    # Check for old notes
    my @old_notes = $self->child_personal_content ($user_id);
    if (@old_notes) {
	# If there are old notes, put our notes into the body of them
	# and save them
	$old_notes[0]->field_value('body', $note);
	return $old_notes[0]->save;
    }

    # If we're making a new note...
    my $new_note = HSDB4::SQLRow::PersonalContent->new;
    $new_note->set_field_values ('user_id' => $user_id,
				 'type' => 'Annotation',
				 'content_id' => $self->primary_key,
				 'body' => $note);
    $new_note->save;

    # Now actually make the link
    my $linkname = 'link_content_personal_content';
    my $linkdef = $HSDB4::SQLLinkDefinition::LinkDefs{$linkname};
    $linkdef->insert (-parent_id => $self->primary_key,
		      -child_id => $new_note->primary_key,
		      -sort_order => 10,
		      -no_parent_update,
		     );
}
#
# >>>>>  Output Methods  <<<<<
#

sub display_framed {
    #
    # Indicates whether this object should be displayed in a frame.
    #

    my $self = shift;
	
	if($self->field_value('style') eq 'minimal'){
		return 1;
	}
    return;
}

sub display_child_content {
    #
    # Indicates whether this object should have the list of sub-documents
    # shown after it.
    #

    my $self = shift;
    return 1;
}


sub out_meta_data {
    #
    # Return meta tags for the top of an HTML file.
    # Meta Fields:
    #     id
    #     title
    #     author authors (same things)
    #     keyword keywords (same things)
    #     type
    #     course
    #     school
    #     system
    #

    my $self = shift;
    my @meta = ();
    
    push @meta, sprintf ("<meta NAME=\"ID\" CONTENT=\"%s\">",
			 $self->primary_key);
    push @meta, sprintf ("<meta NAME=\"title\" CONTENT=\"%s\">",
			 $self->out_label);
    my $authors = join ('; ', map { $_->field_value('lastname') } 
			$self->child_users);
    push @meta, "<meta NAME=\"author\" CONTENT=\"$authors\">" if $authors;
    push @meta, "<meta NAME=\"authors\" CONTENT=\"$authors\">" if $authors;
    my $keywords = join ('; ', map { $_->getKeyword() }
			 $self->keywords);
    push @meta, "<meta NAME=\"keyword\" CONTENT=\"$keywords\">" if $keywords;
    push @meta, "<meta NAME=\"keywords\" CONTENT=\"$keywords\">" if $keywords;
    push @meta, sprintf ("<meta NAME=\"course\" CONTENT=\"%s\">",
			 $self->course->out_label);
    push @meta, sprintf ("<meta NAME=\"type\" CONTENT=\"%s\">",
			 $self->field_value('type'));
    push @meta, sprintf ("<meta NAME=\"school\" CONTENT=\"%s\">",
			 $self->course->school);
    push @meta, sprintf ("<meta NAME=\"system\" CONTENT=\"%s\">",
			 $self->field_value('system'));
    return join ("\n", @meta);
}

sub out_html_forindex {
    #
    # Return an HTML document for indexing
    #

    my $self = shift;
    my $doc = '<HTML><HEAD>';
    $doc .= sprintf "<TITLE>%s</TITLE>\n", $self->out_label;
    $doc .= $self->out_meta_data;
    $doc .= "\n</HEAD>\n<BODY>\n";
    $doc .= $self->out_html_body;
    $doc .= "\n</BODY></HTML>";
}

sub out_index_body {
	my $self = shift;
	my $index_string = shift;

	unless ($index_string){
	    $index_string = $self->out_html_body();
	}

	my @parents = $self->other_parents();
    
	foreach my $parent (@parents){
	    $index_string .= "\n" . $parent->title();
	}

	my @tags = ('h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'b', 'i', 'u', 'span:nugget', 'span:topic-sentence', 'span:keyword', 'span:summary', 'th');
	
	foreach my $tag (@tags){
	    my ($tag, $class) = split ':', $tag;

	    if ($class){
		$index_string =~ s!<\Q$tag\E class="\Q$class\E"[^>]*?>(.*?)</\Q$tag\E>!" $1"  x 10!smgei;
	    }
	    else{
		$index_string =~ s!<\Q$tag\E[^>]*?>(.*?)</\Q$tag\E>!" $1"  x 10!smgei;
	    }
	}

	return $index_string;
}

sub out_file_path{
	return undef;
}
sub out_log_item {
    #
    # Return an item for logging
    #

    my $self = shift;
    my $id = $self->primary_key || '';
    my $course_id = $self->field_value('course_id') || '';
    return "Content:$course_id:$id:";
}

sub out_html_div {
    #
    # Formatted blob of HTML
    #

    my $self = shift;
    return join ("\n",
		 "<DIV>",
		 sprintf ("<H2>%s</H2>", $self->out_label),
		 $self->out_html_body,
		 "</DIV>");
}

sub out_xml{
    my ($self) = @_;
    return();
}

sub out_authors{
#
# Returns the author
#
  my $self = shift;
  my @users = $self->child_users;
    my @non_users = $self->child_non_users;
    push(@users,@non_users);
    return join (', ', map { $_->out_abbrev } @users);
}

sub out_html_thumbnail {
    #
    # Return what should go in the thumbnail part of an row
    #

    my $self = shift;
    return $self->field_value ('type');
}

sub out_html_icon {
    #
    # Return what should go in the thumbnail part of an row
    #

    my $self = shift;
    return $self->field_value ('type');
}

sub out_icon {
    #
    # Return what should go in the thumbnail part of an row
    #

    my $self = shift;
    return $self->field_value('type');
}

sub out_html_thumbnail_choose {
    #
    # Return what should go in the thumbnail part of an row
    #

    my $self = shift;
    return $self->field_value ('type');
}


## new version accepts optional arguments to control the link displayed. 
## Specifically, you can now pass out_html_row an associative array with the 
## following options:
##	cms => 1               links to the content management site, instead
##	                       of to the content
##      content-link => path   define a different path for content links to go to
sub out_html_row {
    # 
    # A four-column HTML row
    #

    my $self = shift;
    my %params = @_;

    my @users = $self->child_users;
    my @non_users = $self->child_non_users;
    push(@users,@non_users);
    @users = grep { $_->aux_info("roles") =~ /Author/ } @users;
    my $col2;
    if ($params{'cms'}){
    	$col2 = sprintf ('<a href="/cms/content/display/%d">edit %s</a>', $self->primary_key, $self->out_label);
    } elsif (exists($params{'content-link'})){
    	$col2 = sprintf ('<a href="%s/%d">%s</a>', $params{'content-link'}, $self->primary_key, $self->out_label);
    } else {
        $col2 = $self->out_html_label;
    }
    my $authors = join (', ', map { $_->out_abbrev } @users);
    my $r;
    if ($params{'sort_order'}){
        $r =sprintf("<TR><TD>%s</TD><TD>%s</TD><TD><B>%s</B></TD><TD>%s</TD><TD>%s</TD></TR>\n",
            $self->aux_info('sort_order') || '&nbsp;',
            $self->out_html_thumbnail, $col2, $authors);
    } else {
        $r =sprintf("<TR><TD class=\"html_row\">%s</TD><TD COLSPAN=2 CLASS=\"html_row\"><B>%s</B></TD><TD CLASS=\"html_row\">%s</TD></TR>\n",
            $self->out_html_thumbnail, $col2, $authors);
    }
    return $r;
}

sub out_html_row_edit {
    # 
    # A six-column HTML row with prompts for editing
    #

    my $self = shift;
    my @users = $self->child_users;
    my @non_users = $self->child_non_users;
    push(@users,@non_users);
    my $authors = join (', ', map { $_->out_abbrev } @users);
    sprintf("<TR><TD>%s</TD><TD><INPUT TYPE=\"checkbox\" name=\"unlink_content\" value=\"%s\"></TD><TD><B>%s</B></TD><TD><input type=\"text\" size=\"6\" maxlength=\"6\" name=\"%s\" value=\"%s\"></TD><TD>%s</TD></TR>\n",
	    $self->out_html_thumbnail, $self->primary_key, $self->out_html_label,
	    $self->primary_key, $self->aux_info('sort_order'), $authors);
}

sub out_html_row_choose {
    # 
    # A two column HTML row
    #

    my $self = shift;
    sprintf("<TR>\n<TD>%s</TD>\n<TD COLSPAN=2><P>%s</P></TD>\n</TR>\n",
	    $self->out_html_thumbnail_choose, $self->out_html_label_nolink
	    );
}

sub out_html_authors {
    #
    # Return comma-separated list of authors
    #

    my $self = shift;
    my $show_authors_flag = shift;

    my @users = ($show_authors_flag) ? $self->child_authors : $self->child_users;
    if ($self->type() eq 'External') {
		return $users[0];
	}
    return join (', ', map { $_->out_html_abbrev } @users);
}

sub out_html_table_authors {
    #
    # Return a table of the authors
    #

    my $self = shift;
    my @users = $self->child_users;
    return join ("\n", 
		 "<TABLE BORDER=0>",
		 "<TR><TD COLSPAN=4><B>Authors</B></TD></TR>",
		 map { $_->out_html_row } @users,
		 "</TABLE>\n"
		 ) if @users;
    return '';
}

sub out_html_table_child_content {
    #
    # Return a table of the child content linked from this document
    #

    my $self = shift;
    my @content = $self->child_users;
    return join ("\n", 
		 "<TABLE BORDER=0>",
		 "<TR><TD COLSPAN=4><B>Linked Content</B></TD></TR>",
		 map { $_->out_html_row } @content,
		 "</TABLE>\n"
		 ) if @content;
    return '';
}

sub out_label {
    #
    # A label for the object: its title
    #

    my $self = shift;
    my $label = $self->aux_info('label');
    return $label if $label;
    return $self->field_value('title');
}

sub out_abbrev {
    #
    # An abbreviation for the object: the first twenty characters of its
    # title
    #

    my $self = shift;
    my $label = $self->out_label;
    my $tail = length $label > 25 ? '...' : '';
    return substr ($label, 0, 25) . $tail;
}

sub out_html_body {
    #
    # Spit out the HTML in the body object
    #

    my $self = shift;
    my $outval = '';

    my $cs = $self->field_value('conversion_status');
    if (defined $cs && $cs eq "2") {
	return unless ($self->field_value('hscml_body'));
	my $hscml = HSDB4::XML::HSCML->new($self->field_value("hscml_body"));

	if ($hscml->error) {
	    $self->error($hscml->error);
	    return;
	}
	my $body = $hscml->out_html_body($self);
	if ($hscml->error) {
	    $self->error($hscml->error);
	    return;
	}
	return $body;
    }
    else {
    # Do a summary, if possible
    if ($self->out_summary) {
	$outval .= '<H3 class="title">Summary</H3>';
	$outval .= '<P class="summary">';
	$outval .= $self->out_summary . '<P>';
    }

    # Put in an outline, and do it by sections if we can
    if ($self->out_section_titles) {
	$outval .= '<H3 class="title">Outline</H3>';
	my @sec_titles = $self->out_section_titles;
	my @sections = $self->out_sections;
	$outval .= '<OL TYPE=I>';
	foreach my $row (0..$#sec_titles) {
	    $outval .= '<DIV class="docinfo"><LI><A HREF="#section-' . $row;
	    $outval .= '">' . $sec_titles[$row] . '</A></DIV>';
	}
	$outval .= '</OL>';

	# Now, actually put out the sections...
	$outval .= '<OL TYPE=I>';
	foreach my $row (0..$#sections) {
	    $outval .= '<H3 CLASS="title"><LI><A NAME="section-' . $row;
	    $outval .= '">' . $sec_titles[$row] . '</A></H3>';
	    $outval .= $sections[$row];
	    $outval .= '<DIV CLASS="auxlinks"><A HREF="#_top">Top</A></DIV>';
	}
	$outval .= '</OL>';
    }
 
    # Now get the body if it's there as well

    my $body = $self->body() or return;
    my ($html) = $body->tag_values ('html');
    $html = $html ? $html->value : '';

    # I hate Basis with a passion
    $html =~ s!^</PRE>!!i;
    $outval .= $html;
    }
    
    # And return the result
    return $outval;
}

sub out_html_appendix {
    #
    # Put the little stuff at the bottom: copyright, etc.
    #

    my $self = shift;
    my $outval = '';

    # Get the source...
    if (my $src_text = $self->source) {
	    $outval .= "<div><b>Source:</b> $src_text</div>\n";
    }

    # Get the contributor...
    my $body = $self->body();
	if ($body){
		my @cont = $body->tag_values('contributor');
		foreach my $cnt (@cont) {
			$cnt = $cnt->value;
			if($cnt){
				$outval .= "<div><b>Contributor:</b> $cnt</div>\n";
			}
		}
    }

    # Put on the copyright info...
    $outval .= "<div><b>Copyright Information:</b>\n";
    $outval .= "<i>@{[$self->field_value('copyright')]}</i></div>";

    return "<p class=\"appendix\">\n$outval</p>";
}

sub out_summary {
    #
    # Get the text of the summary in the body, if it's available
    #

    my $self = shift;
    # Get the summary XML object, if it's there
    my $body = $self->body();
    my ($summary_obj) = $body->tag_values ('summary') if ($body);
    # If it isn't, return nothing
    return unless $summary_obj;
    # Otherwise, return its value
    return $summary_obj->value;
}

sub out_section_titles {
    #
    # The titles of the different sections in the body, if they're there
    #

    my $self = shift;
    # Get the section XML objects
    my $body = $self->body();
    my @sections = $body->tag_values ('section') if ($body);
    # If there aren't any, just return;
    return unless @sections;
    # Otherwise, get their values
    return map { $_->get_attribute_values('section_title')->value } @sections;
}

sub out_sections {
    #
    # The values of the different sections in the body, if they're there
    #

    my $self = shift;
    # Get the section XML objects
    my $body = $self->body();
    my @sections = $body->tag_values ('section') if ($body);
    # If there aren't any, just return;
    return unless @sections;
    # Otherwise, get their values
    return map { $_->value } @sections;
}

sub out_url {
    #
    # Returns a URL for accessing complete info on the row
    #

    # Return the link to the row's fundamental page
    my $self = shift;
    # Get the base URL from HSDB4::Constants
    my $class = ref $self || $self;
    my $url = $HSDB4::Constants::URLs{$class};
    # And we're done if this is a class method; but otherwise...
    return $url unless ref $self;
    # ...stick in the path if it's in the aux info...
    my $path = $self->aux_info ('uri_path');
    $url .= "/$path" if $path;
    # ...and tack on the primary key
    return sprintf ("$url/%s", $self->primary_key);
}

sub out_url_mobi{
	my $self = shift;
	
	my $url = '/mobi/view/content/';
	my $path = $self->aux_info ('uri_path');
	$url .= "$path" if $path;
	# ...and tack on the primary key
	return sprintf ("$url/%s", $self->primary_key);
}

sub out_html_small_img {
    #
    # Return an HTML <IMG> tag for the document in question, and
    # undefined if it's not possible
    #

    my $self = shift;
	my $ext  = $self->image_available('small');
	
    return '' unless $ext;

	my $location = $self->get_image_location();

	my $sm_img= Image::Magick->new();
	my ($width, $height, $size, $format) = $sm_img->Ping( $TUSK::UploadContent::path{'slide'} . '/small/' . $location . '.' . $ext );
	
    return unless $width && $height;
    my $uri = $HSDB4::Constants::URLs{small_data} . "/" . $self->primary_key;
    return "<IMG WIDTH=\"$width\" HEIGHT=\"$height\" SRC=\"$uri\" BORDER=0>";
}

sub out_html_img {
    #
    # Return an HTML <IMG> tag for the document in question, and
    # undefined if it's not possible
    #

    my $self    = shift;
    my $size    = shift;
    my $overlay = shift;

    $size = 'large' unless $size;
    return '<!-- ' . $size . ' no good ( ' . $self->image_available($size) .  ' ) -->' unless $self->image_available($size);

	my $uri;
	
	if ($overlay) { $uri = '/overlay'; }
	
    $uri .= $HSDB4::Constants::URLs{$size} . "/" . $self->primary_key;
	return "<img class=\"mainImg\" src=\"$uri\">";
}

sub out_html_thumbnail_img {
    #
    # Return an HTML <IMG> tag for the document in question, and
    # undefined if it's not possible
    #

    my $self = shift;
	my $ext  = $self->image_available('thumb');
	
    return '' unless $ext;

	my $location = $self->get_image_location();

	my $thumbnail = Image::Magick->new();
	my ($width, $height, $size, $format) = $thumbnail->Ping( $TUSK::UploadContent::path{'slide'} . '/thumb/' . $location . '.' . $ext );
	
    # Scaling of the width and height
    my $right_height = shift;
    if ($right_height && ($right_height < $height)) {
		if (!defined($height) || $height == 0){
			return qq#<IMG WIDTH="$width" HEIGHT="$width" SRC="" BORDER=0>#;
		}
	$width *= $right_height/$height;
	$height = $right_height;
    }

    return unless $width && $height;
    my $uri = $self->out_html_thumbnail_uri;
    return "<IMG WIDTH=\"$width\" HEIGHT=\"$height\" SRC=\"$uri\" BORDER=0>";
}

sub out_html_thumbnail_img_choose {
    #
    # Return an HTML <IMG> tag for the document in question, and
    # undefined if it's not possible
    #

    my $self = shift;
	my $ext  = $self->image_available('thumb');
	
    return '' unless $ext;

	my $location = $self->get_image_location();

	my $thumbnail = Image::Magick->new();
	my ($width, $height, $size, $format) = $thumbnail->Ping( $TUSK::UploadContent::path{'slide'} . '/thumb/' . $location . '.' . $ext );
	
    # Scaling of the width and height
    my $right_height = shift;
    if ($right_height) {
        if (!defined($height) || $height == 0){
            return qq#<IMG WIDTH="$width" HEIGHT="$width" SRC="" BORDER=0>#;
        }
	$width *= $right_height/$height;
	$height = $right_height;
    }

    return unless $width && $height;
    my $uri = $self->out_html_thumbnail_uri_choose("image");
    return "<IMG WIDTH=\"$width\" HEIGHT=\"$height\" SRC=\"$uri\" BORDER=0>";
}

sub out_html_icon_img {
    #
    # Return an HTML <IMG> tag for the document in question, and
    # undefined if it's not possible
    #

    my $self = shift;
	my $ext  = $self->image_available('icon');
	
    return $self->out_html_thumbnail_img(36) unless $ext;

	my $location = $self->get_image_location();

	my $thumbnail = Image::Magick->new();
	my ($width, $height, $size, $format) = $thumbnail->Ping( $TUSK::UploadContent::path{'slide'} . '/icon/' . $location . '.' . $ext );

    # Scaling of the width and height
    my $right_height = shift;
    if ($right_height) {
		if (!defined($height) || $height == 0){
			return qq#<IMG WIDTH="$width" HEIGHT="$width" SRC="" BORDER=0>#;
		}
	$width *= $right_height/$height;
	$height = $right_height;
    }

    return unless $width && $height;
    my $uri = $self->out_html_thumbnail_uri;
	return "<IMG WIDTH=\"$width\" HEIGHT=\"$height\" SRC=\"$uri\" BORDER=0>";
}

sub out_html_thumbnail_uri {
    my $self = shift;
    return $HSDB4::Constants::URLs{thumbnail} . "/" . $self->primary_key;
}

sub out_html_thumbnail_uri_choose {
    my $self = shift;
    my $type = shift;
    $type = $self->field_value('type') unless ($type);
    return $HSDB4::Constants::URLs{choose}."/".$type."/".$self->primary_key;
}

sub out_hscml {
    my $self = shift;
    return unless ($self->field_value('hscml_body'));
    my $body = $self->field_value('hscml_body');
    return $body;
}

sub error {
    my $self = shift;
    my $error = shift;
    if ($error) {
	$self->{error} = $error;
    }
    return $self->{error};
}

sub xsl_stylesheet {
    my $self = shift;
    my $style = shift;
    if ($style) {
	$self->{stylesheet} = $style;
    }
    return $self->{stylesheet};
}


sub _make_object_ref {
	my ($self, $uri, $duri, $w, $h, $ho, $hp, $he, $extratext) = @_;
	my $tag;
	$tag = qq{<p><object width="$w" height="$h"};

	# Add all the optional OBJECT tuples
	if ( scalar %$ho ) {
		map { $tag .= ' ' . $_ . '="' . $ho->{$_} . '"'; } keys %$ho;
	}
	$tag .= qq{>\n};

	# Generate the PARAM tags
	if ( !( $uri =~ /flv$/ ) ) {
		$tag .= qq{<param name="src" value="$uri">\n};
	}
	if ( scalar %$hp ) {
		map { $tag .= '<param name="' . $_ . '" value="' . $hp->{$_} . qq{">\n}; } keys %$hp;
	}

	# Generate the EMBED tuples
	if ( !( $uri =~ /flv$/ ) ) {
		$tag .= qq{<embed src="$uri" width="$w" height="$h"};
		if ( scalar %$he ) {
			map { $tag .= ' ' . $_ . '="' . $he->{$_} . '"'; } keys %$he;
		}
		$tag .= qq{>\n</embed>\n};
		$tag .= qq{<noembed><a href="$duri">Click to play.</a></noembed>\n};
	}

	$tag .= qq{$extratext};

	$tag .= qq{</object></p>\n};

	return $tag;
}

sub _player_header {
	my ($self, $autoplay, $title, $content_type, $download_player_url) = @_;
	my ($res);

	$res = q{<p><b>};
	$res .= qq{Click play to start $content_type.<br>\n} if ( $autoplay eq 'false' );
	$res .= qq{If you cannot see the plugin, download the FREE $title Player <a href="$download_player_url" target="_blank"> here</a></b>.\n};

	return $res;
}

sub _player_footer {
	my ($self, $display_type, $content_type, $uri) = @_;
	my ($res);

	if ($display_type eq 'Downloadable' or $display_type eq 'Both'){
		my $download_uri;
		if    ( $content_type eq "audio" ) { $download_uri = &TUSK::Core::ServerConfig::dbAudioHost . $uri; }
		elsif ( $content_type eq "video" ) { $download_uri = &TUSK::Core::ServerConfig::dbVideoHost . $uri; }
		elsif ( $content_type eq "flash" ) { $download_uri = $uri; }
		$res = qq{<p><a href="} . $download_uri . qq{">Click to Download</a></p>\n};
		$res .= "<p>You will need a media player installed on your computer.<br>If you have problems saving file right click on link and select &quot;save target as&quot; (in IE) or &quot;save link as&quot; (in Firefox).</p>\n";
	}

	return $res;
}

# Some internal functions to embed video and audio player code.
sub _embed_qt_player {
    my ($self, $height, $width, $autoplay, $uri, $display_type) = @_;

    my $content_type = 'video';
    $content_type = 'audio' if ( $uri =~ /\.mp3$/ );
    
    my $media_server=(($content_type eq "audio" ) ? &TUSK::Core::ServerConfig::dbAudioHost : &TUSK::Core::ServerConfig::dbVideoHost);
    my $full_uri = $media_server . $uri;
    my $display;

    # The QuickTime Control Panel is 16 pixels high, so add that 
    # to our given height.
    $height += 16;
    
    if ($display_type eq 'Stream' or $display_type eq 'Both'){

        $display = $self->_player_header($autoplay, 'QuickTime', $content_type, 'http://www.apple.com/quicktime/download/');

        $display .= $self->_make_object_ref (
            $full_uri,
            $full_uri,
            $width,
            $height,
            {
                CLASSID => 'clsid:02BF25D5-8C17-4B23-BC80-D3488ABDDC6B',
            },
            {
                CONTROLLER => 'true',
                LOOP => 'false',
                AUTOPLAY => $autoplay,
                KIOSKMODE => ($display_type eq 'Stream' ? 'true': 'false'),
                SCALE => 'aspect',
            },
            {
                CONTROLLER => 'true',
                LOOP => 'false',
                PLUGINSPAGE => 'http://www.apple.com/quicktime/download/',
                AUTOPLAY => $autoplay,
                KIOSKMODE => ($display_type eq 'Stream' ? 'true': 'false'),
                SCALE => 'aspect',
            },
        );
    }

    return $display;
}

sub _embed_real_player {
    my ($self, $height, $width, $autoplay, $uri, $display_type) = @_;

    my $content_type = 'video';
    $content_type = 'audio' if ( $uri =~ /\.(ra|mp3)$/ );

    my $media_server=(($content_type eq "audio" ) ? &TUSK::Core::ServerConfig::dbAudioHost : &TUSK::Core::ServerConfig::dbVideoHost);
    my $full_uri = $media_server . '/ramgen' . $uri;
    my $download_uri = $media_server . $uri;
    my $display;
    
    if ($display_type eq 'Stream' or $display_type eq 'Both'){

        $display = $self->_player_header($autoplay, 'Real', $content_type, 'http://www.real.com/realsuperpass.html');

        # Only needed for video
        $display .= $self->_make_object_ref (
            $full_uri,
            $download_uri,
            $width,
            $height,
            {
                CLASSID => 'clsid:CFCDAA03-8BE4-11cf-B84B-0020AFBBCCFA',
                ID => 'RVOCX',
                style => 'z-index:1000;'
            },
            {
                CONTROLS => 'ImageWindow',
                CONSOLE => 'one',
                AUTOSTART => $autoplay,
                LOOP => 'false',
                MAINTAINASPECT => 'true',
                PREFETCH => 'true',
            },
            {
                CONTROLS => 'ImageWindow',
                CONSOLE => 'one',
                NOJAVA => 'true',
                TYPE => 'audio/x-pn-realaudio-plugin',
                AUTOSTART => $autoplay,
                MAINTAINASPECT => 'true',
                PREFETCH => 'true',
            },
        ) if ($content_type eq 'video');

        # Display the audio/video Control panel
        $display .= $self->_make_object_ref (
            $full_uri,
            $download_uri,
            $width,
            36,
            {
                CLASSID => 'clsid:CFCDAA03-8BE4-11cf-B84B-0020AFBBCCFA',
                ID => 'RVOCX',
                style => 'z-index:1000;'
            },
            {
                CONTROLS => 'ALL',
                CONSOLE => 'one',
                AUTOSTART => $autoplay,
                LOOP => 'false',
                PREFETCH => 'true',
            },
            {
                CONTROLS => 'ControlPanel',
                CONSOLE => 'one',
                NOJAVA => 'true',
                TYPE => 'audio/x-pn-realaudio-plugin',
                AUTOSTART => $autoplay,
                PREFETCH => 'true',
            },
        );
    }

    return $display;
}

sub _embed_wm_player {
    my ($self, $height, $width, $autoplay, $uri, $display_type) = @_;

    my $content_type = 'video';
    $content_type = 'audio' if ( $uri =~ /\.wma$/ );

    my $media_server=(($content_type eq "audio" ) ? &TUSK::Core::ServerConfig::dbAudioHost : &TUSK::Core::ServerConfig::dbVideoHost);
    my $full_uri = $media_server . '/asxgen' . $uri;
    my $download_uri = $media_server . $uri;
    my $display;
    
    if ($display_type eq 'Stream' or $display_type eq 'Both'){

        $display = $self->_player_header($autoplay, 'Windows Media', $content_type, 'http://microsoft.com/windows/mediaplayer/en/download/');
        $display .= $self->_make_object_ref (
            $full_uri,
            $download_uri,
            $width,
            $height,
            {
                CLASSID => 'clsid:22D6F312-B0F6-11D0-94AB-0080C74C7E95',
                ID => 'MediaPlayer',
                TYPE => 'application/x-oleobject',
            },
            {
                FileName => $full_uri,
                ShowControls => 'true',
                ShowStatus => 'false',
                ShowDisplay => 'false',
                AUTOSTART => $autoplay,
            },
            {
                TYPE => 'application/x-mplayer2',
                NAME => 'MediaPlayer',
                PLUGINSPAGE => 'http://microsoft.com/windows/mediaplayer/en/download/',
                AUTOSTART => $autoplay,
                ShowControls => '1',
                ShowStatus => '0',
                ShowDisplay => '0',
            },
        );
    }

    return $display;
}

sub is_mobile_ready{
	return 0;
}

sub get_originating_course {
	my $self              = shift;
	my $integrated_course = shift;

	if ( $integrated_course ->isa("HSDB45::Course") ) {
		my $tusk_course = TUSK::Course->new()->lookupKey($integrated_course->getTuskCourseID());
		# return specific originating course
		my $link_object = TUSK::Core::LinkIntegratedCourseContent->new()->passValues($tusk_course)->lookupByRelation( $tusk_course->getFieldValue('course_id'), $self->content_id );
		if ( $link_object ) {
			my $originating_course = $link_object->getOriginatingCourseObject;
			return $originating_course->getHSDB45CourseFromTuskID();
		}
	} 

	return undef;
}

package HSDB4::SQLRow::Content::Document;
use strict;
use Carp;
use vars qw (@ISA);
@ISA = ('HSDB4::SQLRow::Content');

sub out_html_body{
    my ($self) = @_;
    return $self->SUPER::out_html_body() unless ($self->field_value('reuse_content_id'));
    if ($self->{_orig_body}){
	return ($self->SUPER::out_html_body() . "<br><br>" . $self->{_orig_body} );
    }else{
	my $html;
	$html = $self->body->tag_values('html')->value . "<br><br>" if ($self->body && $self->body->tag_values('html'));
	return ($html . $self->SUPER::out_html_body()); 
    }
}

sub out_html_icon {
    #
    # Return document icon
    #

    my $self = shift;
    return sprintf("<A HREF=\"%s\">%s</A>", $self->out_url, 
		   $self->out_icon);
}

sub out_icon {
    my $self = shift;
    return "<img src=\"/icons/ico-htm.gif\" width=\"18\" height=\"22\" border=\"0\">";
}

sub out_html_thumbnail_img {
    #
    # Return what should go in the thumbnail part of an row
    #

    my $self = shift;
    return $self->out_icon;
}

sub out_html_thumbnail {
    #
    # Return a different thumbnail
    #

    my $self = shift;
    return sprintf("<A HREF=\"%s\">%s</A>", $self->out_url, 
		   $self->out_html_thumbnail_img);
}

sub out_html_thumbnail_choose {
    #
    # Return a different thumbnail
    #

    my $self = shift;
    return "<IMG SRC=\"/chooser_icon/text/".$self->primary_key."\" WIDTH=\"18\" HEIGHT=\"22\">";
}

sub out_html_label_choose {
    my $self = shift;
    return "<A HREF=\"content_choose?SEARCH=0&content_id=".$self->primary_key."\">".$self->out_label."</A>";
}

sub out_html_row_choose {
    # 
    # A two column HTML row
    #

    my $self = shift;
    sprintf("<TR>\n<TD>%s</TD>\n<TD COLSPAN=2><P>%s</P></TD>\n</TR>\n",
	    $self->out_html_thumbnail_choose, $self->out_html_label_choose
	    );
}

sub out_xml {
    my $self = shift;
    my $xml = $self->field_value("hscml_body");

    return unless ($xml);
	
    my $course_title=$self->course->field_value("title");
    my $content_title=$self->field_value("title");
	
    my $xml_start ="\n<db-content course=\"$course_title\" title=\"$content_title\">";
    $xml=~s/<db-content[^>]*>/$xml_start/gis;
    $xml=~s/<!DOCTYPE content SYSTEM "/<!DOCTYPE content SYSTEM "\/usr\/local\/apache\/apache\/HSCML\/Rules\//;
    $xml=~s/hscml.dtd/hscmlpdf.dtd/;
    $xml=~s/\r//g;
    $xml=~s/([\x80-\xff])/sprintf("\&#%d;",ord($1))/eg;
    $xml=~s/[\x00-\x09\x0b-\x1f]//g; # get rid of all char that aren't printable except for new line
	
    my $temp="\&#8203;";
	
    $xml=~s/,/,$temp/g;
    $xml=~s/\)/\)$temp/g;
    $xml=~s/\(/$temp\(/g;
    return $xml;
}

sub is_mobile_ready{
	return 1;
}

package HSDB4::SQLRow::Content::TUSKdoc;
use strict;
use Carp;
use vars qw (@ISA);
@ISA = ('HSDB4::SQLRow::Content');

sub out_html_body{
    my ($self) = @_;
    $self->field_value('conversion_status', 2); # hack that should be removed when there are no more xml documents that have type = 'Document'
    return ($self->SUPER::out_html_body()); 
}

sub out_file_path{
	my ($self) = @_;

	my $id = ($self->reuse_content_id())? $self->reuse_content_id() : $self->primary_key();
	my $fname_doc  = $TUSK::UploadContent::path{'doc-archive'} . "/$id.doc";
	my $fname_docx = $TUSK::UploadContent::path{'doc-archive'} . "/$id.docx";
	my $file_uri;

	if (-e ($fname_doc) ) {
		$file_uri = $fname_doc;
	}
	elsif (-e ($fname_docx) ) {
		$file_uri = $fname_docx;
	}

	return $file_uri;
}

sub out_html_icon {
    #
    # Return document icon
    #

    my $self = shift;
    return sprintf("<A HREF=\"%s\">%s</A>", $self->out_url, 
		   $self->out_icon);
}

sub out_icon {
    my $self = shift;
    return "<img src=\"/icons/ico-htm.gif\" width=\"18\" height=\"22\" border=\"0\">";
}

sub out_html_thumbnail_img {
    #
    # Return what should go in the thumbnail part of an row
    #

    my $self = shift;
    return $self->out_icon;
}

sub out_html_thumbnail {
    #
    # Return a different thumbnail
    #

    my $self = shift;
    return sprintf("<A HREF=\"%s\">%s</A>", $self->out_url, 
		   $self->out_html_thumbnail_img);
}

sub is_mobile_ready{
	return 1;
}

sub showConversionStatus {
	my $self = shift;

	my $tracker = TUSK::ProcessTracker::ProcessTracker->new()->getMostRecentTracker(undef, $self->primary_key(), 'tuskdoc');
	if (defined $tracker) {
		my $modified = HSDB4::DateTime->new()->in_mysql_timestamp($tracker->getModifiedOn());
		my $three_hrs_ago = HSDB4::DateTime->new();
		$three_hrs_ago->subtract_hours(3);

		if (!$tracker->isCompletedSuccessfully() ||  $modified->is_after($three_hrs_ago)) {
			return 1;
		}
	}
	return 0;
}


package HSDB4::SQLRow::Content::Collection;
use strict;
use vars qw (@ISA);
@ISA = ('HSDB4::SQLRow::Content');

sub out_html_icon {
    my $self = shift;
    return $self->out_html_thumbnail;
}

sub out_icon {
    my $self = shift;
    my $id = shift;
    my $string = "<IMG SRC=\"/icons/ico-folder.gif\" WIDTH=\"20\" HEIGHT=\"22\" BORDER=\"0\"";
    if($id) {$string .= " id=\"$id\"";}
    $string .= ">";
    return $string;
}

sub out_html_thumbnail {
    # 
    # Return a row version of the document
    #
 
    my $self = shift;

    my $thumbnail = "<IMG SRC=\"/icons/folder.gif\" WIDTH=20 HEIGHT=22 BORDER=0>";
    return sprintf ("<A HREF=\"%s\">%s</A>", $self->out_url, $thumbnail);
}

sub out_xml {
    my $self = shift;
    my @content = $self->child_content;
    my $authors = "";
    my $xml = "";
    foreach (@content){
	next unless ($_->field_value('type') eq 'Slide');
      	$xml.=$_->out_xml;
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

    (my $copyright=$self->field_value("copyright"))=~s/"/\\"/g;
    my $title=$self->field_value("title");
    $title=~s/"//g;
    $authors=~s/"//g;
    $copyright=~s/"//g;
    my $tufts_icon="http://" . $ENV{HTTP_HOST} . "/icons/little/alhsdb4-style.gif";
    $xml=~s/([\x80-\xff])/sprintf("\&#%d;",ord($1))/eg;
	
    if ($xml){
      	return "<COLLECTION NAME=\"".$title."\"
 		AUTHOR=\"".$authors."\" 
		COPYRIGHT=\"".$copyright."\"
	        ICONSOURCE=\"".$tufts_icon."\">\n".
		$xml.
		"</COLLECTION>";
    } else {
	return;
    }
}

sub is_mobile_ready{
	return 1;
}

package HSDB4::SQLRow::Content::Slide;
use strict;
use IO::File;
use vars qw (@ISA);
@ISA = ('HSDB4::SQLRow::Content');

sub out_index_body {
	my $self = shift;
        my $returnValue = $self->out_html_body();
        if($self->body && $self->body->tag_values('indexOn')) {
		$returnValue .= $self->body->tag_values('indexOn')->value;
	}
	return $self->SUPER::out_index_body($returnValue);
}

sub generate_image_sizes {
    my $self = shift;
    my %args = @_;
    require HSDB4::Image;

    die "Cannot find image and type" unless ($args{-blob} && $args{-type});

	foreach my $cur_size ( @HSDB4::Constants::image_sizes ) {
		next if ($cur_size eq 'resize');
		
		my ($blob, $type, $width, $height);
		
		if ( $cur_size eq 'small' ) {
			($blob, $type, $width, $height) = HSDB4::Image::make_small(-blob =>  $args{-blob}, -type => $args{-type}, -blur => "-1");
		} elsif ( $cur_size eq 'icon' ) {
			($blob, $type, $width, $height) = HSDB4::Image::make_icon(-blob =>  $args{-blob}, -type => $args{-type}, -blur => "-1");
		} elsif ( $cur_size eq 'large' ) {
			($blob, $type, $width, $height) = HSDB4::Image::make_large(-blob =>  $args{-blob}, -type => $args{-type}, -blur => "-1");
		} elsif ( $cur_size eq 'orig' ) {
			($blob, $type, $width, $height) = HSDB4::Image::make_original(-blob =>  $args{-blob}, -type => $args{-type}, -blur => "-1");
		} elsif ( $cur_size eq 'xlarge' ) {
			($blob, $type, $width, $height) = HSDB4::Image::make_xlarge(-blob =>  $args{-blob}, -type => $args{-type}, -blur => "-1");
		} elsif ( $cur_size eq 'medium' ) {
			($blob, $type, $width, $height) = HSDB4::Image::make_medium(-blob =>  $args{-blob}, -type => $args{-type}, -blur => "-1");
		} elsif ( $cur_size eq 'thumb' ) {
			($blob, $type, $width, $height) = HSDB4::Image::make_thumb(-blob =>  $args{-blob}, -type => $args{-type}, -blur => "-1");
		}
		
		if    ( $args{-type} eq 'x-png' ) { $args{-type} = 'png'; }
		elsif ( $args{-type} eq 'jpeg' )  { $args{-type} = 'jpg'; }
		
		my $location = $self->get_image_location();
		
		open(IMG, ">".$args{-path}."/".$cur_size."/".$location.".".$args{-type}) or die($! . " -- ".$args{-path}."/".$cur_size."/".$location.".".$args{-type});
		binmode(IMG);
		print IMG $blob;
		close(IMG);		
	}
}

sub get_type {
    ## take in binary data and return a file type
    my $self = shift;
    my $i = shift;
    my %types = ('CompuServe graphics interchange format'  => 'image/gif',
		 'Joint Photographic Experts Group JFIF format' => 'image/jpeg',
		 'Portable Network Graphics'  => 'image/png');
    return $types{$i->get('format')};
}

sub get_image {
    my $self = shift;
    my $fh = shift;
    my ($bytesread,$image_binary,$buffer);
    while ($bytesread=read($fh,$buffer,4000)) {
	   $image_binary .= $buffer;
    }
    return $image_binary;
}

sub small_data_preferred {
    #
    # Figure out from the XML if the small size is preferred, and return 1
    # if so
    #

    my $self = shift;

    # Get the slide_info tag
    my ($info);
    if (my $body = $self->body){
	$info = $body->tag_values('slide_info');
    } 
    return 0 unless $info;
    # Get the attributes
    my $size = $info->get_attribute_values('preferred_size');
    # Now, do the check and return the values
    if ($size and $size->value eq 'small') { return 1 }
    return 0;
}

sub overlay_data{
    #
    # Get the overlay information if it's required
    #

	my $self = shift;
	my $info;
	if(my $body = $self->body()){
		($info) = $body->tag_values('slide_info') or return;
	}
	return 0 unless $info;

    return $info->tag_values('overlay');
}

sub get_zoom_menu{
	my ($self, $img) = @_;
	
	my ($class_med,$class_larg,$class_xl,$class_orig) = ("zoomBtn","zoomBtn","zoomBtn","zoomBtn");

	if ( index($img,"/medium/") > -1 ) { $class_med=$class_med." active";}
	elsif ( index($img,"/large/") > -1 ) { $class_larg=$class_larg." active";}
    elsif ( index($img,"/xlarge/") > -1 ) { $class_xl=$class_xl." active";}
    elsif ( index($img,"/orig/") > -1 ) { $class_orig=$class_orig." active";}

	my $mark_up = qq {
<div class="imgCntrlArea">
	<div class="imgControlMenu clearfix">
		<a href="javascript:;" onclick="toggleImgCntrl(this)" class="toggleImgCntrl nodots subHead1">Image Zoom</a>
		<div class="imgCntrl">
		<img class="$class_med" onclick="swapImg('medium', this);" src="/graphics/zoommedium.gif" height="27" width="27" border="0"><!--
		--><img class="$class_larg" onclick="swapImg('large', this);" src="/graphics/zoomlarge.gif" height="27" width="27" border="0"><!--
		--><img class="$class_xl" onclick="swapImg('xlarge', this);" src="/graphics/zoomxlarge.gif" height="27" width="27" border="0"><!--
		--><img class="$class_orig" onclick="swapImg('orig', this);" src="/graphics/zoomorig.gif" height="27" width="27" border="0">
		
		</div>
	</div>
	<div class="image">$img</div>
</div>
};
	return $mark_up
}

sub out_html_thumbnail {
    #
    # Return a different thumbnail
    #

    my $self = shift;
    return sprintf("<a href=\"%s\">%s</a>", $self->out_url, $self->out_html_thumbnail_img(36));
}

sub out_icon {
    my $self = shift;
    return $self->out_html_icon_img;
}

sub out_html_icon {
    #
    # Return a different thumbnail
    #

    my $self = shift;
    return sprintf("<a href=\"%s\">%s</a>", $self->out_url, $self->out_html_icon_img);
}

sub out_html_thumbnail_choose {
    #
    # Return a different thumbnail
    #

    my $self = shift;
    return sprintf($self->out_html_thumbnail_img_choose(36));
}

sub out_html_row {
    # 
    # Return a row version of the document
    #

    my $self = shift;
    my %params = @_;

    my @users = $self->child_users;
    my @non_users = $self->child_non_users;
    push(@users,@non_users);
    @users = grep { $_->aux_info("roles") =~ /Author/ } @users;
    my $col2;
    if ($params{'cms'}){
    	$col2 = sprintf ('<a href="/cms/content/display/%d">edit %s</a>', $self->primary_key, $self->out_label);
    } elsif (exists($params{'content-link'})){
    	$col2 = sprintf ('<a href="%s/%d">%s</a>', $params{'content-link'}, $self->primary_key, $self->out_label);
    } else {
        $col2 = $self->out_html_label;
    }
    my $authors = join (', ', map { $_->out_abbrev } @users);
    my $r;
    if ($params{'sort_order'}){
        $r =sprintf("<tr><td>%s</td><td>%s</td><td><B>%s</B></td><td>%s</td><td>%s</td></tr>\n",
            $self->aux_info('sort_order') || '&nbsp;',
            $self->out_html_thumbnail(36), $col2, $authors);
    } else {
        $r =sprintf("<tr><td class=\"html_row\">%s</td><td colspan=\"2\" class=\"html_row\"><b>%s</b></td><td class=\"html_row\">%s</td></tr>\n",
            $self->out_html_thumbnail(36), $col2, $authors);
    }
    return $r;
}

sub out_stain{
    #
    # Return the value of the stain element
    #

    my ($self) = @_;
    
    if (my $body = $self->body){
	my $info = $body->tag_values('slide_info') or return ;
	if (my ($stain) = $info->tag_values ('stain')) {
	    return $stain->value;
	}
    }
    return '';
}

sub out_just_body {

 my $self = shift;
    my %options = @_;
    my $outval = '';
=head  
    # I'll put in STAIN and IMAGE_TYPE here
    my $info;
    if (my $body = $self->body){
	($info) = $body->tag_values('slide_info'); 
	my $outval2 = '';
	if ($info && (my ($stain) = $info->tag_values ('stain'))) {	    
	    $outval .= sprintf("<DIV><B>Stain:</B> %s</DIV>\n", $stain->value) if ($stain->value);
	}
	if ($info &&( my ($type) = $info->tag_values ('type'))) {
	    $outval .= sprintf("<DIV><B>Image Type:</B> %s</DIV>\n", 
			       $type->value);
	}
	$outval .= "<P CLASS=\"slide_info\">\n$outval2</P>" if $outval2;
    }
	if ( $self->overlay_data ) {
		if ($options{OVERLAY}) {
		    $outval .= "<div><form>\n";
		    $outval .= "<input type=\"hidden\" name=\"SIZE\" value=\"$options{SIZE}\">";
		    $outval .= "<input type=\"hidden\" name=\"OVERLAY\" value=\"0\">";
		    $outval .= "<input type=\"submit\" value=\"Hide Overlay\">\n";
		    $outval .= "</form></div>\n";
		}
		else {
		    $outval .= "<div><form>\n";
		    $outval .= "<input type=\"hidden\" name=\"SIZE\" value=\"$options{SIZE}\">";
		    $outval .= "<input type=\"hidden\" name=\"OVERLAY\" value=\"1\">";
		    $outval .= "<input type=\"submit\" value=\"Show Overlay\">\n";
		    $outval .= "</form></div>\n";
		}
	}
    # Tack on the rest of the body
=cut
    $outval .= $self->SUPER::out_html_body();
    return $outval;
}

sub out_html_body {
    #
    # Return the actual HTML busines, including slides
    #

    my $self = shift;
    my %options = @_;
    my $outval = '';
    # Get the big image by default
    my $img = $self->out_html_img($options{SIZE}, $options{OVERLAY});
    # Put it in a DIV
	if ($options{OVERLAY} || !$options{'zoom'}){
		$outval .=  '<div class="image">' . $img . "</div>\n";
	} else {
		$outval .= $self->get_zoom_menu($img);
	}

    # I'll put in STAIN and IMAGE_TYPE here
    my $info;
    if (my $body = $self->body){
	($info) = $body->tag_values('slide_info'); 
	my $outval2 = '';
	if ($info && (my ($stain) = $info->tag_values ('stain'))) {	    
	    $outval .= sprintf("<DIV><B>Stain:</B> %s</DIV>\n", $stain->value) if ($stain->value);
	}
	if ($info &&( my ($type) = $info->tag_values ('type'))) {
	    $outval .= sprintf("<DIV><B>Image Type:</B> %s</DIV>\n", 
			       $type->value);
	}
	$outval .= "<P CLASS=\"slide_info\">\n$outval2</P>" if $outval2;
    }
	if ( $self->overlay_data ) {
		if ($options{OVERLAY}) {
		    $outval .= "<div><form>\n";
		    $outval .= "<input type=\"hidden\" name=\"SIZE\" value=\"$options{SIZE}\">";
		    $outval .= "<input type=\"hidden\" name=\"OVERLAY\" value=\"0\">";
		    $outval .= "<input type=\"submit\" value=\"Hide Overlay\">\n";
		    $outval .= "</form></div>\n";
		}
		else {
		    $outval .= "<div><form>\n";
		    $outval .= "<input type=\"hidden\" name=\"SIZE\" value=\"$options{SIZE}\">";
		    $outval .= "<input type=\"hidden\" name=\"OVERLAY\" value=\"1\">";
		    $outval .= "<input type=\"submit\" value=\"Show Overlay\">\n";
		    $outval .= "</form></div>\n";
		}
	}
    # Tack on the rest of the body
    $outval .= $self->SUPER::out_html_body();
    return $outval;
}

sub out_xml {
    #
    # An XML representation of the row
    #
    my $self = shift;
    my $uri = shift;

    my $title=$self->field_value('title');
    if (length($title) >57){
	$title=substr($title,0,60);
	$title.="...";
    }
    
    $title =~ s/(\&amp;|\&)/\&amp;/g;
    $title =~ s/\&amp;([A-z0-9]+;)/\&$1/g;
    $title =~ s/<br>/\n/g;
    $title =~ s/</\&lt;/g;
    $title =~ s/>/\&gt;/g;

    $uri = $HSDB4::Constants::URLs{data} . "/" . $self->primary_key unless ($uri);    
    return ("\t<SLIDE SRC=\"" . $uri . "\">\n\t\t" . $title . "\n\t</SLIDE>\n");
}

sub is_mobile_ready{
	return 1;
}

package HSDB4::SQLRow::Content::Question;
use strict;
use vars qw (@ISA);
@ISA = ('HSDB4::SQLRow::Content');

sub answers {
    #
    # Get the answers to this question
    #

    my $self = shift;
    unless ($self->{-answers}) {
	my @conds = (sprintf ("content_id=%d", $self->primary_key),
		     "to_days(modified) >= to_days(now())-180");
	my @answers = HSDB4::SQLRow::Answer->lookup_conditions (@conds);
	$self->{-answers} = \@answers;
    }
    return @{$self->{-answers}};
}

sub correct_answers {
    #
    # Return the correct answers
    # 

    my $self = shift;
    return grep { $_->field_value ('correct') eq 'Correct' } $self->answers;
}

sub incorrect_answers {
    #
    # Return the incorrect answers
    # 

    my $self = shift;
    return grep { $_->field_value ('correct') eq 'Incorrect' } $self->answers;
}

sub answer_hash {
    #
    # Return a hash of the answers
    #

    my $self = shift;
    my %answers = ();
    foreach ($self->answers) { $answers{uc $_->field_value ('answer')}++ }
    return %answers;
}

sub out_form_id {
    # 
    # Gives an id suitable for being in a form
    #

    my $self = shift;
    return "Q-" . $self->primary_key;
}

sub out_choice_row {
    #
    # Spits out a row for a particular choice, which is an XML object
    #

    my $self = shift;
    my $choice = shift;

    my $id= $self->out_form_id;
    my $label = uc $choice->get_attribute_values('label')->value;
    my $answer = shift;
    my $ch =  $label eq uc $answer ? ' CHECKED' : '';

    my $button = "<INPUT TYPE=\"radio\"$ch NAME=\"$id\" VALUE=\"$label\">";
    my $val = $choice->value;
    return "<TR><TD>$button</TD><TD><B>($label)</B></TD><TD>$val</TD></TR>\n";
}

sub correct_answer {
    #
    # Return the value of the correct answer to the question
    #

    my $self = shift;
    # Get the question
    if (my $body = $self->body()){
	my ($question) = $body->tag_values('question_info');
	# Now get the answer
	my ($answer) = $question ? $question->tag_values('correct_answer') : ();
	# And return it
	return $answer->value;
    } 
    return ;
}

sub out_response_row {
    #
    # Returns a row with the given response
    #

    my $self = shift;
    my $resp = shift;
    return "<TR><TD>&nbsp;</TD><TD>&nbsp;</TD><TD><B>Response:</B> " 
	. $resp->value . "</TD></TR>\n";
}

sub out_html_body {
    #
    # Return a nice version of the body
    #

    my $self = shift;
    # First, show the image, if it's there
    my $outval = $self->out_html_img || $self->out_html_small_img;
    # Then, show the image if it's there...
    $outval .= $self->SUPER::out_html_body ();

    # And now, do the choices/responses/correct answer part
    my $question;
    if (my $body = $self->body()){
	($question) = $body->tag_values('question_info');
    } else {
	return;
    } 

    my %args = @_;
    my $id= $self->out_form_id;
    my $answer = '';
    $answer = $args{$id} if exists $args{$id};

    # Figure out parameters. Default is with form, without answers
    my $doform = 1;
    my $doanswer = 0;
    # Get the arguments
    $doform = $args{'-form'} if exists $args{'-form'};
    $doanswer = $args{'answers'} if exists $args{'answers'};

    # Start the display...
    $outval .= "<FORM METHOD=\"POST\">\n" if $doform;
    $outval .= "<TABLE BORDER=0 CELLPADDING=1 CELLSPACING=1>\n";
    # Get the choices, and make them into a table
    my @choices = $question ? $question->tag_values('choice') : ();
    my @resps = $question ? $question->tag_values('response') : ();
    foreach my $choice (@choices) {
	$outval .= $self->out_choice_row ($choice, $answer);
	if ($doanswer and $resps[0]
	    and $choice->get_attribute_values('label')->value eq
	    $resps[0]->get_attribute_values('label')->value) {
	    $outval .= $self->out_response_row (shift @resps);
	}
    }
    # Or, if they're not there, then display a nice text box
    if (not @choices) {
	$outval .= "<TR><TD COLSPAN=2><B>Response:</B></TD>\n";
	$outval .= "<TD><INPUT TYPE=\"TEXT\" VALUE=\"$answer\" NAME=\"$id\"></TD></TR>\n";
    }
    # End the table
    if ($doanswer) {
	my ($answer) = 
	  $question ? $question->tag_values('correct_answer') : ();
	if ($answer) {
	    $outval .= "<tr><td colspan=\"2\"><b>Answer:</b></td>";
	    $outval .= "<td>" . ucfirst $answer->value . ".";
	    if ($self->correct_answers > 0) {
		$outval .= sprintf ("  Users answering correctly: %.1f%%",
				    100*$self->correct_answers/$self->answers);
		$outval .= sprintf (" (%d responses).", 
				    scalar ($self->answers));
	    }
	    $outval .= "</td></tr>";
	    if ($self->correct_answers > 0) {
		$outval .= "<tr><td colspan=\"2\">&nbsp;</td><td>";
		my %answers = $self->answer_hash;
		foreach (keys %answers) {
		    $outval .= sprintf "<b>%s</b>: %d ", $_, $answers{$_};
		}
		$outval .= "</td></tr>";
	    }
	}
   }
    $outval .= "</TABLE>\n";

    # If we have to do the form, put the submission buttons on the end
    if ($doform) {
	$outval .= 
	    "<DIV><INPUT TYPE=\"submit\" NAME=\"answers\" VALUE=\"Get Answers\">";
	$outval .= "</DIV>\n";
	$outval .= "</FORM>\n";
    }

    # And return the string!
    return $outval;
}

package HSDB4::SQLRow::Content::Flashpix;
use strict;
use vars qw (@ISA);
@ISA = ('HSDB4::SQLRow::Content');

sub out_html_thumbnail {
    #
    # Return a different thumbnail
    #

    my $self = shift;
    return sprintf("<A HREF=\"%s\">%s</A>", $self->out_url, 
		   $self->out_html_thumbnail_img (36));
}

sub out_html_thumbnail_choose {
    #
    # Return a different thumbnail
    #

    my $self = shift;
    return sprintf($self->out_html_thumbnail_img_choose(36));
}

sub out_html_body {
    #
    # Make a reasonable Flashpix display
    #

    my $self = shift;
    my %options = @_;
    my $element;
    if (my $body = $self->body) {
	$element = $body->tag_values ('flashpix_uri');
    }
    return unless $element;
    my $filename = $element->value;
    $filename =~ s#^/?flashpix/##;
    my $width = 600;
    my $height = 400;

    my $media_server=&TUSK::Core::ServerConfig::dbFlashPixHost;

my $applet = "<APPLET code=\"zoom2dapplet\" archive=\"zoom2dapplet.jar\" codeBase=\"$media_server/obj=delivery,1.0&cmd=retrieve&fif=servercomponents/code\" width=\"$width\" height=\"$height\">
<PARAM NAME=\"url\" VALUE=\"$media_server/fif=$filename\">
<strong>If you do not see an image above, first be sure that Java is enabled in your browser. If there is still a problem, <a href=\"http://www.java.com/en/download/index.jsp\">download</a> and install Java. Close and re-open your browser to enable it.</strong>
</APPLET>";

    # Change to the small image if we have to
    $applet = $self->out_html_small_img if $options{SIZE} eq "medium";
    my $outval="<TABLE ALIGN=\"CENTER\">
    <TR>
	<TD>$applet</TD>
    </TR>
    </TABLE>";

    return $outval . $self->SUPER::out_html_body;
}

sub out_file_path {
        my $self = shift;
        my $body = $self->body();
        my $uri;
        if (my $body = $self->body) {
            $uri = $body->tag_values ('flashpix_uri');
        }  
        return if (!defined($uri));
        my $uri_value = $uri->value();
        $uri_value =~ s/^\///;
	my $filename = $TUSK::UploadContent::path{"flashpix"} . $uri_value;
	return $filename;
}

sub out_icon {
    my $self = shift;
    return "<img src=\"/icons/ico-fpx.gif\" width=\"22\" height=\"24\" border=\"0\">";
}


package HSDB4::SQLRow::Content::External;
use strict;
use vars qw (@ISA);
@ISA = ('HSDB4::SQLRow::Content');
use TUSK::Content::External::LinkContentField;
use TUSK::Content::External::MetaData;

sub out_html_body {
	my $self = shift;

	my $label = $self->title();
	my $url = '/view/urlExternalContent/' . $self->primary_key();

	my $content = "<div class=\"docinfo\"><a href=\"$url\">$label</a></div>";
	return $content;
}

sub get_external_source {
    # returns 
    my ($self) = @_;
    my $external_info = $self->get_external_content_data();
    if (scalar(@$external_info)){
	my $info = $external_info->[0]->getField();
	my $source = $info->getSource();
	return $source;
    }else{
	return 0;
    }
}

sub get_external_content_data {
    my ($self) = @_;

    unless (ref($self->{_external_content_data}) eq 'ARRAY') {
	$self->{_external_content_data} =  TUSK::Content::External::LinkContentField->new()->lookup('parent_content_id = ' . $self->primary_key(),
	  [
	   'content_external_field.sort_order',
	   ],
	  undef,
	  undef,
	  [
	   TUSK::Core::JoinObject->new('TUSK::Content::External::Field', 
	       { joinkey => 'field_id', origkey => 'child_field_id', }),
	   TUSK::Core::JoinObject->new('TUSK::Content::External::Source', 
	       { joinkey => 'source_id', origkey => 'content_external_field.source_id',
		 objtree => [ 'TUSK::Content::External::Field' ], } ),
	   ]);
    }

    return $self->{_external_content_data};
}

sub get_meta_data {
    my $self = shift;
    my $metadata = TUSK::Content::External::MetaData->new()->lookup("content_id = " . $self->primary_key());
    if (scalar @$metadata == 1) {
	return $metadata->[0];
    } 
    return undef;
}

sub display_framed {
    #
    # Indicates whether this object should be displayed in a frame.
    #

    my $self = shift;
    return 1;
}

sub out_icon {
    my $self = shift;
    return "<img src=\"/icons/ico-url.gif\" width=\"22\" height=\"24\" border=\"0\">";
}

sub is_mobile_ready{
	return 1;
}


package HSDB4::SQLRow::Content::URL;
use strict;
use vars qw (@ISA);
@ISA = ('HSDB4::SQLRow::Content');

sub out_url {
    #
    # Returns a URL for accessing complete info on the row
    #
    # Return the link to the row's fundamental page
    my $self = shift;
    # Get the base URL from HSDB4::Constants
    my $class = ref $self || $self;
    my $external_url = $self->out_external_url;
    if ($external_url && $external_url =~ /external_link/) {
	return $external_url."\" target=\"_blank";
    }
    my $url = $HSDB4::Constants::URLs{$class};
    # And we're done if this is a class method; but otherwise...
    return $url unless ref $self;
    # ...stick in the path if it's in the aux info...
    my $path = $self->aux_info ('uri_path');
    $url .= "/$path" if $path;
    # ...and tack on the primary key
    return sprintf ("$url/%s", $self->primary_key);
}

sub display_framed {
    #
    # Indicates whether this object should be displayed in a frame.
    #

    my $self = shift;
    return 1;
}

sub out_external_url {
    #
    # Return the value of the xternal URL to be linked to
    #

    my $self = shift;
    # Get the object from the body...
    my $body = $self->body or return;
    my ($url) = $body->tag_values ('external_uri');
    # And return undef unless we got it
    return unless $url;
    # and then return the actual value
    $url = $url->value;
}

sub out_html_body {
	my $self = shift;

	my $body = $self->body or return;
	my ($url) = $body->tag_values ('external_uri');
	return unless $url;
	$url = $url->value;
	my $label = $self->title();

	my $content = "<div class=\"docinfo\"><a href=\"$url\">$label</a></div>";
	return $content;
}

sub out_icon {
    my $self = shift;
    return "<img src=\"/icons/ico-url.gif\" width=\"22\" height=\"24\" border=\"0\">";
}

sub is_mobile_ready{
	return 1;
}

package HSDB4::SQLRow::Content::Multidocument;
use strict;
use vars qw (@ISA);
@ISA = ('HSDB4::SQLRow::Content');

sub out_icon {
    my $self = shift;
    return "<img src=\"/icons/ico-doc.gif\">";
}

sub display_child_content {
    #
    # Indicates whether this object should have the list of sub-documents
    # shown after it.
    #

    my $self = shift;
    return 0;
}

sub out_html_thumbnail {
    # 
    # Return a row version of the document
    #
 
    my $self = shift;

    my $thumbnail = "<IMG SRC=\"/icons/folder.gif\" WIDTH=20 HEIGHT=22 BORDER=0>";
    return sprintf ("<A HREF=\"%s\">%s</A>", $self->out_url, $thumbnail);
}

sub out_html_thumbnail_choose {
    # 
    # Return a row version of the document
    #
 
    my $self = shift;
    return "<IMG SRC=\"/icons/folder.gif\" WIDTH=20 HEIGHT=22 BORDER=0>";
}

sub out_html_body {
    #
    # Return the bodies of a thousand content... etc, 
    #
    
    my $self = shift;
    # First, do text, if there is any
    my $outval = $self->SUPER::out_html_body();

    $outval .= "<FORM METHOD=\"POST\">\n";

    $outval .= "<UL>\n";
    foreach my $doc ($self->child_content) {
	$outval .= '<DIV class="docinfo"><LI><A HREF="#sub-' 
	    . $doc->primary_key . '">' . $doc->out_label . "</A></DIV>\n";
    }
    $outval .= "</UL>\n";

    foreach my $doc ($self->child_content) {
	$outval .= 
	    sprintf ("<H3 CLASS=\"title\"><A NAME=\"sub-%d\">%s</A></H3>\n",
		     $doc->primary_key, $doc->out_label);
	$outval .= $doc->out_html_body (@_, -form => 0);
	$outval .= "<DIV CLASS=\"auxlinks\"><A HREF=\"#_top\">Top</A></DIV>\n";
    }
    
    $outval .= 
	"<DIV><INPUT TYPE=\"submit\" NAME=\"answers\" VALUE=\"Get Answers\">";
    $outval .= "</DIV>\n";
    $outval .= "</FORM>\n";
    return $outval;
}

sub is_mobile_ready{
	return 1;
}


package HSDB4::SQLRow::Content::PDF;
use strict;
use vars qw (@ISA);
use Carp;
@ISA = ('HSDB4::SQLRow::Content');

sub out_icon {
    my $self = shift;
    return "<img src=\"/icons/ico-pdf.gif\" width=\"22\" height=\"24\" border=\"0\">";
}

sub out_html_thumbnail {
    #
    # Return a different thumbnail
    #

    my $self = shift;
    return sprintf("<A HREF=\"%s\">%s</A>", $self->out_url, 
		   $self->out_icon);
}

sub display_framed {
    #
    # Indicates whether this object should be displayed in a frame.
    #

    my $self = shift;
    return 1;
}

sub out_external_url {
    #
    # Return the value of the xternal URL to be linked to
    #

    my $self = shift;
    # Get the object from the body...
    my $body = $self->body;
    my ($url) = $body->tag_values('pdf_uri') if ($body);
    # And return undef unless we got it
    return unless $url;
    # and then return the actual value
    $url = $url->value;
    $url =~ s!^/+!!g;
    return "/auth/pdf/$url";
}

sub out_index_body {
        my $self = shift;
        return $self->SUPER::out_index_body($self->get_file_body());
}

sub out_file_path {
	my $self = shift;
        my $body = $self->body();
        my $uri =  $body->tag_values('pdf_uri') if ($body);
        return if (!defined($uri));
        my $uri_value = $uri->value();
        $uri_value = '/'.$uri_value if ($uri_value !~ /^\//);
        my $filename = $TUSK::UploadContent::path{"pdf"} . $uri_value;
	return $filename;
}

sub get_file_body {
        my $self = shift;
	my $filename = $self->out_file_path();
	my $pk = $self->primary_key();
        if (! -f $filename ){
                warn "get_file_body (ID : $pk) : There is no file called $filename";
		return;
        }
        open PDFEXTRACT,$TUSK::Constants::PDFTextExtract." $filename - |" 
                or confess "Can't open ".$TUSK::Constants::PDFTextExtract." : $!";
        my @body_text = <PDFEXTRACT>;
	close PDFEXTRACT;

        return join(" ",@body_text);
}

sub is_mobile_ready{
	return 1;
}


package HSDB4::SQLRow::Content::Shockwave;
use strict;
use vars qw (@ISA);
@ISA = ('HSDB4::SQLRow::Content');

sub out_html_body {
    #
    # Return the movie with all the usual good stuff
    #

    my $self = shift;
    my $body = $self->body();
    my ($uri) = $body->tag_values ('shockwave_uri') if ($body);
    # And return undef unless we got it
    return $self->SUPER::out_html_body unless ($uri);

    my ($width, $height, $autoplay, $type, $classid, $display_type);
    if ($uri->get_attribute_values('width')){
	$width = $uri->get_attribute_values('width')->value;
    }else{
	$width = 400;
    }
    if ($uri->get_attribute_values('height')){
	$height = $uri->get_attribute_values('height')->value;
    }else{
	$height = 400;
    }
    if ($uri->get_attribute_values('autoplay')){
	$autoplay = $uri->get_attribute_values('autoplay')->value;
    }else{
	$autoplay = 'true';
    }
	if ( $uri->get_attribute_values('display-type') ) {
		$display_type = $uri->get_attribute_values('display-type')->value();
	} else {
		$display_type = "Stream";
	}

    # and then return the actual URL
    $uri = $uri->value;

	if ( $uri =~ /dcr$/ ) {
		$type = 'application/x-director';
		$classid = 'clsid:166B1BCA-3F9C-11CF-8075-444553540000';
	} else {
		$type = 'application/x-shockwave-flash';
		$classid = 'clsid:D27CDB6E-AE6D-11cf-96B8-444553540000';
	}

	my $output;

	if ( $uri =~ /flv$/ ) {
		my $height_w_skin = $height + 25;
		$uri =~ s/able_file//g;
    	$output = $self->_make_object_ref (
        	$uri,
        	$uri,
        	$width,
        	$height_w_skin,
        	{
				data    => "/media/player_flv_maxi.swf",
            	type    => $type,
            	id      => 'flvPlayer',
        	},
        	{
            	movie      => '/media/player_flv_maxi.swf',
				FlashVars  => "flv=$uri&amp;width=$width&amp;height=$height_w_skin&amp;showiconplay=1&amp;showstop=1&amp;showvolume=1&amp;showtime=1&amp;showfullscreen=1&amp;showplayer=always&amp;playercolor=$TUSK::Constants::flvplayer_skin_color",
            	swfversion => '9,0,0,0',
				allowFullScreen => 'true',
        	},
        	{},
    	) if ( $display_type ne "Downloadable" ); 
		$output .= $self->SUPER::out_html_body . $self->_player_footer($display_type, 'flash', $uri);
	} else {
    	$output = $self->_make_object_ref (
        	$uri,
        	$uri,
        	$width,
        	$height,
        	{
            	classid => $classid,
            	type => $type,
            	codebase => 'http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,40,0',
            	id => 'myMovie',
        	},
        	{
            	autoplay => $autoplay,
            	quality => 'high',
        	},
        	{
            	name => 'myMovie',
            	movie => $uri,
            	type => $type,
            	class => 'image',
            	wmode => 'transparent',
            	autoplay => $autoplay,
            	pluginspage => 'http://www.macromedia.com/go/getflashplayer',
        	},
    	) if ( $display_type ne "Downloadable" ); 
		$output .= $self->SUPER::out_html_body . $self->_player_footer($display_type, 'flash', $uri);
	}

	return $output;
}

sub make_object_tag{
	my ($self, $uri, $width, $height, $display_type) = @_;
	my ($type, $classid);
	$display_type = 'Stream' if !$display_type;

	if ( $uri =~ /dcr$/ ) {
		$type = 'application/x-director';
		$classid = 'clsid:166B1BCA-3F9C-11CF-8075-444553540000';
	} else {
		$type = 'application/x-shockwave-flash';
		$classid = 'clsid:D27CDB6E-AE6D-11cf-96B8-444553540000';
	}

	my $output;

	if ( $uri =~ /flv$/ ) {
		my $height_w_skin = $height + 25;
		$uri =~ s/able_file//g;
    	$output = $self->_make_object_ref (
        	$uri,
        	$uri,
        	$width,
        	$height_w_skin,
        	{
				data    => "/media/player_flv_maxi.swf",
            	type    => $type,
            	id      => 'flvPlayer',
        	},
        	{
            	movie      => '/media/player_flv_maxi.swf',
				FlashVars  => "flv=$uri&amp;width=$width&amp;height=$height_w_skin&amp;showiconplay=1&amp;showstop=1&amp;showvolume=1&amp;showtime=1&amp;showfullscreen=1&amp;showplayer=always&amp;playercolor=$TUSK::Constants::flvplayer_skin_color",
            	swfversion => '9,0,0,0',
				allowFullScreen => 'true',
        	},
        	{},
    	) if ( $display_type ne "Downloadable" ); 
		$output .= $self->SUPER::out_html_body . $self->_player_footer($display_type, 'flash', $uri);
	} else {
		$output = $self->_make_object_ref (
			$uri, $uri, $width, $height,
			{
				classid => $classid,
				type => $type,
            	codebase => 'http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,40,0',
 				id => 'myMovie',
			},
			{},
			{
				name => 'myMovie',
				movie => $uri,
				type  => $type,
				class => 'image',
				wmode => 'transparent',
            	pluginspage => 'http://www.macromedia.com/go/getflashplayer',
			}
    	) if ( $display_type ne "Downloadable" ); 
		$output .= $self->SUPER::out_html_body . $self->_player_footer($display_type, 'flash', $uri);
	}

	return $output;
}

sub out_icon {
    my $self = shift;
    return "<img src=\"/icons/ico-swf.gif\" width=\"22\" height=\"24\" border=\"0\">";
}

sub out_file_path {
    my $self = shift;
    my $body = $self->body();
    my $uri =  $body->tag_values('shockwave_uri') if ($body);
    return if (!defined($uri));
    my $uri_value = $uri->value();

    my $filename = $TUSK::Constants::BaseStaticPath . "/$uri_value";
    return $filename;
}

package HSDB4::SQLRow::Content::DownloadableFile;
use strict;
use Carp;
use vars qw (@ISA);
@ISA = ('HSDB4::SQLRow::Content');

sub display_framed {
    #
    # Indicates whether this object should be displayed in a frame.
    #

    my $self = shift;
    return 1;
}

sub out_external_url {
    #
    # Return the value of the xternal URL to be linked to
    #

    my $self = shift;
    # Get the object from the body...
    my ($body) = $self->body();
    my $url =	$body->tag_values ('file_uri') if ($body);
    # And return undef unless we got it
    return unless $url;
    # and then return the actual value
    $url = $url->value;
    $url =~ s!^/+!!g;
    return "/downloadable_file/$url";
}

sub out_index_body {
	my $self = shift;
	return $self->SUPER::out_index_body($self->get_file_body());
}

sub out_file_path {
        my $self = shift;
        my $body = $self->body();
        my $uri =  $body->tag_values('file_uri') if ($body);
        return if (!defined($uri));
        my $uri_value = $uri->value();
        $uri_value = '/'.$uri_value if ($uri_value !~ /^\//);
        my $filename = $TUSK::UploadContent::path{"downloadablefile"} . $uri_value;
	return $filename;

}

sub out_file_size {
    my $self = shift;
    my $filename = $self->out_file_path();

    unless (-f $filename){
	warn "out_file_size (ID: " . $self->primary_key() . ") : There is no file called $filename";
	return;
    } 

    my $filesize = (stat($filename))[7];

    return ($filesize > 999999) ? sprintf("%.1fMB", $filesize / 1000000) : sprintf("%.1fKB", $filesize / 1000);
}

sub get_file_body {
	my $self = shift;
	my $filename = $self->out_file_path();
	my $pk = $self->primary_key();
	unless($filename =~ /\.docx?$/ || $filename =~ /\.pptx$/) {
		return $self->out_html_body();
	}
	if (! -f $filename ){
		warn "get_file_body (ID : $pk ) : There is no file called $filename";
		return;
	} 
	my $msConverter = TUSK::Content::MSTextExtractor->new();
	return $msConverter->getDocumentText($filename);
}

sub out_icon {
    my $self = shift;
    return "<img src=\"/icons/ico-download.gif\" width=\"20\" height=\"22\" border=\"0\">";
}

sub out_html_thumbnail_img {
    #
    # Return what should go in the thumbnail part of an row
    #
    my $self = shift;
    return $self->out_icon;
}

sub out_html_thumbnail {
    #
    # Return a different thumbnail
    #

    my $self = shift;
    return sprintf("<A HREF=\"%s\">%s</A>", $self->out_url, 
		   $self->out_html_thumbnail_img);
}

sub is_mobile_ready{
	return 1;
}

package HSDB4::SQLRow::Content::Video;
use strict;
use vars qw (@ISA);
@ISA = ('HSDB4::SQLRow::Content');

sub out_html_body {
    #
    # Return the movie with all the usual good stuff
    #

    my $self = shift;
    my $body = $self->body();
    my $uri = $body->tag_values ('realvideo_uri') if ($body);

    # And return unless we got a uri
    return $self->SUPER::out_html_body unless ($uri);

	my ($width, $height, $autoplay, $display_type);
	if ($uri->get_attribute_values('width')){
		$width = $uri->get_attribute_values('width')->value;
	}
	else{
		$width = 320;
	}
	
	if ($uri->get_attribute_values('height')){
		$height = $uri->get_attribute_values('height')->value;
	}
	else{
		$height = 240;
	}
	
	if ($uri->get_attribute_values('autoplay')){
		$autoplay = $uri->get_attribute_values('autoplay')->value;
	}
	else{
		$autoplay = 'true';
	}

    if ($uri->get_attribute_values('display-type')){
	$display_type = $uri->get_attribute_values('display-type')->value;
    }else{
	$display_type = 'Stream';
    }

    # and then return the actual URL
    $uri = $uri->value;
    
    $uri = "/" . $uri unless ($uri=~/^\//);

    my $display;

    # For the time being, use Real Player for MP3 audio.
    if ($uri =~ /\.(r[mva]|rmvb|mp3)$/i ) {
        $display .= $self->_embed_real_player(
            $height, $width, $autoplay, $uri, $display_type
        );
    } elsif ($uri =~ /\.(mov|mp((e)?g|4))$/i ) {
        $display .= $self->_embed_qt_player(
            $height, $width, $autoplay, $uri, $display_type
        );
    } elsif ($uri =~ /\.(wm[av]|avi|mod)$/i ) {
        # The current Windows Media does not exist for Mac,
        # So let's attempt to use QuickTime for a replacement.
        if ($ENV{HTTP_USER_AGENT} =~/mac/i){
            $display .= $self->_embed_qt_player(
                $height, $width, $autoplay, $uri, $display_type
            );
        } else {
            $display .= $self->_embed_wm_player(
                $height, $width, $autoplay, $uri, $display_type
            );
        }
    }

    $display .= $self->_player_footer($display_type, 'video', $uri);

    return "<center>\n" . $display . $self->SUPER::out_html_body . "</center>\n";
}

sub out_uri{
	my $self = shift;
	my $body = $self->body();
	my $uri =  $body->tag_values('realvideo_uri') if ($body);

	return undef if (!defined($uri));
	my $uri_value = $uri->value();
	$uri_value = '/'.$uri_value if ($uri_value !~ /^\//);

	return $uri_value;
}

sub out_file_path {
	my $self = shift;
	my $uri = $self->out_uri();
	return if (!defined($uri));
	my $filename = $TUSK::UploadContent::path{"video"} . $uri;
	return $filename;
}

sub out_icon {
    my $self = shift;
    return "<img src=\"/icons/ico-movie.gif\" width=\"22\" height=\"24\" border=\"0\">";
}

sub out_streaming_url{
	my $self = shift;

	return '/streaming' . $self->out_uri;
}

sub is_mobile_ready{
	return 1;
}


package HSDB4::SQLRow::Content::Audio;
use strict;
use vars qw (@ISA);
@ISA = ('HSDB4::SQLRow::Content');

sub out_html_body {
 
    #
    # Return the movie with all the usual good stuff
    #

    my $self = shift;
    my $body = $self->body;
    my ($uri) = $body->tag_values ('realaudio_uri') if ($body);

    # Hack because content may have been stored as video....
    $uri = $body->tag_values ('realvideo_uri') unless ($uri);

    # And return unless we got a uri
    return $self->SUPER::out_html_body unless ($uri);
    
    my ($autoplay, $display_type);

    if ($uri->get_attribute_values('autoplay')){
	$autoplay = $uri->get_attribute_values('autoplay')->value;
    }else{
	$autoplay = 'true';
    }
    
    if ($uri->get_attribute_values('display-type')){
	$display_type = $uri->get_attribute_values('display-type')->value;
    }else{
	$display_type = 'Stream';
    }

    # and then return the actual URL
    $uri = $uri->value;

    $uri = "/" . $uri unless ($uri=~/^\//);

    my $display;

    # For the time being, use Real Player for MP3 audio.
    if ($uri =~ /\.(r[mva]|rmvb|mp3)$/i ) {
        $display .= $self->_embed_real_player(
            100, 320, $autoplay, $uri, $display_type
        );
    } elsif ($uri =~ /\.(mov|mp((e)?g|4))$/i ) {
        $display .= $self->_embed_qt_player(
            100, 320, $autoplay, $uri, $display_type
        );
    } elsif ($uri =~ /\.(wm[av]|avi|mod)$/i ) {
        # The current Windows Media does not exist for Mac,
        # So let's attempt to use QuickTime for a replacement.
        if ($ENV{HTTP_USER_AGENT} =~/mac/i){
            $display .= $self->_embed_qt_player(
                100, 320, $autoplay, $uri, $display_type
            );
        } else {
            $display .= $self->_embed_wm_player(
                100, 320, $autoplay, $uri, $display_type
            );
        }
    }

    $display .= $self->_player_footer($display_type, 'audio', $uri);

    return "<center>\n" . $display . $self->SUPER::out_html_body . "</center>\n";
}

sub out_uri{
	my $self = shift;
	my $body = $self->body();
	my $uri =  $body->tag_values('realaudio_uri') if ($body);

	# Hack because content may have been stored as video....
	$uri = $body->tag_values ('realvideo_uri') unless ($uri);

	return undef if (!defined($uri));
	my $uri_value = $uri->value();
	$uri_value = '/'.$uri_value if ($uri_value !~ /^\//);

	return $uri_value;
}

sub out_file_path {
	my $self = shift;
	my $uri = $self->out_uri();
	return if (!defined($uri));
	my $filename = $TUSK::UploadContent::path{"audio"} . $uri;
	return $filename;
}

sub out_icon {
    my $self = shift;
    return "<img src=\"/icons/ico-audio.gif\" width=\"22\" height=\"24\" border=\"0\">";
}

sub out_streaming_url{
	my $self = shift;

	return '/streaming' . $self->out_uri;
}

sub is_mobile_ready{
	return 1;
}


package HSDB4::SQLRow::Content::Quiz;
use strict;
use vars qw (@ISA);
@ISA = ('HSDB4::SQLRow::Content');

sub out_icon {
    my $self = shift;
    return "<img src=\"/icons/ico-doc.gif\">";
}

sub display_child_content {
    #
    # Indicates whether this object should have the list of sub-documents
    # shown after it.
    #

    my $self = shift;
    return 0;
}

sub out_html_thumbnail {
    # 
    # Return a row version of the document
    #
 
    my $self = shift;

    my $thumbnail = "<IMG SRC=\"/icons/folder.gif\" WIDTH=20 HEIGHT=22 BORDER=0>";
    return sprintf ("<A HREF=\"%s\">%s</A>", $self->out_url, $thumbnail);
}

sub out_html_thumbnail_choose {
    # 
    # Return a row version of the document
    #
 
    my $self = shift;
    return "<IMG SRC=\"/icons/folder.gif\" WIDTH=20 HEIGHT=22 BORDER=0>";
}

sub out_html_body {
    #
    # Return the bodies of a thousand content... etc, 
    #
    
    my $self = shift;
    # First, do text, if there is any
    my $outval = $self->SUPER::out_html_body();

    $outval .= "<FORM METHOD=\"POST\">\n";

    $outval .= "<UL>\n";
    foreach my $doc ($self->child_content) {
	$outval .= '<DIV class="docinfo"><LI><A HREF="#sub-' 
	    . $doc->primary_key . '">' . $doc->out_label . "</A></DIV>\n";
    }
    $outval .= "</UL>\n";

    my %args = @_;
    delete $args{answers};

    foreach my $doc ($self->child_content) {
	$outval .= 
	    sprintf ("<H3 CLASS=\"title\"><A NAME=\"sub-%d\">%s</A></H3>\n",
		     $doc->primary_key, $doc->out_label);
	$outval .= $doc->out_html_body (%args, -form => 0);
	$outval .= "<DIV CLASS=\"auxlinks\"><A HREF=\"#_top\">Top</A></DIV>\n";
    }
    
    $outval .= 
	"<DIV><INPUT TYPE=\"submit\" NAME=\"answers\" VALUE=\"Submit Answers\">";
    $outval .= "</DIV>\n";
    $outval .= "</FORM>\n";
    return $outval;
}

1;

__END__

=head1 NAME

B<HSDB4::SQLRow::Content> - Representation of a HSDB content unit

=head1 SYNOPSIS

    use HSDB4::SQLRow::Content;
    
    my $content = HSDB4::SQLRow::Content->lookup_key ('ffyear');
    print $content->out_xml;

=head1 DESCRIPTION

Represents a HSDB4 content unit.  Look the content up in the database,
and provide an interface to all sorts of manipulations for it: who
wrote it, what it's for, what it's related to, etc.  Note that while
the B<HSDB4::SQLRow::Content> interface is maintained, there are
actually a number of subclasses for other data types: notably
B<Collection>, B<Slide>, B<Multidocument>, B<Question>, B<Flashpix>,
B<URL>, B<PDF>, and B<Shockwave> objects.  The B<lookup_key()> and
B<lookup_conditions()> methods are both overridden in B<Content> to
automatically re-bless objects into their proper subclass depending on
the value of their C<type> field. The general B<Content> interface is
described at first, and then overridden methods are describe at the
end.

=head1 METHODS

=head2 Database Methods

B<save_version()> saves changes to the database while at the same time
making and saving a copy B<Content_history> object. It takes a version note
as its first parameter, and the database username and password as its
second and third parameters (for the super-class's B<save()> method,
which it calls).

B<lookup_path()> retrieves the object from the database associated
with a slash separated list of B<Content> IDs in a hierarchy and
establishes context. E.g., "/3231/4323" would retrieve document with
ID 4323 and give it a context such that its parent was the document
with ID 3231.

B<is_user_authorized()> takes a C<user_id> as an argument, and returns
a true value if the named C<User> is allowed to access this
document. It the value of the C<read_access> field to make the
decision.

B<is_user_author()> finds out whether a named user is among the
authors of this B<Content> object.

B<make_annotation()> takes a C<user_id> and a string of text as an
argument, and createds a B<Personal_Content> object as that user's
annotation to this document.

=head2 Linked Objects

B<context_parent()> returns a B<Content> object which is this
B<Content> object's parent in the current context.

B<context_next()> returns a B<Content> object which is the next
B<Content> object in the current context.

B<context_prev()> returns a B<Content> object which is the previous
B<Content> object in the current context.

B<other_parents()> returns the other B<Content> objects which are this
objects parents which are I<not> its parent in the current context.

B<parent_courses()> returns the B<Course> objects which directly link
to this content object.

B<course()> returns the B<Course> object which this object was created
as part of.

B<parent_class_meetings()> returns the B<ClassMeeting> objects which
directly link to this object.

B<parent_objectives()> returns the B<Objective> objects which dirctly
link to this object.

B<parent_personal_content()> returns the B<PersonalContent> objects
which directly link to this content for the B<User> object given as
the argument.

B<parent_content()> returns the other B<Content> objects which
directly link to this B<Content> object.

B<child_content()> returns the B<Content> objects to which this object
directly links.

B<child_users()> returns the B<User> objects associated with this
document (i.e., its authors).

B<child_personal_content()> returns the B<PersonalContent> objects
associated with this document for the B<User> object given as an
argument. These are the B<User>'s annotations of this object.

B<keywords()> returns the B<Keyword> objects associated with this
object.

B<content_history()> gets the B<Content_history> objects with which
this object is associated.

B<data()> gets the B<Binary_data> object which is the primary data
object for this B<Content> object.

B<small_data()> gets the B<Binary_data> object which is the secondary
data object for this B<Content> object.

B<thumbnail()> gets the B<Binary_data> object which is the thumbnail
binary data object for this B<Content> object.

=head2 Body Manipulation Methods

B<small_data_available()> retuns a true value if this object has a
small B<Binary_data> object associated with it.

B<small_data_preferred()> returns a true value if this object prefers
to have the small form of its data displayed.

B<body()> returns an B<HSDB4::XML> object which represents the body of
this B<Content> object.

=head2 Input Methods

B<in_xml()> is not yet implemenented.

B<in_fdat_hash()> is not yet implemented.

=head2 Output Methods

B<modified()> returns an B<HSDB4::DateTime> object representing the
time this document was last modified.

B<created()> returns an B<HSDB4::DateTime> object representing the
time this document was created.

B<display_framed()> returns a true value if this object type should be
displayed in a framed way.

B<display_child_content()> returns a true value if child B<Content>
objects of the B<Content> object should be displayed as part of this
document.

B<out_meta_data()> returns a set of tags of C<META> data for the top
of an HTML file.  The data fields are C<id>, C<title>, C<author>,
C<authors> (same things), C<keyword>, C<keywords> (same things),
C<type>, C<course>, C<school>, and C<system>.

B<out_html_forindex()> outputs an entire HTML document appropriate for
indexing.

B<out_log_item()> returns a string which can be used to generate a
C<Log_item> for this a user's access of a content object.

B<out_html_thumbnail()> returns a blob of HTML which is a linked
thumbnail representation of the document (a small image, or its type,
or an icon of some kind).

B<out_html_authors()> returns a comma-separated list of HTML-formatted
authors.

B<out_html_table_authors()> returns a HTML table of the documents
authors.

B<out_html_table_child_content()> returns a HTML table of a list of
the B<Content> object's child B<Content> objects.

B<out_html_appendix()> returns the HTML footer appropriate for this
B<Content> object.

B<out_summary()> returns the summary gleaned from the document's XML
body, if it's there.

B<out_section_titles()> gets a list of the section titles for this 

B<out_sections()>

B<out_url()>

B<out_html_small_img()>

B<out_html_img()>

B<out_html_thumbnail_img()>

B<out_html_div()> returns a barebones blob of HTML: just the title (in
C<E<lt>H2E<gt>> tags) and the body formatted as HTML.

B<out_xml()> is not yet implemented.

B<out_html_row()> returns the document type, its C<HREF>'ed title
(spanning two columns) and its modified date.

B<out_label()> returns the content title.

B<out_abbrev()> returns the first twenty characters of the content title.

=head2 HSDB4::SQLRow::Content::Collection

B<out_html_thumbnail()>

=head2 HSDB4::SQLRow::Content::Slide

B<small_data_preferred()>

B<out_html_thumbnail()>

B<out_html_row()>

B<out_html_body()>

=head2 HSDB4::SQLRow::Content::Question

B<answers()>

B<correct_answers()>

B<incorrect_answers()>

B<answer_hash()>

B<out_form_id()>

B<out_choice_row()>

B<correct_answer()>

B<out_response_row()>

B<out_html_body()>

=head2 HSDB4::SQLRow::Content::Flashpix

B<out_html_thumbnail()>

B<out_html_body()>

=head2 HSDB4::SQLRow::Content::URL

B<display_framed()>

B<out_external_url()>

B<out_html_body()>

=head2 HSDB4::SQLRow::Content::Multidocument

B<display_child_content()>

B<out_html_thumbnail()>

B<out_html_body()>

=head2 HSDB4::SQLRow::Content::PDF

B<display_framed()>

B<out_external_url()>

=head2 HSDB4::SQLRow::Content::Shockwave

B<out_html_body()>

=head1 AUTHOR

Tarik Alkasab <talkas01@tufts.edu>

=head1 SEE ALSO

L<HSDB4>, L<HSDB4::SQLRow>.

=cut
