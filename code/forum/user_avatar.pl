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

# TUSK begin
use Data::Dumper;
use TUSK::Constants;
# TUSK end

#------------------------------------------------------------------------------

# Init
my ($m, $cfg, $lng, $user) = MwfMain->new(@_);
my $userId = $user->{id};

# Check if access should be denied
$userId or $m->regError();
$m->checkBan($userId);
$m->checkBlock();

# Check if avatars are enabled
$cfg->{avatars} or $m->userError($lng->{errFeatDisbl});
eval { require Image::Info } or $m->cfgError("Image::Info module not available.")
	if $cfg->{avatarUpload};

# Get CGI parameters
my $optUserId = $m->paramInt('uid');
my $attach = $m->paramBool('attach');
my $select = $m->paramBool('select');
my $delete = $m->paramBool('delete');
my $galleryFile = $m->paramStr('galleryFile');
my $submitted = $m->paramBool('subm');
my $sourceAuth = $m->paramInt('auth');

# Select which user to edit
my $optUser = $optUserId && $user->{admin} ? $m->getUser($optUserId) : $user;
$optUser or $m->entryError($lng->{errUsrNotFnd});
$optUserId = $optUser->{id};

# Shortcuts
my $avaUrlPath = "$cfg->{attachUrlPath}/avatars";
my $avaFsPath = "$cfg->{attachFsPath}/avatars";

# Process form
if ($submitted) {
	# Check request source authentication
	$sourceAuth == $user->{sourceAuth} or $m->paramError($lng->{errSrcAuth});

	# Upload avatar
	if ($attach && $cfg->{avatarUpload}) {
		my $fileSize = 0;
		my $upload = undef;
	
		# Get upload object and size
		if (MwfMain::MP) {
			require Apache2::Upload if MwfMain::MP2;
			$upload = $m->{apr}->upload('file');
			$fileSize = $upload->size();
		}
		else {
			$fileSize = length($m->{cgi}->param('file'));
		}
		my $validFileSize = $fileSize <= $cfg->{avatarMaxSize};
		$validFileSize || $cfg->{avatarResize} or $m->formError($lng->{errAvaSizeEx});
		
		# Get image info		
		my $info = undef;
		if (MwfMain::MP1) { 
			$info = Image::Info::image_info($upload->fh);
		}
		elsif (MwfMain::MP2) { 
			$upload->slurp(my $data);
			$info = Image::Info::image_info(\$data);
		}
		else { 
			$info = Image::Info::image_info(\$m->{cgi}->param('file'));
		}
		my $imgW = $info->{width};
		my $imgH = $info->{height};
		my $avaW = $cfg->{avatarWidth};
		my $avaH = $cfg->{avatarHeight};

		# Check image info
		!$info->{error} or $m->formError($lng->{errAvaFmtUns});
		my $ext = $info->{file_ext};
		$ext =~ /^(?:jpg|png|gif)$/ or $m->formError($lng->{errAvaFmtUns});

		# TUSK begin avatar image attribute checks.
		
		# imgW and imgH can be less than or equal to avaW/avaH, doesn't have to be exact.
		#my $validSize = $imgW == $avaW && $imgH == $avaH;
		my $validSize = $imgW <= $avaW && $imgH <= $avaH;
		$validSize || $cfg->{avatarResize} or $m->formError($lng->{errAvaDimens});

		# animatedAvatar flag is a custom flag, set in ForumKey::setCfg();
		my $animatedFlag = $cfg->{animatedAvatar};
		my $animated;
		if (!$animatedFlag) {
		    $animated = $info->{GIF_Loop} ? 1 : 0;
		    !$animated || $cfg->{avatarResize} or $m->formError($lng->{errAvaNoAnim});
		}
		# TUSK end
		

		# Print form errors or finish action
		if (@{$m->{formErrors}}) { $m->printFormErrors() }
		else {
			# Delete old avatar
			unlink "$avaFsPath/$optUser->{avatar}" 
				if $optUser->{avatar} && $optUser->{avatar} !~ /^gallery\//;
		
			# Write avatar file
			my $rnd = sprintf("%04u", int(rand(9999)));
			my $fileName = "$optUserId-$rnd.$ext";
			my $file = "$avaFsPath/$fileName";
			if (MwfMain::MP1) {
				# Create new hardlink for tempfile or copy tempfile
				my $success = $upload->link($file);
				if (!$success) {
					require File::Copy;
					File::Copy::copy($upload->tempname, $file) or $m->cfgError($!);
				}
				chmod 0666 & ~umask(), $file;
			}
			elsif (MwfMain::MP2) {
				# Write data from memory to file
				eval { $upload->link($file) } or $m->cfgError($@);
			}
			else {
				# Write data from memory to file
				open my $fh, ">$file" or $m->cfgError($!);
				binmode $fh;
				syswrite $fh, $m->{cgi}->param('file') or $m->cfgError($!);
				close $fh or $m->cfgError($!);
			}

			# Resize image if enabled and necessary
			if (!$validFileSize || !$validSize || $animated) {
				my $gd = eval { require GD };
				eval { require Image::Magick } 
					or $m->cfgError("Modules required for reformatting not available.") if !$gd;
				my $shrW = $avaW / $imgW;
				my $shrH = $avaH / $imgH;
				my $shrF = $m->min($shrW, $shrH, 1);
				my $dstW = $imgW * $shrF;
				my $dstH = $imgH * $shrF;
				my $dstX = $m->max($avaW - $dstW, 0) / 2;
				my $dstY = $m->max($avaH - $dstH, 0) / 2;
				$rnd = sprintf("%04u", int(rand(99999)));
				my $newFileName = "$optUserId-$rnd.png";
				my $newFile = "$avaFsPath/$newFileName";
				if ($gd) {
					GD::Image->trueColor(1);
					my $oldImg = GD::Image->new($file);
					unlink $file;
					$oldImg or $m->userError($lng->{errAvaFmtUns});
					my $newImg = GD::Image->new($avaW, $avaH);
					$newImg->alphaBlending(0);
					$newImg->saveAlpha(1);
					$newImg->fill(0, 0, $newImg->colorAllocateAlpha(239,239,239, 127));
					$newImg->copyResampled($oldImg, $dstX, $dstY, 0, 0, $dstW, $dstH, $imgW, $imgH);
					open my $newFh, ">$newFile" or $m->cfgError($!);
					binmode $newFh;
					print $newFh $newImg->png();
					close $newFh;
				}
				else {
					my $oldImg = Image::Magick->new();
					my $rc = $oldImg->Read($file . "[0]");
					unlink $file;
					!$rc or $m->userError($lng->{errAvaFmtUns});
					$oldImg->Resize(width => $dstW, height => $dstH);
					my $newImg = Image::Magick->new(size => "${avaW}x${avaH}");
					$newImg->Read("xc:transparent");
					$newImg->Composite(image => $oldImg, x => $dstX, y => $dstY);
					$newImg->Write(filename => $newFile);
				}
				$fileName = $newFileName;
			}
			
			# Update user
			$m->dbDo("
				UPDATE $cfg->{dbPrefix}users SET
					showAvatars = 1,
					avatar = '$fileName'
				WHERE id = $optUserId");

			# Log action
			$m->logAction(1, 'user', 'avaupl', $userId, 0, 0, 0, $optUserId);

			# Redirect to user options
			$m->redirect('user_avatar', uid => $optUserId);
		}
	}
	elsif ($select && $cfg->{avatarGallery}) {
		# Check if file exists
		-f "$avaFsPath/gallery/$galleryFile" or $m->formError("Gallery avatar not found.");

		# Print form errors or finish action
		if (@{$m->{formErrors}}) { $m->printFormErrors() }
		else {
			# Update user
			my $galleryFileQ = $m->dbQuote("gallery/$galleryFile");
			$m->dbDo("
				UPDATE $cfg->{dbPrefix}users SET
					showAvatars = 1,
					avatar = $galleryFileQ
				WHERE id = $optUserId");

			# Delete uploaded avatar
			unlink "$avaFsPath/$optUser->{avatar}"
				if $optUser->{avatar} && $optUser->{avatar} !~ /^gallery\//;		
		
			# Log action
			$m->logAction(1, 'user', 'avasel', $userId, 0, 0, 0, $optUserId);

			# Redirect to user options
			$m->redirect('user_options', uid => $optUserId);
		}
	}
	elsif ($delete && $optUser->{avatar}) {
		# Update user
		$m->dbDo("
			UPDATE $cfg->{dbPrefix}users SET avatar = '' WHERE id = $optUserId");

		# Delete uploaded avatar
		unlink "$avaFsPath/$optUser->{avatar}" if $optUser->{avatar} !~ /^gallery\//;

		# Log action
		$m->logAction(1, 'user', 'avadel', $userId, 0, 0, 0, $optUserId);
	
		# Redirect back
		$m->redirect('user_avatar', uid => $optUserId);
	}
	else { $m->paramError($lng->{errParamMiss}) }
}

# Print form
if (!$submitted || @{$m->{formErrors}}) {
	# Print header
	$m->printHeader();

	# Print page bar
	my @navLinks = ({ url => $m->url('user_options', uid => $optUserId), 
		txt => 'comUp', ico => 'up' });
	$m->printPageBar(mainTitle => $lng->{avaTitle}, subTitle => $optUser->{userName}, 
		navLinks => \@navLinks);
	
	# Print avatar upload form
	if ($cfg->{avatarUpload}) {
		print
			"<form class='aul' action='user_avatar$m->{ext}' method='post' enctype='multipart/form-data'>\n",
			"<div class='frm'>\n",
			"<div class='hcl'>\n",
			"<span class='htt'>$lng->{avaUplTtl}</span>\n",
			"</div>\n",
			"<div class='ccl'>\n";

		if (!$optUser->{avatar} || $optUser->{avatar} =~ /^gallery\//) {
			print
				$m->formatStr($lng->{avaUplFile}, { bytes => $cfg->{avatarMaxSize}, 
					width => $cfg->{avatarWidth}, height => $cfg->{avatarHeight} }), "<br/>\n",
				$cfg->{avatarResize} ? "$lng->{avaUplResize}<br/>\n" : "",
				"<input type='file' name='file' size='80'/><br/><br/>\n",
				$m->submitButton('avaUplUplB', 'attach', 'attach');
		}
		else {
			print
				"<img class='ava' src='$avaUrlPath/$optUser->{avatar}' alt=''/><br/><br/>\n",
				$m->submitButton('avaUplDelB', 'delete', 'delete');
		}
	
		print	
			"<input type='hidden' name='uid' value='$optUserId'/>\n",
			$m->stdFormFields(),
			"</div>\n",
			"</div>\n",
			"</form>\n\n";
	}

	# Print avatar gallery form
	if ($cfg->{avatarGallery}) {
		# Get gallery image filenames
		my @files = <$avaFsPath/gallery/*>;
		
		print
			"<form class='agl' action='user_avatar$m->{ext}' method='post'>\n",
			"<div class='frm'>\n",
			"<div class='hcl'>\n",
			"<span class='htt'>$lng->{avaGalTtl}</span>\n",
			"</div>\n",
			"<div class='ccl'>\n";

		# Print selectable avatars			
		for my $file (@files) {
			my $status = $file eq "$avaFsPath/$optUser->{avatar}" ? "checked='checked'" : "";
			$file =~ s/.*[\\\/:]//;
			print
				"<label><input type='radio' name='galleryFile' value='$file' $status/>",
				"<img class='ava' src='$avaUrlPath/gallery/$file' alt=''/></label>\n";
		}
	
		print
			"<br/><br/>\n",
			$m->submitButton('avaGalSelB', 'avatar', 'select'),
			$optUser->{avatar} =~ /^gallery\// ? $m->submitButton('avaGalDelB', 'remove', 'delete') : "",
			"<input type='hidden' name='uid' value='$optUserId'/>\n",
			$m->stdFormFields(),
			"</div>\n",
			"</div>\n",
			"</form>\n\n";
	}
	
	# Log action
	$m->logAction(3, 'user', 'avatar', $userId, 0, 0, 0, $optUserId);
	
	# Print footer
	$m->printFooter();
}
