package TUSK::Content::MSTextExtractor;

=head1 NAME

B<TUSK::Content::MSTextExtractor> - Class for extracting text from a .[doc|ppt]x document

=head1 SYNOPSIS

This module will take a docx file name, extract specific pieces of the archive and xslt said pieces into text.

=head1 DESCRIPTION

This is based off http://stackoverflow.com/questions/1110409/how-can-i-programmatically-convert-word-doc-or-docx-files-into-text-files
Per the thread, the .xsl files are from http://cvs.forge.objectweb.org/cgi-bin/viewcvs.cgi/snapper/Snapper/snapperPreviewer/presentation/resource/xsl/


=head1 INTERFACE

=head2 GET/SET METHODS

=over 4

=cut

use strict;
use Archive::Zip qw( :ERROR_CODES :CONSTANTS );
use XML::LibXML;
use XML::LibXSLT;
use TUSK::Core::Logger;

BEGIN {
	require Exporter;

	use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
    
	@ISA = qw();
	@EXPORT = qw( );
	@EXPORT_OK = qw( );
}

use vars @EXPORT_OK;

# Non-exported package globals go here
use vars ();

my $TUSK_Logger = TUSK::Core::Logger->new();

sub new {
	# Find out what class we are
	my $class = shift;
	$class = ref $class || $class;
	my $self = {};
	# Finish initialization...
	bless $self, $class;

	return $self;
}


sub getDocumentText {
	my $self = shift;
	my $documentToParse = shift;

	$TUSK_Logger->logDebug("Starting get document text with $documentToParse", "mstextextractor");
	unless( -f $documentToParse) {
		$TUSK_Logger->logError("Passed document $documentToParse does not exist or is not a file!", "mstextextractor");
		return undef;
	}
	unless( -r $documentToParse) {
		$TUSK_Logger->logError("Passed document $documentToParse is not readable!", "mstextextractor");
		return undef;
	}

	my $text = undef;
	if($documentToParse =~ /\.doc$/) {
		$TUSK_Logger->logDebug("Going to call parseDoc with $documentToParse\n");
		$text = $self->parseDoc($documentToParse);
	} elsif($documentToParse =~ /x$/) {
		my $archive;
		eval { $archive = Archive::Zip->new( $documentToParse );  };
		if($@) {
			$TUSK_Logger->logError("Exception caught when unarchiving: $@", "mstextextractor");
			return undef;
		}
		$TUSK_Logger->logDebug("Archive opened.", "mstextextractor");

		if($documentToParse =~ /\.docx/) {
			$text = $self->parseDocx($archive);
		} elsif($documentToParse =~ /\.pptx/) {
			$text = $self->parsePPTx($archive);
		}
	} else {
		$TUSK_Logger->logError("Passed document $documentToParse is not in a convertable format", "mstextextractor");
	}
	return $text
}

sub parseDoc {
	my $self = shift;
	my $filename = shift;

	unless($TUSK::Constants::WordTextExtract) {
		$TUSK_Logger->logError("Asked to parse a regular .doc but antiword is not configured in TUSK::Constants", "mstextextractor");
		return undef;
	}

	unless(-e $TUSK::Constants::WordTextExtract) {
		$TUSK_Logger->logError("Asked to parse a regular but .doc configured $TUSK::Constants::WordTextExtract is not executable", "mstextextractor");
		return undef;
	}

	unless($filename) {
		$TUSK_Logger->logError("Asked to parse a regular .doc but no file name was given", "mstextextractor");
		return undef;
	}

	unless(open(WORDEXTRACT,$TUSK::Constants::WordTextExtract." $filename |")) {
		$TUSK_Logger->logError("Unable to execute ". $TUSK::Constants::WordTextExtract ."\n$!");
		return undef;
	}

	$TUSK_Logger->logDebug("Running antiword as: ". $TUSK::Constants::WordTextExtract." $filename", "mstextextractor");
		my @body_text = <WORDEXTRACT>;
	close WORDEXTRACT;
	return join(' ', @body_text);
}

sub parseDocx {
	my $self = shift;
	my $archive = shift;

	$TUSK_Logger->logDebug("Parsing docx.", "mstextextractor");
	my $extractedDocument = extractMember($self, $archive, 'word/document.xml');
	return $self->getText('docx2txt.xsl', \$extractedDocument);
}

sub parsePPTx {
	my $self = shift;
	my $archive = shift;
	my $extractedDocument = '';

	$TUSK_Logger->logDebug("Parsing pptx.", "mstextextractor");
	my @xmlFiles;
	push @xmlFiles, 'ppt/presentation.xml';
	push @xmlFiles, map { $_->fileName()} $archive->membersMatching( 'ppt/slides/slide.*\.xml' );
	#push @xmlFiles, map { $_->fileName()} $archive->membersMatching( 'ppt/slideMasters/slideMaster.*\.xml' );

	foreach my $xmlFile (@xmlFiles) {
		my $documentText = extractMember($self, $archive, $xmlFile);
		my $parsedText = $self->getText('pptx2txt.xsl', \$documentText);
		chomp $parsedText;
		if($parsedText) {$extractedDocument.= $parsedText ."\n"; }
	}
	return $extractedDocument;
}

sub extractMember {
	my $self = shift;
	my $archive = shift;
	my $docToExtract = shift;

	$TUSK_Logger->logDebug("Extracting member named $docToExtract from archive.", "mstextextractor");
	my $member = $archive->memberNamed( $docToExtract );
	$member->desiredCompressionMethod( COMPRESSION_STORED );
	my $status;
	my $buffer;
	$status = $member->rewindData();
	unless($status == AZ_OK) {
		$TUSK_Logger->logError("Unable to rewind the member for ${docToExtract}.", "mstextextractor");
		return undef;
	}
	my $document;
	while ( ! $member->readIsDone() ) {
		( $buffer, $status ) = $member->readChunk();
		if($status != AZ_OK && $status != AZ_STREAM_END) {
			$TUSK_Logger->logError("Error reading zip member! : $status", "mstextextractor");
			return undef;
		}
		$document .= $$buffer;
	}
	$member->endRead();
	$TUSK_Logger->logDebug("Completed the reading of the archive.", "mstextextractor");
	return $document;
}

sub getText {
	my $self = shift;
	my $stylesheetName = shift;
	my $contentRef = shift;

	$TUSK_Logger->logDebug("Starting to get the text for the document", "mstextextractor");
	my $parser = XML::LibXML->new();
	my $source;
	eval { $source = $parser->parse_string(${$contentRef}); };
	if($@) {
		$TUSK_Logger->logError("Exception caught when XML parsing document: $@\n${$contentRef}", "mstextextractor");
        	return undef;
	}

	# Update the location of he stylesheet.
	unless($ENV{SERVER_ROOT}) {
		$TUSK_Logger->logError("The SERVER_ROOT environment variable is undefined.", "mstextextractor");
		return undef;
	}
	my ($stylesheet) = ($ENV{SERVER_ROOT} =~ /^(.*)$/g);
	$stylesheet.= "/addons/ms_extractor/$stylesheetName";
	$TUSK_Logger->logDebug("Using the stylesheet $stylesheet.", "mstextextractor");

	my $xslt = XML::LibXSLT->new();
	eval {
		my $style_doc = $parser->parse_file($stylesheet);
		$stylesheet = $xslt->parse_stylesheet($style_doc);
	};
	if($@) {
		$TUSK_Logger->logError("Exception caught when XML parsing stylesheet: $@", "mstextextractor");
		return undef;
	}

	my $results;
	eval {
		$results =  $stylesheet->transform($source);
	};
	if ($@){
		$TUSK_Logger->logError("Exception caught when XSLT transforming docx: $@", "mstextextractor");
		return undef;
	}
	$TUSK_Logger->logDebug("Completed getting the text for document\n". $stylesheet->output_string($results), "mstextextractor");
	return $stylesheet->output_string($results) ."\n";
}


=back

=cut

### Other Methods

=head1 BUGS

None Reported.

=head1 SEE ALSO

=head1 AUTHOR

TUSK Development Team <tuskdev@tufts.edu>

=head1 COPYRIGHT

Copyright (c) Tufts University Sciences Knowledgebase, 2004.

=cut

1;

