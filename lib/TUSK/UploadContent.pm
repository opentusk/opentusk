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


package TUSK::UploadContent;

use strict;

use HSDB4::SQLRow::Content;
use HSDB4::SQLRow::PPTUpload;
use HSDB4::Constants;
use TUSK::Constants;
use TUSK::Core::LinkContentKeyword;
use TUSK::Content::External::LinkContentField;
use TUSK::Content::External::Field;
use TUSK::ProcessTracker::ProcessTracker;
use File::Copy;
use File::Type;
use IO::File;
use DBI qw(:sql_types);

my $pw = $TUSK::Constants::DatabaseUsers{ContentManager}->{writepassword};
my $un = $TUSK::Constants::DatabaseUsers{ContentManager}->{writeusername};

my $CHUNK_SIZE = 32768; # for calls to 'read' 
our %path = (
		'downloadablefile'=> $TUSK::Constants::BaseStaticPath . '/downloadable_file',
		'shockwave' => $TUSK::Constants::BaseStaticPath . '/downloadable_file',
		'flashpix' => $TUSK::Constants::BaseStreamPath . '/flashpix/',
		'pdf' => $TUSK::Constants::BaseStaticPath . '/web-auth/pdf',
		'ppt' => $TUSK::Constants::BasePPTPath . '/native',
		'doc' => $TUSK::Constants::BaseTUSKDocPath . '/native',
		'doc-archive' => $TUSK::Constants::BaseTUSKDocPath . '/native-archive',
		'doc-processed' => $TUSK::Constants::BaseTUSKDocPath . '/processed',
		'video' => $TUSK::Constants::BaseStreamPath . '/video',
		'audio' => $TUSK::Constants::BaseStreamPath . '/video',
		'temp' => $TUSK::Constants::TempPath,
		'slide' => $TUSK::Constants::BaseStaticPath . '/slide',
	    );

our %fileTypes = (
		'htm' => 'Document',
		'html'=> 'Document',
		'pdf' => 'PDF',
		'jpg' => 'Slide',
		'jpeg' => 'Slide',
		'gif' => 'Slide',
		'png' => 'Slide',
		'swf' => 'Shockwave',
		'flv' => 'Shockwave',
		'dcr' => 'Shockwave',
		'fpx' => 'Flashpix',
		'mov' => 'Video',
		'avi' => 'Video',
		'mpa' => 'Video',
		'mpg' => 'Video',
		'mpeg'=> 'Video',
		'mpv' => 'Video',
		'm2v' => 'Video',
		'm1v' => 'Video',
		'mp3' => 'Audio',
		'mp4' => 'Video',
		'rm'  => 'Video',
		'rmvb'=> 'Video',
		'rv'  => 'Video',
		'ra'  => 'Audio',
		'rmvb'=> 'Video',
		'smi' => 'Video',
		'mod' => 'Video',
		'url' => 'URL',
		'wmv' => 'Video',
		'wma' => 'Audio',
	);

sub process_args_for_content_sub{
	my($req, $args) = @_;
	if ($args->{parent_content} && $args->{parent_content}->primary_key()){
		$req->{parent_content} = $args->{parent_content};
		$args->{course} = $args->{parent_content}->school() . "-" . $args->{parent_content}->field_value('course_id');
		$req->{school} = $args->{parent_content}->school();
		$req->{course} = HSDB45::Course->new( _school => $req->{school} )->lookup_key( $args->{parent_content}->field_value('course_id') );
		$req->{course_id} = $req->{course}->primary_key();
	} elsif ($args->{course}){
		$req->{course} = $args->{course};
		$req->{root_course} = $args->{course};
		unless($req->{school}) {$req->{school} = $req->{course}->school();}
		unless($req->{course_id}) {$req->{course_id} = $req->{course}->primary_key();}
	} else {
		$req->{school} = $req->{course}->school();
		$req->{course_id} = $req->{course}->primary_key();
		$req->{root_course} = $req->{course};
	}

	delete($args->{start_date}) unless ($args->{start_date});
	delete($args->{end_date}) unless ($args->{end_date});
}

sub add_content_sub{
    my ($req, %fdat) = @_;
    process_args_for_content_sub($req, \%fdat);
    my ($rval, $msg);

    if ($req->{course}){
	$fdat{course}=$req->{school}."-".$req->{course_id};
    }else{
	$fdat{course} = $req->{content}->field_value('school') . "-" . $req->{content}->field_value('course_id') unless ($fdat{course});
    }

    if ($req->{parent_content}){
	$fdat{parent}="content";
	$fdat{content_id}=$req->{parent_content}->primary_key;
    }elsif ($req->{course_id}){
	$fdat{parent}="course";
    }
    
    $fdat{school}=$req->{school};

    $fdat{filename} =~ s/$path{'temp'}//;
    unless (-e $path{'temp'} . "/" . $fdat{filename}) {
	warn("Unable to create content because " . $path{'temp'} . "/" . $fdat{filename} . " does not exist\n");
	return (0, "The file could not be found.  Please try to upload again.");
    }
    ($rval, $req->{content_id}) = add_content($req->{user}, %fdat);
    return ($rval, $req->{content_id}) unless ($rval > 0);
    
    $req->{content}=HSDB4::SQLRow::Content->new->lookup_key($req->{content_id});
    $req->{selfpath}.="/".$req->{content_id};
    
    if ($fdat{filename}){
	($rval,$msg) = do_file_stuff($req->{content}, $req->{user}->primary_key, %fdat);
	return ($rval, $msg) unless ($rval > 0);
    }

    # do common actions
    ($rval, $msg) = common_actions($req->{user}, $req->{content}, $req->{course}, $req->{root_course}, %fdat);
    return (0, $msg) unless (defined($rval));
    
    return(1,"Content successfully added", $req->{content});
}

sub update_content_sub{
    my ($req, %fdat) = @_;

    process_args_for_content_sub($req, \%fdat);
    my ($rval, $msg);

    # first we will do an update to the link_course_user stuff (sort and roles)

    ($rval, $msg) = update_html($req->{content}, $req->{user}->primary_key, %fdat);
    return (0, $msg) unless ($rval > 0);

    ($rval, $msg) = update_content($req->{content}, $req->{user}->primary_key, %fdat);
    return (0, $msg) unless ($rval > 0);
    
    ($rval, $msg) = $req->{content}->save_version("Content updated by CMS", $req->{user}->primary_key);
    return (0, $msg) unless ($rval > 0);

    # do common actions
    ($rval, $msg) = common_actions($req->{user}, $req->{content}, $req->{course}, $req->{root_course}, %fdat);
    return (0, $msg) unless ($rval > 0);

    return(1,"Content successfully updated", $req->{content});
}

sub common_actions{
    my ($user, $content, $course, $root_course, %fdat) = @_;
    my ($rval, $msg, $data, @split, $struct);

    foreach my $key (keys %fdat){
	if ($key =~/^(keywordsdiv|authorsdiv|objectivesdiv|reuseauthorsdiv|meetingsdiv)/){
	    @split = split("__", $key);
	    $split[0]=~s/div//;
	    $struct->{$split[0]}[$split[3]]->{pk} = $split[1];
	    $struct->{$split[0]}[$split[3]]->{$split[2]} = $fdat{$key};
	}
    }

    # update the keywords for this content
#    my @keywords = map { TUSK::Core::Keyword->lookupKey($_->{pk}) } @{$struct->{keywords}};
#    ($rval, $msg) = update_keywords($content, \@keywords,$struct->{keywords},$user );
#    return (0, $msg) unless ($rval > 0);

    # update the objectives for this content
    ($rval, $msg) = update_objectives($content, $struct->{objectives});
    return (0, $msg) unless ($rval > 0);

    # update the users for this content
    if ($content and $content->field_value('reuse_content_id')){
	($rval, $msg) = update_users($content, $struct->{reuseauthors});
    }else{
	($rval, $msg) = update_users($content, $struct->{authors});
    }
    return (0, $msg) unless ($rval > 0);
   
    if ($fdat{ppt_change}){
	($rval, $msg) = ppt_process($user, $content, %fdat);
	return (0, $msg) unless ($rval > 0);
	if ($fdat{ppt_change} == 2){
	    ($rval, $msg) = save_ppt_file($content, $struct->{authors}, \%fdat, $user);
	    return (0, $msg) unless ($rval > 0);
	}
    }
    
    if ($fdat{doc_change}){
		($rval, $msg) = doc_process($user, $content, %fdat);
		return (0, $msg) unless ($rval > 0);
    }
    if ($fdat{real_change}){
	($rval,$msg) = real_process($content, $user->primary_key, %fdat);
        return (0,$msg) unless ($rval > 0);
    }

	# update the subcourses if it's an integrated course
	# Need to do this last in case it's new content, since we need a content id
	if ( $root_course && $root_course->isa( "HSDB45::Course" ) && ($root_course->type eq 'integrated course') ) { 
		# Create link_course_content record for subcourse <-> content
		my $course_link  = $root_course->content_link;
		my $content_link = $content->content_link;

		if ( $fdat{'originating_course'} ) {
			my $new_orig_course = HSDB45::Course->new( _school => $root_course->school )->lookup_key( $fdat{'originating_course'} );
			my $integrated_course_link = TUSK::Core::LinkIntegratedCourseContent->new()->lookupByRelation( $root_course->getTuskCourseID(), $content->content_id );
			if ( $integrated_course_link ) {
				$integrated_course_link->setOriginatingCourseID( $new_orig_course->getTuskCourseID() );
				$integrated_course_link->save();
			} else {
				$integrated_course_link = TUSK::Core::LinkIntegratedCourseContent->new();
				$integrated_course_link->setParentIntegratedCourseID( $root_course->getTuskCourseID() );
				$integrated_course_link->setChildContentID( $content->content_id );
				$integrated_course_link->setOriginatingCourseID( $new_orig_course->getTuskCourseID() );
				$integrated_course_link->save();
			}
		}

		my $ids     = ();
		foreach ( @{$root_course->get_subcourses()} ) {
			push @{$ids}, $_->course_id;
		}

		my $update = 1;
		my @other_parents = $content->root_parents();
		foreach ( @other_parents ) {
			if ( $fdat{'originating_course'} == $_->course_id ) {
				$update = 0;
				last;
			}
		}

		if ( $update ) {
			foreach my $o_parent ( @other_parents ) { 
				if ( $o_parent->isa( "HSDB45::Course" ) ) { 
					if (grep {$_ == $o_parent->course_id} @{$ids}) {
						$course_link->delete( '-parent_id', $o_parent->course_id, '-child_id', $content->content_id );

						# Need to fake out the cache since we're modifying the source of the data and the cache is used further down the page.
						@{$content->{-parent_courses}} = grep { $_ != $o_parent } @{$content->{-parent_courses}};
					}
				} elsif ( $o_parent->isa( "HSDB4::SQLRow::Content::Collection" ) ) { 
					if (grep {$_ == $o_parent->course->course_id} @{$ids}) {
						$content_link->delete( '-parent_id', $o_parent->content_id, '-child_id', $content->content_id );
					}
				}
			}

			# Call this to refresh the cache after the deletions.
			$content->parent_content(1);

			if ( $fdat{'originating_course'} ) {
				$course_link->insert( 
					-child_id  => $content->content_id,
					-parent_id => $fdat{'originating_course'} );

				# Need to fake out the cache since we're modifying the source of the data and the cache is used further down the page.
				push @{$content->{-parent_courses}}, HSDB45::Course->new( _school => $root_course->school )->lookup_key( $fdat{'originating_course'} );
			}
		}
	}

	# update the class meeting associations
	# Need to do this last in case it's new content, since we need a content id
	# And, if it's not in the context of a course, don't bother with class_meeting linkage
	($rval, $msg) = update_meetings($content, $course, $struct->{meetings}) if $fdat{'is_a_course'};
	return (0, $msg) unless ($rval > 0);

    return 1;
}

sub save_ppt_file{
    my ($parent_content, $authors, $fdat, $user) = @_;
    my ($rval, $msg, $body);

    my $ppt_content = HSDB4::SQLRow::Content->new;
    my @time = localtime;
    $ppt_content->set_field_values(   type => 'DownloadableFile',
				      title => $parent_content->field_value('title'),
				      school => $parent_content->field_value('school'),
				      style => $parent_content->field_value('style'),
				      course_id => $parent_content->field_value('course_id'),
				      copyright => $parent_content->field_value('copyright'),
				      system => $parent_content->field_value('system'),
				      source => $parent_content->field_value('source'),
				      write_access => $parent_content->field_value('write_access'),
				      read_access => $parent_content->field_value('read_access'),
				      display => $parent_content->field_value('display'),
				      start_date => $parent_content->field_value('start_date'),
				      end_date => $parent_content->field_value('end_date'),
				      conversion_status => $parent_content->field_value('conversion_status'),
				      created => sprintf ("%d-%d-%d %d:%d:%d", $time[5]+1900, $time[4]+1, $time[3], $time[2], $time[1], $time[0])
				      );

    $ppt_content->save_version("Pre-process", $user->primary_key);

    ($rval, $body) = move_file($ppt_content, $fdat, $path{downloadablefile},"file_uri");
    return (0, $body) unless ($rval);

    $ppt_content->set_field_values(body => $body);

    $ppt_content->save_version("Created content",$user->primary_key);
    
    $parent_content->add_child_content ($un, $pw, $ppt_content->primary_key, 1);

    # update the users for this content
    ($rval, $msg) = update_users($ppt_content, $authors);
    return (0, $msg) unless ($rval > 0);

    return (1);
}

sub real_process{
    my ($content, $user_id, %fdat) = @_;
    my ($rval, $msg);

    return 1 if ($content->type() eq $fdat{real_change}); # make sure there is a change

    $content->set_field_values("type" => $fdat{real_change});

    ($rval, $msg) = $content->save_version("Updated type",$user_id);
    if ($msg){
        return (0, $msg);
    }
    return 1;
}

sub replace_file{
    my ($content, $user_id, %fdat) = @_;
    my ($rval, $msg);

	if ($content->type() eq 'TUSKdoc') {
		my $tracker = TUSK::ProcessTracker::ProcessTracker->getMostRecentTracker(undef, $content->primary_key, 'tuskdoc');
		return (0, "Cannot replace this TUSKdoc because it is already in the process of being converted.") if (defined $tracker && !$tracker->isCompleted());
	}
	
    # upload the file
    ($rval, $fdat{filename}, $fdat{body}) = upload_file(%fdat);
    return (0, $fdat{filename}) unless ($rval > 0);

    # do some file stuff
    ($rval, $msg) = do_file_stuff($content, $user_id, %fdat);
    return (0, $msg) unless ($rval > 0);

    return 1, "File changed";
}

sub update_users{
    my ($content, $authors) = @_;
    my ($rval, $msg, $authorid);
    my %current_users; # used to make sure we dont try to add duplicate users
    my $count = 0;

    $content->delete_child_users($un, $pw);
    if ($authors){
	for (my $i=0; $i<scalar(@$authors); $i++){
	    $authorid = @{$authors}[$i]->{pk};
	    next if ($current_users{$authorid});
	    $current_users{$authorid} = 1; # make sure the list contains unique users
	    
	    my $newauthor=HSDB4::SQLRow::User->new->lookup_key($authorid);
	    if ($newauthor->primary_key){
		($rval, $msg) = $content->add_child_user($un, $pw, $authorid, 10*($i + 1), @{$authors}[$i]->{role});
		return (0, $msg) unless (defined($rval));
	    }
	}
    }
    return 1;
}

sub add_content{
	my ($user, %fdat) = @_;
	my ($rval, $msg);

	# body and data ids all depend on type of document
	my $content = HSDB4::SQLRow::Content->new;
	my $body = "";

	# ok, upload 
	($fdat{school},$fdat{course_id}) = split ('-', $fdat{course});
	
	if ($fdat{copy_content_data}){
	    my $old_content = HSDB4::SQLRow::Content->new->lookup_key($fdat{copy_content_data});
	    return (0,"Please supply a content_id to copy.") unless ($old_content);
	    $fdat{content_type}="Reuse";
	    $fdat{title}=$old_content->field_value('title');
	    $fdat{write_access}=$old_content->field_value('write_access');
	    $fdat{read_access}=$old_content->field_value('read_access');
	    $fdat{display} = $old_content->field_value('display');
	    $content->field_value('reuse_content_id', $old_content->primary_key);
	}else{
	    # make an entry in the right content table
	    $fdat{title} = $fdat{title} || 'Untitled';
	    $fdat{style} = $fdat{style} || 'hsdb4-style';
	    $fdat{system} = join (',', split (/\t/, $fdat{system})) if ($fdat{system});
	}

	$fdat{display} = 0 unless ($fdat{display});

	my @time = localtime;
	$content->set_field_values(
				   type => $fdat{content_type},
				   body => $body,
				   hscml_body => $fdat{hscml_body},
				   title => $fdat{title},
				   school => $fdat{school},
				   style => $fdat{style},
				   course_id => $fdat{course_id},
				   copyright => $fdat{copyright},
				   system => $fdat{system},
				   source => $fdat{source},
				   write_access => 'All authors',
				   read_access => $fdat{read_access},
				   display => $fdat{display},
				   start_date => $fdat{start_date},
				   end_date => $fdat{end_date},
				   conversion_status => $fdat{conversion_status},
				   created => sprintf ("%d-%d-%d %d:%d:%d", $time[5]+1900, $time[4]+1, $time[3], $time[2], $time[1], $time[0]),
				   );


#warn("Going to call the update_html\n");
	($rval, $msg) = update_html($content, $user->primary_key,%fdat);
	return (0, $msg) unless ($rval > 0);
#warn("After the update_html the body is ". $content->body->out_xml() ."\n");

#warn("Saving the version\n");
	($rval, $msg) = $content->save_version("content added by CMS",$user->primary_key);
#warn("After the save version the body is ". $content->body->out_xml() ."\n");
	return (0, $msg) unless ($rval > 0);

	return (0, 'An unkown error has occured. Please try again.') unless ($content->primary_key);
	
	# Make a link from something to this content?
	if ($fdat{'parent'} eq "course"){
		($rval, $msg) = add_course_content($user, $content, %fdat);
		return(0, $msg) unless ($rval>0);
	} elsif ($fdat{'parent'} eq "content"){
		($rval, $msg ) = add_content_content($user, $content, %fdat);
		return(0, $msg) unless ($rval>0);
	}
#warn("After the link from parent the body is ". $content->body->out_xml() ."\n");

	return (1, $content->primary_key);
}
# This is Paul Silevitch's code, adapted for the integrated content upload
# tool.
sub ppt_process{
	my ($user, $content, %fdat) = @_;
	my $body=$content->body;
	$body->in_fdat_hash ('content_body:0:file_uri' => "");
	
	$fdat{body}=$body->out_xml;

	# the upload type changes
	$fdat{content_type} = "Collection";

	$content->set_field_values(type=>"Collection", body=>$fdat{body}, title=> $fdat{title} . " - Lecture Slides");

	my ($rval, $msg) = $content->save_version("content updated", $user->primary_key);
	return(0,$msg) unless ($rval>0);

	my $filename = $content->primary_key."\.ppt";

	my $ppt_name = sprintf ("%s-%s-%s", $user->primary_key,
		$content->primary_key, time());

	my $ppt = HSDB4::SQLRow::PPTUpload->new;

	my @authors = $content->child_authors;
	
	my $first_author;

	# if no author, take the first linked user
	if(@authors){
	    $first_author = $authors[0]->primary_key;
	}else{
	    $first_author = "";
	}

	
	# XXX: I suspect a lot of these fields are not needed, since the 'parent'
	# collection has already been created... 
	$ppt->set_field_values(course_id => $content->field_value('course_id'),
		username => $user->primary_key,
		school => $content->field_value('school'),
		copyright => $fdat{'copyright'},
		status => 'Uploaded',
		author => $first_author,
		title => $fdat{'title'},
		content_id => $content->primary_key,
	);
	($rval, $msg) = $ppt->save($un,$pw);

	return (1, $msg);
}

sub doc_process{
    my ($user, $content, %fdat) = @_;
    $content->field_value('type', 'TUSKdoc');
    $content->save_version("content turned into TUSKdoc type", $user->primary_key);
	$content = $content->rebless();

    return (1, "Success");
}


sub update_html{
    my ($content, $user_id, %fdat) = @_;
    my ($body, $rval, $msg);
    
    $body =~ s/\&shy;//g;

    if (exists($fdat{contributor}) and $content->field_value('reuse_content_id') == 0){
        ($rval, $msg) = mangle_element($content, $fdat{contributor},"contributor");
        return (0, $msg) if ($rval == 0);
    }
    
    return 1 if ($fdat{content_type} eq "PDF" or $fdat{content_type} eq "DownloadableFile");

    if ($fdat{content_type} eq "Slide" and $content->field_value('reuse_content_id') == 0){
       
        my $body = $content->body;
	return (0,$content->error()) if (!$body);
        my ($info) = $body->tag_values('slide_info') ;
        unless ($info){
            $info = HSDB4::XML::Content->new('slide_info');
            $body->xml_insert(0, $info);
        }

        my ($stain) = $info->tag_values('stain');
        unless ($stain){
            $stain = HSDB4::XML::SimpleElement->new(-tag => 'stain',
                                                    -label => 'Stain');
            $info->xml_push($stain);
        }

        $stain->set_value($fdat{stain});

        $content->field_value('body', $body->out_xml);
    }

    if ($fdat{content_type} eq "Shockwave"){
	($rval, $msg) = mangle_shockwave($content, %fdat);
	return (0, $msg) if ($rval == 0);	    
    } elsif ($fdat{content_type} eq "Video" or $fdat{content_type} eq "Audio"){
	($rval, $msg) = mangle_audiovideo($content, %fdat);
	return (0, $msg) if ($rval == 0);
    } elsif ($fdat{content_type} eq "External"){
	unless ($content->primary_key()){
	    my $fields = TUSK::Content::External::Field->new()->lookup('source_id = ' . $fdat{source_id});
	    $content->save('pre-Save needed for external content', $user_id);
	    
	    foreach my $field (@$fields){
		my $link = TUSK::Content::External::LinkContentField->new();
		$link->setParentContentID($content->primary_key());
		$link->setChildFieldID($field->getPrimaryKeyID());
		$link->setValue($fdat{ 'external_content_field_' . $link->getChildFieldID() });
		$link->save({ user => $user_id });
	    }
	}
    } elsif ($fdat{content_type} eq "URL"){
#warn("The content_type is URL with body of ". $fdat{'body'} ."\n");
	$fdat{'body'}="http://".$fdat{'body'} unless($fdat{'body'}=~/^(\/|[A-Za-z]+:\/\/)/);
#warn("after the sub the body is ". $fdat{'body'} ."\n");
	($rval, $msg) = mangle_element($content, $fdat{'body'},"external_uri");
#warn("The value from mangle_element is $rval: $msg\n");
	return (0, $msg) if ($rval == 0);
    } elsif (exists($fdat{body})){
	($rval, $msg) = mangle_element($content, $fdat{body},"html");
	return (0, $msg) if ($rval == 0);
    }

    return 1;

}

sub do_file_stuff{
    my ($content, $user_id, %fdat) = @_;
    my ($body, $rval, $msg);
    return 1 unless ($fdat{filename});

	if ($fdat{content_type} eq "Document"){
		($rval, $body) = mangle_element($content, $fdat{body}, "html");
		return (0, $body) if ($rval == 0);
    }elsif ($fdat{content_type} eq "URL"){
		($rval, $body) = move_file($content, \%fdat,$path{pdf},"external_uri");
		return (0, $body) if ($rval == 0);
    }elsif ($fdat{content_type} eq "PDF"){
		($rval, $body) = move_file($content, \%fdat,$path{pdf},"pdf_uri");
		return (0, $body) if ($rval == 0);
    }elsif ($fdat{doc_change} > 0 or $fdat{content_type} eq 'TUSKdoc'){
        ($rval, $body) = move_file($content, \%fdat, $path{doc});
		return (0, $body) unless ($rval);
        ($rval, $body) = move_file($content, \%fdat, $path{'doc-archive'});
		return (0, $body) unless ($rval);
		my $tracker = TUSK::ProcessTracker::ProcessTracker->new();
		$tracker->setObjectID($content->primary_key());
		$tracker->setTrackerType('tuskdoc');
		$tracker->setStatus('tuskdoc_received');
		$tracker->save({user => $user_id});
    }elsif ($fdat{content_type} eq 'DownloadableFile' and $fdat{ppt_change} < 1){
        ($rval, $body) = move_file($content, \%fdat,$path{downloadablefile},"file_uri");
		return (0, $body) unless ($rval);
    }elsif ($fdat{ppt_change} > 0){
        ($rval, $body) = move_file($content, \%fdat, $path{ppt},"file_uri");
		return (0, $body) unless ($rval);
    }elsif ($fdat{content_type} eq 'Shockwave'){
		($rval, $body) = move_file($content, \%fdat,$path{shockwave},"shockwave_uri");
		return (0, $body) unless ($rval);
    }elsif ($fdat{content_type} eq 'Flashpix'){
		($rval, $body) = move_file($content, \%fdat,$path{flashpix},"flashpix_uri");
		return (0, $body) unless ($rval);
    }elsif ($fdat{content_type} eq 'Video' or $fdat{content_type} eq 'Audio'){
		($rval, $body) = move_file($content, \%fdat,$path{video},"realvideo_uri");
		return (0, $body) unless ($rval);
    }elsif ($fdat{content_type} eq 'Slide'){
		unless (-e $path{'temp'} . "/" . $fdat{filename}){
			return(0, "The file could not be found.");
		}
		open(IMG, $path{'temp'}."/".$fdat{filename});
		binmode(IMG);

		my ($buffer, $blob);
		while (my $bytesread = read(IMG, $buffer, $CHUNK_SIZE)){
			$blob .= $buffer;
		}
		close(IMG);
		my $ft = File::Type->new();
		my $type = $ft->mime_type($blob);

		$type =~s/^.*?\///;
		$content->generate_image_sizes( -path => $path{slide}, -blob => $blob, -type=>$type );
    }

    $content->set_field_values("body" => $body);

    ($rval, $msg) = $content->save_version("Updated body",$user_id);
    if ($msg){
	return (0, $msg);
    }
    return 1;
}

sub update_content{
	my ($content, $user_id, %fdat) = @_;
	my ($rval, $msg);

	my $ctype = $content->field_value('type');
	$fdat{system} = join (',', split(/\t/,$fdat{system})) if ($fdat{system});

	if(($fdat{content_type} eq "Collection") or ($fdat{content_type} eq "Multidocument")){
	    $content->set_field_values("type" => $fdat{folderformat});
	    $fdat{content_type} = $fdat{folderformat};
	}
	    
	$fdat{'display'} = 0 unless ($fdat{'display'});
	$content->set_field_values("read_access" => $fdat{'read_access'}, "display" => $fdat{display});

	if ($content->field_value('reuse_content_id') == 0 or $content->field_value('type') ne "Document"){
	    $content->set_field_values("title" => $fdat{'title'});
	}
	
	unless ($content->field_value('reuse_content_id')){
	    $content->set_field_values(
				       "system" => $fdat{'system'},
				       "source" => $fdat{'source'},
				       "start_date" => $fdat{'start_date'},
				       "end_date" => $fdat{'end_date'},
				       "copyright" => $fdat{'copyright'},
				       );
	}

	if ($content->type eq "Collection"){
	    my @child_contents = $content->child_content();
	    foreach my $child_content (@child_contents){
		next if ($child_content->type() eq "Collection");
		$child_content->set_field_values(
						 "read_access" => $fdat{'read_access'},
						 "display" => $fdat{'display'},
						 "start_date" => $fdat{'start_date'},
						 "end_date" => $fdat{'end_date'},
						 );
		$child_content->save($un, $pw);
	    }
	}

	if ($content->type eq "External") {
	    if ($fdat{source_id}) {
		my $fields = TUSK::Content::External::Field->lookup("source_id = $fdat{source_id} AND required = 'N'");

		foreach my $field (@$fields) {
		    my $link = TUSK::Content::External::LinkContentField->new();
		    my $existing_link = $link->lookupReturnOne('parent_content_id = ' . $content->primary_key() . ' AND child_field_id = ' . $field->getPrimaryKeyID());

		    if ($existing_link) {
			$existing_link->setValue($fdat{'external_content_field_' . $existing_link->getChildFieldID()});
			$existing_link->save({ user => $user_id });
		    } else {
			$link->setParentContentID($content->primary_key());
			$link->setChildFieldID($field->getPrimaryKeyID());
			$link->setValue($fdat{'external_content_field_' . $field->getPrimaryKeyID()});
			$link->save({ user => $user_id });
		    }
		}
	    } 
	}

	return 1;
}

sub update_meetings{
    my ($content, $course, $meetings) = @_;
    my ($rval, $msg);

	my @existing_meetings = $content->parent_class_meetings();

	my @course_ids;
	if ( $course->type eq 'integrated course' ) {
		foreach ( @{$course->get_subcourses} ) {
			push @course_ids, $_->course_id;
		}
	}
	push @course_ids, $course->course_id;

	if ($meetings && scalar(@$meetings)) {
		foreach my $meeting_data (@$meetings) {
			my $meeting = HSDB45::ClassMeeting->new( _school => $content->school )->lookup_key( $meeting_data->{'pk'} );
			my $child_content = $meeting->child_content( 'child_content_id = ' . $content->content_id );

			if ($child_content) {
				# Find the meeting and remove it from the list.
				# Anything that's left at the end will be removed from the database.
				my $index = 0;
				while ($index < scalar(@existing_meetings)) {
					if ( ($existing_meetings[$index]->class_meeting_id == $meeting_data->{'pk'}) ||
						 (!(grep {$_ eq $existing_meetings[$index]->course_id} @course_ids)) ) {
						splice(@existing_meetings, $index, 1);
					} else {
						$index++;
					}
				}
				next;
			}

			$meeting->add_child_content( {'content_id' => $content->content_id, 'class_meeting_content_type_id' => 0} );
		}
	}
	
	foreach my $existing_meeting ( @existing_meetings ) {
		my $meeting = HSDB45::ClassMeeting->new( _school => $content->school )->lookup_key( $existing_meeting->{'class_meeting_id'} );

		if (grep {$_ eq $existing_meeting->course_id} @course_ids) {
			$meeting->delete_child_content( $content->content_id );
		}
	}

	return 1;
}

sub update_objectives{
    my ($content, $objectives) = @_;
    my ($rval, $msg);
    
    ($rval, $msg) = $content->delete_objectives($un, $pw);
    return (0,$msg) unless (defined($rval));

    if ($objectives and scalar(@$objectives)){
	for(my $i=0; $i<scalar(@$objectives); $i++){
		unless (@$objectives[$i]->{pk}){
		    my $objective = HSDB4::SQLRow::Objective->new;
		    $objective->set_field_values(body => @$objectives[$i]->{body});
		    ($rval, $msg) = $objective->save($un,$pw);
		    return (0, $msg) unless ($rval > 0);
		    @$objectives[$i]->{pk} = $objective->primary_key;
		    warn @$objectives[$i]->{pk};
		}elsif (@$objectives[$i]->{elementchanged} == 1){
		    my $objective = HSDB4::SQLRow::Objective->new->lookup_key(@$objectives[$i]->{pk});
		    
		    $objective->set_field_values(body => @$objectives[$i]->{body});
		    
		    ($rval, $msg) = $objective->save($TUSK::Constants::DatabaseUsers{ContentManager}->{writeusername}, $TUSK::Constants::DatabaseUsers{ContentManager}->{writepassword});
		    return (0, $msg) unless ($rval > 0);
		}
		
		($rval, $msg) = $content->add_child_objective($un, $pw, @$objectives[$i]->{pk}, ($i+10));

		return (0, $msg) unless (defined($rval));
	    }
	}
    return 1;
}

sub update_keywords{
	my ($content, $keywords,$keywordStruct,$user) = @_;
	my $link;
	my $user_id = $user->user_id();
	my $currentKeywordLinks = TUSK::Core::LinkContentKeyword->lookup(" parent_content_id = ".$content->primary_key );
	my %keywordHash = map { ( $_->getPrimaryKeyID(), 1 ) } @{$keywords} ;
	my %currentKeywordHash = map { ($_->getChildKeywordID(),1 ) } @{$currentKeywordLinks};
	my %sortOrderLookup;
	# get the sort order for each keyword id
	foreach my $rowHash (@{$keywordStruct}) { 
		$sortOrderLookup{$rowHash->{pk}} = $rowHash->{sortorder};
	}
	# delete keywords that were removed
	foreach my $old_keyword (@{$currentKeywordLinks}){
		if (!$keywordHash{$old_keyword->getChildKeywordID()}){
			$old_keyword->delete({'user'=>$user_id});
		}

	}
	# insert keywords that were added
	foreach my $keyword (@{$keywords}){
		if (!$currentKeywordHash{$keyword->getPrimaryKeyID()}){
			$link = TUSK::Core::LinkContentKeyword->new();
			$link->setParentContentID($content->getPrimaryKeyID());
			$link->setChildKeywordID($keyword->getPrimaryKeyID());
			$link->setSortOrder($sortOrderLookup{$keyword->getPrimaryKeyID()});
			$link->save({'user'=>$user_id});
			$currentKeywordHash{$keyword->getPrimaryKeyID()} = 1;
		}
	}
	return 1;
}

sub move_file{
    my ($content, $fdat, $path, $element_uri) = @_;
    (my $fileext = $fdat->{filename}) =~ s/.*\././; # we need the period
    $fileext = "" if ($fileext eq $fdat->{filename});
    $fileext = ".pp" . lc($1) if ($fileext =~ /\.pp(s|tx?)/i);
    $fileext = ".ppt" if ($fileext eq ".pps" and $path eq $path{'ppt'});

    my $newfilename = $content->primary_key . $fileext;
    
    my $newfilepath1 = $path ."/" . $newfilename;

    $newfilepath1 =~ /(.*)/; # untaint
    my $newfilepath = $1;
    
    my $body = $content->body;
    my $slash = "";
    $slash = "/" if ($fdat->{content_type} eq "Flashpix");
    
    my $uri = $slash.$newfilename;
    my ($ret, $rval);

    if ($fdat->{content_type} eq "Shockwave"){ $uri = '/downloadable_file/'.$uri; }
    ($rval, $ret) = mangle_element($content, $uri, $element_uri,1 ) if ($element_uri);

    if ($fdat->{content_type} eq "Shockwave"){
	($rval, $ret) = mangle_shockwave($content, %$fdat);
    }
	elsif ($fdat->{content_type} eq "Audio" or $fdat->{content_type} eq "Video"){
	($rval, $ret) = mangle_audiovideo($content, %$fdat);
    }
    
    $fdat->{filename}=~/(.*)/;
    my $filename = $1;
    if (-e $newfilepath){
	unlink $newfilepath;
    }

    unless (-e $path{'temp'} . "/" . $filename){
	return(0, "The file could not be found.");
    }
    link $path{'temp'}."/".$filename, $newfilepath or return (0, $!);
    
    if ($fdat->{content_type} eq "Flashpix"){
	chmod 0644, $newfilepath; # flashpix files need to have these permissions
    }
	elsif ($fdat->{content_type} eq "TUSKdoc"){
		if ($newfilepath =~ /\.(docx?)$/) {
			my $alt_ext = ($1 eq 'docx')? 'doc' : 'docx';
			my $altfilepath = $newfilepath;
			$altfilepath =~ s/docx?$/$alt_ext/;
			if (-e $altfilepath) {
				# if we uploaded a doc and there is a docx with same id, delete it (or vice versa)
				unlink $altfilepath;
			}
		}
	}

    return (1, $ret);
}

sub upload_file {
    my (%fdat) = @_;
    my $body;

    (my $fileext = $fdat{file}) =~ s/.*\.//; # we do not need the period
    $fileext = "" if ($fileext eq $fdat{file});

    my $filename = int(10000*rand(time));
    
    my %extensions=(
		    'Shockwave' => 'swf',
		    'Document' => 'html',
		    'PDF' => 'pdf',
		    'Flashpix' => 'fpx',
		    'Video' => 'rm',
		    'Video' => 'rmvb',
		    'Video' => 'rv',
		    'Video' => 'mov',
		    'Video' => 'mpeg',
		    'Video' => 'mpg',
		    'Video' => 'mp4',
		    'Video' => 'wmv',
		    'Video' => 'avi',
		    'Audio' => 'ra',
		    'Audio' => 'mp3',
		    'Audio' => 'wma',
		    'PPT' => 'ppt',
		    'PPTX' => 'pptx',
		    'PPS' => 'pps',
		    );

	if ($fdat{upload_type}){
		$fileext = $extensions{$fdat{upload_type}} unless ($fileext);
		$fdat{upload_type} = "DownloadableFile" if ($fdat{upload_type} =~ /PPS|PPTX?/);
    }elsif(!$fdat{upload_type}){
		$fdat{upload_type}=TUSK::UploadContent::get_content_type_from_file_ext($fileext);
		unless ($fdat{upload_type}){ $fdat{upload_type}="DownloadableFile"; }
    }
	if (lc($fileext) =~ /docx?/ and $fdat{content_type} eq 'TUSKdoc'){
		$fdat{upload_type} = 'TUSKdoc';
	}
    # are we replacing a file here?
    if ($fdat{content_type} and $fdat{content_type} ne $fdat{upload_type}){
	return(0, "The file type (extension) of the uploaded file did not match the content type.");
    }
    
    $filename .= "." . $fileext if ($fileext);
    my $newfilepath1 = ( $path{'temp'} . "/" . $filename ) =~ /(.*)/; # untaint
    my $newfilepath = $1;
    
    unlink $newfilepath if (-e $newfilepath);

    my $FILE;
    if (open ($FILE, ">$newfilepath")){
	binmode $FILE; # not necessary on most unixes?
	my $bytesread;
	my $fh = ($fdat{filehandle}) ? $fdat{filehandle} : $fdat{file};
	my $buffer;

	while ($bytesread = read($fh, $buffer, $CHUNK_SIZE)){
	    $body .= $buffer;
	}

	print $FILE $body;
	close $FILE;
	close ($fh);
        #This can be caused by having a bad version of CGI.pm
        #At NYMC we found an error where the uploaded file was seen in /var/tmp (by uploading a huge file) but no body was avaliable
        #They were on CGI.pm v 3.01 (or something like that) and going to 3.20 fixed this error
        unless($body) {return(0, "Error saving file: no data!");}
    } else {
	return (0, "Error saving file: $! :: '$newfilepath' :: '" . $path{'temp'} . "/" . $filename . "'");
    }

    $fdat{body} = "";

    $fdat{body} = $body if ($fdat{upload_type} eq "Document");

    return (1, $filename, $fdat{body}, $fdat{upload_type});
}
     
sub add_content_content{
	my ($user, $content, %fdat) = @_;

	my $parent = HSDB4::SQLRow::Content->new->lookup_key($fdat{'content_id'});
	if (!$parent->primary_key){
		return (0, 'Invalid parent content id');
	}
	
	my $count = scalar $parent->child_content;

	return $parent->add_child_content ($un,
		$pw, $content->primary_key, ($count + 1) * 10,'');
}

# what about support for 'label' column in HSDB45::Course::add_child_content?
sub add_course_content{
	my ($user, $content, %fdat) = @_;

	my ($school,$course_id) = split (/-/, $fdat{'course'});

	my $label = $fdat{'label'};

	my $course = HSDB45::Course->new(_school => $school);
	$course->lookup_key($course_id);

	return  (0, "Invalid course id '$course_id' for school '$school'")
		unless ($course->primary_key);

	my $count = scalar $course->child_content;
	
	return $course->add_child_content($un,$pw, $content->primary_key, ($count + 1) * 10);
}

sub mangle_element{
    my ($c, $value, $element, $non_cdata_flag) = @_;
    my $xml = $c->twig_body;

    my ($status, $note);
    if ($non_cdata_flag){
	($status, $note) = $xml->replace_element_uri($value,$element);
    }else{
	($status, $note) = $xml->replace_element_uri('<![CDATA['.$value.']]>',$element);
    }
    return (0, $note) unless ($status);
    $c->set_field_values("body" => $xml->out_xml);
    return (1, $xml->out_xml);
}



sub mangle_shockwave{
    my ($c, %fdat) = @_;
    my $xml = $c->twig_body;
    my ($status, $note);
    
    ($status, $note) = $xml->replace_element_uri('<![CDATA['.$fdat{body}.']]>',"html");
    return (0, $note) unless ($status);

    $fdat{width} = 550 unless ($fdat{width} > 0);
    ($status, $note) = $xml->replace_element_attribute("shockwave_uri", "width", $fdat{width});
    return (0, $note) unless ($status);

    $fdat{height} = 450 unless ($fdat{height} > 0);
    ($status, $note) = $xml->replace_element_attribute("shockwave_uri", "height", $fdat{height});
    return (0, $note) unless ($status);

    $fdat{displaytype} = "Stream" unless ($fdat{displaytype});
    ($status, $note) = $xml->replace_element_attribute("shockwave_uri", "display-type", $fdat{displaytype});
    return (0, $note) unless ($status);

    $c->set_field_values("body" => $xml->out_xml);

    return (1, $xml->out_xml);
}

sub mangle_audiovideo{
    my ($c, %fdat) = @_;
    my $xml = $c->twig_body;
    my ($status, $note, $uri);

    $uri = 'realvideo_uri';

    ($status, $note) = $xml->replace_element_uri('<![CDATA['.$fdat{body}.']]>',"html");
    return (0, $note) unless ($status);

    if ($fdat{'content_type'} eq 'Video'){
	$fdat{width} = 320 unless ($fdat{width} > 0);
	($status, $note) = $xml->replace_element_attribute($uri, "width", $fdat{width});
	return (0, $note) unless ($status);
	
	$fdat{height} = 240 unless ($fdat{height} > 0);
	($status, $note) = $xml->replace_element_attribute($uri, "height", $fdat{height});
	return (0, $note) unless ($status);

    }

    $fdat{displaytype} = "Stream" unless ($fdat{displaytype});

    ($status, $note) = $xml->replace_element_attribute($uri, "display-type", $fdat{displaytype});
    return (0, $note) unless ($status);


    $c->set_field_values("body" => $xml->out_xml);

    return (1, $xml->out_xml);
}

sub get_content_type_from_file_ext {
	#	Returns one of the TUSK content types based on a file extension
	#		Document, Audio, Video, Flashpix, Collection, Slide, Shockwave, URL, PDF,
	#		Question, Multidocument, Quiz, Student, Reuse, External, TUSKdoc
	#	Defaulting to a DownloadableFile if can not be determined.
	my $fileName = shift;
	my $extension = lc($fileName);
	$extension =~ s/^.*\.//g;
	if(exists($fileTypes{$extension})) {return $fileTypes{$extension};}
	return 'DownloadableFile';
}

sub isa_powerpoint {
	my $extension = shift;
	if($extension eq 'ppt' || $extension eq 'pps' || $extension eq 'pptx') {return 1;}
	return 0;
}

sub isa_worddoc {
	my $extension = shift;
	if($extension eq 'doc' || $extension eq 'docx') {return 1;}
	return 0;
}

1;


