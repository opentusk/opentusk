package TUSK::Application::Assignment::Upload;

##########################################################
## Wrapper Class for uploading assingment using some 
## methods from TUSK::UploadContent
##########################################################

use strict;
use TUSK::UploadContent;
use TUSK::Assignment::LinkAssignmentContent;
use TUSK::Assignment::LinkAssignmentUser;
use TUSK::Assignment::LinkAssignmentStudent;


sub new {

	my ($class, $args) = @_;

	my $self = { 
		 school     => $args->{school},
		 course_id  => $args->{course_id},
		 user       => $args->{user},
		 role       => $args->{role},
		 assignment => $args->{assignment},
		 sequence   => $args->{sequence},
		 content    => undef,
		 message    => undef,
		 };

	return bless ($self, $class);
}

sub uploadContent {
    my $self = shift;
    my $args = shift;
    $self->{filename} = $args->{filename};
    $self->{filehandle} = $args->{filehandle};
    my $group_id = $args->{group_id} || 0;
    my $user_id = $args->{user_id};

    ### only 2 roles beins used in link_content_user
    ### if any changes, make sure it is changed somewhere else
    if ($self->{role} eq 'Student-Author') {
	if ($self->uploadFile()) {
	    if (my $content_id = $self->addContent('All Users')) {
		$self->{content} = HSDB4::SQLRow::Content->new()->lookup_key($content_id);
		if ($self->completeContentUpload()) {
		    if ($self->updateContentUsers()) {
			if ($self->updateAssignmentContent($group_id,$user_id)) {
			    return 1;
			}
		    }
		}
	    }
	}
    } elsif ($self->{role} eq 'Author') {
	if ($self->uploadFile()) {
	    if (my $content_id = $self->addContent('All Users')) {
		$self->{content} = HSDB4::SQLRow::Content->new()->lookup_key($content_id);
		if ($self->completeContentUpload()) {
		    if ($self->updateContentUsers()) {
			if ($self->updateAssignmentContent($group_id,$user_id)) {
			    if ($self->updateAssignmentUser()) {
				return 1;
			    }
			}
		    }
		}
	    }
	}
    } else {
	$self->{message} = 'Invalid user role';
    }

    return 0;
}

sub setFilename {
	my ($self, $filename) = @_;
	die "Need filename as an argument\n" unless defined $filename;
	$self->{filename} = $filename;
}


sub setFilehandle {
	my ($self, $filehandle) = @_;
	die "Need filename as an argument\n" unless defined $filehandle;
	$self->{filehandle} = $filehandle;
}

sub getMessage {
	my $self = shift;
	return $self->{message};
}

sub uploadFile {
	my $self = shift;
	my ($rval);

	($rval, $self->{tempfilename}, $self->{body}, $self->{upload_type}) = 
	    TUSK::UploadContent::upload_file(
		    upload_type  => 'DownloadableFile', 
		    content_type => 'DownloadableFile', 
		    file 	 => $self->{filename},
		    filehandle   => $self->{filehandle},
        );

	$self->{message} = "Failed to upload $self->{filename}" if $rval == 0;
	return $rval;
}

sub addContent  {
	my ($self, $read_access) = @_;

	my ($dirpath,$basename) = ($self->{filename} =~ m#^((?:.*[:\\/])?)(.*)#s);
	my ($rval, $content_id) = TUSK::UploadContent::add_content(
			$self->{user},
		    ( course       => $self->{school} . "-" . $self->{course_id},
		      title        => $basename,
		      read_access  => $read_access,
		      application_access => 'Assignment',
		      content_type => 'DownloadableFile', 
		      display      => 0,
		    ),
	);

	if ($rval > 0) {
		return $content_id;
	} else {
		$self->{message} = "Failed to upload $content_id";
		return undef;
	}
}

sub completeContentUpload {
	my $self = shift;
	my ($rval,$msg) = TUSK::UploadContent::do_file_stuff(
		 $self->{content}, 
		 $self->{user}->primary_key(), 
         (content_type => 'DownloadableFile', 
          filename     => $self->{tempfilename}, 
	  ppt_change   => 0));

	$self->{message} = $msg if $rval == 0;
	return $rval;
}


sub updateContentUsers {
	my $self = shift;
	my $authors = [ { pk   => $self->{user}->primary_key(),
			  role => $self->{role}  } ];

	my ($rval, $msg);
	if (defined $self->{content}) {
		($rval, $msg) = TUSK::UploadContent::update_users($self->{content}, $authors);
	}

	$self->{message} = $msg if $rval == 0;
	return $rval;
}


sub updateAssignmentContent {
	my ($self,$group_id,$user_id) = @_;
	my $link = TUSK::Assignment::LinkAssignmentContent->new();
	$link->setFieldValues({ 
	    parent_assignment_id => $self->{assignment}->getPrimaryKeyID(),
	    child_content_id => $self->{content}->primary_key(),
	    user_group_id    => $group_id,
	    user_id          => $user_id,
	    submit_sequence  => $self->{sequence},
	});

	if ($link->save({user => $self->{user}->primary_key()})) {
		return 1;
	} else {
		$self->{message} = 'Failed to update link_assignment_content';
		return 0 ;
	}
}


sub updateAssignmentUser {
	my $self = shift;
	my $link = TUSK::Assignment::LinkAssignmentUser->new();
	my $found = $link->lookupReturnOne("parent_assignment_id = " . $self->{assignment}->getPrimaryKeyID() . " AND child_user_id = '" . $self->{user}->primary_key() . "'");

	unless ($found && $found->getPrimaryKeyID()) {
	    $link->setFieldValues({ 
		parent_assignment_id => $self->{assignment}->getPrimaryKeyID(),
		child_user_id => $self->{user}->primary_key() });

	    if ($link->save({user => $self->{user}->primary_key()})) {
		return 1;
	    } else {
		$self->{message} = 'Failed to update link_assignment_user';
		return 0 ;
	    }
	}
}


sub updateAssignmentStudent {
	my $self = shift;
	my $link = TUSK::Assignment::LinkAssignmentStudent->new();
	$link->setFieldValues({ 
		parent_assignment_id => $self->{assignment}->getPrimaryKeyID(),
		child_user_id => $self->{user}->primary_key() });

	if ($link->save({user => $self->{user}->primary_key()})) {
		return 1;
	} else {
		$self->{message} = 'Failed to update link_assignment_student';
		return 0 ;
	}
}


1;
