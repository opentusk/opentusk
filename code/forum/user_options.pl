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
no warnings qw(uninitialized redefine once);

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
my $realName = $m->paramStr('realName') || "";
my $homepage = $m->paramStr('homepage') || "";
my $occupation = $m->paramStr('occupation') || "";
my $hobbies = $m->paramStr('hobbies') || "";
my $location = $m->paramStr('location') || "";
my $icq = $m->paramStr('icq') || "";
my $signature = $m->paramStr('signature') || "";
my $extra1 = $m->paramStr('extra1') || "";
my $extra2 = $m->paramStr('extra2') || "";
my $extra3 = $m->paramStr('extra3') || "";
my $birthdate = $m->paramStr('birthdate') || "";
my $timezone = $m->paramStr('timezone');
my $language = $m->paramStr('language') || $cfg->{language};
my $style = $m->paramStr('style') || $cfg->{style};
my $fontFace = $m->paramStr('fontFace') || $cfg->{fontFace};
my $fontSize = $m->paramInt('fontSize') || 0;
my $indent = $m->paramInt('indent') || $cfg->{indent};
my $notify = $m->paramBool('notify');
my $msgNotify = $m->paramBool('msgNotify');
my $hideEmail = $m->paramBool('hideEmail');
my $manOldMark = $m->paramBool('manOldMark');
my $secureLogin = $m->paramBool('secureLogin');
my $privacy = $m->paramBool('privacy');
my $boardDescs = $m->paramBool('boardDescs');
my $showDeco = $m->paramBool('showDeco');
my $showAvatars = $m->paramBool('showAvatars');
my $showImages = $m->paramBool('showImages');
my $showSigs = $m->paramBool('showSigs');
my $collapse = $m->paramBool('collapse');
my $topicsPP = $m->paramStr('topicsPP');  # Detaint and default later
my $postsPP = $m->paramStr('postsPP');  # Detaint and default later
my $userName = $m->paramStr('userName') || "";
my $title = $m->paramStr('titleSel') || $m->paramStr('title') || "";
my $admin = $m->paramBool('admin');
my $dontEmail = $m->paramBool('dontEmail');
my $submitted = $m->paramBool('subm');
my $sourceAuth = $m->paramInt('auth');

# Select which user to edit
my $optUser = $optUserId && $user->{admin} ? $m->getUser($optUserId) : $user;
$optUser or $m->entryError($lng->{errUsrNotFnd});
$optUserId = $optUser->{id};

# Process form
if ($submitted) {
	# Check request source authentication
	$sourceAuth == $user->{sourceAuth} or $m->formError($lng->{errSrcAuth});

	# Don't update fields if they are not displayed in form
	$extra1 = $optUser->{extra1} if !$cfg->{extra1} || $cfg->{regExtra1} == 2;
	$extra2 = $optUser->{extra2} if !$cfg->{extra2} || $cfg->{regExtra2} == 2;
	$extra3 = $optUser->{extra3} if !$cfg->{extra3} || $cfg->{regExtra3} == 2;
	$secureLogin = $cfg->{secureLogin} if !$cfg->{enableSecLogin};
	$showAvatars = $optUser->{showAvatars} if !$cfg->{avatars};
	
	if (!$user->{admin}) {
		# Reset admin-only options if user is not admin
		$userName = $optUser->{userName};
		$title = $optUser->{title};
		$admin = $optUser->{admin};
		$dontEmail = $optUser->{dontEmail};
	}	
	else {
		# Check stuff that only admin can change	
		$m->checkUsername($userName);
	}
	
	# Parse birthdate
	my ($birthyear, $birthday) = $birthdate =~ /(?:(\d\d\d\d)\-)?(\d\d\-\d\d)/;
	$birthyear ||= 0;
	$birthday ||= "";
	
	# Add http:// to homepage if missing
	$homepage = "http://$homepage" if $homepage && $homepage !~ /^http/ && $homepage =~ /^www\./;
	
	# Limit string lengths
	($realName, $homepage, $occupation, $hobbies, $location, $icq) =
		map(substr($_, 0, 100), $realName, $homepage, $occupation, $hobbies, $location, $icq);
	($extra1, $extra2, $extra3) =
		map(substr($_, 0, 255), $extra1, $extra2, $extra3);
		
	# Set default values for numbers per page
	$topicsPP = $cfg->{topicsPP} if length($topicsPP) == 0;
	$postsPP = $cfg->{postsPP} if length($postsPP) == 0;
	$topicsPP = $cfg->{maxTopicsPP} if $topicsPP == 0;
	$postsPP = $cfg->{maxPostsPP} if $postsPP == 0;
	$topicsPP = int($topicsPP);
	$postsPP = int($postsPP);
	
	# Limit numerical values to valid range
	$fontSize = $m->min($m->max(0, $fontSize), 20);
	$indent = $m->min($m->max(1, $indent), 10);
	$topicsPP = $m->min($m->max(0, $topicsPP), $cfg->{maxTopicsPP});
	$postsPP = $m->min($m->max(0, $postsPP), $cfg->{maxPostsPP});
	
	# Limit language and style to valid selection
	$language = $cfg->{languages}{$language} ? $language : $cfg->{language};
	$style = $cfg->{styles}{$style} ? $style : $cfg->{style};

	# Process signature
	if ($cfg->{fullSigs}) {
		my $fakeBoard = { };
		my $fakePost = { isSignature => 1, body => $signature };
		$m->editToDb($fakeBoard, $fakePost);
		$signature = $fakePost->{body};
		length($signature) <= $cfg->{maxBodyLen} or $m->formError($lng->{errBdyLen});
	}
	else {
		$signature =~ s/\r//g;
		($signature) = $signature =~ /(.+\n?.*)/;
		$signature = substr($signature, 0, 100);
		$signature = $m->escHtml($signature, 2);
	}
	
	# Filter and quote strings
	my $userNameQ = $m->dbQuote($userName);
	my $titleQ = $m->dbQuote($title);
	my $realNameQ = $m->dbQuote($m->escHtml($realName));
	my $homepageQ = $m->dbQuote($m->escHtml($homepage));
	my $occupationQ = $m->dbQuote($m->escHtml($occupation));
	my $hobbiesQ = $m->dbQuote($m->escHtml($hobbies));
	my $locationQ = $m->dbQuote($m->escHtml($location));
	my $icqQ = $m->dbQuote($m->escHtml($icq));
	my $signatureQ = $m->dbQuote($signature);
	my $extra1Q = $m->dbQuote($m->escHtml($extra1));
	my $extra2Q = $m->dbQuote($m->escHtml($extra2));
	my $extra3Q	= $m->dbQuote($m->escHtml($extra3));
	my $birthdayQ = $m->dbQuote($m->escHtml($birthday));
	my $timezoneQ = $m->dbQuote($m->escHtml($timezone));
	my $languageQ = $m->dbQuote($language);
	my $styleQ = $m->dbQuote($style);
	my $fontFaceQ = $m->dbQuote($m->escHtml($fontFace));
	
	# Check if username is free
	!$m->fetchArray("
		SELECT id FROM $cfg->{dbPrefix}users WHERE userName = $userNameQ AND id <> $optUserId")
		or $m->formError($lng->{errNamGone});

	# Print form errors or finish action
	if (@{$m->{formErrors}}) { $m->printFormErrors() }
	else {
		# Call authorization plugin
		$m->checkAuthz($user, 'userOpt');
		
		# Transaction
		$m->dbBegin();
		eval {
			# Update user
			$m->dbDo("
				UPDATE $cfg->{dbPrefix}users SET
					userName    = $userNameQ,
					realName    = $realNameQ,
					title       = $titleQ, 
					admin       = $admin,
					hideEmail   = $hideEmail,
					dontEmail   = $dontEmail,
					notify      = $notify,
					msgNotify   = $msgNotify,
					manOldMark  = $manOldMark,
					secureLogin = $secureLogin,
					privacy     = $privacy,
					homepage    = $homepageQ, 
					occupation  = $occupationQ, 
					hobbies     = $hobbiesQ,
					location    = $locationQ, 
					icq         = $icqQ,
					signature   = $signatureQ,
					extra1      = $extra1Q, 
					extra2      = $extra2Q, 
					extra3      = $extra3Q,
					birthyear   = $birthyear,
					birthday    = $birthdayQ,
					timezone    = $timezoneQ,
					language    = $languageQ,
					style       = $styleQ,
					fontFace    = $fontFaceQ, 
					fontSize    = $fontSize,
					boardDescs  = $boardDescs,
					showDeco    = $showDeco,
					showAvatars = $showAvatars,
					showImages  = $showImages,
					showSigs    = $showSigs,
					collapse    = $collapse,
					indent      = $indent, 
					topicsPP    = $topicsPP,
					postsPP     = $postsPP
				WHERE id = $optUserId");

			# Update snippets
			for my $snippet (keys %{$cfg->{styleSnippets}}) {
				my $enable = $m->paramBool($snippet);
				my $enabled = $m->fetchArray("
					SELECT userId
					FROM $cfg->{dbPrefix}variables
					WHERE name = '$snippet'
						AND userId = $optUserId");

				if (!$enable && $enabled) {
					$m->dbDo("
						DELETE FROM $cfg->{dbPrefix}variables 
						WHERE name = '$snippet'
							AND userId = $optUserId");
				}
				elsif ($enable && !$enabled) {
					$m->dbDo("
						INSERT INTO $cfg->{dbPrefix}variables (name, userId)
						VALUES ('$snippet', $optUserId)");
				}
			}
			
			# If username changed, update posts.userNameBak
			$m->dbDo("
				UPDATE $cfg->{dbPrefix}posts SET userNameBak = $userNameQ WHERE userId = $optUserId")
				if $userName ne $optUser->{userName};
			
			# Update cookies if secure cookie flag was changed
			if ($secureLogin != $user->{secureLogin} && $optUserId == $userId 
				&& !$cfg->{authenPlg}{request}) {
				$m->setCookies($optUserId, $optUser->{password}, $optUser->{tempLogin}, $secureLogin);
			}
		};
		$@ ? $m->dbRollback() : $m->dbCommit();
		
		# Log action
		$m->logAction(1, 'user', 'options', $userId, 0, 0, 0, $optUserId);
		
		# Redirect
		# TUSK changed this to forward back to user_options.
		$m->redirect('user_options', msg => 'OptChange');
	}
}

# Print form
if (!$submitted || @{$m->{formErrors}}) {
	# Print header
	$m->printHeader();

	# User button links
	my @userLinks = ();
	push @userLinks, { url => $m->url('user_password', uid => $optUserId), 
		txt => 'uopPasswd', ico => 'password' }
		if !$cfg->{authenPlg}{login} && !$cfg->{authenPlg}{request};
	# TUSK begin
	# changing the change email link
	#push @userLinks, { url => $m->url('user_email', uid => $optUserId), 
	push @userLinks, { url => "/view/user/" . $optUser->{userName}, 
		txt => 'uopEmail', ico => 'subscribe' };
	# TUSK end
	push @userLinks, { url => $m->url('user_avatar', uid => $optUserId), 
		txt => 'uopAvatar', ico => 'avatar' } 
		if $cfg->{avatars};
	push @userLinks, { url => $m->url('user_key', uid => $optUserId), 
		txt => 'uopOpenPgp', ico => 'key' }
		if $cfg->{gpgSignKeyId};
	push @userLinks, { url => $m->url('user_ignore'), txt => 'uopIgnore', ico => 'ignore' } 
		if $userId == $optUserId;
	push @userLinks, { url => $m->url('user_boards', uid => $optUserId, ori => 1), 
		txt => 'uopBoards', ico => 'board' };
	push @userLinks, { url => $m->url('user_topics', uid => $optUserId, ori => 1), 
		txt => 'uopTopics', ico => 'topic' }
		if $cfg->{subscriptions};
	push @userLinks, { url => $m->url('user_info', uid => $optUserId), 
		txt => 'uopInfo', ico => 'info' };

	# Print page bar
	my @navLinks = ({ url => $m->url('forum_show'), txt => 'comUp', ico => 'up' });
	$m->printPageBar(mainTitle => $lng->{uopTitle}, subTitle => $optUser->{userName}, 
		navLinks => \@navLinks, userLinks => \@userLinks);
	
	# Determine language
	my ($httpLangCode) = $m->{env}{acceptLang} =~ /^(\w\w)/;
	my $httpLang = $cfg->{languageCodes}{$httpLangCode};
	$optUser->{language} ||= $httpLang || $cfg->{language};
	
	# Set submitted or database values
	$realName = $submitted ? $m->escHtml($realName) : $optUser->{realName};
	$title = $submitted ? $m->escHtml($title) : $m->escHtml($optUser->{title});
	$homepage = $submitted ? $m->escHtml($homepage) : $optUser->{homepage};
	$occupation = $submitted ? $m->escHtml($occupation) : $optUser->{occupation};
	$hobbies = $submitted ? $m->escHtml($hobbies) : $optUser->{hobbies};
	$location = $submitted ? $m->escHtml($location) : $optUser->{location};
	$icq = $submitted ? $m->escHtml($icq) : $optUser->{icq};
	$signature = $submitted ? $signature : $optUser->{signature};
	$extra1 = $submitted ? $m->escHtml($extra1) : $optUser->{extra1};
	$extra2 = $submitted ? $m->escHtml($extra2) : $optUser->{extra2};
	$extra3 = $submitted ? $m->escHtml($extra3) : $optUser->{extra3};
	$fontFace = $submitted ? $m->escHtml($fontFace) : $optUser->{fontFace};
	$fontSize = $submitted ? $fontSize : $optUser->{fontSize};
	$indent = $submitted ? $indent : $optUser->{indent};
	$topicsPP = $submitted ? int($topicsPP) : $optUser->{topicsPP};
	$postsPP = $submitted ? int($postsPP) : $optUser->{postsPP};
	$hideEmail = $submitted ? $hideEmail : $optUser->{hideEmail};
	$dontEmail = $submitted ? $dontEmail : $optUser->{dontEmail};
	$manOldMark = $submitted ? $manOldMark : $optUser->{manOldMark};
	$secureLogin = $submitted ? $secureLogin : $optUser->{secureLogin};
	$privacy = $submitted ? $privacy : $optUser->{privacy};
	$boardDescs = $submitted ? $boardDescs : $optUser->{boardDescs};
	$showDeco = $submitted ? $showDeco : $optUser->{showDeco};
	$showAvatars = $submitted ? $showAvatars : $optUser->{showAvatars};
	$showImages = $submitted ? $showImages : $optUser->{showImages};
	$showSigs = $submitted ? $showSigs : $optUser->{showSigs};
	$collapse = $submitted ? $collapse : $optUser->{collapse};
	$admin = $submitted ? $admin : $optUser->{admin};
	$notify = $submitted ? $notify : $optUser->{notify};
	$msgNotify = $submitted ? $msgNotify : $optUser->{msgNotify};
	$timezone = $submitted ? $timezone : $optUser->{timezone};
	$language = $submitted ? $language : $optUser->{language};
	$style = $submitted ? $style : $optUser->{style};
	
	# Concat birthdate
	if ($submitted) {
		$birthdate = $m->escHtml($birthdate);
	}
	else {
		$birthdate = $optUser->{birthyear} . "-" if $optUser->{birthyear};
		$birthdate .= $optUser->{birthday};
	}

	# Limit language and style to valid selection
	$language = $cfg->{languages}{$language} ? $language : $cfg->{language};
	$style = $cfg->{styles}{$style} ? $style : $cfg->{style};

	# Prepare signature
	if ($cfg->{fullSigs}) { 
		my $fakeBoard = { };
		my $fakePost = { isSignature => 1, body => $signature };
		$m->dbToEdit($fakeBoard, $fakePost);
		$signature = $fakePost->{body};
	}
	else {
		$signature = $m->escHtml($signature, 1) if $submitted;
		$signature =~ s!<br/>!\n!g;
	}

	# Determine checkbox, radiobutton and listbox states
	my $checked = "checked='checked'";
	my $selected = "selected='selected'";
	my %state = (
		hideEmail => $hideEmail ? $checked : undef,
		dontEmail => $dontEmail ? $checked : undef,
		manOldMark => $manOldMark ? $checked : undef,
		secureLogin => $secureLogin ? $checked : undef,
		privacy => $privacy ? $checked : undef,
		boardDescs => $boardDescs ? $checked : undef,
		showDeco => $showDeco ? $checked : undef,
		showAvatars => $showAvatars ? $checked : undef,
		showImages => $showImages ? $checked : undef,
		showSigs => $showSigs ? $checked : undef,
		collapse => $collapse ? $checked : undef,
		admin => $admin ? $checked : undef,
		notify => $notify ? $checked : undef,
		msgNotify => $msgNotify ? $checked : undef,
		"zone$timezone" => $selected,
		"language$language" => $selected,
		"style$style" => $selected,
	);
	my $snippets = $m->fetchAllArray("
		SELECT name 
		FROM $cfg->{dbPrefix}variables 
		WHERE name LIKE 'sty%'
			AND userId = $optUserId");
	$state{$_->[0]} = $checked for @$snippets;
	
	# Print profile options
	print
		"<form action='user_options$m->{ext}' method='post'>\n",
		"<div class='frm'>\n",
		"<div class='hcl'>\n",
		"<span class='htt'>$lng->{uopProfTtl}</span>\n",
		"</div>\n",
		"<div class='ccl'>\n",

# TUSK begin added email address 
	        "E-mail Address: <i> Edit this value in your TUSK profile <a href='/view/user/" . $optUser->{userName} . "'>here</a>.</i><br>",
		"<span style='color:grey'>$user->{email} </span><br><br>\n",
		"$lng->{uopProfRName}:<br/>\n",
	        "<span style='color:grey'>$realName</span><br><br>\n",
		"<input type='hidden' name='realName' size='40' maxlength='100' value='$realName'/><br/>\n",
# TUSK end
		"$lng->{uopProfBdate}<br/>\n",
		"<input type='text' name='birthdate' size='40' maxlength='10' value='$birthdate'/><br/>\n",
		"$lng->{uopProfPage}<br/>\n",
		"<input type='text' name='homepage' size='80' maxlength='100' value='$homepage'/><br/>\n",
		"$lng->{uopProfOccup}<br/>\n",
		"<input type='text' name='occupation' size='80' maxlength='100' value='$occupation'/><br/>\n",
		"$lng->{uopProfHobby}<br/>\n",
		"<input type='text' name='hobbies' size='80' maxlength='100' value='$hobbies'/><br/>\n",
		"$lng->{uopProfLocat}<br/>\n",
		"<input type='text' name='location' size='80' maxlength='100' value='$location'/><br/>\n",
		"$lng->{uopProfIcq}<br/>\n",
		"<input type='text' name='icq' size='80' maxlength='100' value='$icq'/><br/>\n",
		"$lng->{uopProfSig} ", $cfg->{fullSigs} ? "" : $lng->{uopProfSigLt}, "<br/>\n",
		"<textarea name='signature' cols='80' rows='2'>$signature</textarea><br/>\n";
	
	# Print configurable fields
	print
		"$cfg->{longExtra1}<br/>\n",
		"<input type='text' name='extra1' size='80' maxlength='255' value='$extra1'/><br/>\n"
		if $cfg->{extra1} && $cfg->{regExtra1} < 2;
	
	print
		"$cfg->{longExtra2}<br/>\n",
		"<input type='text' name='extra2' size='80' maxlength='255' value='$extra2'/><br/>\n"
		if $cfg->{extra2} && $cfg->{regExtra2} < 2;
	
	print
		"$cfg->{longExtra3}<br/>\n",
		"<input type='text' name='extra3' size='80' maxlength='255' value='$extra3'/><br/>\n"
		if $cfg->{extra3} && $cfg->{regExtra3} < 2;
	
	print 
		"</div>\n",
		"</div>\n";
	
	# Print general options
	print
		"<div class='frm'>\n",
		"<div class='hcl'>\n",
		"<span class='htt'>$lng->{uopPrefTtl}</span>\n",
		"</div>\n",
		"<div class='ccl'>\n",
		"<label><input type='checkbox' name='hideEmail' $state{hideEmail}/>",
		" $lng->{uopPrefHdEml}</label><br/>\n",
		"<label><input type='checkbox' name='privacy' $state{privacy}/>",
		" $lng->{uopPrefPrivc}</label><br/>\n";
		
	print
		"<label><input type='checkbox' name='secureLogin' $state{secureLogin}/>",
		" $lng->{uopPrefSecLg}</label><br/>\n"
		if !$cfg->{authenPlg}{request} && $cfg->{enableSecLogin};

	print
		"<label><input type='checkbox' name='manOldMark' $state{manOldMark}/>",
		" $lng->{uopPrefMnOld}</label><br/>\n",
		"<label><input type='checkbox' name='notify' $state{notify}/>",
		" $lng->{uopPrefNt}</label><br/>\n",
		"<label><input type='checkbox' name='msgNotify' $state{msgNotify}/>",
		" $lng->{uopPrefNtMsg}</label>\n",
		"</div>\n",
		"</div>\n\n";
	
	# Print display options
	print
		"<div class='frm'>\n",
		"<div class='hcl'>\n",
		"<span class='htt'>$lng->{uopDispTtl}</span>\n",
		"</div>\n",
		"<div class='ccl'>\n",
 		"<div style='float: right; width: 50%'>\n",
		"<label><input type='checkbox' name='boardDescs' $state{boardDescs}/>",
		" $lng->{uopDispDescs}</label><br/>\n",
		"<label><input type='checkbox' name='showDeco' $state{showDeco}/>",
		" $lng->{uopDispDeco}</label><br/>\n";
		
	print
		"<label><input type='checkbox' name='showAvatars' $state{showAvatars}/>",
		" $lng->{uopDispAvas}</label><br/>\n"
		if $cfg->{avatars};
		
	print
		"<label><input type='checkbox' name='showImages' $state{showImages}/>",
		" $lng->{uopDispImgs}</label><br/>\n",
		"<label><input type='checkbox' name='showSigs' $state{showSigs}/>",
		" $lng->{uopDispSigs}</label><br/>\n",
		"<label><input type='checkbox' name='collapse' $state{collapse}/>",
		" $lng->{uopDispColl}</label><br/>\n";

  if (%{$cfg->{styleSnippets}}) {
		for my $snippet (sort keys %{$cfg->{styleSnippets}}) {
			my $label = $lng->{$snippet} || $snippet;
			print 
				"<label><input type='checkbox' name='$snippet' $state{$snippet}/>",
				" $label</label><br/>\n";
		}
	}

	print 
		"</div>\n",
		"$lng->{uopDispLang}<br/>\n",
		"<select name='language' size='1'>\n";
	
	for (sort keys %{$cfg->{languages}}) {
		print "<option value='$_' $state{\"language$_\"}>$_</option>\n"
	}
	
	print
		"</select><br/>\n",
		"$lng->{uopDispTimeZ}<br/>\n",
		"<select name='timezone' size='1'>\n";

	my @zones = ();		
	for (-28 .. 28) {
		my $zone  = $_ / 2;
		$zone = "+$zone" if $zone > 0;
		push @zones, $zone;
	}

	for (@zones) {
		my $name = "GMT" . ($_ ? $_ : "");
		print "<option value='$_' $state{\"zone$_\"}>$name</option>\n";
	}
	
	print 
		"</select><br/>\n",
		"$lng->{uopDispStyle}<br/>\n",
		"<select name='style' size='1'>\n";
	
	for (sort keys %{$cfg->{styles}}) {
		my %styleOpt = $cfg->{styleOptions}{$_} =~ /(\w+)="(.+?)"/g;
		next if $styleOpt{excludeUA} && $m->{env}{userAgent} =~ /$styleOpt{excludeUA}/
			|| $styleOpt{requireUA} && $m->{env}{userAgent} !~ /$styleOpt{requireUA}/;
		print "<option value='$_' $state{\"style$_\"}>$_</option>\n"
	}
	
	print 
		"</select><br/>\n",
		"$lng->{uopDispFFace}<br/>\n",
		"<input type='text' name='fontFace' size='20' maxlength='20' value='$fontFace'/><br/>\n",
		"$lng->{uopDispFSize}<br/>\n",
		"<input type='text' name='fontSize' size='6' maxlength='2' value='$fontSize'/><br/>\n",
		"$lng->{uopDispIndnt}<br/>\n",
		"<input type='text' name='indent' size='6' maxlength='2' value='$indent'/><br/>\n",
		" $lng->{uopDispTpcPP}<br/>\n",
		"<input type='text' name='topicsPP' size='6' maxlength='3' value='$topicsPP'/><br/>\n",
		" $lng->{uopDispPstPP}<br/>\n",
		"<input type='text' name='postsPP' size='6' maxlength='3' value='$postsPP'/>\n",
		"</div>\n",
		"</div>\n\n";
	
	# Print admin only options
	if ($user->{admin}) {
		print
			"<div class='frm'>\n",
			"<div class='hcl'>\n",
			"<span class='htt'>Admin Options</span>\n",
			"</div>\n",
			"<div class='ccl'>\n",
			"Username<br/>\n",
			"<input type='text' name='userName' size='20' maxlength='$cfg->{maxUserNameLen}'",
			" value='$optUser->{userName}'/><br/>\n",
			"Title (see FAQ.html for details)<br/>\n",
			"<select name='titleSel' size='1'>\n",
			"<option value=''>(individual title below)</option>\n";
		
		for my $ttl (@{$cfg->{userTitles}}) {
			$ttl = $m->escHtml($ttl);
			my $sel = $ttl eq $title ? "selected='selected'" : "";
			print "<option value='$ttl' $sel>$ttl</option>\n";
		}
		
		print
			"</select><br/>\n",
			"<input type='text' name='title' size='80' value='$title'/><br/><br/>\n",
			"<label><input type='checkbox' name='admin' $state{admin}/>",
			" User is a forum admin</label><br/>\n",
			"<label><input type='checkbox' name='dontEmail' $state{dontEmail}/>",
			" Don't send email to this user</label>\n",
			"</div>\n",
			"</div>\n\n";
	}
	
	# Print submit section
	print
		"<div class='frm'>\n",
		"<div class='hcl'>\n",
		"<span class='htt'>$lng->{uopSubmitTtl}</span>\n",
		"</div>\n",
		"<div class='ccl'>\n",
		$m->submitButton('uopSubmitB', 'edit'),
		"<input type='hidden' name='uid' value='$optUserId'/>\n",
		$m->stdFormFields(),
		"</div>\n",
		"</div>\n",
		"</form>\n\n";
	
	# Log action
	$m->logAction(3, 'user', 'options', $userId, 0, 0, 0, $optUserId);
	
	# Print footer
	$m->printFooter();
}
