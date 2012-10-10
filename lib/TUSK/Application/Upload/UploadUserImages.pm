package TUSK::Application::Upload::UploadUserImages;

use strict;

use HSDB4::SQLRow::User;
use TUSK::Constants;
use File::Copy;
use File::Type;
use IO::File;
use DBI qw(:sql_types);

my $CHUNK_SIZE = 32768; # for calls to 'read' 

sub check_file {
# check file extensions, file size
	my ($fn,$f_ext,$f_size) = @_;

	my @extensions = ("jpg","png","jpeg","gif", "bmp");
	my $max_size = 4000000;
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
	#### THIS HAS CHANGED 8/9/10 scorde01
	# now we are deleting any/all images in the dir and adding our file as the official image
	# this will most likely change in the future


	# method to check types are correct and size limit ok  with success/failure response
	my ($is_valid,$msg) = check_file($fn,$fileext,$fsize);
	if ($is_valid ==0) { return ($is_valid,$msg); }
		

	if ($found_user == 1) {

		#user_path is the dir path that will contain all images for a given student
		my $user_path = $TUSK::Constants::userImagesPath . "/".$uid;

		if (-d $user_path ) {} else { mkdir($user_path) };

		opendir(DIR, $user_path) or die "can't opendir : $!";
		my @thefiles = readdir(DIR);
		foreach my $tfile (@thefiles) {
			if($tfile ne "." && $tfile ne "..") {
		   
				$tfile = $user_path."/".$tfile;
				$tfile =~/(.*)/; #untaint 
				my $tf = $1;
				unlink $tf || warn $!;
			}
		}
		closedir(DIR);

		my $file_nm = "official";
	    my $full_path = $user_path."/$file_nm.".$fileext;
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
