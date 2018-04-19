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

package TUSK::Manage::Course::Export;

use strict;

use HSDB4::SQLRow::Content;
use HSDB4::SQLRow::User;
use HSDB45::Course;
use TUSK::Course::CourseMetadataDisplay;
use HSDB4::XML::HSCML;
use HSDB4::XML::Content;
use HSDB4::DateTime;
use TUSK::Constants;
use TUSK::Manage::Course::Import;

use Archive::Zip; 
use XML::Twig;
use File::Path;
use File::Copy;
use FindBin qw($Bin);
use lib "$Bin/../lib";

our $export_dir = (-d '/export') ? '/export' : $TUSK::Constants::TempPath;

# pass in a course object and params and return the name of a zip file that is the 
# content package.

# params are: start, end, and approved  
# 'start' & 'end' provide a lifespan for the course. we only grab content that was active
# during the span. if no values supplied, we use the current date for both.
# 'approved' are all of the posted values from get_content_package. the values we
# care about are either 'export_all', which means we should export all content from
# the course, or the various 'content chains' that are passed. 'content chains' are 
# strings of '-' delimited content ids. the final id is the id of the specific content
# and the preceding ids are the ids of any (nested) collections that contain that
# instance of the content.
sub export{
	my ($course, $params) = @_;

	#not really putting $log to great use at this time...
	my $log = '';

	#####
	# make tmp file with random number. put this in lexical var and use that as dir for adds
	my $tmp_dir = TUSK::Manage::Course::Import::genTmpDir($export_dir . '/', 'tmp_');
	$log .= "created tmp directory for content package.\n";

	#####
	# create zip archive
	my $arc = Archive::Zip->new();

	#####
	# build the basic xml structure that we will be fleshing out
	my $xml = getXML();

	my $today = HSDB4::DateTime->new()->out_mysql_date();
	my $start = $params->{start} || $today;
	my $end = $params->{end} || $today;

	#####
	# let's get some course metadata
	exportCourseMetadata($course, $start, $end, $xml);

	my $xtra_params =  {isvisible        => 'true', 
	                    xml              => $xml, 
	                    start            => $start, 
	                    end              => $end,
	                    course           => $course, 
	                    approved         => $params, 
	                    exported_content => {}, 
	                    tmp_dir          => $tmp_dir, 
	                    item_count       => 0, 
	                    log              => $log };

	my @contents = $course->active_child_content_during_span($start, $end);

	foreach my $c (@contents){
		$xtra_params->{parent_chain} = '';
		exportContent($c, $xml->{content}, $xml->{resources}, $xtra_params);	
	}

	$log = $xtra_params->{log};

	#####
	# bogus deal
	# HSDB4::XML::HSCML->new() sets KeepEncoding to 1. That causes special entities to be converted
	# to their characters. this is not desired when the following &lt;br> gets converted to <br>.
	# by setting KeepEncoding to 0 before the print, we save the day, and entities are preserved.
	my $bogus_twig = XML::Twig->new(KeepEncoding => 0);

	#####
	# print the imsmanifest.xml file
	my $retval = printManifest($xml, $tmp_dir);
	return $retval if $retval;

	#####
	# add files from tmp dir to content package archive
	# NB: Archive::Zip has an addTree() method that would do the trick, but
	# it croaks when in taint mode. therefore, we have this workaround
	opendir(DIR, $tmp_dir) or die "can't opendir $tmp_dir: $!";
	while (defined(my $file = readdir(DIR))) {
		next if $file =~ /^\.\.?$/;     # skip . and ..
		$arc->addFile("$tmp_dir/$file", $file);
	}
	closedir(DIR);

	#####
	# create content package zip and alert as to its creation and location	
	my $cp_file = getPackageName($course->title());

	if ($arc->writeToFileNamed($cp_file) == Archive::Zip::AZ_OK) {
		$log .= "TUSK content package generation successful!\n";
		$log .= "content package is located at: $cp_file\n"; 
	} else {
		return "Error: could not zip TUSK content package!\n";
	} 

	#####
	# then print log to tmp_dir
	open my $log_fh, ">$tmp_dir/log" or die $!;
	print $log_fh $log;
	close $log_fh;

	return ($log, $cp_file);
}


sub exportContent {
	my ($c, $cont_parent, $res_root, $xtra_args) = @_;

	$c = HSDB4::SQLRow::Content->new()->lookup_key($c) unless(ref $c);

	my $content_chain = ($xtra_args->{parent_chain} ne '')? $xtra_args->{parent_chain} . '-' : '';
	$content_chain .= $c->primary_key;

	unless(exists $xtra_args->{approved}->{export_all} || $xtra_args->{approved}->{$content_chain}){
		if($xtra_args->{lnkd_from_doc}){
		# if content not approved for export, but linked from a document, we want to generate some
		# html text that says that the content is missing from the doc
			my $return_str = missContStr($c);
			return $return_str;
		}
		else{
			return 0;
		}
	}

	if($c->type() eq 'External'){
		$xtra_args->{log} .= 'We are not currently exporting content of type External, so not exported: ' . $c->primary_key . "\n";
		return 0;
	}
	elsif($c->type()){
		my $res_id = genResource($c, $res_root, $cont_parent, $xtra_args);

		if($res_id){
			# do not want the same <item> element listed twice at same level in
			# content hierarchy. this can happen when content is linked from a doc
			unless($cont_parent->has_child('item[@identifierref="' . $res_id  . '"]')){
				my $item;
				$item = XML::Twig::Elt->new('item', {
					identifier => ('itm' . ++$xtra_args->{item_count}), 
					identifierref => ($res_id), 
					isvisible => $xtra_args->{isvisible} 
				});
				
				$item->paste('last_child' => $cont_parent);

				my $itm_title = XML::Twig::Elt->new('title', $c->title());
				$itm_title->paste('last_child' => $item);

				# RECURSIVELY GENERATE <item>'s AND <resource>'s FOR CHILDREN CONTENT
				if($c->type() =~ /Collection|Multidocument/){
					my @sub_content = $c->active_child_content_during_span($xtra_args->{start}, $xtra_args->{end});
					foreach my $sc (@sub_content){
						my $id = $sc->primary_key();
						
						#we want to eliminate circular directory refs, which TUSK allows.
						unless($sc->type() eq 'Collection' && $content_chain =~ /$id/){
							$xtra_args->{parent_chain} = $content_chain;
							exportContent($sc, $item, $res_root, $xtra_args);
						}
					}
				}
			}
			$xtra_args->{log} .= 'Content exported: ' . $c->primary_key . "\n";
			return $res_id;
		}
		else {
			$xtra_args->{log} .= 'No file found on system for content, so not exported: ' . $c->primary_key . "\n";
			return 0;
		}
	}
	else {
		$xtra_args->{log} .= "No type for content, so not exported: " . $c->primary_key . "\n";
		return 0;
	}

}

# generate the <resource> element for the imsmanifest.xml file
# this sub calls packContent() which actually takes the media and places it in 
# the directory for packaging
sub genResource{
	my ($c, $res_root, $cont_parent, $args) = @_;

	# we want all collections to be unique resources.
	# in TUSK, if a collection is used twice in a course, it is represented by one id
	# and simply linked twice; upon import each occurrence of this collection will become a
	# unique piece of content with a unique id
	my $id = (($c->type() eq 'Collection' || $c->type() eq 'Multidocument') && !$args->{lnkd_from_doc})? 'res' . generateID() : 'res' . $c->primary_key;

	# as long as we haven't seen this content before, generate a resource elmt for it
	unless($args->{exported_content}->{$id}) {
		if($c->type() ne 'URL'){			
			my $resource = XML::Twig::Elt->new('resource', {identifier => $id, type => 'webcontent'});
			my $fn = packContent($c, $resource, $res_root, $cont_parent, $args);
			
			if($fn){
				genContMetaData($c, $args->{course}, $resource);
				$resource->paste('last_child' => $res_root);		
				$args->{exported_content}->{$id} = $fn;
			}
			else {
				return 0;
			}
		} 
		else {
			my $resource = XML::Twig::Elt->new('resource', 
			                     {identifier => $id, 
								  type => 'webcontent', 
								  href => $c->out_external_url()
								  });
			$resource->paste('last_child' => $res_root);
			genContMetaData($c, $args->{course}, $resource);
			$args->{exported_content}->{$id} = $c->out_external_url();
		}
		$args->{log} .= 'Resource generated for content with id: ' . $c->primary_key . "\n";
	}
	return $id;
}


sub packContent {
	my ($c, $res_parent, $res_root, $cont_parent, $xtra_args) = @_;

	my $filename;
	
	if($c->type() eq 'Slide'){
		if ( $c->reuse_content_id() ) {
			$filename = $c->reuse_content_id();
		} else {
			$filename = $c->primary_key();
		}

		my $ext = $c->image_available('orig');
		
		return 0 unless($ext);

		$filename .= '.' . $ext;

		my $location = join "/", (split '', sprintf "%03d", $filename)[0..2], $filename;
		
		my $file_uri = $TUSK::UploadContent::path{'slide'} . $HSDB4::Constants::URLs{'orig'} . '/' . $location;

		unless( copy($file_uri, $xtra_args->{tmp_dir} . "/$filename") ) {
			$xtra_args->{log} .= "file copy failed for $file_uri: $!\n";
			return 0;
		}
		$xtra_args->{log} .= "content packed for content with id: " . $c->primary_key . "\n";
	} elsif ($c->type() =~ /DownloadableFile|Flashpix|Shockwave|PDF/){

		my $file_uri = $c->out_file_path();
		($filename = $file_uri) =~ s/\/.*\///;

		my $title = safe($c->title());
		$filename = "$title-$filename" if ($title);

		unless( -e $xtra_args->{tmp_dir} . "/$filename" ){
			unless( copy($file_uri, $xtra_args->{tmp_dir} . "/$filename") ) {
				$xtra_args->{log} .= "file copy failed for $file_uri: $!\n";
				return 0;
			}
			$xtra_args->{log} .= "content packed for content with id: " . $c->primary_key . "\n";
		}
	}
	elsif ($c->type() =~ /Document|TUSKdoc/){
		
		$filename = $c->primary_key() . '.xml';
		
		my $xml = $c->out_html_body();

		my $content_chain = ($xtra_args->{parent_chain} ne '')? $xtra_args->{parent_chain} . '-' : '';
		$content_chain .= $c->primary_key;

		# need to search docs and see if they link to any content.
		# if content is approved for export, we will export it, if not, we will print a 
		# message in the doc that alerts the user that there is a missing piece of content
		$xml =~ s/(<a\s[^>]*\/view\/content\/(\d+)[^>]*>.+?<\/a>)/canExport($1, $2, $cont_parent, $res_root, $content_chain, $xtra_args)/eg;
		$xml =~ s/(<img[^>]+src="\/\w+\/(\d+)"[^\/>]*\/?>)/canExport($1, $2, $cont_parent, $res_root, $content_chain, $xtra_args)/eg;

		my $packed_xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><originalXML>" . escape($xml) . "</originalXML>";

		# put file in tmp dir
		my $file_uri = $xtra_args->{tmp_dir} . "/$filename";
		unless( -e "$file_uri" ){
			open(my $fh, '>', $file_uri) or die $!;

			print $fh $packed_xml;
			close $fh;
			$xtra_args->{log} .= "content packed for content with id: " . $c->primary_key . "\n";
		}

		unless( -e $xtra_args->{tmp_dir} . "/hscml.css" ){
			if( copy("$Bin/../code/style/hscml.css", $xtra_args->{tmp_dir} . "/hscml.css") ) {
				my $elt_str = '<resource identifier="resHSCML" type="webcontent"><metadata><tom xmlns="http://'.$TUSK::Constants::Domain.'/xsd/tuskv0p1"><tuskType>CSS</tuskType></tom></metadata><file href="hscml.css"/></resource>';
				my $elt = parse XML::Twig::Elt($elt_str);
				$elt->paste(last_child => $res_root);
			}
			else {
				$xtra_args->{log} .= "file copy failed for hscml.css: $!\n";
			}
		}
	}

	# collections will not have a file to ref in resource element
	if($c->type() =~ /Collection|Multidocument/){
		return $c->primary_key();
	}
	else {
		pasteFileName($res_parent, $filename);
		return $filename;
	}
}

sub pasteFileName{
	my ($res, $fn) = @_;
	my $file = XML::Twig::Elt->new('file', {href => $fn});
	$file->paste(last_child => $res);
}


sub exportTuskMeta {
	my ($course, $start, $end, $md_root) = @_;
	my $md_types = $course->getSchoolMetadata();

	# need to change this to real location when done testing!!!
	my $elt_str = '<tusk xmlns="http://'.$TUSK::Constants::Domain.'/xsd/tuskv0p1">';
	$elt_str .= "<courseSpan><startDate>$start</startDate><endDate>$end</endDate></courseSpan>";
	$elt_str .= genMetadataString($course, $md_types);
	$elt_str .= '</tusk>';

	my $elt = parse XML::Twig::Elt($elt_str);
	$elt->paste('last_child' => $md_root);
}

# gets all of the metadata for a course and iterates through it to make a string which 
# can be parsed to make an xml representation of it
sub genMetadataString {
	my ($course, $md_types, $parent) = @_;
	my $elt_str = '';
   
	for my $id (@{ $md_types->{'metadataOrder'} }){
		my $disp_name = $md_types->{$id}->{'displayName'};
		my $type = $md_types->{$id}->{'editType'};

		my $metadata = $course->getCourseMetadataByType($course->getTuskCourseID(), $id, $parent, undef);
		foreach my $datum (@$metadata){
			$elt_str .= "<tuskMetaData token=\"$disp_name\" title=\"$disp_name\" type=\"$type\">";
			$elt_str .= "<value>" . escape($datum->getValue()) . "</value>" if $datum->getValue();

			if($md_types->{$id}->{'children'} && $type ne 'select'){
				$elt_str .= genMetadataString($course, $md_types->{$id}->{'children'}, $datum->getPrimaryKeyID());
			}
			
			$elt_str .= "</tuskMetaData>";
		}
	}

	return $elt_str;
}


sub exportObjectives {
	my ($c, $lom_root) = @_;
	my @objectives;
	
	# $c could be a course or content
	if ($c->isa('HSDB45::Course')) {
		@objectives = $c->child_topics();
	}

	if (scalar @objectives) {
		foreach my $obj (@objectives){
			my $obj_str = '<classification><purpose><source><langstring xml:lang="en">LOMv1.0</langstring></source><value><langstring xml:lang="en">Educational Objective</langstring></value></purpose><description><langstring xml:lang="en">' . escape($obj->out_label()) . '</langstring></description></classification>';

			my $obj_elt = parse XML::Twig::Elt($obj_str);
			$obj_elt->paste(last_child => $lom_root);
		}
	}
}

sub exportTitle {
	my ($course, $lom_root) = @_;

	my $title = escape($course->title());
	my $elt_str = "<general><title><langstring xml:lang=\"en\">$title</langstring></title></general>";
	my $elt = parse XML::Twig::Elt($elt_str);
	$elt->paste(last_child => $lom_root);
}


# export all of the users of a course with their title and a vcard
# representation of their identity
sub exportUsers {
	my ($course, $lom_root) = @_;
	my $users = $course->unique_users();
	if (scalar @$users) {
		my $lifecycle = XML::Twig::Elt->new('lifecycle');
		my %role_hash = ();
		foreach my $user (@$users) {
		    my $roles = $user->{roles};
			if (scalar (keys %$roles)) {
				my $vcard_str = genVcard(@{$user->{user}->getFieldValues([qw(user_id firstname midname lastname suffix degree preferred_email email)])});
				my $centity_str = '<centity><vcard>' . $vcard_str . '</vcard></centity>';
				foreach my $token (keys %$roles) {
				    if ($role_hash{$token}) {
					$role_hash{$token} .= $centity_str;
				    } else {
					$role_hash{$token} = '<contribute><role><source><langstring xml:lang="en">tuskv0.1</langstring></source><value><langstring xml:lang="en">' . $roles->{$token}->getRoleDesc() . '</langstring></value></role>';
					$role_hash{$token} .= $centity_str;
				    }
				}
			}
		}
		foreach my $key (keys %role_hash){
			$role_hash{$key} .= '</contribute>';
			my $elt = parse XML::Twig::Elt($role_hash{$key});
			$elt->paste(last_child => $lifecycle);
		}
		$lifecycle->paste(last_child => $lom_root);
	}
}


sub exportContentAuthors{
	my ($c, $lom) = @_;

	my @users = $c->child_authors();
	
	if(scalar @users){
		my $lifecycle = XML::Twig::Elt->new('lifecycle');
		$lifecycle->paste(last_child=>$lom);

		my $cont_str = '<contribute><role><source><langstring xml:lang="en">tuskv1.1</langstring></source><value><langstring xml:lang="en">author</langstring></value></role>';
		foreach my $author (@users){
		    my $vcard_str = genVcard($author->get_field_values(qw(user_id firstname midname lastname suffix degree preferred_email email)));
		    $cont_str .= "<centity><vcard>$vcard_str</vcard></centity>";
		}
		$cont_str .= '</contribute>';
		my $elt = parse XML::Twig::Elt($cont_str);
		$elt->paste('last_child' => $lifecycle);
	}

}

sub genContMetaData {
	my ($c, $course, $resource_elt) = @_;
	my $meta = XML::Twig::Elt->new('metadata');
	$meta->paste(first_child=>$resource_elt);
	my $lom = XML::Twig::Elt->new('lom', {xmlns => 'http://www.imsglobal.org/xsd/imsmd_v1p2'});
	$lom->paste(last_child=>$meta);
	
	# START BY EXPORTING 'GENERAL' INFO
	my $gen = XML::Twig::Elt->new('general');
	$gen->paste(last_child=>$lom);

	my $elt_str = '<title><langstring xml:lang="en">' . escape($c->title())  . '</langstring></title>';
	my $elt = parse XML::Twig::Elt($elt_str);
	$elt->paste(last_child => $gen);

	$elt = XML::Twig::Elt->new('language', 'en');
	$elt->paste(last_child => $gen);

	my $description = HSDB4::SQLRow::Content::out_html_body($c);
	if($description && $c->type() !~ /Document|TUSKdoc/){
		# Document's return their content with a call to out_html_body(); whereas,
		# a slide actually returns descriptive text with a call to that method.
		$elt_str = '<description><langstring xml:lang="en">' . escape($description)  . '</langstring></description>';
		$elt = parse XML::Twig::Elt($elt_str);
		$elt->paste(last_child => $gen);
	}

	if(scalar($c->keywords())){
		foreach my $kw ($c->keywords()){
			$elt_str = '<keyword><langstring xml:lang="en">' . escape($kw->getKeyword())  . '</langstring></keyword>';
			$elt = parse XML::Twig::Elt($elt_str);
			$elt->paste(last_child => $gen);
		}
	}

	exportContentAuthors($c, $lom);
	exportObjectives($c, $lom);
	

	# NOW EXPORT TUSK META
	my $tom = XML::Twig::Elt->new('tom', {xmlns => 'http://'.$TUSK::Constants::Domain.'/xsd/tuskv0p1'});
	$tom->paste(last_child=>$meta);

	# let's convert tuskdocs and xmetal to plain ol' docs...	
	my $type = ($c->type() eq 'TUSKdoc')? 'Document' : $c->type();

	my $tmd = XML::Twig::Elt->new('tuskType', $type);
	$tmd->paste(last_child=>$tom);

	$tmd = XML::Twig::Elt->new('originatingID', $c->primary_key);
	$tmd->paste(last_child=>$tom);

	$tmd = XML::Twig::Elt->new('createdTxt', $c->created());
	$tmd->paste(last_child=>$tom);

	$tmd = XML::Twig::Elt->new('created', $c->field_value('created'));
	$tmd->paste(last_child=>$tom);

	$tmd = XML::Twig::Elt->new('modifiedTxt', $c->modified());
	$tmd->paste(last_child=>$tom);

	$tmd = XML::Twig::Elt->new('modified', $c->field_value('modified'));
	$tmd->paste(last_child=>$tom);

	$tmd = XML::Twig::Elt->new('readAccess', $c->read_access());
	$tmd->paste(last_child=>$tom);

	$tmd = XML::Twig::Elt->new('copyright', $c->copyright());
	$tmd->paste(last_child=>$tom);

	if($c->source()){
		$tmd = XML::Twig::Elt->new('source', $c->source());
		$tmd->paste(last_child=>$tom);
	}
	if($c->contributor()){
		$tmd = XML::Twig::Elt->new('tuskContributor', $c->contributor());
		$tmd->paste(last_child=>$tom);
	}

	if($c->type =~ /Shockwave/){
		my $body = $c->body();
		my ($uri) = $body->tag_values ('shockwave_uri') if ($body);

		my ($width, $height);
		if ($uri->get_attribute_values ('width', 'height')){
			($width, $height) = map { $_->value } ($uri->get_attribute_values ('width', 'height'));
		}else{
			($width, $height) = (400, 400);
		}

		my $dim_str = "<dimensions><height>$height</height><width>$width</width></dimensions>";
		$tmd = parse XML::Twig::Elt($dim_str);
		$tmd->paste('last_child' => $tom);
	}
}

sub genVcard{
    my ($id, $fn, $mn, $ln, $sfx, $dg, $pfemail, $email) = @_;

    my $uemail = ($pfemail) ? $pfemail : $email;
    my $suffix = ($sfx && $dg) ? "$sfx,$dg" : ($sfx) ? $sfx : ($dg) ? $dg : '';
    my $fullname = "$fn $ln";
    my $vcard_str = qq(
begin: vcard
n: $ln;$fn;$mn;;$suffix
fn: $fullname
nickname: $id
EMAIL;INTERNET: $email
end: vcard
);
    return $vcard_str;
}


sub escape {
	my $str = shift;
	$str =~ s/&/&amp;/g;
	$str =~ s/</&lt;/g;
	return $str;
}

sub generateID{
	my $id  = "";
	my $length = 16;
	
	my $j;
	for(my $i=0 ; $i < $length ;){
		$j = chr(int(rand(127)));

		if($j =~ /[a-zA-Z0-9]/){
			$id .= $j;
			$i++;
		}
	}
	return $id;
}


sub getXML{

#	my $xml = XML::Twig->new(pretty_print => 'indented');
	my $xml = XML::Twig->new();

	my $mani_id = generateID();
	$xml->parse('<manifest identifier="MAN' . $mani_id . '" xmlns="http://www.imsglobal.org/xsd/imscp_v1p1" xmlns:md="http://www.imsglobal.org/xsd/imsmd_v1p2" xmlns:cp="http://www.imsglobal.org/xsd/imscp_v1p1" xmlns:ec="http://cosl.usu.edu/xsd/eduCommonsv1.1" xmlns:tmd="http://'.$TUSK::Constants::Domain.'/xsd/tuskv0p1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.imsglobal.org/xsd/imscp_v1p1  http://www.imsglobal.org/xsd/imscp_v1p2.xsd  http://www.imsglobal.org/xsd/imsmd_v1p2  http://www.imsglobal.org/xsd/imsmd_v1p2p4.xsd 
http://'.$TUSK::Constants::Domain.'/xsd/tuskv0p1 http://'.$TUSK::Constants::Domain.'/xsd/tuskv0p1/tuskv0p1.xsd http://cosl.usu.edu/xsd/eduCommonsv1.1 http://cosl.usu.edu/xsd/educommonsv1.1.xsd"><metadata><lom xmlns="http://www.imsglobal.org/xsd/imsmd_v1p2"></lom></metadata><organizations default="toc001"><organization identifier="toc001"></organization></organizations><resources></resources></manifest>');

	my $xml_root = $xml->root();

	my ($org_root) = $xml_root->descendants('organization');
	my ($lom_root) = $xml_root->descendants('lom');
	my ($md_root) = $xml_root->descendants('metadata');
	my $res_root = $xml_root->first_child('resources');

	my $content = XML::Twig::Elt->new('item', {identifier => 'content'});
	$content->paste(last_child => $org_root);

	my $elt = XML::Twig::Elt->new('title', 'Content');
	$elt->paste(last_child => $content);


	my %xml_hash = ( trunk        => $xml,
	                 content      => $content,
	                 resources    => $res_root,
	                 metadata     => $md_root,
	                 lom          => $lom_root
	               );
	return \%xml_hash;
}

sub exportCourseMetadata{
	my ($course, $start, $end, $xml) = @_;
	exportTitle($course, $xml->{lom});
	exportUsers($course, $xml->{lom});   
	exportObjectives($course, $xml->{lom});
	exportTuskMeta($course, $start, $end, $xml->{metadata});
}


sub isNativeContent{
	my ($c, $valid_users) = @_;

	$c = HSDB4::SQLRow::Content->new->lookup_key($c) unless ref $c;

	# at this point, we are not even exporting external content, but for the 
	# record, we want to indicate that it is always considered "foreign"
	return 0 if ($c->type() eq 'External');

	# array with users of this content; used to determine if this is 'foreignContent'
	my @content_users = $c->child_authors();

	my $count = grep { $valid_users->{$_->primary_key()} } @content_users;

	return $count;
}

sub getCourseUsers{
    my $course = shift;
    my %course_users = ();

    foreach my $user (@{$course->unique_users()}) {
	if (grep { /director|author|lecturer|instructor/ } keys %{$user->{roles}}) {
	    $course_users{$user->{user}->getPrimaryKeyID()} = 1;
	}
    }
    return \%course_users;
}

# determine if this content, which is linked from a document, can be exported.
# if so, pack it up. if not, generate an html message that the content is missing
# and replace the inline call to the content with that.
sub canExport{
	my ($tag, $c_id, $cont_parent, $res_root, $content_chain, $xtra_args) = @_;

	# over-ride some args to make it clear that content exported below is linked from a doc.
	$xtra_args->{isvisible} = 'false';
	$xtra_args->{lnkd_from_doc} = 1;
	$xtra_args->{parent_chain} = $content_chain;

	my $ret_val = exportContent($c_id, $cont_parent, $res_root, $xtra_args);

	# now we need to clear out those args so that they don't mess up the doc itself by the time it
	# is time to generate its item element
	$xtra_args->{isvisible} = 'true';
	delete $xtra_args->{lnkd_from_doc};

	if($ret_val =~ /^<div/){
		return $ret_val;
	}

	return $tag;

}

sub printManifest{
	my ($xml, $tmp_dir) = @_;

	if(open my $fh, '>', "$tmp_dir/imsmanifest.xml"){
		print $fh $xml->{trunk}->sprint();
		close $fh;
		return '';
	}
	else{
		return "could not write imsmanifest.xml: $!\n";
	}

}

# using the course title as a base, generate a name for the content package
sub getPackageName{
	my $title = shift;

	return TUSK::Manage::Course::Import::getRandomFile($export_dir . '/', safe($title) . '-cp', '.zip');
}

# if content linked inline in a document cannot be exported, generate an html
# message that will be placed where the call to the content would have been.
sub missContStr{
	my $c = shift;
	my $type = $c->type();
	my $title = $c->title();
	my $copy = $c->copyright();
	my $return_str = qq(<div class="missingContent" style="margin:10px; padding:5px; border:2px solid orange;">
Missing $type <br/>
Title: $title <br/>
Copyright: $copy
</div>
);

	return $return_str;
}

sub safe {
        my $title = shift || 'Untitled';

        $title =~ s/<.+?>//g;
        $title =~ s/\W+/_/g;
        $title =~ s/^_|_$//g;

        return $title;
}

1;
