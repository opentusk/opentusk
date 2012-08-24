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


package Apache::HSDBSlide;

use strict;
use Apache2::Const qw(:common);
use Apache2::Log;
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
	$r->print($image->ImageToBlob()) or return DECLINED;

    return OK;
}

1;

__END__
