package Apache::MultiSlide;

use strict;
use Apache::Constants qw(:common);
use Apache::Log;
use Image::Magick;
use TUSK::Content::MultiContentManager;

sub handler {
	my $r = shift;
	my $path = $r->uri;
	# Kill the leading slash, if it's there
	$path =~ s!^/!!;

	# The first item is going to be /mcp (or whatever the URL is for this)
	my @path_info = split ('/', $path);
	my $mcuID = $path_info[1];
	my $fileName = $path_info[2];

	my $multiContentUpload = TUSK::Content::MultiContentManager->new->lookupKey( $mcuID );
	return FORBIDDEN unless( $multiContentUpload && $multiContentUpload->is_user_authorized( Apache::AuthzHSDB::get_user_id($r) ));

	# If we were not given a file name freak out
	return NOT_FOUND unless($fileName);

	# A multi content preview has to have a .jpg file type because thats all we make for it.
	my $fileType = 'jpg';

	my $fileOnDisk = $multiContentUpload->getPreviewDirectory() . "/${fileName}.jpg";
	# If the preview image is not available then default to the ? image
	unless(-f $fileOnDisk) {
		$fileOnDisk = "$ENV{SERVER_ROOT}/graphics/icons/unknown.gif";
		$fileType = "gif";
	}
	# If we can't find the file asked for nor the defualt image give a not found.
	return NOT_FOUND unless(-f $fileOnDisk);

	return DECLINED unless $fileType;

	$r->content_type('image/jpeg')  if $fileType eq 'jpg';	
	$r->content_type('image/gif')   if $fileType eq 'gif';

	my $image = Image::Magick->new();
	$image->Read( $fileOnDisk );
	$r->no_cache;
	$r->send_http_header;
	$r->print($image->ImageToBlob()) or return DECLINED;
	return OK;
}

1;

__END__
