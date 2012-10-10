package Apache::HSDBSlide;

use strict;
use Apache::Constants qw(:common);
use Apache::Log;
use Image::Magick;
use HSDB4::SQLRow::Content;

sub handler {
    my $r = shift;
    my $path = $r->uri;
    # Kill the leading slash, if it's there
	$path =~ s!^/!!;

	my @path_info = split ('/', $path);
	my ( $overlay, $size, $id );

	if ( lc($path_info[0]) eq 'overlay' ) {
		$overlay = 1;
		$size    = $path_info[1];
		$id      = $path_info[2];
	} else {
		$overlay = 0;
		$size    = $path_info[0];
		$id      = $path_info[1];
	}

	my $content = HSDB4::SQLRow::Content->new()->lookup_key( $id );

	return FORBIDDEN unless ( $content && $content->is_user_authorized( Apache::AuthzHSDB::get_user_id($r) ) );

	my $file_type = $content->image_available( $size, $overlay );

	return DECLINED unless $file_type;

	$r->content_type('image/jpeg')  if $file_type eq 'jpg';	
	$r->content_type('image/gif')   if $file_type eq 'gif';
	$r->content_type('image/x-png') if $file_type eq 'png';

	my $image = Image::Magick->new();
	my $location = $content->get_image_location();
	
	if ( $overlay ) {
		$image->Read( $TUSK::UploadContent::path{'slide'} . '/overlay' . $HSDB4::Constants::URLs{$size} . '/' . $location . '.' . $file_type );
	} else {
		$image->Read( $TUSK::UploadContent::path{'slide'} . $HSDB4::Constants::URLs{$size} . '/' . $location . '.' . $file_type );
	}

	$r->no_cache;
	$r->send_http_header;
	$r->print($image->ImageToBlob()) or return DECLINED;

    return OK;
}

1;

__END__
