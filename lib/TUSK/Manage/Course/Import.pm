#! /usr/bin/perl

package TUSK::Manage::Course::Import;

use strict;

use HSDB4::SQLRow::Content;
use HSDB4::SQLRow::User;
use HSDB45::Course;
use TUSK::Course::CourseMetadataDisplay;
use HSDB4::XML::HSCML;
use HSDB4::XML::Content;
use TUSK::UploadContent;

use Archive::Zip; 
use XML::Twig;
use File::Path;
use File::Copy;
use FindBin qw($Bin);
use lib "$Bin/../lib";
use Data::Dumper;


#############################################
# importCourse will take a TUSK-generated content package, and create a course 
# with the contents of the package. it takes several params that could benefit
# from explanation.

# $cont_pack is the location of a directory that contains the course contents. theoretically,
# it would make sense that this could also be the location of a zip file that is a content package.
# we will need to build in that flexibility when desired.

# $approved_authors is a list of content authors who are both in the course to be 
# imported and in the TUSK system that is importing the course. if user in system and 
# approved, we don't add them, but use their existing record to link content to. 
# if user not in importing system, or in system but not approved, we add user to 
# system with id of _foreign. 

# $user is the user who kicked off the process.
# school_name is the name of the school where the course should be housed.
sub importCourse{
	my ($school_name, $cont_pack, $user, $approved_authors) = @_;

	#####
	# find, open, and parse manifest
	my $twig = XML::Twig->new();
	$twig->parsefile( "$cont_pack/imsmanifest.xml" );

	#####
	# create TUSK course object
	my $course = HSDB45::Course->new(_school => $school_name);

	my $course_title = $twig->findvalue('/manifest/metadata/lom/general/title/langstring[@xml:lang="en"]');

	# in case no course_title
	unless($course_title){
		$course_title = 'PLEASE CHANGE TITLE';
	}
	$course_title .= ' - IMPORT';
	$course->set_field_values( 'title' => $course_title,
	                           'type'  => 'course');
	$course->save();

	my ($manifest) = $twig->get_xpath('/manifest');
	importObjectives($manifest, $course);

	my $course_id = $course->primary_key(); 

	#####
	# retrieve items from mani and start importing into TUSK
	my @item_elts = $twig->get_xpath('/manifest/organizations/organization/item[@identifier="content"]/item');

	my %imported_users;

	if(scalar @$approved_authors){
		foreach my $a (@$approved_authors){
			$imported_users{$a} = $a;
		}
	}

	my $xtra_params = { twig => $twig,
	                    imported_content => {},
	                    imported_users => \%imported_users,
	                    tmp_dir => $cont_pack,
	                    user => $user,
	                  };

	foreach my $i (@item_elts){
		# if item's isvisible attribute is set to false, that means it is in the course ONLY 
		# because it is linked to from within a document. we do not want to import this content
		# here as it will generate a link record... we'll import it below when we regex
		# the doc for all linked content.
		importContent($i, $course, $xtra_params) if isVisible($i);
	}

	return $course;
}


sub importContent{
	my ($item, $parent, $xtra_params) = @_;

	my $id = $item->{'att'}->{'identifierref'};

	#   if we've already imported res_id, don't import again, just make a new link record
	unless($xtra_params->{imported_content}->{$id}){

		(my $resource) = $xtra_params->{twig}->get_xpath('/manifest/resources/resource[@identifier="' . $id . '"]');

		# this is lazy, i know. this library should implement logging.
		# when/if that is implemented, this would be a prime candidate for a message.
		return unless($resource);

		(my $tusk_meta) = $resource->get_xpath('metadata/tom');
		my $c_type = $tusk_meta->first_child_text('tuskType');

		my $file_elt = $resource->first_child('file');
		my $filename = ($file_elt && $c_type !~ /Document/)? $file_elt->{att}->{href} : '';
		my $filepath = ($filename)? $xtra_params->{tmp_dir} . "/$filename" : '';
		
		my $fh;
		open $fh, $filepath if $filepath;

		my %content_data = (
					title          => $resource->findvalue('metadata/lom/general/title/langstring[@xml:lang="en"]'),
					upload_type    => $c_type, 
					content_type   => $c_type, 
					filehandle     => $fh,
					width          => $tusk_meta->findvalue('dimensions/width'),
					height         => $tusk_meta->findvalue('dimensions/height'),
					source         => $tusk_meta->findvalue('source'),
					copyright      => $tusk_meta->findvalue('copyright'),
					sort_order     => 65535,
					read_access    => $tusk_meta->findvalue('readAccess'),
					);

		my $course;
		if($parent->isa('HSDB4::SQLRow::Content')){
			$content_data{parent} = 'content';
			$content_data{content_id} = $parent->primary_key();
			$course = $parent->course();
		}
		else{
			# if content is linked from a doc, we don't want to have a parent
			# of course or content b/c we don't want to have a 
			# link_[course|content]_content record
			$content_data{parent} = 'course' unless $xtra_params->{lnkd_from_doc};
			$course = $parent;
		}

		$content_data{course} = $course->school() . "-" . $course->primary_key();

		if($tusk_meta->findvalue('tuskContributor')){
			$content_data{contributor} =  $tusk_meta->findvalue('tuskContributor');
		}

		if($c_type eq 'URL'){
			$content_data{body} = $resource->{att}->{href};
		}
		elsif($c_type ne 'Document') {
			$content_data{body} = $resource->findvalue('metadata/lom/general/description/langstring');
		}

		if($c_type =~ /Document/){
			my $doc_twig = XML::Twig->new();
			$doc_twig->parsefile( $xtra_params->{tmp_dir} . '/' . $resource->first_child('file')->{att}->{href} );
			my $root = $doc_twig->root();
			my $xml_str = $root->findvalue('/originalXML');

			# if a document contains inline links to content, we want to import linked content with
			# no link_[course|content]_content records. the only identifier we want for this
			# content is the home course.
			$xml_str =~ s/src="\/(.*?)\/(\d+)"/'src="\/' . $1 . '\/' . importFromDoc($2, $course, $xtra_params) . '"'/eg;
			$xml_str =~ s/(\/view\/content\/)(\d+)/$1 . importFromDoc($2, $course, $xtra_params)/eg;
			
			$content_data{body} = $xml_str;
		} 


		my ($file, $rval);
		unless($c_type =~ /Document|Collection|Multidocument|URL/){
			$content_data{file} = $filename;
			($rval, $file->{tempfilename}, $file->{body}, $file->{upload_type}) = TUSK::UploadContent::upload_file(%content_data);
			if ($rval == 0){
				# $log .= "Failed to upload $filepath\n";
				next;
			}
			else {
				$content_data{filename} = $file->{tempfilename};
			}
		}

		my $content_id;
		($rval, $content_id) = TUSK::UploadContent::add_content($xtra_params->{user}, %content_data);

		if ($rval > 0) {
			$xtra_params->{imported_content}->{$id} = $content_id;
		} 
		else {
			# $log .= "Failed to upload $content_id\n";
			next;
		}

		my $c = HSDB4::SQLRow::Content->new->lookup_key($content_id);
		if ($content_data{filename}){
			my ($rval,$msg) = TUSK::UploadContent::do_file_stuff($c, $xtra_params->{user}->primary_key, %content_data);
			unless ($rval > 0){
				# $Log .= "$msg\n";
				next; 
			}
		}

		importUsers($resource, $c, $xtra_params);
		importObjectives($resource, $c);

		if($c_type =~ /Collection|Multidocument/){
			my @children = $item->children('item');
			foreach my $child (@children){
				importContent($child, $c, $xtra_params) if isVisible($child);
			}
		}
	}
	elsif(! exists $xtra_params->{lnkd_from_doc}) {
		# if content already imported, but present in package again, we don't want 
		# to re-import, but create a new link record to the imported content.
		# unless, this content is linked from a document, in which case we don't 
		# want to create a link record at all
		$parent->add_child_content($TUSK::Constants::DatabaseUsers->{ContentManager}->{writeusername}, $TUSK::Constants::DatabaseUsers->{ContentManager}->{writepassword}, $xtra_params->{imported_content}->{$id}, 65535);
	}

	return $xtra_params->{imported_content}->{$id};
}



sub importUsers{
	my ($resource, $content, $xtra_params) = @_;

	my @authors = $resource->get_xpath('metadata/lom/lifecycle/contribute/centity');

	my $counter = 0;
	foreach my $a (@authors){
		my $vcard = unpackVcard($a->findvalue('vcard'));

		if(defined $vcard && exists $vcard->{nickname}){
			my $id = $vcard->{nickname};

			# make sure that we don't import a user more than once
			# this has is primed with any users that were already found in system,
			# and approved by user on import as valid users
			unless(defined $xtra_params->{imported_users}->{$id}){

				my $iter = 0;
				my ($new_id, $test_obj);
				my $user = HSDB4::SQLRow::User->new();
				do{
					$new_id = $id . '_foreign';
					$new_id .= ($iter == 0)? '' : sprintf('%02d',$iter);
					$test_obj = $user->lookup_key($new_id);
					$iter++;
				}while($test_obj->primary_key);

				$user->primary_key($new_id);

				my @name_parts = split(/;/, $vcard->{n});
				$user->set_field_values(
				            status => 'inactive',
				            email => $vcard->{'EMAIL;INTERNET'},
				            lastname => $name_parts[0],
				            firstname => $name_parts[1],
				            midname => $name_parts[2],
				                       );

				$user->save($TUSK::Constants::DatabaseUsers->{ContentManager}->{writeusername}, $TUSK::Constants::DatabaseUsers->{ContentManager}->{writepassword});
				
				$xtra_params->{imported_users}->{$id} = $new_id;
			}
			
			my ($rval, $msg) = $content->add_child_user($TUSK::Constants::DatabaseUsers->{ContentManager}->{writeusername}, $TUSK::Constants::DatabaseUsers->{ContentManager}->{writepassword}, $xtra_params->{imported_users}->{$id}, 10*(++$counter), 'author');
			# $log .= "$msg\n" unless (defined($rval));
		}
	}
}

sub unpackVcard{
	my $vcard_txt = shift;
	
	my @lines = split(/\n/, $vcard_txt);
	my $vcard_obj;
	foreach my $l (@lines){
		my ($id_part, $value) = split(/:\s/, $l);
		unless($value eq 'vcard'){
			$vcard_obj->{$id_part} = $value;
		}
	}

	return $vcard_obj;
}

sub importObjectives{
	my $resource = shift; # can be either a resource or course
	my $c = shift;        # can be content or course object

	my @possible_objs = $resource->get_xpath('metadata/lom/classification');
	my @objectives;
		
	foreach my $testit (@possible_objs){
		if($testit->get_xpath('purpose/value/langstring[string() = "Educational Objective"]')){
			push @objectives, $testit->findvalue('description/langstring');
		}
	}

	my $counter = 0;
	foreach my $obj_str (@objectives){
		my $tmp_obj = $obj_str;
		# don't let single quotes break in the lookup
		$tmp_obj =~ s|\\*'|\\'|g;
		my ($objective) = HSDB4::SQLRow::Objective->new()->lookup_conditions("body='$tmp_obj'");

		my ($rval, $msg);
		unless(defined $objective){
			$objective = HSDB4::SQLRow::Objective->new();
			$objective->field_value(body => $obj_str);
			($rval, $msg) = $objective->save($TUSK::Constants::DatabaseUsers->{ContentManager}->{writeusername},$TUSK::Constants::DatabaseUsers->{ContentManager}->{writepassword});
		}

		unless(defined $rval && $rval == 0){
			$counter++;
			$c->add_child_objective($TUSK::Constants::DatabaseUsers->{ContentManager}->{writeusername}, $TUSK::Constants::DatabaseUsers->{ContentManager}->{writepassword}, $objective->primary_key(), ($counter*10));
		}
	}
}

sub getItem{
	my ($id, $twig) = @_;
	(my $item) = $twig->get_xpath('/manifest/organizations/organization/item[@identifier="content"]//item[@identifierref="res' . $id . '"]');
	return $item;
}

sub genTmpDir{
	my ($path, $seed) = @_;

	my $tmp_dir = getRandomFile($path, $seed);

	eval { mkpath($tmp_dir, 0, 0775) };
	if($@){
		die "couldn't create directory $tmp_dir: $@\n";
	}
	else{
		return $tmp_dir;
	}
}

sub unzip{
	my $cont_pack = shift;

	my $tmp_dir = genTmpDir('/data/temp/', 'unpacked_');

	$ENV{PATH} = '/bin:/usr/bin';

	system "unzip -qq -o $cont_pack -d $tmp_dir";
	
	return $tmp_dir;
}

sub getManifest{
	my $locale = shift;

	#####
	# find, open, and parse manifest
	my $twig = XML::Twig->new();
	$twig->parsefile( "$locale/imsmanifest.xml" );

	return $twig;
}

sub getNativeUsers{
	my $tmp_dir = shift;

	my $manifest = getManifest($tmp_dir);
	
	my @users = $manifest->get_xpath('//vcard');

	my @native_users;
	my %course_users;

	foreach my $u (@users){
		my $vcard = unpackVcard($u->text);
		if($vcard->{nickname}){
			unless($course_users{$vcard->{nickname}}){
				$course_users{$vcard->{nickname}} = 1;
				my $user = HSDB4::SQLRow::User->new->lookup_key($vcard->{nickname});
				if($user->primary_key()){
					push @native_users, $user->primary_key;
				}
			}
		}
	}

	return \@native_users;
}

sub isVisible {
	my $item = shift;

	if($item->{'att'}->{'isvisible'} eq 'false'){
		return 0;
	}
	else {
		return 1;
	}
}

sub importFromDoc {
	my ($c_id, $course, $xtra_params) = @_;

	my $item = getItem($c_id, $xtra_params->{twig});

	$xtra_params->{lnkd_from_doc} = 1;

	my $new_id = importContent($item, $course, $xtra_params);

	delete $xtra_params->{lnkd_from_doc};

	return $new_id;
}

sub getRandomFile {
	my ($path, $fileseed, $suffix) = @_;

	my $fn;
	do{
		my $randnum = int(rand(10000));
		$fn = "$path$fileseed$randnum$suffix";
	} while(-e $fn);
	
	return $fn;
}

return 1;
