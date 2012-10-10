#! /usr/bin/perl -w

use strict;

use File::stat;
use MySQL::Password;
use HSDB4::Constants;
use HSDB4::SQLRow::Content;
use TUSK::UploadContent;
use Date::Format;




my ($user_name, $password) = get_user_pw();
HSDB4::Constants::set_user_pw($user_name, $password);

my $confirmation;

do {
    print "Do you want to run in debug mode (i.e., just report data, don't actually do anything) (y/n): ";
    $confirmation = lc(<>);
    chomp $confirmation;
} while $confirmation ne 'y' && $confirmation ne 'n';

my $debug = ($confirmation eq 'y')? 1 : 0;

my $stamp = time2str("%Y%m%d.%H%M%S", time);
open my $fh, ">conversion.out.$stamp" or die $!;



my @tuskdocs = HSDB4::SQLRow::Content->new->lookup_conditions('type="tuskdoc"', 'order by content_id asc');

my ($doc_count, $docx_count, $doc_and_docx_count, $total, $num_formats, $no_uri) = (0,0,0,0,0,0);

foreach my $td (@tuskdocs) {
	$total++;

	my $fname_doc  = $TUSK::UploadContent::path{'doc-archive'} . '/' . $td->primary_key() . '.doc';
	my $fname_docx = $TUSK::UploadContent::path{'doc-archive'} . '/' . $td->primary_key() . '.docx';

	my $file_uri;
	if (-e ($fname_doc) ) {
		$doc_count++;
		$num_formats++;
		$file_uri = $fname_doc;
	}
	if (-e ($fname_docx) ) {
		$docx_count++;
		$num_formats++;
		$file_uri = $fname_docx;
	}

	if ($num_formats > 1) {
		$doc_and_docx_count++;
		my $doc_mod = stat($fname_doc)->mtime;
		my $docx_mod = stat($fname_docx)->mtime;

		print $fh $td->primary_key() . "\n";
		print $fh "doc  mod: $doc_mod\n";
		print $fh "docx mod: $docx_mod\n";
		
		if ($doc_mod > $docx_mod) {
			if ($debug) {
				print $fh "would unlink docx\n\n";
			}
			else {
				print $fh "unlinking docx\n\n";
				unlink $fname_docx;
			}
		}
		else {
			if ($debug) {
				print $fh "would unlink doc\n\n";
			}
			else {
				print $fh "unlinking doc\n\n";
				unlink $fname_doc;
			}
		}
	}

	unless ($file_uri) {
		$no_uri++;
		print $fh "no uri: " . $td->primary_key() . "\n";
	}

	$num_formats = 0;
}

print $fh "TOTALS\n";
print $fh "nuri: $no_uri\n";
print $fh "doc:  $doc_count\n";
print $fh "docx: $docx_count\n";
print $fh "both: $doc_and_docx_count\n";
print $fh "tot:  $total\n";

close $fh;
