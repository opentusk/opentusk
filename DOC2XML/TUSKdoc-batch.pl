use warnings;
use strict;
use FindBin;
use lib "$FindBin::Bin/../lib";
use TUSK::Constants;
require 'TUSK-Windows.pm';

my $host		= 'fetch.tusk.tufts.edu';
my $pscp_location	= 'C:\TUSKdoc\putty\pscp -unsafe';                              ##Location of pscp
my $doc_base_dir	= 'C:\TUSKdoc';
my $server_user		= 'tusk';
my $native_doc_dir	= $TUSK::Constants::BaseTUSKDocPath . '/native';
my $processed_doc_dir	= $TUSK::Constants::BaseTUSKDocPath . '/processed';
my $doc_in_dir		= $doc_base_dir . '\in';
my $doc_out_dir		= $doc_base_dir . '\out';### must match what is in config file
my $doc_to_xml_command	= 'C:\TUSKdoc\exe\20100830\DOCtoXML.exe';
my $plink_location      = 'C:\TUSKdoc\putty\plink ';                                    ##Location of plink
my $server_command	= '/usr/local/tusk/current/bin/stuff_hscml_into_db';
my $update_status_cmd	= '/usr/local/tusk/current/bin/set_tuskdoc_processing';
my $file_count		= 0;

setEmailSubject("TUSKdoc-batch processing");

checkIfRunning();

print "Grabbing docs from $host\n";

system("$pscp_location $server_user\@$host:$native_doc_dir/* $doc_in_dir");

opendir(DOC, $doc_in_dir) or sendMail("Problem opening $doc_in_dir: $!");
while (defined(my $doc = readdir(DOC))){
	next unless ($doc =~ /\.docx?$/);
	print "Processing $doc\n";
	# change the upload_transaction status to "processing"
	system("$plink_location -ssh -l $server_user -load $host $update_status_cmd $doc 2>&1");
	$file_count++;
	
	# do TUSKdoc-batch command here
	system("$doc_to_xml_command $doc_in_dir\\$doc %err%");

	system("$plink_location -ssh -l $server_user -load $host rm $native_doc_dir\/$doc"); 
	system("del /Q \"$doc_in_dir\\$doc\"");
}

if ($file_count){
	# put the files
	print "Put files back to $host\n";
	system("$pscp_location $doc_out_dir\\*.xml $doc_out_dir\\*.err $server_user\@$host:$processed_doc_dir/");	

	print "Run remote command\n";
	system("$plink_location -ssh -l $server_user -load $host $server_command 2>&1");

	print "Going to remove the xml and err files.\n";
		
	# back up the xml files: remove
	system("copy \"$doc_out_dir\\*.xml\" \"c:\\TUSKdoc\\out_bak\\\"");

	# back up the err files: remove
	system("copy \"$doc_out_dir\\*.err\" \"c:\\TUSKdoc\\out_bak\\\"");
	
	# remove the xml files
	system("del /F /S /Q \"$doc_out_dir\\*.xml\"");
	
	# remove the err files
	system("del /F /S /Q \"$doc_out_dir\\*.err\"");
}
else {
	print "No files to process\n";
}

#At this point we have run successfully so write a 0 to the counter file
printToCountFile(0);

exitSystem('');





