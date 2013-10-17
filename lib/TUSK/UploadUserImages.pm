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


package TUSK::UploadUserImages;

use strict;

use HSDB4::SQLRow::Content;
use HSDB4::SQLRow::PPTUpload;
use HSDB4::Constants;
use HSDB4::SQLRow::User;
use TUSK::Constants;
use TUSK::Core::LinkContentKeyword;
use TUSK::Content::External::LinkContentField;
use TUSK::Content::External::Field;
use File::Copy;
use File::Type;
use IO::File;
use DBI qw(:sql_types);
use Data::Dumper;


my $CHUNK_SIZE = 32768; # for calls to 'read' 


sub check_file {
# check file extensions, file size
	my ($fn,$f_ext,$f_size) = @_;

	my @extensions = ("jpg","png","jpeg","gif", "bmp");
	my $max_size = 400000;
	my $msg;
	my $validity =0;

	foreach my $ext (@extensions) {
		if ($f_ext eq $ext) { $validity=1; }
	}
	
	if ($f_size > $max_size) {
		my $mbytes = $max_size / 100000;
		$msg = "File $fn is too large, the maximum file size is $mbytes megabytes";
	}

	if ($validity == 0) {
		$msg = "File $fn failed. Files of type '.$f_ext' are not allowed.";
	}

	return ($validity,$msg);
}

sub determine_user_by_utln {

	my ($fn) = @_;
	my @fields = split(/\./, $fn);
	my $utln = $fields[0];

	my $user = HSDB4::SQLRow::User->new->lookup_key($utln);
	
	if($user){
		return (1,$user->uid());
	} else {
		return (0,"Could not find a user matching $fn, please check that the filename is correct and try again");
	}

}

sub determine_user {
# find user that corresponds to uploaded file

	my ($fn) = @_;

	my @fields = split(/\./, $fn);
	my $lastn = $fields[0];
	my $firstn = $fields[1];
	my $result =0;
	my $msg ="";
	my @user;

	#we might get a first initial of first name, or get the whole first name... SURPRISE
	if (length($firstn) == 1) {
		# my first use of SUBSTRING in a query, as far as I remember
		@user = HSDB4::SQLRow::User->lookup_conditions("lastname = '$lastn'", "SUBSTRING(firstname,1,1) = '$firstn'");
	} else {
		@user = HSDB4::SQLRow::User->lookup_conditions("lastname = '$lastn'", "firstname = '$firstn'");
	}
	my $num_users = @user;

	if ($num_users == 1) {
		return(1,$user[0]->uid());
	} elsif ($num_users == 0) {
		($result,$msg) = determine_user_by_utln($fn);
		return($result,$msg);
	} else {
		return(0, "Multiple users where found matching $fn , please try again with a more specific file name.");
	}
	
	
}

sub upload_file{

    my ($fn,$fh,$fsize) = @_;
    my $body;
	
	$fn = lc($fn);
	# method to correspond image with a user in user table based on type of filename pattern used
	my ($found_user, $uid) = determine_user($fn);
	
    (my $fileext = $fn) =~ s/.*\.//; # we do not need the period
    $fileext = "" if ($fileext eq $fn);

	# if everything succeeds, now determine if users dir already exists, if not create it
	# determine # of pics in the dir if exists, change file name to reflect this
    # finally write the file and throw back success
	
	# method to check types are correct and size limit ok  with success/failure response
	my ($is_valid,$msg) = check_file($fn,$fileext,$fsize);
	if ($is_valid ==0) { return ($is_valid,$msg); }
		

	if ($found_user == 1) {

		#user_path is the dir path that will contain all images for a given student
		my $user_path = $TUSK::Constants::UserImagesPath . "/".$uid;
		if (-d $user_path ) {} else { mkdir($user_path) };

		#determine how many images are already in the user's dir
		my $file_count =0;
		my $files;
		opendir(DIR, $user_path) or die "can't opendir $user_path: $!";
		while (defined($files = readdir(DIR))) {
			$file_count++;
		}
		closedir(DIR);

		# so file_count will always return at least two because it counts "." and ".." as files, go figure
		# therefore a little math before the naming of the new file. we want the new file name to be the # 
		# of images that'll be in the dir, so just subtract one since two are already there. 

		$file_count--;
		
        my $full_path = $user_path."/$file_count.".$fileext;
		my $FILE;
		if (open ($FILE, ">$full_path")) { 
			binmode $FILE; # not necessary on most unixes?
			my $bytesread;
		
			my $buffer;
			while ($bytesread = read($fh, $buffer, $CHUNK_SIZE)){
				$body .= $buffer;
			}

			print $FILE $body;
			close $FILE;
			close ($fh);

			unless($body) {return(0, "Error saving file: no data!");}

		} else {
			return (0, "Error saving file $fn");
		}
	} else { 
		return(0,$uid);
	}
	return (1, "$fn added successfully");
}
