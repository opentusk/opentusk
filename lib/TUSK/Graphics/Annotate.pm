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


package TUSK::Graphics::Annotate;

use strict;
use Image::Magick;
use HSDB4::SQLRow::Content;
use Carp;


sub annotateImage {
	my $bin = shift;
	my $annotateText = shift;

	my $im = Image::Magick->new();
	$im->BlobToImage($bin);

	my $pointsize = 12;
	my $threshold = 65536 / 2; # taken from Image Magick

	my $crop = $im;
	my $height = $crop->Get('height');
	my $width = $crop->Get('width');

	# this crop will have to change if the gravity in the Annotate is customizable
	$crop->Crop('width'=> 5.5*length($annotateText), 'height'=>$pointsize, x=>$width-5.5*length($annotateText), y=>$height-$pointsize);

	my $pixel_count = 0;

	my $total = {};

	foreach my $x (0..5*50-1){
		foreach my $y (0..(12-1)){
			my ($r, $g, $b) = split(',', $crop->Get("pixel[$x,$y]"), 3);
			$total->{'r'} += $r;
			$total->{'g'} += $g;
			$total->{'b'} += $b;
			$pixel_count++;
		}
	}

	my $count = 0;

	foreach my $i (keys %$total){
	$count++ if ($total->{$i} / $pixel_count < $threshold);
	}

	my $fill = ($count > 1) ? "white" : "black";

	$im = Image::Magick->new();
	$im->BlobToImage($bin);
	$im->Annotate(font=>'Helvetica',
                  fill=>$fill,
                  gravity=>'SouthEast',
                  x=>1,
                  pointsize=>$pointsize,
                  text=>$annotateText);
	
	return $im->ImageToBlob();   
}

1;
