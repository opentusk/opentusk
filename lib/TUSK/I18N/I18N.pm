package TUSK::I18N::I18N;
# Notes: turn on strict/warn
# Test if lang dir exists ?
# define defaults hash?

use strict;
use warnings;
use Data::Dumper;
use Carp qw(longmess shortmess carp cluck);
use TUSK::Constants;
use POSIX qw (setlocale LC_ALL);
#use Apache2::RequestRec ();
#use Apache2::RequestUtil;
use Apache2::ServerUtil ();
use Apache2::Log;
use Locale::TextDomain ();
use Locale::Messages qw (bindtextdomain textdomain bind_textdomain_codeset);
use TUSK::Application::Email;
use Exporter;
our @ISA = qw(Exporter);
## need to forcefullfy export mason doesn't like the more polite EXPORT_OK ?
our @EXPORT_OK = qw (__ __x __n __p __nx __xn  __px __np __npx $__ %__ 
             N__ N__n N__p N__np);
            
# create some tags to limit name space pollution if desired
our %EXPORT_TAGS = (
		'basic'			=> [ qw(__ __x  __p)],
		'plurals'		=> [ qw( __n __nx __xn __np __npx) ],
		'context'		=> [ qw( __p ) ],
		'dummys'		=> [ qw( N__ N__n N__p N__np ) ]
		
);
# create a :all (from perldoc Export)
my %seen = ();
push @{$EXPORT_TAGS{all}}, grep {!$seen{$_}++} @{$EXPORT_TAGS{$_}} foreach keys %EXPORT_TAGS;

# start by turning off gettext
BEGIN { $ENV{LANGUAGE} = $ENV{LANG} = "C"; }


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

This class relys on Exporter's import method to get things going.

    use TUSK::I18N::I18N;    # exports all macro's
        or
    use TUSK::I18N::I18N qw(:all);
    
    use TUSK::I18N::I18N qw(:common);    # exports onli __() and __x()


=head1 EXPORT

	__() __x() __n() __p() __nx() __xn()  __px() __np() __npx() 
	$__() %__() N__() N__n() N__p() N__np()

=head1 SUBROUTINES/METHODS

=head2 new

	The new function called via the import method that is involked via 'use'.
	This method while not really needed for static localization will be needed
	for each child process in more dynamic language handling.

=cut
sub new {
	my $class = shift;
	my $self = {
			init		 	=> 0,
			debug			=> 1,
			serverObject	=> undef,  # apache2 server object
			requestObject	=> undef,	# apache2 request object
			configLangKey	=> 'TUSK_LANGUAGE',
			catalog		    => $TUSK::Constants::LexiconRoot,
			serverRoot		=> $TUSK::Constants::ServerRoot || '/usr/local/tusk/current',
			localeDomain	=> 'messages', 	# default for gettext
			lang			=> 'en_US',
			localeMethod	=> 'static' # static = sitewide, dynamin = user/header choice
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
	my $self = shift;	
	$self->serverObject(Apache2::ServerUtil->server);
	$self->setLocaleDomain();
	$self->setCatalog();
	$self->setLanguage();
	$ENV{'LANG'} = $ENV{'LANGUAGE'} = $self->language;
	my $catalog = $self->catalog;
	my $domain = $self->localeDomain();
	warn("pp import($domain,$catalog)");
	Locale::TextDomain->import($domain,$catalog);
	#use Locale::TextDomain $domain, $catalog ;
	my $selected = Locale::Messages->select_package('gettext_pp');
	warn("selected = $selected");
	textdomain($domain);
	my $ok = bindtextdomain $domain => $catalog ;
	warn("xx bindtextdomain $domain => $catalog = " . $ok ? $ok : 'NG');
	bind_textdomain_codeset $domain => 'utf-8';
    Locale::Messages->turn_utf_8_on(my $utf);	
	$self->{init} = 1;
	$self->cache_language();
	#$self->cache_language();
	warn("login = " . __('Login'));
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

=cut

sub cache_language {
	my $this = shift;
	$this->errorEmail("cache language");
	my $s = Apache2::ServerUtil->server;
	my $config_key = $this->configkey;
	if(defined($config_key)) {
		my $lang = $this->language;
		if(defined($lang)) {
			my $config_lang = $s->dir_config($config_key);
			# test if it has changed (?) if so reset.
			if(defined($config_lang)) {
				if($config_lang ne $lang ) {
					warn("I18N: Switching $lang to $config_lang" );
					$s->dir_config($config_key => $lang);
				}
			} else {
				warn("I18N:first time setting $config_key => $lang");
				$s->dir_config($config_key => $lang);
			}
			
		} else {
			warn("I18N:Setting to default language");
			$s->dir_config($config_key => 'en');
		}
		
	} else {
		warn("I18N: config key not set");
	}
	
}
=head2 errorEmail

	Sends error mail to address listed in $TUSK::Constants::ErrorEmail
=cut
sub errorEmail {
	my ($self,$errmsg) = @_;
	my $x = longmess();
	my $count = Apache2::ServerUtil::restart_count();
	$errmsg = sprintf("count = %s",Apache2::ServerUtil::restart_count());
	if($count > 1 ) {
			my $body=<<EOM;
$x
EOM
		my $mailer = TUSK::Application::Email->new({
	        		to_addr   => $TUSK::Constants::ErrorEmail,
	                from_addr => $TUSK::Constants::ErrorEmail,
	                subject   => "Foo",
	                body      => $errmsg
	                });
	     cluck(sprintf("Mail Error: )%s)",$mailer->getError())) unless($mailer->send());
		
	}

       
		
}
=head2 configkey

	Returns the confuguration key to use to set PerSerVar config

=cut

sub configkey {
	my $self = shift;
	my $key = 'configLangKey';
	$self->{$key} = shift if(@_);
	return($self->{$key});
	
}
=head2 logger

	Define our own logger function for debugging. Under mod_perl this should
	output to error_log using the server object or carp if from command line.

=cut

sub logger {
	my ($self,$msg) = @_;
	return unless($msg);
	if( $self->serverObject) {
	#	$self->serverObject->log_error($msg);
	} else {
		carp($msg);
	}
	
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
	my $self = shift;
	my $constKey = "SiteLang";
	my $lang = $self->_getI18NConstant($constKey) || 'C';
	if( $lang ) {
		$self->language($lang);
	}
}

=head2 language

	This is the setter and getter for the current language locale.

=cut
sub language {
	my $self = shift;
	my $key = 'lang';
	$self->{$key} = shift if(@_);
	return($self->{$key});
}

=head2 debug

	Set on off via 'SiteDebug' in tusk.conf.

=cut
sub debug {
	my $self = shift;
	my $key = 'debug';
	$self->{$key} = shift if(@_);
	return($self->{$key});
}
=head2 setCatalog

=cut

sub setCatalog {
	my $self = shift;
	my $constKey = "SiteLocale";
	
	my $catalog = $self->_getI18NConstant($constKey) || "lib/LocalData";
	my $docRoot = $self->serverRoot();
	$docRoot = $1 if( $docRoot =~ /(.*)\/$/ ); # strip trailing slash for concat below.
	if( $catalog !~ /^\// ) {
			$catalog = $self->serverRoot() . '/' . $catalog; 
		}
	$self->logger("setCatalog ($catalog)");
	return($self->catalog($catalog));
			
	}

=head2 catalog

	This is the setter and getter for the current language locale.

=cut
sub catalog {
	my $self = shift;
	my $key = 'catalog';
	$self->{$key} = shift if(@_);
	return($self->{$key});
}

sub setLocaleDomain {
	my $self = shift;
	my $constKey = "SiteDomain";	
	my $domain = $self->_getI18NConstant($constKey) || 'messages';
	return($self->localeDomain($domain));			
	}
	
	
sub _getI18NConstant {
	my ($self,$key) = @_;
	return undef unless(defined($key));
	if( ! exists($TUSK::Constants::I18N{$key})) {
		warn ("NO TUSK::Constants::I18N{$key}");
	}
	warn("NO TUSK::Constants::I18N key $key") unless ( exists($TUSK::Constants::I18N{$key}));
	return undef unless ( exists($TUSK::Constants::I18N{$key}));
	warn("YES TUSK::Constants::I18N key $key = " . $TUSK::Constants::I18N{$key});
	return($TUSK::Constants::I18N{$key});
}
sub serverObject {
	my $self = shift;
	my $key = 'serverObject';
	$self->{$key} = shift if(@_);
	return($self->{$key});
}
sub serverRoot {
	my $self = shift;
	my $key = 'serverRoot';
	$self->{$key} = shift if(@_);
	return($self->{$key});
}
sub localeDomain {
	my $self = shift;
	my $key = 'localeDomain';
	$self->{$key} = shift if(@_);
	return($self->{$key});
}



sub Locale::TextDomain::__x ($@)
			{
			    my ($msgid, %vars) = @_;
			    my $textdomain = 'tusk';
			    my $msgstr = Locale::TextDomain::__expand ((Locale::TextDomain::dgettext $textdomain => $msgid), %vars);
			     if($msgstr eq $msgid) {
			     	carp("I18N: hash: ($msgid, $msgstr) no match from:");			     
			     }			    
			    return $msgstr;
			};
sub Locale::TextDomain::__ ($)
			{
				my $msgid = shift;
			    my $package = caller;
			    my $textdomain = 'tusk';
			    my $msgstr = Locale::TextDomain::dgettext $textdomain => $msgid;
			     if($msgstr eq $msgid) {
			     	carp("I18N: string: ($msgid, $msgstr) no match from: ");
			     }		    
			    return $msgstr;
			};
=head2 function2

=cut

sub function2 {
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
