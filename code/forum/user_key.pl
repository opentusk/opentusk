#!/usr/bin/env perl
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

use strict;
use warnings;
no warnings qw(uninitialized redefine);

# Imports
use Forum::MwfMain;

#------------------------------------------------------------------------------

# Init
my ($m, $cfg, $lng, $user) = MwfMain->new(@_);
my $userId = $user->{id};

# Check if access should be denied
$userId or $m->regError();
$m->checkBan($userId);
$m->checkBlock();

# Get CGI parameters
my $optUserId = $m->paramInt('uid');
my $keyId = $m->paramStr('keyId');
my $compat = $m->paramInt('compat');
my $key = $m->paramStr('key');
my $result = $m->paramStr('result');
my $change = $m->paramBool('change');
my $upload = $m->paramBool('upload');
my $submitted = $m->paramBool('subm');
my $sourceAuth = $m->paramInt('auth');

# Select which user to edit
my $optUser = $optUserId && $user->{admin} ? $m->getUser($optUserId) : $user;
$optUser or $m->entryError($lng->{errUsrNotFnd});
$optUserId = $optUser->{id};

# Shortcuts
my $keyringDir = "$cfg->{attachFsPath}/keys";
my $keyring = "$keyringDir/$optUserId.gpg";

if ($change) {
	# Process form
	if ($submitted) {
		# Check request source authentication
		$sourceAuth == $user->{sourceAuth} or $m->formError($lng->{errSrcAuth});

		# Check length
		length($keyId) == 0 || length($keyId) >= 8 
			or $m->formError("OpenPGP key ID is too short.");
		length($keyId) <= 18 
			or $m->formError("OpenPGP key ID is too long.");
	
		# Print form errors or finish action
		if (@{$m->{formErrors}}) { $m->printFormErrors() }
		else {
			# Filter and quote strings
			my $keyIdQ = $m->dbQuote($m->escHtml($keyId));
	
			# Update user
			$m->dbDo("
				UPDATE $cfg->{dbPrefix}users SET 
					gpgKeyId = $keyIdQ, 
					gpgCompat = $compat 
				WHERE id = $optUserId");
			
			# Log action
			$m->logAction(1, 'user', 'keyopt', $userId, 0, 0, 0, $optUserId);
			
			# Redirect
			$m->redirect('user_key', uid => $optUserId, msg => 'OptChange');
		}
	}
}
elsif ($upload) {
	# Process form
	if ($submitted) {
		# Check request source authentication
		$sourceAuth == $user->{sourceAuth} or $m->formError($lng->{errSrcAuth});
	
		# Check key
		length($key) > 200 or $m->formError("OpenPGP key is empty or too short.");
		length($key) <= 20000 or $m->formError("OpenPGP key is too long.");
		$key =~ /\-\-\-\-\-BEGIN PGP PUBLIC KEY BLOCK\-\-\-\-\-/ 
			&& $key =~ /\-\-\-\-\-END PGP PUBLIC KEY BLOCK\-\-\-\-\-/
			or $m->formError("Input doesn't look like an OpenPGP key.");
		
		# Print form errors or finish action
		if (@{$m->{formErrors}}) { $m->printFormErrors() }
		else {
			# Make keyring directory
			mkdir $keyringDir;
			
			# Import key into user's own keyring
			my $out = "";
			my $err = "";
			my $cmd = [
				"gpg", "--batch",
				$m->{gcfg}{utf8} ? ("--charset", "utf-8") : (),
				"--no-default-keyring",
				"--keyring", $keyring,
				$cfg->{gpgOptions} ? @{$cfg->{gpgOptions}} : (),
				"--import",
			];
			$m->ipcRun($cmd, \$key, \$out, \$err) 
				or $m->logError("Key import failed ($err).");
	
			# Log action
			$m->logAction(1, 'user', 'keyupl', $userId, 0, 0, 0, $optUserId);
			
			# Redirect
			$m->redirect('user_key', uid => $optUserId, result => $err);
		}
	}
}

# Print form
if (!$submitted || @{$m->{formErrors}}) {
	# Print header
	$m->printHeader();

	# Print page bar
	my @navLinks = ({ url => $m->url('user_options', uid => $optUserId), 
		txt => 'comUp', ico => 'up' });
	$m->printPageBar(mainTitle => "User", subTitle => $optUser->{userName}, navLinks => \@navLinks);

	# Set submitted or database values
	$keyId = $submitted ? $m->escHtml($keyId) : $optUser->{gpgKeyId};
	$compat = $submitted ? $compat : $optUser->{gpgCompat};
	
	# Determine radiobutton states
	my %compatSel = ( $compat => "checked='checked'" );
	
	# Print keyId form
	print
		"<form action='user_key$m->{ext}' method='post'>\n",
		"<div class='frm'>\n",
		"<div class='hcl'>\n",
		"<span class='htt'>OpenPGP Options</span>\n",
		"</div>\n",
		"<div class='ccl'>\n",
		"You can have your emails encrypted for you by uploading your",
		" OpenPGP public key and then filling in your key ID.<br/><br/>\n",
		"Key ID (example: 0xC7A966DD)<br/>\n",
		"<input type='text' name='keyId' size='30' maxlength='18' value='$keyId'/><br/><br/>\n",
		"Compatibility:<br/>\n",
		"<label><input type='radio' name='compat' value='0' $compatSel{0}/>OpenPGP</label>\n",
		"<label><input type='radio' name='compat' value='8' $compatSel{8}/>PGP 8.x</label>\n",
		"<label><input type='radio' name='compat' value='7' $compatSel{7}/>PGP 7.x</label>\n",
		"<label><input type='radio' name='compat' value='6' $compatSel{6}/>PGP 6.x</label>\n",
		"<label><input type='radio' name='compat' value='5' $compatSel{5}/>PGP 5.x</label>\n",
		"<label><input type='radio' name='compat' value='2' $compatSel{2}/>PGP 2.x</label>\n",
		"<br/><br/>\n",
		$m->submitButton("Change", 'edit', 'change'),
		"<input type='hidden' name='uid' value='$optUserId'/>\n",
		$m->stdFormFields(),
		"</div>\n",
		"</div>\n",
		"</form>\n\n";

	# Print upload form
	print
		"<form action='user_key$m->{ext}' method='post'>\n",
		"<div class='frm'>\n",
		"<div class='hcl'>\n",
		"<span class='htt'>OpenPGP Key Upload</span>\n",
		"</div>\n",
		"<div class='ccl'>\n",
		"ASCII-armored public key<br/>\n",
		"<textarea name='key' cols='80' rows='4'></textarea>\n",
		"<br/><br/>\n",
		$m->submitButton("Upload", 'attach', 'upload'),
		"<input type='hidden' name='uid' value='$optUserId'/>\n",
		$m->stdFormFields(),
		"</div>\n",
		"</div>\n",
		"</form>\n\n";

	# Print output
	print
		"<div class='frm'>\n",
		"<div class='hcl'>\n",
		"<span class='htt'>OpenPGP Key Upload Result</span>\n",
		"</div>\n",
		"<div class='ccl'>\n",
		$m->escHtml($result, 2), "\n",
		"</div>\n",
		"</div>\n\n"
		if $result;

	# Show keys in user's ring
	if (-s $keyring) {
		my $in = "";
		my $out = "";
		my $err = "";
		my $cmd = [
			"gpg", "--batch",
			$m->{gcfg}{utf8} ? ("--charset", "utf-8") : (),
			"--no-default-keyring",
			"--keyring", $keyring,
			$cfg->{gpgOptions} ? @{$cfg->{gpgOptions}} : (),
			"--list-keys",
		];
		$m->ipcRun($cmd, \$in, \$out, \$err) or $m->logError("Keyring list failed ($err).");
		$out =~ s!^(.*?\-{10,})!!s;
		$out =~ s!\n+$!\n!;

		print
			"<div class='frm'>\n",
			"<div class='hcl'>\n",
			"<span class='htt'>OpenPGP Keyring</span>\n",
			"</div>\n",
			"<div class='ccl'>\n",
			$m->escHtml($out, 2), "\n",
			"</div>\n",
			"</div>\n\n";
	}

	# Log action
	$m->logAction(3, 'user', 'key', $userId, 0, 0, 0, $optUserId);
	
	# Print footer
	$m->printFooter();
}
