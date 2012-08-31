#!/usr/bin/perl
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
my $postId = $m->paramInt('pid');
my $attachId = $m->paramInt('aid');
my $embed = $m->paramBool('embed');
my $upload = $m->paramBool('upload');
my $delete = $m->paramBool('delete');
my $toggle = $m->paramBool('toggle');
my $submitted = $m->paramBool('subm');
my $sourceAuth = $m->paramInt('auth');
$postId or $m->paramError($lng->{errPstIdMiss}) if $upload;
$attachId or $m->paramError($lng->{errAttIdMiss}) if $toggle || $delete;

# Get attachment
my $attachment = undef;
if ($attachId) {
	$attachment = $m->fetchHash("
		SELECT * FROM $cfg->{dbPrefix}attachments WHERE id = $attachId");
	$attachment or $m->entryError($lng->{errAttNotFnd});
	$postId = $attachment->{postId};
}

# Get post
my $post = $m->fetchHash("
	SELECT * FROM $cfg->{dbPrefix}posts WHERE id = $postId");
$post or $m->entryError($lng->{errPstNotFnd});
my $postIdMod = $postId % 100;

# Get board
my $board = $m->fetchHash("
	SELECT * FROM $cfg->{dbPrefix}boards WHERE id = $post->{boardId}");
my $boardId = $board->{id};

# Get topic
my $topic = $m->fetchHash("
	SELECT * FROM $cfg->{dbPrefix}topics WHERE id = $post->{topicId}");
my $topicId = $topic->{id};

# Check authorization
$m->checkAuthz($user, 'attach', post => $post, topic => $topic, board => $board, 
	delete => $delete, toggle => $toggle);

# Check if user can edit post
my $boardAdmin = $user->{admin} || $m->boardAdmin($userId, $board->{id});
$userId == $post->{userId} || $boardAdmin or $m->userError($lng->{errCheat});

# Check if attachments are enabled
($board->{attach} == 1 || $board->{attach} == 2 && $boardAdmin)
	&& $cfg->{attachFsPath} 
	or $m->userError($lng->{errAttDisab});

# Check if topic is locked
!$topic->{locked} || $boardAdmin or $m->userError($lng->{errTpcLocked});

# Process form
if ($submitted) {
	# Check request source authentication
	$sourceAuth == $user->{sourceAuth} or $m->formError($lng->{errSrcAuth});

	# Upload attachment
	if ($upload) {
		my $fileSize = 0;
		my $fileName = "";
		my $uploadObj = undef;
	
		# Get filename and size
		if (MwfMain::MP) {
			require Apache2::Upload if MwfMain::MP2;
			$uploadObj = $m->{apr}->upload('file');
			$uploadObj or $m->paramError($lng->{errAttSize});
			$fileName = $uploadObj->filename();
			$fileSize = $uploadObj->size();
		}
		else {
			$fileName = $m->{cgi}->param_filename('file');
			$fileSize = length($m->{cgi}->param('file'));
		}
	
		# Check filename and size
		length($fileName) or $m->paramError($lng->{errAttName});
		$fileSize or $m->paramError($lng->{errAttSize});
		
		# Is embedding allowed?
		$embed = 0 if !$cfg->{attachImg} || $fileName !~ /\.(?:jpg|png|gif)$/i;
	
		# Remove illegal stuff from filename
		$fileName =~ s/.*[\\\/:]//;  # Remove path
		$fileName =~ s/[^\w\.\-]+//g;  # Remove special chars
		$fileName = "attachment" if $fileName eq ".htaccess";
		
		# Make sure filename doesn't end up empty
		$fileName = "attachment" if !length($fileName);

		# Make sure filenames don't clash
		my $fileNameQ = $m->dbQuote($fileName);
		my $fileNameExists = $m->fetchArray("
			SELECT 1 FROM $cfg->{dbPrefix}attachments WHERE postId = $postId AND fileName = $fileNameQ");
		$fileName = int(rand(9999)) . $fileName if $fileNameExists;
		$fileNameQ = $m->dbQuote($fileName);
	
		# Create directories
		mkdir "$cfg->{attachFsPath}/$postIdMod";
		mkdir "$cfg->{attachFsPath}/$postIdMod/$postId";
	
		# Create attachment file
		my $saveFile = "$cfg->{attachFsPath}/$postIdMod/$postId/$fileName";
		if (MwfMain::MP1) {
			# Create new hardlink for tempfile or copy tempfile
			my $success = $uploadObj->link($saveFile);
			if (!$success) {
				require File::Copy;
				File::Copy::copy($uploadObj->tempname, $saveFile) or $m->cfgError("File::Copy: $!");
			}
			chmod 0666 & ~umask(), $saveFile;
		}
		elsif (MwfMain::MP2) {
			# Create new hardlink for tempfile or copy tempfile
			# or write data from memory to file for small uploads
			eval { $uploadObj->upload_link($saveFile) } or $m->cfgError("upload_link: $@");
			chmod 0666 & ~umask(), $saveFile;
		}
		else {
			# Write data from memory to file
			open my $fh, ">$saveFile" or $m->cfgError("open: $!");
			binmode $fh;
			syswrite $fh, $m->{cgi}->param('file') or $m->cfgError("syswrite: $!");
			close $fh or $m->cfgError("close: $!");
		}
		
		# Add attachments table entry
		my $webImage = $fileName =~ /\.(?:jpg|png|gif)$/i ? 1 : 0;
		$webImage = 2 if $embed && $webImage;
		$m->dbDo("
			INSERT INTO $cfg->{dbPrefix}attachments (postId, webImage, fileName)
			VALUES ($postId, $webImage, $fileNameQ)");
		$attachId = $m->dbInsertId("$cfg->{dbPrefix}attachments");
		
		# Log action
		$m->logAction(1, 'post', 'attach', $userId, $boardId, $topicId, $postId, $attachId);

		# Redirect back
		$m->redirect('post_attach', pid => $postId, msg => 'PstAttach');
	}
	elsif ($delete) {
		# Delete attachment
		$m->deleteAttachment($attachId);

		# Log action
		$m->logAction(1, 'post', 'detach', $userId, $boardId, $topicId, $postId, $attachId);

		# Redirect back
		$m->redirect('post_attach', pid => $postId, msg => 'PstDetach');
	}
	elsif ($toggle) {
		$attachment->{webImage} or $m->userError('errCheat');
		
		# Toggle embedding
		my $webImage = $attachment->{webImage} == 1 ? 2 : 1;
		$m->dbDo("
			UPDATE $cfg->{dbPrefix}attachments SET webImage = $webImage WHERE id = $attachId");
	
		# Log action
		$m->logAction(1, 'post', 'atttgl', $userId, $boardId, $topicId, $postId);

		# Redirect back
		$m->redirect('post_attach', pid => $postId, msg => 'PstAttTgl');
	}
	else { $m->paramError($lng->{errParamMiss}) }
}

# Print form
if (!$submitted || @{$m->{formErrors}}) {
	# Print header
	$m->printHeader();

	# Print bar
	my @navLinks = ({ 
		url => $m->url('topic_show', tid => $topicId, pid => $postId, tgt => "pid$postId"), 
		txt => 'comUp', ico => 'up' });
	$m->printPageBar(mainTitle => $lng->{attTitle}, navLinks => \@navLinks);

	# Print attachment form
	print	
		"<form action='post_attach$m->{ext}' method='post' enctype='multipart/form-data'>\n",
		"<div class='frm'>\n",
		"<div class='hcl'>\n",
		"<span class='htt'>$lng->{attUplTtl}</span>\n",
		"</div>\n",
		"<div class='ccl'>\n",
		$m->formatStr($lng->{attUplFile}, { bytes => $cfg->{maxAttachLen} }), "<br/>\n",
		"<input type='file' name='file' size='80'/><br/>\n",
		$cfg->{attachImg} ? 
			"<label><input type='checkbox' name='embed'/>$lng->{attUplEmbed}</label><br/><br/>\n" : "",
		$m->submitButton('attUplB', 'attach', 'upload'),
		"<input type='hidden' name='pid' value='$postId'/>\n",
		$m->stdFormFields(),
		"</div>\n",
		"</div>\n",
		"</form>\n\n";
		
	# Get existing attachments
	my $attachments = $m->fetchAllHash("
		SELECT id, webImage, fileName 
		FROM $cfg->{dbPrefix}attachments 
		WHERE postId = $postId
		ORDER BY id");

	# Print existing attachments		
	for my $attach (@$attachments) {
		print	
			"<form action='post_attach$m->{ext}' method='post'>\n",
			"<div class='frm'>\n",
			"<div class='hcl'>\n",
			"<span class='htt'>$lng->{attAttTtl}</span> $attach->{fileName}\n",
			"</div>\n",
			"<div class='ccl'>\n";

		# Print attachment
		my $attFsBasePath = "$cfg->{attachFsPath}/$postIdMod/$postId";
		my $attUrlBasePath = "$cfg->{attachUrlPath}/$postIdMod/$postId";
		my $fileName = $attach->{fileName};
		my $attFsPath = "$attFsBasePath/$fileName";
		my $attUrlPath = "$attUrlBasePath/$fileName";
		my $size = -s $attFsPath || 0;
		$size = sprintf("%.1fk", $size / 1024);
		if ($cfg->{attachImg} && $attach->{webImage} == 2 && $user->{showImages}) {
			my $thbFsPath = $attFsPath;
			my $thbUrlPath = $attUrlPath;
			$thbFsPath =~ s!\.(?:jpg|png|gif)$!.thb.jpg!i;
			$thbUrlPath =~ s!\.(?:jpg|png|gif)$!.thb.jpg!i;
			print $cfg->{attachImgThb} && (-f $thbFsPath || $m->addThumbnail($attFsPath) > 0)
				? "<a href='$attUrlPath'><img class='amt' src='$thbUrlPath' alt=''/></a> $size"
				: "<img class='ami' src='$attUrlPath' alt=''/> $size";
		}
		else {
			print "<a href='$attUrlPath'>$fileName</a> ($size)";
		}
		print 
			"<br/>\n",
			$m->submitButton('attAttDelB', 'delete', 'delete'),
			$cfg->{attachImg} && $attach->{webImage} >= 1 ?
				$m->submitButton('attAttTglB', 'image', 'toggle') : "",
			"<input type='hidden' name='aid' value='$attach->{id}'/>\n",
			$m->stdFormFields(),
			"</div>\n",
			"</div>\n",
			"</form>\n\n";
	}

	# Log action
	$m->logAction(3, 'post', 'attach', $userId, $boardId, $topicId, $postId);

	# Print footer
	$m->printFooter();
}
