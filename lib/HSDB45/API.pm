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


package HSDB45::API;

use strict;
use DBI;
use Apache::TicketTool ();
use Apache::Util;
use XML::EscapeText qw(:escape);
use HSDB4::XML::HSCML;
use HSDB4::SQLRow::Content;
use HSDB4::SQLRow::ContentDraft;
use HSDB4::SQLRow::StatusHistory;
use TUSK::Constants;
use TUSK::UploadContent;

BEGIN {
    require Exporter;
    require HSDB4::Constants;

    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
    
    @ISA = qw(Exporter);
    @EXPORT = qw( );
    @EXPORT_OK = qw( );
    $VERSION = do { my @r = (q$Revision: 1.38 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
}

use vars @EXPORT_OK;

# Non-exported package globals go here
use vars qw($DBUser $DBPass $LASTMSG);

$DBUser = "api_user";
$DBPass = "M0unta1nDew";
$LASTMSG=""; ## this var is used for setting/getting the last message generated in a database interaction

#
# >>>>> Constructor <<<<<
#

sub new {
    #
    # Does the default creation stuff
    #
    my $class = shift;
    $class = ref $class || $class;
    my $type = shift;
    my $self = {type => $type};
    $self = {output => start_output()};
    return bless $self, $class;
}

sub login {
    my $self = shift;
    my $r = shift;
    my $user = shift;
    my $pass = shift;
    my $ticketTool = Apache::TicketTool->new($r);
    my ($result,$msg,$status,$ticket,$return_ticket);
    if ($user and $pass) {
	($result, $msg) = $ticketTool->authenticate($user, $pass);
	if ($result) {
	    $ticket = $ticketTool->make_string_ticket($user);
	    $self->add_status("00"); # success
	    $self->add_ticket($ticket);
	}
	else {
	    $self->add_status("31"); # login failed
	}
    }
    else {
	$self->add_status("30"); #invalid username and/or password
    }
}

sub document_make {
    my $self = shift;
    my $token = shift;
    my $course_id = shift;
    my $school = shift;
    my $data = shift;
    my $title = shift;
    $title = "not yet titled" unless ($title);
    my ($status,$new_token) = $self->check_token($token);
    return $self->add_status($status) if ($status !~ /00/); # return if not successful validating token
    return $self->add_status("40") if (!$course_id); ## missing course_id
    my $user_id = get_token_user($token);
    ## can this person add documents?
    my $course = HSDB45::Course->new(_school => $school, _id => $course_id);
    return $self->add_status("32") unless ($course->can_user_add(HSDB4::SQLRow::User->new->lookup_key($user_id)));

    ## make the content record
    my $content = HSDB4::SQLRow::Content->new ();
    $content->set_field_values (read_access => 'HSDB Users',
				type => 'Document',
				course_id => $course_id,
				school => $school,
				title => $title,
				write_access => 'All authors',
				checked_out_by => $user_id,
				created => format_sql_date(get_now_sql_date()),
				conversion_status => 2,
				style => 'hscml',
				display => 1,
			       );
    my ($r, $msg) = $content->save_version("Document created",$user_id);
    return $self->add_status("11") unless ($r);
    my $new_content_id = $content->primary_key;
    return $self->add_status("11") if (!$new_content_id);

    ## output the status and the token for this transaction
    $self->add_status($status);
    $self->add_ticket($new_token);
    $self->add_content($new_content_id);
}

sub document_save {
    my $self = shift;
    my $token = shift;
    my $content_id = shift;
    my $data = shift;
    my $modified_note = shift;
    my $doc_status = shift;
    my $doc_status_note = shift;
    $modified_note = "No modified note sent." if (!$modified_note);
    $doc_status = "Draft" if (!$doc_status);
    $doc_status_note = "No status note sent." if (!$doc_status_note);
    my ($status,$new_token) = $self->check_token($token);
    return $self->add_status($status) if ($status !~ /00/); # return if not successful validating token
    return $self->add_status("50") if (!$content_id); ## missing course_id
    return $self->add_status("60") if (!$data); ## missing data
    my $user_id = get_token_user($token);
    my $content = HSDB4::SQLRow::Content->new->lookup_key($content_id);

    ## is there a content with this id?
    return $self->add_status("51") if (!$content->primary_key);

    ## can this person add documents?
    return $self->add_status("57") unless ($content->can_user_edit(HSDB4::SQLRow::User->new->lookup_key($user_id)));

    ## make sure this document by no-one, or by the user
    ## if the document is checked out, make sure it is by the user
    if ($content->field_value("checked_out_by") !~ /^$|NULL/) {
	return $self->add_status("53") if ($content->field_value('checked_out_by') !~ /$user_id/);
    }

    ## make entry into status_history
    my $statusref = HSDB4::SQLRow::StatusHistory->new();
    my ($r,$msg) = $statusref->save_status($TUSK::Constants::DatabaseUsers{ContentManager}->{writeusername},$TUSK::Constants::DatabaseUsers{ContentManager}->{writepassword},$content_id,$doc_status,$doc_status_note);

    # take out replace text from document body
    $data =~ s/\<\?xm\-replace\_text.*?\?\>//g;
    # take out empty paragraphs
    $data =~  s/\<para(\ id=\"\_\d+\"|)\>\ {0,1}(|\n)\ {0,1}\<\/para\>//sg;

    ## create hscml ref to clean up data
    my $hscml = HSDB4::XML::HSCML->new;
    $data = XML::EscapeText::spec_chars_name($data);

    ## if this content is to be saved as a draft do that now and return
    my $draft = HSDB4::SQLRow::ContentDraft->new();
    if ($draft->requires_draft($doc_status)) {
	## make sure this user is linked to the content (for draft documents without users)
	$content->add_child_user($TUSK::Constants::DatabaseUsers{ContentManager}->{writeusername},$TUSK::Constants::DatabaseUsers{ContentManager}->{writepassword},$user_id,"Editor");
	$draft->save_draft($TUSK::Constants::DatabaseUsers{ContentManager}->{writeusername},$TUSK::Constants::DatabaseUsers{ContentManager}->{writepassword},$content->primary_key,$user_id,$data);
	$self->update_check_in_out($content);
	$self->add_status($status);
	return $self->add_ticket($new_token);
    }
    else {
	$draft->lookup_content($content->primary_key);
	($r,$msg) = $draft->delete($TUSK::Constants::DatabaseUsers{ContentManager}->{writeusername},$TUSK::Constants::DatabaseUsers{ContentManager}->{writepassword});
    }

    # set new twig
    $hscml->create_twig($data);

    if (my $error = $hscml->error()) {
	if ($error =~ /invalid\ token/) {
	    $error =~ s/.+line\ (\d+),\ (column \d+),.+/Invalid\ character\ near\ line\ $1, $2./;
	    return $self->add_status("99: $error");
	}
	else {
	    return $self->add_status("99: $error");
	}
    }
    $hscml->parse_header($self);

    ## remove and make the objective links
    return $self->add_status("112") unless ($self->process_objectives($content,$hscml));
    $hscml->remove_header_objectives($self);

    ## remove and make the objective links
    return $self->add_status("113") unless ($self->process_body_objectives($content,$hscml));

    my $nothing;
    ## make the content record
    $content->set_field_values (type => 'Document',
				title => $self->{title},
				course_id => $self->{course_id},
				school => $self->{school},
				copyright => $self->{copyright},
				write_access => 'All authors',
				checked_out_by => $nothing,
				hscml_body => $self->{data},
				conversion_status => 2,
				style => 'hscml',
			       );
    ($r, $msg) = $content->save_version($modified_note,$user_id);
    return $self->add_status("101") unless ($r);

    ## remake the link_content_user entries
    return $self->add_status("102") unless ($self->delete_content_user($content_id));
    return $self->add_status("103") unless ($self->delete_content_non_user($content_id));
    return $self->add_status("104") unless ($self->process_content_user($content_id));

    ## remove and then remake entry into link_content_content (for collections)
    return $self->add_status("106") unless ($self->delete_content_content($content_id));
    return $self->add_status("108") unless ($self->process_content_content($user_id,$content_id));

    ## make the keyword entries
    return $self->add_status("110") unless ($self->process_keywords($content_id,$user_id));

    ## output the status and the token for this transaction
    $self->add_status($status);
    $self->add_ticket($new_token);
}

sub document_load {
    my $self = shift;
    my $token = shift;
    my $content_id = shift;
    my ($status,$new_token) = $self->check_token($token);
    return $self->add_status($status) if ($status !~ /00/); # return if not successful validating token
    return $self->add_status("50") if (!$content_id); ## missing content_id
    my $user_id = get_token_user($token);
    ## can this person load this document (linked to course or content)?
    my $content = HSDB4::SQLRow::Content->new->lookup_key($content_id);
    return $self->add_status("51") unless ($content->primary_key);
    return $self->add_status("52") unless ($content->can_user_edit(HSDB4::SQLRow::User->new->lookup_key($user_id)));

    ## get status_history info
    $self->select_status_history($content_id);

    ## if there is a draft, return that instead of using content
    my $draft = HSDB4::SQLRow::ContentDraft->new();
    $draft->lookup_content($content->primary_key);
    if ($draft->primary_key) {
	## if possible, check the document out
	$status = $self->update_document_checkout($content_id,$user_id);
	return $self->add_status($status) if ($status !~ /00/);
	$self->add_status($status);
	$self->add_ticket($new_token);
	my $body = $draft->field_value('body');
	$body =~ s/\<\?xml version\=\"1.0\".*\?\>/\<\?xml version\=\"1.0\" encoding\=\"ISO\-8859\-1\"\ standalone=\"no\"\?\>/s;
	my $hscml = HSDB4::XML::HSCML->new($body);
	$hscml->refresh_status($self);
	return $self->add_document($content_id,$content->field_value('title'),$self->{data});
    }

    return $self->add_status("61") unless ($content->field_value('hscml_body'));

    ## now, if possible, check the document out
    $status = $self->update_document_checkout($content_id,$user_id);
    return $self->add_status($status) if ($status !~ /00/);

    ## get link_content_user info
    my @users = $content->child_users("roles DESC");
    push(@users,$content->child_non_users("roles DESC"));
    my @contact_people = grep { $_->aux_info('roles') =~ /Contact-Person/  } @users;
    ## if there isn't a contact person, make it the course director or the requesting author
    if (!@contact_people) {
	my @courseusers = grep { $_->aux_info('roles') =~ /Director/  } $content->course->child_users;
	my $person;
	if (@courseusers) {
	    $person = $courseusers[0];
	    $person->set_aux_info('roles' => 'Contact-Person');
	}
	else {
	    $person = HSDB4::SQLRow::User->new->lookup_key($user_id);
	    $person->set_aux_info('roles' => 'Contact-Person');
	}
	push(@users,$person);
    }
    $self->package_content_user(@users);

    ## get last content_history
    $self->select_content_history($content_id);

    ## get link_content_content info
    $self->select_content_content($content_id);

    ## set misc fields
    $self->{content_id} = $content->primary_key;
    $self->{title} = $content->field_value('title');
    if ($content->field_value('created')) {
	$self->{created} = $content->field_value('created');
    }
    else {
	$self->{created} = "NULL";
    }
    $self->{course_id} = $content->field_value('course_id');
    $self->{copyright} = $content->field_value('copyright');
    $self->{title} = $content->field_value('title');
    $self->{data} = $content->field_value('hscml_body');
    $self->{school} = $content->field_value('school');
    $self->{course_title} = $content->course->field_value('title');

    my $hscml = HSDB4::XML::HSCML->new();
    my $error = $hscml->create_twig($self->{data});
    # set new twig, after chars removed
    if ($error) {
	$self->update_document_release($content_id,$user_id); ## perform update
	if ($error =~ /invalid\ token/) {
	    $error =~ s/.+line\ (\d+),\ (column \d+),.+/Invalid\ character\ near\ line\ $1, $2./;
	    return $self->add_status("99: $error");
	}
	else {
	    return $self->add_status("99: $error");
	}
    }

    $status = $hscml->build_header($self);
    ## if status from processing is bad check the document back in
    if ($status !~ /00/) {
	$self->update_document_release($content_id,$user_id); ## perform update
	return $self->add_status($status);
    }

    $self->add_status($status);
    $self->add_ticket($new_token);
    $self->add_document($content_id,$self->{title},$self->{data});
}

sub content {
    my $self = shift;
    my $content = HSDB4::SQLRow::Content->new->lookup_key($self->{content_id});
    return $content;
}

sub header_objectives {
    my $self = shift;
    return $self->content->child_objectives;
}

sub document_view {
    my $self = shift;
    my $token = shift;
    my $content_id = shift;
    my ($status,$new_token) = $self->check_token($token);
    return $self->add_status($status) if ($status !~ /00/); # return if not successful validating token
    return $self->add_status("50") if (!$content_id); ## missing content_id
    my $user_id = get_token_user($token);
    ## can this person load this document (linked to course or content)?
    my $content = HSDB4::SQLRow::Content->new->lookup_key($content_id);
    return $self->add_status("51") unless ($content->primary_key);
    return $self->add_status("52") unless ($content->can_user_edit(HSDB4::SQLRow::User->new->lookup_key($user_id)));

    ## if there is a draft, return that instead of using content
    my $draft = HSDB4::SQLRow::ContentDraft->new();
    $draft->lookup_content($content->primary_key);
    if ($draft->primary_key) {
	## if possible, check the document out
	$self->add_status($status);
	$self->add_ticket($new_token);
	my $body = $draft->field_value('body');
	$body =~ s/\<\?xml version\=\"1.0\".*\?\>/\<\?xml version\=\"1.0\" encoding\=\"ISO\-8859\-1\"\ standalone=\"no\"\?\>/s;
	return $self->add_document($content_id,$content->field_value('title'),$body);
    }
    return $self->add_status("61") unless ($content->field_value('hscml_body'));

    ## get link_content_user info
    my @users = $content->child_users("roles DESC");
    push(@users,$content->child_non_users("roles DESC"));
    my @contact_people = grep { $_->aux_info('roles') =~ /Contact-Person/  } @users;
    ## if there isn't a contact person, make it the course director or the requesting author
    if (!@contact_people) {
	my @courseusers = grep { $_->aux_info('roles') =~ /Director/  } $content->course->child_users;
	my $person;
	if (@courseusers) {
	    $person = $courseusers[0];
	    $person->set_aux_info('roles' => 'Contact-Person');
	}
	else {
	    $person = HSDB4::SQLRow::User->new->lookup_key($user_id);
	    $person->set_aux_info('roles' => 'Contact-Person');
	}
	push(@users,$person);
    }
    $self->package_content_user(@users);

    ## get status_history info
    $self->select_status_history($content_id);

    ## get link_content_content info
    $self->select_content_content($content_id);

    ## get last content_history
    $self->select_content_history($content_id);

    ## set misc fields
    $self->{content_id} = $content->primary_key;
    $self->{title} = $content->field_value('title');
    if ($content->field_value('created')) {
	$self->{created} = $content->field_value('created');
    }
    else {
	$self->{created} = "NULL";
    }
    $self->{course_id} = $content->field_value('course_id');
    $self->{copyright} = $content->field_value('copyright');
    $self->{title} = $content->field_value('title');
    $self->{data} = $content->field_value('hscml_body');
    $self->{school} = $content->field_value('school');
    $self->{course_title} = $content->course->field_value('title');

    my $data_processor = HSDB4::XML::HSCML->new();
    my $error = $data_processor->create_twig($self->{data});
    # set new twig, after chars removed
    if ($error) {
	$self->update_document_release($content_id,$user_id); ## perform update
	if ($error =~ /invalid\ token/) {
	    $error =~ s/.+line\ (\d+),\ (column \d+),.+/Invalid\ character\ near\ line\ $1, $2./;
	    return $self->add_status("99: $error");
	}
	else {
	    return $self->add_status("99: $error");
	}
    }

    $status = $data_processor->build_header($self);
    ## if status from processing is bad check the document back in
    if ($status !~ /00/) {
	$self->update_document_release($content_id,$user_id); ## perform update
	return $self->add_status($status);
    }

    $self->add_status($status);
    $self->add_ticket($new_token);
    $self->add_document($content_id,$self->{title},$self->{data});
}

sub document_release {
    my $self = shift;
    my $token = shift;
    my $content_id = shift;
    my ($status,$new_token) = $self->check_token($token);
    return $self->add_status($status) if ($status !~ /00/); # return if not successful validating token
    return $self->add_status("50") if (!$content_id); ## missing content_id

    my $user_id = get_token_user($token);

    ## make sure this person has access to this content
    my $content = HSDB4::SQLRow::Content->new->lookup_key($content_id);
    return $self->add_status("52") unless ($content->can_user_edit(HSDB4::SQLRow::User->new->lookup_key($user_id)));
    $status = $self->update_document_release($content_id,$user_id); ## perform update
    return $self->add_status($status) if ($status !~ /00/);
    $self->add_status($status);
    $self->add_ticket($new_token);
}

sub document_choose {
    my $self = shift;
    my $token = shift;
    my $course_id = shift;
    my $school = shift;
    my $content_id = shift;
    my ($status,$new_token) = $self->check_token($token);
    return $self->add_status($status) if ($status !~ /00/); ## return if token isn't validated

    my $user_id = get_token_user($token);
    my @set;
    my $user = HSDB4::SQLRow::User->new->lookup_key($user_id);
    my $content = HSDB4::SQLRow::Content->new;
    if ($course_id) {
	my $course = HSDB45::Course->new(_school => $school, _id => $course_id);
	# get complete set of docs for this course because user is an author in this course
	if ($course->can_user_edit($user)) {
	    @set = $content->lookup_conditions("type = 'Document' and conversion_status = 2","course_id = $course_id","school = '$school'","order by title");
	}
	else {
	    ## get a list of docs that this user can edit in the course
	    @set = $user->all_user_content("type = 'Document' and conversion_status = 2","roles regexp '(Author|Editor|Contact-Person)'","course_id=$course_id");
	}
    }
    else {
	## if there's a content_id (collection)
	if ($content_id) {
	    $content->lookup_key($content_id);
	    ## return all linked docs if a course director for the content
	    @set = grep {$_->field_value('type') =~ /Document/ } $content->child_content;
	    @set = grep { $_->is_user_author($user_id) } @set unless ($content->course->can_user_edit($user));
	}
	else {
	    ## else make a list of specifically authored documents
	    @set = $user->all_user_content("type = 'Document' and conversion_status = 2","roles regexp '(Author|Editor|Contact-Person)'");
	}
    }

    return $self->add_status("56") if (@set < 1);
    $self->add_status($status);
    $self->add_ticket($new_token);
    $self->add_document("records",scalar @set);

    foreach (sort {$a->out_label cmp $b->out_label} @set) {
	$self->add_document($_->field_value('content_id'),$_->field_value('title'));
    }
}

sub course_choose {
    my $self = shift;
    my $token = shift;
    my ($status,$new_token) = $self->check_token($token);
    return $self->add_status($status) if ($status !~ /00/); # return if not successful validating token
    my $user_id = get_token_user($token);

    ## lookup user
    my $user = HSDB4::SQLRow::User->new->lookup_key($user_id);
    my @courses = $user->parent_courses;
    @courses = grep { $_->can_user_add($user) } @courses; 
    my @content = $user->parent_content;
    foreach (@content) {
	if ($_->field_value("school")) {
	    my $course = $_->course;
	    push(@courses,$course) if ($course->primary_key);
	}
    }
    push(@courses,$user->admin_courses);

    $self->add_status($status);
    $self->add_ticket($new_token);
    my ($course_id,$school,$course_list);
    foreach my $course_info (sort {$a->out_label cmp $b->out_label} @courses) {
	$course_id = $course_info->field_value("course_id");
	$school = $course_info->school;
	next if ($course_list =~ /\!$course_id$school\!/);
	$course_list .= "!".$course_id.$school."!";
	$self->add_course($course_id,$course_info->field_value('title'),$school);
    }
    return;
}

sub collection_choose {
    my $self = shift;
    my $token = shift;
    my $course_id = shift;
    my $school = shift;
    my ($status,$new_token) = $self->check_token($token);
    return $self->add_status($status) if ($status !~ /00/); # return if not successful validating token
    return $self->add_status("40") if (!$course_id); ## missing course_id
    my $user = get_token_user($token);

    ## can this person add documents?
    my $course = HSDB45::Course->new(_school => $school, _id => $course_id);
    return $self->add_status("32") unless ($course->can_user_add(HSDB4::SQLRow::User->new->lookup_key($user)));

    # get complete set of collections
    my $content = HSDB4::SQLRow::Content->new();
    my @collections = $content->lookup_conditions("type='Collection'","course_id='".$course->primary_key."'","school='".$course->school."'");
    push(@collections,$course->child_content("type='Collection'"));
    $self->add_status($status);
    $self->add_ticket($token);
    my $entlist; ## will keep track of items already added to XML (in case of duplicates)
    foreach my $entity (sort {$a->out_label cmp $b->out_label} @collections) {
	my $id = $entity->primary_key;
	next if ($entlist =~ /,$id/);
	$self->add_collection($id,$entity->out_label);
	$entlist .= ",".$id;
    }
}

sub collection_make {
    my $self = shift;
    my $token = shift;
    my $course_id = shift;
    my $school = shift;
    my $content_id = shift;
    my $title = shift;
    my $system = shift;
    my $copyright = shift;
    my $sort = shift;
    my $author = shift;
    my $role = shift;
    my ($status,$new_token) = $self->check_token($token);
    return $self->add_status($status) if ($status !~ /00/); # return if not successful validating token
    return $self->add_status("40") if (!$course_id); ## missing course_id
    return $self->add_status("90") if (!$title || !$copyright || !$school); ## missing other critical element
    my $user_id = get_token_user($token);
    $author = $user_id unless ($author);
    $role = "Author" unless ($role);
    ## insert the collection
    my $content = HSDB4::SQLRow::Content->new;
    $content->set_field_values (course_id => $course_id,
				   type => 'Collection',
				   title => $title,
				   school => $school,
				   copyright => $copyright);
    $content->set_field_values (system => $system) if ($system);
    my ($r,$msg) = $content->save_version("Collection created",$user_id);
    return $self->add_status("11") unless ($r);
    my $new_content_id = $r;

    ## now link it
    if ($content_id) {
	my $newcontent = HSDB4::SQLRow::Content->new->lookup_key($content_id);
	return $self->add_status("32") unless $newcontent->can_user_edit(HSDB4::SQLRow::User->new->lookup_key($user_id));
	($r,$msg) = $newcontent->add_child_content($TUSK::Constants::DatabaseUsers{ContentManager}->{writeusername},$TUSK::Constants::DatabaseUsers{ContentManager}->{writepassword},$new_content_id);
    }
    else {
	my $course = HSDB45::Course->new(_school => $school, _id => $course_id);
	return $self->add_status("32") unless ($course->can_user_add(HSDB4::SQLRow::User->new->lookup_key($user_id)));
	($r,$msg) = $course->add_child_content($TUSK::Constants::DatabaseUsers{ContentManager}->{writeusername},$TUSK::Constants::DatabaseUsers{ContentManager}->{writepassword},$new_content_id,$sort);
    }
    
    ## now link the user to this collection
    ($r,$msg) = $self->insert_content_user($new_content_id,$author,$role);

    $self->add_status($status);
    $self->add_ticket($new_token);
    $self->add_content($new_content_id);
}

sub image_make {
    my ($self,$token,$image_file,$course_id,$school,$title,$copyright,$system,$body,$content_id,$sort,$keywords,$author_id,$source,$image_type) = @_;

    my ($status,$new_token) = $self->check_token($token);
    return $self->add_status($status) if ($status !~ /00/); # return if not successful validating token
    return $self->add_status("90") if (!$image_file || !$author_id || !$copyright || !$title); ## missing necessary element
    my $user_id = get_token_user($token);
    if ($course_id) {
	## can this person add documents?
	my $course = HSDB45::Course->new(_school => $school, _id => $course_id);
	return $self->add_status("11") unless ($course->can_user_add(HSDB4::SQLRow::User->new->lookup_key($user_id)));
    }
    ## get an object for the Slide
    my $content = HSDB4::SQLRow::Content->new;
    $content->field_value('type' => 'Slide');
    $content->rebless;
    my ($r,$msg,$new_content_id);
    my $binary = $content->get_image($image_file); # get the data
    $content->generate_image_sizes(-username => $TUSK::Constants::DatabaseUsers{ContentManager}->{writeusername}, -password => $TUSK::Constants::DatabaseUsers{ContentManager}->{writepassword}, -blob => $binary, -type=>"$image_type", -path => $TUSK::UploadContent::path{slide});
    my @time = localtime;
    $content->set_field_values(body => $body,
			       type => "Slide",
			       title => $title,
			       school => $school,
			       course_id => $course_id,
			       copyright => $copyright,
			       system => $system,
			       source => $source,
			       write_access => 'All authors',
			       created => sprintf ("%d-%d-%d %d:%d:%d", $time[5]+1900, $time[4]+1, $time[3], $time[2], $time[1], $time[0]),
			       );
    $content->save_version("Image created",$user_id);
    $new_content_id = $content->primary_key;
    return $self->add_status("11") unless ($new_content_id);

    if ($keywords) {
	my $type = "Author Defined";
	foreach (split(/,/,$keywords)) {
	    my ($r,$msg) = $self->insert_keyword($new_content_id,$_,$type);
	    return $self->add_status("11") unless ($r);
	}
    }

    ($r,$msg) = $self->insert_content_user($new_content_id,$author_id,"Author");
    return $self->add_status("11") unless ($r);

    if ($content_id) {
	    my $newcontent = HSDB4::SQLRow::Content->new->lookup_key($content_id);
	    $newcontent->add_child_content($TUSK::Constants::DatabaseUsers{ContentManager}->{writeusername},$TUSK::Constants::DatabaseUsers{ContentManager}->{writepassword},$new_content_id,$sort);
    }
    $self->add_status($status);
    $self->add_ticket($new_token);
    $self->add_image($new_content_id);
}

sub umls_choose {
    my $self = shift;
    my $token = shift;
    my $keyword = shift;
    my ($status,$new_token) = $self->check_token($token);
    return $self->add_status($status) if ($status !~ /00/); # return if not successful validating token
    return $self->add_status("90") if (!$keyword); ## missing necessary element
    my $concepts = TUSK::Search::UserSearch->findPossibleUMLSConcepts($keyword);
    $self->add_status($status);
    $self->add_ticket($new_token);
    foreach my $item (@{$concepts}) {
	    $self->add_umls($item->getPrimaryKeyID,$item->getKeyword,$item->getDefinition);    
    }
}

sub objective_choose {
    my $self = shift;
    my $token = shift;
    my $searchTerm = shift;
    my ($status,$new_token) = $self->check_token($token);
    return $self->add_status($status) if ($status !~ /00/); # return if not successful validating token
    return $self->add_status("90") if (!$searchTerm); ## missing necessary element
    my $objectives = TUSK::Search::UserSearch->findObjectives($searchTerm);
    $self->add_status($status);
    $self->add_ticket($new_token);
    foreach my $item (@{$objectives}) {
	    $self->add_objective($item->primary_key,$item->field_value('body'));    
    }
}

sub objective_make {
    my $self = shift;
    my $token = shift;
    my $body = shift;
    my ($status,$new_token) = $self->check_token($token);
    return $self->add_status($status) if ($status !~ /00/); # return if not successful validating token
    return $self->add_status("90") if (!$body); ## missing necessary element
    my $user_id = get_token_user($token);
    my $objective = HSDB4::SQLRow::Objective->new;
    $objective->set_field_values(body => $body);
    my ($r,$msg) = $objective->save($TUSK::Constants::DatabaseUsers{ContentManager}->{writeusername},$TUSK::Constants::DatabaseUsers{ContentManager}->{writepassword});
    return $self->add_status("11") if ($r < 1);
    $self->add_status($status);
    $self->add_ticket($new_token);
    return $self->add_objective($objective->primary_key,$objective->field_value('body'));    
}

sub non_user_choose {
    my $self = shift;
    my $token = shift;
    my $name = shift;
    my ($status,$new_token) = $self->check_token($token);
    return $self->add_status($status) if ($status !~ /00/); # return if not successful validating token
    return $self->add_status("90") if (!$name); ## missing necessary element
    my @users = TUSK::Search::UserSearch->findUsers($name);
    my @non_users = TUSK::Search::UserSearch->findNonUsers($name);
    $self->add_status($status);
    $self->add_ticket($new_token);
    foreach my $item (@users) {
	$self->add_user($item->primary_key,
			    $item->field_value('affiliation'),
			    $item->field_value('lastname'),
			    $item->field_value('firstname'),
			    $item->field_value('midname'),
			    $item->field_value('suffix'),
			    $item->field_value('degree'),
			    $item->field_value('email'));
    }
    foreach my $item (@non_users) {
	$self->add_non_user($item->primary_key,
			    $item->field_value('institution'),
			    $item->field_value('lastname'),
			    $item->field_value('firstname'),
			    $item->field_value('midname'),
			    $item->field_value('suffix'),
			    $item->field_value('degree'),
			    $item->field_value('email'));
    }
}

sub non_user_make {
    my $self = shift;
    my $token = shift;
    my $institution = shift;
    my $lastname = shift;
    my $firstname = shift;
    my $midname = shift;
    my $suffix = shift;
    my $degree = shift;
    my $email = shift;
    my ($status,$new_token) = $self->check_token($token);
    return $self->add_status($status) if ($status !~ /00/); # return if not successful validating token
    return $self->add_status("90") if (!$institution && !$lastname); ## missing necessary element
    my $userref = HSDB4::SQLRow::User->new;
    my @conditions;
    push(@conditions,"lastname = '$lastname'") if ($lastname);
    push(@conditions,"firstname = '$firstname'") if ($firstname);
    push(@conditions,"affiliation = '$institution'") if ($institution);

    ## see if the user is in the user table
    my @set = $userref->lookup_conditions(@conditions);
    if (@set) {
	$self->add_status("62");
	foreach my $item (@set) {
	    $self->add_user($item->primary_key,
			    $item->field_value('affiliation'),
			    $item->field_value('lastname'),
			    $item->field_value('firstname'),
			    $item->field_value('midname'),
			    $item->field_value('suffix'),
			    $item->field_value('degree'),
			    $item->field_value('email'));
	}
	return;
    }

    my $user_id = get_token_user($token);
    my $nonuserref = HSDB4::SQLRow::NonUser->new;
    ## see if the user is in the non_user table
    my @non_conditions;
    push(@non_conditions,"lastname = '$lastname'") if ($lastname);
    push(@non_conditions,"firstname = '$firstname'") if ($firstname);
    push(@non_conditions,"institution = '$institution'") if ($institution);

    my @nonset = $nonuserref->lookup_conditions(@non_conditions);
    if (@nonset) {
	$self->add_status("62");
	foreach my $item (@nonset) {
	    $self->add_non_user($item->primary_key,
			    $item->field_value('institution'),
			    $item->field_value('lastname'),
			    $item->field_value('firstname'),
			    $item->field_value('midname'),
			    $item->field_value('suffix'),
			    $item->field_value('degree'),
			    $item->field_value('email'));
	}
	return;
    }

    ## if the user wasn't in either table then add it
    $nonuserref->set_field_values(institution => $institution,
				  lastname => $lastname,
				  firstname => $firstname,
				  midname => $midname,
				  suffix => $suffix,
				  degree => $degree,
				  email => $email);
    my ($r,$msg) = $nonuserref->save($TUSK::Constants::DatabaseUsers{ContentManager}->{writeusername},$TUSK::Constants::DatabaseUsers{ContentManager}->{writepassword});
    return $self->add_status("11") if ($r < 1);
    $self->add_status($status);
    $self->add_ticket($new_token);
    $self->add_non_user($r,$institution,$lastname,$firstname,$midname,$suffix,$degree,$email);
}

## validation methods ##
sub check_token {
    my $self = shift;
    my $token = shift;
    return ("01") if (!$token);
    my $ticketTool = Apache::TicketTool->new();
    my ($result,$status) = $ticketTool->verify_string_ticket($token);
    return $status if (!$result);
    my $user = get_token_user($token);
    my $new_token = $ticketTool->make_string_ticket($user);
    return ($status,$new_token);
}

sub get_school_admin_group {
    my $school = shift;
    return $HSDB4::Constants::School_Admin_Group{$school};
}

## database interactions ##
sub package_content_user {
    my $self = shift;
    my @users = @_;
    $self->{entities} = \@users;
}

sub select_content_content {
    my $self = shift;
    my $content_id = shift;
    my ($linkref,$set,$item,%hash,$ii);
    $linkref = HSDB4::SQLRow::Content->new;
    $linkref->lookup_key($content_id);
    my @set = $linkref->parent_content;
    $ii = 0;
    foreach $item (@set) {
	$hash{$ii} = $item->primary_key;
	$hash{"sort".$ii} = $item->aux_info('sort_order');
	$hash{"text".$ii} = $item->field_value('title');
	$ii ++;
    }
    $hash{items} = $ii;
    $self->{collection} = \%hash;
}

sub select_content_content_link {
    my $self = shift;
    my $content_id = shift;
    my $child_list = shift;
    my $linkref = $HSDB4::SQLLinkDefinition::LinkDefs{'link_content_content'};
    my $set = $linkref->get_children($content_id,"child_content_id in ($child_list)");
    return @{%{$set}->{_list}};
}

sub select_status_history {
    my $self = shift;
    my $content_id = shift;
    my ($linkref,@set,$item,%hash,$ii);
    $linkref = HSDB4::SQLRow::StatusHistory->new;
    @set = $linkref->lookup_conditions("content_id=$content_id","ORDER BY status_date DESC"); 
    $ii=0;
    foreach $item (@set) {
	$hash{$ii} = $item->{status};
	$hash{"date".$ii} = $item->{status_date};
	$hash{"assigner".$ii} = $item->{assigner};
	$hash{"note".$ii} = $item->{status_note};
	$ii++;
	last if ($ii > 2);
    }
    $hash{items} = $ii;
    $self->{status_history} = \%hash;
}

sub select_content_history {
    my $self=shift;
    my $content_id = shift;
    my ($linkref,@set,$item,%hash,$ii);
    $linkref = HSDB4::SQLRow::ContentHistory->new;
    @set = $linkref->lookup_conditions("content_id=$content_id","ORDER BY content_id");
    @set = splice(@set, $#set-1, 2) if (@set > 2); # get last two elements of the set
    $ii=0;
    foreach $item (@set) {
	$hash{$ii} = format_sql_date($item->{modified});
	$hash{"modifier".$ii} = $item->{modified_by};
	$hash{"note".$ii} = $item->{modify_note};
	$ii++;
    }
    $hash{items} = (@set < 2 ? @set : 2);
    $self->{modified_history} = \%hash;
}

sub process_content_user {
    my $self = shift;
    my $new_content_id = shift;
    my $content = HSDB4::SQLRow::Content->new()->lookup_key($new_content_id);
    my (%hash,$new_link,$r,$msg);
    %hash = %{$self->{entities}};
    for (my $ii=0;$ii<$hash{items};$ii++) {
	if ($hash{$ii} !~ /^\d+$/) {
	    unless (($r,$msg) = $content->add_child_user($TUSK::Constants::DatabaseUsers{ContentManager}->{writeusername},$TUSK::Constants::DatabaseUsers{ContentManager}->{writepassword},$hash{$ii},$hash{$hash{$ii}.$ii})) {
		set_message($msg);
		return;
	    }
	}
	else {
	    unless (($r,$msg) = $content->add_child_non_user($TUSK::Constants::DatabaseUsers{ContentManager}->{writeusername},$TUSK::Constants::DatabaseUsers{ContentManager}->{writepassword},$hash{$ii},$hash{$hash{$ii}.$ii})) {
		set_message($msg);
		return;
	    }
	}
    }
    return 1;
}

sub insert_content_user {
    my $self = shift;
    my $parent_id = shift;
    my $child_id = shift;
    my $roles = shift;
    my $sort_order = shift;
    $sort_order = $sort_order * 10;
    my $linkref = $HSDB4::SQLLinkDefinition::LinkDefs{'link_content_user'};
    my ($r,$msg) = $linkref->insert(-user => $TUSK::Constants::DatabaseUsers{ContentManager}->{writeusername},
       		   -password => $TUSK::Constants::DatabaseUsers{ContentManager}->{writepassword},
       		   -parent_id => $parent_id,
       		   -child_id => $child_id,
       		    roles => $roles,
		    sort_order => $sort_order
       		  );
    set_message($msg);
    return 1 if ($r);
}

sub insert_content_non_user {
    my $self = shift;
    my $parent_id = shift;
    my $child_id = shift;
    my $roles = shift;
    my $sort_order = shift;
    $sort_order = $sort_order * 10;
    my $linkref = $HSDB4::SQLLinkDefinition::LinkDefs{'link_content_non_user'};
    my ($r,$msg) = $linkref->insert( -user => $TUSK::Constants::DatabaseUsers{ContentManager}->{writeusername},
       		   -password => $TUSK::Constants::DatabaseUsers{ContentManager}->{writepassword},
       		   -parent_id => $parent_id,
       		   -child_id => $child_id,
       		    roles => $roles,
		    sort_order => $sort_order
       		  );
    set_message($msg);
    return 1 if ($r);
}

sub process_content_content {
    my $self = shift;
    my $user_id = shift;
    my $new_content_id = shift;
    my (%hash,$r,$msg);
    %hash = %{$self->{collection}};
    return 1 if ($hash{items} < 1);
    for (my $ii=0;$ii<$hash{items};$ii++) {
	my $content = HSDB4::SQLRow::Content->new->lookup_key($hash{$ii});
	next unless ($content->can_user_edit(HSDB4::SQLRow::User->new->lookup_key($user_id)));
	($r,$msg) = $content->add_child_content($TUSK::Constants::DatabaseUsers{ContentManager}->{writeusername},$TUSK::Constants::DatabaseUsers{ContentManager}->{writepassword},$new_content_id,$hash{"sort".$ii});
	set_message($msg);
	return unless ($r);
    }
    return 1;
}

sub insert_keyword {
    my $self = shift;
    my $content_id = shift;
    my $keyword = shift;
    my $type = shift;
    my $concept_id = shift;
    my $linkdef = TUSK::Core::LinkContentKeyword->new();
    my ($keywordObject,$r,$msg);
    if ($concept_id){
	$keywordObject = pop @{TUSK::Core::Keyword->lookup(" concept_id = '$concept_id' ")};
    } else {
	my $escape_keyword = $keyword;
	$escape_keyword =~ s/'/\\'/g;
	$keywordObject =  pop @{TUSK::Core::Keyword->lookup(" keyword = '$escape_keyword' ")};
	if (!$keywordObject){
		$keywordObject = TUSK::Core::Keyword->new();
		$keywordObject->setKeyword($keyword);
		$keywordObject->save();
	}
    }
    $linkdef->setContentID($content_id);
    $linkdef->setKeywordID($keywordObject->getPrimaryKeyID);
    $linkdef->save();
    return ($r,$msg);
}

sub process_keywords {
	my $self = shift;
	my $content_id = shift;
	my $user_id = shift;
	my $content = HSDB4::SQLRow::Content->new->lookup_key($content_id);
	my $keywords = [];
        my %keyword_hash = %{$self->{keywords}};
	my $keywordsFound;
	for (my $ii=0;$ii<$keyword_hash{items};$ii++) {
	    if ($keyword_hash{$ii."id"}){
		push @{$keywords}, TUSK::Core::Keyword->lookup(" concept_id = '".$keyword_hash{$ii."id"}."'");	
	    } else {
		next unless ($keyword_hash{$ii});
		my $escape_keyword = $keyword_hash{$ii};
		$escape_keyword =~ s/'/\\'/g;
		$keywordsFound = TUSK::Core::Keyword->lookup(" concept_id is null and keyword = '".$escape_keyword."'");	
		if (ref($keywordsFound) ne 'ARRAY' or scalar(@$keywordsFound) == 0){
		    my $keyword = TUSK::Core::Keyword->new();
		    $keyword->setKeyword($keyword_hash{$ii});
		    $keyword->save();
		    $keywordsFound->[0] = $keyword;
		}
		push @{$keywords}, $keywordsFound;
	    }
	    
	}
	
        my $link;
        my $currentKeywordLinks = TUSK::Core::LinkContentKeyword->lookup(" parent_content_id = ".$content_id);
	my @all_keywords = map { @{$_} } @{$keywords};
        my %keywordHash = map { ( $_->getPrimaryKeyID(), 1 ) } @all_keywords ;
        my %currentKeywordHash = map { ($_->getChildKeywordID(),1 ) } @{$currentKeywordLinks};
        # delete keywords that were removed
        foreach my $old_keyword (@{$currentKeywordLinks}){
                if (!$keywordHash{$old_keyword->getChildKeywordID()}){
                        $old_keyword->delete({'user'=>$user_id});
                }

        }
        # insert keywords that were added
	my $keyword_check = {};
        foreach my $keyword (@all_keywords){
                if (!$currentKeywordHash{$keyword->getPrimaryKeyID()}){
		    if ($keyword_check->{$keyword->getPrimaryKeyID()}){
                        $link = TUSK::Core::LinkContentKeyword->new();
                        $link->setParentContentID($content->getPrimaryKeyID());
                        $link->setChildKeywordID($keyword->getPrimaryKeyID());
                        $link->save({'user'=>$user_id});
			$keyword_check->{$keyword->getPrimaryKeyID()} = 1;
		    }
                }
        }
        return 1;

}

sub process_objectives {
    my $self = shift;
    my $content = shift;
    my $xml = shift;
    ## remove existing objective links
    foreach ($content->child_objectives) {
	$content->unlink_child_objective($TUSK::Constants::DatabaseUsers{ContentManager}->{writeusername},$TUSK::Constants::DatabaseUsers{ContentManager}->{writepassword},$_->primary_key);
    }
    ## add new links from XML document
    my ($r,$msg);
    my $count = 0;
    foreach ($xml->header_objectives) {
	($r,$msg) = $content->add_child_objective($TUSK::Constants::DatabaseUsers{ContentManager}->{writeusername},$TUSK::Constants::DatabaseUsers{ContentManager}->{writepassword},$_->primary_key, $count++);
    }
    return 1;
}

sub process_body_objectives {
    my $self = shift;
    my $content = shift;
    my $xml = shift;
    ## remove existing objective links
    foreach ($content->parent_objectives) {
	$content->unlink_parent_objective($TUSK::Constants::DatabaseUsers{ContentManager}->{writeusername},$TUSK::Constants::DatabaseUsers{ContentManager}->{writepassword},$_->primary_key);
    }
    ## add new links from XML document
    my ($r,$msg);
    foreach ($xml->body_objectives) {
	($r,$msg) = $content->add_parent_objective($TUSK::Constants::DatabaseUsers{ContentManager}->{writeusername},$TUSK::Constants::DatabaseUsers{ContentManager}->{writepassword},$_->primary_key);
    }
    return 1;
}

sub update_document_checkout {
    my $self = shift;
    my $content_id = shift;
    my $user_id = shift;
    my $content_ref = HSDB4::SQLRow::Content->new();
    $content_ref->lookup_key($content_id);
    ## return error if this document is checked out
    return "54" if ($content_ref->field_value('checked_out_by') =~ /$user_id/);
    return "53" if ($content_ref->field_value('checked_out_by') !~ /(^$|NULL)/);
    return "11" unless ($self->update_check_in_out($content_ref,$user_id));
    ## put body into field
    $self->{data} = $content_ref->field_value('hscml_body');
    return "00";
}

sub update_document_release {
    my $self = shift;
    my $content_id = shift;
    my $user_id = shift;
    my $content_ref = HSDB4::SQLRow::Content->new();
    $content_ref->lookup_key($content_id);
    # return error if document not checked out or is checked out by another user
    return "55" if ($content_ref->field_value('checked_out_by') !~ /^.+$/);
    return "53" if ($content_ref->field_value('checked_out_by') !~ /$user_id/);
    return "11" unless ($self->update_check_in_out($content_ref));
    return "00";
}

sub update_document_save {
    my $self = shift;
    my $content_id = shift;
    my $user_id = shift;
    my $content_ref = HSDB4::SQLRow::Content->new();
    $content_ref->lookup_key($content_id);
    # return error if document not checked out or is checked out by another user
    return "53" if ($content_ref->field_value('checked_out_by') !~ /$user_id/);
    return "11" unless ($self->update_check_in_out($content_ref));
    return "00";
}

sub update_check_in_out {
    my $self = shift;
    my $contentref = shift;
    my $user_id = shift;
    $contentref->set_field_values (checked_out_by => $user_id);
    my ($r,$msg) = $contentref->save_version("Updated checked_out_by",$user_id);
    set_message($msg);
    return 1 unless ($r)
}

sub delete_content_content {
    my $self = shift;
    my $content_id = shift;
    my $linkref = $HSDB4::SQLLinkDefinition::LinkDefs{'link_content_content'};
    my $set = $linkref->get_parents($content_id);
    foreach my $item (@{%{$set}->{_list}}) {
	my ($r,$msg) = $linkref->delete( -user => $TUSK::Constants::DatabaseUsers{ContentManager}->{writeusername},
			 -password => $TUSK::Constants::DatabaseUsers{ContentManager}->{writepassword},
			 -parent_id => $item->parent->primary_key,
			 -child_id => $content_id
			 );
	set_message($msg);
	return unless ($r);
    }
    return 1;
}

sub delete_content_user {
    my $self = shift;
    my $content_id = shift;
    my $linkref = $HSDB4::SQLLinkDefinition::LinkDefs{'link_content_user'};
    my @set = $linkref->get_children($content_id)->children;
    foreach my $item (@set) {
	my ($r,$msg) = $linkref->delete( -user => $TUSK::Constants::DatabaseUsers{ContentManager}->{writeusername},
			 -password => $TUSK::Constants::DatabaseUsers{ContentManager}->{writepassword},
			 -parent_id => $content_id,
			 -child_id => $item->primary_key
			 );
	set_message($msg);
	return unless ($r);
    }
    return 1;
}

sub delete_content_non_user {
    my $self = shift;
    my $content_id = shift;
    my $linkref = $HSDB4::SQLLinkDefinition::LinkDefs{'link_content_non_user'};
    my @set = $linkref->get_children($content_id)->children;
    foreach my $item (@set) {
	my ($r,$msg) = $linkref->delete( -user => $TUSK::Constants::DatabaseUsers{ContentManager}->{writeusername},
			 -password => $TUSK::Constants::DatabaseUsers{ContentManager}->{writepassword},
			 -parent_id => $content_id,
			 -child_id => $item->primary_key
			 );
	set_message($msg);
	return unless ($r);
    }
    return 1;
}


## output and formatting methods ##
sub add_status {
    my $self = shift;
    my $status = shift;
    $self->{output} .= output("<STATUS>$status</STATUS>");
}

sub add_ticket {
    my $self = shift;
    my $ticket = shift;
    $self->{output} .= output("<TOKEN>$ticket</TOKEN>");
}

sub add_content {
    my $self = shift;
    my $content_id = shift;
    $self->{output} .= output("<CONTENT>\n<ID>$content_id</ID>\n</CONTENT>");
}

sub add_image {
    my $self = shift;
    my $content_id = shift;
    $self->{output} .= output("<IMAGE>\n<ID>$content_id</ID>\n</IMAGE>");
}

sub add_document {
    my $self = shift;
    my $id = shift;
    my $title = shift;
    my $xml = shift;
    my $return_string = "<DOCUMENT>";
    $return_string .= "<ID>$id</ID>" if ($id);
    $return_string .= "<TITLE>".make_pcdata($title)."</TITLE>" if ($title);
    $return_string .= "<CONTENT>".escape($xml)."</CONTENT>" if ($xml);
    $self->{output} .= output($return_string."</DOCUMENT>");
}

sub add_course {
    my $self = shift;
    my $id = shift;
    my $title = shift;
    my $school = shift;
    my $return_string = "<COURSE>";
    $return_string .= "<ID>$id</ID>";
    $return_string .= "<TITLE>".make_pcdata($title)."</TITLE>";
    $return_string .= "<SCHOOL>".escape($school)."</SCHOOL>";
    $self->{output} .= output($return_string."</COURSE>");
}

sub add_collection {
    my $self = shift;
    my $id = shift;
    my $title = shift;
    my $sort_order = shift;
    my $return_string = "<COLLECTION>";
    $return_string .= "<ID>$id</ID>"; 
    $return_string .= "<TITLE>".make_pcdata($title)."</TITLE>";
    $return_string .= "</COLLECTION>"; 
    $self->{output} .= output($return_string);
}

sub add_umls {
    my $self = shift;
    my $id = shift;
    my $concept = shift;
    my $definition = shift;
    my $return_string = "<UMLS>";
    $return_string .= "<ID>$id</ID>"; 
    $return_string .= "<CONCEPT>".escape($concept)."</CONCEPT>";
    $return_string .= "<DEFINITION>".escape($definition)."</DEFINITION>" if ($definition);
    $return_string .= "</UMLS>"; 
    $self->{output} .= output($return_string);
}

sub add_objective {
    my $self = shift;
    my $id = shift;
    my $body = shift;
    my $return_string = "<OBJECTIVE>";
    $return_string .= "<ID>$id</ID>"; 
    $return_string .= "<BODY>".escape($body)."</BODY>";
    $return_string .= "</OBJECTIVE>"; 
    $self->{output} .= output($return_string);
}

sub add_non_user {
    my $self = shift;
    my $id = shift;
    my $institutionname = shift;
    my $lastname = shift;
    my $firstname = shift;
    my $midname = shift;
    my $suffix = shift;
    my $degree = shift;
    my $email = shift;
    my $return_string = "<NONUSER>";
    $return_string .= "<ID>$id</ID>"; 
    $return_string .= "<INSTITUTION_NAME>".make_pcdata($institutionname)."</INSTITUTION_NAME>" if ($institutionname);
    $return_string .= "<LASTNAME>".make_pcdata($lastname)."</LASTNAME>" if ($lastname);
    $return_string .= "<FIRSTNAME>".make_pcdata($firstname)."</FIRSTNAME>" if ($firstname);
    $return_string .= "<MIDNAME>".make_pcdata($midname)."</MIDNAME>" if ($midname);
    $return_string .= "<SUFFIX>".make_pcdata($suffix)."</SUFFIX>" if ($suffix);
    $return_string .= "<DEGREE>".make_pcdata($degree)."</DEGREE>" if ($degree);
    $return_string .= "<EMAIL>".make_pcdata($email)."</EMAIL>" if ($email);
    $return_string .= "</NONUSER>"; 
    $self->{output} .= output($return_string);

}

sub add_user {
    my $self = shift;
    my $id = shift;
    my $institutionname = shift;
    my $lastname = shift;
    my $firstname = shift;
    my $midname = shift;
    my $suffix = shift;
    my $degree = shift;
    my $email = shift;
    my $return_string = "<USER>";
    $return_string .= "<ID>$id</ID>";
    $return_string .= "<INSTITUTION_NAME>".make_pcdata($institutionname)."</INSTITUTION_NAME>" if ($institutionname);
    $return_string .= "<LASTNAME>".make_pcdata($lastname)."</LASTNAME>" if ($lastname);
    $return_string .= "<FIRSTNAME>".make_pcdata($firstname)."</FIRSTNAME>" if ($firstname);
    $return_string .= "<MIDNAME>".make_pcdata($midname)."</MIDNAME>" if ($midname);
    $return_string .= "<SUFFIX>".make_pcdata($suffix)."</SUFFIX>" if ($suffix);
    $return_string .= "<DEGREE>".make_pcdata($degree)."</DEGREE>" if ($degree);
    $return_string .= "<EMAIL>".make_pcdata($email)."</EMAIL>" if ($email);
    $return_string .= "</USER>"; 
    $self->{output} .= output($return_string);

}

sub start_output {
    return output("<?xml version=\"1.0\" encoding=\"UTF-8\"?>").output("<DATA>");
}

sub end_output {
    return output("</DATA>");
}

sub output {
    my $string = shift;
    return $string;
}

sub escape {
    my $text = shift;
    return Apache::Util::escape_html($text);
}

sub output_xml {
    my $self = shift;
    $self->{output} .= end_output();    
    return $self->{output};
}

## accessory methods ##
sub get_token_user {
    my $token = shift;
    my $user = HSDB4::SQLRow::User->new;
    return $user->get_id_api_token($token);
}

sub strip_last {
    my $string = shift;
    my $char = shift;
    $char = "," if (!$char);
    $string =~ s/(.+)$char$/$1/;
    return $string;
}

sub content_type {
    return "text/xml";
}

sub set_message {
    $LASTMSG = shift;
}

sub append_message {
    $LASTMSG .= shift;
}

sub get_message {
    return $LASTMSG;
}

sub get_now_sql_date {
    my ($secs,$mins,$hours,$mo_day,$mo,$yr) = (localtime)[0,1,2,3,4,5];
    $yr += 1900;
    $mo += 1;
    ## prepend 0 if single numbers
    $mo = "0$mo" if (length($mo) < 2);
    $mo_day = "0$mo_day" if (length($mo_day) < 2);
    $secs = "0$secs" if (length($secs) < 2);
    $hours = "0$hours" if (length($hours) < 2);
    $mins = "0$mins" if (length($mins) < 2);
    return "$yr-$mo-$mo_day $hours:$mins:$secs";
}

sub format_sql_date {
    my $time = shift;
    $time =~ s/(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})/$1-$2-$3\ $4:$5:$6/;
    return $time;
}

1;
__END__

=head1 NAME

B<HSDB45::API> - Class for responding to requests from external XMetaL tool

=head1 DESCRIPTION

This class encapsulates a set of methods which correlates to commands initiated on the XMetaL application on a user's desktop. The commands are sent via HTTP and processed within this class (using embperl pages as a front-end). 

=head2 Methods

B<login()> authenticates username and password and returns an XML string with status and token (if login succesful)

=head2 Supporting Methods

=cut


