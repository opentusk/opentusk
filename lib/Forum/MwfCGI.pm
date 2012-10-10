# Based on CGI::Minimal by Benjamin Franz.
# This version has been modified for mwForum.
# The original version can be obtained from CPAN.
# Changes:
# - Recognize semicolon as parameter separator for xwwwformurlencoded
# - Use binmode() on STDIN for Windows compatibility
# - Escape regexp special characters in MIME boundary
# - Removed obscure {jcgi} layer

#######################################################################
#                                                                     #
# The most current release can always be found at                     #
# <URL:http://www.nihongo.org/snowhare/utilities/>                    #
#                                                                     #
# THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS         #
# OR IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE           #
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A             #
# PARTICULAR PURPOSE.                                                 #
#                                                                     #
# Use of this software in any way or in any form, source or binary,   #
# is not allowed in any country which prohibits disclaimers of any    #
# implied warranties of merchantability or fitness for a particular   #
# purpose or any disclaimers of a similar nature.                     #
#                                                                     #
# IN NO EVENT SHALL I BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT,    #
# SPECIAL, INCIDENTAL,  OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE   #
# USE OF THIS SOFTWARE AND ITS DOCUMENTATION (INCLUDING, BUT NOT      #
# LIMITED TO, LOST PROFITS) EVEN IF I HAVE BEEN ADVISED OF THE        #
# POSSIBILITY OF SUCH DAMAGE                                          #
#                                                                     #
# This program is free software; you can redistribute it              #
# and/or modify it under the same terms as Perl itself.               #
#                                                                     #
# Copyright 1999 Benjamin Franz. All Rights Reserved.                 #
#                                                                     #
#######################################################################

package MwfCGI;

use strict;
use vars qw ($_query $VERSION $form_initial_read);
$VERSION = "2.3.1";

# check for mod_perl and include the 'Apache' module if needed
if (exists $ENV{'MOD_PERL'}) {
	$| = 1;
	require Apache;
}

# Initialize the CGI global variables
&_reset_globals;


######################################################################

sub new {

	if ($form_initial_read) {
		$_query->_read_form;
		$form_initial_read = 0;
	}
	if (exists $ENV{'MOD_PERL'}) {
		Apache->request->register_cleanup(\&MwfCGI::_reset_globals);
	}

	$_query;
}

#######################################################################

sub param {
	my ($self) = shift;

	my @result = ();
	if ($#_ == -1) {
		@result = @{$self->{'field_names'}};
	} elsif ($#_ == 0) {
		my ($fieldname)=@_;
		if (defined($self->{'field'}{$fieldname})) {
			@result = @{$self->{'field'}{$fieldname}{'value'}};
		}
	}
	if (wantarray) {
		return @result;
	} elsif ($#result > -1) {
		return $result[0];
	} else {
		return;
	}
}

#######################################################################

sub param_filename {
	my ($self) = shift;

	my @result = ();
	if ($#_ == -1) {
		@result = @{$self->{'field_names'}};
	} elsif ($#_ == 0) {
		my ($fieldname)=@_;
		if (defined($self->{'field'}{$fieldname})) {
			@result = @{$self->{'field'}{$fieldname}{'filename'}};
		}
	}
	if (wantarray) {
		return @result;
	} elsif ($#result > -1) {
		return $result[0];
	} else {
		return;
	}
}

#######################################################################

sub url_decode {
	my ($self) = shift;

	my ($line) = @_;

	return ('') if (! defined($line));
	$line =~ s/\+/ /gos;
	$line =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/egos;
	$line;
}

#######################################################################

sub truncated {
	my ($self) = shift;

	$self->{'form_truncated'};
}

########################################################################

sub max_read_size {
	my ($size) = shift;

	$_query->{'max_buffer'} = $size;
}

########################################################################
# Wrapper for form reading for GET, HEAD and POST methods              #
########################################################################

sub _read_form {
	my ($self) = shift;

	return if (! defined($ENV{"REQUEST_METHOD"})); 

	my ($request_method)=$ENV{"REQUEST_METHOD"};

	if ($request_method eq 'POST') {
		$self->_read_post;
	} elsif (($request_method eq 'GET') || ($request_method eq 'HEAD')) {
		$self->_read_get;
	}
}

########################################################################
# Performs form reading for POST method                                #
########################################################################

sub _read_post {
	my ($self) = shift;

	my ($read_length)    = $self->{'max_buffer'};
	
	if ($ENV{'CONTENT_LENGTH'} < $self->{'max_buffer'}) {
		$read_length= $ENV{'CONTENT_LENGTH'};
	}

	my ($buffer)     = '';
	my ($read_bytes) = 0;
	if ($read_length) {
		binmode(STDIN);
		$read_bytes = read(STDIN, $buffer, $read_length,0);
	}
	if ($read_bytes < $ENV{'CONTENT_LENGTH'}) {
		$self->{'form_truncated'} = 1;
	} else {
		$self->{'form_truncated'} = 0;
	}

	# Default to this if they don't tell us
	my ($content_type) = 'application/x-www-form-urlencoded';

	if (defined($ENV{'CONTENT_TYPE'})) {
		$content_type = $ENV{'CONTENT_TYPE'};
	}

	my ($boundary,$form_type);
	if ($content_type =~ m#^multipart/form-data; boundary=(.*)$#oi) {
		$form_type="multipart";
		$boundary = $1;
		$boundary =~ s!([\\\.\+\*\?\(\)\[\]\{\}\^\$])!\\$1!g;
		$boundary="--$boundary(--)?\015\012";
		$self->_burst_multipart_buffer ($buffer,$boundary);
	} elsif ($content_type =~ m#^application/x-www-form-urlencoded$#oi) {
		$form_type="xwwwformurlencoded";
		$self->_burst_URL_encoded_buffer($buffer,$form_type);
	}
}

########################################################################
# Performs form reading for GET and HEAD methods                       #
########################################################################

sub _read_get {
	my ($self) = shift;

	my ($buffer)='';
	if (exists $ENV{'MOD_PERL'}) {
		$buffer = Apache->request->args;
	} else {
		$buffer = $ENV{'QUERY_STRING'} if (defined $ENV{'QUERY_STRING'});
	}
	my ($form_type);

	$form_type="xwwwformurlencoded";

	$self->_burst_URL_encoded_buffer($buffer,$form_type);
}

##########################################################################
# Bursts normal URL encoded buffers                                      #
# Takes: $buffer   - the actual data to be burst                         #
#        $form_type - 'xwwwformurlencoded','sgmlformurlencoded'          #
#                'xwwwformurlencoded' is old style forms                 #
#                'sgmlformurlencoded' is new style SGML compatible forms #
##########################################################################

sub _burst_URL_encoded_buffer {
	my ($self) = shift;

	my ($buffer,$form_type)=@_;

	my ($mime_type) = "text/plain";
	my ($filename) = "";

	# Split the name-value pairs on the selected split char
	my (@pairs) = ();
	if ($buffer) {
		@pairs = split(/[;&]/, $buffer);
	}

	# Initialize the field hash and the field_names array
	%{$self->{'field'}}      = ();
	@{$self->{'field_names'}} = ();

	my ($pair);
	foreach $pair (@pairs) {
		my ($name, $data) = split(/=/, $pair);

		# De-URL encode plus signs and %-encoding
		$name = $self->url_decode($name);
		$data = $self->url_decode($data);

		if (! defined ($self->{'field'}{$name}{'count'})) {
			push (@{$self->{'field_names'}},$name);
			$self->{'field'}{$name}{'count'} = 0;
		}
		my ($field_count) = $self->{'field'}{$name}{'count'};
		$self->{'field'}{$name}{'count'}++;
		$self->{'field'}{$name}{'value'}[$field_count]     = $data;
		$self->{'field'}{$name}{'filename'}[$field_count]  = $filename;
		$self->{'field'}{$name}{'mime_type'}[$field_count] = $mime_type;
	}
}

##########################################################################
# Bursts multipart mime encoded buffers                                  #
# Takes: $buffer   - the actual data to be burst                         #
#        $boundary - the mime boundary to split on                       #
##########################################################################

sub _burst_multipart_buffer {
	my ($self) = shift;

	my ($buffer,$Boundary)=@_;

	# Split the name-value pairs
	my (@pairs) = split(/$Boundary/, $buffer);

	# Initialize the field hash and the field_names array
	%{$self->{'field'}}       = ();
	@{$self->{'field_names'}} = ();

	my ($pair);
	foreach $pair (@pairs) {
		next if (! defined ($pair));
		chop $pair; # Trailing \015 left over from the boundary
		chop $pair; # Trailing \012 left over from the boundary
		last if ($pair eq "--");
		next if (not $pair);
		# Split the header off from the actual data
		my ($header, $data) = split(/\015\012\015\012/so,$pair,2);

		# parse the header lines
		$header =~ s/\015\012/\012/osg; # change all the \r\n to \n
		my (@headerlines) = split(/\012/so,$header);
		my ($name)        = '';
		my ($filename)    = '';
		my ($mime_type)    = 'text/plain';

		my ($headfield);
		foreach $headfield (@headerlines) {
			my ($fieldname,$fielddata) = split(/: /,$headfield);
			if ($fieldname =~ m/^Content-Type$/io) {
				$mime_type=$fielddata;
			}
			if ($fieldname =~ m/^Content-Disposition$/io) {
				my (@dispositionlist) = split(/; /,$fielddata);
				my ($dispitem);
				foreach $dispitem (@dispositionlist) {
					next if ($dispitem eq 'form-data');
					my ($dispfield,$dispdata) = split(/=/,$dispitem,2);
					$dispdata =~ s/^\"//o;
					$dispdata =~ s/\"$//o;
					$name = $dispdata if ($dispfield eq 'name');
					$filename = $dispdata if ($dispfield eq 'filename');
				}
			}
		}

		if (! defined ($self->{'field'}{$name}{'count'})) {
			push (@{$self->{'field_names'}},$name);
			$self->{'field'}{$name}{'count'} = 0;
		}
		my ($field_count) = $self->{'field'}{$name}{'count'};
		$self->{'field'}{$name}{'count'}++;
		$self->{'field'}{$name}{'value'}[$field_count]     = $data;
		$self->{'field'}{$name}{'filename'}[$field_count]  = $filename;
		$self->{'field'}{$name}{'mime_type'}[$field_count] = $mime_type;
	}
}

##########################################################################
# _reset_globals;
#
# Sets the MwfCGI object to it's initial state (before
# calling 'new' for the first time in a CGI interaction)
#
##########################################################################

sub _reset_globals {
	$form_initial_read = 1;
	$_query = {};
	bless $_query;
	$_query->{'max_buffer'}     = 1000000;
	@{$_query->{'field_names'}}  = ();
	%{$_query->{'field'}}        = ();
}

##########################################################################

1;
