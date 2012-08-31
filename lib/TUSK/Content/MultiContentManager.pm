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


package TUSK::Content::MultiContentManager;

=head1 NAME

B<TUSK::Content::MultiContentManager> - Class for manipulating entries in table multi_content_manager in tusk database

=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 INTERFACE


=head2 GET/SET METHODS

=over 4

=cut

use strict;
use Archive::Zip;
use File::Path;
use HSDB4::Image;
use TUSK::UploadContent;

BEGIN {
    require Exporter;
    require TUSK::Core::SQLRow;

    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
    
    @ISA = qw(TUSK::Core::SQLRow Exporter);
    @EXPORT = qw( );
    @EXPORT_OK = qw( );
}

use vars @EXPORT_OK;

# Non-exported package globals go here
use vars ();

my $CHUNK_SIZE = 32768;

sub new {
    # Find out what class we are
    my $class = shift;
    $class = ref $class || $class;
    # Call the super-class's constructor and give it all the values
    my $self = $class->SUPER::new ( 
				    _datainfo => {
					'database' => 'tusk',
					'tablename' => 'multi_content_manager',
					'usertoken' => '',
					'database_handle' => '',
					},
				    _field_names => {
					'multi_content_manager_id' => 'pk',
					'status' => '',
					'error' => '',
					'uploaded_file_name' => '',
					'directory' => '',
					'zip_file' => '',
					'zip_entities' => '',
					'zip_entities_extracted' => '',
					'previews_to_generate' => '',
					'previews_generated' => '',
					'size' => '',
				    },
				    _attributes => {
					save_history => 0,
					tracking_fields => 1,	
				    },
				    _levels => {
					reporting => 'cluck',
					error => 0,
				    },
				    @_
				  );
    # Finish initialization...
    return $self;
}

### Get/Set methods

#######################################################

=item B<getStatus>

my $string = $obj->getStatus();

Get the value of the status field

=cut

sub getStatus{
    my ($self) = @_;
    return $self->getFieldValue('status');
}

#######################################################

=item B<setStatus>

$obj->setStatus($value);

Set the value of the status field

=cut

sub setStatus{
    my ($self, $value) = @_;
    $self->setFieldValue('status', $value);
}


#######################################################

=item B<getError>

my $string = $obj->getError();

Get the value of the error field

=cut

sub getError{
    my ($self) = @_;
    return $self->getFieldValue('error');
}

#######################################################

=item B<setError>

$obj->setError($value);

Set the value of the error field

=cut

sub setError{
    my ($self, $value) = @_;
    $self->setFieldValue('error', $value);
}


#######################################################

=item B<getUploadedFileName>

my $string = $obj->getUploadedFileName();

Get the value of the uploaded_file_name field

=cut

sub getUploadedFileName{
    my ($self) = @_;
    return $self->getFieldValue('uploaded_file_name');
}

#######################################################

=item B<setUploadedFileName>

$obj->setUploadedFileName($value);

Set the value of the uploaded_file_name field

=cut

sub setUploadedFileName{
    my ($self, $value) = @_;
    $self->setFieldValue('uploaded_file_name', $value);
}


#######################################################

=item B<getDirectory>

my $string = $obj->getDirectory();

Get the value of the directory field

=cut

sub getDirectory{
    my ($self) = @_;
    return $self->getFieldValue('directory');
}

#######################################################

=item B<setDirectory>

$obj->setDirectory($value);

Set the value of the directory field

=cut

sub setDirectory{
    my ($self, $value) = @_;
    $self->setFieldValue('directory', $value);
}


#######################################################

=item B<getZipFile>

my $string = $obj->getZipFile();

Get the value of the zip_file field

=cut

sub getZipFile{
    my ($self) = @_;
    return $self->getFieldValue('zip_file');
}

#######################################################

=item B<setZipFile>

$obj->setZipFile($value);

Set the value of the zip_file field

=cut

sub setZipFile{
    my ($self, $value) = @_;
    $self->setFieldValue('zip_file', $value);
}


#######################################################

=item B<getZipEntities>

my $string = $obj->getZipEntities();

Get the value of the zip_entities field

=cut

sub getZipEntities{
    my ($self) = @_;
    return $self->getFieldValue('zip_entities');
}

#######################################################

=item B<setZipEntities>

$obj->setZipEntities($value);

Set the value of the zip_entities field

=cut

sub setZipEntities{
    my ($self, $value) = @_;
    $self->setFieldValue('zip_entities', $value);
}



#######################################################

=item B<getZipEntitiesExtracted>

my $string = $obj->getZipEntitiesExtracted();

Get the value of the zip_entities_extracted field

=cut

sub getZipEntitiesExtracted{
    my ($self) = @_;
    return $self->getFieldValue('zip_entities_extracted');
}

#######################################################

=item B<setZipEntitiesExtracted>

$obj->setZipEntitiesExtracted($value);

Set the value of the zip_entities_extracted field

=cut

sub setZipEntitiesExtracted{
    my ($self, $value) = @_;
    $self->setFieldValue('zip_entities_extracted', $value);
}

#######################################################

=item B<getPreviewsToGenerate>

my $string = $obj->getPreviewsToGenerate();

Get the value of the previews_to_generate field

=cut

sub getPreviewsToGenerate{
    my ($self) = @_;
    return $self->getFieldValue('previews_to_generate');
}

#######################################################

=item B<setPreviewsToGenerate>

$obj->setPreviewsToGenerate($value);

Set the value of the previews_to_generate field

=cut

sub setPreviewsToGenerate{
    my ($self, $value) = @_;
    $self->setFieldValue('previews_to_generate', $value);
}


#######################################################

=item B<getPreviewsGenerated>

my $string = $obj->getPreviewsGenerated();

Get the value of the previews_generated field

=cut

sub getPreviewsGenerated{
    my ($self) = @_;
    return $self->getFieldValue('previews_generated');
}

#######################################################

=item B<setPreviewsGenerated>

$obj->setPreviewsGenerated($value);

Set the value of the previews_generated field

=cut

sub setPreviewsGenerated{
    my ($self, $value) = @_;
    $self->setFieldValue('previews_generated', $value);
}

#######################################################

=item B<getSize>

my $string = $obj->getSize();

Get the value of the size field (upload file size)

=cut

sub getSize{
    my ($self) = @_;
    return $self->getFieldValue('size');
}

#######################################################

=item B<setSize>

$obj->setSize($value);

Set the value of the size field (upload file size)

=cut

sub setSize{
    my ($self, $value) = @_;
    $self->setFieldValue('size', $value);
}

#######################################################

=item B<getPrettySize>

my $string = $obj->getPrettySize($value);

Set the value of the size field (upload file size) in pretty format

=cut

sub getPrettySize{
	my ($self) = @_;

	my $myFileSize = $self->getSize();
	my $fileSizeIndex = 0;
	my @fileSizes = ( 'b', 'Kb', 'Mb', 'Gb', 'Tb' );
	while(($myFileSize/1000) > 1 && $fileSizeIndex < scalar(@fileSizes)) {
		$myFileSize =  sprintf("%.2f", ($myFileSize/1000));
		$fileSizeIndex++;
	}
	return "$myFileSize $fileSizes[$fileSizeIndex]";
}

#######################################################

=item B<upload>

($returnValue) = $obj->upload($filename, $filehandle);

Set the status to 'uploading' and perform the upload writing the file to disk

=cut

sub upload {
	my ($self, $filename, $filehandle) = @_;

	# Create us a temp directory unless we already have one and its created.
	unless($self->getDirectory() && -d $self->getDirectory()) {
		my $directoryName = $TUSK::UploadContent::path{'temp'} ."/". $$ . "_". time;
		$self->setDirectory($directoryName);
		unless($self->cleanAndBuildDir($directoryName)) {return 0;}
	}

	my $fileName = $self->getDirectory() ."/$filename";

	$self->setStatus('uploading');

	unless(open(FILE, ">$fileName")) {
		warn("Unable to open file for write (filename $fileName): $!\n");
		$self->setError('Unable to save file to server');
		$self->save();
		return(0);
	}
	binmode FILE;
	my $buffer;
	while (my $bytesread = read($filehandle, $buffer, $CHUNK_SIZE)){
		print FILE $buffer;
	}
	close FILE;
	my $myFileSize = -s $fileName;
	$self->setSize($self->getSize() + $myFileSize);

	return (1);
}

#######################################################

=item B<cleanAndBuildDir>

($returnValue) = $obj->cleanAndBuildDir($dirName);

Clean up and rebuild the specified directory

=cut

sub cleanAndBuildDir {
	my ($self, $directoryName) = @_;

	unless($directoryName) {
		warn("No directory name was passed to TUSK::MultiContentUpload::cleanAndBuildDir\n");
		return(0);
	}

	# if we've already made a directory (from a previous run) then we need to wipe it out
	if(-d $directoryName) { rmtree([$directoryName]); }

	# I really hope this dosen't fail since we just wiped the dir out if it existed
	unless(mkdir($directoryName)) {
		warn("Unable to create $directoryName: $!\n");
		$self->setError('Unable to create temp directory');
		$self->save();
		return (0);
	}
}

#######################################################

=item B<uploadZipFile>

($returnValue) = $obj->uploadZipFile($filename, $filehandle);

Set the status to 'uploading' and perform the upload writing the file to disk

=cut

sub uploadZipFile {
	my ($self, $filename, $filehandle) = @_;

	# Create us a temp directory
	my $directoryName = $self->getDirectory();
	unless($self->getDirectory()) {
		$directoryName = $TUSK::UploadContent::path{'temp'} ."/". $$ . "_". time;
		$self->setDirectory($directoryName);
	}

	# Create us a zip file at the same location as the temp directory
	my $extension = lc($filename);
	if ($extension =~ /^.*\.([a-z0-9]+)$/) {
		$extension = $1;
	}
	else {
		warn("Extension came in with junk\n");
		$extension = '';
	}
	unless($extension) {
		warn("No extension passed, assuming .zip file\n");
		$extension = "zip";
	}
	my $zipName = "${directoryName}.${extension}";

	$self->setUploadedFileName($filename);
	$self->setZipFile($zipName);
	$self->setStatus('uploading');

	unless(open(ZIP_FILE, ">$zipName")) {
		warn("Unable to open file for write (filename $zipName): $!\n");
		$self->setError('Unable to save file to server');
		$self->save();
		return(0);
	}
	binmode ZIP_FILE;
	my $buffer;
	while (my $bytesread = read($filehandle, $buffer, $CHUNK_SIZE)){
		print ZIP_FILE $buffer;
	}
	close ZIP_FILE;
	my $myFileSize = -s $zipName;
	$self->setSize($myFileSize);

	# This call does the save for us.
	$self->setUploadComplete();
	return (1);
}

#######################################################

=item B<setUploadComplete>

($returnValue) = $obj->setUploadComplete();

Set the status to 'upload complete'

=cut

sub setUploadComplete {
	my ($self) = shift;
        $self->setStatus('upload complete');
        $self->save();
}

#######################################################

=item B<extract>

($returnValue) = $obj->extract();

Given the name of the zip file, extract the files

=cut

sub extract {
	my ($self) = @_;

	# This will only be set if we uploaded one zip file
	unless($self->getZipFile()) {
		$self->setStatus('extraction complete');
		$self->save();
		return (1);
	}

	my $directoryName = $self->getDirectory();
	unless($self->cleanAndBuildDir($directoryName)) {return 0;}
	$self->setStatus('extracting');

	# See if we can determine the archive type
	my $extension = lc($self->getZipFile());
	$extension =~ s/^.*\.//g;
	my $numExtracted = 0;
	if($extension eq 'zip') {
		my $zip;
		eval { $zip = Archive::Zip->new( $self->getZipFile() );  };
		if($@) {
			warn("Exception caught when unarchiving: $@\n");
			$self->setError("Exception caught when unarchiving: $@");
			$self->save();
			return(0);
		}

		my $numberOfExtractedFiles = 0;
		$self->setZipEntities(scalar($zip->members()));
		$self->save();
		foreach my $fileInZip ($zip->members()) {
			# Is there a way that we can check to see if this is a directory or not?
			unless($fileInZip->isDirectory()) {
				my $newFileName = $fileInZip->fileName() ;
				# untaint $newFileName by removing any extra /./ or /../ in the file name
				$newFileName =~ s/\/\.+\///g;
				# Change slashes into . (flatten the directory structure so all files are in this directory)
				$newFileName =~ s/\//\./g;
				$newFileName =~ /(.*)/;
				$newFileName = $1;

				my $unableToUnzipMessage = '';
				eval {
					unless($zip->extractMember($fileInZip->fileName(), $directoryName ."/". $newFileName) == Archive::Zip::AZ_OK ) {
						$unableToUnzipMessage = $!;
					}
				}; if($@) { $unableToUnzipMessage = $@; }
				if($unableToUnzipMessage) {
					warn("Unable to to extract file ". $fileInZip->fileName() ." from ". $self->getZipFile() .": $unableToUnzipMessage\n");
					$self->setError("Unable to extract ". $fileInZip->fileName());
					$self->save();
					return(0);
				}
				$numExtracted++;
			}
			$self->setZipEntitiesExtracted( $numExtracted );
			$self->save();
		}
		$self->setStatus('extraction complete');
		$self->save();
		return(1);
	} else {
		warn("TUSK::UploadContent::unarchive_file does not know how to extract a $extension file (". $self->getUploadedFileName() .")\n");
		$self->setError("Unable to unarchive ". $self->getUploadedFileName() );
		$self->save();
		return(0);
	}
}

#######################################################

=item B<getPreviewDirectory>

($returnValue) = $obj->getPreviewDirectory();

Get the directory name which will hold the previews.

=cut

sub getPreviewDirectory {
	my $self = shift;
	unless($self->getDirectory()) {return undef;}
	return $self->getDirectory() . "_previews";
}

#######################################################

=item B<generatePreviewes>

($returnValue) = $obj->generatePreviewes();

Generate all of the previews

=cut

sub generatePreviews {
	my $self = shift;
	$self->setStatus('previews');

	my $directoryName = $self->getPreviewDirectory();
	unless($self->cleanAndBuildDir($directoryName)) {return 0;}

	# Lets scan the directory to see if we have any kind of image that needs a generated preview
	my @unzippedFiles = $self->readFiles( $self->getDirectory() );

	# We really could have done this in one step but we want to be able to setPreviewsToGenerate
	my @previewsToGenerate;
	foreach my $fileName (@unzippedFiles) {
		if(TUSK::UploadContent::get_content_type_from_file_ext($fileName) eq 'Slide') { push @previewsToGenerate, $fileName; }
	}

	$self->setPreviewsToGenerate(scalar(@previewsToGenerate));
	$self->save();

	my $previewsGenerated = 0;
	foreach my $genPreviewFrom (@previewsToGenerate) {
		my $actualFileName = $genPreviewFrom;
		$actualFileName =~ s/^.*\///;

		my $previewName = "$directoryName/$actualFileName.jpg";
		# something has tainted previewName so we need to untaint
		$previewName =~ s/(.*)//;
		$previewName = $1;
		unless(open(PREVIEW, ">$previewName")) {warn("Unable to create new preview file $previewName : $!\n");}
		else {
			binmode(PREVIEW);
			my ($blob, $type, $width, $height) = HSDB4::Image::make_small(-filename => $genPreviewFrom, -type => 'jpg', -blur => "-1");
			unless($blob) {warn("Unable to create preview for $genPreviewFrom\n");}
			else {
				print PREVIEW $blob;
				$previewsGenerated++;
				$self->setPreviewsGenerated( $previewsGenerated );
				$self->save();
			}
			close(PREVIEW);
		}
	}
	$self->setStatus('previews complete');
	$self->save();
}


#######################################################

=item B<readFiles>

@filesInDir = $obj->readFiles();

read all of the files in a directory (recursivly)

=cut

sub readFiles {
	my $self = shift;
	my $dirName = shift;
	my @returnFiles;
	unless(opendir(DIR, $dirName)) {
		warn("Can't read $dirName\n");
	} else {
		foreach (grep !/^\.{1,2}$/, readdir(DIR)) {
			my $fileName = "$dirName/$_";
			if(-d $fileName)	{ push @returnFiles, $self->readFiles($fileName); }
			elsif(-f $fileName)	{ push @returnFiles, $fileName; }
			else			{ warn("$fileName is neither a file or a dir, ignoring\n");}
		}
	}
	return @returnFiles;
}


#######################################################

=item B<is_user_authorized>

($user_has_permissions) = $obj->returnFiles();

See if the user ID passed in has permissions to look at this multicontent

=cut

sub is_user_authorized {
	my $self = shift;
	my $userID = shift;

	if($userID eq 'admin') {return 1;}
	if($userID eq $self->getCreatedBy()) {return 1;}
	return 0;
}


=back

=cut

### Other Methods

=head1 BUGS

None Reported.

=head1 SEE ALSO

B<TUSK::Core::SQLRow> - parent class

=head1 AUTHOR

TUSK Development Team <tuskdev@tufts.edu>

=head1 COPYRIGHT

Copyright (c) Tufts University Sciences Knowledgebase, 2004.

=cut

1;

