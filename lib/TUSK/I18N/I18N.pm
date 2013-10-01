# Copyright 2013 Tufts University 
#
# Licensed under the Educational Community License, Version 1.0 (the "License"); 
# you may not use this file except in compliance with the License. 
# You may obtain a copy of the License at 
#
# http://www.opensource.org/licenses/ecl1.php 
#
# Unless required by applicable law or agreed to in writing, software 
# distributed under the License is distributed on an "AS IS" BASIS, 
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
# See the License for the specific language governing permissions and 
# limitations under the License.

package TUSK::I18N::I18N;

use strict;
use warnings;
use Carp qw(longmess shortmess carp cluck);
use TUSK::Constants;
use POSIX qw (setlocale LC_ALL);
use Apache2::ServerUtil ();
use Apache2::Log;
use Apache2::Const -compile => 'OK';
use Locale::TextDomain ();
use Locale::Messages qw (bindtextdomain textdomain bind_textdomain_codeset);
use TUSK::Application::Email;
use Exporter;
use utf8;
use Encode;
our @ISA = qw(Exporter);

## Using EXPORT_OK ?
our @EXPORT_OK = qw (__ __x __n __p __nx __xn  __px __np __npx $__ %__ 
             N__ N__n N__p N__np);
            
# create some tags to limit name space pollution if desired
our %EXPORT_TAGS = (
		'basic'			=> [ qw(__ __x  __p)],
		'plurals'		=> [ qw( __n __nx __xn __np __npx) ],
		'context'		=> [ qw( __p ) ],
		'dummys'		=> [ qw( N__ N__n N__p N__np ) ]
		
);

# create an :all tag (from perldoc Export)
my %seen = ();
push @{$EXPORT_TAGS{all}}, grep {!$seen{$_}++} @{$EXPORT_TAGS{$_}} foreach keys %EXPORT_TAGS;

# start by turning off gettext translation
BEGIN { $ENV{LANGUAGE} = $ENV{LANG} = "C"; 
}


=head1 NAME

TUSK::I18N::I18N - Internationalisation module.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

	This module extends the functionality of Locale::TextDomain and GNU's gettext.
	It basically exports macro functions into the caller's namespace. 
	These macro's act as interfaces to gettext's methods.
	Some common macros are:
	__()
	__x()

This class relies on Exporter's import method to get things going.

    use TUSK::I18N::I18N;    # exports all macro's
        or
    use TUSK::I18N::I18N qw(:all);
    
    use TUSK::I18N::I18N qw(:basic);    # exports only __() and __x()


=head1 EXPORT

	__() __x() __n() __p() __nx() __xn()  __px() __np() __npx() 
	$__() %__() N__() N__n() N__p() N__np()

=head1 SUBROUTINES/METHODS

=head2 new

	The new function called via the import method that is invoked via 'use'.
	This method while not really needed for static localization will be needed
	for each child process in more dynamic language handling.

=cut
sub new {
	my $class = shift;
	my $self = {
			init	 	=> 0,
			debug		=> 1,
			serverObject	=> undef,             # apache2 server object
			configLangKey	=> 'TUSK_LANGUAGE',   # used by gettext js
			configDomainKey	=> 'TUSK_DOMAIN',     # used by gettext js
			catalog	        => 'locale',          # default can be overwritten in tusk.conf
			category        => 'LC_MESSAGES',     # gettext category we support, static
			serverRoot	=> $TUSK::Constants::ServerRoot || '/usr/local/tusk/current',
			serverObj       => undef,             # server object is used for logging, dir_config, ...
			domain	        => 'tusk', 	      # default for gettext overridden in tusk.conf typically 'tusk'
			language	=> 'C',               # standard gettext default overridden in tusk.conf
			errSubj         => 'I18N Error'
	};
	bless $self, $class;
	$self->init();
	
	return $self;
}

=head2 init

	This method attempts to resolve POSIX setlocal language settings and
	the important defining of paths to the language specific mo (machine object)
	files.
	
=cut
sub init {
	my $this = shift;;	
	$this->serverObject(Apache2::ServerUtil->server);
	$this->setLocaleDomain();
	$this->setCatalog();
	$this->setLanguage();	
	if(! $this->validMoFile) {
	    my $msg = sprintf("Invalid language (%s) catalog [%s.mo] doesn't exist.",
   	    $this->language,$this->domainPath);
	    $this->errorEmail($msg);
	    $this->language('C'); # we don't have a valid language set back to default
	    $this->catalog('');   # remove catalog from search path for performance.
	}
	my $catalog = $this->catalog;
	$ENV{'LANG'} = $ENV{'LC_ALL'} = $ENV{'LANGUAGE'} = $this->language;
	my $domain = $this->domain();
	Locale::TextDomain->import($domain,$catalog);  # this is where we export markup
	my $selected = Locale::Messages->select_package('gettext_pp');
	textdomain($domain);
	my $ok = bindtextdomain $domain => $catalog ;
	#$this->logger("xx bindtextdomain $domain => $catalog = " . $ok ? $ok : 'NG');
	bind_textdomain_codeset $domain => 'utf-8';
        Locale::Messages->turn_utf_8_on(my $utf);
        # try and cache language for gettext javascript
        $this->cache_language();
        my $count = Apache2::ServerUtil::restart_count();	 
#	$this->errorEmail("test startup [$$] ($count)");
	
}

=head2 import

	This is called when involking the 'use' statement.
	It is invollked as follows.
	
		use TUSK::I18N::I18N;  	# imports all @EXPORT_OK methods/variables
		use TUSK::I18N::I18N (); # ignores this function
		use TUSK::I18N::I18N qw(:common) # exports a tag from %EXPORT_TAGS
	
	We redifine out gettext methods and export them into the callers namespace.
	
	Note:  I'm not sure yet why this nessessary when using base, perhaps it is needed 
			to get into the Mason command/component namespace.

=cut
sub import {
    my $caller = caller;
     my $pkg = __PACKAGE__->new();	
    # since we have defined import we need to run export_to_level
     __PACKAGE__->export_to_level(1, @_); 
  }


=head2 cache_lang

	caches current language in dir_config primarily for use downstream
	such as javascript deciding where to read it's catalog file from.
	We use ENV instead of dir_config to cache since this module may be
        called from startup.pl and may nor have access to the server object.

=cut

sub cache_language {
	my $this = shift;
	my $config_key = $this->configkey;
	if(defined($config_key)) {
		my $lang = $this->language;
		if(defined($lang)) {
			my $config_lang = $ENV{$config_key};
			# test if it has changed (?) if so reset.
			if(defined($config_lang)) {
				if($config_lang ne $lang ) {
				#	$this->logger("I18N: Switching $lang to $config_lang" );
					$ENV{$config_key} = $lang;
					}
			} else {
				#$this->logger("I18N:first time setting $config_key => $lang");
				$ENV{$config_key} = $lang;
			}
				
		} else {
			#$this->logger("I18N:Setting to default language");
			$ENV{$config_key} = 'en';
			}
			
	} else {
		$this->logger("I18N: config key not set");
	}
	
}
=head2 errorEmail

	Sends error mail to address listed in $TUSK::Constants::ErrorEmail
=cut
sub errorEmail {
	my ($this,$msg) = @_;
	
	my $count = Apache2::ServerUtil::restart_count();
	if( $count > 1) {
	    my $mailer = TUSK::Application::Email->new({
        		to_addr   => $TUSK::Constants::ErrorEmail,
                from_addr => $TUSK::Constants::ErrorEmail,
                subject   => $this->{errSubj},
                body      => "Error: $msg [$count]"
         });
        $this->logger(sprintf("Mail Error: )%s)",$mailer->getError())) unless($mailer->send());
	}

		
}
=head2 configkey

	Returns the confuguration key to use to set PerSerVar config

=cut

sub configkey {
	my $this = shift;;
	my $key = 'configLangKey';
	$this->{$key} = shift if(@_);
	return($this->{$key});
	
}
=head2 logger

	Define our own logger function for debugging. Under mod_perl this should
	output to error_log using the server object or carp if from command line.

=cut

sub logger {
	my ($this,$msg) = @_;
	return unless($msg);
	if( $this->serverObject) {
		$this->serverObject->log_error("I18n:$msg");
	} else {
		carp("I18N:CARP:$msg");
	}
	
}
=head2 setServerObj
=cut
	
sub setServerObj {
    my $this = shift;
    my $s = undef;
    eval {
        $s = Apache2::ServerUtil->server;
    }; 
	return($this->serverObj($s));
}
  
=head2 serverObj
=cut

sub serverObj {
    my $this = shift;
    my $key = 'serverObj';
  	$this->{$key} = shift if(@_);
	return($this->{$key});
  
}
=head2 setLanguage

	Module to abstract how we set the language. There are typicaly three methods for 
	setting language.
		1) One glocale language for entire site
		2) Users browser controlled via HTTP Accept-Language header value.
		3) User choice using some pulldown menu.
	Currently we only support option #1 set in tusk.conf
=cut
sub setLanguage {
	my $this = shift;;
	my $constKey = "SiteLanguage";
	my $lang = $this->_getI18NConstant($constKey) || 'C';
	$lang 	= 'C' if( $lang eq 'en' || $lang eq "" );
	if( $lang ) {
		$this->language($lang);
	}
}

=head2 language

	This is the setter and getter for the current language locale.

=cut
sub language {
	my $this = shift;;
	my $key = 'language';
	$this->{$key} = shift if(@_);
	return($this->{$key});
}

=head2 debug

	Set on off via 'SiteDebug' in tusk.conf.

=cut
sub debug {
	my $this = shift;;
	my $key = 'debug';
	$this->{$key} = shift if(@_);
	return($this->{$key});
}
=head2 setCatalog

=cut

sub setCatalog {
	my $this = shift;;
	my $constKey = "SiteLocale";
	
	my $catalog = $this->_getI18NConstant($constKey) || $this->catalog;
	my $docRoot = $this->serverRoot();
	$docRoot = $1 if( $docRoot =~ /(.*)\/$/ ); # strip trailing slash for concat below.
	if( $catalog !~ /^\// ) {
			$catalog = $this->serverRoot() . '/' . $catalog; 
		}
	#$this->logger("setCatalog ($catalog)");
	return($this->catalog($catalog));
			
	}

=head2 catalog

	This is the setter and getter for the current language locale.

=cut
sub catalog {
	my $this = shift;;
	my $key = 'catalog';
	$this->{$key} = shift if(@_);
	return($this->{$key});
}
=head2 category

	Getter/setter for gettext category defined as 'LC_MESSAGES'

=cut
sub category {
	my $this = shift;;
	my $key = 'category';
	$this->{$key} = shift if(@_);
	return($this->{$key});
}
=head2 domainPath

    Builds a path used for out .po .mo catalogs
=cut
sub domainPath {
    my $this = shift;
    my $path = sprintf("%s/%s/%s/%s",
	   $this->catalog,$this->language,$this->category,$this->domain);
	return($path);
}
=head2 validMoFile

	Checks if we have a valid <domain>.mo compiled hash index for text lookups.
	This is the compiles hash used by gettext via our markup.

=cut
sub validMoFile {
	my $this = shift;
	my $mo_path = sprintf("%s.mo",$this->domainPath);
	return(1) if( -f $mo_path );
    return(0);
}
=head2 validPoFile

	Checks if we have a valid <domain>.  hash index for javascript markup lookups.
	This is the human readable hash used by gettext.js.

=cut
sub validPoFile {
	my $this = shift;
	my $mo_path = sprintf("%s.po",$this->domainPath);
	return(1) if( -f $mo_path );
    return(0);
}


=head2 setLocaleDomain


=cut
sub setLocaleDomain {
	my $this = shift;;
	my $constKey = "SiteDomain";	
	if($this->_getI18NConstant($constKey)) {
		$this->domain($this->_getI18NConstant($constKey));
	}
	return($this->domain);			
}

=head2 serverObject

=cut
sub serverObject {
	my $this = shift;;
	my $key = 'serverObject';
	$this->{$key} = shift if(@_);
	return($this->{$key});
}
=head2 serverRoot


=cut
sub serverRoot {
	my $this = shift;;
	my $key = 'serverRoot';
	$this->{$key} = shift if(@_);
	return($this->{$key});
}
=head2 domain


=cut
sub domain {
	my $this = shift;;
	my $key = 'domain';
	$this->{$key} = shift if(@_);
	return($this->{$key});
}

=head2 getLanguages


=cut
sub getLanguages {
	my $this = shift;;	
}

=head2 _getI18NConstant


=cut
sub _getI18NConstant {
	my ($this,$key) = @_;
	return undef unless(defined($key));
	if( ! exists($TUSK::Constants::I18N{$key})) {
		$this->logger("NO TUSK::Constants::I18N{$key}");
	}
	if ($TUSK::Constants::I18N{Debug}) {
		$this->logger("NO TUSK::Constants::I18N key $key") unless ( exists($TUSK::Constants::I18N{$key}));
	}
	return undef unless ( exists($TUSK::Constants::I18N{$key}));
	if ($TUSK::Constants::I18N{Debug}) {
		$this->logger("YES TUSK::Constants::I18N key $key = " . $TUSK::Constants::I18N{$key});
	}
	return($TUSK::Constants::I18N{$key});
}

# gettext debug method overrides. To be removed before production
{
no warnings 'redefine';
sub Locale::TextDomain::__x ($@)
			{
			    my ($msgid, %vars) = @_;
			    my $textdomain = 'tusk';
			    my ($msgstr, $substring);
				if ($ENV{LANG} eq 'C') {
			    	$msgstr = Locale::TextDomain::__expand ($msgid, %vars);
			    	$substring = $msgid;
				}
				else {
					$substring = Locale::TextDomain::dgettext $textdomain => $msgid;
			    	$msgstr = Locale::TextDomain::__expand ($substring, %vars);
				}
				if ($TUSK::Constants::I18N{Debug}) {
					if ($substring eq $msgid) {
						carp("I18N: hash: ($msgid, $msgstr) no $ENV{LANG} match") if(0);			     
						$msgstr = "($msgstr)-";
					}
					else {
						$msgstr = "($msgstr)+";
					}		    
				}
			    return $msgstr;
			    return decode("UTF-8",$msgstr);
			};
sub Locale::TextDomain::__ ($)
			{
			    my $msgid = shift;
			    my $package = caller;
			    my $textdomain = 'tusk';
			    my $msgstr;
			    if ($ENV{LANG} eq 'C') {
					$msgstr = $msgid;
				}
				else {
					$msgstr = Locale::TextDomain::dgettext $textdomain => $msgid;
				}
				if ($TUSK::Constants::I18N{Debug}) {
					if ($msgstr eq $msgid ) {
						carp("I18N: string: ($msgid, $msgstr) no $ENV{LANG} match") if(0);
						$msgstr = "($msgstr)-";
					}
					else {
						$msgstr = "($msgid)+";
						carp("I18N: string: ($msgid, $msgstr) yes $ENV{LANG} match") if(0);
					}		    
				}
			    return decode("UTF-8",$msgstr);
			};

}
=head1 AUTHOR

your name here, C<< <your_email at somewhere.com> >>

=head1 BUGS



=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc TUSK::I18N::I18N


You can also look for information at:

=over 4

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2012 your name here.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of TUSK::I18N::I18N

__END__









1;
