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

package MwfMain;
use 5.006;
use strict;
use warnings;
no warnings qw(uninitialized redefine once);
$MwfMain::VERSION = "2.12.0";

#------------------------------------------------------------------------------

# TUSK begin load ForumKey functions
use Forum::ForumKey;
use TUSK::Core::DB;
use Data::Dumper;
use TUSK::Constants;
use TUSK::ErrorReport;
use Apache2::RequestRec;
# TUSK end load ForumKey functions

# Load global configuration
use Forum::MwfConfigGlobal;


# TUSK changed some of these constants so the cron scripts would work
# Constants
use constant MP1  => defined($ENV{COMMAND_LINE}) ? 0 
    : defined($mod_perl::VERSION) && $mod_perl::VERSION < 1.99 ? 1 
    : 0;
use constant MP2  => defined($ENV{COMMAND_LINE}) ? 0
    : defined($mod_perl2::VERSION) && $mod_perl2::VERSION > 1.99 ? 1 
    : 0;
use constant MP   => MP1 || MP2;
use constant CGI  => !MP && $ENV{GATEWAY_INTERFACE} ? 1 : 0;
use constant FCGI => CGI && $ENV{FCGI_ROLE} ? 1 : 0;


###############################################################################
# Initialization

#------------------------------------------------------------------------------
# Create MwfMain object for CGI/mod_perl requests

sub new
{
	my $class = shift();
	my $ap = shift();

	# TUSK begin added an argument in lib/Forum/ForumKey::new_post_forums
	# the argument tells whether this user is an admin or not, adding it
	# to the $m hash
	my $forum_admin = shift();
	my $redirect_error_flag = shift() || 0; # when MwfMain is called from a non forum page we do not want the forum error format to appear
	my $board_keys = shift() || undef;

	# TUSK end
	
	# Check execution environment
	MP || CGI or die "Execution environment unknown, should be CGI or mod_perl.";

	# Create instance	
	my $m = { 
		ap => $ap,          # Apache/Apache::RequestRec object
		apr => undef,       # Apache(2)::Request object
		dbh => undef,       # DBI handle
		ext => '.pl',       # Script file extension
		now => time(),      # Request time (instead of local $now vars)
		env => {},          # CGI-environment-style vars
		gcfg => $MwfConfigGlobal::gcfg, # Host/path to forum mapping etc.
		query => "",        # Last SQL query, since MySQL's errmsg are useless
		queries => [],      # All SQL queries in debug mode
		queryNum => 0,      # Number of SQL queries performed
		printPhase => 0,    # 1=HTTP-header, 2=page-header, 4=all printed
		transaction => 0,   # Currently in SQL transaction?
		boardAdmin => {},   # Cached boardAdmin status
		boardMember => {},  # Cached boardMember status
		pageBar => [],      # Cached HTML for repeated page bars
		cookies => [],      # Cookies to be printed in CGI mode
		warnings => [],     # Warnings shown in page footer
		formErrors => [],   # Errors from form validation
		sessionId => undef, # Session id for cookieless login
		cdataEnd => "",     # CDATA end marker in XHTML mode
		cdataStart => "",   # CDATA start marker in XHTML mode
		contentType => "text/html",  # Or application/xhtml+xml
		style => "default", # Current style subpath/filename
		styleOptions => {}, # Current style's options
		showIcons => 0,     # Show button icons to user?

		# TUSK begin added a forumAdmin field, indicates whether a new user should be a forum admin, used in the MwfPlgAuthen.pm plugin.
		forumAdmin => $forum_admin, 
		redirectError => $redirect_error_flag,
		board_keys => $board_keys,
		# TUSK end
	};
	$class = ref($class) || $class;
	bless $m, $class;

	# Measure page creation time
	if ($MwfConfigGlobal::gcfg->{pageTime}) {
		require Time::HiRes;
		$m->{startTime} = [Time::HiRes::gettimeofday()];
	}
	
	# Load mod_perl modules
	$m->initModPerl() if MP;

	# Init CGI environment variable equivalents
	$m->initEnvironment();

	# Load basic configuration
	$m->initConfiguration();

	# Set preliminary image path
	$m->{stylePath} = "$m->{cfg}{dataPath}/$m->{style}";

	# Create CGI or mod_perl request object
	$m->initRequestObject();

	# Connect database
	$m->dbConnect();

	# Load configuration from database
	$m->loadConfiguration();

	# Select content type
	$m->initContentType();

	# Set default user
	$m->initDefaultUser();

	# Set preliminary language
	$m->setLanguage();

	# Authenticate user
	$m->authenticateUser();
	
	# Cron emulation
	$m->cronEmulation();

	# Update user's lastOnTime etc.
	$m->updateUser() if $m->{user}{id};

	# TUSK begin
	# set variables that are defined in TUSK::Constants
	Forum::ForumKey::setCfg($m);
	# TUSK end
	
	return ($m, $m->{cfg}, $m->{lng}, $m->{user}) if wantarray;
	return $m;
}

#------------------------------------------------------------------------------
# Create MwfMain object for commandline scripts

sub newShell
{
	my $class = shift();
	my %params = @_;
	my $allowCgi = $params{allowCgi};  # Allow execution over CGI
	my $upgrade = $params{upgrade};  # Avoid incompatibilities with upgrade scripts

	# Create instance	
	my $m = {
		ext => '.pl',
		now => time(),
		gcfg => $MwfConfigGlobal::gcfg,
		env => {},
		transaction => 0,
	};
	$class = ref($class) || $class;
	bless $m, $class;

	# Don't run this over CGI unless explicitly allowed
	!CGI && !MP || $allowCgi || $ENV{MWF_ALLOWCGI}
		or die "This script must not be executed via CGI or mod_perl.";

	# Print HTTP header under CGI if started directly (not spawned by forum)
	print "Content-Type: text/plain\n\n" if (CGI || MP) && !$ENV{MWF_ALLOWCGI};

	# Load base configuration
	$m->{env}{realHost} = $ARGV[0];
	$m->{env}{scriptUrlPath} = $ARGV[0];
	$m->initConfiguration();

	# Connect database
	$m->dbConnect();

	# Load configuration from database
	$m->loadConfiguration() if !$upgrade;
	my $cfg = $m->{cfg};

	# Set language
	$m->setLanguage() if !$upgrade;

	# TUSK begin
	# set variables that are defined in TUSK::Constants
	Forum::ForumKey::setCfg($m);
	# TUSK end

	return ($m, $cfg, $m->{lng}) if wantarray;
	return $m;
}

#------------------------------------------------------------------------------
# mod_perl initialization

sub initModPerl
{
	my $m = shift();

	if (MP1) {
		# Load MP1 modules
		require Apache;
		require Apache::Constants;
		require Apache::Connection;
		require Apache::File;
		require Apache::Request;
	}
	else {
		# Load MP2 modules
		require Apache2::Connection;
		require Apache2::RequestRec;
		require Apache2::RequestIO;
		require Apache2::RequestUtil;
		require Apache2::ServerUtil;
		require Apache2::Request;
		require ModPerl::Util;
	}
}

#------------------------------------------------------------------------------
# Init CGI environment variable equivalents

sub initEnvironment
{
	my $m = shift();

	# Shortcuts
	my $ap = $m->{ap};
	my $env = $m->{env};
	
	if (MP) {
		$env->{port} = $ap->get_server_port;
		$env->{method} = $ap->method;
		$env->{protocol} = $ap->protocol;
		$env->{host} = $ap->hostname;
		$env->{realHost} = $ap->headers_in->{'X-Forwarded-Host'} 
			|| $ap->headers_in->{'X-Host'} || $ap->hostname;
		($env->{script}) = $ap->uri =~ m!.*/(.*)\.!;
		($env->{scriptUrlPath}) = $ap->uri =~ m!(.*)/!;
		$env->{cookie} = $ap->headers_in->{'Cookie'};
		$env->{referrer} = $ap->headers_in->{'Referer'};
		$env->{accept} = lc $ap->headers_in->{'Accept'};
		$env->{acceptLang} = lc $ap->headers_in->{'Accept-Language'};
		$env->{userAgent} = $ap->headers_in->{'User-Agent'};
		$env->{userIp} = $ap->connection->remote_ip;
		$env->{userAuth} = $ap->user;
		$env->{params} = $ap->args;
		
		if (MP1) {
			$env->{server} = Apache::Constants::SERVER_VERSION();
		}
		else {
			$env->{server} = Apache2::ServerUtil::get_server_version();
		}
	}
	else {
		$env->{port} = $ENV{SERVER_PORT};
		$env->{method} = $ENV{REQUEST_METHOD};
		$env->{protocol} = $ENV{SERVER_PROTOCOL};
		($env->{host}) = $ENV{HTTP_HOST} =~ m!([^:]*)!;
		($env->{realHost}) = $ENV{HTTP_X_FORWARDED_HOST} || $ENV{HTTP_X_HOST} || $env->{host};
		($env->{script}) = $ENV{SCRIPT_NAME} =~ m!.*/(.*)\.!;
		($env->{scriptUrlPath}) = $ENV{SCRIPT_NAME} =~ m!(.*)/!;
		$env->{cookie} = $ENV{HTTP_COOKIE} || $ENV{COOKIE};
		$env->{referrer} = $ENV{HTTP_REFERER};
		$env->{accept} = lc $ENV{HTTP_ACCEPT};
		$env->{acceptLang} = lc $ENV{HTTP_ACCEPT_LANGUAGE};
		$env->{userAgent} = $ENV{HTTP_USER_AGENT};
		$env->{userIp} = $ENV{REMOTE_ADDR};
		$env->{userAuth} = $ENV{REMOTE_USER};
		$env->{params} = $ENV{QUERY_STRING};
		$env->{server} = $ENV{SERVER_SOFTWARE};
	}
}

#------------------------------------------------------------------------------
# Create CGI or mod_perl request object

sub initRequestObject
{
	my $m = shift();

	# Shortcuts
	my $ap = $m->{ap};
	my $cfg = $m->{cfg};

	# Set STDOUT encoding in UTF-8 mode
	binmode STDOUT, ':utf8' if $m->{gcfg}{utf8};

	if (MP1) {
		# Use Apache::Request object under mod_perl 1
		$m->{apr} = Apache::Request->new($ap,
			POST_MAX => $cfg->{maxAttachLen},
			TEMP_DIR => $cfg->{attachFsPath},
		);

		# Parse POST request and check for errors
		$m->{apr}->parse() == 0 
			or $m->userError("Input exceeds maximum allowed size or is corrupted.")
			if $ap->method eq 'POST';
	}
	elsif (MP2) {
		# Use Apache2::Request object under mod_perl 2
		$m->{apr} = Apache2::Request->new($ap,
			POST_MAX => $cfg->{maxAttachLen},
			TEMP_DIR => $cfg->{attachFsPath},
		);

		# Discard raw request body 	 
		$m->{apr}->discard_request_body() == 0 or $m->userError("Input is corrupted.");

		# Parse POST request and check for errors
		$m->{apr}->parse() == 0 
			or $m->userError("Input exceeds maximum allowed size or is corrupted.")
			if $ap->method eq 'POST';
	}
	else {
		# Use MwfCGI object
		require Forum::MwfCGI;
		MwfCGI::_reset_globals() if FCGI;
		MwfCGI::max_read_size($cfg->{maxAttachLen});
		$m->{cgi} = MwfCGI->new();
		!$m->{cgi}->truncated 
			or $m->userError("Input exceeds maximum allowed size or is corrupted.");
	}
}	

#------------------------------------------------------------------------------
# Load basic configuration

sub initConfiguration
{
	my $m = shift();

	# Load basic configuration
	my $module = $m->{gcfg}{forums}{$m->{env}{realHost}} 
		|| $m->{gcfg}{forums}{$m->{env}{scriptUrlPath}} || "MwfConfig";
	require "Forum/$module.pm";
	eval "\$m->{cfg} = \$${module}::cfg";
	!$@ or die "Configuration assignment failed ($@).";
	
	# Load configuration defaults
	my $cfg = $m->{cfg};
	if (!$cfg->{lastUpdate}) {
		require Forum::MwfDefaults;
		for my $opt (@$MwfDefaults::options) {
			$cfg->{$opt->{name}} = $opt->{default};
		}
	}
}

#------------------------------------------------------------------------------
# Load configuration from database

sub loadConfiguration
{
	my $m = shift();

	# Shortcuts
	my $cfg = $m->{cfg};
	my $utf8 = $m->{gcfg}{utf8} && !$m->{pgsql};

	# Exit if database config hasn't changed
	if (MP || FCGI) {
		$m->{query} = "
			SELECT value FROM $cfg->{dbPrefix}config WHERE name = 'lastUpdate'";
		my $sth = $m->{dbh}->prepare($m->{query}) or $m->dbError();
		$sth->execute() or $m->dbError();
		return if $sth->fetchrow_array() <= $cfg->{lastUpdate};
	}

	# Copy database config to $cfg
	my ($name, $value, $parse);
	$m->{query} = "
		SELECT name, value, parse FROM $cfg->{dbPrefix}config";
	my $sth = $m->{dbh}->prepare($m->{query}) or $m->dbError();
	$sth->execute() or $m->dbError();
	$sth->bind_columns(\($name, $value, $parse));
	while ($sth->fetch()) {
		utf8::decode($value) if $utf8;
		if (!$parse) {
			# Simple string/numeric/boolean option
			$cfg->{$name} = $value;
		}
		elsif ($parse eq 'array') {
			# Array option
			$cfg->{$name} = [ split(/\n/, $value) ];
		}
		elsif ($parse eq 'hash') {
			# Hash option
			$cfg->{$name} = {};
			for my $line (split(/\n/, $value)) {
				my ($key, $val) = $line =~ /^\s*(.+?)\s*=\s*(.*?)\s*$/;
				$cfg->{$name}{$key} = $val;
			}
		}
	}
	
	# Post-processing of options
	if ($cfg->{dataBaseUrl} && $cfg->{dataPath} !~ /^$cfg->{dataBaseUrl}/) {
		$cfg->{dataPath} = $cfg->{dataBaseUrl} . $cfg->{dataPath};
		$cfg->{attachUrlPath} = $cfg->{dataBaseUrl} . $cfg->{attachUrlPath};
	}
}

#------------------------------------------------------------------------------
# Select content type

sub initContentType 
{
	my $m = shift();

	if ($m->{cfg}{xhtml} && 
		($m->{env}{accept} =~ /application\/xhtml\+xml/ || $m->{env}{userAgent} =~ /^W3C/)) {
		$m->{contentType} = "application/xhtml+xml";
		$m->{cdataStart} = "<![CDATA[";
		$m->{cdataEnd} = "]]>";
	}
	else {
		$m->{contentType} = "text/html";
		$m->{cdataStart} = "";
		$m->{cdataEnd} = "";
	}
}

#------------------------------------------------------------------------------
# Set language

sub setLanguage
{
	my $m = shift();
	my $forceLang = shift() || undef;

	# Shortcuts
	my $cfg = $m->{cfg};
	my $user = $m->{user};
	
	# Get language from user agent (primitive parsing)
	my ($uaLangCode) = $m->{env}{acceptLang} =~ /^(\w\w)/;
	my $uaLang = $cfg->{languageCodes}{$uaLangCode};
	
	# Determine which language to set
	undef $forceLang if !$cfg->{languages}{$forceLang};
	undef $user->{language} if !$cfg->{languages}{$user->{language}};
	my $lang = $forceLang || $user->{language} || $uaLang || $cfg->{language};
	
	# Determine module name
	my $module = $cfg->{languages}{$lang};
	$module = "MwfEnglish" if $module !~ /^Mwf[a-zA-Z0-9_]+$/;
	
	# Load and assign language
	# TUSK begin: module is located at a specific path
	eval { require "Forum/$module.pm" };
	# TUSK end
	if ($@) {
		$m->logError("Language loading failed, defaulting to English ($@).", 1);
		require Forum::MwfEnglish;
		$m->{lng} = $MwfEnglish::lng;
	}
	else {
		eval "\$m->{lng} = \$${module}::lng";
		if (!$m->{lng}) {
			$m->logError("Language assignment failed, defaulting to English.", 1);
			require Forum::MwfEnglish;
			$m->{lng} = $MwfEnglish::lng;
		}
	}
}

#------------------------------------------------------------------------------
# Cron emulation

sub cronEmulation
{
	my $m = shift();

	if ($m->{cfg}{cronEmu}) {
		my (undef, undef, undef, $today) = localtime(time());
		my $lastExecDay = $m->getVar('crnExcDay') || 0;

		if ($today != $lastExecDay) {
			$m->setVar('crnExcDay', $today);

			# Tell user to come back later
			$m->printHeader();
			print
				"<div class='frm nte'>\n",
				"<div class='hcl'>\n",
				"<span class='htt'>$m->{lng}{errNote}</span>\n",
				"</div>\n",
				"<div class='ccl'>\n",
				"$m->{lng}{errCrnEmuBsy}\n",
				"</div>\n",
				"</div>\n\n";
			$m->printFooter();
			
			# Execute cronjob scripts and wait for them to finish
			$ENV{MWF_ALLOWCGI} = 1;
			system "perl cron_jobs$m->{ext}";
			system "perl cron_subscriptions$m->{ext}";
			$ENV{MWF_ALLOWCGI} = 0;
			
			FCGI ? die : exit;
		}
	}
}


###############################################################################
# Utility Functions

#------------------------------------------------------------------------------
# Replace placeholders in language string

sub formatStr
{
	my $m = shift();
	my $str = shift();
	my $params = shift();

	for my $key (keys %$params) {
		my $repl = $params->{$key};
		if (ref($repl)) {
			my ($format, $value) = @$repl;
			$value = sprintf($format, $value);
			$str =~ s!\[\[$key\]\]!$value!;
		}
		else {
			$str =~ s!\[\[$key\]\]!$repl!;
		}
	}
	return $str;
}

#------------------------------------------------------------------------------
# Get time string from seconds-since-epoch

sub formatTime
{
	my $m = shift();
	my $epoch = shift();
	my $tz = shift();
	my $format = shift() || $m->{cfg}{timeFormat};
	
	if (MP1) { 
		require Apache::Util;
		return Apache::Util::ht_time($epoch + $tz * 3600, $format);
	}
	elsif (MP2) { 
		require Apache2::Util;
		return Apache2::Util::ht_time($m->{ap}->pool, $epoch + $tz * 3600, $format);
	}
	else {
		require POSIX;
		return POSIX::strftime($format, gmtime($epoch + $tz * 3600));
	}
}

#------------------------------------------------------------------------------
# Format topic tag/icon string

sub formatTopicTag
{
	my $m = shift();
	my $key = shift();
	
	my $tag = $m->{cfg}{topicTags}{$key};

	if ($tag =~ /\.(?:jpg|png|gif)/i && $tag !~ /[<]/) {
		# Create image tag from image file name
		my ($src, $alt) = $tag =~ /([\w\.]+)\s*(.*)?/;
		return "<img class='ttg' src='$m->{cfg}{dataPath}/$src' title='$alt' alt='[$alt]'/>";
	}
	else {
		# Use tag as is
		return $tag;
	}
}

#------------------------------------------------------------------------------
# Format user title/icon string

sub formatUserTitle 
{
	my $m = shift();
	my $title = shift();

	if ($title =~ /[<\[\(]/) {
		# Use title with < ( [ as is
		return $title;
	}
	elsif ($title =~ /\.(?:jpg|png|gif)/i) {
		# Create image tag from image file name
		my ($src, $alt) = $title =~ /([\w\.]+)\s*(.*)?/;
		return "<img class='utt' src='$m->{cfg}{dataPath}/$src' title='$alt' alt='($alt)'/>";
	}
	else {
		# Put title in parens
		return "($title)";
	}
}

#------------------------------------------------------------------------------
# Format user rank/icon string

sub formatUserRank
{
	my $m = shift();
	my $postNum = shift();

	for my $line (@{$m->{cfg}{userRanks}}) {
		my ($num, $rank) = $line =~ /(\d+)\s+(.+)/;
		if ($postNum >= $num) {
			if ($rank =~ /[<\[\(]/) {
				# Use rank with < ( [ as is
				return $rank;
			}
			elsif ($rank =~ /\.(?:jpg|png|gif)/i) {
				# Create image tag from image file name
				my ($src, $alt) = $rank =~ /([\w\.]+)\s*(.*)?/;
				return "<img class='rnk' src='$m->{cfg}{dataPath}/$src' title='$alt' alt='($alt)'/>";
			}
			else {
				# Put rank in parens
				return "($rank)";
			}
		}
	}
}

#------------------------------------------------------------------------------
# Shorten string and add ellipsis if necessary 

sub abbr
{
	my $m = shift();
	my $str = shift();
	my $maxLength = shift() || 10;  # Excluding dots
	my $removeHtml = shift() || 0;

	# Remove HTML
	if ($removeHtml) {
		$str =~ s/<.+?>/ /g;
	}

	# Compress multiple spaces to make better use of given length
	$str =~ s/&#160;/ /g;
	$str =~ s/\s{2,}/ /g;

	# Unescape HTML to count actual characters and to avoid breaking entities
	$str = $m->deescHtml($str);
	
	# Shorten and append ellipsis
	my $oldLen = length($str);
	$str = substr($str, 0, $maxLength);
	$str .= "..." if $oldLen > length($str);

	# Escape again
	$str = $m->escHtml($str);
	
	return $str;
}

#------------------------------------------------------------------------------
# Get the greatest of the args

sub max 
{
	my $m = shift();

	my $max = undef;
	for (@_) { $max = $_ if $_ > $max || !defined($max) }
	return $max;
}

#------------------------------------------------------------------------------
# Get the least of the args

sub min 
{
	my $m = shift();

	my $min = undef;
	for (@_) { $min = $_ if $_ < $min || !defined($min) }
	return $min;
}

#------------------------------------------------------------------------------
# Get the first argument that is defined

sub firstDef
{
	my $m = shift();

	for (@_) { return $_ if defined }
	return undef;
}

#------------------------------------------------------------------------------
# Call plugin

sub callPlugin
{
	my $m = shift();
	my $plugin = shift();
	
	return if !$plugin;

	my ($module) = $plugin =~ /(.+?)::/;
	if ($module !~ /^MwfPlg[a-zA-Z0-9_]+$/) {
		$m->logError("Invalid plugin module configuration", 1);
		return undef;
	}

	my $func = undef;
	my $result = undef;
	eval { 
	    # TUSK begin modified path for module.pm
	    require "Forum/$module.pm";
	    # TUSK end
	    $func = \&$plugin;
	};
	!$@ && $func or $m->logError("Plugin module loading failed: $@", 1);

	eval { 
		$result = &$func(m => $m, @_);
	};
	!$@ or $m->logError("Plugin function execution failed: $@", 1);
	
	return $result;
}

#------------------------------------------------------------------------------
# Execute external program with cmd/in/out/err 

sub ipcRun
{
	my $m = shift();

	#require IPC::Run3;
	#my $success = eval { IPC::Run3::run3(shift(), shift(), shift(), shift()) };
	require IPC::Run;
	my $success = eval { IPC::Run::run(shift(), shift(), shift(), shift()) };
	$success && !$@ or $m->logError("ipcRun failed ($@).");
	return $success;
}

#------------------------------------------------------------------------------
# Get MD5 hash of string

sub md5
{
	my $m = shift();
	my $str = shift();

	if (!$m->{sqlite}) {
		my $strQ = $m->dbQuote($str);
		return scalar $m->fetchArray("SELECT MD5($strQ)");
	}
	else {
		require Digest::MD5;
		return Digest::MD5::md5_hex($m->encUtf8($str));
	}
}

#------------------------------------------------------------------------------
# Get 128-bit 32 hex-digit random id for auth tickets etc.

sub randomId
{
	my $m = shift();

	my $rnd = "";
	eval { 
		open my $fh, "/dev/urandom" or die;
		read $fh, $rnd, 16;
		close $fh;
	};
	my $time = eval { require Time::HiRes } ? Time::HiRes::gettimeofday() : time();
	return $m->md5(unpack("H*", $rnd . rand() . $time . $m . $$ . $< . $]));
}

#------------------------------------------------------------------------------
# Encode string (clear internal UTF-8 flag) when in UTF-8 mode

sub encUtf8
{
	my $m = shift();
	my $str = shift();

	utf8::encode($str) if $m->{gcfg}{utf8};
	return $str;
}

#------------------------------------------------------------------------------
# Decode string (set internal UTF-8 flag) when in UTF-8 mode

sub decUtf8
{
	my $m = shift();
	my $str = shift();

	return undef if $m->{gcfg}{utf8} && !utf8::decode($str);
	return $str;
}

#------------------------------------------------------------------------------
# Create thumbnail image

sub addThumbnail
{
	my $m = shift();
	my $imgFsPath = shift();

	# Load modules
	my $gd = eval { require GD; require Image::Info; };
	eval { require Image::Magick } 
		or $m->cfgError("Modules required for thumbnails not available.") if !$gd;

	# Get image info without loading full image
	my $thbFsPath = $imgFsPath;
	$thbFsPath =~ s!\.(?:jpg|png|gif)$!.thb.jpg!i;
	my ($imgW, $imgH);
	if ($gd) {
		my $info = Image::Info::image_info($imgFsPath);
		$info or return -1;
		$imgW = $info->{width};
		$imgH = $info->{height};
		$imgW && $imgH or return -1;
	}
	else {
		my $info = Image::Magick->new();
		($imgW, $imgH) = $info->Ping($imgFsPath);
		$imgW && $imgH or return -1;
	}
	
	# Determine values
	my $shrW = 150 / $imgW;
	my $shrH = 150 / $imgH;
	my $shrink = $m->min($shrW, $shrH, 1);
	my $thbW = $imgW * $shrink;
	my $thbH = $imgH * $shrink;
	my $imgSize = -s $imgFsPath;
	my $useThb = $shrink < 1 || $imgSize > 15 * 1024;

	# Return if no need to create thumbnail	
	return 0 if !$useThb;
	
	# Create thumbnail image
	if ($gd) {
		GD::Image->trueColor(1);
		my $img = GD::Image->new($imgFsPath);
		$img or return -1;
		my $thb = GD::Image->new($thbW, $thbH);
		$thb->fill(0, 0, $thb->colorAllocate(239,239,239));
		$thb->copyResampled($img, 0, 0, 0, 0, $thbW, $thbH, $imgW, $imgH);
		open my $thbFh, ">$thbFsPath" or $m->cfgError($!);
		binmode $thbFh;
		print $thbFh $thb->jpeg(70);
		close $thbFh;
	}
	else {
		my $thb = Image::Magick->new(size => "${thbW}x$thbH");
		$thb->Read('xc:#efefef');
		my $img = Image::Magick->new();
		my $rc = $img->Read($imgFsPath . "[0]");
		!$rc or return -1;
		$img->Resize(width => $thbW, height => $thbH);
		$thb->Composite(image => $img);
		$thb->Write(filename => $thbFsPath, compression => 'JPEG', quality => 70);
	}
	
	return 1;
}


###############################################################################
# CGI Functions

#------------------------------------------------------------------------------
# Get parameter definedness

sub paramDefined
{
	my $m = shift();
	my $name = shift();
	
	return defined(eval {$m->{apr}->param($name)}) ? 1 : 0 if MP;
	return defined($m->{cgi}->param($name)) ? 1 : 0;
}

#------------------------------------------------------------------------------
# Get int parameter(s)

sub paramInt
{
	my $m = shift();
	my $name = shift();

	if (wantarray()) {
		my @ints;
		if (MP) { @ints = eval {$m->{apr}->param($name)} || () }
		else { @ints = $m->{cgi}->param($name) || () }
		@ints = map(int($_), @ints);
		return @ints;
	}
	else {
		return int(eval {$m->{apr}->param($name)} || 0) if MP;
		return int($m->{cgi}->param($name) || 0);
	}
}

#------------------------------------------------------------------------------
# Get boolean parameter

sub paramBool
{
	my $m = shift();
	my $name = shift();

	return eval {$m->{apr}->param($name)} ? 1 : 0 if MP;
	return $m->{cgi}->param($name) ? 1 : 0;
}

#------------------------------------------------------------------------------
# Get string parameter

sub paramStr
{
	my $m = shift();
	my $name = shift();

	my $str;
	if (MP) { 
		$str = eval { $m->{apr}->param($name) };
		!$@ or $m->paramError("Parameter '$name' is not valid.");
	}
	else { 
		$str = $m->{cgi}->param($name);
	}
	$str = "" if !defined($str);
	
	if ($m->{gcfg}{utf8}) {
		# Decode UTF-8 and check validity
		utf8::decode($str) or $m->paramError("Parameter '$name' is not valid UTF-8.");

		# Normalize to NFC
		require Unicode::Normalize;
		my $orgStr = undef;
		$orgStr = $str if $m->{cfg}{debug};
		$str = Unicode::Normalize::NFC($str);

		# Warn if input wasn't in NFC or NFKC
		if ($m->{cfg}{debug}) {
			$m->logError("Parameter '$name' is not in Unicode NFC.", 1)
				if $orgStr ne $str;
			$m->logError("Parameter '$name' is not in Unicode NFKC.", 1)
				if $orgStr ne Unicode::Normalize::NFKC($str);
		}
	}

	return $str;
}

#------------------------------------------------------------------------------
# Get identifier string parameter

sub paramStrId
{
	my $m = shift();
	my $name = shift();
	
	my $str;
	if (MP) { ($str) = eval {$m->{apr}->param($name)} =~ /^([A-Za-z0-9_]+)$/	}
	else { ($str) = $m->{cgi}->param($name) =~ /^([A-Za-z0-9_]+)$/ }
	$str = "" if !defined($str);
	return $str;
}

#------------------------------------------------------------------------------
# Assemble script URL with query string

sub url
{
	my $m = shift();
	my $script = shift();
	my @params = @_;

	# Shortcuts
	my $env = $m->{env};
	my $utf8 = $m->{gcfg}{utf8};

	# Add session ID	
	push @params, sid => $m->{sessionId} if $m->{sessionId};
	
	# Fragment identifier
	my $target = "";

	# Start URL
	my $url = $script . $m->{ext};
	$url .= "?" if @params;

	# Add query parameters
	for (my $i = 0; $i < @params; $i += 2) {
		my $key = $params[$i];
		my $value = $params[$i+1];

		# Handle special keys
		if ($key eq 'tgt') { $target = $value; next }
		elsif ($key eq 'auth') { $value = $m->{user}{sourceAuth} }
		elsif ($key eq 'ori') { 
			$value = $env->{script} . $m->{ext};
			$value .= "?$env->{params}" if $env->{params};
			$value =~ s![?;]?sid=[0-9a-f]+!!;
			$value =~ s![?;]?msg=[A-Za-z]+!!;
		}

		# Escape value
		utf8::encode($value) if $utf8;
		$value =~ s/([^A-Za-z0-9\-\_.!~()])/'%'.unpack("H2",$1)/eg;

		$url .= "$key=$value;";
	}

	# Remove trailing semicolon	
	chop $url if @params && substr($url, -1, 1) eq ';';
	
	# Append fragment identifier
	$url .= "#$target" if $target;

	return $url;
}

#------------------------------------------------------------------------------
# Redirect via HTTP header

sub redirect
{
	my $m = shift();
	my $script = shift();
	my @params = @_;

	# Shortcuts
	my $ap = $m->{ap};
	my $cfg = $m->{cfg};
	my $env = $m->{env};
	
	# Determine status, host and protocol
	my $status = $env->{protocol} eq "HTTP/1.1" ? 303 : 302;
	my $proto = $env->{port} == 443 ? "https://" : "http://";
	my $host = $env->{host};
	($host) = $cfg->{baseUrl} =~ m!^https?://([^:]+)! if !$host;
	$host .= ":" . $env->{port} if $env->{port} != 80;
	my $scriptAndParam = $m->url($script, @params);

	# If there was an origin parameter, use that instead, but add sid and msg
	my $origin = $m->paramStr('ori');
	if ($origin) {
		my %params = @params;
		my $msg = $params{msg};
		$msg = $origin =~ /=/ ? ";msg=$msg" : "?msg=$msg" if $msg;
		my $sessionId = $m->{sessionId};
		$sessionId = ($origin . $msg) =~ /=/ ? ";sid=$sessionId" : "?sid=$sessionId" if $sessionId;
		$scriptAndParam = $origin . $msg . $sessionId;
	}
	
	# Location URL must be absolute according to HTTP
	my $location = $cfg->{relRedir} 
		? "$env->{scriptUrlPath}/$scriptAndParam" 
		: "$proto$host$env->{scriptUrlPath}/$scriptAndParam";  

	# Print HTTP redirection	
	if (MP) {
		$ap->status($status);
		$ap->headers_out->{'Location'} = $location;
		$ap->send_http_header() if MP1;
	}
	else {
		print "HTTP/1.1 302 Found\n" if $cfg->{nph};
		print "Status: $status\n" if !$cfg->{nph};
		print "Set-Cookie: $cfg->{cookiePrefix}$_\n" for @{$m->{cookies}};
		print "Location: $location\n\n";
	}

	# Exit		
	FCGI ? die : exit;
}


###############################################################################
# User Functions

#------------------------------------------------------------------------------
# Get default user hash ref

sub initDefaultUser
{
	my $m = shift();

	# Shortcuts
	my $cfg = $m->{cfg};

	$m->{user} = {
		default      => 1,
		id           => 0,
		admin        => 0,
		timezone     => $cfg->{userTimezone},
		fontFace     => $cfg->{fontFace},
		fontSize     => $cfg->{fontSize},
		boardDescs   => $cfg->{boardDescs},
		showDeco     => $cfg->{showDeco},
		showAvatars  => $cfg->{showAvatars},
		showImages   => $cfg->{showImages},
		showSigs     => $cfg->{showSigs},
		indent       => $cfg->{indent},
		topicsPP     => $cfg->{topicsPP},
		postsPP      => $cfg->{postsPP},
		prevOnTime   => 4294967296,
	};
}

#------------------------------------------------------------------------------
# Authenticate user

sub authenticateUser
{
	my $m = shift();
	
	# Shortcuts
	my $cfg = $m->{cfg};
	my $sessionId = $m->paramStrId('sid');

	if ($cfg->{authenPlg}{request}) {
		# Call request authentication plugin
		my $dbUser = $m->callPlugin($cfg->{authenPlg}{request});
		$m->{user} = $dbUser if $dbUser;
	}
	else {
		# Cookie authentication
		my $cookies = $m->getCookies();
		my ($id, $pwd) = $cookies->{"$cfg->{cookiePrefix}login"} =~ /(\d+)\-(.+)/;
		if ($id) {
			my $dbUser = $m->getUser($id);
			$m->{user} = $dbUser if $dbUser && $pwd eq $dbUser->{password};
		}
		elsif ($sessionId) {
			# URL session authentication
			$id = $m->fetchArray("
				SELECT userId 
				FROM $m->{cfg}{dbPrefix}sessions 
				WHERE id = '$sessionId' 
					AND ip = '$m->{env}{userIp}'
					AND lastOnTime > $m->{now} - $cfg->{sessionTimeout} * 60");
			my $dbUser = undef;
			$dbUser = $m->getUser($id) if $id;
			if ($id && $dbUser) {
				$m->{user} = $dbUser;
				$m->{sessionId} = $sessionId;
			}
			else {
				$m->printHeader();
				print
					"<div class='frm nte'>\n",
					"<div class='hcl'>\n",
					"<span class='htt'>$m->{lng}{errNote}</span>\n",
					"</div>\n",
					"<div class='ccl'>\n",
					"$m->{lng}{errSsnTmeout}\n",
					"</div>\n",
					"</div>\n\n";
			}
		}
	}

	# Set style and its path
	my $user = $m->{user};
	my $styleName = $cfg->{styles}{$user->{style}} ? $user->{style} : $cfg->{style};
	my $styleOpt = $m->{styleOptions};
	%$styleOpt = $cfg->{styleOptions}{$styleName} =~ /(\w+)="(.+?)"/g;
	if ($styleOpt->{excludeUA} && $m->{env}{userAgent} =~ /$styleOpt->{excludeUA}/
		|| $styleOpt->{requireUA} && $m->{env}{userAgent} !~ /$styleOpt->{requireUA}/) {
		# If style doesn't support browser
		$m->{style} = $cfg->{styles}{$cfg->{fallbackStyle}};
		$m->{stylePath} = "$cfg->{dataPath}/$m->{style}";
		$styleOpt = {};
	}
	else {
		$m->{style} = $cfg->{styles}{$styleName};
		$m->{stylePath} = "$cfg->{dataPath}/$m->{style}";
	}
	
	# Show buttons icons?
	$m->{buttonIcons} = $cfg->{buttonIcons} && $styleOpt->{buttonIcons} && $user->{showDeco};

	# Set language
	$m->setLanguage();
	
	# Deny access if forum is in lockdown
	!$cfg->{locked} || $user->{admin} or $m->printNote($m->{lng}{errForumLock});

	# Cache board admin/board member status
	$m->cacheUserStatus() if $user->{id};
}

#------------------------------------------------------------------------------
# Cache board admin/board member status

sub cacheUserStatus
{
	my $m = shift();
	
	# Shortcuts
	my $cfg = $m->{cfg};
	my $dbh = $m->{dbh};
	my $boardAdmin = $m->{boardAdmin};
	my $boardMember = $m->{boardMember};
	my $debug = $cfg->{debug} >= 2;
	my $userId = $m->{user}{id};
	my $boardId = undef;

	# Cache admin status for boards
	$m->{query} = "
		SELECT boardId FROM $cfg->{dbPrefix}boardAdmins WHERE userId = $userId";
	$m->{queryNum}++;
	push @{$m->{queries}}, $m->{query} if $debug;
	my $sth = $dbh->prepare($m->{query}) or $m->dbError();
	$sth->execute() or $m->dbError();
	$sth->bind_col(1, \$boardId);
	$boardAdmin->{$boardId} = 1 while $sth->fetch();

# TUSK we don't use the forum board members or group members, so the queries here have been deleted.

}

#------------------------------------------------------------------------------
# Get user hash ref from user id

sub getUser 
{
	my $m = shift();
	my $id = shift();

	return $m->fetchHash("
		SELECT * FROM $m->{cfg}{dbPrefix}users WHERE id = $id");
}

#------------------------------------------------------------------------------
# Create user account

sub createUser
{
	my $m = shift();
	my %params = @_;

	# Shortcuts
	my $cfg = $m->{cfg};

	# First user gets admin status with hardcoded password
#	my $userNum = $m->fetchArray("
#		SELECT COUNT(*) FROM $cfg->{dbPrefix}users");
#	my $admin = $userNum ? 0 : 1;
#	$params{password} = "admin" if $admin;
	
	my $admin = 0;

	# Get salted password hash
	my $salt = int(rand(2147483647));
	my $passwordMd5 = $m->md5($params{password} . $salt);

	# Quote strings
	my $userNameQ = $m->dbQuote($params{userName});
	my $emailQ = $m->dbQuote($params{email});
	my $timezoneQ = $m->dbQuote($m->firstDef($params{timezone}, $cfg->{userTimezone}));
	my $languageQ = $m->dbQuote($m->firstDef($params{language}, $cfg->{language}));
	my $styleQ = $m->dbQuote($m->firstDef($params{style}, $cfg->{style}));
	my $fontFaceQ = $m->dbQuote($m->firstDef($params{fontFace}, $cfg->{fontFace}));
	my $extra1Q = $m->dbQuote($params{extra1});
	my $extra2Q = $m->dbQuote($params{extra2});
	my $extra3Q = $m->dbQuote($params{extra3});

	# TUSK begin
	# adding realName (populated from TUSK DB)
	my $realNameQ = $m->dbQuote($params{realName});
	# adding possible admin status if forumAdmin was passed to MwfPlgAuthen.pm
	$admin = $admin ? 1:$params{admin};
	# TUSK end

	# Make sure values are not undefined
	my $hideEmail = $m->firstDef($params{hideEmail}, $cfg->{hideEmail});
	my $notify = $m->firstDef($params{notify}, $cfg->{notify}, 0);
	my $msgNotify = $m->firstDef($params{msgNotify}, $cfg->{msgNotify});
	my $tempLogin = $m->firstDef($params{tempLogin}, $cfg->{tempLogin});
	my $secureLogin = $m->firstDef($params{secureLogin}, $cfg->{secureLogin});
	my $privacy = $m->firstDef($params{privacy}, $cfg->{privacy});
	my $fontSize = $m->firstDef($params{fontSize}, $cfg->{fontSize});
	my $boardDescs = $m->firstDef($params{boardDescs}, $cfg->{boardDescs});
	my $showDeco = $m->firstDef($params{showDeco}, $cfg->{showDeco});
	my $showAvatars = $m->firstDef($params{showAvatars}, $cfg->{showAvatars});
	my $showImages = $m->firstDef($params{showImages}, $cfg->{showImages});
	my $showSigs = $m->firstDef($params{showSigs}, $cfg->{showSigs});
	my $collapse = $m->firstDef($params{collapse}, $cfg->{collapse});
	my $indent = $m->firstDef($params{indent}, $cfg->{indent});
	my $topicsPP = $m->firstDef($params{topicsPP}, $cfg->{topicsPP});
	my $postsPP = $m->firstDef($params{postsPP}, $cfg->{postsPP});
	
	# Get random values
	my $bounceAuth = int(rand(2147483647));
	my $sourceAuth = int(rand(2147483647));
	
	# Insert user	
	# TUSK begin modification, adding realName to the end of inserted values.
	$m->dbDo("
		INSERT INTO $cfg->{dbPrefix}users (
			userName, password, salt, email, admin, hideEmail, 
			notify, msgNotify, tempLogin, secureLogin, privacy,
			extra1, extra2, extra3, timezone, language,
			style, fontFace, fontSize, boardDescs,
			showDeco, showAvatars, showImages, showSigs,
			collapse, indent, topicsPP, postsPP, 
			regTime, lastOnTime, prevOnTime, 
			lastIp, bounceAuth, sourceAuth, realName
		) VALUES (
			$userNameQ, '$passwordMd5', $salt, $emailQ, $admin, $hideEmail,
			$notify, $msgNotify, $tempLogin, $secureLogin, $privacy,
			$extra1Q, $extra2Q, $extra3Q, $timezoneQ, $languageQ, 
			$styleQ, $fontFaceQ, $fontSize, $boardDescs, 
			$showDeco, $showAvatars, $showImages, $showSigs,
			$collapse, $indent, $topicsPP, $postsPP,
			$m->{now}, $m->{now}, $m->{now},
			'$m->{env}{userIp}', $bounceAuth, $sourceAuth, $realNameQ
		)");
	# TUSK end

	# Return id of created user	
	return $m->dbInsertId("$cfg->{dbPrefix}users");
}

#------------------------------------------------------------------------------
# Update user's timestamps and session

sub updateUser
{
	my $m = shift();

	# Shortcuts
	my $user = $m->{user};
	my $env = $m->{env};
	my $script = $env->{script};

	# Update lastOnTime?
	my $lastOnTimeStr = $script ne "user_login" ? ", lastOnTime = $m->{now}" : "";

	# Update lastTopicId?
	my $lastTopicIdStr = $script !~ /^topic_|^branch_|^post_|^poll_|^report_|^todo_/ 
		&& $user->{lastTopicId} ? ", lastTopicId = 0, lastTopicTime = 0" : "";
	
	# Update chatReadTime?
	my $chatReadTimeStr = $script eq 'chat_show' ? ", chatReadTime = $m->{now}" : "";

	# Update user	
	my $agentQ = $m->dbQuote($m->escHtml($env->{userAgent}));
	$m->dbDo("
		UPDATE $m->{cfg}{dbPrefix}users SET 
			lastIp = '$env->{userIp}',
			userAgent = $agentQ
			$lastOnTimeStr
			$lastTopicIdStr
			$chatReadTimeStr
		WHERE id = $user->{id}");
		
	# Touch user's session
	$m->dbDo("
		UPDATE $m->{cfg}{dbPrefix}sessions SET lastOnTime = $m->{now} WHERE id = '$m->{sessionId}'")
		if $m->{sessionId};
}

#------------------------------------------------------------------------------
# Delete user and dependent data

sub deleteUser
{
	my $m = shift();
	my $userId = shift();

	# Shortcuts
	my $cfg = $m->{cfg};
	my $lng = $m->{lng};

	# Get user
	my $delUser = $m->getUser($userId);
	$delUser or $m->entryError($lng->{errUsrNotFnd});

	# Delete avatar
	unlink "$cfg->{attachFsPath}/avatars/$delUser->{avatar}" if $delUser->{avatar};
	
	# Delete keyring
	unlink "$cfg->{attachFsPath}/keys/$userId.gpg";
	unlink "$cfg->{attachFsPath}/keys/$userId.gpg~";
	
	$m->dbBegin();
	eval {
		# Delete user options in the variables table
		$m->dbDo("
			DELETE FROM $cfg->{dbPrefix}variables WHERE userId = $userId");

		# Delete blog topics
		my $topics = $m->fetchAllArray("
			SELECT id FROM $cfg->{dbPrefix}topics WHERE boardId = -$userId");
		$m->deleteTopic($_->[0]) for @$topics;

		# Delete ban entries
		$m->dbDo("
			DELETE FROM $cfg->{dbPrefix}userBans WHERE userId = $userId");
	
		# Delete member entries
		$m->dbDo("
			DELETE FROM $cfg->{dbPrefix}boardMembers WHERE userId = $userId");
	
		# Delete moderator entries
		$m->dbDo("
			DELETE FROM $cfg->{dbPrefix}boardAdmins WHERE userId = $userId");
	
		# Delete hidden board entries
		$m->dbDo("
			DELETE FROM $cfg->{dbPrefix}boardHiddenFlags WHERE userId = $userId");
		
		# Delete board subscriptions
		$m->dbDo("
			DELETE FROM $cfg->{dbPrefix}boardSubscriptions WHERE userId = $userId");

		# Delete topic subscriptions
		$m->dbDo("
			DELETE FROM $cfg->{dbPrefix}topicSubscriptions WHERE userId = $userId");
		
		# Delete todo list entries
		$m->dbDo("
			DELETE FROM $cfg->{dbPrefix}postTodos WHERE userId = $userId");
		
		# Delete ignore entries
		$m->dbDo("
			DELETE FROM $cfg->{dbPrefix}userIgnores WHERE userId = $userId");
		$m->dbDo("
			DELETE FROM $cfg->{dbPrefix}userIgnores WHERE ignoredId = $userId");
	
		# Delete topicReadTimes entries
		$m->dbDo("
			DELETE FROM $cfg->{dbPrefix}topicReadTimes WHERE userId = $userId");

		# Delete messages from and to user
		$m->dbDo("
			DELETE FROM $cfg->{dbPrefix}messages WHERE receiverId = $userId");
		$m->dbDo("
			DELETE FROM $cfg->{dbPrefix}messages WHERE senderId = $userId");

		# Delete notifications for user
		$m->dbDo("
			DELETE FROM $cfg->{dbPrefix}notes WHERE userId = $userId");

		# Set post user ids and notifications to 0
		$m->dbDo("
			UPDATE $cfg->{dbPrefix}posts SET userId = 0 WHERE userId = $userId");
		
		# Delete user
		$m->dbDo("
			DELETE FROM $cfg->{dbPrefix}users WHERE id = $userId");
	};
	$@ ? $m->dbRollback() : $m->dbCommit();
}

#------------------------------------------------------------------------------
# Check if user is banned

sub checkBan
{
	my $m = shift();
	my $userId = shift();

	# Don't check for admins	
	return if $m->{user}{admin};

	# Check for ban 
	my ($banTime, $reason, $duration) = $m->fetchArray("
		SELECT banTime, reason, duration 
		FROM $m->{cfg}{dbPrefix}userBans 
		WHERE userId = $userId");

	if ($banTime) {
		# Log event
		$m->logAction(1, 'user', 'banned', $userId);
	
		# Print error
		my $durationStr = $duration ? "$m->{lng}{errBannedT2} $duration $m->{lng}{errBannedT3}" : "";
		$m->printError($m->{lng}{errBlocked}, "$m->{lng}{errBannedT} $reason. $durationStr");
	}
}

#------------------------------------------------------------------------------
# Check if read access/registration should be denied

sub checkBlock
{
	my $m = shift();

	# Shortcuts
	my $cfg = $m->{cfg};
	my $ip = $m->{env}{userIp};

	# Check for IP block
	for my $block (@{$cfg->{ipBlocks}}) {
		if (index($ip, $block) == 0) {
			# Log event
			$m->logAction(1, 'ip', 'blocked');
			
			# Print error
			$m->printError($m->{lng}{errBlocked}, $m->{lng}{errBlockedT});
		}
	}
}

#------------------------------------------------------------------------------
# Check authorization with plugin

sub checkAuthz
{
	my $m = shift();
	my $authzUser = shift();
	my $action = shift();

	# No check for admins
	return if $m->{user}{admin};

	# Call authz plugin
	my $reason = $m->callPlugin($m->{cfg}{authzPlg}{$action}, user => $authzUser, @_);
	!$reason or $m->printError($m->{lng}{errAuthz}, $reason);
}

#------------------------------------------------------------------------------
# Get cookie hash ref

sub getCookies
{
	my $m = shift();

	my $cookies = {};
	my ($key, $value);
	my @pairs = split("; ?", $m->{env}{cookie});

	for (@pairs) {
		s!\s*(.*?)\s*!$1!;
		if (/^([^=]+)=(.*)/) {
			$key = $1;
			$value = $2;
		}
		else {
			$key = $_;
			$value = '';
		}
		$value =~ s!%([0-9a-fA-F]{2})!chr hex($1)!ge;
		$cookies->{$key} = $value;
	}

	return $cookies;
}

#------------------------------------------------------------------------------
# Set user/pwd cookies

sub setCookies
{
	my $m = shift();
	my $id = shift();
	my $pwd = shift();
	my $temp = shift() || 0;
	my $secure = shift() || 0;
	
	# Shortcuts
	my $cfg = $m->{cfg};

	my $path = $cfg->{cookiePath} ? "; path=$cfg->{'cookiePath'}" : "; path=$m->{env}{scriptUrlPath}";
	my $domain = $cfg->{cookieDomain} ? "; domain=$cfg->{'cookieDomain'}" : "";
	my $expires = !$temp ? "; expires=Mon, 16-Mar-2020 00:00:00 GMT" : "";
	$secure = $secure ? "; secure" : "";

	if (MP) {
		$m->{ap}->err_headers_out->{'Set-Cookie'} 
			= "$cfg->{cookiePrefix}login=$id-$pwd$path$domain$expires$secure";
	}
	else {
		push @{$m->{cookies}}, "login=$id-$pwd$path$domain$expires$secure";
	}
}

#------------------------------------------------------------------------------
# Remove login cookie

sub deleteCookies
{
	my $m = shift();

	# Shortcuts
	my $cfg = $m->{cfg};

	my $path = $cfg->{cookiePath} ? "; path=$cfg->{'cookiePath'}" : "; path=$m->{env}{scriptUrlPath}";
	my $domain = $cfg->{cookieDomain} ? "; domain=$cfg->{'cookieDomain'}" : "";
	my $expires = "; expires=Thu, 01-Jan-1970 00:00:00 GMT";

	if (MP) {
		$m->{ap}->err_headers_out->{'Set-Cookie'} = "$cfg->{cookiePrefix}login=$path$domain$expires";
	}
	else {
		push @{$m->{cookies}}, "login=$path$domain$expires";
	}
}

#------------------------------------------------------------------------------
# Check username for validity (but not reservations or vacancy)

sub checkUsername
{
	my $m = shift();
	my $name = shift();

	# Shortcuts
	my $cfg = $m->{cfg};
	my $lng = $m->{lng};
	
	length($name) or $m->formError($lng->{errNamEmpty});
	if ($name) {
		length($name) >= 2 && length($name) <= $cfg->{maxUserNameLen} 
			or $m->formError($lng->{errNamSize});
		$name =~ /$cfg->{userNameRegExp}/ or $m->formError($lng->{errNamChar});
		$name !~ /^ / or $m->formError($lng->{errNamChar});
		$name !~ / $/ or $m->formError($lng->{errNamChar});
		$name !~ /  / or $m->formError($lng->{errNamChar});
	}
}


###############################################################################
# Board Functions

#------------------------------------------------------------------------------
# Check if user is moderator

sub boardAdmin
{
	my $m = shift();
	my $userId = shift();
	my $boardId = shift();

	# Shortcuts
	my $cfg = $m->{cfg};

	# Return true if user is blog owner	
	return 1 if $boardId < 0 && abs($boardId) == $m->{user}{id};

	# Return cached status if query is for current user
	if ($userId == $m->{user}{id}) {
		return 1 if exists($m->{boardAdmin}{$boardId});
		return 0;
	}

	# Otherwise fetch status from database
	return 1 if $m->fetchArray("
		SELECT 1 
		FROM $cfg->{dbPrefix}boardAdmins 
		WHERE userId = $userId 
			AND boardId = $boardId");

	return 1 if $m->fetchArray("
		SELECT 1
		FROM $cfg->{dbPrefix}groupMembers AS groupMembers
		INNER JOIN $cfg->{dbPrefix}boardAdminGroups AS boardAdminGroups
			ON boardAdminGroups.groupId = groupMembers.groupId
			AND boardAdminGroups.boardId = $boardId
		WHERE groupMembers.userId = $userId");
	
	return 0;
}

#------------------------------------------------------------------------------
# Check if user is board member

sub boardMember
{
	my $m = shift();
	my $userId = shift();
	my $boardId = shift();

	# Shortcuts
	my $cfg = $m->{cfg};

	# Return cached status if query is for current user
	if ($userId == $m->{user}{id}) {
		return 1 if exists($m->{boardMember}{$boardId});
		return 0;
	}

	# Otherwise fetch status from database
	return 1 if $m->fetchArray("
		SELECT 1 
		FROM $cfg->{dbPrefix}boardMembers
		WHERE userId = $userId 
			AND boardId = $boardId");

	return 1 if $m->fetchArray("
		SELECT 1
		FROM $cfg->{dbPrefix}groupMembers AS groupMembers
		INNER JOIN $cfg->{dbPrefix}boardMemberGroups AS boardMemberGroups
			ON boardMemberGroups.groupId = groupMembers.groupId
			AND boardMemberGroups.boardId = $boardId
		WHERE groupMembers.userId = $userId");
	
	return 0;
}

#------------------------------------------------------------------------------
# Check if user has write access to board

sub boardWritable
{
	my $m = shift();
	my $board = shift();
	my $reply = shift() || 0;

	# Shortcuts
	my $user = $m->{user};
	
	return 0 if !$user->{id} && !$board->{unregistered};
	return 1 if $board->{announce} == 0;
	return 1 if $board->{announce} == 2 && $reply;
	return 1 if $user->{admin};
	return 1 if $m->boardMember($user->{id}, $board->{id});
	return 1 if $m->boardAdmin($user->{id}, $board->{id});
	return 0;
}

#------------------------------------------------------------------------------
# Check if user has read access to board

sub boardVisible
{
	my $m = shift();
	my $board = shift();
	my $user = shift() || $m->{user};

	# Shortcuts
	my $cfg = $m->{cfg};

	# Call authz plugin
	if ($cfg->{authzPlg}{viewBoard}) { 
		my $result = $m->callPlugin($cfg->{authzPlg}{viewBoard}, user => $user, board => $board);
		return 1 if $result == 2;  # unconditional access
		return 0 if $result == 1;  # access denied
	}

	# Normal access checking
	return 1 if $board->{private} == 0;
	return 0 if !$user->{id};
	return 1 if $board->{private} == 2;
	return 1 if $user->{admin};
	return 1 if $m->boardMember($user->{id}, $board->{id});
	return 1 if $m->boardAdmin($user->{id}, $board->{id});
	return 0;
}

#------------------------------------------------------------------------------
# Get virtual blog board for blogger

sub getBlogBoard
{
	my $m = shift();
	my $blogger = shift() || {};
	
	return { 
		isBlog => 1, 
		id => -$blogger->{id} || 0, 
		title => $blogger->{userName} || "?", 
		private => $m->{cfg}{blogs} == 2 ? 2 : 0,
		flat => $m->{cfg}{blogsFlat},
		announce => 2, 
	};
}


###############################################################################
# Output Functions

#------------------------------------------------------------------------------
# Print HTTP header

sub printHttpHeader
{
	my $m = shift();

	# Shortcuts
	my $ap = $m->{ap};
	my $cfg = $m->{cfg};

	# Return if header was already printed
	return if $m->{printPhase} >= 1;

	if (MP) {
		$ap->status(200);
		$ap->content_type("$m->{contentType}; charset=$cfg->{charset}");
		
		if ($cfg->{noCacheHeaders}) {
			$ap->no_cache(1);
		}
		else {
			$ap->headers_out->{'Expires'} =  "Thu, 01 Jan 1970 00:00:00 GMT";
			$ap->headers_out->{'Cache-Control'} = "private";
		}
	}
	else {
		print "HTTP/1.1 200 OK\n" if $cfg->{nph};

		print 
			"Content-Type: $m->{contentType}; charset=$cfg->{charset}\n",
			"Expires: Thu, 01 Jan 1970 00:00:00 GMT\n";

		if ($cfg->{noCacheHeaders}) {
			print
				"Pragma: no-cache\n",
				"Cache-Control: no-cache\n";
		}
		else {
			print "Cache-Control: private\n";
		}
		
		print "Set-Cookie: $cfg->{cookiePrefix}$_\n" for @{$m->{cookies}};
	}

	# Call include plugin
	$m->callPlugin($cfg->{includePlg}{httpHeader});
		
	$m->{printPhase} = 1;
}

#------------------------------------------------------------------------------
# Print page header

sub printHeader 
{
	my $m = shift();
	my $title = shift() || undef;
	my $board = shift() || undef;

	# Return if header was already printed
	return if $m->{printPhase} >= 2;

	# Shortcuts
	my $ap = $m->{ap};
	my $env = $m->{env};
	my $cfg = $m->{cfg};
	my $lng = $m->{lng};
	my $user = $m->{user};
	my $userId = $user->{id};
	my $ctype = $m->{contentType};

	# Print HTTP header if not already done
	$m->printHttpHeader() if $m->{printPhase} < 1;

	# Determine execution message or greeting string
	my $msg = $m->paramStrId('msg');
	if ($msg) {
		my $msgId = "msg$msg"; 
		$msg = "<span class='tbm'>$lng->{$msgId}</span>" 
	}
	else { 
	# TUSK begin
        # changed title to display realName rather than userName
		$msg = !$userId ? $lng->{hdrNoLogin} : "$lng->{hdrWelcome} $user->{realName}" 
		#$msg = !$userId ? $lng->{hdrNoLogin} : "$lng->{hdrWelcome} $user->{userName}" 
	# TUSK end
	}
	
	# Print warning for locked forums for admin
	$msg .= " - <em>FORUM IS LOCKED</em>" if $cfg->{locked} && $user->{admin};
	
	# End HTTP header
	if (MP1) { $ap->send_http_header() }
	elsif (CGI) { print "\n" }

	# Format output
	$title ||= $cfg->{forumName};
	my $fontFaceStr = $user->{fontFace} ? "font-family: '$user->{fontFace}', sans-serif;" : "";
	my $fontSizeStr = $user->{fontSize} ? "font-size: $user->{fontSize}px;" : "";
	
	# Print HTML header
	my $et = "/";
	if ($ctype eq "application/xhtml+xml") {
		print
			"<?xml version='1.0' encoding='$cfg->{charset}'?>\n",
			"<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.1//EN'",
			" 'http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd'>\n",
			"<html xmlns='http://www.w3.org/1999/xhtml'>\n";
	}
	else {
		# W3C validator doesn't like empty tag syntax on header elements in HTML4
		$et = "";
		print 
			'<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">',
			"\n<html>\n";
	}

	print		
		"<head>\n",
		"<title>$title</title>\n",
		"<meta http-equiv='content-type' content='$ctype; charset=$cfg->{charset}'$et>\n",
		"<meta http-equiv='content-style-type' content='text/css'$et>\n",
		"<meta http-equiv='content-script-type' content='text/javascript'$et>\n";

	if ($board){
	    srand($board->{id});
	    my $randBid = rand();
	    my $path = "$cfg->{attachUrlPath}/xml";
	    my $title = $board->{title};
	    $title =~ s/"/&quot;/g;
	    print '<link rel="alternate"  type="application/rss+xml" title="' . $title . ' RSS feed" href="' . $path . '/board' . $randBid . '.rss200.xml" />' . "\n";
	    print '<link rel="alternate"  type="application/rss+xml" title="' . $title . ' ATOM feed" href="' . $path . '/board' . $randBid . '.atom10.xml" />' . "\n";

	}
	
	# Search engines should only index pages where it makes sense
	if (!$cfg->{noIndex} && $env->{script} =~ /^(?:forum|board|blog|topic)_show$/) {
		 print "<meta name='robots' content='noindex,nofollow'$et>\n";
	}
		
	# Microsummary link
	print 
		"<link rel='microsummary' href='$cfg->{attachUrlPath}/xml/microsummary.txt'",
		" type='text/plain'$et>\n"
		if $cfg->{microsummary} && $env->{script} eq 'forum_show';

	# Site navigation links
	my $topUrl = $m->url('forum_show');
	my $helpUrl = $m->url('forum_help');
	my $searchUrl = $m->url('forum_search');
	if ($cfg->{navLinkTags}) {
		my $copyUrl = $m->url('forum_info');
		print
			"<link rel='top' href='$topUrl' type='$ctype'$et>\n",
			"<link rel='contents' href='$topUrl' type='$ctype'$et>\n",
			"<link rel='help' href='$helpUrl' type='$ctype'$et>\n",
			$cfg->{forumSearch} ? "<link rel='search' href='$searchUrl' type='$ctype'$et>\n" : "",
			"<link rel='copyright' href='$copyUrl' type='$ctype'$et>\n";
	
		# Home link
		print	"<link rel='home' href='$cfg->{homeUrl}' type='$ctype' title='$cfg->{homeTitle}'$et>\n"
			if $cfg->{homeUrl};
	
		# Prev/next links
		if ($env->{script} eq 'board_show') {
			my $boardId = $m->paramInt('bid');
			my $upUrl = $m->url('forum_show', tgt => "bid$boardId");
			my $prevUrl = $m->url('prevnext', bid => $boardId, dir => 'prev');
			my $nextUrl = $m->url('prevnext', bid => $boardId, dir => 'next');
			print
				"<link rel='up' href='$upUrl' type='$ctype'$et>\n",
				"<link rel='prev' href='$prevUrl' type='$ctype'$et>\n",
				"<link rel='next' href='$nextUrl' type='$ctype'$et>\n";
		}
		if ($env->{script} eq 'topic_show') {
			my $topicId = $m->paramInt('tid');
			my $upUrl = $m->url('board_show', tid => $topicId, tgt => "tid$topicId");
			my $prevUrl = $m->url('prevnext', tid => $topicId, dir => 'prev');
			my $nextUrl = $m->url('prevnext', tid => $topicId, dir => 'next');
			print
				"<link rel='up' href='$upUrl' type='$ctype'$et>\n",
				"<link rel='prev' href='$prevUrl' type='$ctype'$et>\n",
				"<link rel='next' href='$nextUrl' type='$ctype'$et>\n";
		}
	}

	# Main stylesheet
	print "<link rel='stylesheet' href='$m->{stylePath}/$m->{style}.css' type='text/css'$et>\n";

	# Forum stylesheet
	print "<link rel='stylesheet' href='$cfg->{dataPath}/$cfg->{forumStyle}' type='text/css'$et>\n"
		if $cfg->{forumStyle};

	# Inline style for user options
	print
		"<style type='text/css'>\n",
		"  table#fullContentTable, table#fullContentTable input, table#fullContentTable textarea, table#fullContentTable select, table#fullContentTable table { $fontFaceStr $fontSizeStr }\n";

	# Inline style snippets
	if (%{$cfg->{styleSnippets}} && $m->{dbh}) {
		my $snippets = $m->fetchAllArray("
			SELECT name 
			FROM $cfg->{dbPrefix}variables 
			WHERE name LIKE 'sty%' 
				AND userId = $userId");
		for my $snippet (@$snippets) { 
			my $css = $cfg->{styleSnippets}{$snippet->[0]};
			print "  $css\n" if $css;
		}
	}
	print "</style>\n";
	
	# Call include plugin
	$m->callPlugin($cfg->{includePlg}{htmlHeader});

	# Print focus script	
	print <<"EOSCRIPT"
<script type='text/javascript'>$m->{cdataStart}
	function mwfSetFocus() {
		var texta = document.getElementsByTagName('textarea')[0];
		var inputs = document.getElementsByTagName('input');
		for (var i = 0; i < inputs.length; i++) {
			var inp = inputs[i];
			if (inp.type != 'hidden' && inp.type != 'submit' && inp.type != 'checkbox') {
				var input = inp;
				break;
			}
		}
		if (input) input.focus();
		else if (texta) texta.focus();
	}
	
	function mwfSetFocusOnload() {
		var mwfOldOnload = window.onload;
		if (typeof(window.onload) != 'function') window.onload = mwfSetFocus;
		else {
			window.onload = function() {
				if (mwfOldOnload) mwfOldOnload();
				mwfSetFocus();
			}
		}
	}
	mwfSetFocusOnload();
$m->{cdataEnd}</script>
EOSCRIPT
;

	print
		"</head>\n",
		"<body class='forum $env->{script}'>\n\n";

	# Call include plugin
	$m->callPlugin($cfg->{includePlg}{top});

	# Print title image
	if ($cfg->{titleImage}) {
		print
			"<div class='tim'><a href='$topUrl'>",
			"<img src='$cfg->{dataPath}/$cfg->{titleImage}' alt=''/>",
			"</a></div>\n\n";
	}

	# Print top bar
	print
		"<div class='frm tpb' style='border-top: none'>\n",
		$cfg->{pageIcons} && $user->{showDeco} && $env->{userAgent} !~ /MSIE (?:5|6)/
			? "<img class='pic' src='$cfg->{dataPath}/pageicons/$env->{script}.png' alt=''/>\n" : "",
#		"<div class='hcl'>\n",
#		"<span class='htt'>$cfg->{forumName}</span> - $msg\n",
#		"</div>\n",
# TUSK removed the above div because it was a redundant Tusk title.  added the style border-top:none
# to the previous div because there was a 2px top border.
		"<div class='bcl'>\n",
		$m->buttonLink($topUrl, $lng->{comBoardList}, 'forum');

	# Print home link
	print $m->buttonLink($cfg->{homeUrl}, $cfg->{homeTitle}, 'home') if $cfg->{homeUrl};

	# Print help link
	print $m->buttonLink($helpUrl, 'hdrHelp', 'help');
		
	# Print search link
	print $m->buttonLink($searchUrl, 'hdrSearch', 'search') if $cfg->{forumSearch}; 

	# Print chat link
	print $m->buttonLink($m->url('chat_show'), 'hdrChat', 'chat')
		if $cfg->{chat} && ($cfg->{chat} < 2 || $userId);

	# Print blog link
	print $m->buttonLink($m->url('blog_show'), 'hdrBlog', 'blog') if $cfg->{blogs} && $userId;

	# Print private messages link
	print $m->buttonLink($m->url('message_list'), 'hdrMsgs', 'message') 
		if $cfg->{messages} && $userId;

	# Print user options link
	print $m->buttonLink($m->url('user_options'), 'hdrOptions', 'option') if $userId;

	# Print user registration link
	print $m->buttonLink("user_register$m->{ext}", 'hdrReg', 'user')
		if (!$userId && !$cfg->{adminUserReg} && !$cfg->{authenPlg}{login} 
			&& !$cfg->{authenPlg}{request})
		|| ($cfg->{adminUserReg} && $user->{admin});

	# Print user login link
	if (!$userId && (!$cfg->{authenPlg}{request} || $cfg->{noHideLogBtn})) {
		my $url = $m->url('user_login', $m->{env}{script} !~ /^user_/ ? (ori => 1) : ());
		print $m->buttonLink($url, 'hdrLogin', 'login');
	}

	# Print logout link
	if ($userId && (!$cfg->{authenPlg}{request} || $cfg->{noHideLogBtn})) {
		my $url = $m->url('user_logout', auth => 1);
		print	$m->buttonLink($url, 'hdrLogout', 'logout');
	}

	print	"</div>\n</div>\n\n";

	# Call include plugin
	$m->callPlugin($cfg->{includePlg}{middle});

	$m->{printPhase} = 2;
}

#------------------------------------------------------------------------------
# Print page footer

sub printFooter 
{
	my $m = shift();
	shift();
	my $hideBoardList = shift() || 0;
	my $boardId = shift() || undef;

	# Return if footer was already printed
	return if $m->{printPhase} >= 4;

	# Shortcuts
	my $ap = $m->{ap};
	my $cfg = $m->{cfg};
	my $lng = $m->{lng};
	my $user = $m->{user};

	# TUSK begin moved the includePlg{bottom} to be above the jump-to-board list and above the copyright notice.
	$m->callPlugin($cfg->{includePlg}{bottom});
	# TUSK end

	# Print jump-to-board list	
	if ($cfg->{boardJumpList} && !$hideBoardList && $m->{dbh}) {
		# Get boards

	    # TUSK begin 
	    # We have already compiled a list of viewable boards on login.
	    # Call the appropriate function from the ForumKey pkg to retrieve
	    # the hash, and remove the boardVisible check because it isn't necessary.

	    my $boards = Forum::ForumKey::getBoardsHashnoHidden($m, $user);
	    # TUSK end


		# Print list
		my $sid = $m->{sessionId} ? "sid=$m->{sessionId}" : "";
		my $script = 
			"var id = this.options[this.selectedIndex].value; "
			. "if (id.indexOf('cid') == 0) { window.location = 'forum_show$m->{ext}?$sid#' + id } "
			. "else if (id == 0) { window.location = 'forum_show$m->{ext}?$sid' } "
			. "else { window.location = 'board_show$m->{ext}?bid=' + id + ';$sid' }";

		print
			"<form class='bjp' action='board_show$m->{ext}' method='get'>\n",
			"<div>\n",
			"<select name='bid' size='1' onchange=\"$script\">\n",
			"<option value='0'>$lng->{comBoardList}</option>\n";
			
		my $lastCategId = 0;
		for my $board (@$boards) {
			if ($board->{categoryId} != $lastCategId) {
				$lastCategId = $board->{categoryId};
				print "<option value='cid$board->{categoryId}'>$board->{categTitle}</option>\n";
			}
			my $sel = $boardId && $board->{id} == $boardId ? "selected='selected'" : '';
			print "<option value='$board->{id}' $sel>- $board->{title}</option>\n";
		}

		print
			"</select>\n",
			$m->{sessionId} ? "<input type='hidden' name='sid' value='$m->{sessionId}'/>\n" : "",
			"<input type='submit' value='$lng->{comBoardGo}'/>\n",
			"</div>\n",
			"</form>\n";

		my $years_script = 
			"var id = this.options[this.selectedIndex].value; "
			. "window.location = 'forum_show$m->{ext}?$sid\&' + id";

		print
			"<form class='bjp' action='forum_show$m->{ext}' method='get'>\n",
			"<div>\n",
			"<select name='dates' size='1' onchange=\"$years_script\">\n",
			"<option value=''>Previous Years</option>\n";
		    my (undef,undef,undef, $mday,$mon,$year) = localtime(time);
	    if ($mon < 7){
		$year += 1900
	    }
	    else{
		$year += 1900 + 1;
	    }
	    foreach my $i (0..3){
		print "<option value='start_date=" . ($year-$i) . "-06-30&end_date=" . ($year - $i - 1) . "-07-01'>Academic Year: " . ($year - $i - 1 ) . "-" . ($year - $i) . "</option>\n";
	    }
		print
			"</select>\n",
			$m->{sessionId} ? "<input type='hidden' name='sid' value='$m->{sessionId}'/>\n" : "",
			"<input type='submit' value='$lng->{comBoardGo}'/>\n",
			"</div>\n",
			"</form>\n";
	}

	# Print non-fatal warnings, since many admins never check webserver log
	if (@{$m->{warnings}}) {
		print
			"<div class='frm err'>\n",
			"<div class='hcl'>\n",
			"<span class='htt'>Warning</span>\n",
			"</div>\n",
			"<div class='ccl'>\n";
	
		for my $msg (@{$m->{warnings}}) {
			$msg = $m->escHtml($msg);
			print "<p>$msg</p>\n";
		}
		
		print
			"</div>\n",
			"</div>\n\n";
	}

	# Print all SQL queries in debug mode
	if (@{$m->{queries}}) {
		print
			"<div class='frm err'>\n",
			"<div class='hcl'>\n",
			"<span class='htt'>SQL Queries ($m->{queryNum})</span>\n",
			"</div>\n",
			"<div class='ccl'>\n";
	
		for my $query (@{$m->{queries}}) {
			$query =~ s!\n!!g;
			$query =~ s!\t! !g;
			$query =~ s!\s{2,}! !g;
			$query =~ s!FROM!\nFROM!;
			$query =~ s!INNER!\nINNER!g;
			$query =~ s!LEFT!\nLEFT!g;
			$query =~ s!WHERE!\nWHERE!;
			$query =~ s!GROUP!\nGROUP!;
			$query =~ s!ORDER!\nORDER!;
			$query =~ s!LIMIT!\nLIMIT!;
			$query = $m->escHtml($query, 2);
			print "<p>$query</p>\n";
		}
		
		print
			"</div>\n",
			"</div>\n\n";
	}

	# Print copyright message
	print
		"<p class='cpr'>Powered by mwForum $MwfMain::VERSION",
		" &#169; 1999-2007 Markus Wichitill</p>\n\n"
		if $m->{env}{script} ne 'forum_info';
		
	# Call include plugin
	# TUSK begin moved this plug-in call to the beginning of this fn
	#$m->callPlugin($cfg->{includePlg}{bottom});
	# TUSK end

	# Print page creation time
	if ($m->{gcfg}{pageTime}) {
		my $time = Time::HiRes::tv_interval($m->{startTime});
		$time = sprintf("%.3f", $time);
		print "<p class='pct'>Page created in ${time}s with $m->{queryNum} database queries.</p>\n\n";
	}
	
	print	
		"</body>\n",
		"</html>\n\n";

	$m->{printPhase} = 4;
}

#------------------------------------------------------------------------------
# Print page bar

sub printPageBar
{
	my $m = shift();
	my %params = @_;
	my $mainTitle = $params{mainTitle};
	my $subTitle = $params{subTitle};
	my $navLinks = $params{navLinks};
	my $pageLinks = $params{pageLinks};
	my $userLinks = $params{userLinks};
	my $adminLinks = $params{adminLinks};

	# Use cached version for repeated page bar (topic page)
	my @lines = $params{repeat} ? @{$m->{pageBar}} : ();
	if (@lines) {
		print @lines;
		return;
	}

	# Shortcuts
	my $cfg = $m->{cfg};
	my $lng = $m->{lng};
	my $imgPath = $m->{stylePath};

	if ($mainTitle){
	    # Start
	    push @lines,
	    "<div class='frm' style='border-top: none; border-bottom: none'>\n",
	    "<div class='hcl'>\n",
	    "<span class='nav'>\n";
	    
	    # Navigation button links
	    for my $link (@$navLinks) {
		my $textId = $link->{txt};
		my $text = $lng->{$textId} || $textId;
		my $textTT = $lng->{$textId . 'TT'};
		$link->{dsb}
		? push @lines, 
		"<img class='ico' src='$imgPath/nav_$link->{ico}_d.png' title='$textTT' alt='$text'/>\n"
		    : push @lines, "<a href='$link->{url}'>",
		    "<img class='ico' src='$imgPath/nav_$link->{ico}.png' title='$textTT' alt='$text'/></a>\n";
	    }
	    
	    # Title
	    push @lines, 
	    "</span>\n",
	    "<span class='htt'>$mainTitle</span> $subTitle\n",
	    "</div>\n";
	}
	# Page links
	my @bclLines = ();

	if ($pageLinks && @$pageLinks) {
		push @bclLines, "<span class='pln'>\n";
		for my $link (@$pageLinks) {
			my $textId = $link->{txt};
			my $text = $lng->{$textId} || $textId;
			my $textTT = $lng->{$textId . 'TT'};
			if ($textId =~ /Up|Prev|Next/) {
				# Prev/next page icons
				my $img = "";
				if    ($textId =~ /Up/)   { $img = "nav_up" }
				elsif ($textId =~ /Next/) { $img = "nav_next" }
				elsif ($textId =~ /Prev/) { $img = "nav_prev" }
				$link->{dsb} 
					? push @bclLines, 
						"<img class='ico dsb' src='$imgPath/${img}_d.png' title='$textTT' alt='$text'/>\n"
					: push @bclLines, "<a href='$link->{url}'>",
						"<img class='ico' src='$imgPath/$img.png' title='$textTT' alt='$text'/></a>\n";
			}
			elsif ($textId eq "...") {
				push @bclLines, "...\n";
			}
			else {
				# Page number links
				$link->{dsb}
					? push @bclLines, "<span>$text</span>\n"
					: push @bclLines, "<a href='$link->{url}'>$text</a>\n";
			}
		}
		push @bclLines, "</span>\n";
	}

	# Normal button links
	if ($userLinks && @$userLinks) {
		push @bclLines, "<div class='nbl'>\n" if @$userLinks;
		for my $link (@$userLinks) {
			my $textId = $link->{txt};
			my $text = $lng->{$textId} || $textId;
			my $textTT = $lng->{$textId . 'TT'};
			$link->{ico} && $m->{buttonIcons}
				? push @bclLines, "<a href='$link->{url}' title='$textTT'>",
					"<img class='bic' src='$cfg->{dataPath}/buttonicons/bic_$link->{ico}.png' alt=''/> "
					. "$text</a>\n"
				: push @bclLines, "<a href='$link->{url}' title='$textTT'>$text</a>\n";
		}
		push @bclLines, "</div>\n" if @$userLinks;
	}

	# Admin button links
	if ($adminLinks && @$adminLinks) {
		push @bclLines, "<div class='abl'>\n" if @$adminLinks;
		for my $link (@$adminLinks) {
			my $textId = $link->{txt};
			my $text = $lng->{$textId} || $textId;
			my $textTT = $lng->{$textId . 'TT'};
			$link->{ico} && $m->{buttonIcons}
				? push @bclLines, "<a href='$link->{url}' title='$textTT'>",
					"<img class='bic' src='$cfg->{dataPath}/buttonicons/bic_$link->{ico}.png' alt=''/> "
					. "$text</a>\n"
				: push @bclLines, "<a href='$link->{url}' title='$textTT'>$text</a>\n";
		}
		push @bclLines, "</div>\n" if @$adminLinks;
	}

	# If there's only page links, we need a filler space or float breaks
	push @bclLines, "&#160;\n" 
		if $pageLinks && @$pageLinks && !($userLinks && @$userLinks || $adminLinks && @$adminLinks);
	my $special_case_border = (! $mainTitle) ? 'border-top:10px solid white;' : '';
	push @lines, "<div class='bcl' style='" . $special_case_border . " border-bottom: 1px solid silver'>\n",	@bclLines, "</div>\n" if @bclLines;
	push @lines, "</div>\n\n";

	# Print and cache bar
	print @lines;
	$m->{pageBar} = \@lines;
}

#------------------------------------------------------------------------------
# Get button link markup

sub buttonLink
{
	my $m = shift();
	my $url = shift();
	my $textId = shift();
	my $icon = shift();

	# Shortcuts
	my $lng = $m->{lng};

	my $text = $lng->{$textId} || $textId;
	my $title = $lng->{$textId . 'TT'};
	my $str = "<a class='btl' href='$url' title='$title'>";
	$str .= "<img class='bic' src='$m->{cfg}{dataPath}/buttonicons/bic_$icon.png' alt=''/> " 
		if $m->{buttonIcons};
  $str .= $text . "</a>\n";
  return $str;
}

#------------------------------------------------------------------------------
# Get submit button markup

sub submitButton
{
	my $m = shift();
	my $textId = shift();
	my $icon = shift();
	my $name = shift();

	my $text = $m->{lng}{$textId} || $textId;
	
	if ($m->{buttonIcons} && $m->{env}{userAgent} !~ /MSIE (?:5|6)/) {
		my $nameStr = $name ? "name='$name' value='1'" : "";
		return "<button type='submit' class='isb' $nameStr>"
			. " <img class='bic' src='$m->{cfg}{dataPath}/buttonicons/bic_$icon.png' alt=''/>"
			. " $text</button>\n";
	}
	else {
		# IE<7 submits values of all <buttons>, so don't use them
		my $nameStr = $name ? "name='$name'" : "";
		return "<input type='submit' $nameStr value='$text'/>\n";
	}
}

#------------------------------------------------------------------------------
# Get tag buttons markup for post forms

sub tagButtons
{
	my $m = shift();

	# Shortcuts
	my $cfg = $m->{cfg};

	# Don't print when disabled
	return if $cfg->{tagButtons} < 1;

	# Print script	
	my @lines = ();
	push @lines, <<"EOHTML";
	<script type='text/javascript'>$m->{cdataStart}
		function mwfInsertTags(tag1, tag2) {
			var txta = document.getElementsByName('body')[0];
			txta.focus();

			if (typeof document.selection != 'undefined') {
				var range = document.selection.createRange();
				var sel = range.text;
				range.text = tag2 
					? "[" + tag1 + "]" + sel + "[/" + tag2 + "]"
					: ":" + tag1 + ":";
				range = document.selection.createRange();
				if (tag2 && !sel.length) range.move('character', -tag2.length - 3);
				else if (tag2) range.move('character', tag1.length + 2 + sel.length + tag2.length + 3);
				range.select();
			}
			else if (typeof txta.selectionStart != 'undefined') {
				var scroll = txta.scrollTop;
				var start  = txta.selectionStart;
				var end    = txta.selectionEnd;
				var before = txta.value.substring(0, start);
				var sel    = txta.value.substring(start, end);
				var after  = txta.value.substring(end, txta.textLength);
				txta.value = tag2 
					? before + "[" + tag1 + "]" + sel + "[/" + tag2 + "]" + after
					: before + ":" + tag1 + ":" + after;
				var caret = sel.length == 0
					? start + tag1.length + 2
					: start + tag1.length + 2 + sel.length + tag2.length + 3;
				txta.selectionStart = caret;
				txta.selectionEnd = caret;
				txta.scrollTop = scroll;
			}
		}
	$m->{cdataEnd}</script>
EOHTML

	# Print [tag] buttons
	push @lines,
		"<button type='button' class='tbt' accesskey='b' title='Bold (Alt+B)'",
		" onfocus='document.getElementsByName(\"body\")[0].focus()'",
		" onclick='mwfInsertTags(\"b\",\"b\")'><b>b</b></button>\n",
		"<button type='button' class='tbt' accesskey='i' title='Italic (Alt+I)'",
		" onfocus='document.getElementsByName(\"body\")[0].focus()'",
		" onclick='mwfInsertTags(\"i\",\"i\")'><i>i</i></button>\n",
		"<button type='button' class='tbt' accesskey='t' title='TeleType (Alt+T)'",
		" onfocus='document.getElementsByName(\"body\")[0].focus()'",
		" onclick='mwfInsertTags(\"tt\",\"tt\")'><tt>tt</tt></button>\n",
		"<button type='button' class='tbt' accesskey='w' title='URL (Alt+W)'",
		" onfocus='document.getElementsByName(\"body\")[0].focus()'",
		" onclick='mwfInsertTags(\"url=\",\"url\")'>url</button>\n";

	# Print [img] tag button
	push @lines,
		"<button type='button' class='tbt' accesskey='p' title='Image (Alt+P)'",
		" onfocus='document.getElementsByName(\"body\")[0].focus()'",
		" onclick='mwfInsertTags(\"img\",\"img\")'>img</button>\n"
		if $cfg->{imgTag};

	# Print :tag: buttons
	if ($cfg->{tagButtons} == 2) {
		push @lines, "<br/>\n";
		for (sort keys %{$cfg->{tags}}) {
			push @lines, "<span class='tbc' onclick='mwfInsertTags(\"$_\")'>$cfg->{tags}{$_}</span>\n";
		}
	}

	push @lines, "<font size='1'>For assistance with text markup, please read the <a href='forum_help.pl'>forum help</a>.</font><br>";

	push @lines, "<br/>\n";

	return @lines;
}

#------------------------------------------------------------------------------
# Return hidden standard form fields

sub stdFormFields
{
	my $m = shift();

	my @lines = ();

	push @lines, "<input type='hidden' name='subm' value='1'/>\n";
		
	push @lines, "<input type='hidden' name='auth' value='$m->{user}{sourceAuth}'/>\n"
		if $m->{user} && $m->{user}{sourceAuth};

	push @lines, "<input type='hidden' name='sid' value='$m->{sessionId}'/>\n" 
		if $m->{sessionId};

	my $origin = $m->escHtml($m->paramStr('ori'));
	push @lines, "<input type='hidden' name='ori' value='$origin'/>\n" 
		if $origin;
		
	return @lines;
}


###############################################################################
# Error Functions

#------------------------------------------------------------------------------
# Print error, called by other fatal error functions

sub printError 
{
	my $m = shift();
	my $title = "Forum " . (shift() || $m->{lng}{errGeneric});
	my $msg = shift() || $m->{lng}{errDefault};
	
	die $msg if ($ENV{COMMAND_LINE});

	my $r = $m->{ap};
	# Avoid recursion
	return if $m->{error};
	$m->{error} = 1;

	# Default to English if error came too early for regular language loading
	if (!$m->{lng}{charset}) {
		eval {
			require Forum::MwfEnglish;
			$m->{lng} = $MwfEnglish::lng;
		};
	}

	# Shortcuts
	my $cfg = $m->{cfg};
	my $lng = $m->{lng};

	# Log error
	$m->logError($msg);
	
	# Transaction active?	
	my $transaction = $m->{dbh} && $m->{dbh}{AutoCommit} == 0;
	
	# TUSK begin
	# adding custom error handling.  if we are on a development machine, display errors as usual
	
	if ($m->{redirectError}){
	    die $msg;
	}

	# We are on a development machine, go ahead and print errors to screen.
	if (Apache2::ServerUtil::exists_config_define('DEV') or $msg ne $lng->{errDb}) {
	    if (MP || CGI) {
		# Escape HTML in message
		$msg = $m->escHtml($msg, 2) if MP || CGI;

		# Normal CGI output
		$m->printHeader();

		print
			"<div class='frm err'>\n",
			"<div class='hcl'>\n",
			"<span class='htt'>$title</span>\n",
			"</div>\n",
			"<div class='ccl'>\n",
			"<p>$msg</p>\n",
			"<p>$lng->{errText}</p>\n",
			"</div>\n",
			"</div>\n\n";

		$m->printFooter(undef, 1);
	    }
	    else {
		# Output for cronjobs
		print "$title: $msg";
		$m->{printPhase} = 4;
	    }
	}
	# We are on a production or test machine, print generic error message and email msg.
	else {
		# Normal CGI output
		$m->printHeader();

	    print
		"<div class='frm err'>\n",
		"<div class='hcl'>\n",
		"<span class='htt'>Forum Error</span>\n",
		"</div>\n",
		"<div class='ccl'>\n",
		"<p>$TUSK::Constants::WebError</p>\n",
		"</div>\n",
		"</div>\n\n";

		$m->printFooter(undef, 1);
		ErrorReport::sendErrorReport($r, 
					     {
						 To => $TUSK::Constants::ErrorEmail, 
						 From => $TUSK::Constants::ErrorEmail, 
						 Msg => $msg,
						 uriRequest => $ENV{'SCRIPT_NAME'},
						 }
					     );	    
	}

	# Inside transaction eval block, throw exception to leave and rollback
	die if $transaction;

	# Otherwise exit here
	FCGI ? die : exit;
}

#------------------------------------------------------------------------------
# Print simple note and exit, for cases that don't need full error handling

sub printNote
{
	my $m = shift();
	my $msg = shift() || $m->{lng}{errDefault};

	$m->printHeader();

	print
		"<div class='frm nte'>\n",
		"<div class='hcl'>\n",
		"<span class='htt'>$m->{lng}{errNote}</span>\n",
		"</div>\n",
		"<div class='ccl'>\n",
		"$msg\n",
		"</div>\n",
		"</div>\n\n";

	$m->printFooter();

	FCGI ? die : exit;
}

#------------------------------------------------------------------------------
# User has probably done something wrong

sub userError 
{
	my $m = shift();
	$m->printError($m->{lng}{errUser}, shift());
}

#------------------------------------------------------------------------------
# Database error

sub dbError 
{
	my $m = shift();

	# Default to English if error came too early for regular language loading
	if (!$m->{lng}{charset}) {
		eval {
			require Forum::MwfEnglish;
			$m->{lng} = $MwfEnglish::lng;
		};
	}

	# Prepare error message	
	$m->{query} =~ s!\t!!g;
	$m->{query} =~ s!^\n+!!g;
	$m->{query} =~ s!\n+$!!g;
	$m->{query} =~ s!\n{3,}!\n\n!g;
	my $msg = $m->decUtf8($DBI::errstr) . "\n\n" . $m->{query};

	if ($m->{cfg}{dbHideError} && !$m->{user}{admin}) {
		# Log detailed error message but print basic error message only
		$m->logError($msg);
		$m->printError($m->{lng}{errDb}, $m->{lng}{errDbHidden});
	}
	else {
		# Print detailed error message
		$m->printError($m->{lng}{errDb}, $msg);
	}
}

#------------------------------------------------------------------------------
# CGI parameter missing/empty

sub paramError 
{
	my $m = shift();
	$m->printError($m->{lng}{errParam}, shift());
}

#------------------------------------------------------------------------------
# Database entry not found

sub entryError 
{
	my $m = shift();
	$m->printError($m->{lng}{errEntry}, shift());
}

#------------------------------------------------------------------------------
# User should have been registered for requested action

sub regError 
{
	my $m = shift();
	$m->printError($m->{lng}{errUser}, $m->{lng}{errReg});
}

#------------------------------------------------------------------------------
# User should have been an admin or mod for requested action

sub adminError 
{
	my $m = shift();
	$m->printError($m->{lng}{errUser}, $m->{lng}{errAdmin});
}

#------------------------------------------------------------------------------
# Error probably based on wrong configuration (file path/access etc.)

sub cfgError
{
	my $m = shift();
	$m->printError($m->{lng}{errConfig}, shift());
}

#------------------------------------------------------------------------------
# Problem with form input, add message to list and continue

sub formError
{
	my $m = shift();
	my $errorMsg = shift() || $m->{lng}{errDefault};
	
	# Add message to error list
	push @{$m->{formErrors}}, $errorMsg;
}

#------------------------------------------------------------------------------
# Print form error messages and continue

sub printFormErrors
{
	my $m = shift();

	$m->printHeader();

	print
		"<div class='frm err fer'>\n",
		"<div class='hcl'>\n",
		"<span class='htt'>$m->{lng}{errForm}</span>\n",
		"</div>\n",
		"<div class='ccl'>\n";

	print "<p>$_</p>\n" for @{$m->{formErrors}};
	
	print
		"</div>\n",
		"</div>\n\n";
}

#------------------------------------------------------------------------------
# Log error to webserver log

sub logError
{
	my $m = shift();
	my $msg = shift();
	my $warning = shift();  # Is non-fatal error, print at page bottom

	# Log to webserver log	
	if (MP) {
		$m->{ap}->log_error("[forum] [client $m->{env}{userIp}] $msg");
	}
	elsif (CGI) {
		my $timestamp = FCGI ? "" : ("[".localtime(time())."] [forum] ");
		warn $timestamp . "[client $m->{env}{userIp}]" . $msg;
	}

	# Optionally log to own logfile	
	if ($m->{cfg}{errorLog}) {
		if (open my $fh, '>>', $m->{cfg}{errorLog}) {
			binmode $fh, ':utf8' if $m->{gcfg}{utf8};
			flock $fh, 2;
			seek $fh, 0, 2;
			my $timestamp = $m->formatTime($m->{now});
			print $fh "[$timestamp] [$m->{env}{userIp}] $msg\n";
			close $fh;
		}
	}
	
	# Add to warnings shown at bottom of page (not if script redirects)
	push @{$m->{warnings}}, $msg if $warning;
}


###############################################################################
# Filter Functions

#------------------------------------------------------------------------------
# Escape HTML

sub escHtml
{
	my $m = shift();
	my $text = shift();
	my $newlines = shift() || 0;  # 0 = strip, 1 = ignore, 2 = replace with <br/>

	# Shortcuts
	my $cfg = $m->{cfg};

	# Handle Windows-1252 characters that are not valid in ISO-8859 codepages
	if (!$cfg->{win1252} && !$m->{gcfg}{utf8}) {
		# Translate to ASCII characters
		$text =~ s!€!EUR!g;
		$text =~ s!\x81!!g;
		$text =~ s!‚!'!g;
		$text =~ s!ƒ!NLG!g;
		$text =~ s!„!"!g;
		$text =~ s!…!...!g;
		$text =~ s!†!+!g;
		$text =~ s!‡!++!g;
		$text =~ s!ˆ!^!g;
		$text =~ s!‰!o/oo!g;
		$text =~ s!Š!S!g;
		$text =~ s!‹!<!g;
		$text =~ s!Œ!OE!g;
		$text =~ s!\x8D!!g;
		$text =~ s!\x8E!!g;
		$text =~ s!\x8F!!g;
		$text =~ s!\x90!!g;
		$text =~ s!‘!'!g;
		$text =~ s!’!'!g;
		$text =~ s!“!"!g;
		$text =~ s!”!"!g;
		$text =~ s!•!*!g;
		$text =~ s!–!-!g;
		$text =~ s!—!--!g;
		$text =~ s!˜!~!g;
		$text =~ s!™!(TM)!g;
		$text =~ s!š!s!g;
		$text =~ s!›!>!g;
		$text =~ s!œ!oe!g;
		$text =~ s!\x9d!!g;
		$text =~ s!\x9e!!g;
		$text =~ s!Ÿ!Y!g;
		$text =~ s!\xA0! !g;  # Not really Windows-1252 specific
	}
	elsif ($cfg->{win1252} == 2 && !$m->{gcfg}{utf8}) {
		# Remove all Windows-1252-specific characters
		$text =~ s![\x80-\xA0]!!g;
	}

	# Escape HTML special characters
	$text =~ s!&!&amp;!g;
	$text =~ s!<!&lt;!g;
	$text =~ s!>!&gt;!g;
	$text =~ s!'!&#39;!g;
	$text =~ s!"!&quot;!g;

	# Filter newlines and tabs
	$text =~ s!\n!!g if $newlines == 0;
	$text =~ s!\n!<br/>!g if $newlines == 2;
	$text =~ s!\t!  !g;
	
	# Remove control characters (not valid in XML)
	$text =~ s![\x00-\x09\x0B-\x1F\x7F]!!g;

	return $text;
}

#------------------------------------------------------------------------------
# De-escape HTML

sub deescHtml
{
	my $m = shift();
	my $text = shift();

	# Translate newlines
	$text =~ s!<br/>!\n!g;

	# Decode HTML special chars
	$text =~ s!&#160;! !g;
	$text =~ s!&quot;!"!g;
	$text =~ s!&#39;!'!g;
	$text =~ s!&lt;!<!g;
	$text =~ s!&gt;!>!g;
	$text =~ s!&amp;!&!g;

	return $text;
}

#------------------------------------------------------------------------------
# Translate text for storage in DB

sub editToDb
{
	my $m = shift();
	my $board = shift();
	my $post = shift();

	# Shortcuts
	my $cfg = $m->{cfg};

	# Escape HTML in subject, but don't do full filtering
	$post->{subject} = $m->escHtml($post->{subject});

	# Alias
	$post->{body} ||= "";
	my $text = \$post->{body};

	# Normalize space around quotes
	$$text =~ s!\n*((?:(?:^|\n)>[^\n]*)+)\n*!\n$1\n\n!g;

	# Remove multiple empty lines and empty lines at start and end
	$$text =~ s!\r!!g;
	$$text =~ s!^\n+!!g;
	$$text =~ s!\n+$!!g;
	$$text =~ s!\n{3,}!\n\n!g;

	# Filter bad words
	for my $word (@{$cfg->{censorWords}}) {
		my @chars = split(//, $word);
		my $rx = join("+", @chars);
		$post->{subject} =~ s!$rx!'*' x length($word)!egi;
		$$text =~ s!$rx!'*' x length($word)!egi;
	}
	
	# Escape HTML
	$$text = $m->escHtml($$text, 2);

	# Translate two spaces to "&#160; " for code snippets etc.
	$$text =~ s!  !&#160; !g;
	$$text =~ s!  !&#160; !g;

	# Quotes
	$$text =~ s~(^|<br/>)((?:&gt;).*?)(?=(?:<br/>)+(?!&gt;)|$)~$1<blockquote><p>$2</p></blockquote>~g;
	$$text =~ s~</blockquote>(?:<br/>){2,}~</blockquote><br/>~g;

	# Style tags
	$$text =~ s!\[b\]!<b>!g;
	$$text =~ s!\[/b\]!</b>!g;
	$$text =~ s!\[i\]!<i>!g;
	$$text =~ s!\[/i\]!</i>!g;
	$$text =~ s!\[tt\]!<tt>!g;
	$$text =~ s!\[/tt\]!</tt>!g;

	# Make tags correctly balanced and nested
	for my $pass (1..2) {
		my @stack = ();
		my $dropped = 0;
		$$text =~ s%(<(/?)(blockquote|p|b|i|tt)>)%
			my $tag = $1;
			if (!$2) { push @stack, $3 }
			elsif ($3 eq $stack[-1]) { pop @stack }
			else { $tag = ""; $dropped++ }
			$tag
		%eg;
		if ($pass == 1) {
			while (@stack) { $$text .= "</". pop(@stack) . ">" }
		}
		elsif ($dropped || @stack) {
			$$text =~ s!<!(!g;
			$$text =~ s!>!)!g;
		}
	}
	
	# Do image and URL tags in one pass to avoid interference
	$$text =~ s%
		# Image tags
		\[img\](https?://[^<>\'\"\s\{\}\|\\\^\[\]`]+?)\[/img\]
		| # URL tags without linktext
		\[url=?\]((?:https?|ftp)://[^<>\'\"\s\{\}\|\\\^\[\]`]+?)\[/url\]
		| # URL tags with linktext
		\[url=((?:https?|ftp)://[^<>\'\"\s\{\}\|\\\^\[\]`]+?)\](.+?)\[/url\]
		| # URL autotags
		((?:https?|ftp)://[^<>\'\"\s\{\}\|\\\^\[\]\)`]+)
	%
		if ($1 && !$cfg->{imgTag}) { "[img]${1}[/img]" }
		elsif ($1) { "<img class='emi' src='$1' alt=''/>" }
		elsif ($2) { "<a class='url' href='$2'>$2</a>" }
		elsif ($3) { "<a class='url' href='$3'>$4</a>" }
		elsif ($5) { 
			# Don't include trailing entities in autotagged URLs
			my $all = $5;
			my ($ent) = $all =~ /(&quot;|&gt;|&lt;|&#160;|&#39;)/g;
			my $entPos = $ent ? index($all, $ent, 0) : -1;
			my $url = $ent ? substr($all, 0, $entPos) : $all;
			$entPos > -1
				? "<a class='url' href='$url'>$url</a>" . substr($all, $entPos)
				: "<a class='url' href='$url'>$url</a>";
		}
	%egx;
}

#------------------------------------------------------------------------------
# Translate stored text for editing

sub dbToEdit
{
	my $m = shift();
	my $board = shift();
	my $post = shift();

	# Shortcuts
	my $cfg = $m->{cfg};

	# Alias
	$post->{body} ||= "";
	my $text = \$post->{body};

	# Translate linebreaks
	$$text =~ s!<br/>!\n!g;

	# Translate escaped spaces to normal spaces 
	# (otherwise some browsers convert them to A0 spaces)
	$$text =~ s!&#160;! !g;
	
	# Remove blockquotes
	$$text =~ s!<blockquote><p>!!g;
	$$text =~ s!</p></blockquote>!\n!g;

	# Translate markup tags
	$$text =~ s!<b>![b]!g;
	$$text =~ s!</b>![/b]!g;
	$$text =~ s!<i>![i]!g;
	$$text =~ s!</i>![/i]!g;
	$$text =~ s!<tt>![tt]!g;
	$$text =~ s!</tt>![/tt]!g;
	$$text =~ s!<a class='url' href='(.+?)'>(.+?)</a>![url=$1]${2}[/url]!g;
	$$text =~ s!<img class='emi' src='(.+?)' alt=''/>![img]${1}[/img]!g if $cfg->{imgTag};
}

#------------------------------------------------------------------------------
# Translate stored text for display

sub dbToDisplay
{
	my $m = shift();
	my $board = shift();
	my $post = shift();

	# Shortcuts
	my $cfg = $m->{cfg};
	my $lng = $m->{lng};
	my $user = $m->{user};
	my $script = $m->{env}{script};
	my $imgPath = $m->{stylePath};
	
	# Call text display plugin
	if ($cfg->{msgDisplayPlg}) {
		return if $m->callPlugin($cfg->{msgDisplayPlg}, board => $board, post => $post);
	}

	# Alias
	$post->{body} ||= "";
	my $text = \$post->{body};

	# Attachments
	my $attachments = $post->{attachments};
	if ($attachments && @$attachments) {
		$$text .= "<br/><br/>\n<div class='pat'>\n";
		my $postId = $post->{id};
		my $postIdMod = $postId % 100;
		my $attFsBasePath = "$cfg->{attachFsPath}/$postIdMod/$postId";
		my $attUrlBasePath = "$cfg->{attachUrlPath}/$postIdMod/$postId";
		for my $attach (@$attachments) {
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
				$$text .= $cfg->{attachImgThb} && (-f $thbFsPath || $m->addThumbnail($attFsPath) > 0)
					? "<a href='$attUrlPath'><img class='amt' src='$thbUrlPath' title='$size' alt=''/></a>\n"
					: "<img class='ami' src='$attUrlPath' title='$size' alt=''/>\n";
			}
			else {
				$$text .= "<div class='amf'>$lng->{tpcAttText} "
					. "<a href='$attUrlPath'>$fileName</a> ($size)</div>\n";
			}
		}
		$$text .= "</div>\n";
	}

	# De-embed [img]
	$$text =~ s~<img class='emi' src='([^\']+)' alt=''/>~<a href='$1'>$1</a>~g
		if !$user->{showImages} || $script eq 'forum_overview' || $script eq 'forum_search';
	
	# Signature
	$$text .= "\n" . $cfg->{sigStart} . $post->{signature} . $cfg->{sigEnd}
		if $post->{signature} && $user->{showSigs};
	
	# :Tags:
	$$text =~ s!:([^\s:]+):!
		$cfg->{tags}{$1} ? $cfg->{tags}{$1} : ":$1:";
	!eg if %{$cfg->{tags}};
	
	# Smileys
	if ($cfg->{smileys} && $user->{showDeco}) {
		$$text =~ s~(?<!\w):\-?\)~<img class='sml' src='$imgPath/sml_pos.png' alt=':-)'/>~g;
		$$text =~ s~(?<!\w);\-?\)~<img class='sml' src='$imgPath/sml_wnk.png' alt=';-)'/>~g;
		$$text =~ s~(?<!\w):\-?\(~<img class='sml' src='$imgPath/sml_neg.png' alt=':-('/>~g;
		$$text =~ s~(?<!\w):\-[pP]~<img class='sml' src='$imgPath/sml_tng.png' alt=':-p'/>~g;
		$$text =~ s~(?<!\w):\-[oO]~<img class='sml' src='$imgPath/sml_ooh.png' alt=':-o'/>~g;
		$$text =~ s~(?<!\w):\-D~<img class='sml' src='$imgPath/sml_lol.png' alt=':-D'/>~g;
	}
}	

#------------------------------------------------------------------------------
# Translate stored text for email

sub dbToEmail
{
	my $m = shift();
	my $board = shift();
	my $post = shift();

	# Shortcuts
	my $cfg = $m->{cfg};

	# Alias
	$post->{body} ||= "";
	my $text = \$post->{body};

	# De-escape HTML
	$post->{subject} = $m->deescHtml($post->{subject}) if $post->{subject};
	$$text = $m->deescHtml($$text);

	# Remove blockquotes
	$$text =~ s!<blockquote><p>!!g;
	$$text =~ s!</p></blockquote>!\n!g;

	# Remove markup
	$$text =~ s!<b>!!g;
	$$text =~ s!</b>!!g;
	$$text =~ s!<i>!!g;
	$$text =~ s!</i>!!g;
	$$text =~ s!<tt>!!g;
	$$text =~ s!</tt>!!g;
	$$text =~ s!<a class='url' href='(.+?)'>(.+?)</a>!$2 <$1>!g;
	$$text =~ s!<img class='emi' src='(.+?)' alt=''/>!<Image $1>!g;
} 


###############################################################################
# Low-Level Database Functions

#------------------------------------------------------------------------------
# Connect to MySQL database

sub dbConnect 
{
	my $m = shift();

	# Shortcuts
	my $cfg = $m->{cfg};
	my $dbh = undef;
	
	# Connect
	require DBI;

	if ($cfg->{dbDriver} eq 'mysql' || $cfg->{dbDriver} eq 'mysqlPP') {
		$m->{mysql} = 1;
		my $dbName = $m->{gcfg}{dbName} || $cfg->{dbName};
		$dbh = TUSK::Core::DB::getReadHandle(); 
		$dbh->do("SET NAMES 'utf8'") if $m->{gcfg}{utf8};
		$dbh->do("USE $cfg->{dbName}") if $m->{gcfg}{dbName};
	}
	elsif ($cfg->{dbDriver} eq 'Pg') {
		$m->{pgsql} = 1;
		require Hash::Case::Lower;
		$dbh = DBI->connect(
			"dbi:Pg:dbname=$cfg->{dbName};host=$cfg->{dbServer};$cfg->{dbParam}",
			$cfg->{dbUser}, $cfg->{dbPassword}, 
			{ PrintError => 0, RaiseError => 0, AutoCommit => 1 })
			or $m->dbError();
		if ($m->{gcfg}{utf8}) {
			$dbh->do("SET NAMES 'utf8'");
			$dbh->{pg_enable_utf8} = 1;
		}
	}
	elsif ($cfg->{dbDriver} eq 'SQLite') {
		$m->{sqlite} = 1;
		$dbh = DBI->connect("dbi:SQLite:dbname=$cfg->{dbName}", "", "",
			{ PrintError => 0, RaiseError => 0, AutoCommit => 1 })
			or $m->dbError();
		$dbh->do("PRAGMA short_column_names = 1");
		$dbh->do("PRAGMA synchronous = OFF");
		$dbh->func(1000, 'busy_timeout');
	}
	else { 
		$m->printError("Database Error", "Database driver not supported");
	}
	
	$m->{dbh} = $dbh;

	# Register disconnect handler in case mod_perl is used but not Apache::DBI

	if (MP1 && !defined($Apache::DBI::VERSION)) {
		$m->{ap}->register_cleanup(sub { $dbh->disconnect() });
	}
	elsif (MP2 && !defined($Apache::DBI::VERSION)) {
		$m->{ap}->pool->cleanup_register(sub { $dbh->disconnect() });
	}
}

#------------------------------------------------------------------------------
# Escape string for inclusion in SQL LIKE search statement

sub dbEscLike
{
	my $m = shift();
	my $str = shift();

	$str =~ s!\\!\\\\!;
	$str =~ s!_!\\\_!;
	$str =~ s!%!\\\%!;
	return $str;
}

#------------------------------------------------------------------------------
# Quote string for inclusion in SQL statement

sub dbQuote 
{
	my $m = shift();
	my $str = shift();

	$str = $m->{dbh}->quote($str);
	utf8::decode($str) if $m->{gcfg}{utf8} && !$m->{pgsql} && !utf8::is_utf8($str);
	return $str;
}

#------------------------------------------------------------------------------
# Begin transaction

sub dbBegin
{
	my $m = shift();

	$m->{transaction}++;
	$m->{dbh}->begin_work() if $m->{transaction} == 1;
}

#------------------------------------------------------------------------------
# Commit transaction

sub dbCommit
{
	my $m = shift();

	$m->{dbh}->commit() if $m->{transaction} == 1;
	$m->{transaction}--;
}

#------------------------------------------------------------------------------
# Rollback transaction

sub dbRollback
{
	my $m = shift();

	# Rollback if there really was an active transaction
	if ($m->{dbh}{AutoCommit} == 0) {
		$m->{dbh}->rollback();	
	}
	
	# Print possible unhandled exception
	$m->{printPhase} > 3 or $m->printError("Exception", $@) if MP || CGI;

	# Don't continue
	FCGI ? die : exit;
}

#------------------------------------------------------------------------------
# Execute manipulation query

sub dbDo
{
	my $m = shift();
	$m->{query} = shift();
	my $ignoreError = shift();
	
	push @{$m->{queries}}, $m->{query} if $m->{cfg}{debug} >= 2;
	$m->{queryNum}++;
	my $result = $m->{dbh}->do($m->{query}, @_);
	defined($result) or $m->dbError() if !$ignoreError;
	return $result;
}

#------------------------------------------------------------------------------
# Prepare query

sub dbPrepare
{
	my $m = shift();
	$m->{query} = shift();
	
	my $sth = $m->{dbh}->prepare($m->{query}) or $m->dbError();
	push @{$m->{queries}}, $m->{query} if $m->{cfg}{debug} >= 2;
	return $sth;
}

#------------------------------------------------------------------------------
# Execute prepared query

sub dbExecute
{
	my $m = shift();
	my $sth = shift();
	
	$m->{queryNum}++;
	my $result = $sth->execute(@_);
	defined($result) or $m->dbError();
	return $result;
}

#------------------------------------------------------------------------------
# Get last inserted autoincrement ID

sub dbInsertId
{
	my $m = shift();
	my $table = shift();

	# Shortcuts
	my $cfg = $m->{cfg};

	if ($m->{mysql}) {
		return $m->{dbh}->{mysql_insertid};
	}
	elsif ($m->{pgsql}) {
		return 0 if !$table;
		return scalar $m->fetchArray("SELECT CURRVAL('${table}_id_seq')");
	}
	elsif ($m->{sqlite}) {
		return $m->{dbh}->func('last_insert_rowid');
	}
}

#------------------------------------------------------------------------------
# Fetch one record as array (incl. prepare/execute)

sub fetchArray
{
	my $m = shift();
	$m->{query} = shift();

	my $sth = $m->{dbh}->prepare($m->{query}) or $m->dbError();
	$m->{queryNum}++;
	$sth->execute(@_) or $m->dbError();
	push @{$m->{queries}}, $m->{query} if $m->{cfg}{debug} >= 2;
	my @a = $sth->fetchrow_array();
	if ($m->{gcfg}{utf8} && !$m->{pgsql}) { utf8::decode($_) for @a }

	return @a if wantarray;
	return @a ? $a[0] : undef;
}

#------------------------------------------------------------------------------
# Fetch one record as hash ref (incl. prepare/execute)

sub fetchHash
{
	my $m = shift();
	$m->{query} = shift();

	my $sth = $m->{dbh}->prepare($m->{query}) or $m->dbError();
	$m->{queryNum}++;
	$sth->execute(@_) or $m->dbError();
	push @{$m->{queries}}, $m->{query} if $m->{cfg}{debug} >= 2;

	my $hr = undef;
	if ($m->{pgsql}) {
		$hr = $sth->fetchrow_hashref();
		if ($hr) {
			tie my %h, 'Hash::Case::Lower', $hr;
			$hr = \%h;
		}
	}
	else { 
		$hr = $sth->fetchrow_hashref();
		if ($hr && $m->{gcfg}{utf8}) { 
			utf8::decode($_) for values %$hr 
		}
	}

	return $hr;
}

#------------------------------------------------------------------------------
# Fetch all records as array ref of array refs (incl. prepare/execute)

sub fetchAllArray
{
	my $m = shift();
	$m->{query} = shift();

	my $sth = $m->{dbh}->prepare($m->{query}) or $m->dbError();
	$m->{queryNum}++;
	$sth->execute(@_) or $m->dbError();
	push @{$m->{queries}}, $m->{query} if $m->{cfg}{debug} >= 2;
	my $ar = $sth->fetchall_arrayref();
	if ($m->{gcfg}{utf8} && !$m->{pgsql}) { 
		for (@$ar) { utf8::decode($_) for @$_ } 
	}

	return $ar;
}

#------------------------------------------------------------------------------
# Fetch all records as array ref of hash refs (incl. prepare/execute)

sub fetchAllHash
{
	my $m = shift();
	$m->{query} = shift();

	my $sth = $m->{dbh}->prepare($m->{query}) or $m->dbError();
	$m->{queryNum}++;
	$sth->execute(@_) or $m->dbError();
	push @{$m->{queries}}, $m->{query} if $m->{cfg}{debug} >= 2;

	my $arhr = undef;
	if ($m->{pgsql}) {
		my (@rows, $hr);
		while ($hr = $sth->fetchrow_hashref()) {
			tie my %h, 'Hash::Case::Lower', $hr;	
			push @rows, \%h;
		}
		$arhr = \@rows;
	}
	else { 
		$arhr = $sth->fetchall_arrayref({});
		if ($m->{gcfg}{utf8}) { 
			for (@$arhr) { utf8::decode($_) for values %$_ } 
		}
	}

	return $arhr;
}

###############################################################################
# High-Level Database Functions

#------------------------------------------------------------------------------
# Insert/delete entries in simple relation tables with no extra data

sub setRel
{
	my $m = shift();
	my $set = shift();
	my $table = shift();
	my $key1 = shift();
	my $key2 = shift();
	my $val1 = shift();
	my $val2 = shift();

	# Shortcuts	
	my $cfg = $m->{cfg};

	my $exists = $m->fetchArray("
		SELECT 1 FROM $cfg->{dbPrefix}$table WHERE $key1 = $val1 AND $key2 = $val2");

	if ($set && !$exists) {	
		$m->dbDo("
			INSERT INTO $cfg->{dbPrefix}$table ($key1, $key2) VALUES ($val1, $val2)");
	}
	elsif (!$set && $exists) {
		$m->dbDo("
			DELETE FROM $cfg->{dbPrefix}$table WHERE $key1 = $val1 AND $key2 = $val2");
	}
}

#------------------------------------------------------------------------------
# Update board and topic statistics

sub recalcStats
{
	my $m = shift();
	my $boardId = shift();
	my $topicId = shift() || undef;

	# Shortcuts	
	my $cfg = $m->{cfg};

	# Recalc board stats
	if ($boardId > 0) {	
		my ($postNum, $lastPostTime) = $m->fetchArray("
			SELECT COUNT(*), MAX(postTime) FROM $cfg->{dbPrefix}posts WHERE boardId = $boardId");
		$lastPostTime ||= 0;
	
		$m->dbDo("
			UPDATE $cfg->{dbPrefix}boards SET 
				postNum = $postNum, 
				lastPostTime = $lastPostTime
			WHERE id = $boardId");
	}

	# Recalc topic stats
	if ($topicId) {
		my ($postNum, $lastPostTime) = $m->fetchArray("
			SELECT COUNT(*), MAX(postTime) FROM $cfg->{dbPrefix}posts WHERE topicId = $topicId");
		$lastPostTime ||= 0;
	
		$m->dbDo("
			UPDATE $cfg->{dbPrefix}topics SET 
				postNum = $postNum, 
				lastPostTime = $lastPostTime
			WHERE id = $topicId");
	}
}

#------------------------------------------------------------------------------
# Store persistent variable in "variables" table
# Contains variables like last cronjob runtime and additional user options

sub setVar
{
	my $m = shift();
	my $name = shift();
	my $value = shift();
	my $userId = shift() || 0;

	$m->dbBegin();
	$m->dbDo("
		DELETE FROM $m->{cfg}{dbPrefix}variables
		WHERE name = '$name' 
			AND userId = $userId");
	my $valueQ = $m->dbQuote($value);
	$m->dbDo("
		INSERT INTO $m->{cfg}{dbPrefix}variables (name, userId, value)
		VALUES ('$name', $userId, $valueQ)");
	$m->dbCommit();
}

#------------------------------------------------------------------------------
# Retrieve persistent variable from "variables" table

sub getVar
{
	my $m = shift();
	my $name = shift();
	my $userId = shift() || 0;
	
	my $value = $m->fetchArray("
		SELECT value 
		FROM $m->{cfg}{dbPrefix}variables 
		WHERE name = '$name' 
			AND userId = $userId");

	return $value;
}

#------------------------------------------------------------------------------
# Log action to database

sub logAction
{
	my $m = shift();

	# Shortcuts
	my $cfg = $m->{cfg};

	my $level = shift();	
	my $entity = shift();
	my $action = shift();
	my $userId = shift() || 0;
	my $boardId = shift() || 0;
	my $topicId = shift() || 0;
	my $postId = shift() || 0;
	my $extraId = shift() || 0;

	# Call log/event plugins
	$m->callPlugin($_, 
		level => $level,
		entity => $entity,
		action => $action,
		userId => $userId,
		boardId => $boardId,
		topicId => $topicId,
		postId => $postId,
		extraId => $extraId,
		) for @{$cfg->{logPlg}};

	return if $cfg->{logLevel} < $level;

	# Normal logging
	$m->dbDo("
		INSERT INTO $cfg->{dbPrefix}log (
			level, entity, action, userId, boardId, topicId, postId, extraId, 
			logTime, ip
		) VALUES (
			$level, '$entity', '$action', $userId, $boardId, $topicId, $postId, $extraId, 
			$m->{now}, '$m->{env}{userIp}'
		)");
}

#------------------------------------------------------------------------------
# Add additional info for log entries, referenced with log.extraId
# Could be used for any sort of strings, though.

sub logString
{
	my $m = shift();
	my $string = shift();

	$string =~ /[^\s]+/ or return 0;
	my $stringQ = $m->dbQuote($string);
	$m->dbDo("
		INSERT INTO $m->{cfg}{dbPrefix}logStrings (string) VALUES ($stringQ)");
	
	return $m->dbInsertId("$m->{cfg}{dbPrefix}logStrings");
}

#------------------------------------------------------------------------------
# Delete attachment entry, file and directories

sub deleteAttachment
{
	my $m = shift();
	my $attachId = shift();

	# Shortcuts
	my $cfg = $m->{cfg};
	
	my $attach = $m->fetchHash("
		SELECT postId, fileName FROM $cfg->{dbPrefix}attachments WHERE id = $attachId");
	my $attachFsPath = $m->{cfg}{attachFsPath};
	my $postIdMod = $attach->{postId} % 100;
	my $file = "$attachFsPath/$postIdMod/$attach->{postId}/$attach->{fileName}";
	my $thumbnail = $file;
	$thumbnail =~ s!\.(?:jpg|png|gif)$!.thb.jpg!i;
	unlink $file, $thumbnail;
	rmdir "$attachFsPath/$postIdMod/$attach->{postId}";
	rmdir "$attachFsPath/$postIdMod";
	$m->dbDo("
		DELETE FROM $cfg->{dbPrefix}attachments WHERE id = $attachId");
}

#------------------------------------------------------------------------------
# Delete post and dependent data

sub deletePost
{
	my $m = shift();
	my $postId = shift();
	my $trash = shift() || 0;
	my $hasChildren = shift() || undef;
	my $alone = shift() || undef;

	# Shortcuts
	my $cfg = $m->{cfg};
	my $lng = $m->{lng};

	$m->dbBegin();
	eval {
		# Does post have children?	
		$hasChildren = $m->fetchArray("
			SELECT id IS NOT NULL FROM $cfg->{dbPrefix}posts WHERE parentId = $postId")
			if !defined($hasChildren);
		$alone = 0 if $hasChildren;
	
		# Is post the only one in the topic?
		$alone = $m->fetchArray("
			SELECT parentId = 0 FROM $cfg->{dbPrefix}posts WHERE id = $postId")
			if !defined($alone);
	
		if ($alone) {
			# Delete whole topic if only one post
			my $topicId = $m->fetchArray("
				SELECT topicId FROM $cfg->{dbPrefix}posts WHERE id = $postId");
			$m->deleteTopic($topicId, $trash);
		}
		else {
			# Delete attachments
			my $attachments = $m->fetchAllArray("
				SELECT id FROM $cfg->{dbPrefix}attachments WHERE postId = $postId");
			$m->deleteAttachment($_->[0]) for @$attachments;
	
			# Delete todo entries
			$m->dbDo("
				DELETE FROM $cfg->{dbPrefix}postTodos WHERE postId = $postId");
	
			# Delete reports
			$m->dbDo("
				DELETE FROM $cfg->{dbPrefix}postReports WHERE postId = $postId");
	
			if ($hasChildren) {
				# Only modify post body to preserve thread integrity
				$m->setLanguage($cfg->{language});
				$m->dbDo("
					UPDATE $cfg->{dbPrefix}posts SET body = '$lng->{eptDeleted}' WHERE id = $postId");
				$m->setLanguage();
			}
			else {
				# Delete post
				$m->dbDo("
					DELETE FROM $cfg->{dbPrefix}posts WHERE id = $postId");
			}
		}
	};
	$@ ? $m->dbRollback() : $m->dbCommit();
	
	return $alone;
}

#------------------------------------------------------------------------------
# Delete topic and dependent data

sub deleteTopic
{
	my $m = shift();
	my $topicId = shift();
	my $trash = shift() || 0;

	# Shortcuts
	my $cfg = $m->{cfg};
	my $lng = $m->{lng};
	
	# Get topic
	my ($topicExists, $pollId) = $m->fetchArray("
		SELECT id, pollId FROM $cfg->{dbPrefix}topics WHERE id = $topicId");
	$topicExists or $m->entryError($lng->{errTpcNotFnd});
	
	# Get IDs of posts in topic
	my $posts = $m->fetchAllArray("
		SELECT id FROM $cfg->{dbPrefix}posts WHERE topicId = $topicId");
	my $postIdsStr = join(",", map($_->[0], @$posts));

	$m->dbBegin();
	eval {
		# Delete attachments
		if (!$trash) {
			my $attachments = $m->fetchAllArray("
				SELECT id FROM $cfg->{dbPrefix}attachments WHERE postId IN ($postIdsStr)");
			$m->deleteAttachment($_->[0]) for @$attachments;
		}

		# Delete subscriptions
		$m->dbDo("
			DELETE FROM $cfg->{dbPrefix}topicSubscriptions WHERE topicId = $topicId");

		# Delete poll
		if ($pollId && !$trash) {
			$m->dbDo("
				DELETE FROM $cfg->{dbPrefix}pollVotes WHERE pollId = $pollId");
			$m->dbDo("
				DELETE FROM $cfg->{dbPrefix}pollOptions WHERE pollId = $pollId");
			$m->dbDo("
				DELETE FROM $cfg->{dbPrefix}polls WHERE id = $pollId");
		}

		if ($postIdsStr) {	
			# Delete todo list entries
			$m->dbDo("
				DELETE FROM $cfg->{dbPrefix}postTodos WHERE postId IN ($postIdsStr)");
	
			# Delete report list entries
			$m->dbDo("
				DELETE FROM $cfg->{dbPrefix}postReports WHERE postId IN ($postIdsStr)");
		}
	
		# Delete topic and posts
		if ($trash) {
			$m->dbDo("
				UPDATE $cfg->{dbPrefix}topics SET boardId = $cfg->{trashBoardId} WHERE id = $topicId");
			$m->dbDo("
				UPDATE $cfg->{dbPrefix}posts SET boardId = $cfg->{trashBoardId} WHERE topicId = $topicId");
		}
		else {
			$m->dbDo("
				DELETE FROM $cfg->{dbPrefix}topics WHERE id = $topicId");
			$m->dbDo("
				DELETE FROM $cfg->{dbPrefix}posts WHERE topicId = $topicId");
		}
	};
	$@ ? $m->dbRollback() : $m->dbCommit();
}

#------------------------------------------------------------------------------
# Add notification message to user's list

sub addNote
{
	my $m = shift();
	my $userId = shift();
	my $strId = shift();
	my %params = @_;
	
	return if $userId < 1;
	
	# Moderator action reason
	my $reason = $params{reason};
	delete $params{reason};
	$reason = $m->escHtml($reason);

	# Get message template in user's language
	my $cfg = $m->{cfg};
	my $userLang = $m->fetchArray("
		SELECT language FROM $cfg->{dbPrefix}users WHERE id = $userId");
	$m->setLanguage($userLang);
	my $body = $m->{lng}{$strId} || $strId;
	$body .= " $m->{lng}{notReason} $reason" if $reason;
	$m->setLanguage();

	# Replace parameters
	$body =~ s!\[\[$_\]\]!$params{$_}! for keys %params;
	
	# Insert notifiction
	my $bodyQ = $m->dbQuote($body);	
	$m->dbDo("
		INSERT INTO $cfg->{dbPrefix}notes (userId, sendTime, body)
		VALUES ($userId, $m->{now}, $bodyQ)");
}


###############################################################################
# Email Functions

#------------------------------------------------------------------------------
# Encode MIME header with RFC 2047

sub encWord
{
	my $m = shift();
	my $str = shift();

	if ($str =~ /[^\000-\177]/) {
		if ($m->{gcfg}{utf8}) {
			require Encode;
			$str = Encode::encode('MIME-Q', $str);
		}
		elsif (eval { require MIME::QuotedPrint }) {
			$str = MIME::QuotedPrint::encode($m->encUtf8($str), '');
			$str =~ s! !_!g;
			$str = "=?$m->{cfg}{charset}?Q?$str?=";
			length($str) <= 75 or $m->logError("RFC 2047 word > 75.") if $m->{cfg}{debug};
		}
	}

	return $str;
}

#------------------------------------------------------------------------------
# Create email

sub createEmail
{
	my $m = shift();
	my %params = @_;

	# Shortcuts
	my $cfg = $m->{cfg};
	my $lng = $m->{lng};
	my $user = $params{user};

	my $subject = "";
	my $body = "";

	# User registration email	
	if ($params{type} eq 'userReg') {
		$subject = $cfg->{forumName} . " - " . $lng->{regMailSubj};
		$body = $lng->{regMailT} . "\n\n"
			. $params{url} . "\n\n"
			. $lng->{regMailName} . $user->{userName} . "\n"
			. $lng->{regMailPwd} . $user->{password} . "\n\n"
			. $lng->{regMailT2}
			. ($cfg->{policy} ? "\n\n$cfg->{policyTitle}:\n\n$cfg->{policy}\n\n" : "\n\n");
	}
	# Forgot password ticket
	elsif ($params{type} eq 'fgtPwd') {
		$subject = $cfg->{forumName} . " - " . $lng->{lgiFpwMlSbj};
		$body = $lng->{lgiFpwMlT} . "\n\n" 
			. $params{url} . "\n\n";
	}
	# Email change ticket
	elsif ($params{type} eq 'emlChg') {
		$subject = $cfg->{forumName} . " - " . $lng->{emlChgMlSubj};
		$body = $lng->{emlChgMlT} . "\n\n" . $params{url} . "\n\n";
	}
	# Reply notification email
	elsif ($params{type} eq 'replyNtf') {
		# Set language to recipient's preference	
		$m->setLanguage($user->{language});
		$lng = $m->{lng};

		$params{post}{subject} = $params{topic}{subject};
		$m->dbToEmail($params{board}, $params{post});
		$subject = $cfg->{forumName} . " - " . $lng->{rplEmailSbj};
		$body = $lng->{rplEmailT2} . "\n\n"
			. $lng->{rplEmailUrl} . $params{url} . "\n"
			. $lng->{rplEmailBrd} . $params{board}{title} . "\n"
			. $lng->{rplEmailTpc} . $params{post}{subject} . "\n"
			. $lng->{rplEmailUsr} . $params{replUser}{userName} . "\n\n"
			. $params{post}{body} . "\n\n";

		# Reset language
		$m->setLanguage();
	}
	# Message notification email
	elsif ($params{type} eq 'msgNtf') {
		# Set language to recipient's preference	
		$m->setLanguage($user->{language});
		$lng = $m->{lng};

		$m->dbToEmail($params{board}, $params{msg});
		$subject = $cfg->{forumName} . " - " . $lng->{msaEmailSbj};
		$body = $lng->{msaEmailT2} . "\n\n"
			. $lng->{msaEmailUrl} . $params{url} . "\n"
			. $lng->{msaEmailUsr} . $params{sendUser}{userName} . "\n"
			. $lng->{msaEmailTSbj} . $params{msg}{subject} . "\n\n"
			. $params{msg}{body} . "\n\n";

		# Reset language
		$m->setLanguage();
	}
	# Error
	else { $m->logError("Create email failed: no valid email type specified.") }

	# Return params
	return (user => $params{user}, subject => $subject, body => $body);
}

#------------------------------------------------------------------------------
# Send email

sub sendEmail
{
	my $m = shift();
	my %params = @_;

	# Shortcuts
	my $cfg = $m->{cfg};
	my $lng = $m->{lng};

	# Don't send if params or email address are empty	
	return if !@_;
	return if !$params{user}{email} || $params{user}{dontEmail};

	# Encode
	my $forumName = $m->encWord($cfg->{forumName});
	$params{subject} = $m->encWord($params{subject});
	$params{body} = $m->encUtf8($params{body});

	# Sign and encrypt body
	if ($cfg->{gpgSignKeyId}) {
		my $keyring = "$cfg->{attachFsPath}/keys/$params{user}{id}.gpg";
		my $encrypt = $params{user}{gpgKeyId} && -s $keyring ? 1 : 0;
		my $in = $m->encUtf8($cfg->{gpgSignKeyPwd}) . "\n" . $params{body};
		my $out = "";
		my $err = "";
		my $cmd = [
			"gpg", "--batch",
			$m->{gcfg}{utf8} ? ("--charset" => "utf-8") : (),
			$encrypt ? "--always-trust" : (),
			$encrypt ? ("--keyring" => $keyring) : (),
			$params{user}{gpgCompat} ? "--pgp$params{user}{gpgCompat}" : "--openpgp",
			"--default-key" => $cfg->{gpgSignKeyId},
			"--passphrase-fd" => 0,
			$cfg->{gpgOptions} ? @{$cfg->{gpgOptions}} : (),
			$encrypt 
				? ("--sign", "--encrypt", "--armor", "--recipient" => $params{user}{gpgKeyId}) 
				: "--clearsign",
		];
		my $success = $m->ipcRun($cmd, \$in, \$out, \$err);
		$success or $m->logError("Sign/encrypt failed ($err).");
		$params{body} = $out if $success && $out;
	}

	# Determine sender address
	my $from = "$forumName <$cfg->{forumEmail}>";

	# SMTP
	if ($cfg->{mailer} eq 'SMTP') {
		require Forum::MwfSendmail;
		MwfSendmail::sendmail(
			'smtp' => $cfg->{smtpServer},
			'From' => $from,
			'To' => $params{user}{email},
			'Subject' => $params{subject},
			'Content-Type' => ($params{ctype} || "text/plain") . "; charset=$cfg->{charset}",
			'X-mwForum-BounceAuth' => $params{user}{bounceAuth},
			'Body' => $params{body},	
		) or $m->logError("Send email failed: $MwfSendmail::error");
	}
	elsif ($cfg->{mailer} eq 'ESMTP') {
		require Mail::Sender;
		Mail::Sender->new()->MailMsg({
			'smtp' => $cfg->{smtpServer},
			'from' => $from,
			'to' => $params{user}{email},
			'subject' => $params{subject},
			'ctype' => $params{ctype} || "text/plain",
			'charset' => $cfg->{charset},
			'encoding' => "quoted-printable",
			'headers' => "X-mwForum-BounceAuth: $params{user}{bounceAuth}",
			'auth' => $cfg->{esmtpAuth},
			'authid' => $cfg->{esmtpUser},
			'authpwd' => $cfg->{esmtpPassword},
			'msg' => $params{body},
		}) >= 0 or $m->logError("Send email failed: $Mail::Sender::Error");
	}
	# Local mail or sendmail programs
	elsif ($cfg->{mailer} eq 'mail' || $cfg->{mailer} eq 'sendmail') {
		# Use quoted-printable if possible
		my $qp = 0;
		if (eval { require MIME::QuotedPrint }) {
			$params{body} = MIME::QuotedPrint::encode($params{body}, "\n");
			$qp = 1;
		}

		# Open pipe		
		my $emailPipe = undef;
		if ($cfg->{mailer} eq 'mail') {
			# Address is specified on command line, so for security, do very strict filtering
			my $to = $params{user}{email};
			$to =~ /^[\w\.\-_]+?\@[\w\.\-]+?\.\w{2,}$/ or return 0;

			# Open pipe to mail
			open $emailPipe, "|mail $to" 
				or $m->logError("Send email failed: can't open |mail.");
		}
		else {
		    # Open pipe to sendmail
		    $ENV{PATH} =~ /(.*)/;
		    $ENV{PATH} = $1;
		    
		    open $emailPipe, "|$cfg->{sendmail}" 
			or $m->logError("Send email failed: can't open |sendmail.");
		}

		# Print to pipe
		print $emailPipe
			"From: $from\n",
			"To: $params{user}{email}\n",
			"Subject: $params{subject}\n",
			"MIME-Version: 1.0\n",
			"Content-Type: ", ($params{ctype} || "text/plain"), "; charset=$cfg->{charset}\n",
			"Content-Transfer-Encoding: ", $qp ? "quoted-printable\n" : "8bit\n",
			"X-mwForum-BounceAuth: $params{user}{bounceAuth}\n\n",
			$params{body}, "\n";

		close $emailPipe;
	}
	else { $m->logError("Send email failed: no valid email transport selected.") }
}

#------------------------------------------------------------------------------
# Check email address for blocks and validity

sub checkEmail
{
	my $m = shift();
	my $email = shift();

	# Shortcuts
	my $cfg = $m->{cfg};
	my $lng = $m->{lng};

	# Check length
	length($email) or $m->formError($lng->{errEmlEmpty});
	length($email) >= 6 && length($email) <= 100 
		or $m->formError($lng->{errEmlSize}) if $email;
	
	if ($email) {
		# Check address syntax
		$email =~ /$cfg->{emailRegExp}/ or $m->formError($lng->{errEmlInval});
		$email =~ /^[[:ascii:]]+$/ or $m->formError($lng->{errEmlInval}) if $m->{gcfg}{utf8};
		
		# Some n00bs try to add "www." in front of the address
		$email = lc($email);
		$email !~ /^www\./ or $m->formError($lng->{errEmlInval});
	
		# Check against hostname blocks
		for my $block (@{$cfg->{hostnameBlocks}}) {
			$block = lc($block);
			index($email, $block) < 0 
				or $m->printError($lng->{errBlocked}, $m->{lng}{errBlockEmlT});
		}
	}
}


#------------------------------------------------------------------------------
# Return OK
1;
