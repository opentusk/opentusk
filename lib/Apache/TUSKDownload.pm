package Apache::TUSKDownload;

use strict;

use Apache::Constants qw(:common);
use Apache::URI ();
use Apache::File ();
use Apache::AuthzHSDB;
use HSDB4::SQLRow::Content;
use TUSK::XMLRenderer;
use Devel::Size;

my %noAttachmentExt = (
		       'doc' => 'application/msword',
		       'docx' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
		       'ppt' => 'application/vnd.ms-powerpoint', 
		       'xls' => 'application/vnd.ms-excel',
		       'pdf' => 'application/pdf',
		       );

my %ImageTypes =  (
		   'image/gif'  => 'gif',
		   'image/jpeg' => 'jpg',
		   'image/png' => 'png'
		   );

sub handler {
	my $r = shift;

	my $uri = ($r->path_info()) ? $r->path_info() : $r->uri();
	if ( $uri =~ /\.flv$/ ) {
		$uri =~ s/\.flv$//;
	}

	my $user_id = Apache::AuthzHSDB::get_user_id($r);

	my $document = HSDB4::SQLRow::Content->new->lookup_path($uri);

	unless($document) {
	    return NOT_FOUND;
	}

        unless($document->is_user_authorized($user_id)) {
	    return FORBIDDEN;
	}

	my $ext = '';
	my $blob = '';
	my $filename = '';

	if($document->content_type() eq "Slide") {
		my @path = split( '/', $uri );
		if (scalar(@path) == 2) {
			my $content  = HSDB4::SQLRow::Content->new->lookup_key( $path[1] );
			my $location = $content->get_image_location();
			$ext         = $content->image_available( 'orig' );
	
			$filename = $TUSK::UploadContent::path{'slide'} . '/orig/' . $location . "." . $ext;
		} else {
			if ( lc($path[1]) eq 'overlay' ) {
				my $content  = HSDB4::SQLRow::Content->new->lookup_key( $path[3] );
				my $location = $content->get_image_location();
				$ext         = $content->image_available( 'orig', 1 );
			
				$filename = $TUSK::UploadContent::path{'slide'} . '/' . $path[1] . '/' . $path[2] . '/' . $location . "." . $ext;
			} else {
				my $content  = HSDB4::SQLRow::Content->new->lookup_key( $path[2] );
				my $location = $content->get_image_location();
				$ext         = $content->image_available( 'orig' );
			
				$filename = $TUSK::UploadContent::path{'slide'} . '/' . $path[1] . '/' . $location . "." . $ext;
			}
		}
	} 
	elsif($document->content_type() eq "Document") {
		$ext = "html";
		$blob = &TUSK::XMLRenderer::transform($document->field_value('body'), $r->server_root_relative("code/XSL")."/Content/edit_text.xsl");
	} 
	elsif($document->content_type() eq "PDF") {
		$ext = "pdf";
		$filename = $document->out_file_path();
	} 
	elsif($document->content_type() eq "DownloadableFile") {
		my $fileobj = $document->body->tag_values('file_uri');
		my $file = $fileobj->value;
		$file =~ /\.(.*)/;
		$ext = $1;

		$filename = $document->out_file_path();
	}
	elsif($document->content_type() eq 'TUSKdoc') {
		$filename = $document->out_file_path();

		if (defined $filename) {
			$ext = 'doc'  if ($filename =~ /\.doc$/);
			$ext = 'docx' if ($filename =~ /\.docx$/);
		}
	}
	elsif($document->content_type() eq "Shockwave") {
		$filename = $document->out_file_path();
		$ext = "flv" if ( $filename =~ /\.flv/ );
		$ext = "swf" if ( $filename =~ /\.swf/ );
	}

	# If we did not get a blob  or a valid filename print off a 404
	unless($blob || $filename) {
	    return(NOT_FOUND);
	}

	#A list bit of header checks
	my $fileSize = 0;
	if($blob) {$fileSize = Devel::Size::size($blob);}
	else      {$fileSize = -s $filename;}

	my $attachmentType = "attachment";
	my $contentType = "application/unknown";

	$ext = lc($ext);
	if(exists $noAttachmentExt{$ext} ) {
		$attachmentType = "inline";
		$contentType = $noAttachmentExt{$ext}
	}

	my $title = '';
	if ($document->title()){
		$title .= substr($document->title(), 0, 25);
		$title =~ s/ /_/g;
		$title =~ s/\W//g;
	}
	my $file_title;
	$file_title  = $title . "-" if $title;
	$file_title .= $document->primary_key();

	#Send the download
	$r->content_type($contentType);
	$r->header_out("Accept-Ranges", "bytes");
	$r->header_out("Content-Length", $fileSize);
	$r->header_out("Content-disposition","$attachmentType; filename=" . $file_title . "." . $ext); 
	$r->no_cache(1);
	$r->send_http_header;

	if($filename) {
	    
	    my $fh = Apache::File->new($filename) or return NOT_FOUND;

	    $r->send_fd($fh);
	    
	    close $fh;
	} 
	else {
	    $r->print($blob);
	}

	return OK;
}

1;
