package TUSK::Manage::Reuse;

use HSDB4::Constants;
use HSDB4::SQLLink;
use TUSK::UploadContent;
use TUSK::Constants;
use TUSK::Content::External::MetaData;
use TUSK::Content::External::Field;
use TUSK::Content::External::LinkContentField;

use strict;

my $pw = $TUSK::Constants::DatabaseUsers->{ContentManager}->{writepassword};
my $un = $TUSK::Constants::DatabaseUsers->{ContentManager}->{writeusername};

sub process_reuse{
    my ($req,$course_id, $school, $is_parent_content, $user_id, $fdat) = @_;
    my ($rval, $msg, $content);

    $fdat->{content_id} = int $fdat->{content_id};
    if ($fdat->{content_id}){
		$content = HSDB4::SQLRow::Content->new->lookup_key($fdat->{content_id});
		unless ($content->primary_key){
			return(0, "Content id not found.");
		}
		if ($content->field_value('reuse_content_id') and $fdat->{selection} == 2){
			return(0, "This content has already been reused from content with id " . $content->field_value('reuse_content_id') . ".");
		}
    } else {
		return(0, "Please enter a content id.");
    }

    $fdat->{copy_content_data} = $fdat->{content_id};

    if ($is_parent_content > 0){
		$fdat->{parent} = "content";
		$fdat->{content_id} = $is_parent_content; # $req->{parent_content}->primary_key;
    }elsif ($course_id){
		$fdat->{parent} = "course";
		$fdat->{course} = $school."-".$course_id;
    }

    $fdat->{sort_order}=65535;
    $fdat->{course}=$school . "-" . $course_id;
    
    if ($fdat->{selection} == 1){
		($rval, $msg) = make_copy($req, $course_id, $school, $is_parent_content, $fdat);
		return ($rval, $msg) if ($rval == 0);
    }else{
		($rval, $msg) = reuse_content($req, $content, $user_id, $fdat);
		return ($rval, $msg) if ($rval == 0);

		if ($content->field_value('type') eq "Collection"){
			if ($content->child_contentref) {
				my ($data);
				$data->{parent} = "content";
##				$data->{content_id} = $req->{content}->primary_key;
				$data->{sort_oder} = 0;
				$data->{course} = $fdat->{course};

				foreach my $foldercontent (@{$content->child_contentref}){
					$data->{copy_content_data} = $foldercontent->primary_key;
					$data->{sort_order} += 10;
					($rval, $msg) = reuse_content($req, $foldercontent, $user_id,  $data);
				}
			}
		}
    }
    
    return ($rval, "Content Successfully Added");
}

sub reuse_content{
    my ($req, $content, $user_id, $fdat) = @_;
    my ($rval, $msg);

	my $new_content;

	my $user = HSDB4::SQLRow::User->new->lookup_key($user_id);
 
    ($rval, $msg) = TUSK::UploadContent::add_content($user, %$fdat);
    return ($rval, $msg) if ($rval == 0);

    ### new content whereas $content is an original content
#     $req->{content} = HSDB4::SQLRow::Content->new->lookup_key($msg);
	$new_content = HSDB4::SQLRow::Content->new->lookup_key($msg);
	
#    ($rval, $msg) = $req->{content}->add_child_user($un, $pw, $req->{user}->primary_key, 0, "Author");
	($rval, $msg) = $new_content->add_child_user($un, $pw, $user_id, 0, "Author");

    if ($fdat->{objectives}){
#		($rval, $msg) = create_objectives($content, $req->{content});
		($rval, $msg) = create_objectives($content, $new_content);
		return ($rval, $msg) if ($rval == 0);
    }

    if ($fdat->{keywords}){
#		($rval, $msg) = create_keywords($content, $req->{content}, $req->{user});
		($rval, $msg) = create_keywords($content, $new_content, $user);
		return ($rval, $msg) if ($rval == 0);
    }

    if ($content->field_value('type') eq 'External') {

	my $fields = TUSK::Content::External::Field->lookup('', undef, undef, undef, [ TUSK::Core::JoinObject->new("TUSK::Content::External::LinkContentField", { origkey => 'field_id', joinkey => 'child_field_id', joincond => 'parent_content_id = ' . $content->primary_key(), jointype => 'inner'}) ]);

	return (0, "Can't copy link_content_field") unless $fields && scalar @$fields;

	foreach my $field (@$fields) {
	    my $link = TUSK::Content::External::LinkContentField->new();
	    $link->setFieldValues({
		parent_content_id => $new_content->primary_key(),
		child_field_id    => $field->getPrimaryKeyID(),
		value             => $field->getJoinObject('TUSK::Content::External::LinkContentField')->getValue() });
	    $link->save({ user => $user_id });
	}

	if (my $from_metadata = TUSK::Content::External::MetaData->lookupReturnOne("content_id = " . $content->primary_key())) {

	    my $to_metadata = TUSK::Content::External::MetaData->new();
	    $to_metadata->setFieldValues({
		abstract => $from_metadata->getAbstract(),
		author => $from_metadata->getAuthor(),
		content_id => $new_content->primary_key(),
	    });
	    $to_metadata->save({user => $user_id});

	    if (my $url = $from_metadata->getUrl()) {
			$to_metadata->setUrl($url, $user_id);
	    }
	}
}

    return (1);
}

sub create_objectives{
    my ($oldcontent, $newcontent) = @_;
    my ($rval, $msg, $i);
    my @objectives = $oldcontent->child_objectives;
    foreach my $objective (@objectives){
	$i = $i + 10;
	($rval, $msg) = $newcontent->add_child_objective($un, $pw, $objective->primary_key, $i);
	return (0, $msg) unless (defined($rval));
    }
    return (1);
}

sub create_keywords{
    my ($oldcontent, $newcontent, $user) = @_;
    my ($rval, $msg);
    my @keywords = $oldcontent->keywords();
    
    my $i = 0;
    foreach my $keyword (@keywords){
	$i++;
	my $newkeyword =  TUSK::Core::LinkContentKeyword->new();
	$newkeyword->setParentContentID($newcontent->primary_key());
	$newkeyword->setChildKeywordID($keyword->getPrimaryKeyID());
	$newkeyword->setSortOrder($i*10);
	$newkeyword->save( { 'user'=> $user->primary_key() } );
    }
    return (1);
}

sub make_copy{
    my ($req, $course_id, $school, $is_parent_content, $fdat) = @_;
    my ($rval, $msg, $linkdef, $id, $schooldb);

    if ($is_parent_content > 0){
        $linkdef = $HSDB4::SQLLinkDefinition::LinkDefs{'link_content_content'};
        $id = $is_parent_content;
    }else{
        $schooldb = HSDB4::Constants::get_school_db($school);
        $linkdef = $HSDB4::SQLLinkDefinition::LinkDefs{"$schooldb\.link_course_content"};
        $id = $course_id;
    }
    
    my @children  = $linkdef->get_children($id,"child_content_id = $fdat->{copy_content_data}")->children();        

    unless (@children){
        ($rval, $msg) = $linkdef->insert(-user =>$un, -password => $pw,
                                         -parent_id => $id,
                                         -child_id => $fdat->{copy_content_data});
        return ($rval, $msg) if ($rval == 0);
    }   
    return (1, "Content Successfully Added");
}

