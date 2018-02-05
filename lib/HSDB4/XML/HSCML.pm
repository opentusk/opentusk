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


package HSDB4::XML::HSCML;

use strict;
use XML::Twig;
use HSDB4::SQLRow::User;
use XML::EscapeText;
use TUSK::Constants;
use Data::Dumper;

BEGIN {
    require Exporter;
    require HSDB4::Constants;

    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

    @ISA = qw(Exporter);
    @EXPORT = qw( );
    @EXPORT_OK = qw( );
    $VERSION = do { my @r = (q$Revision: 1.56 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
}

use vars @EXPORT_OK;

# Non-exported package globals go here
use vars ();

#
# >>>>> Constructor <<<<<
#

sub new {
    #
    # Does the default creation stuff
    #
    my $class = shift;
    $class = ref $class || $class;
    my $data = shift;
    my $self = {data => $data,error => ""};
    my $twig = XML::Twig->new(KeepEncoding => 1,NoExpand => 1, ErrorContext => 0);
    $twig->safe_parse($self->{data}) if ($self->{data});
    my $error = $@;
    $self->{twig} = $twig;
    bless $self, $class;
    if ($error) {
	$self->error($error);
    }
    return $self;
}

sub twig {
    my $self = shift;
    return $self->{twig};
}

sub create_twig {
    my $self = shift;
    my $data = shift;
    my $twig = $self->twig;
    if ($data) {
	$self->{data} = $data;
	$twig = $twig->safe_parse($self->{data});
	if ($@) {
	   $self->error($@);
	   return;
	}
	$self->{twig} = $twig;
    }
    return;
}

sub replace_html_element {
    my $self = shift;
    my $new_html = shift;
    my $twig = $self->twig;
    # if there is no data, make a new entry
    $self->start_xml if (!$self->{data});

    unless($twig->safe_parse($self->{data})) {
	return (0,"Existing data in the database is malformed, can't replace it.")
    }

    my $root = $twig->root;
    # get the root of the twig (content_body)
    my $elt = $root->child(0,'html'); # check for html element
    if ($elt) { # if html element is there remove it
	$elt->cut;
    }
    paste_last($root,"html",$new_html);
    $self->{data} = $twig->sprint(1);
    return 1;
}

sub replace_external_uri {
    my $self = shift;
    my $url = shift;
    my $twig = $self->twig;
    $self->start_xml if (!$self->{data});
    unless($twig->safe_parse($self->{data})) {
	return (0,"Existing data in the database is malformed, can't replace it.")
    }
    my $root = $twig->root;
    my $elt = $root->child(0,"external_uri");
    if ($elt) {
	$elt->cut;
    }
    paste_last($root,"external_uri",$url);
    $self->{data} = $twig->sprint(1);
    return 1;
}

sub replace_element_uri {
    my $self = shift;
    my $uri = shift;  ## values
    my $element = shift;
    my $twig = $self->twig;

    if (ref $uri eq ref {} && exists $uri->{'#CDATA'}) {
        $uri->{'#CDATA'} =  XML::EscapeText::spec_chars_name($uri->{'#CDATA'});
    } else { ## trying to parse PCDATA
        unless ($twig->safe_parse($self->{data})) {
            return (0,"Existing data in the database is malformed, can't replace it.")
        }
    }

    $self->start_xml unless ($self->{data});
    my $root = $twig->root;
    my $elt = $root->child(0,$element);
    $elt->cut if ($elt);
    paste_last($root,$element,$uri);
    $self->{data} = $twig->sprint(1);
    return 1;
}

sub replace_element_attribute {
    my $self = shift;
    my $element = shift;
    my $attribute = shift;
    my $value = shift;
    my $twig = $self->twig;
    $self->start_xml if (!$self->{data});
    unless($twig->safe_parse($self->{data})) {
	return (0,"Existing data in the database is malformed, can't replace it.")
    }
    my $root = $twig->root;

    my $elt = $root->first_child($element);
    unless ($elt) {
	paste_first($root, $element, '');
	$elt = $root->child(0,$element);
    }

    set_attribute($elt,$attribute,$value);

    $self->{data} = $twig->sprint(1);
    return 1;
}

sub out_html_body {
    my $self = shift;
    my $content = shift;
    use XML::LibXML;
    use XML::LibXSLT;

    my $parser = XML::LibXML->new();
    my $prolog = "<?xml version=\"1.0\"?><!DOCTYPE CONTENT SYSTEM \"http://". $TUSK::Constants::Domain ."/DTD/hscmlweb.dtd\">";
    my $source;
    eval {
	    $source = $parser->parse_string($prolog.$self->out_content_body);
    };
    if ($@){
	$self->error("XML Parse:" . $@);
	return;
    }

    my $doc = $ENV{XSL_ROOT} . '/Content/Document.xsl';
    $doc = $content->xsl_stylesheet if ($content->xsl_stylesheet);
    my $style_doc;
    eval {
        $style_doc = $parser->parse_file($doc);
    };
    if ($@){
        $self->error("XSLT Stylesheet:".$@);
        return;
    }

    my $xslt = XML::LibXSLT->new();
    my $stylesheet = $xslt->parse_stylesheet($style_doc);
    my $results;

    eval {
	    $results = $stylesheet->transform($source,
					      'CONTENTID' => $content->primary_key,
					      'HTTP_HOST' => "'" .  $ENV{HTTP_HOST} . "'");
    };
    if ($@){
        $self->error("XSLT Transform:".$@);
        return;
    }
    return $stylesheet->output_string($results);
}

sub out_xml {
    my $self = shift;
    return $self->out_db_content;
}

sub start_xml {
    my $self = shift;
    $self->{data} =  "<?xml version=\"1.0\" encoding=\"UTF-8\"?><content_body></content_body>";
}

sub out_content {
    my $self = shift;
    $self->build_header;
    return $self->out_content_header.$self->out_content_body;
}

sub out_content_body {
    my $self = shift;
    my $node_id = shift;
    my $twig = $self->twig;
    my $root = $twig->root;           # get the root of the twig (db-content)
    my $body = $root->child(0,'body');    # get body
    ## find cite includes and stick in the label and copyright information
    foreach my $elt ($body->descendants("hsdb-cite-include")) {
	my $content_id = $elt->att("content-id");
	my $content = HSDB4::SQLRow::Content->new->lookup_key($content_id);
	set_attribute($elt,"label",$content->out_label);
	set_attribute($elt,"copyright-holder",$content->field_value("copyright"));
    }
    return $self->parse_sub_body($node_id) if ($node_id);
    return $body->sprint();
}

sub out_title {
    my $self = shift;
    my $header = $self->out_twig_header;
    my $title = $header->first_child("title");
    return $title->text;
}

sub out_twig_header {
    my $self = shift;
    my $twig = $self->twig;
    my $root = $twig->root;           # get the root of the twig (db-content)
    return $root->child(0,'header')
}

sub out_twig_body {
    my $self = shift;
    my $twig = $self->twig;
    my $root = $twig->root;           # get the root of the twig (db-content)
    return $root->child(0,'body')
}

sub out_content_header {
    my $self = shift;
    my $twig = $self->twig;
    $self->build_header;
    my $root = $twig->root;           # get the root of the twig (db-content)
    my $header = $root->child(0,'header');    # get header
    return $header->sprint(1);
}

sub out_db_content {
    my $self = shift;
    return $self->{data};
}

sub out_db_content_header {
    my $self = shift;
    my $twig = $self->twig;
    my $root = $twig->root;           # get the root of the twig (db-content)
    my $header = $root->child(0,'header');    # get header
    return $header->sprint(1);
}

sub get_prolog {
    my $self = shift;
    my $twig = $self->twig;
    return $twig->prolog;
}

sub parse_header {
    my $self = shift;
    my $caller = shift;
    my $twig = $self->twig;
    my $status = "00";
    my $root = $twig->root;           # get the root of the twig (content)
    my $header = $self->out_twig_header;
    my $body = $self->out_twig_body;

    ## make sure the content_id is left blank
    cut_attribute($root,"content-id");

    ## get and cut title from header
    my $title = $header->child(0,'title');
    $caller->{title} = $title->text;
    $title->cut;

    ## get and cut creation information from header
    my $creation = $header->child(0,'creation-date');
    $caller->{created} = $creation->text if ($creation);
    $creation->cut if ($creation);

    ## get and cut course reference
    my $course = $header->child(0,'course-ref');
    $caller->{course_id} = $course->att('course-id');
    $caller->{school} = $course->att('school');
    $course->cut;

    ## get and cut copyright information
    my $copyright = $header->child(0,'copyright');
    ## if it's copyright-text, grab and cut the information, otherwise just grab
    if ($copyright->child(0,'copyright-text')) {
	$caller->{copyright} = $copyright->child(0,'copyright-text')->text;
	$copyright->cut;
    }
    else {
	my $cstructure = $copyright->child(0,'copyright-structure');
	my $cowner = $cstructure->child(0,'copyright-owner');
	$caller->{copyright} = "Copyright ".$cstructure->child(0,'copyright-years')->text.", ".$cowner->att('friendly-name');
    }

    ## get and cut all user and non_user references
    my ($entity,$entity_ref,@set,$ii,%entities);
    $ii = 0;
    foreach ('author','contact-person','editor') {
	@set = $header->children($_);
	## loop over all author, contact-person, and editor entries
	foreach $entity (@set) {
	    $entity_ref = $entity->first_child;
	    next if ($entity_ref->field('non-user'));
	    my $user_id = $entity_ref->att('user-id') if $entity_ref->att('user-id');
	    $user_id = $entity_ref->att('non-user-id') if $entity_ref->att('non-user-id');
	    $entities{$ii} = $user_id;
	    $entities{$user_id.$ii} = $_;
	    $entity_ref->cut; ## now remove the user reference from entity
	    $entity->cut; ## not remove the entity from the header
	    $ii++;
	}
    }
    $entities{items} = $ii;
    $caller->{entities} = \%entities;

    ## get all keywords tags
    my (%keywords,$UMLS);
    $ii=0;
    @set = $header->children('header-keyword');
    foreach $entity (@set) {
	if ($UMLS = $entity->child(0,'umls-concept')) {
	    $keywords{$ii."id"} = $UMLS->att('concept-id');
	    $keywords{$ii} = $UMLS->text;
	}
	else {
	    $keywords{$ii} = $entity->text;
        }
	$ii++;
    }

    @set = $body->descendants('keyword');
    foreach $entity (@set) {
	if ($UMLS = $entity->child(0,'umls-concept')) {
	    $keywords{$ii."id"} = $UMLS->att('concept-id');
	    $keywords{$ii} = $UMLS->text;
	}
	else {
	    $keywords{$ii} = $entity->text;
        }
	$ii++;
    }
    $keywords{items} = $ii;
    $caller->{keywords} = \%keywords;

    ## get and cut all entries in the collection list
    my (%collection);
    undef @set;
    my $collection_root = $header->child(0,'collection-list');
    @set = $collection_root->children if ($collection_root);
    $ii = 0;
    foreach $entity_ref (@set) {
	$collection{$ii} = $entity_ref->att('content-id');
	$collection{"sort".$ii} = $entity_ref->att('sort-order');
	$collection{"text".$ii} = $entity_ref->text if ($entity_ref->text);
	$entity_ref->cut;
	$ii++;
    }
    $collection_root->cut if ($collection_root);
    $collection{items} = $ii;
    $caller->{collection} = \%collection;

    ## cut all modified-history
    undef @set;
    @set = $header->children('modified-history');
    ## loop over all modified-history structures and cut them
    foreach $entity (@set) {
	$entity->cut;
    }

    ## cut all status-history references
    undef @set;
    @set = $header->children('status-history');
    $ii = 0;
    ## loop over all status structures and pull out data
    foreach $entity (@set) {
	$entity->cut;
    }

    ## not change the element names to align with the dbhscml.dtd
    $root->set_gi("db-content");
    $header->set_gi("brief-header");

    ## do work on the body of the paragraph
    $self->insert_node_tags($body);

    ## reset the data variable to include only what's left in the header and body
    $caller->{data} = $twig->sprint(1);
    return $status;
}

sub header_objectives {
    ## this sub returns a set of objectives from the header of the XML, after it's been stripped down by other processing
    my $self = shift;
    my $twig = $self->twig;
    my $root = $twig->root;           # get the root of the twig (content)
    my $header = $root->child(0,'brief-header');
    my @objectives;
    my @set = $header->children('header-objective-item');
    foreach my $entity (@set) {
	my $objective = HSDB4::SQLRow::Objective->new;
	push (@objectives,$objective->lookup_key($entity->att("objective-id"))) if ($entity->att("objective-id"));
    }
    return @objectives;
}

sub remove_header_objectives {
    ## find and remove all header-objective-item tags from the brief-header
    my $self = shift;
    my $api = shift;
    my $twig = $self->twig;
    my $root = $twig->root;           # get the root of the twig (content)
    my $header = $root->child(0,'brief-header');
    my @set = $header->children('header-objective-item');
    foreach (@set) {
	$_->cut;
    }
    $api->{data} = $twig->sprint(1);
}

sub body_objectives {
    ## this sub returns a set of objectives from the body of the XML
    my $self = shift;
    my $twig = $self->twig;
    my $root = $twig->root;           # get the root of the twig (content)
    my $body = $root->child(0,'body');
    my @objectives;
    my @set = $body->descendants('objective-item');
    foreach my $entity (@set) {
	my $objective = HSDB4::SQLRow::Objective->new;
	push (@objectives,$objective->lookup_key($entity->att("objective-id"))) if ($entity->att("objective-id"));
    }
    return @objectives;
}

sub build_header {
    my $self = shift;
    my $caller = shift;
    my $twig = $self->twig;
    my $status = "00";
    my $root = $twig->root;           # get the root of the twig (content)
    my $header = $root->child(0,'brief-header');
    my $body = $root->child(0,'body');
    return "61" unless ($header);

    my (%hash,@set,@keyword_elts,@keywords,$mimetype,$copyright_struct,@ack_elts,@acks,@source_elts,@source,@objective_elts,@h_objectives,$elt,$sub_elt,$ii);

    $root->set_gi("content");
    $header->set_gi("header");

    ## get all existing elements that are in the header - can be pasted back in
    @keyword_elts = $header->children('header-keyword');
    foreach (@keyword_elts) {
	push(@keywords,$_->text);
	$_->cut;
    }

    if ($header->child(0,'mime-type')) {
	$mimetype = $header->child(0,'mime-type')->text;
	$header->child(0,'mime-type')->cut;
    }

    if ($header->child(0,'copyright')) {
	$copyright_struct = $header->child(0,'copyright');
	$header->child(0,'copyright')->cut;
    }

    @ack_elts = $header->children('acknowledgement');
    foreach (@ack_elts) {
	push(@acks,$_->text);
	$_->cut;
    }

    @source_elts = $header->children('source');
    foreach (@source_elts) {
	push(@source,$_->text);
	$_->cut;
    }

    ## remove associated data
    my $associated_data = $root->child(0,'associated-data');
    $associated_data->cut if ($associated_data);

    ## put the content_id into the content tag
    set_attribute($root,"content-id",$caller->{content_id});

    ## add the title
    paste_last($header,"title",$caller->{title});

    ## add all role information
    @set = @{$caller->{entities}};
    foreach my $role (qw(Author Contact-Person Editor)) {
        foreach (@set) {
	    if ($_->aux_info('roles') =~ /$role/) {
		$elt = new XML::Twig::Elt (lc($role));
		set_attribute($elt,"friendly-name",$_->out_label);
		my $prefix;
		if ($_->primary_key =~ /^\d+$/) { $prefix = "non-"; }
		$sub_elt = paste_first($elt,$prefix."user-identifier");
		set_attribute($sub_elt,$prefix."user-id",$_->primary_key);
		$sub_elt->set_empty();
		paste_last_object($header,$elt);
	    }
        }
    }

    ## add the created tag
    paste_last($header,"creation-date",format_sql_date($caller->{created})) if ($caller->{created});

    ## add the content (modified) history
    %hash = %{$caller->{modified_history}};
    for ($ii=0;$ii<$hash{items};$ii++) {
	$elt = new XML::Twig::Elt ("modified-history");
	paste_first($elt,"modified-note",$hash{"note".$ii}) if ($hash{"note".$ii});
	paste_first($elt,"modifier",$hash{"modifier".$ii});
	paste_first($elt,"modified-date",format_sql_date($hash{$ii}));
	paste_last_object($header,$elt);
    }

    ## add the status history
    %hash = %{$caller->{status_history}};
    for ($ii=0;$ii<$hash{items};$ii++) {
	$elt = new XML::Twig::Elt ("status-history");
	paste_first($elt,"status-note",$hash{"note".$ii}) if ($hash{"note".$ii});
	paste_first($elt,"assigner",$hash{"assigner".$ii});
	paste_first($elt,"status-date",format_sql_date($hash{"date".$ii}));
	paste_first($elt,"status",$hash{$ii});
	paste_last_object($header,$elt);
    }

    ## add the course ref element
    $elt = paste_last($header,"course-ref",$caller->{course_title});
    set_attribute($elt,"course-id",$caller->{course_id});
    set_attribute($elt,"school",$caller->{school});
    $elt->set_empty() unless ($caller->{course_title});

    ## add header-keyword elements back in
    foreach (@keywords) {
	paste_last($header,"header-keyword",$_);
    }

    ## add mime-type
    paste_last($header,"mime-type",$mimetype) if ($mimetype);

    ## add acknowledgement elements back in
    foreach (@acks) {
	paste_last($header,"acknowledgement",$_);
    }

    ## add source elements back in
    foreach (@source) {
	paste_last($header,"source",$_);
    }

    ## stick the copyright info in the doc
    if ($copyright_struct) {
	paste_last_object($header,$copyright_struct);
    }
    else {
	$elt = new XML::Twig::Elt ("copyright");
	paste_last($elt,"copyright-text",$caller->{copyright});
	paste_last_object($header,$elt);
    }

    ## add the collection structure
    %hash = %{$caller->{collection}};
    $elt = new XML::Twig::Elt("collection-list");
    for (my $ii=0;$ii<$hash{items};$ii++) {
	## only paste it in if it's not empty
	if ($hash{$ii}) {
	    my $sub_elt = paste_first($elt,"member-of",$hash{"text".$ii});
	    set_attribute($sub_elt,"content-id",$hash{$ii});
	    set_attribute($sub_elt,"sort-order",$hash{"sort".$ii});
	    $sub_elt->set_empty() if (!$hash{"text".$ii});
	}
    }
    paste_last_object($header,$elt) if ($hash{items} > 0);

    ## add objective elements
    foreach ($caller->header_objectives) {
	$elt = new XML::Twig::Elt("header-objective-item",$_->field_value("body"));
	set_attribute($elt,"objective-id",$_->primary_key);
	paste_last_object($header,$elt);
    }

    ## go through and add title and copyright to hsdb-cite-include items
    foreach my $elt ($body->descendants("hsdb-cite-include")) {
	my $content_id = $elt->att("content-id");
	my $content = HSDB4::SQLRow::Content->new->lookup_key($content_id);
	set_attribute($elt,"label",$content->out_label);
	set_attribute($elt,"copyright-holder",$content->field_value("copyright"));
    }

    $caller->{data} = $twig->sprint(1);
    $caller->{data} =~ s/\<\!DOCTYPE.+dtd\">/<!DOCTYPE\ content\ SYSTEM\ \"hscml.dtd\">/s;
    $caller->{data} =~ s/\<\?xml version\=\"1.0\".*\?\>/\<\?xml version\=\"1.0\"\ encoding\=\"ISO\-8859\-1\"?\>/s;

    return "00";
}

sub refresh_status {
    my $self = shift;
    my $caller = shift;
    my $twig = $self->twig;
    my $root = $twig->root;           # get the root of the twig (db-content)
    my $header = $root->child(0,'header');    # get body
    foreach ($header->descendants('status-history')) {
	$_->cut;
    }
    my $last_modified;
    ## find the last modified element, which will give us a place to paste the status elements
    $last_modified = $header->last_child("modified-history");
    ## if there isn't a last modified go back one more to creation-date
    $last_modified = $header->last_child("creation-date") if (!$last_modified);
    my (%hash,$ii,$elt);
    ## add the status history
    %hash = %{$caller->{status_history}};
    for ($ii=0;$ii<$hash{items};$ii++) {
	$elt = new XML::Twig::Elt ("status-history");
	paste_first($elt,"status-note",$hash{"note".$ii}) if ($hash{"note".$ii});
	paste_first($elt,"assigner",$hash{"assigner".$ii});
	paste_first($elt,"status-date",format_sql_date($hash{"date".$ii}));
	paste_first($elt,"status",$hash{$ii});
	$elt->paste("after",$last_modified);
    }
    $caller->{data} = $twig->sprint(1);
}

sub parse_body {
    my $self = shift;
    my $twig = $self->twig;
    $twig->set_pretty_print("none");
    return "The document you requested contains invalid or no HSCML. Please contact the HSDB." if (!$self->{data});
    my $content_id = shift;
    my $root = $twig->root;
    my $body = $root->child(0,"body");
    return "Body not in correct XML format" if (!$body);
    ## paras contains all paragraph elements as well as all tables
    my @paras = $body->descendants("/para|table/");
    my $html = "<TABLE>\n";
    my $para_count = 0;
    foreach my $para (@paras) {
	next if ($para->att("id") =~ /^$/);
	next if ($para->text =~ /^$/);
	my $text = $para->text;
	$text =~ s/[\t\n\r\f]//g;
	if ($para->gi =~ /table/) {
	$html .= "<TR>\n<TD VALIGN=\"top\"><IMG SRC=\"/chooser_icon/table/".$content_id."/".$para->att("id")."\" HEIGHT=\"22\" WIDTH=\"20\" ALT=\"".$text."\"></TD>\n";
    } else {
	$html .= "<TR>\n<TD VALIGN=\"top\"><IMG SRC=\"/chooser_icon/text/".$content_id."/".$para->att("id")."\" HEIGHT=\"22\" WIDTH=\"20\" ALT=\"".$text."\"></TD>\n";
    }
	if (length($text) > 100) {
	    $html .= "<TD>".substr($text,0,100)." . . .</TD>\n</TR>\n";
	}
	else {
	    $html .= "<TD>".$text."</TD>\n</TR>\n";
	}
	$para_count++;
    }
    $html .= "<TR><TD>This document does not contain linkable pieces.</TD></TR>" unless ($para_count);
    $html .= "</TABLE>\n";
    return $html;
}

sub parse_sub_body {
    my $self = shift;
    my $sub_id = shift;
    my $content = shift;
    my $twig = $self->twig;
    my $root = $twig->root;
    my $body;
    eval { $body = $root->child(0,"body"); };
    return "Body not in correct XML format" if (!$body);
    my @elts = $body->descendants();
    foreach my $elt (@elts) {
	return $elt->sprint if ($elt->att("id") =~ /$sub_id/);
    }
    return "The requested piece of this document could not be located.";
}

sub paste_first {
    my $XML_doc = shift;
    my $field = shift;
    my $value = shift;
    my $elt = new XML::Twig::Elt ($field,$value);
    $elt->paste('first_child',$XML_doc);
    return $elt;
}

sub paste_last {
    my $XML_doc = shift;
    my $field = shift;
    my $value = shift;
    my $elt = XML::Twig::Elt->new(%$value)->wrap_in($field);
    $elt->paste('last_child',$XML_doc);
    return $elt;
}

sub paste_first_object {
    my $parent_object = shift;
    my $child_object = shift;
    $child_object->paste('first_child',$parent_object);
}

sub paste_last_object {
    my $parent_object = shift;
    my $child_object = shift;
    $child_object->paste('last_child',$parent_object);
}

sub set_attribute {
    my $XML_doc = shift;
    my $title = shift;
    my $value = shift;
    $XML_doc->set_att($title,$value);
}

sub cut_attribute {
    my $XML_doc = shift;
    my $title = shift;
    $XML_doc->del_att($title);
}
sub format_sql_date {
    my $date = shift;
    return $date;
}

sub insert_node_tags {
    my $self = shift;
    my $body = shift;
    my @nodetags = qw(enumerated-list itemized-list definition-list
                  para equation figure table hsdb-cite-include
                  section-level-1 section-level-2 section-level-3
		      section-level-4 section-level-5 section-level-6);
    my @nodes = map { $body->descendants($_) } @nodetags;
    srand;
    ## put all of the current id attributes into a list
    my $id_list = join(",",map { $_->att("id") } @nodes);
    my $rand = (int(rand 8999) + 1000);
    ## now make a unique entry for each one that is empty
    foreach my $tag (@nodes) {
	if ($tag->att("id") =~ /^$/) {
	    $rand = (int(rand 8999) + 1000) while ($id_list =~ /$rand/);
	    $id_list .= ",$rand";
	    set_attribute($tag,"id","_".$rand)
	}
	else {
	    $id_list .= ",".$tag->att("id");
	}
    }
}

sub error {
    my $self = shift;
    my $error = shift;
    if ($error) {
	$self->{error} = $error;
    }
    return $self->{error};
}

1;
