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


package HSDB4::Image;

use strict;
use IO::File;
use FileHandle;
use Image::Magick;
use Image::Size;

use vars ('%Types');

%Types =  ('GIF'  => 'image/gif',
	   'JPEG' => 'image/jpeg',
	   'JPG' => 'image/jpeg',
	   'PNG'  => 'image/png',
	  );

# Make a regex pattern for matching the file types
my $types_pat = '(' . join ('|', keys %Types) . ')';

sub figure_type {
    #
    # Figure a type from a filename
    #

    my $filename = shift;
    my ($type) = $filename =~ /\.$types_pat$/i 
      or die "Could not figure out what type file $filename is.";
    return uc $type;
}

sub raw_image {
    #
    # Take a filename and return the data of the unedited image
    #

    my $filename = shift;
    die "Cannot find file $filename" unless -e $filename;
    my $type = $Types{figure_type $filename};
    my ($w, $h) = imgsize ($filename);
    my $data;
    {
	open FILE, $filename or die "Cannot open $filename";
	local $/ = undef;
	$data = <FILE>;
	close FILE;
    }
    return ($data, $type, $w, $h);
}

sub size_image {
    #
    # Take an image filename/filehandle, and a max size for the larger
    # and return its data, MIME type, height and width
    #

    # Arguments:
    #   Either:
    #     -filehandle AND -type
    #   Or
    #     -filename (with a recognizable type)
    #     -maxsize  : Size along larger dimension
    #     -square   : If it's to be cropped square
    #

    my %args = @_;
    my ($i, $type, $fh, $filename);

  # If we get a filehandle and a size...
    if ($args{-filehandle} && $args{-type}) {
	# Then we'll use those
	#
	# !!!! Check this code before incorporting into stuff...
	#
	$fh = $args{-filehandle};
	# Reset the filehandle
	$fh->seek (0, 0);
	$type = uc $args{-type};
	die "Could not recognize type $type" unless $Types{$type};
	$filename = "tmp.$type";
	$i = Image::Magick->new (magick => $type);
	my $rv = $i->Read (file=>$fh, filename => $filename);
	#
	# !!!!!
    }
    if($args{-blob}){
	$type = uc $args{-type};
	$i=Image::Magick->new(magick=>$type);
	$i->BlobToImage($args{-blob});
    }
    # Otherwise, if we get a filename...
    if ($args{-filename} && -e $args{-filename}) {
	$type = figure_type $args{-filename};
	# And create a brand new file handle which is nice and open
	$i = Image::Magick->new ();
	$i->Read ($args{-filename});
    }

    # And if neither of those worked, we have to call it quits
    unless ($i) {
	die "Could not find an image to size";
    }

    # Check for a sensible maxsize
    die "Bad maxsize: $args{-maxsize}" unless $args{-maxsize} >= 8;

    # Get the width and height
    my ($in_w, $in_h) = $i->Get ('base-columns', 'base-rows');
    my ($out_w, $out_h) = ($in_w, $in_h);
    # Now check for one to be a problem
    if ($in_w > $args{-maxsize} or $in_h > $args{-maxsize}) {
	# If it's too wide...
	if ($in_w > $in_h) {
	    # Crop it square, if required
	    if ($args{-square}) {
		my $left = int (($in_w - $in_h) / 2);
		$i->Crop (geometry=>"${in_h}x${in_h}+${left}+0");
		$in_w = $in_h;
	    }
	    # Scale it appropriately
	    $i->Scale (width => ($out_w = $args{-maxsize}),
		       height =>
		       ($out_h = int ($in_h * $args{-maxsize} / $in_w))
		      );
	}
	# If it's too tall...n
	else {
	    # Crop it square, if required
	    if ($args{-square}) {
		my $top = int (($in_h - $in_w) / 2);
		$i->Crop (geometry=>"${in_h}x${in_h}+0+$top");
		$in_h = $in_w;
	    }
	    # Scale it appropriately
	    $i->Scale (height => ($out_h = $args{-maxsize}),
		       width =>
		       ($out_w = int ($in_w * $args{-maxsize} / $in_h))
		      );
	}
    }
    return ($i->ImageToBlob(), $Types{$type}, $out_w, $out_h);
}

sub cleanJPGheader{
	my $old_binary=shift;
	my $temp_dir="/tmp";
	my $rand = rand(time());
	my $randname = time().$rand;

	undef $ENV{PATH};

	open (BIN,">$temp_dir/temp$randname.jpg");
	print BIN $old_binary;
	close(BIN);
	`/usr/local/bin/jpegtran -copy none $temp_dir/temp$randname.jpg > $temp_dir/convert$randname.jpg`;
	open(BIN,"$temp_dir/convert$randname.jpg") or die "can't open cleaned jpg image";
	local undef $/;
	my $new_binary = <BIN>;
	close(BIN);
	unlink "$temp_dir/temp$randname.jpg";
	unlink "$temp_dir/convert$randname.jpg";
	return $new_binary;        
}

sub make_original {
    # this isn't supposed to change the size at all
    return size_image (-maxsize => 5000, @_);
}

sub make_xlarge {
    return size_image(-maxsize => 700, @_);
}

sub make_large {
    return size_image(-maxsize => 520, @_);
}

sub make_medium {
    return size_image(-maxsize => 360, @_);
}

sub make_small {
    return size_image(-maxsize => 200, @_);
}

sub make_thumb {
    return size_image(-maxsize => 72, @_);
}

sub make_icon {
    return size_image(-maxsize => 30, @_);
}

sub make_fullscreen {
    #
    # Wrapper for doing the fullscreen thing
    #

    #
    # Takes filename or whatever and does the righthing with it
    # Arguments:
    #   Either:
    #     -filehandle AND -type
    #   Or
    #     -filename (with a recognizable type)

    return size_image (-maxsize => 520, @_);
}

sub make_halfscreen {
    #
    # Wrapper for doing the fullscreen thing
    #

    #
    # Takes filename or whatever and does the righthing with it
    # Arguments:
    #   Either:
    #     -filehandle AND -type
    #   Or
    #     -filename (with a recognizable type)

    return size_image (-maxsize => 360, @_);
}

sub make_thumbnail {
    #
    # Wrapper for doing the thumbnail thing
    #

    #
    # Takes filename or whatever and does the righthing with it
    # Arguments:
    #   Either:
    #     -filehandle AND -type
    #   Or
    #     -filename (with a recognizable type)

    return size_image (-maxsize => 72, -square => 1, @_);
}


1;

__END__
