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


package Apache::TUSKDownload;

use strict;

use Apache2::Const qw(:common);
use Apache2::URI ();
use Apache2::ServerUtil;
use Apache::AuthzHSDB;
use HSDB4::SQLRow::Content;
use TUSK::XMLRenderer;
use TUSK::ErrorReport;
use Devel::Size;
use Devel::StackTrace;

my %noAttachmentExt = (
    'doc'  => 'application/msword',
    'docx' => 'application/vnd.openxmlformats-"
        . "officedocument.wordprocessingml.document',
    'ppt'  => 'application/vnd.ms-powerpoint',
    'xls'  => 'application/vnd.ms-excel',
    'pdf'  => 'application/pdf',
);

my %ImageTypes =  (
    'image/gif'  => 'gif',
    'image/jpeg' => 'jpg',
    'image/png' => 'png'
);

sub _handle_err {
    my ($r, $err) = @_;
    my $trace = Devel::StackTrace->new()->as_string();
    my $msg = "$err at $trace";
    $r->log_error($msg);
    # Should be TUSK::ErrorReport to match the file path and use
    # statement. Will require refactor of several files.
    ErrorReport::sendErrorReport($r, {
        To => $TUSK::Constants::ErrorEmail,
        From => $TUSK::Constants::ErrorEmail,
        Msg => $msg,
    });
}

sub handle_slide {
    my ($uri,) = @_;

    my $ext;
    my $filename;
    my @path = split( '/', $uri );

    # original slide
    if (scalar(@path) == 2) {
        my $content_id = $path[1];
        my $content    = HSDB4::SQLRow::Content->new->lookup_key(
            $content_id
        );
        my $location   = $content->get_image_location();
        $ext           = $content->image_available( 'orig' );
        $filename      = sprintf('%s/orig/%s.%s',
                                 $TUSK::UploadContent::path{slide},
                                 $location,
                                 $ext, );
    }
    # other slide
    else {
        my $type = $path[1];
        if ( lc($type) eq 'overlay' ) {
            my $size       = $path[2];
            my $content_id = $path[3];
            my $content    = HSDB4::SQLRow::Content->new->lookup_key(
                $content_id
            );
            my $location   = $content->get_image_location();
            $ext           = $content->image_available( 'orig', 1 );

            $filename = sprintf('%s/%s/%s/%s.%s',
                                $TUSK::UploadContent::path{slide},
                                $type,
                                $size,
                                $location,
                                $ext, );
        }
        else {
            my $content_id = $path[2];
            my $content    = HSDB4::SQLRow::Content->new->lookup_key(
                $content_id
            );
            my $location   = $content->get_image_location();
            $ext           = $content->image_available( 'orig' );

            $filename = sprintf('%s/%s/%s.%s',
                                $TUSK::UploadContent::path{'slide'},
                                $type,
                                $location,
                                $ext, );
        }
    }

    return { filename => $filename, ext => $ext, };
}

sub handle_document {
    my ($r, $document,) = @_;
    my $ext = "html";
    my $blob = TUSK::XMLRenderer::transform(
        $document->field_value('body'),
        $r->server_root_relative("code/XSL") . "/Content/edit_text.xsl",
    );
    return { blob => $blob, ext => $ext, };
}

sub handle_pdf {
    my ($document,) = @_;
    my $ext = "pdf";
    my $filename = $document->out_file_path();
    return { filename => $filename, ext => $ext, };
}

sub handle_downloadable {
    my ($document,) = @_;
    my $fileobj = $document->body->tag_values('file_uri');
    my $file = $fileobj->value;
    $file =~ /\.(.*)/;
    my $ext = $1;
    my $filename = $document->out_file_path();
    return { filename => $filename, ext => $ext };
}

sub handle_tuskdoc {
    my ($document,) = @_;
    my $filename = $document->out_file_path();
    my $ext = q{};
    if (defined $filename) {
        $ext = 'doc'  if ($filename =~ /\.doc$/);
        $ext = 'docx' if ($filename =~ /\.docx$/);
    }
    return { filename => $filename, ext => $ext, };
}

sub handle_shockwave {
    my ($document,) = @_;
    my $filename = $document->out_file_path();
    my $ext = q{};
    $ext = "flv" if ( $filename =~ /\.flv/ );
    $ext = "swf" if ( $filename =~ /\.swf/ );
    return { filename => $filename, ext => $ext, };
}

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
		$blob = &TUSK::XMLRenderer::transform($document->field_value('body'), $TUSK::Constants::XSLRoot . "/Content/edit_text.xsl");
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
	$r->headers_out->set("Accept-Ranges", "bytes");
	$r->headers_out->set("Content-Length", $fileSize);
	$r->headers_out->set("Content-disposition","$attachmentType; filename=" . $file_title . "." . $ext); 
	$r->no_cache(1);
	$r->content_type($contentType);

	if($filename) {
            if (-e $filename) {
		$r->sendfile($filename);
            } else {
                # file not found in the file system for some reason
                # (this is bad in production)
                my $msg = "Error in lib/Apache/TUSKDownload.pm: "
                    . "File '$filename' referenced in database but file "
                    . "not found in file system.\n";
                $r->log_error($msg);
		ErrorReport::sendErrorReport($r, {
                    To => $TUSK::Constants::ErrorEmail,
                    From => $TUSK::Constants::ErrorEmail,
                    Msg => $msg,
                });
                return Apache2::Const::NOT_FOUND;
            }
	}
	else {
	    $r->print($blob);
	}

	return OK;
}

1;
