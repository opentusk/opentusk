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


package Apache::MultiSlide;

use strict;
use Apache2::Const qw(:common);
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
	$r->print($image->ImageToBlob()) or return DECLINED;
	return OK;
}

1;

__END__
