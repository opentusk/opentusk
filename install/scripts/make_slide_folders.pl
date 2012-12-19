#!/usr/bin/perl
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


use File::Path;
use FindBin;
use lib "$FindBin::Bin/../../lib";

use strict;
use TUSK::UploadContent;
use HSDB4::Constants;

foreach my $cur_size ( @HSDB4::Constants::image_sizes ) {
	next if ($cur_size eq 'resize');

	for my $a (0..9) {
		doMkDir( $TUSK::UploadContent::path{'slide'} . '/' . $cur_size . '/' . $a );
		for my $b (0..9) {
			doMkDir( $TUSK::UploadContent::path{'slide'} . '/' . $cur_size .  '/' . $a . '/' . $b );
			for my $c (0..9) {
				doMkDir( $TUSK::UploadContent::path{'slide'} . '/' . $cur_size .  '/' . $a . '/' . $b . '/' . $c );
			}
		}
	}
}

foreach my $cur_size ( @HSDB4::Constants::image_sizes ) {
	next if ($cur_size eq 'resize' || $cur_size eq 'thumb' || $cur_size eq 'icon');

	for my $a (0..9) {
		doMkDir( $TUSK::UploadContent::path{'slide'} . '/overlay/' . $cur_size . '/' . $a );
		for my $b (0..9) {
			doMkDir( $TUSK::UploadContent::path{'slide'} . '/overlay/' . $cur_size .  '/' . $a . '/' . $b );
			for my $c (0..9) {
				doMkDir( $TUSK::UploadContent::path{'slide'} . '/overlay/' . $cur_size .  '/' . $a . '/' . $b . '/' . $c );
			}
		}
	}
}

sub doMkDir {
	my $dir = shift;
	print "doMkDir($dir)\n";
	unless(mkpath($dir)) {print "Unable to mkdir $dir : $!\n";}
}
