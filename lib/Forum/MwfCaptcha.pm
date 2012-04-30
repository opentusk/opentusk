#------------------------------------------------------------------------------
#    mwForum - Web-based discussion forum
#    Copyright (c) 1999-2007 Markus Wichitill
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#------------------------------------------------------------------------------

package MwfCaptcha;
use strict;
use warnings;
no warnings qw(uninitialized redefine);
$MwfCaptcha::VERSION = "2.11.1";

# Imports
use Forum::MwfMain;

#------------------------------------------------------------------------------
# Return captcha input elements

sub captchaInputs
{
	my $m = shift();
	my $type = shift();

	# Shortcuts
	my $cfg = $m->{cfg};
	my $lng = $m->{lng};

	my @lines = ();
	if ($cfg->{captchaFont}) {
		# Captcha image
		my $captchaTicketId = addCaptcha($m, 'pstCpt');
		push @lines,
			"<br/>$lng->{comCaptcha}<br/>\n",
			"<input type='text' name='captchaCode' size='10' maxlength='6'/><br/>\n",
			"<input type='hidden' name='captchaTicketId' value='$captchaTicketId'/>\n",
			"<img class='cpt' src='$cfg->{attachUrlPath}/captchas/$captchaTicketId.png' alt=''/><br/>\n";
	}
	else {
		# Cheap captcha
		my $sel = $m->paramInt('bot') == 2 ? "selected='selected'" : "";
		push @lines,
			"<br/><select name='bot' size='1'>\n",
			"<option value='1'>$lng->{comCptImaBot}</option>\n",
			"<option value='2' $sel>$lng->{comCptImaMan}</option>\n",
			"</select><br/>\n";
	}
	
	return @lines;
}

#------------------------------------------------------------------------------
# Check captcha input

sub checkCaptcha
{
	my $m = shift();
	my $type = shift();

	# Shortcuts
	my $cfg = $m->{cfg};
	my $lng = $m->{lng};

	if ($cfg->{captchaFont}) {
		# Real captcha image check
		my $ticketId = $m->paramStrId('captchaTicketId');
		my $code = $m->paramStr('captchaCode');

		# Delete old captcha tickets and files
		my $timeout = 120;
		$timeout = 600 if $type eq 'pstCpt' || $type eq 'msgCpt';
		$m->dbDo("
			DELETE FROM $cfg->{dbPrefix}tickets 
			WHERE type = '$type'
				AND issueTime < $m->{now} - $timeout");
		unlink grep((stat($_))[9] < $m->{now} - $timeout, glob("$cfg->{attachFsPath}/captchas/*"));
		
		# Get and delete current captcha ticket
		my $realCode = $m->fetchArray("
			SELECT data
			FROM $cfg->{dbPrefix}tickets 
			WHERE id = '$ticketId'");
		$m->dbDo("
			DELETE FROM $cfg->{dbPrefix}tickets WHERE id = '$ticketId'") 
			if $realCode;
			
		# Check string
		$realCode or $m->formError($m->formatStr($lng->{errCptTmeOut}, { seconds => $timeout }));
		lc($code) eq lc($realCode) or $m->formError($lng->{errCptWrong}) if $realCode;
	}
	else {
		# Turing test for village idiots
		$m->paramInt('bot') == 2 or $m->formError($lng->{errCptFail})
	}
}

#-----------------------------------------------------------------------------
# Create captcha image and store captcha ticket

sub addCaptcha
{
	my $m = shift();
	my $type = shift();

	# Shortcuts
	my $cfg = $m->{cfg};

	# Load modules
	my $gd = eval { require GD };
	eval { require Image::Magick } 
		or $m->cfgError("Modules required for captchas not available.") if !$gd;

	# Generate captcha image
	require GD::SecurityImage;
	GD::SecurityImage->import($gd ? () : (use_magick => 1));
	my $img = GD::SecurityImage->new(
		width => $cfg->{captchaWidth} || 250,
		height => $cfg->{captchaHeight} || 60,
		font => $cfg->{captchaFont},
		ptsize => $cfg->{captchaPts} || ($gd ? 16 : 20),
		scramble => defined($cfg->{captchaScrambl}) ? $cfg->{captchaScrambl} : 1,
		rnd_data => $cfg->{captchaChars} || [qw(A B C D E F G H I J K L M O P R S T U V W X Y)],
	);
	$img->random();
	my $newCaptchaStr = $img->random_str();
	$img->create('ttf', int(rand(2)) ? 'default' : 'ec', "#777777", "#777777");
	$img->particle(3000);

	# Store captcha image
	my ($imgData) = $img->out(force => 'png');
	my $ticketId = $m->randomId();
	mkdir "$cfg->{attachFsPath}/captchas";
	open my $fh, ">$cfg->{attachFsPath}/captchas/$ticketId.png" or $m->cfgError($!);
	binmode $fh;
	print $fh $imgData;
	close $fh;
	
	# Insert captcha ticket
	$m->dbDo("
		INSERT INTO $cfg->{dbPrefix}tickets (id, userId, issueTime, type, data)
		VALUES ('$ticketId', 0, $m->{now}, '$type', '$newCaptchaStr')");

	return $ticketId;
}

#-----------------------------------------------------------------------------
1;
